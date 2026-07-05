import Foundation

// Phase 0 stub services. They conform to the protocols and compile, but defer
// real integrations (AI Edge Functions, StoreKit/RevenueCat, Firebase/PostHog)
// to later phases. Swap for concrete impls without touching call sites.

@Observable
final class StubAuthService: AuthServiceProtocol {
    private(set) var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }

    func signInWithApple() async throws -> User { throw AppError.notImplemented }
    func signInWithGoogle() async throws -> User { throw AppError.notImplemented }
    func signInWithEmail(_ email: String, password: String) async throws -> User { throw AppError.notImplemented }
    func signUp(email: String, password: String, name: String) async throws -> User { throw AppError.notImplemented }
    func signOut() async throws { currentUser = nil }
    func deleteAccount() async throws {}
    func refreshSession() async throws {}
}

@Observable
final class StubAIService: AIServiceProtocol {
    func startConversation(type: ConversationType, scenario: Scenario?) async throws -> AIConversation {
        throw AppError.notImplemented
    }
    func sendMessage(conversationID: UUID, message: String) async throws -> AIResponse {
        throw AppError.notImplemented
    }
    func evaluatePronunciation(word: String, phonetic: String?, transcription: String, confidence: Double) async throws -> PronunciationResult {
        throw AppError.notImplemented
    }
    func generateExplanation(prompt: String, userAnswer: String, correctAnswer: String?, isCorrect: Bool) async throws -> String {
        throw AppError.notImplemented
    }
}

@Observable
final class StubSubscriptionService: SubscriptionServiceProtocol {
    var isPremium: Bool = false
    var currentSubscription: SubscriptionInfo? = nil

    func fetchProducts() async throws -> [SubscriptionProduct] { [] }
    func purchase(_ product: SubscriptionProduct) async throws -> PurchaseResult { .failed }
    func restorePurchases() async throws {}
    func checkEntitlements() async throws -> Bool { false }
}

// No-op analytics for Phase 0 (avoids linking Firebase/PostHog before keys exist).
final class StubAnalyticsService: AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent) {}
    func setUser(_ userID: String) {}
    func setUserProperty(_ key: String, value: String) {}
}

final class StubSyncService: SyncServiceProtocol {
    func syncPendingActions() async throws {}
    func syncContent() async throws {}
}
