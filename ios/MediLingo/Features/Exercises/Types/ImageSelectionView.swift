import SwiftUI

// Pick the image matching the prompt. Options carry option_image_url.
struct ImageSelectionView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var selectedID: UUID?
    @State private var phase: AnswerPhase = .answering

    private var meta: ImageSelectionMeta {
        ExerciseMetadata.decode(ImageSelectionMeta.self, from: exercise.metadataJSON, fallback: .default)
    }
    private var options: [ExerciseOption] {
        exercise.options.sorted { $0.sortOrder < $1.sortOrder }
    }
    private var isCorrect: Bool {
        options.first { $0.id == selectedID }?.isCorrect ?? false
    }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            content: {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: max(1, meta.columns)), spacing: MLSpacing.sm) {
                    ForEach(options) { option in
                        AnswerButton(
                            text: option.text,
                            imageURL: option.imageURL,
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
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
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
