import SwiftUI

// Translate the source text. Graded locally by exact match or key-term coverage
// (server AI grading arrives with use_ai_evaluation in a later phase).
struct TranslationView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var answer = ""
    @State private var phase: AnswerPhase = .answering

    private var meta: TranslationMeta {
        ExerciseMetadata.decode(TranslationMeta.self, from: exercise.metadataJSON, fallback: .default)
    }
    private var isCorrect: Bool {
        if AnswerMatcher.matches(answer, against: meta.acceptableTranslations, caseSensitive: false) {
            return true
        }
        if let keyTerms = meta.keyTerms {
            return AnswerMatcher.containsKeyTerms(answer, keyTerms: keyTerms)
        }
        return false
    }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            content: {
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    if !meta.sourceText.isEmpty {
                        Text(meta.sourceText)
                            .font(MLFont.body(18))
                            .foregroundStyle(Color.mlTextPrimary)
                            .padding(MLSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.mlSurface)
                            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                    }
                    TextField("Tu traducción", text: $answer, axis: .vertical)
                        .lineLimit(2...5)
                        .autocorrectionDisabled()
                        .padding(MLSpacing.md)
                        .background(Color.mlSurface)
                        .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                        .foregroundStyle(Color.mlTextPrimary)
                        .disabled(phase == .checked)
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: !answer.trimmingCharacters(in: .whitespaces).isEmpty,
                isCorrect: isCorrect,
                explanation: isCorrect ? (exercise.explanationES ?? exercise.explanation) : "Ejemplo: \(meta.acceptableTranslations.first ?? "")",
                onCheck: { phase = .checked },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }
}
