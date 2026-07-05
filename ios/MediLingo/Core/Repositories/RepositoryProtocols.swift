import Foundation

// Repository layer (CLAUDE-ios.md § Repository Layer). Repositories coordinate
// remote (Supabase) + local (SwiftData) and own the caching/offline strategy.

protocol ContentRepositoryProtocol {
    func fetchCourses() async throws -> [Course]
    func fetchModules(courseID: UUID) async throws -> [Module]
    func fetchLessons(moduleID: UUID) async throws -> [Lesson]
    func fetchExercises(lessonID: UUID) async throws -> [Exercise]
    func fetchVocabulary(lessonID: UUID) async throws -> [VocabularyWord]
    func searchVocabulary(query: String) async throws -> [VocabularyWord]
    func downloadLessonForOffline(lessonID: UUID) async throws
    func syncContent() async throws
}

protocol ProgressRepositoryProtocol {
    func getUserProgress(courseID: UUID) async throws -> CourseProgress
    func submitExerciseAttempt(_ attempt: ExerciseAttempt) async throws -> ExerciseResult
    func completeLesson(lessonID: UUID, score: Double, xpEarned: Int) async throws
    func getCompletedLessons(moduleID: UUID) async throws -> Set<UUID>
    func syncProgress() async throws
}

protocol GamificationRepositoryProtocol {
    func getUserStats() async throws -> UserStats
    func addXP(_ amount: Int) async throws -> UserStats
    func consumeHeart() async throws -> Int
    func refillHearts() async throws -> Int
    func getDailyQuests() async throws -> [DailyQuest]
    func updateQuestProgress(questID: UUID, increment: Int) async throws
    func getAchievements() async throws -> [Achievement]
    func getUnlockedAchievements() async throws -> Set<UUID>
    func checkAndUnlockAchievements() async throws -> [Achievement]
    func getLeagueStandings() async throws -> LeagueStandings
    func getShopItems() async throws -> [ShopItem]
    func purchase(itemID: UUID) async throws -> UserStats
}

protocol FlashcardRepositoryProtocol {
    func getDueFlashcards(limit: Int) async throws -> [FlashcardItem]
    func submitReview(vocabularyID: UUID, quality: Int) async throws
    func getStats() async throws -> FlashcardStats
    func addWord(vocabularyID: UUID) async throws
}
