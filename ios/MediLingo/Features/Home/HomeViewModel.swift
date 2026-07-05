import SwiftUI

// Home dashboard state. Phase 0 loads user stats; widgets render in Phase 1.
@MainActor
@Observable
final class HomeViewModel {
    var stats: UserStats = .empty
    var quests: [DailyQuest] = []
    var isLoading = false

    private let gamification: GamificationRepositoryProtocol

    init(gamification: GamificationRepositoryProtocol) {
        self.gamification = gamification
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        stats = (try? await gamification.getUserStats()) ?? .empty
        quests = (try? await gamification.getDailyQuests()) ?? []
    }
}
