import SwiftUI

// Loads the course tree and drives lesson launch (CLAUDE-ios.md § Learning).
// Phase 1 flattens to the first course's first module; the full Duolingo-style
// tree arrives with CourseDetailView later.
@MainActor
@Observable
final class LearningViewModel {
    var courseTitle: String = ""
    var lessons: [Lesson] = []
    var isLoading = false
    var errorMessage: String?

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
            lessons = try await content.fetchLessons(moduleID: module.id)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
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

    /// Persist completion: updates progress + XP + lessons_completed and bumps
    /// the streak (server trigger on user_progress).
    func completeLesson(_ lesson: Lesson, xp: Int, accuracy: Double) async {
        try? await progress.completeLesson(lessonID: lesson.id, score: accuracy, xpEarned: xp)
    }
}
