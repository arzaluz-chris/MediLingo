import SwiftUI

// Post-auth root shell.
//
// Redesign: brand-tinted TabView plus a dashboard with a clear hierarchy —
// greeting → gamification stats → today's goal ring → continue-learning hero
// → daily quests. The hero CTA cross-navigates to the Learn tab.
struct HomeView: View {
    enum Tab: Hashable {
        case home, learn, review, league, profile
    }

    @State private var selection: Tab = .home
    let onSignOut: () -> Void

    var body: some View {
        TabView(selection: $selection) {
            HomeDashboardView(onStartLearning: { selection = .learn })
                .tabItem { Label("Inicio", systemImage: "house.fill") }
                .tag(Tab.home)
            LearningView()
                .tabItem { Label("Aprender", systemImage: "book.fill") }
                .tag(Tab.learn)
            FlashcardReviewView()
                .tabItem { Label("Repaso", systemImage: "rectangle.on.rectangle.angled") }
                .tag(Tab.review)
            SocialView()
                .tabItem { Label("Liga", systemImage: "trophy.fill") }
                .tag(Tab.league)
            ProfileView(onSignOut: onSignOut)
                .tabItem { Label("Perfil", systemImage: "person.fill") }
                .tag(Tab.profile)
        }
        .tint(.mlPrimary)
    }
}

// MARK: - Dashboard

