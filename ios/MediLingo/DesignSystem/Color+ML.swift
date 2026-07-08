import SwiftUI
import UIKit

// MediLingo brand palette — medical, elegant, adaptive.
//
// Every token resolves for BOTH light and dark mode via dynamic providers.
// Primary identity: deep blue + emerald on white/system surfaces.
// Accents: cyan + soft mint, used sparingly (gradients, decorative fills).
// Surfaces map to the system grouped-background stack so the app inherits
// Apple's elevation semantics (and looks native under high contrast).
extension Color {
    // MARK: Brand

    /// Deep medical blue — primary actions, links, focus states.
    static let mlPrimary = Color(lightHex: "#1A56DB", darkHex: "#4C82F7")
    /// Darker blue gradient stop for hero surfaces and primary buttons.
    static let mlPrimaryDeep = Color(lightHex: "#0F3CA6", darkHex: "#2F5FD0")
    /// Emerald — the second brand pillar: progress, health, success.
    static let mlEmerald = Color(lightHex: "#059669", darkHex: "#34D399")
    /// Darker emerald gradient stop.
    static let mlEmeraldDeep = Color(lightHex: "#047857", darkHex: "#10B981")
    /// Cyan accent — secondary actions, informational highlights.
    static let mlCyan = Color(lightHex: "#0891B2", darkHex: "#22D3EE")
    /// Soft mint accent — decorative fills and gradient stops only.
    static let mlMint = Color(lightHex: "#2DD4BF", darkHex: "#5EEAD4")

    // Legacy aliases kept so older call sites keep compiling.
    static let mlSecondary = Color.mlCyan
    static let mlAccent = Color(lightHex: "#D97706", darkHex: "#FBBF24")

    // MARK: Feedback

    static let mlSuccess = Color.mlEmerald
    static let mlError = Color(lightHex: "#DC2626", darkHex: "#F87171")
    static let mlWarning = Color(lightHex: "#D97706", darkHex: "#FBBF24")
    static let mlInfo = Color(lightHex: "#2563EB", darkHex: "#60A5FA")

    // MARK: Surfaces (system grouped stack — free light/dark/elevation)

    static let mlBackground = Color(uiColor: .systemGroupedBackground)
    static let mlSurface = Color(uiColor: .secondarySystemGroupedBackground)
    static let mlSurfaceElevated = Color(uiColor: .tertiarySystemGroupedBackground)
    /// Hairline stroke that gives cards definition in dark mode.
    static let mlCardStroke = Color(lightHex: "#0F172A0A", darkHex: "#FFFFFF14")

    // MARK: Text

    static let mlTextPrimary = Color.primary
    static let mlTextSecondary = Color.secondary
    static let mlTextTertiary = Color(uiColor: .tertiaryLabel)
    /// Text/icons placed on top of filled brand surfaces (buttons, gradients).
    static let mlOnAccent = Color.white

    // MARK: Gamification

    static let mlXP = Color(lightHex: "#D97706", darkHex: "#FBBF24")
    static let mlStreak = Color(lightHex: "#EA580C", darkHex: "#FB923C")
    static let mlGems = Color(lightHex: "#7C3AED", darkHex: "#A78BFA")
    static let mlHearts = Color(lightHex: "#E11D48", darkHex: "#FB7185")

    // MARK: Leagues

    static let mlBronze = Color(lightHex: "#B45309", darkHex: "#CD7F32")
    static let mlSilver = Color(lightHex: "#6B7280", darkHex: "#C0C0C0")
    static let mlGold = Color(lightHex: "#B7791F", darkHex: "#FFD700")
    static let mlDiamond = Color(lightHex: "#0E7490", darkHex: "#B9F2FF")
    static let mlMaster = Color(lightHex: "#7E22CE", darkHex: "#C084FC")
}

// MARK: - Gradients

/// Brand gradient presets. Use sparingly: hero headers, primary buttons,
/// celebration moments — never as body-text backgrounds.
enum MLGradient {
    /// Deep blue brand gradient — primary buttons, hero cards.
    static let brand = LinearGradient(
        colors: [.mlPrimary, .mlPrimaryDeep],
        startPoint: .topLeading, endPoint: .bottomTrailing,
    )
    /// Blue → cyan — decorative hero headers (auth, paywall).
    static let hero = LinearGradient(
        colors: [.mlPrimaryDeep, .mlPrimary, .mlCyan],
        startPoint: .topLeading, endPoint: .bottomTrailing,
    )
    /// Emerald → mint — success, progress, lesson completion.
    static let emerald = LinearGradient(
        colors: [.mlEmeraldDeep, .mlEmerald, .mlMint],
        startPoint: .topLeading, endPoint: .bottomTrailing,
    )
    /// Streak fire.
    static let streak = LinearGradient(
        colors: [.mlStreak, .mlXP],
        startPoint: .bottomLeading, endPoint: .topTrailing,
    )
    /// Premium (paywall, crown moments).
    static let premium = LinearGradient(
        colors: [Color(lightHex: "#4338CA", darkHex: "#6366F1"), .mlGems],
        startPoint: .topLeading, endPoint: .bottomTrailing,
    )
}

// MARK: - Hex + dynamic initializers

extension Color {
    /// Create a Color from a hex string like "#4F46E5", "4F46E5" or "#4F46E5CC".
    init(hex: String) {
        self.init(uiColor: UIColor(mlHex: hex))
    }

    /// Adaptive color resolving to different hex values in light and dark mode.
    init(lightHex: String, darkHex: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(mlHex: darkHex) : UIColor(mlHex: lightHex)
        })
    }
}

extension UIColor {
    convenience init(mlHex hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red, green, blue, alpha: Double
        switch sanitized.count {
        case 6:
            red = Double((value & 0xFF0000) >> 16) / 255.0
            green = Double((value & 0x00FF00) >> 8) / 255.0
            blue = Double(value & 0x0000FF) / 255.0
            alpha = 1.0
        case 8:
            red = Double((value & 0xFF000000) >> 24) / 255.0
            green = Double((value & 0x00FF0000) >> 16) / 255.0
            blue = Double((value & 0x0000FF00) >> 8) / 255.0
            alpha = Double(value & 0x000000FF) / 255.0
        default:
            red = 0; green = 0; blue = 0; alpha = 1
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
