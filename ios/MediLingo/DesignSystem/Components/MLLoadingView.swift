import SwiftUI

// Loading states (CLAUDE-ios.md § Component Library).

/// Generic centered spinner for full-screen waits.
struct MLLoadingView: View {
    var message: String?

    var body: some View {
        VStack(spacing: MLSpacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(.mlPrimary)
            if let message {
                Text(message)
                    .font(MLFont.subheadline)
                    .foregroundStyle(Color.mlTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement()
        .accessibilityLabel(message ?? "Cargando")
    }
}

/// Shimmering placeholder block. Compose several to sketch a screen's layout
/// while content loads (list rows, cards, stat tiles).
struct MLSkeleton: View {
    var height: CGFloat = 20
    var cornerRadius: CGFloat = MLRadius.sm

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shimmering = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.mlSurfaceElevated)
            .frame(height: height)
            .overlay {
                if !reduceMotion {
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [.clear, Color.mlTextTertiary.opacity(0.18), .clear],
                            startPoint: .leading, endPoint: .trailing,
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: shimmering ? geo.size.width : -geo.size.width * 0.6)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    shimmering = true
                }
            }
            .accessibilityHidden(true)
    }
}

/// Skeleton sketch of a list of cards — the default loading state for
/// content-driven screens.
struct MLSkeletonList: View {
    var rows: Int = 5
    var rowHeight: CGFloat = 76

    var body: some View {
        VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
            ForEach(0..<rows, id: \.self) { _ in
                MLSkeleton(height: rowHeight, cornerRadius: MLRadius.lg)
            }
        }
        .padding(MLSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement()
        .accessibilityLabel("Cargando contenido")
    }
}
