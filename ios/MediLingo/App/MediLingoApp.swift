import SwiftUI
import SwiftData

@main
struct MediLingoApp: App {
    @State private var dependencies = AppDependencies.live()

    // Shared with the repository-layer cache actors (see AppModelContainer).
    private let modelContainer = AppModelContainer.shared

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
