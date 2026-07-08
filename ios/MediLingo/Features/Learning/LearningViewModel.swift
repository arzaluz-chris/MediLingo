import SwiftUI

// Loads the course tree and drives lesson launch (CLAUDE-ios.md § Learning).
// Phase 1 flattens to the first course's first module; the full multi-course
// tree arrives with CourseDetailView later.
@MainActor
@Observable
final class LearningViewModel {
    var courseTitle: String = ""
    var lessons: [Lesson] = []
    /// Lesson IDs the user has already completed (drives the path states).
    var completedLessons: Set<UUID> = []
    var isLoading = false
    var errorMessage: String?

    private var moduleID: UUID?
    private let content: ContentRepositoryProtocol
    private let gamification: GamificationRepositoryProtocol
    private let progress: ProgressRepositoryProtocol

    init(content: ContentRepositoryProtocol,
         gamification: GamificationRepositoryProtocol,
         progress: ProgressRepositoryProtocol) {
        self.content = content
        self.gamification = gamification
        self.progress = progress
    }

    /// First lesson that hasn't been completed yet — the path's "current" node.
    var currentLessonID: UUID? {
        lessons.first { !completedLessons.contains($0.id) }?.id
    }

    var completedCount: Int {
        lessons.filter { completedLessons.contains($0.id) }.count
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let courses = try await content.fetchCourses()
            guard let course = courses.first else { lessons = []; return }
            courseTitle = course.title
            let modules = try await content.fetchModules(courseID: course.id)
            guard let module = modules.first else { lessons = []; return }
            moduleID = module.id
            lessons = try await content.fetchLessons(moduleID: module.id)
            await refreshCompleted()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    /// Refresh which lessons are complete (cheap; called after every lesson).
    func refreshCompleted() async {
        guard let moduleID else { return }
        completedLessons = (try? await progress.getCompletedLessons(moduleID: moduleID)) ?? completedLessons
    }

    /// Fetch the exercises + current heart count needed to launch a lesson.
    func prepareLesson(_ lesson: Lesson) async -> (exercises: [Exercise], hearts: Int)? {
        do {
            let exercises = try await content.fetchExercises(lessonID: lesson.id)
            guard !exercises.isEmpty else { return nil }
            let hearts = (try? await gamification.getUserStats().hearts) ?? 5
            return (exercises, hearts)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return nil
        }
    }

    /// Server-side heart decrement on a wrong answer (fire-and-forget).
    func consumeHeart() async {
        _ = try? await gamification.consumeHeart()
    }

    /// Persist completion via the record_lesson_completion RPC (authoritative
    /// XP + counters + quest progress, server-side), then unlock any newly
    /// earned achievements. Newly unlocked achievements surface to the UI.
    var newlyUnlocked: [Achievement] = []
    func completeLesson(_ summary: LessonFlowViewModel.Summary) async {
        do {
            try await progress.completeLesson(
                lessonID: summary.lessonID,
                score: summary.score,
                perfect: summary.isPerfect,
                timeMinutes: summary.timeMinutes,
                exerciseCount: summary.exerciseCount,
            )
            await refreshCompleted()
            newlyUnlocked = try await gamification.checkAndUnlockAchievements()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
