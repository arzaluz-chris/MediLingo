import SwiftUI

// Typography system — built ONLY on Dynamic Type text styles so every label
// scales with the user's preferred content size (HIG: Dynamic Type).
// Rounded design for display text gives the friendly-but-professional voice;
// body text stays default SF for maximum legibility.
enum MLFont {
    // Display
    static let hero = Font.system(.largeTitle, design: .rounded).weight(.heavy)
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title, design: .rounded).weight(.bold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.bold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)

    // Text
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body)
    static let bodyMedium = Font.system(.body).weight(.medium)
    static let callout = Font.system(.callout)
    static let subheadline = Font.system(.subheadline)
    static let footnote = Font.system(.footnote)
    static let caption = Font.system(.caption).weight(.medium)
    static let caption2 = Font.system(.caption2).weight(.medium)

    // Numbers & special
    /// Big stat numerals (XP, streak count, scores).
    static let statLarge = Font.system(.largeTitle, design: .rounded).weight(.heavy)
    static let statValue = Font.system(.title2, design: .rounded).weight(.heavy)
    /// Phonetics / codes.
    static let mono = Font.system(.callout, design: .monospaced).weight(.medium)
}

// Shared spacing constants — no magic numbers in views.
enum MLSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// Corner radii. Always pair with `style: .continuous` (squircle curvature).
enum MLRadius {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let button: CGFloat = 18
    static let lg: CGFloat = 22
    static let xl: CGFloat = 28
}

// MARK: - Elevation

/// Soft shadow levels. Cards float gently; overlays float more.
enum MLShadow {
    case soft, card, floating

    var color: Color {
        switch self {
        case .soft: .black.opacity(0.05)
        case .card: .black.opacity(0.08)
        case .floating: .black.opacity(0.16)
        }
    }
    var radius: CGFloat {
        switch self {
        case .soft: 8
        case .card: 16
        case .floating: 28
        }
    }
    var y: CGFloat {
        switch self {
        case .soft: 2
        case .card: 6
        case .floating: 12
        }
    }
}

extension View {
    /// Apply a design-system shadow level.
    func mlShadow(_ level: MLShadow = .card) -> some View {
        shadow(color: level.color, radius: level.radius, x: 0, y: level.y)
    }

    /// Standard full-screen background for every screen.
    func mlScreen() -> some View {
        background(Color.mlBackground.ignoresSafeArea())
    }
}

// MARK: - Motion

/// Shared spring curves so the whole app moves with one voice.
enum MLMotion {
    /// Quick UI response (button presses, selections).
    static let snappy = Animation.spring(response: 0.28, dampingFraction: 0.75)
    /// Standard transitions (cards, reveals).
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
    /// Playful emphasis (celebrations, badges popping in).
    static let bouncy = Animation.spring(response: 0.45, dampingFraction: 0.6)
}
