import Foundation
import Supabase

// Supabase-backed gamification. Every balance mutation (XP, hearts, gems,
// quests, achievements, leagues) goes through a SECURITY DEFINER RPC keyed on
// auth.uid(); the client's user_stats/user_inventory/user_daily_quests rows are
// SELECT-only under RLS, so direct writes are impossible by design.
struct SupabaseGamificationRepository: GamificationRepositoryProtocol {
    let client: SupabaseClient

    private func currentUserID() async throws -> UUID {
        try await client.auth.session.user.id
    }

    func getUserStats() async throws -> UserStats {
        let uid = try await currentUserID()
        let row: UserStatsRow = try await client
            .from("user_stats").select().eq("user_id", value: uid).single()
            .execute().value
        return row.toDomain()
    }

    func addXP(_ amount: Int) async throws -> UserStats {
        // Server clamps, updates total/weekly XP + derived level + league tally.
        let row: UserStatsRow = try await client
            .rpc("add_xp", params: ["p_amount": amount])
            .single().execute().value
        return row.toDomain()
    }

    func consumeHeart() async throws -> Int {
        // Server decrements (premium users keep unlimited hearts) and returns the count.
        try await client.rpc("consume_heart").execute().value
    }

    func refillHearts() async throws -> Int {
        // Server applies the "1 heart / 4h" refill and returns the new count.
        try await client.rpc("refill_hearts").execute().value
    }

    func getDailyQuests() async throws -> [DailyQuest] {
        let uid = try await currentUserID()
        let today = Self.dateFormatter.string(from: Date())

        // Server assigns 3 random active quests on first read of the day; we
        // ignore its bare return and re-read joined with the quest definitions.
        _ = try await client.rpc("get_or_assign_daily_quests").execute()

        let assigned: [UserQuestRow] = try await client
            .from("user_daily_quests")
            .select("id, current_value, is_completed, quest_id, daily_quests(id, title, description, quest_type, target_value)")
            .eq("user_id", value: uid)
            .eq("quest_date", value: today)
            .execute().value
        return assigned.compactMap { $0.toDomain() }
    }

    func updateQuestProgress(questType: String, increment: Int) async throws {
        // Server bumps today's incomplete quests of this type and auto-awards
        // xp/gems on completion.
        _ = try await client
            .rpc("update_quest_progress", params: QuestProgressParams(p_quest_type: questType, p_increment: increment))
            .execute()
    }

    func recordActivity(_ activity: String, amount: Int) async throws {
        // Server updates the relevant counter (words_learned / ai_conversations)
        // and bumps the matching quest progress in one round-trip.
        _ = try await client
            .rpc("record_activity", params: ActivityParams(p_activity: activity, p_amount: amount))
            .execute()
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

    func getAchievements() async throws -> [Achievement] {
        let rows: [AchievementRow] = try await client
            .from("achievements").select().order("sort_order")
            .execute().value
        let unlocked = try await getUnlockedAchievements()
        return rows.map { $0.toDomain(isUnlocked: unlocked.contains($0.id)) }
    }

    func getUnlockedAchievements() async throws -> Set<UUID> {
        let uid = try await currentUserID()
        let rows: [UserAchievementRow] = try await client
            .from("user_achievements").select("achievement_id").eq("user_id", value: uid)
            .execute().value
        return Set(rows.map { $0.achievement_id })
    }

    func checkAndUnlockAchievements() async throws -> [Achievement] {
        // Server evaluates stat-based requirements, inserts unlocks, awards
        // their rewards, and returns only the newly unlocked rows.
        let rows: [AchievementRow] = try await client
            .rpc("check_achievements").execute().value
        return rows.map { $0.toDomain(isUnlocked: true) }
    }

    func getLeagueStandings() async throws -> LeagueStandings {
        // Seat the user in an active cohort of their tier (idempotent), then
        // read that cohort's members ranked by weekly XP.
        let leagueID: UUID = try await client.rpc("join_league").single().execute().value

        let league: LeagueTierRow = try await client
            .from("leagues").select("tier").eq("id", value: leagueID).single()
            .execute().value

        let rows: [LeagueMemberRow] = try await client
            .from("league_members")
            .select("user_id, weekly_xp, rank, profiles(display_name)")
            .eq("league_id", value: leagueID)
            .order("weekly_xp", ascending: false)
            .execute().value

        let members = rows.enumerated().map { index, row in
            LeagueMember(
                id: row.user_id,
                displayName: row.profiles?.display_name ?? "",
                weeklyXP: row.weekly_xp,
                rank: row.rank ?? index + 1,
            )
        }
        return LeagueStandings(tier: league.tier, members: members)
    }

    func getShopItems() async throws -> [ShopItem] {
        let uid = try await currentUserID()
        let items: [ShopItemRow] = try await client
            .from("shop_items").select().eq("is_available", value: true).order("sort_order")
            .execute().value
        let inventory: [InventoryRow] = try await client
            .from("user_inventory").select("item_id, quantity").eq("user_id", value: uid)
            .execute().value
        let owned = Dictionary(inventory.map { ($0.item_id, $0.quantity) }, uniquingKeysWith: +)
        return items.map { $0.toDomain(owned: owned[$0.id] ?? 0) }
    }

    func purchase(itemID: UUID) async throws -> UserStats {
        // Atomic server purchase: row lock, price/max-owned checks, gem deduct,
        // inventory upsert, immediate power-up effects. Returns updated stats.
        let row: UserStatsRow = try await client
            .rpc("purchase_item", params: ["p_item_id": itemID.uuidString])
            .single().execute().value
        return row.toDomain()
    }
}

// MARK: - Row DTOs

private struct UserStatsRow: Decodable {
    let total_xp: Int
    let level: Int
    let current_streak: Int
    let longest_streak: Int
    let hearts: Int
    let hearts_max: Int
    let gems: Int
    let coins: Int
    let lessons_completed: Int
    let words_learned: Int
    let current_league: String
    let weekly_xp: Int

