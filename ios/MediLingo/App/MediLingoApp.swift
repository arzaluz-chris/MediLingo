import SwiftUI
import SwiftData

@main
struct MediLingoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var dependencies: AppDependencies

    // Shared with the repository-layer cache actors (see AppModelContainer).
    private let modelContainer = AppModelContainer.shared

    init() {
        // Configure third-party SDKs before any service uses them. Each is a safe
        // no-op when its key/plist is absent.
        CrashReportingService.configureIfPossible()
        RevenueCatService.configureIfPossible()
        PostHogAnalyticsService.configureIfPossible()
        _dependencies = State(initialValue: AppDependencies.live())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                .preferredColorScheme(.dark)
                .tint(.mlPrimary)
        }
        .modelContainer(modelContainer)
    }
}
