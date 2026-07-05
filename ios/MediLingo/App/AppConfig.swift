import Foundation

// Runtime configuration. Values come from Info.plist keys injected by
// Resources/Secrets.xcconfig (see Secrets.xcconfig.example). Falls back to the
// local Supabase defaults so the app runs against `supabase start` out of the box.
enum AppConfig {
    static var supabaseURL: URL {
        let raw = infoValue("SupabaseURL") ?? "http://127.0.0.1:54321"
        return URL(string: raw) ?? URL(string: "http://127.0.0.1:54321")!
    }

    static var supabaseAnonKey: String {
        infoValue("SupabaseAnonKey") ?? "anon-key-placeholder"
    }

    private static func infoValue(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else { return nil }
        return value
    }
}
