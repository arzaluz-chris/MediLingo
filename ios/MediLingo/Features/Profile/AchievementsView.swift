import SwiftUI

// Achievement gallery (docs/GAMIFICATION.md § Achievements). Server-side
// check_achievements() unlocks; this screen renders the catalog grouped by
// category. Unlocked achievements get gradient medallions; locked ones stay
// dimmed with a lock, and a header ring summarizes overall completion.
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
                MLSkeletonList(rows: 5, rowHeight: 84)
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.groups.isEmpty {
                MLEmptyState(systemImage: "trophy.fill", title: "Sin logros todavía",
                             subtitle: "Completa lecciones y los logros aparecerán aquí.",
                             tint: .mlXP)
            } else {
                list(viewModel)
            }
        } else {
            MLSkeletonList(rows: 5, rowHeight: 84)
        }
    }

    private func list(_ viewModel: AchievementsViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MLSpacing.md) {
                summaryCard(viewModel)

                ForEach(viewModel.groups, id: \.category) { group in
                    Text(viewModel.categoryDisplayName(group.category))
                        .font(MLFont.title3)
                        .foregroundStyle(Color.mlTextPrimary)
                        .padding(.top, MLSpacing.sm)
                    ForEach(group.achievements) { achievement in
                        row(achievement)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(MLSpacing.md)
            .padding(.bottom, MLSpacing.xl)
        }
    }

    private func summaryCard(_ viewModel: AchievementsViewModel) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                MLProgressRing(
                    progress: viewModel.totalCount == 0 ? 0
                        : Double(viewModel.unlockedCount) / Double(viewModel.totalCount),
                    lineWidth: 9,
                    tint: .mlXP,
                    label: "\(viewModel.unlockedCount)",
                )
                .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    Text("\(viewModel.unlockedCount) de \(viewModel.totalCount)")
                        .font(MLFont.headline)
                        .foregroundStyle(Color.mlTextPrimary)
                    Text("logros desbloqueados")
                        .font(MLFont.footnote)
                        .foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.unlockedCount) de \(viewModel.totalCount) logros desbloqueados")
    }

    private func row(_ achievement: Achievement) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked
                              ? AnyShapeStyle(MLGradient.streak)
                              : AnyShapeStyle(Color.mlSurfaceElevated))
                        .frame(width: 52, height: 52)
                    Image(systemName: achievement.isUnlocked ? "trophy.fill" : "lock.fill")
                        .font(.title3)
                        .foregroundStyle(achievement.isUnlocked ? Color.mlOnAccent : Color.mlTextTertiary)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    Text(achievement.title)
                        .font(MLFont.headline)
                        .foregroundStyle(achievement.isUnlocked ? Color.mlTextPrimary : Color.mlTextSecondary)
                    Text(achievement.description)
                        .font(MLFont.footnote)
                        .foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: MLSpacing.xxs) {
                    Text("+\(achievement.xpReward) XP")
                        .font(MLFont.caption)
                        .foregroundStyle(Color.mlXP)
                    if achievement.gemReward > 0 {
                        HStack(spacing: MLSpacing.xxs) {
                            Image(systemName: "diamond.fill")
                                .font(.caption2)
                            Text("+\(achievement.gemReward)")
                        }
                        .font(MLFont.caption)
                        .foregroundStyle(Color.mlGems)
                    }
                }
            }
            .opacity(achievement.isUnlocked ? 1 : 0.65)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title): \(achievement.description). \(achievement.isUnlocked ? "Desbloqueado" : "Bloqueado")")
    }
}
