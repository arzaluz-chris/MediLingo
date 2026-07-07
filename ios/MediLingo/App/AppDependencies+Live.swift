import Foundation
import Supabase

// Live wiring. The only place the Supabase client is constructed. Auth is real;
// the remaining services/repositories are Phase-0 stubs (swap incrementally).
extension AppDependencies {
    // @MainActor: constructs StoreKitSubscriptionService, whose init starts the
    // main-actor transaction listener. Called from the @main App (main actor).
    @MainActor
    static func live() -> AppDependencies {
        let client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )

        return AppDependencies(
            authService: SupabaseAuthService(client: client),
            profileRepository: SupabaseProfileRepository(client: client),
            contentRepository: SupabaseContentRepository(client: client),
            progressRepository: SupabaseProgressRepository(client: client),
            gamificationRepository: SupabaseGamificationRepository(client: client),
            flashcardRepository: SupabaseFlashcardRepository(client: client),
            aiService: SupabaseAIService(client: client),
            audioService: AudioService(),
            speechService: SpeechService(),
            subscriptionService: StoreKitSubscriptionService(),
            analyticsService: StubAnalyticsService(),
            syncService: StubSyncService(),
        )
    }
}