private struct HomeDashboardView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: HomeViewModel?
    let onStartLearning: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                content
            }
            .navigationTitle(greeting)
            .toolbar {
                if let viewModel {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: MLSpacing.sm) {
                            MLStatPill(icon: "flame.fill", value: "\(viewModel.stats.currentStreak)",
                                       tint: .mlStreak,
                                       accessibilityText: "Racha de \(viewModel.stats.currentStreak) días")
                            MLHeartDisplay(hearts: viewModel.stats.hearts)
                        }
                    }
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = HomeViewModel(gamification: dependencies.gamificationRepository)
                    await viewModel?.load()
                }
            }
            .refreshable { await viewModel?.load() }
        }
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "¡Buenos días!"
        case 12..<19: "¡Buenas tardes!"
        default: "¡Buenas noches!"
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel, !viewModel.isLoading {
            ScrollView {
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    statRow(viewModel.stats)
                    continueLearningCard
                    dailyGoalCard(viewModel)
                }
                .padding(MLSpacing.md)
                .padding(.bottom, MLSpacing.xl)
            }
        } else {
            MLSkeletonList(rows: 4, rowHeight: 110)
        }
    }

    // MARK: Stats

    private func statRow(_ stats: UserStats) -> some View {
        HStack(spacing: MLSpacing.sm + MLSpacing.xs) {
            statTile(value: "\(stats.currentStreak)", label: "Racha",
                     icon: "flame.fill", tint: .mlStreak)
            statTile(value: "\(stats.totalXP)", label: "XP total",
                     icon: "bolt.fill", tint: .mlXP)
            statTile(value: "\(stats.gems)", label: "Gemas",
                     icon: "diamond.fill", tint: .mlGems)
        }
    }

    private func statTile(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: MLSpacing.xs) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(MLFont.statValue)
                .foregroundStyle(Color.mlTextPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .minimumScaleFactor(0.7)
            Text(label)
                .font(MLFont.caption)
                .foregroundStyle(Color.mlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MLSpacing.md)
        .mlCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: Continue learning hero

    private var continueLearningCard: some View {
        Button {
            MLHaptic.medium()
            onStartLearning()
        } label: {
            MLHeroCard(gradient: MLGradient.brand) {
                HStack(spacing: MLSpacing.md) {
                    VStack(alignment: .leading, spacing: MLSpacing.xs) {
                        Text("Sigue aprendiendo")
                            .font(MLFont.title3)
                            .foregroundStyle(Color.mlOnAccent)
                        Text("Tu próxima lección de inglés médico te espera.")
                            .font(MLFont.subheadline)
                            .foregroundStyle(Color.mlOnAccent.opacity(0.85))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)
                    ZStack {
                        Circle()
                            .fill(Color.mlOnAccent.opacity(0.2))
                            .frame(width: 56, height: 56)
                        Image(systemName: "play.fill")
                            .font(.title3)
                            .foregroundStyle(Color.mlOnAccent)
                    }
                }
            }
        }
        .buttonStyle(MLPressableButtonStyle())
        .accessibilityLabel("Sigue aprendiendo. Abre tu próxima lección")
    }

    // MARK: Daily quests

    @ViewBuilder
    private func dailyGoalCard(_ viewModel: HomeViewModel) -> some View {
        let completed = viewModel.quests.filter(\.isCompleted).count
        let total = viewModel.quests.count

        VStack(alignment: .leading, spacing: MLSpacing.md) {
            Text("Misiones de hoy")
                .font(MLFont.title2)
                .foregroundStyle(Color.mlTextPrimary)
                .padding(.top, MLSpacing.sm)

            if viewModel.quests.isEmpty {
                MLCard {
                    MLEmptyState(systemImage: "target", title: "Sin misiones por hoy",
                                 subtitle: "Vuelve mañana por nuevas misiones diarias.",
                                 tint: .mlCyan)
                        .frame(maxHeight: 220)
                }
            } else {
                MLCard {
                    HStack(spacing: MLSpacing.md) {
                        MLProgressRing(
                            progress: total == 0 ? 0 : Double(completed) / Double(total),
                            lineWidth: 9,
                            tint: .mlEmerald,
                            label: "\(completed)/\(total)",
                        )
                        .frame(width: 76, height: 76)

                        VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                            Text(completed == total ? "¡Meta diaria cumplida!" : "Meta diaria")
                                .font(MLFont.headline)
                                .foregroundStyle(Color.mlTextPrimary)
                            Text(completed == total
                                 ? "Increíble constancia. Nos vemos mañana."
                                 : "Completa tus misiones para mantener la racha.")
                                .font(MLFont.footnote)
                                .foregroundStyle(Color.mlTextSecondary)
                        }
                        Spacer(minLength: 0)
                    }
                }

                ForEach(viewModel.quests) { quest in
                    questRow(quest)
                }
            }
        }
    }

    private func questRow(_ quest: DailyQuest) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                ZStack {
                    Circle()
                        .fill((quest.isCompleted ? Color.mlEmerald : Color.mlCyan).opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: quest.isCompleted ? "checkmark" : questIcon(quest.questType))
                        .font(.body.weight(.bold))
                        .foregroundStyle(quest.isCompleted ? Color.mlEmerald : Color.mlCyan)
                        .contentTransition(.symbolEffect(.replace))
                }

                VStack(alignment: .leading, spacing: MLSpacing.sm) {
                    HStack {
                        Text(quest.title)
                            .font(MLFont.bodyMedium)
                            .foregroundStyle(Color.mlTextPrimary)
                        Spacer()
                        Text("\(min(quest.currentValue, quest.targetValue))/\(quest.targetValue)")
                            .font(MLFont.caption)
                            .foregroundStyle(Color.mlTextSecondary)
                            .monospacedDigit()
                    }
                    MLProgressBar(
                        progress: quest.targetValue == 0 ? 0 : Double(quest.currentValue) / Double(quest.targetValue),
                        tint: quest.isCompleted ? .mlEmerald : .mlCyan,
                        height: 8,
                    )
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(quest.title). \(quest.currentValue) de \(quest.targetValue)\(quest.isCompleted ? ". Completada" : "")")
    }

    private func questIcon(_ type: String) -> String {
        switch type {
        case let t where t.contains("lesson"): "book.fill"
        case let t where t.contains("flashcard") || t.contains("review"): "rectangle.on.rectangle.angled"
        case let t where t.contains("xp"): "bolt.fill"
        case let t where t.contains("perfect"): "star.fill"
        default: "target"
        }
    }
}
