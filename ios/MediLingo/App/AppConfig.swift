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
        // Anon key is public (client-shippable, protected by RLS). Injected via
        // project.yml Info.plist; fallback to the hosted project's key.
        infoValue("SupabaseAnonKey") ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqaXh5enRjd3FjZmRnaXhkZmxhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMzNDQ2MTcsImV4cCI6MjA5ODkyMDYxN30.9FfxXdeMyoqWpnePRM5uRoSRrV59JdZjAPqhynm4W2Y"
    }

    // Analytics / subscriptions keys. Injected via Secrets.xcconfig → Info.plist
    // (see Resources/Secrets.xcconfig.example). Empty when unset — the matching
    // service skips configuration and stays a safe no-op.
    static var revenueCatAPIKey: String { infoValue("RevenueCatAPIKey") ?? "" }
    static var postHogAPIKey: String { infoValue("PostHogAPIKey") ?? "" }
    static var postHogHost: String { infoValue("PostHogHost") ?? "https://us.i.posthog.com" }

    private static func infoValue(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else { return nil }
        return value
    }
}
