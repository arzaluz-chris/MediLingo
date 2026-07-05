import SwiftUI

// Top bar for the lesson flow: close, progress, hearts (CLAUDE-ios.md § Components).
struct MLExerciseHeader: View {
    let progress: Double
    let hearts: Int
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: MLSpacing.md) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.mlTextSecondary)
            }
            .accessibilityLabel("Cerrar lección")

            MLProgressBar(progress: progress, tint: .mlSuccess, height: 12)

            MLHeartDisplay(hearts: hearts)
        }
        .padding(.horizontal, MLSpacing.md)
        .padding(.vertical, MLSpacing.sm)
    }
}
