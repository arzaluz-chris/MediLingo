import SwiftUI

// End-of-lesson celebration: confetti, staggered stat reveal, XP count-up.
struct LessonCompleteView: View {
    let xpEarned: Int
    let accuracy: Double
    let isPerfect: Bool
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sealVisible = false
    @State private var statsVisible = false
    @State private var displayedXP = 0

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()

            VStack(spacing: MLSpacing.lg) {
                Spacer()

                ZStack {
                    Circle()
                        .fill((isPerfect ? Color.mlXP : Color.mlEmerald).opacity(0.14))
                        .frame(width: 148, height: 148)
                    Image(systemName: isPerfect ? "star.circle.fill" : "checkmark.seal.fill")
                        .font(.system(size: 84))
                        .foregroundStyle(isPerfect ? AnyShapeStyle(MLGradient.streak) : AnyShapeStyle(MLGradient.emerald))
                        .symbolRenderingMode(.hierarchical)
                }
                .scaleEffect(sealVisible ? 1 : 0.4)
                .opacity(sealVisible ? 1 : 0)
                .accessibilityHidden(true)

                VStack(spacing: MLSpacing.xs) {
                    Text(isPerfect ? "¡Lección perfecta!" : "¡Lección completada!")
                        .font(MLFont.largeTitle)
                        .foregroundStyle(Color.mlTextPrimary)
                        .multilineTextAlignment(.center)
                    Text(isPerfect ? "Sin un solo error. Nivel experto." : "Buen trabajo, sigue así.")
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)
                }
                .opacity(sealVisible ? 1 : 0)

                HStack(spacing: MLSpacing.md) {
                    statCard(title: "XP ganados", value: "+\(displayedXP)", tint: .mlXP, icon: "bolt.fill")
                    statCard(title: "Precisión", value: "\(Int((accuracy * 100).rounded()))%",
                             tint: .mlEmerald, icon: "target")
                }
                .opacity(statsVisible ? 1 : 0)
                .offset(y: statsVisible ? 0 : 24)

                Spacer()

                MLButton(title: "Continuar") { onContinue() }
                    .opacity(statsVisible ? 1 : 0)
            }
            .padding(MLSpacing.lg)

            MLConfettiView()
        }
        .onAppear { celebrate() }
        .accessibilityElement(children: .contain)
    }

    private func celebrate() {
        MLHaptic.levelUp()
        MLSoundPlayer.play(.lessonComplete)

        guard !reduceMotion else {
            sealVisible = true
            statsVisible = true
            displayedXP = xpEarned
            return
        }

        withAnimation(MLMotion.bouncy.delay(0.15)) { sealVisible = true }
        withAnimation(MLMotion.smooth.delay(0.5)) { statsVisible = true }
        // XP count-up, animated via numericText content transition.
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            let steps = min(20, max(1, xpEarned))
            for step in 1...steps {
                withAnimation(.linear(duration: 0.03)) {
                    displayedXP = xpEarned * step / steps
                }
                try? await Task.sleep(for: .seconds(0.035))
            }
            displayedXP = xpEarned
        }
    }

    private func statCard(title: String, value: String, tint: Color, icon: String) -> some View {
        VStack(spacing: MLSpacing.xs) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(MLFont.statLarge)
                .foregroundStyle(tint)
                .monospacedDigit()
                .contentTransition(.numericText())
                .minimumScaleFactor(0.6)
            Text(title)
                .font(MLFont.caption)
                .foregroundStyle(Color.mlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MLSpacing.lg)
        .mlCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}
