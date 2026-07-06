import SwiftUI

// Achievement gallery (docs/GAMIFICATION.md § Achievements). Server-side
// check_achievements() unlocks; this screen renders the catalog grouped by
// category with locked entries dimmed.
struct AchievementsView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: AchievementsViewModel?

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Logros")
        .task {
            if viewModel == nil {
                viewModel = AchievementsViewModel(gamification: dependencies.gamificationRepository)
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            if viewModel.isLoading {
                MLLoadingView(message: "Cargando logros…")
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.groups.isEmpty {
                MLEmptyState(systemImage: "trophy", title: "Sin logros",
                             subtitle: "Los logros aparecerán aquí.")
            } else {
                list(viewModel)
            }
        } else {
            MLLoadingView()
        }
    }

    private func list(_ viewModel: AchievementsViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MLSpacing.md) {
                Text("\(viewModel.unlockedCount) de \(viewModel.totalCount) desbloqueados")
                    .font(MLFont.caption())
                    .foregroundStyle(Color.mlTextSecondary)
                    .padding(.top, MLSpacing.sm)
                ForEach(viewModel.groups, id: \.category) { group in
                    Text(viewModel.categoryDisplayName(group.category))
                        .font(MLFont.heading(18))
                        .foregroundStyle(Color.mlTextPrimary)
                    ForEach(group.achievements) { achievement in
                        row(achievement)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(MLSpacing.md)
        }
    }

    private func row(_ achievement: Achievement) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                Image(systemName: achievement.isUnlocked ? "trophy.fill" : "lock.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(achievement.isUnlocked ? Color.mlGold : Color.mlTextTertiary)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(achievement.title)
                        .font(MLFont.heading(16))
                        .foregroundStyle(achievement.isUnlocked ? Color.mlTextPrimary : Color.mlTextSecondary)
                    Text(achievement.description)
                        .font(MLFont.caption())
                        .foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("+\(achievement.xpReward) XP")
                        .font(MLFont.caption())
                        .foregroundStyle(Color.mlXP)
                    if achievement.gemReward > 0 {
                        Text("+\(achievement.gemReward) 💎")
                            .font(MLFont.caption())
                            .foregroundStyle(Color.mlGems)
                    }
                }
            }
            .opacity(achievement.isUnlocked ? 1 : 0.6)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title): \(achievement.description). \(achievement.isUnlocked ? "Desbloqueado" : "Bloqueado")")
    }
}
