import Foundation

// Typed, localized app errors (CLAUDE-ios.md § Error Handling).
// Never force-unwrap; throw a case from here instead.
enum AppError: LocalizedError {
    // Network
    case networkUnavailable
    case serverError(statusCode: Int, message: String)
    case timeout

    // Auth
    case authenticationRequired
    case sessionExpired
    case accountDeleted
    case notImplemented

    // Content
    case contentNotFound
    case contentNotDownloaded
    case exerciseCorrupted

    // Audio
    case microphonePermissionDenied
    case speechNotAvailable
    case audioPlaybackFailed

    // Subscription
    case productNotFound
    case purchaseFailed(String)
    case notPremium

    // Game
    case insufficientHearts
    case insufficientGems

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Some features require connectivity."
        case .serverError(_, let message):
            return message
        case .timeout:
            return "The request timed out. Please try again."
        case .authenticationRequired:
            return "Please sign in to continue."
        case .sessionExpired:
            return "Your session expired. Please sign in again."
        case .accountDeleted:
            return "This account has been deleted."
        case .notImplemented:
            return "This feature is not available yet."
        case .contentNotFound:
            return "We couldn't find that content."
        case .contentNotDownloaded:
            return "This lesson isn't downloaded for offline use."
        case .exerciseCorrupted:
            return "This exercise couldn't be loaded."
        case .microphonePermissionDenied:
            return "Microphone access is needed to practice speaking."
        case .speechNotAvailable:
            return "Speech recognition isn't available right now."
        case .audioPlaybackFailed:
            return "Audio playback failed."
        case .productNotFound:
            return "That subscription isn't available."
        case .purchaseFailed(let reason):
            return reason
        case .notPremium:
            return "This is a Premium feature."
        case .insufficientHearts:
            return "You've run out of hearts! Wait for them to refill or upgrade to Premium."
        case .insufficientGems:
            return "You don't have enough gems."
        }
    }
}
