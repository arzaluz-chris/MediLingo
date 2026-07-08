import SwiftUI

// Free-text typing exercise. Matched against correct_answer + acceptable_answers.
struct TypingView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var answer = ""
    @State private var phase: AnswerPhase = .answering

    private var meta: TypingMeta {
        ExerciseMetadata.decode(TypingMeta.self, from: exercise.metadataJSON, fallback: .default)
    }
    private var acceptable: [String] {
        var all = meta.acceptableAnswers
        if let correct = exercise.correctAnswer { all.append(correct) }
        return all
    }
    private var isCorrect: Bool {
        AnswerMatcher.matches(answer, against: acceptable, caseSensitive: meta.caseSensitive)
    }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            content: {
                ExerciseTextField(
                    placeholder: meta.placeholder,
                    text: $answer,
                    lineLimit: 1...4,
                    disabled: phase == .checked,
                )
                .onChange(of: answer) { _, new in
                    if new.count > meta.maxLength { answer = String(new.prefix(meta.maxLength)) }
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: !answer.trimmingCharacters(in: .whitespaces).isEmpty,
                isCorrect: isCorrect,
                explanation: isCorrect ? (exercise.explanationES ?? exercise.explanation) : "Respuesta: \(exercise.correctAnswer ?? acceptable.first ?? "")",
                onCheck: { withAnimation(MLMotion.smooth) { phase = .checked } },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }
}
