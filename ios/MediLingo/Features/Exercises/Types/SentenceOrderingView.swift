import SwiftUI

// Tap word tiles to build the sentence; compared to correct_answer.
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
                    // Built sentence.
                    Text(built.isEmpty ? "…" : built)
                        .font(MLFont.body(18))
                        .foregroundStyle(Color.mlTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
                        .padding(MLSpacing.md)
                        .background(Color.mlSurface)
                        .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                        .onTapGesture { if phase == .answering { _ = chosen.popLast() } }

                    // Remaining word pool.
                    FlowChips(items: remaining) { word in
                        if phase == .answering, let idx = remaining.firstIndex(of: word) {
                            chosen.append(remaining[idx])
                        }
                    }
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: !chosen.isEmpty,
                isCorrect: isCorrect,
                explanation: isCorrect ? (exercise.explanationES ?? exercise.explanation) : "Correcto: \(exercise.correctAnswer ?? "")",
                onCheck: { phase = .checked },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
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
