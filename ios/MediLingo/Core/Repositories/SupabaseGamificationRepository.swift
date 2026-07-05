import Foundation
import Supabase

// Supabase-backed gamification. XP/heart mutations are read-modify-write for
// Phase 1; move to atomic RPCs (and server-side XP verification) in Phase 3.
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
        let uid = try await currentUserID()
        var stats = try await getUserStats()
        let newXP = stats.totalXP + amount
        let newWeekly = stats.weeklyXP + amount
        try await client.from("user_stats")
            .update(["total_xp": newXP, "weekly_xp": newWeekly])
            .eq("user_id", value: uid)
            .execute()
        stats.totalXP = newXP
        stats.weeklyXP = newWeekly
        return stats
    }

    func consumeHeart() async throws -> Int {
        let uid = try await currentUserID()
        let stats = try await getUserStats()
        let remaining = max(0, stats.hearts - 1)
        try await client.from("user_stats")
            .update(["hearts": remaining])
            .eq("user_id", value: uid)
            .execute()
        return remaining
    }

    func refillHearts() async throws -> Int {
        let uid = try await currentUserID()
        // Server function applies the "1 heart / 4h" refill and returns the new count.
        let hearts: Int = try await client
            .rpc("refill_hearts", params: ["p_user_id": uid.uuidString])
            .execute().value
        return hearts
    }

    func getDailyQuests() async throws -> [DailyQuest] {
        let uid = try await currentUserID()
        let today = Self.dateFormatter.string(from: Date())

        // Assigned quests for today (joined with the quest definition).
        var assigned: [UserQuestRow] = try await client
            .from("user_daily_quests")
            .select("id, current_value, is_completed, quest_id, daily_quests(id, title, description, quest_type, target_value)")
            .eq("user_id", value: uid)
            .eq("quest_date", value: today)
            .execute().value

        // First visit today → assign 3 random active quests.
        if assigned.isEmpty {
            let pool: [QuestRow] = try await client
                .from("daily_quests").select("id, title, description, quest_type, target_value")
                .eq("is_active", value: true)
                .execute().value
            let picks = Array(pool.shuffled().prefix(3))
            if !picks.isEmpty {
                let rows = picks.map { AssignQuest(user_id: uid, quest_id: $0.id, quest_date: today) }
                try await client.from("user_daily_quests").insert(rows).execute()
                assigned = try await client
                    .from("user_daily_quests")
                    .select("id, current_value, is_completed, quest_id, daily_quests(id, title, description, quest_type, target_value)")
                    .eq("user_id", value: uid).eq("quest_date", value: today)
                    .execute().value
            }
        }
        return assigned.compactMap { $0.toDomain() }
    }

    func updateQuestProgress(questID: UUID, increment: Int) async throws {
        let uid = try await currentUserID()
        let today = Self.dateFormatter.string(from: Date())
        let rows: [UserQuestProgressRow] = try await client
            .from("user_daily_quests")
            .select("id, current_value, quest_id, daily_quests(target_value)")
            .eq("user_id", value: uid).eq("quest_date", value: today).eq("quest_id", value: questID)
            .execute().value
        guard let row = rows.first else { return }
        let newValue = row.current_value + increment
        let completed = newValue >= (row.daily_quests?.target_value ?? Int.max)
        try await client.from("user_daily_quests")
            .update(QuestProgressUpdate(current_value: newValue, is_completed: completed))
            .eq("id", value: row.id)
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
        // TODO(phase-2): call the check-achievements Edge Function.
        []
    }

    func getLeagueStandings() async throws -> LeagueStandings {
        // TODO(phase-4): leagues are post-MVP.
        LeagueStandings(tier: "bronze", members: [])
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
        let uid = try await currentUserID()
        let itemRows: [ShopItemRow] = try await client
            .from("shop_items").select().eq("id", value: itemID).limit(1).execute().value
        guard let item = itemRows.first else { throw AppError.contentNotFound }

        var stats = try await getUserStats()
        guard stats.gems >= item.price_gems else { throw AppError.insufficientGems }

        // Deduct gems.
        let newGems = stats.gems - item.price_gems
        try await client.from("user_stats").update(["gems": newGems]).eq("user_id", value: uid).execute()
        stats.gems = newGems

        // Add to inventory (increment quantity if already owned).
        let existing: [InventoryRow] = try await client
            .from("user_inventory").select("item_id, quantity").eq("user_id", value: uid).eq("item_id", value: itemID).limit(1)
            .execute().value
        if let current = existing.first {
            try await client.from("user_inventory")
                .update(["quantity": current.quantity + 1]).eq("user_id", value: uid).eq("item_id", value: itemID).execute()
        } else {
            try await client.from("user_inventory").insert(InventoryInsert(user_id: uid, item_id: itemID, quantity: 1)).execute()
        }
        return stats
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

private struct AssignQuest: Encodable {
    let user_id: UUID
    let quest_id: UUID
    let quest_date: String
}

private struct QuestTargetRow: Decodable { let target_value: Int }

private struct UserQuestProgressRow: Decodable {
    let id: UUID
    let current_value: Int
    let quest_id: UUID
    let daily_quests: QuestTargetRow?
}

private struct QuestProgressUpdate: Encodable {
    let current_value: Int
    let is_completed: Bool
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

private struct InventoryInsert: Encodable {
    let user_id: UUID
    let item_id: UUID
    let quantity: Int
}
