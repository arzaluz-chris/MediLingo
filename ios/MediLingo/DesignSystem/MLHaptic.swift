import UIKit

// Centralized haptic feedback (CLAUDE-ios.md § Haptic Feedback).
enum MLHaptic {
    static func correct() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func incorrect() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func levelUp() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func achievement() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
