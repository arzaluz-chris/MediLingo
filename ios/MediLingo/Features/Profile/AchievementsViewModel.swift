import SwiftUI

// Loads the achievement catalog with unlock state, grouped by category.
@MainActor
@Observable
final class AchievementsViewModel {
    struct Group {
        let category: String
        let achievements: [Achievement]
    }

    var groups: [Group] = []
    var isLoading = false
    var errorMessage: String?

    private let gamification: GamificationRepositoryProtocol

    init(gamification: GamificationRepositoryProtocol) {
        self.gamification = gamification
    }

    var totalCount: Int { groups.reduce(0) { $0 + $1.achievements.count } }
    var unlockedCount: Int {
        groups.reduce(0) { $0 + $1.achievements.filter(\.isUnlocked).count }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let all = try await gamification.getAchievements()
            // Preserve the server's sort_order inside each category; order the
            // categories by their first appearance.
            var order: [String] = []
            var buckets: [String: [Achievement]] = [:]
            for achievement in all {
                if buckets[achievement.category] == nil { order.append(achievement.category) }
                buckets[achievement.category, default: []].append(achievement)
            }
            groups = order.map { Group(category: $0, achievements: buckets[$0] ?? []) }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func categoryDisplayName(_ category: String) -> String {
        switch category {
        case "streak": "Rachas"
        case "learning", "lessons": "Aprendizaje"
        case "vocabulary", "words": "Vocabulario"
        case "social": "Social"
        case "special": "Especiales"
        case "xp", "level": "Progreso"
        default: category.capitalized
        }
    }
}
