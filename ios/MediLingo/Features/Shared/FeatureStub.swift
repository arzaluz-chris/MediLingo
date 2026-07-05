import SwiftUI

// Phase-0 placeholder body for a feature screen not yet implemented.
struct FeatureStub: View {
    let title: String
    let systemImage: String
    var subtitle: String = "En construcción."

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                MLEmptyState(systemImage: systemImage, title: title, subtitle: subtitle)
            }
            .navigationTitle(title)
        }
    }
}
