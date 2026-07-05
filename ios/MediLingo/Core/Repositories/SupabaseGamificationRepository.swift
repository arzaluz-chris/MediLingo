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
        // TODO(phase-2): join user_daily_quests for today with the quest pool.
        []
    }

    func updateQuestProgress(questID: UUID, increment: Int) async throws {}

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
        // TODO(phase-2): leagues are post-MVP.
        LeagueStandings(tier: "bronze", members: [])
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
