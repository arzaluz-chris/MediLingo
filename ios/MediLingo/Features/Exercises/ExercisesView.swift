import SwiftUI

// Hosts the data-driven exercise engine (Core/Engine/ExerciseContainerView).
// Phase-0 entry point; the LessonFlowView drives real lessons in Phase 1.
struct ExercisesView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            ExerciseContainerView(exercise: exercise, onComplete: onComplete)
        }
    }
}
