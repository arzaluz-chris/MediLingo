import SwiftUI

// Typography tokens (CLAUDE-ios.md § Typography). SF Pro rounded for a
// friendly, medical-professional feel.
enum MLFont {
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func heading(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular)
    }
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium)
    }
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

// Shared spacing/radius constants — no magic numbers in views.
enum MLSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum MLRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
}