    func toDomain() -> UserStats {
        UserStats(totalXP: total_xp, level: level, currentStreak: current_streak,
                  longestStreak: longest_streak, hearts: hearts, heartsMax: hearts_max,
                  gems: gems, coins: coins, lessonsCompleted: lessons_completed,
                  wordsLearned: words_learned, currentLeague: current_league, weeklyXP: weekly_xp)
    }
}

private struct AchievementRow: Decodable {
    let id: UUID
    let slug: String
    let title: String
    let description: String
    let category: String
    let xp_reward: Int
    let gem_reward: Int
    func toDomain(isUnlocked: Bool) -> Achievement {
        Achievement(id: id, slug: slug, title: title, description: description,
                    category: category, xpReward: xp_reward, gemReward: gem_reward,
                    isUnlocked: isUnlocked)
    }
}

private struct UserAchievementRow: Decodable {
    let achievement_id: UUID
}

private struct QuestRow: Decodable {
    let id: UUID
    let title: String
    let description: String
    let quest_type: String
    let target_value: Int
}

private struct UserQuestRow: Decodable {
    let id: UUID
    let current_value: Int
    let is_completed: Bool
    let quest_id: UUID
    let daily_quests: QuestRow?
    func toDomain() -> DailyQuest? {
        guard let q = daily_quests else { return nil }
        return DailyQuest(id: quest_id, title: q.title, description: q.description,
                          questType: q.quest_type, targetValue: q.target_value,
                          currentValue: current_value, isCompleted: is_completed)
    }
}

private struct QuestProgressParams: Encodable {
    let p_quest_type: String
    let p_increment: Int
}

private struct ActivityParams: Encodable {
    let p_activity: String
    let p_amount: Int
}

private struct LeagueTierRow: Decodable { let tier: String }

private struct ProfileNameRow: Decodable { let display_name: String }

private struct LeagueMemberRow: Decodable {
    let user_id: UUID
    let weekly_xp: Int
    let rank: Int?
    let profiles: ProfileNameRow?
}

private struct ShopItemRow: Decodable {
    let id: UUID
    let slug: String
    let title: String
    let description: String
    let category: String
    let price_gems: Int
    let max_owned: Int?
    func toDomain(owned: Int) -> ShopItem {
        ShopItem(id: id, slug: slug, title: title, description: description,
                 category: category, priceGems: price_gems, owned: owned, maxOwned: max_owned)
    }
}

private struct InventoryRow: Decodable {
    let item_id: UUID
    let quantity: Int
}
