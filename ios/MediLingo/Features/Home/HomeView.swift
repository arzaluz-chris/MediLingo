import SwiftUI

// Post-auth root shell. Tabs are Phase-0 placeholders; each fills in later.
struct HomeView: View {
    var body: some View {
        TabView {
            HomeDashboardView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }
            LearningView()
                .tabItem { Label("Aprender", systemImage: "book.fill") }
            FlashcardReviewView()
                .tabItem { Label("Repaso", systemImage: "rectangle.on.rectangle.angled") }
            ProfileView()
                .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
    }
}

private struct HomeDashboardView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: HomeViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                MLEmptyState(
                    systemImage: "sparkles",
                    title: "¡Bienvenido a MediLingo!",
                    subtitle: "Tu panel de progreso aparecerá aquí.",
                )
            }
            .navigationTitle("Inicio")
            .task {
                if viewModel == nil {
                    viewModel = HomeViewModel(gamification: dependencies.gamificationRepository)
                    await viewModel?.load()
                }
            }
        }
    }
}
