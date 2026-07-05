import SwiftUI

// MediLingo brand palette (CLAUDE-ios.md § Design System).
// Token names are prefixed `ml` to avoid clashing with system colors.
extension Color {
    // Brand
    static let mlPrimary = Color(hex: "#4F46E5")
    static let mlSecondary = Color(hex: "#06B6D4")
    static let mlAccent = Color(hex: "#F59E0B")

    // Feedback
    static let mlSuccess = Color(hex: "#10B981")
    static let mlError = Color(hex: "#EF4444")
    static let mlWarning = Color(hex: "#F59E0B")
    static let mlInfo = Color(hex: "#3B82F6")

    // Surfaces
    static let mlBackground = Color(hex: "#0F172A")
    static let mlSurface = Color(hex: "#1E293B")
    static let mlSurfaceElevated = Color(hex: "#334155")

    // Text
    static let mlTextPrimary = Color(hex: "#F8FAFC")
    static let mlTextSecondary = Color(hex: "#94A3B8")
    static let mlTextTertiary = Color(hex: "#64748B")

    // Gamification
    static let mlXP = Color(hex: "#FBBF24")
    static let mlStreak = Color(hex: "#F97316")
    static let mlGems = Color(hex: "#8B5CF6")
    static let mlHearts = Color(hex: "#EF4444")

    // Leagues
    static let mlBronze = Color(hex: "#CD7F32")
    static let mlSilver = Color(hex: "#C0C0C0")
    static let mlGold = Color(hex: "#FFD700")
    static let mlDiamond = Color(hex: "#B9F2FF")
    static let mlMaster = Color(hex: "#9333EA")
}

extension Color {
    /// Create a Color from a hex string like "#4F46E5" or "4F46E5".
    init(hex: String) {
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
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
