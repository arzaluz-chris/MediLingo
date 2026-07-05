import SwiftUI

// Profile screen state: aggregate stats + flashcard progress (CLAUDE-ios.md § Profile).
@MainActor
@Observable
final class ProfileViewModel {
    var stats: UserStats = .empty
    var profile: Profile?
    var flashcards: FlashcardStats = FlashcardStats(due: 0, learned: 0, mastered: 0)
    var isLoading = false

    private let gamification: GamificationRepositoryProtocol
    private let profiles: ProfileRepositoryProtocol
    private let flashcardRepo: FlashcardRepositoryProtocol

    init(gamification: GamificationRepositoryProtocol,
         profiles: ProfileRepositoryProtocol,
         flashcardRepo: FlashcardRepositoryProtocol) {
        self.gamification = gamification
        self.profiles = profiles
        self.flashcardRepo = flashcardRepo
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        async let s = try? await gamification.getUserStats()
        async let p = try? await profiles.fetchProfile()
        async let f = try? await flashcardRepo.getStats()
        stats = (await s) ?? .empty
        profile = await p ?? nil
        flashcards = (await f) ?? FlashcardStats(due: 0, learned: 0, mastered: 0)
    }
}
