import SwiftUI

// Friendly empty-list placeholder (CLAUDE-ios.md § Component Library).
// Icon in a soft tinted circle with a one-shot bounce; optional action button.
struct MLEmptyState: View {
    let systemImage: String
    let title: String
    var subtitle: String?
    var tint: Color = .mlPrimary
    var actionTitle: String?
    var action: (() -> Void)?

    @State private var appeared = false

    var body: some View {
        VStack(spacing: MLSpacing.md) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(tint)
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.bounce, value: appeared)
            }
            .accessibilityHidden(true)

            VStack(spacing: MLSpacing.xs) {
                Text(title)
                    .font(MLFont.title3)
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.center)
                if let subtitle {
                    Text(subtitle)
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let actionTitle, let action {
                MLButton(title: actionTitle, style: .soft, action: action)
                    .fixedSize()
                    .padding(.top, MLSpacing.xs)
            }
        }
        .padding(MLSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { appeared = true }
    }
}
