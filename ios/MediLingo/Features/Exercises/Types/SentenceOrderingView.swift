import SwiftUI

// Tap word tiles to build the sentence; compared to correct_answer.
// Chosen words render as removable chips inside the answer area.
struct SentenceOrderingView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var chosen: [String] = []
    @State private var phase: AnswerPhase = .answering

    private var meta: SentenceOrderingMeta {
        ExerciseMetadata.decode(SentenceOrderingMeta.self, from: exercise.metadataJSON, fallback: .default)
    }
    private var pool: [String] { meta.words + meta.extraWords }
    private var built: String { chosen.joined(separator: " ") }
    private var isCorrect: Bool {
        AnswerMatcher.matches(built, against: [exercise.correctAnswer ?? meta.words.joined(separator: " ")], caseSensitive: false)
    }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            content: {
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    answerArea
                    FlowChips(items: remaining) { word in
                        guard phase == .answering else { return }
                        withAnimation(MLMotion.snappy) { chosen.append(word) }
                    }
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: !chosen.isEmpty,
                isCorrect: isCorrect,
                explanation: isCorrect ? (exercise.explanationES ?? exercise.explanation) : "Correcto: \(exercise.correctAnswer ?? "")",
                onCheck: { withAnimation(MLMotion.smooth) { phase = .checked } },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }

    /// The sentence under construction. Tap a chip to send it back to the pool.
    private var answerArea: some View {
        Group {
            if chosen.isEmpty {
                Text("Toca las palabras para formar la oración")
                    .font(MLFont.subheadline)
                    .foregroundStyle(Color.mlTextTertiary)
                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .center)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: MLSpacing.sm)],
                          spacing: MLSpacing.sm) {
                    ForEach(Array(chosen.enumerated()), id: \.offset) { index, word in
                        Button {
                            guard phase == .answering else { return }
                            MLHaptic.selection()
                            withAnimation(MLMotion.snappy) {
                                _ = chosen.remove(at: index)
                            }
                        } label: {
                            Text(word)
                                .font(MLFont.bodyMedium)
                                .foregroundStyle(Color.mlOnAccent)
                                .padding(.horizontal, MLSpacing.md)
                                .padding(.vertical, MLSpacing.sm + MLSpacing.xs)
                                .background(Color.mlPrimary, in: Capsule())
                        }
                        .buttonStyle(MLPressableButtonStyle(scale: 0.93))
                        .accessibilityLabel("\(word). Toca para quitar")
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            }
        }
        .padding(MLSpacing.md)
        .background(Color.mlSurface, in: RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
                .strokeBorder(Color.mlCardStroke, lineWidth: 1)
        )
    }

    /// Pool minus already-chosen tokens (accounts for duplicates by count).
    private var remaining: [String] {
        var counts: [String: Int] = [:]
        for word in chosen { counts[word, default: 0] += 1 }
        var result: [String] = []
        for word in pool {
            if let c = counts[word], c > 0 { counts[word] = c - 1 } else { result.append(word) }
        }
        return result
    }
}
