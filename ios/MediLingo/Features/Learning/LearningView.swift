import SwiftUI

// Lesson list for the first course (Phase 1). Tapping a lesson loads its
// exercises and launches the full-screen lesson flow.
struct LearningView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: LearningViewModel?
    @State private var active: ActiveLesson?

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
            ) { xp, _ in
                Task { await viewModel?.awardLessonXP(xp) }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            if viewModel.isLoading {
                MLLoadingView(message: "Cargando…")
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.lessons.isEmpty {
                MLEmptyState(systemImage: "book.closed", title: "Sin lecciones",
                             subtitle: "Aún no hay lecciones publicadas.")
            } else {
                ScrollView {
                    VStack(spacing: MLSpacing.sm) {
                        ForEach(viewModel.lessons) { lesson in
                            lessonRow(lesson, viewModel: viewModel)
                        }
                    }
                    .padding(MLSpacing.md)
                }
            }
        } else {
            MLLoadingView()
        }
    }

    private func lessonRow(_ lesson: Lesson, viewModel: LearningViewModel) -> some View {
        Button {
            Task {
                if let prepared = await viewModel.prepareLesson(lesson) {
                    active = ActiveLesson(id: lesson.id, lesson: lesson,
                                          exercises: prepared.exercises, hearts: prepared.hearts)
                }
            }
        } label: {
            MLCard {
                HStack(spacing: MLSpacing.md) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.mlPrimary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lesson.title)
                            .font(MLFont.heading(17))
                            .foregroundStyle(Color.mlTextPrimary)
                        Text("\(lesson.estimatedMinutes) min · \(lesson.xpReward) XP")
                            .font(MLFont.caption())
                            .foregroundStyle(Color.mlTextSecondary)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").foregroundStyle(Color.mlTextTertiary)
                }
            }
        }
        .accessibilityLabel("Lección: \(lesson.title)")
    }
}
