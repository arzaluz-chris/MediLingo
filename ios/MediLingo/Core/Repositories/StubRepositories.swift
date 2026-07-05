import Foundation

// Phase 0 stub repositories. They return empty/default data so the app compiles
// and navigates. Wire Supabase + SwiftData reads/writes in Phase 1.

struct StubContentRepository: ContentRepositoryProtocol {
    func fetchCourses() async throws -> [Course] { [] }
    func fetchModules(courseID: UUID) async throws -> [Module] { [] }
    func fetchLessons(moduleID: UUID) async throws -> [Lesson] { [] }
    func fetchExercises(lessonID: UUID) async throws -> [Exercise] { [] }
    func fetchVocabulary(lessonID: UUID) async throws -> [VocabularyWord] { [] }
    func searchVocabulary(query: String) async throws -> [VocabularyWord] { [] }
    func downloadLessonForOffline(lessonID: UUID) async throws {}
    func syncContent() async throws {}
}

struct StubProgressRepository: ProgressRepositoryProtocol {
    func getUserProgress(courseID: UUID) async throws -> CourseProgress {
        CourseProgress(courseID: courseID, completedLessons: 0, totalLessons: 0, xpEarned: 0)
    }
    func submitExerciseAttempt(_ attempt: ExerciseAttempt) async throws -> ExerciseResult {
        ExerciseResult(isCorrect: attempt.isCorrect, xpEarned: 0, explanation: nil)
    }
    func completeLesson(lessonID: UUID, score: Double, xpEarned: Int) async throws {}
    func getCompletedLessons(moduleID: UUID) async throws -> Set<UUID> { [] }
    func syncProgress() async throws {}
}

struct StubGamificationRepository: GamificationRepositoryProtocol {
    func getUserStats() async throws -> UserStats { .empty }
    func addXP(_ amount: Int) async throws -> UserStats { .empty }
    func consumeHeart() async throws -> Int { 5 }
    func refillHearts() async throws -> Int { 5 }
    func getDailyQuests() async throws -> [DailyQuest] { [] }
    func updateQuestProgress(questID: UUID, increment: Int) async throws {}
    func getAchievements() async throws -> [Achievement] { [] }
    func getUnlockedAchievements() async throws -> Set<UUID> { [] }
    func checkAndUnlockAchievements() async throws -> [Achievement] { [] }
    func getLeagueStandings() async throws -> LeagueStandings {
        LeagueStandings(tier: "bronze", members: [])
    }
}

struct StubFlashcardRepository: FlashcardRepositoryProtocol {
    func getDueFlashcards(limit: Int) async throws -> [FlashcardItem] { [] }
    func submitReview(vocabularyID: UUID, quality: Int) async throws {}
    func getStats() async throws -> FlashcardStats { FlashcardStats(due: 0, learned: 0, mastered: 0) }
    func addWord(vocabularyID: UUID) async throws {}
}
