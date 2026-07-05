import Foundation

// Dependency-injection container (CLAUDE-ios.md § Dependency Injection).
// Holds protocol-typed services/repositories so features stay testable and the
// concrete (Supabase-backed) wiring lives in one place (see AppDependencies+Live).
@Observable
final class AppDependencies {
    let authService: AuthServiceProtocol
    let contentRepository: ContentRepositoryProtocol
    let progressRepository: ProgressRepositoryProtocol
    let gamificationRepository: GamificationRepositoryProtocol
    let flashcardRepository: FlashcardRepositoryProtocol
    let aiService: AIServiceProtocol
    let audioService: AudioServiceProtocol
    let speechService: SpeechServiceProtocol
    let subscriptionService: SubscriptionServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    let syncService: SyncServiceProtocol

    init(
        authService: AuthServiceProtocol,
        contentRepository: ContentRepositoryProtocol,
        progressRepository: ProgressRepositoryProtocol,
        gamificationRepository: GamificationRepositoryProtocol,
        flashcardRepository: FlashcardRepositoryProtocol,
        aiService: AIServiceProtocol,
        audioService: AudioServiceProtocol,
        speechService: SpeechServiceProtocol,
        subscriptionService: SubscriptionServiceProtocol,
        analyticsService: AnalyticsServiceProtocol,
        syncService: SyncServiceProtocol,
    ) {
        self.authService = authService
        self.contentRepository = contentRepository
        self.progressRepository = progressRepository
        self.gamificationRepository = gamificationRepository
        self.flashcardRepository = flashcardRepository
        self.aiService = aiService
        self.audioService = audioService
        self.speechService = speechService
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
        self.syncService = syncService
    }

    /// All-stub container for previews and tests.
    static func stub() -> AppDependencies {
        AppDependencies(
            authService: StubAuthService(),
            contentRepository: StubContentRepository(),
            progressRepository: StubProgressRepository(),
            gamificationRepository: StubGamificationRepository(),
            flashcardRepository: StubFlashcardRepository(),
            aiService: StubAIService(),
            audioService: AudioService(),
            speechService: SpeechService(),
            subscriptionService: StubSubscriptionService(),
            analyticsService: StubAnalyticsService(),
            syncService: StubSyncService(),
        )
    }
}
