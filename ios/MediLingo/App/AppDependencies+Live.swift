import Foundation
import Supabase

// Live wiring. The only place the Supabase client is constructed. Auth is real;
// the remaining services/repositories are Phase-0 stubs (swap incrementally).
extension AppDependencies {
    static func live() -> AppDependencies {
        let client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey,
        )

        return AppDependencies(
            authService: SupabaseAuthService(client: client),
            contentRepository: SupabaseContentRepository(client: client),
            progressRepository: StubProgressRepository(),
            gamificationRepository: SupabaseGamificationRepository(client: client),
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
