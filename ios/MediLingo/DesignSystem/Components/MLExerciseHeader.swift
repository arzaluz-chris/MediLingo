import SwiftUI

// Top bar for the lesson flow: close, animated progress, hearts.
struct MLExerciseHeader: View {
    let progress: Double
    let hearts: Int
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: MLSpacing.md) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.mlTextSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(MLPressableButtonStyle(scale: 0.9))
            .accessibilityLabel("Cerrar lección")

            MLProgressBar(progress: progress, tint: .mlEmerald, height: 14)

            MLHeartDisplay(hearts: hearts)
        }
        .padding(.horizontal, MLSpacing.md)
        .padding(.vertical, MLSpacing.xs)
    }
}
