import SwiftUI

// Full-screen exercise-by-exercise lesson flow (CLAUDE-ios.md § Learning).
struct LessonFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LessonFlowViewModel
    /// Called when the lesson completes, with (xpEarned, accuracy 0…1).
    let onFinish: (Int, Double) -> Void

    init(lesson: Lesson, exercises: [Exercise], hearts: Int, isPremium: Bool,
         onFinish: @escaping (Int, Double) -> Void = { _, _ in }) {
        _viewModel = State(initialValue: LessonFlowViewModel(
            lesson: lesson, exercises: exercises, hearts: hearts, isPremium: isPremium,
        ))
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .exercise, .feedback:
            VStack(spacing: 0) {
                MLExerciseHeader(
                    progress: viewModel.progress,
                    hearts: viewModel.hearts,
                    onClose: { dismiss() },
                )
                if let exercise = viewModel.currentExercise {
                    ExerciseContainerView(exercise: exercise) { result in
                        MLHaptic.correct()
                        viewModel.record(result)
                    }
                    // Fresh view state per exercise.
                    .id(viewModel.currentIndex)
                } else {
                    MLLoadingView()
                }
            }
        case .outOfHearts:
            outOfHearts
        case .complete:
            LessonCompleteView(
                xpEarned: viewModel.xpEarned,
                accuracy: viewModel.accuracy,
                isPerfect: viewModel.isPerfect,
            ) {
                onFinish(viewModel.xpEarned, viewModel.accuracy)
                dismiss()
            }
        }
    }

    private var outOfHearts: some View {
        VStack(spacing: MLSpacing.lg) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.mlHearts)
            Text("¡Te quedaste sin corazones!")
                .font(MLFont.heading())
                .foregroundStyle(Color.mlTextPrimary)
            Text("Espera a que se recarguen o hazte Premium para corazones ilimitados.")
                .font(MLFont.body())
                .foregroundStyle(Color.mlTextSecondary)
                .multilineTextAlignment(.center)
            MLButton(title: "Salir", style: .outline) { dismiss() }.fixedSize()
        }
        .padding(MLSpacing.lg)
    }
}
