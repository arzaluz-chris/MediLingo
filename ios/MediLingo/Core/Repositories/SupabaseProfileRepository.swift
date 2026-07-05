import Foundation
import Supabase

// Supabase-backed profile + onboarding writes.
struct SupabaseProfileRepository: ProfileRepositoryProtocol {
    let client: SupabaseClient

    private func currentUserID() async throws -> UUID {
        try await client.auth.session.user.id
    }

    func isOnboardingComplete() async throws -> Bool {
        let uid = try await currentUserID()
        let rows: [OnboardingRow] = try await client
            .from("user_onboarding").select("completed").eq("user_id", value: uid).limit(1)
            .execute().value
        return rows.first?.completed ?? false
    }

    func saveOnboarding(role: String, englishLevel: String, goal: String, dailyGoalXP: Int) async throws {
        let uid = try await currentUserID()
        // Persist the choices on the profile…
        try await client.from("profiles").update([
            "role": role,
            "english_level": englishLevel,
            "primary_goal": goal,
        ]).eq("id", value: uid).execute()
        try await client.from("profiles").update(["daily_goal_xp": dailyGoalXP]).eq("id", value: uid).execute()
        // …and mark onboarding complete.
        try await client.from("user_onboarding").update(OnboardingComplete(
            completed: true, step_completed: 5, completed_at: ISO8601DateFormatter().string(from: Date()),
        )).eq("user_id", value: uid).execute()
    }

    func fetchProfile() async throws -> Profile? {
        let uid = try await currentUserID()
        let rows: [ProfileRow] = try await client
            .from("profiles").select("id,display_name,role,english_level,is_premium").eq("id", value: uid).limit(1)
            .execute().value
        return rows.first?.toDomain()
    }
}

private struct OnboardingRow: Decodable { let completed: Bool }

private struct OnboardingComplete: Encodable {
    let completed: Bool
    let step_completed: Int
    let completed_at: String
}

private struct ProfileRow: Decodable {
    let id: UUID
    let display_name: String
    let role: String
    let english_level: String
    let is_premium: Bool
    func toDomain() -> Profile {
        Profile(id: id, displayName: display_name, role: role, englishLevel: english_level, isPremium: is_premium)
    }
}
