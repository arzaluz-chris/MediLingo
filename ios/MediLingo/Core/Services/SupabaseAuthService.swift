import Foundation
import Supabase

// Real Supabase-backed auth (CLAUDE-ios.md § Service Layer, CLAUDE-backend.md § Auth).
// The one Phase-0 service wired against the SDK. Apple/Google sign-in are
// scaffolded but return `notImplemented` until the native credential flow lands.
@Observable
final class SupabaseAuthService: AuthServiceProtocol {
    let client: SupabaseClient
    private(set) var currentUser: User?

    var isAuthenticated: Bool { currentUser != nil }

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: Email / password

    func signInWithEmail(_ email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(email: email, password: password)
        return mapUser(session.user)
    }

    func signUp(email: String, password: String, name: String) async throws -> User {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(name)],
        )
        return mapUser(response.user)
    }

    // MARK: OAuth

    func signInWithApple() async throws -> User {
        // Native Sign in with Apple: get the identity token + raw nonce, then
        // exchange it for a Supabase session.
        let credential = try await AppleSignInCoordinator().signIn()
        let session = try await client.auth.signInWithIdToken(credentials: .init(
            provider: .apple,
            idToken: credential.identityToken,
            nonce: credential.rawNonce,
        ))
        // Apple only returns the name on first authorization; persist it if present.
        if let name = credential.fullName, !name.isEmpty {
            try? await client.auth.update(user: UserAttributes(data: ["full_name": .string(name)]))
        }
        return mapUser(session.user)
    }

    func signInWithGoogle() async throws -> User {
        // Web OAuth via ASWebAuthenticationSession (managed by supabase-swift).
        let session = try await client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "com.medilingo.app://callback"),
        )
        return mapUser(session.user)
    }

    // MARK: Session

    func signOut() async throws {
        try await client.auth.signOut()
        currentUser = nil
    }

    func deleteAccount() async throws {
        // Server-side purge via the delete-account Edge Function (GDPR).
        _ = try await client.functions.invoke("delete-account")
        try await signOut()
    }

    func refreshSession() async throws {
        let session = try await client.auth.refreshSession()
        currentUser = mapUser(session.user)
    }

    /// Restore any persisted session on launch.
    func restoreSession() async {
        if let session = try? await client.auth.session {
            currentUser = mapUser(session.user)
        }
    }

    private func mapUser(_ authUser: Auth.User) -> User {
        let user = User(
            id: authUser.id,
            email: authUser.email ?? "",
            displayName: (authUser.userMetadata["full_name"]?.stringValue) ?? "",
        )
        currentUser = user
        return user
    }
}
