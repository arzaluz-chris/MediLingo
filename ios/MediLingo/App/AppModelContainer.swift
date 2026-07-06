import Foundation
import SwiftData

// Single shared SwiftData container. The SwiftUI scene and the repository-layer
// cache actors must share one container so they observe the same store.
enum AppModelContainer {
    static let shared: ModelContainer = {
        do {
            let schema = Schema(CachedSchema.models)
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // Corrupt store: fall back to an in-memory container rather than crash;
            // cache is a convenience layer, Supabase remains the source of truth.
            do {
                let schema = Schema(CachedSchema.models)
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("Unable to create even an in-memory ModelContainer: \(error)")
            }
        }
    }()
}
