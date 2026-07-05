import SwiftUI

// Single-answer multiple choice. Options come from exercise_options.
struct MultipleChoiceView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var selectedID: UUID?
    @State private var phase: AnswerPhase = .answering

    private var options: [ExerciseOption] {
        exercise.options.sorted { $0.sortOrder < $1.sortOrder }
    }
    private var isCorrect: Bool {
        options.first { $0.id == selectedID }?.isCorrect ?? false
    }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            promptImageURL: exercise.promptImageURL,
            content: {
                VStack(spacing: MLSpacing.sm) {
                    ForEach(options) { option in
                        AnswerButton(
                            text: option.text,
                            isSelected: selectedID == option.id,
                            correctness: correctness(for: option),
                        ) {
                            if phase == .answering { selectedID = option.id }
                        }
                        .disabled(phase == .checked)
                    }
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: selectedID != nil,
                isCorrect: isCorrect,
                explanation: exercise.explanationES ?? exercise.explanation,
                onCheck: { phase = .checked },
                onContinue: {
                    onComplete(ExerciseResult(
                        isCorrect: isCorrect,
                        xpEarned: isCorrect ? exercise.xpReward : 0,
                        explanation: exercise.explanation,
                    ))
                },
            ),
        )
    }

    private func correctness(for option: ExerciseOption) -> Bool? {
        guard phase == .checked else { return nil }
        if option.isCorrect { return true }
        return option.id == selectedID ? false : nil
    }
}
