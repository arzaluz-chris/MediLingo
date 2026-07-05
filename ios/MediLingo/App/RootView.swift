import SwiftUI

// App root. Routes between the auth flow and the authenticated experience.
struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var path = NavigationPath()
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                NavigationStack(path: $path) {
                    HomeView()
                }
            } else {
                AuthView(onAuthenticated: { isAuthenticated = true })
            }
        }
        .task {
            // Reflect any restored session on launch.
            isAuthenticated = dependencies.authService.isAuthenticated
        }
    }
}
