import Foundation
import PostHog

// Real analytics backed by PostHog (replaces StubAnalyticsService). Configured
// once at launch; every method is a safe no-op until PostHogAPIKey is provided
// via Secrets.xcconfig.
final class PostHogAnalyticsService: AnalyticsServiceProtocol {
    private static var isConfigured = false

    static func configureIfPossible() {
        guard !isConfigured else { return }
        let key = AppConfig.postHogAPIKey
        guard !key.isEmpty else { return }
        let config = PostHogConfig(apiKey: key, host: AppConfig.postHogHost)
        PostHogSDK.shared.setup(config)
        isConfigured = true
    }

    func track(_ event: AnalyticsEvent) {
        guard Self.isConfigured else { return }
        let (name, props) = Self.map(event)
        PostHogSDK.shared.capture(name, properties: props)
    }

    func setUser(_ userID: String) {
        guard Self.isConfigured else { return }
        PostHogSDK.shared.identify(userID)
    }

    func setUserProperty(_ key: String, value: String) {
        guard Self.isConfigured else { return }
        PostHogSDK.shared.capture("$set", properties: ["$set": [key: value]])
    }

    private static func map(_ event: AnalyticsEvent) -> (String, [String: Any]) {
        switch event {
        case .appOpened:
            return ("app_opened", [:])
        case .onboardingStarted:
            return ("onboarding_started", [:])
        case let .onboardingCompleted(role, level, goal):
            return ("onboarding_completed", ["role": role, "level": level, "goal": goal])
        case let .lessonStarted(lessonID, courseID):
            return ("lesson_started", ["lesson_id": lessonID, "course_id": courseID])
        case let .lessonCompleted(lessonID, score, xp, time):
            return ("lesson_completed", ["lesson_id": lessonID, "score": score, "xp": xp, "time": time])
        case let .exerciseAttempted(type, correct, time):
            return ("exercise_attempted", ["type": type, "correct": correct, "time": time])
        case let .levelUp(newLevel):
            return ("level_up", ["new_level": newLevel])
        case let .achievementUnlocked(slug):
            return ("achievement_unlocked", ["slug": slug])
        case let .paywallViewed(source):
            return ("paywall_viewed", ["source": source])
        case let .purchaseCompleted(productID, price):
            return ("purchase_completed", ["product_id": productID, "price": price])
        }
    }
}
