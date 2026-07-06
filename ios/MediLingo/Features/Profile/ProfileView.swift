import SwiftUI

// User profile + stats (CLAUDE-ios.md § Profile & Stats).
struct ProfileView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: ProfileViewModel?
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("Perfil")
        }
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(
                    gamification: dependencies.gamificationRepository,
                    profiles: dependencies.profileRepository,
                    flashcardRepo: dependencies.flashcardRepository,
                )
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            ScrollView {
                VStack(spacing: MLSpacing.md) {
                    header(viewModel)
                    statGrid(viewModel)
                    navLink("Logros", icon: "trophy.fill", tint: .mlGold) { AchievementsView() }
                    navLink("Vocabulario", icon: "text.book.closed.fill", tint: .mlSecondary) { VocabularyView() }
                    navLink("Práctica con IA", icon: "bubble.left.and.bubble.right.fill", tint: .mlInfo) { AIConversationView() }
                    navLink("Tienda", icon: "bag.fill", tint: .mlGems) { ShopView() }
                    MLButton(title: "Cerrar sesión", style: .outline) {
                        Task {
                            try? await dependencies.authService.signOut()
                            onSignOut()
                        }
                    }
                    .padding(.top, MLSpacing.md)
                }
                .padding(MLSpacing.md)
            }
        } else {
            MLLoadingView()
        }
    }

    private func header(_ vm: ProfileViewModel) -> some View {
        VStack(spacing: MLSpacing.sm) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.mlPrimary)
            Text(vm.profile?.displayName.isEmpty == false ? vm.profile!.displayName : "Estudiante")
                .font(MLFont.title(24))
                .foregroundStyle(Color.mlTextPrimary)
            Text("Nivel \(vm.stats.level) · \(vm.stats.totalXP) XP")
                .font(MLFont.caption())
                .foregroundStyle(Color.mlTextSecondary)
        }
        .padding(.vertical, MLSpacing.md)
    }

    private func statGrid(_ vm: ProfileViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MLSpacing.sm) {
            stat("Racha", "\(vm.stats.currentStreak) días", .mlStreak, "flame.fill")
            stat("Lecciones", "\(vm.stats.lessonsCompleted)", .mlSuccess, "checkmark.seal.fill")
            stat("Palabras", "\(vm.flashcards.learned)", .mlSecondary, "text.book.closed.fill")
            stat("Dominadas", "\(vm.flashcards.mastered)", .mlXP, "star.fill")
        }
    }

    private func navLink<Destination: View>(_ title: String, icon: String, tint: Color, @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            MLCard {
                HStack {
                    Image(systemName: icon).foregroundStyle(tint)
                    Text(title).font(MLFont.heading(17)).foregroundStyle(Color.mlTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(Color.mlTextTertiary)
                }
            }
        }
    }

    private func stat(_ title: String, _ value: String, _ tint: Color, _ icon: String) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.sm) {
                Image(systemName: icon).foregroundStyle(tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value).font(MLFont.heading(18)).foregroundStyle(Color.mlTextPrimary)
                    Text(title).font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
