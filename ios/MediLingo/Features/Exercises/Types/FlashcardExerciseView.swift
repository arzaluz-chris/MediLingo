import SwiftUI

// A study flashcard inside a lesson: reveal the back, then continue.
// (The dedicated SM-2 review flow lives in Features/Flashcards.)
struct FlashcardExerciseView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var revealed = false

    private var meta: FlashcardMeta {
        ExerciseMetadata.decode(FlashcardMeta.self, from: exercise.metadataJSON, fallback: .default)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: MLSpacing.lg) {
                    Text(exercise.prompt)
                        .font(MLFont.caption())
                        .foregroundStyle(Color.mlTextSecondary)

                    card
                        .onTapGesture { withAnimation(.spring) { revealed.toggle() } }
                }
                .padding(MLSpacing.md)
            }
            MLButton(title: revealed ? "Continuar" : "Mostrar respuesta") {
                if revealed {
                    onComplete(ExerciseResult(isCorrect: true, xpEarned: exercise.xpReward, explanation: exercise.explanation))
                } else {
                    withAnimation(.spring) { revealed = true }
                }
            }
            .padding(MLSpacing.md)
        }
    }

    private var card: some View {
        VStack(spacing: MLSpacing.md) {
            if revealed {
                Text(meta.back.text.isEmpty ? (exercise.correctAnswer ?? "") : meta.back.text)
                    .font(MLFont.title(26))
                    .foregroundStyle(Color.mlTextPrimary)
                if let translation = meta.back.translation {
                    Text(translation).font(MLFont.body()).foregroundStyle(Color.mlSecondary)
                }
                if let example = meta.back.example {
                    Text(example).font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
                }
            } else {
                Text(meta.front.text.isEmpty ? exercise.prompt : meta.front.text)
                    .font(MLFont.title(28))
                    .foregroundStyle(Color.mlTextPrimary)
                if let subtext = meta.front.subtext {
                    Text(subtext).font(MLFont.caption()).foregroundStyle(Color.mlTextTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(MLSpacing.lg)
        .background(Color.mlSurface)
        .clipShape(RoundedRectangle(cornerRadius: MLRadius.lg))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Toca para voltear")
    }
}
