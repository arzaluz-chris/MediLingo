import UIKit

// Centralized haptic feedback (CLAUDE-ios.md § Haptic Feedback).
// Micro-interactions only — every haptic maps to a meaningful state change.
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
    /// Picker-style selection change (option tiles, quality buttons).
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    /// Weightier impact for significant moments (card flip, lesson start).
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func levelUp() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func achievement() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
