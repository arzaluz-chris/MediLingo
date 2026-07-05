import SwiftUI

// Hearts remaining (CLAUDE-ios.md § Component Library).
struct MLHeartDisplay: View {
    let hearts: Int
    var max: Int = 5

    var body: some View {
        HStack(spacing: MLSpacing.xs) {
            Image(systemName: hearts > 0 ? "heart.fill" : "heart")
                .foregroundStyle(Color.mlHearts)
            Text("\(hearts)")
                .font(MLFont.caption(15))
                .foregroundStyle(Color.mlTextPrimary)
                .monospacedDigit()
        }
        .accessibilityLabel("\(hearts) de \(max) corazones")
    }
}

// XP badge (CLAUDE-ios.md § Component Library).
struct MLXPBadge: View {
    let xp: Int

    var body: some View {
        HStack(spacing: MLSpacing.xs) {
            Image(systemName: "bolt.fill").foregroundStyle(Color.mlXP)
            Text("\(xp)")
                .font(MLFont.caption(15))
                .foregroundStyle(Color.mlTextPrimary)
                .monospacedDigit()
        }
        .accessibilityLabel("\(xp) puntos de experiencia")
    }
}
