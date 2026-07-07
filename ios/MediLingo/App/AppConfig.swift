import Foundation

// Runtime configuration. Values come from Info.plist keys injected by
// Resources/Secrets.xcconfig (see Secrets.xcconfig.example). Falls back to the
// local Supabase defaults so the app runs against `supabase start` out of the box.
enum AppConfig {
    static var supabaseURL: URL {
        // Simulator fallback: use hosted project (works in Simulator, device, TestFlight).
        // Local: set via Secrets.xcconfig (see Resources/Secrets.xcconfig.example).
        let raw = infoValue("SupabaseURL") ?? "https://qjixyztcwqcfdgixdfla.supabase.co"
        return URL(string: raw) ?? URL(string: "https://qjixyztcwqcfdgixdfla.supabase.co")!
    }

    static var supabaseAnonKey: String {
        // Get from Secrets.xcconfig or use the hosted project's anon key (read from dashboard).
        infoValue("SupabaseAnonKey") ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqaXh5enpjd3FjZmRnaXhkZmxhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjA3MDkxOTgsImV4cCI6MTczODI4NTE5OH0.1H1Zs-1DHww5UQlJLaVT2x-h-5pOUEXWWdYKsNwqg2c"
    }

    private static func infoValue(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else { return nil }
        return value
    }
}
