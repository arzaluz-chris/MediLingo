import SwiftUI

// App root. Routes between auth → onboarding → the authenticated experience.
struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var isAuthenticated = false
    @State private var onboardingComplete: Bool?

    var body: some View {
        Group {
            if !isAuthenticated {
                AuthView(onAuthenticated: {
                    isAuthenticated = true
                    Task { await loadOnboarding() }
                })
            } else if onboardingComplete == nil {
                MLLoadingView()
            } else if onboardingComplete == false {
                OnboardingView(onComplete: { onboardingComplete = true })
            } else {
                HomeView(onSignOut: {
                    onboardingComplete = nil
                    isAuthenticated = false
                })
            }
        }
        .task {
            isAuthenticated = dependencies.authService.isAuthenticated
            if isAuthenticated { await loadOnboarding() }
        }
    }

    private func loadOnboarding() async {
        onboardingComplete = (try? await dependencies.profileRepository.isOnboardingComplete()) ?? false
    }
}
