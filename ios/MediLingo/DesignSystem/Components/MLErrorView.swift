import SwiftUI

// Error state with retry (CLAUDE-ios.md § Component Library).
struct MLErrorView: View {
    let message: String
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: MLSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.mlWarning)
            Text(message)
                .font(MLFont.body())
                .foregroundStyle(Color.mlTextSecondary)
                .multilineTextAlignment(.center)
            if let retry {
                MLButton(title: "Reintentar", style: .outline) { retry() }
                    .fixedSize()
            }
        }
        .padding(MLSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
