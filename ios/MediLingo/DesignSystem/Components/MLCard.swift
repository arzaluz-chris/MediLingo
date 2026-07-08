import SwiftUI

// Surface card container (CLAUDE-ios.md § Component Library).
// Large continuous corners, soft shadow, hairline stroke for dark mode.
struct MLCard<Content: View>: View {
    var padding: CGFloat = MLSpacing.md
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .mlCardStyle()
    }
}

extension View {
    /// The standard card treatment, applicable to any container.
    func mlCardStyle(cornerRadius: CGFloat = MLRadius.lg) -> some View {
        modifier(MLCardStyleModifier(cornerRadius: cornerRadius))
    }
}

private struct MLCardStyleModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(Color.mlSurface)
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.mlCardStroke, lineWidth: 1))
            .mlShadow(.soft)
    }
}

/// A card with a gradient fill for hero moments (continue-learning, referral,
/// paywall header). Content renders on top of the gradient in `mlOnAccent`.
struct MLHeroCard<Content: View>: View {
    var gradient: LinearGradient = MLGradient.brand
    var padding: CGFloat = MLSpacing.lg
    @ViewBuilder let content: () -> Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: MLRadius.xl, style: .continuous)
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(gradient)
            .clipShape(shape)
            .mlShadow(.card)
    }
}
