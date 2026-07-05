import SwiftUI

// Primary reusable button with brand variants (CLAUDE-ios.md § Component Library).
struct MLButton: View {
    enum Style {
        case primary, secondary, destructive, outline
    }

    let title: String
    var style: Style = .primary
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            MLHaptic.tap()
            action()
        }) {
            ZStack {
                if isLoading {
                    ProgressView().tint(foreground)
                } else {
                    Text(title)
                        .font(MLFont.heading(17))
                        .foregroundStyle(foreground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: MLRadius.md)
                    .strokeBorder(borderColor, lineWidth: style == .outline ? 1.5 : 0)
            )
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }

    private var background: Color {
        switch style {
        case .primary: .mlPrimary
        case .secondary: .mlSecondary
        case .destructive: .mlError
        case .outline: .clear
        }
    }

    private var foreground: Color {
        style == .outline ? .mlPrimary : .white
    }

    private var borderColor: Color {
        style == .outline ? .mlPrimary : .clear
    }
}
