import Foundation
import RevenueCat

// Thin wrapper over the RevenueCat SDK. Entitlement truth stays with StoreKit
// (StoreKitSubscriptionService); RevenueCat is used for cross-platform analytics
// and — critically — to set app_user_id to the Supabase user id so the
// revenuecat-webhook can attribute purchases to the right account and keep
// profiles.is_premium in sync. Every method is a safe no-op until an API key is
// provided via Secrets.xcconfig (RevenueCatAPIKey).
enum RevenueCatService {
    /// Configure once at launch. Skips when no key is set.
    static func configureIfPossible() {
        guard !Purchases.isConfigured else { return }
        let key = AppConfig.revenueCatAPIKey
        guard !key.isEmpty else { return }
        Purchases.configure(withAPIKey: key)
    }

    /// Associate RevenueCat's app_user_id with the Supabase user id.
    static func logIn(userID: String) {
        guard Purchases.isConfigured else { return }
        Task { _ = try? await Purchases.shared.logIn(userID) }
    }

    static func logOut() {
        guard Purchases.isConfigured else { return }
        Task { _ = try? await Purchases.shared.logOut() }
    }
}
