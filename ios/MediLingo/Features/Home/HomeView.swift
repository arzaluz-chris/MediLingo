import SwiftUI

// Post-auth root shell. Tabs are Phase-0 placeholders; each fills in later.
struct HomeView: View {
    let onSignOut: () -> Void

    var body: some View {
        TabView {
            HomeDashboardView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }
            LearningView()
                .tabItem { Label("Aprender", systemImage: "book.fill") }
            FlashcardReviewView()
                .tabItem { Label("Repaso", systemImage: "rectangle.on.rectangle.angled") }
            SocialView()
                .tabItem { Label("Liga", systemImage: "trophy.fill") }
            ProfileView(onSignOut: onSignOut)
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
                content
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

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            ScrollView {
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    // Top stats row.
                    HStack(spacing: MLSpacing.md) {
                        miniStat("\(viewModel.stats.currentStreak)", "Racha", .mlStreak, "flame.fill")
                        miniStat("\(viewModel.stats.hearts)", "Vidas", .mlHearts, "heart.fill")
                        miniStat("\(viewModel.stats.totalXP)", "XP", .mlXP, "bolt.fill")
                    }

                    Text("Misiones de hoy")
                        .font(MLFont.heading())
                        .foregroundStyle(Color.mlTextPrimary)
                        .padding(.top, MLSpacing.sm)

                    if viewModel.quests.isEmpty {
                        MLEmptyState(systemImage: "target", title: "Sin misiones",
                                     subtitle: "Vuelve más tarde por tus misiones diarias.")
                    } else {
                        ForEach(viewModel.quests) { quest in questRow(quest) }
                    }
                }
                .padding(MLSpacing.md)
            }
        } else {
            MLLoadingView()
        }
    }

    private func miniStat(_ value: String, _ label: String, _ tint: Color, _ icon: String) -> some View {
        MLCard {
            VStack(spacing: MLSpacing.xs) {
                Image(systemName: icon).foregroundStyle(tint)
                Text(value).font(MLFont.heading(18)).foregroundStyle(Color.mlTextPrimary).monospacedDigit()
                Text(label).font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func questRow(_ quest: DailyQuest) -> some View {
        MLCard {
            VStack(alignment: .leading, spacing: MLSpacing.sm) {
                HStack {
                    Text(quest.title).font(MLFont.body(15)).foregroundStyle(Color.mlTextPrimary)
                    Spacer()
                    if quest.isCompleted {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.mlSuccess)
                    } else {
                        Text("\(quest.currentValue)/\(quest.targetValue)")
                            .font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary).monospacedDigit()
                    }
                }
                MLProgressBar(
                    progress: quest.targetValue == 0 ? 0 : Double(quest.currentValue) / Double(quest.targetValue),
                    tint: quest.isCompleted ? .mlSuccess : .mlAccent,
                    height: 8,
                )
            }
        }
    }
}
