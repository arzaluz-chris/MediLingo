import SwiftUI

// Loading state placeholder (CLAUDE-ios.md § Component Library).
struct MLLoadingView: View {
    var message: String?

    var body: some View {
        VStack(spacing: MLSpacing.md) {
            ProgressView().tint(.mlPrimary)
            if let message {
                Text(message)
                    .font(MLFont.caption())
                    .foregroundStyle(Color.mlTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(message ?? "Loading")
    }
}
