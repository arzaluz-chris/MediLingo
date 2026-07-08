import SwiftUI

// Full-screen exercise-by-exercise lesson flow (CLAUDE-ios.md § Learning).
struct LessonFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LessonFlowViewModel
    /// Called when the lesson completes, with the full lesson summary.
    let onFinish: (LessonFlowViewModel.Summary) -> Void

    init(lesson: Lesson, exercises: [Exercise], hearts: Int, isPremium: Bool,
         onHeartLost: @escaping @Sendable () async -> Void = {},
         onFinish: @escaping (LessonFlowViewModel.Summary) -> Void = { _ in }) {
        _viewModel = State(initialValue: LessonFlowViewModel(
            lesson: lesson, exercises: exercises, hearts: hearts, isPremium: isPremium,
            onHeartLost: onHeartLost,
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
                        viewModel.record(result)
                    }
                    // Fresh view state per exercise; slide new exercises in.
                    .id(viewModel.currentIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity,
                    ))
                    .animation(MLMotion.smooth, value: viewModel.currentIndex)
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
                onFinish(viewModel.summary)
                dismiss()
            }
        }
    }

    private var outOfHearts: some View {
        VStack(spacing: MLSpacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.mlHearts.opacity(0.12))
                    .frame(width: 128, height: 128)
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.mlHearts)
                    .symbolRenderingMode(.hierarchical)
            }
            .accessibilityHidden(true)

            VStack(spacing: MLSpacing.sm) {
                Text("¡Te quedaste sin corazones!")
                    .font(MLFont.title2)
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.center)
                Text("Espera a que se recarguen o hazte Premium para corazones ilimitados.")
                    .font(MLFont.body)
                    .foregroundStyle(Color.mlTextSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()

            MLButton(title: "Salir", style: .soft) { dismiss() }
        }
        .padding(MLSpacing.lg)
        .onAppear {
            MLHaptic.incorrect()
            MLSoundPlayer.play(.heartLost)
        }
    }
}
