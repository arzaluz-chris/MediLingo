import SwiftUI

// Drives a spaced-repetition review session (CLAUDE-ios.md § Flashcards).
@MainActor
@Observable
final class FlashcardReviewViewModel {
    // SM-2 quality mapped from the four rating buttons.
    enum Rating: Int { case again = 1, hard = 3, good = 4, easy = 5 }

    var cards: [FlashcardItem] = []
    var index = 0
    var revealed = false
    var reviewedCount = 0
    var isLoading = false
    var errorMessage: String?

    private let flashcards: FlashcardRepositoryProtocol

    init(flashcards: FlashcardRepositoryProtocol) {
        self.flashcards = flashcards
    }

    var current: FlashcardItem? { index < cards.count ? cards[index] : nil }
    var isDone: Bool { !cards.isEmpty && index >= cards.count }
    var progress: Double { cards.isEmpty ? 0 : Double(index) / Double(cards.count) }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            cards = try await flashcards.getDueFlashcards(limit: 20)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func rate(_ rating: Rating) {
        guard let card = current else { return }
        MLHaptic.tap()
        reviewedCount += 1
        Task { try? await flashcards.submitReview(vocabularyID: card.vocabularyID, quality: rating.rawValue) }
        revealed = false
        index += 1
    }
}
