import Foundation

// Service-layer protocols (CLAUDE-ios.md § Service Layer). All services are
// protocol-backed for testability and DI. Concrete impls live alongside.

protocol AuthServiceProtocol: Sendable {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }

    func signInWithApple() async throws -> User
    func signInWithGoogle() async throws -> User
    func signInWithEmail(_ email: String, password: String) async throws -> User
    func signUp(email: String, password: String, name: String) async throws -> User
    func signOut() async throws
    func deleteAccount() async throws
    func refreshSession() async throws
}

protocol AIServiceProtocol: Sendable {
    func startConversation(type: ConversationType, scenario: Scenario?) async throws -> AIConversation
    func sendMessage(conversationID: UUID, message: String) async throws -> AIResponse
    func evaluatePronunciation(audioData: Data, expectedText: String) async throws -> PronunciationResult
    func generateExplanation(exercise: Exercise, userAnswer: String) async throws -> String
}

protocol AudioServiceProtocol: Sendable {
    func play(url: URL) async throws
    func playLocal(filename: String) async throws
    func pause()
    func stop()
    func setPlaybackSpeed(_ speed: Float)
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
}

protocol SpeechServiceProtocol: Sendable {
    func startRecording() async throws
    func stopRecording() async throws -> SpeechResult
    func requestAuthorization() async -> Bool
    var isRecording: Bool { get }
    var isAvailable: Bool { get }
}

protocol SubscriptionServiceProtocol: Sendable {
    var isPremium: Bool { get }
    var currentSubscription: SubscriptionInfo? { get }

    func fetchProducts() async throws -> [SubscriptionProduct]
    func purchase(_ product: SubscriptionProduct) async throws -> PurchaseResult
    func restorePurchases() async throws
    func checkEntitlements() async throws -> Bool
}

protocol AnalyticsServiceProtocol: Sendable {
    func track(_ event: AnalyticsEvent)
    func setUser(_ userID: String)
    func setUserProperty(_ key: String, value: String)
}

protocol SyncServiceProtocol: Sendable {
    func syncPendingActions() async throws
    func syncContent() async throws
}
