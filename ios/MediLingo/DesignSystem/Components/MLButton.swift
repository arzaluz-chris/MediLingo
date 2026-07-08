import SwiftUI

// Primary reusable button (CLAUDE-ios.md § Component Library).
// 56pt touch target, continuous corners, spring press-down, optional icon.
struct MLButton: View {
    enum Style {
        /// Brand gradient fill — the screen's single main action.
        case primary
        /// Emerald fill — positive/confirm alternatives.
        case secondary
        /// Tinted translucent fill — medium-emphasis actions.
        case soft
        /// Stroked, transparent — low-emphasis actions.
        case outline
        /// Red fill — destructive or error-path actions.
        case destructive
    }

    let title: String
    var icon: String?
    var style: Style = .primary
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            MLHaptic.tap()
            action()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView().tint(foreground)
                } else {
                    HStack(spacing: MLSpacing.sm) {
                        if let icon {
                            Image(systemName: icon)
                                .font(.body.weight(.semibold))
                        }
                        Text(title)
                            .font(MLFont.headline)
                    }
                    .foregroundStyle(foreground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(background)
            .clipShape(shape)
            .overlay(
                shape.strokeBorder(borderColor, lineWidth: style == .outline ? 1.5 : 0)
            )
            .compositingGroup()
        }
        .buttonStyle(MLPressableButtonStyle())
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.45)
        .accessibilityLabel(title)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MLRadius.button, style: .continuous)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary: MLGradient.brand
        case .secondary: Color.mlEmerald
        case .soft: Color.mlPrimary.opacity(0.14)
        case .outline: Color.clear
        case .destructive: Color.mlError
        }
    }

    private var foreground: Color {
        switch style {
        case .primary, .secondary, .destructive: .mlOnAccent
        case .soft, .outline: .mlPrimary
        }
    }

    private var borderColor: Color {
        style == .outline ? .mlPrimary.opacity(0.55) : .clear
    }
}

// MARK: - Press interaction

/// Spring scale-down on press. Shared by every tappable card/tile in the app
/// so all touch feedback feels identical.
struct MLPressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.965

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(MLMotion.snappy, value: configuration.isPressed)
    }
}
