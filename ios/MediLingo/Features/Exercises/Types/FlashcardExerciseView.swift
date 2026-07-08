import SwiftUI

// A study flashcard inside a lesson: reveal the back, then continue.
// (The dedicated SM-2 review flow lives in Features/Flashcards.)
// The card flips in 3D; Reduce Motion swaps to a crossfade.
struct FlashcardExerciseView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    private var meta: FlashcardMeta {
        ExerciseMetadata.decode(FlashcardMeta.self, from: exercise.metadataJSON, fallback: .default)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: MLSpacing.lg) {
                    Text(exercise.prompt)
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)

                    flipCard
                        .onTapGesture { flip() }
                }
                .padding(MLSpacing.md)
            }
            MLButton(title: revealed ? "Continuar" : "Mostrar respuesta") {
                if revealed {
                    onComplete(ExerciseResult(isCorrect: true, xpEarned: exercise.xpReward, explanation: exercise.explanation))
                } else {
                    flip()
                }
            }
            .padding(MLSpacing.md)
        }
    }

    private func flip() {
        MLHaptic.medium()
        if reduceMotion {
            revealed.toggle()
        } else {
            withAnimation(MLMotion.smooth) { revealed.toggle() }
        }
    }

    private var flipCard: some View {
        ZStack {
            face(front: true)
                .opacity(revealed ? 0 : 1)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : (revealed ? 180 : 0)), axis: (x: 0, y: 1, z: 0))
            face(front: false)
                .opacity(revealed ? 1 : 0)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : (revealed ? 0 : -180)), axis: (x: 0, y: 1, z: 0))
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Toca para voltear la tarjeta")
    }

    @ViewBuilder
    private func face(front: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: MLRadius.xl, style: .continuous)
        VStack(spacing: MLSpacing.md) {
            if front {
                Text(meta.front.text.isEmpty ? exercise.prompt : meta.front.text)
                    .font(MLFont.largeTitle)
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.center)
                if let subtext = meta.front.subtext {
                    Text(subtext)
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextTertiary)
                }
                Label("Toca para voltear", systemImage: "hand.tap.fill")
                    .font(MLFont.caption)
                    .foregroundStyle(Color.mlTextTertiary)
                    .padding(.top, MLSpacing.sm)
            } else {
                Text(meta.back.text.isEmpty ? (exercise.correctAnswer ?? "") : meta.back.text)
                    .font(MLFont.title)
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.center)
                if let translation = meta.back.translation {
                    Text(translation)
                        .font(MLFont.bodyMedium)
                        .foregroundStyle(Color.mlCyan)
                }
                if let example = meta.back.example {
                    Text(example)
                        .font(MLFont.subheadline)
                        .italic()
                        .foregroundStyle(Color.mlTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(MLSpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(Color.mlSurface)
        .clipShape(shape)
        .overlay(
            shape.strokeBorder(
                front ? Color.mlCardStroke : Color.mlCyan.opacity(0.35),
                lineWidth: front ? 1 : 1.5,
            )
        )
        .mlShadow(.card)
    }
}
