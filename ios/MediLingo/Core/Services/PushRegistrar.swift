import Foundation
import Supabase

// Bridges the APNs device token (delivered to the AppDelegate) to the backend.
// Persists the token in push_tokens keyed on the signed-in user, so a future
// remote-push sender can reach the device. The token and the Supabase client
// can arrive in either order, so both setters attempt a flush.
actor PushRegistrar {
    static let shared = PushRegistrar()

    private var client: SupabaseClient?
    private var token: String?

    func configure(client: SupabaseClient) {
        self.client = client
        Task { await flush() }
    }

    func setToken(_ token: String) {
        self.token = token
        Task { await flush() }
    }

    private func flush() async {
        guard let client, let token else { return }
        guard let userID = try? await client.auth.session.user.id else { return }
        let row = PushTokenRow(user_id: userID, token: token, platform: "ios")
        _ = try? await client
            .from("push_tokens")
            .upsert(row, onConflict: "user_id,token")
            .execute()
    }

    private struct PushTokenRow: Encodable {
        let user_id: UUID
        let token: String
        let platform: String
    }
}
