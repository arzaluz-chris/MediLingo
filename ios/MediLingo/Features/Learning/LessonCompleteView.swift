import SwiftUI

// End-of-lesson summary: XP, accuracy, perfect badge (CLAUDE-ios.md § Learning).
struct LessonCompleteView: View {
    let xpEarned: Int
    let accuracy: Double
    let isPerfect: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: MLSpacing.lg) {
            Spacer()

            Image(systemName: isPerfect ? "star.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(isPerfect ? Color.mlXP : Color.mlSuccess)
                .accessibilityHidden(true)

            Text(isPerfect ? "¡Lección perfecta!" : "¡Lección completada!")
                .font(MLFont.title())
                .foregroundStyle(Color.mlTextPrimary)

            HStack(spacing: MLSpacing.md) {
                statCard(title: "XP", value: "+\(xpEarned)", tint: .mlXP)
                statCard(title: "Precisión", value: "\(Int((accuracy * 100).rounded()))%", tint: .mlSuccess)
            }

            Spacer()

            MLButton(title: "Continuar") { onContinue() }
        }
        .padding(MLSpacing.lg)
    }

    private func statCard(title: String, value: String, tint: Color) -> some View {
        MLCard {
            VStack(spacing: MLSpacing.xs) {
                Text(value)
                    .font(MLFont.title(28))
                    .foregroundStyle(tint)
                    .monospacedDigit()
                Text(title)
                    .font(MLFont.caption())
                    .foregroundStyle(Color.mlTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
