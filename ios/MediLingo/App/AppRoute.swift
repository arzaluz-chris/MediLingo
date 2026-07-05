import Foundation

// Type-safe navigation destinations (CLAUDE-ios.md § Navigation).
enum AppRoute: Hashable {
    case courseDetail(Course)
    case lesson(Lesson)
    case exercise(Exercise)
    case flashcardReview
    case aiConversation(ConversationType)
    case clinicalCase(ClinicalCase)
    case profile
    case settings
    case achievements
    case leaderboard
    case friends
    case shop
    case subscription
}
