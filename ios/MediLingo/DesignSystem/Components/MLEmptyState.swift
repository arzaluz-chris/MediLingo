import SwiftUI

// Empty-list placeholder (CLAUDE-ios.md § Component Library).
struct MLEmptyState: View {
    let systemImage: String
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(spacing: MLSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(Color.mlTextTertiary)
            Text(title)
                .font(MLFont.heading(18))
                .foregroundStyle(Color.mlTextPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(MLFont.caption())
                    .foregroundStyle(Color.mlTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(MLSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
