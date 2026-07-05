import SwiftUI
import SwiftData

@main
struct MediLingoApp: App {
    @State private var dependencies = AppDependencies.live()

    private let modelContainer: ModelContainer = {
        do {
            let schema = Schema(CachedSchema.models)
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

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
