import UIKit

// Minimal UIApplicationDelegate to receive the APNs device token (SwiftUI has no
// hook for it). The token is forwarded to PushRegistrar, which persists it in
// push_tokens for the signed-in user. Registration is triggered from RootView
// after the user grants notification permission.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data,
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        Task { await PushRegistrar.shared.setToken(token) }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error,
    ) {
        // Non-fatal: remote push simply stays unavailable on this launch.
    }
}
