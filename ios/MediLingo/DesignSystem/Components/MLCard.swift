import SwiftUI

// Surface card container (CLAUDE-ios.md § Component Library).
struct MLCard<Content: View>: View {
    var padding: CGFloat = MLSpacing.md
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mlSurface)
            .clipShape(RoundedRectangle(cornerRadius: MLRadius.lg))
    }
}
