import SwiftUI

// Type (or pick from a word bank) the term that completes the sentence.
struct FillInBlankView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var answer = ""
    @State private var phase: AnswerPhase = .answering

    private var meta: FillInBlankMeta {
        ExerciseMetadata.decode(FillInBlankMeta.self, from: exercise.metadataJSON, fallback: .default)
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
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    ExerciseTextField(
                        placeholder: "Respuesta",
                        text: $answer,
                        lineLimit: 1...2,
                        disabled: phase == .checked,
                    )

                    if let bank = meta.wordBank, !bank.isEmpty {
                        FlowChips(items: bank) { word in
                            if phase == .answering { answer = word }
                        }
                    }
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: !answer.trimmingCharacters(in: .whitespaces).isEmpty,
                isCorrect: isCorrect,
                explanation: correctAnswerHint,
                onCheck: { withAnimation(MLMotion.smooth) { phase = .checked } },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }

    private var correctAnswerHint: String? {
        if isCorrect { return exercise.explanationES ?? exercise.explanation }
        return "Respuesta: \(exercise.correctAnswer ?? acceptable.first ?? "")"
    }
}
