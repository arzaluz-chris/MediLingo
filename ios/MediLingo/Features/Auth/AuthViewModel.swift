import SwiftUI

// Drives the auth screen. Talks to AuthServiceProtocol (Supabase-backed in live).
@MainActor
@Observable
final class AuthViewModel {
    enum Mode { case signIn, signUp }

    var mode: Mode = .signIn
    var email: String = ""
    var password: String = ""
    var name: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let auth: AuthServiceProtocol

    init(auth: AuthServiceProtocol) {
        self.auth = auth
    }

    var canSubmit: Bool {
        email.contains("@") && password.count >= 6 &&
            (mode == .signIn || !name.isEmpty)
    }

    func submit() async -> Bool {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            switch mode {
            case .signIn:
                _ = try await auth.signInWithEmail(email, password: password)
            case .signUp:
                _ = try await auth.signUp(email: email, password: password, name: name)
            }
            return true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }

    func signInWithApple() async -> Bool {
        await run { try await auth.signInWithApple() }
    }

    func signInWithGoogle() async -> Bool {
        await run { try await auth.signInWithGoogle() }
    }

    private func run(_ operation: () async throws -> User) async -> Bool {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await operation()
            return true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }
}
