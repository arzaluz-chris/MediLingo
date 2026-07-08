import SwiftUI

// The learning path (CLAUDE-ios.md § Learning).
//
// Redesign: a Duolingo-style vertical path of circular lesson nodes that
// winds gently left and right. Node states — completed (emerald check),
// current (gradient + pulse + "Empieza" balloon), upcoming (neutral).
// A course header card summarizes overall progress.
struct LearningView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: LearningViewModel?
    @State private var active: ActiveLesson?
    @State private var showAchievements = false

    private struct ActiveLesson: Identifiable {
        let id: UUID
        let lesson: Lesson
        let exercises: [Exercise]
        let hearts: Int
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("Aprender")
        }
        .task {
            if viewModel == nil {
                viewModel = LearningViewModel(
                    content: dependencies.contentRepository,
                    gamification: dependencies.gamificationRepository,
                    progress: dependencies.progressRepository,
                )
                await viewModel?.load()
            }
        }
        .fullScreenCover(item: $active) { item in
            LessonFlowView(
                lesson: item.lesson,
                exercises: item.exercises,
                hearts: item.hearts,
                isPremium: dependencies.subscriptionService.isPremium,
                onHeartLost: { [weak viewModel] in await viewModel?.consumeHeart() },
            ) { summary in
                Task {
                    await viewModel?.completeLesson(summary)
                    if viewModel?.newlyUnlocked.isEmpty == false { showAchievements = true }
                }
            }
        }
        .sheet(isPresented: $showAchievements, onDismiss: { viewModel?.newlyUnlocked = [] }) {
            if let unlocked = viewModel?.newlyUnlocked {
                AchievementUnlockedSheet(achievements: unlocked)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(MLRadius.xl)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            if viewModel.isLoading {
                MLSkeletonList(rows: 5, rowHeight: 90)
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.lessons.isEmpty {
                MLEmptyState(systemImage: "book.closed.fill", title: "Aún no hay lecciones",
                             subtitle: "Publicamos contenido nuevo cada semana. ¡Vuelve pronto!",
                             tint: .mlEmerald)
            } else {
                path(viewModel)
            }
        } else {
            MLSkeletonList(rows: 5, rowHeight: 90)
        }
    }

    // MARK: Path

    private func path(_ viewModel: LearningViewModel) -> some View {
        ScrollView {
            VStack(spacing: MLSpacing.lg) {
                courseHeader(viewModel)

                VStack(spacing: MLSpacing.lg) {
                    ForEach(Array(viewModel.lessons.enumerated()), id: \.element.id) { index, lesson in
                        lessonNode(
                            lesson,
                            index: index,
                            state: nodeState(lesson, viewModel: viewModel),
                            viewModel: viewModel,
                        )
                    }
                }
                .padding(.vertical, MLSpacing.md)
            }
            .padding(MLSpacing.md)
            .padding(.bottom, MLSpacing.xl)
        }
        .refreshable { await viewModel.load() }
    }

    private func courseHeader(_ viewModel: LearningViewModel) -> some View {
        MLHeroCard(gradient: MLGradient.emerald) {
            VStack(alignment: .leading, spacing: MLSpacing.sm) {
                Label("Curso actual", systemImage: "stethoscope")
                    .font(MLFont.caption)
                    .foregroundStyle(Color.mlOnAccent.opacity(0.85))
                    .textCase(.uppercase)
                Text(viewModel.courseTitle)
                    .font(MLFont.title2)
                    .foregroundStyle(Color.mlOnAccent)
                HStack(spacing: MLSpacing.sm) {
                    MLProgressBar(
                        progress: viewModel.lessons.isEmpty ? 0
                            : Double(viewModel.completedCount) / Double(viewModel.lessons.count),
                        tint: .white,
                        height: 10,
                    )
                    Text("\(viewModel.completedCount)/\(viewModel.lessons.count)")
                        .font(MLFont.caption)
                        .foregroundStyle(Color.mlOnAccent)
                        .monospacedDigit()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.courseTitle). \(viewModel.completedCount) de \(viewModel.lessons.count) lecciones completadas")
    }

    // MARK: Nodes

    private enum NodeState { case completed, current, upcoming }

    private func nodeState(_ lesson: Lesson, viewModel: LearningViewModel) -> NodeState {
        if viewModel.completedLessons.contains(lesson.id) { return .completed }
        if viewModel.currentLessonID == lesson.id { return .current }
        return .upcoming
    }

    /// Horizontal offset that makes the path wind: 0, +1, 0, -1, 0, +1…
    private func windOffset(_ index: Int) -> CGFloat {
        let pattern: [CGFloat] = [0, 1, 0, -1]
        return pattern[index % pattern.count] * 64
    }

    private func lessonNode(_ lesson: Lesson, index: Int, state: NodeState,
                            viewModel: LearningViewModel) -> some View {
        Button {
            MLHaptic.medium()
            Task {
                if let prepared = await viewModel.prepareLesson(lesson) {
                    active = ActiveLesson(id: lesson.id, lesson: lesson,
                                          exercises: prepared.exercises, hearts: prepared.hearts)
                }
            }
        } label: {
            VStack(spacing: MLSpacing.sm) {
                if state == .current {
                    Text("Empieza")
                        .font(MLFont.caption)
                        .foregroundStyle(Color.mlPrimary)
                        .padding(.horizontal, MLSpacing.sm + MLSpacing.xs)
                        .padding(.vertical, MLSpacing.xs)
                        .background(Color.mlSurface, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.mlPrimary.opacity(0.4), lineWidth: 1))
                        .mlShadow(.soft)
                }

                nodeCircle(state)

                VStack(spacing: MLSpacing.xxs) {
                    Text(lesson.title)
                        .font(MLFont.subheadline.weight(.semibold))
                        .foregroundStyle(state == .upcoming ? Color.mlTextSecondary : Color.mlTextPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 200)
                    Text("\(lesson.estimatedMinutes) min · \(lesson.xpReward) XP")
                        .font(MLFont.caption2)
                        .foregroundStyle(Color.mlTextTertiary)
                }
            }
        }
        .buttonStyle(MLPressableButtonStyle())
        .offset(x: windOffset(index))
        .accessibilityLabel(accessibilityText(lesson, state: state))
    }

    @ViewBuilder
    private func nodeCircle(_ state: NodeState) -> some View {
        ZStack {
            switch state {
            case .completed:
                Circle().fill(MLGradient.emerald)
                Image(systemName: "checkmark")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(Color.mlOnAccent)
            case .current:
                PulsingHalo(tint: .mlPrimary)
                Circle().fill(MLGradient.brand)
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundStyle(Color.mlOnAccent)
            case .upcoming:
                Circle().fill(Color.mlSurface)
                Circle().strokeBorder(Color.mlCardStroke, lineWidth: 1.5)
                Image(systemName: "book.fill")
                    .font(.title3)
                    .foregroundStyle(Color.mlTextTertiary)
            }
        }
        .frame(width: 72, height: 72)
        .mlShadow(state == .upcoming ? .soft : .card)
    }

    private func accessibilityText(_ lesson: Lesson, state: NodeState) -> String {
        let stateText = switch state {
        case .completed: "Completada"
        case .current: "Lección actual"
        case .upcoming: "Pendiente"
        }
        return "Lección: \(lesson.title). \(stateText). \(lesson.estimatedMinutes) minutos, \(lesson.xpReward) XP"
    }
}

// Soft expanding halo behind the current node. Static under Reduce Motion.
private struct PulsingHalo: View {
    let tint: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    var body: some View {
        Circle()
            .fill(tint.opacity(0.25))
            .frame(width: 92, height: 92)
            .scaleEffect(reduceMotion ? 1 : (pulsing ? 1.12 : 0.94))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
            .accessibilityHidden(true)
    }
}

// Celebration sheet for freshly unlocked achievements.
private struct AchievementUnlockedSheet: View {
    let achievements: [Achievement]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            VStack(spacing: MLSpacing.lg) {
                Text(achievements.count == 1 ? "¡Logro desbloqueado!" : "¡Logros desbloqueados!")
                    .font(MLFont.title2)
                    .foregroundStyle(Color.mlTextPrimary)
                    .padding(.top, MLSpacing.lg)

                ForEach(achievements) { achievement in
                    MLCard {
                        HStack(spacing: MLSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(MLGradient.streak)
                                    .frame(width: 52, height: 52)
                                Image(systemName: "trophy.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.mlOnAccent)
                            }
                            VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                                Text(achievement.title)
                                    .font(MLFont.headline)
                                    .foregroundStyle(Color.mlTextPrimary)
                                Text(achievement.description)
                                    .font(MLFont.footnote)
                                    .foregroundStyle(Color.mlTextSecondary)
                            }
                            Spacer(minLength: 0)
                            Text("+\(achievement.xpReward) XP")
                                .font(MLFont.caption)
                                .foregroundStyle(Color.mlXP)
                        }
                    }
                }
                .padding(.horizontal, MLSpacing.md)

                Spacer()
                MLButton(title: "¡Genial!") { dismiss() }
                    .padding(MLSpacing.md)
            }
            MLConfettiView()
        }
        .onAppear { MLHaptic.achievement() }
    }
}
