import Foundation

// Profile + onboarding persistence.
protocol ProfileRepositoryProtocol: Sendable {
    func isOnboardingComplete() async throws -> Bool
    func saveOnboarding(role: String, englishLevel: String, goal: String, dailyGoalXP: Int) async throws
    func fetchProfile() async throws -> Profile?
}

// Minimal profile projection for the app.
struct Profile: Sendable {
    let id: UUID
    var displayName: String
    var role: String
    var englishLevel: String
    var isPremium: Bool
}
