import SwiftUI

// Error state with retry (CLAUDE-ios.md § Component Library).
struct MLErrorView: View {
    let message: String
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: MLSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.mlWarning.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(Color.mlWarning)
                    .symbolRenderingMode(.hierarchical)
            }
            .accessibilityHidden(true)

            Text("Algo salió mal")
                .font(MLFont.title3)
                .foregroundStyle(Color.mlTextPrimary)
            Text(message)
                .font(MLFont.subheadline)
                .foregroundStyle(Color.mlTextSecondary)
                .multilineTextAlignment(.center)

            if let retry {
                MLButton(title: "Reintentar", icon: "arrow.clockwise", style: .soft) { retry() }
                    .fixedSize()
                    .padding(.top, MLSpacing.xs)
            }
        }
        .padding(MLSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
