import SwiftUI

// Compact gamification chips (CLAUDE-ios.md § Component Library).

/// Icon + value pill used for streaks, hearts, gems, XP across the app.
struct MLStatPill: View {
    let icon: String
    let value: String
    let tint: Color
    var accessibilityText: String?

    var body: some View {
        HStack(spacing: MLSpacing.xs) {
            Image(systemName: icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(MLFont.subheadline.weight(.bold))
                .foregroundStyle(Color.mlTextPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .padding(.horizontal, MLSpacing.sm + MLSpacing.xs)
        .padding(.vertical, 6)
        .background(tint.opacity(0.14), in: Capsule())
        .accessibilityElement()
        .accessibilityLabel(accessibilityText ?? value)
    }
}

// Hearts remaining.
struct MLHeartDisplay: View {
    let hearts: Int
    var max: Int = 5

    var body: some View {
        MLStatPill(
            icon: hearts > 0 ? "heart.fill" : "heart",
            value: "\(hearts)",
            tint: .mlHearts,
            accessibilityText: "\(hearts) de \(max) corazones",
        )
    }
}

// XP badge.
struct MLXPBadge: View {
    let xp: Int

    var body: some View {
        MLStatPill(
            icon: "bolt.fill",
            value: "\(xp)",
            tint: .mlXP,
            accessibilityText: "\(xp) puntos de experiencia",
        )
    }
}
