import Foundation
import SwiftData

// SwiftData local cache. Source of truth is always Supabase; these exist for
// offline-first reads and the pending-sync queue (CLAUDE-ios.md § SwiftData Models).

// MARK: - Content cache

@Model
final class CachedCourse {
    @Attribute(.unique) var id: UUID
    var slug: String
    var title: String
    var shortDesc: String
    var iconURL: String?
    var colorHex: String
    var difficulty: String
    var category: String
    var isPremium: Bool
    var sortOrder: Int
    var lastSyncedAt: Date

    @Relationship(deleteRule: .cascade) var modules: [CachedModule]

    init(id: UUID, slug: String, title: String, shortDesc: String, iconURL: String?,
         colorHex: String, difficulty: String, category: String, isPremium: Bool,
         sortOrder: Int, lastSyncedAt: Date, modules: [CachedModule] = []) {
        self.id = id; self.slug = slug; self.title = title; self.shortDesc = shortDesc
        self.iconURL = iconURL; self.colorHex = colorHex; self.difficulty = difficulty
        self.category = category; self.isPremium = isPremium; self.sortOrder = sortOrder
        self.lastSyncedAt = lastSyncedAt; self.modules = modules
    }
}

@Model
final class CachedModule {
    @Attribute(.unique) var id: UUID
    var courseID: UUID
    var title: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade) var lessons: [CachedLesson]
    @Relationship(inverse: \CachedCourse.modules) var course: CachedCourse?

    init(id: UUID, courseID: UUID, title: String, sortOrder: Int, lessons: [CachedLesson] = []) {
        self.id = id; self.courseID = courseID; self.title = title
        self.sortOrder = sortOrder; self.lessons = lessons
    }
}

@Model
final class CachedLesson {
    @Attribute(.unique) var id: UUID
    var moduleID: UUID
    var title: String
    var lessonType: String
    var difficulty: String
    var estimatedMinutes: Int
    var xpReward: Int
    var sortOrder: Int
    var isPremium: Bool
    var isDownloaded: Bool

    @Relationship(deleteRule: .cascade) var exercises: [CachedExercise]
    @Relationship(inverse: \CachedModule.lessons) var module: CachedModule?

    init(id: UUID, moduleID: UUID, title: String, lessonType: String, difficulty: String,
         estimatedMinutes: Int, xpReward: Int, sortOrder: Int, isPremium: Bool,
         isDownloaded: Bool = false, exercises: [CachedExercise] = []) {
        self.id = id; self.moduleID = moduleID; self.title = title; self.lessonType = lessonType
        self.difficulty = difficulty; self.estimatedMinutes = estimatedMinutes
        self.xpReward = xpReward; self.sortOrder = sortOrder; self.isPremium = isPremium
        self.isDownloaded = isDownloaded; self.exercises = exercises
    }
}

@Model
final class CachedExercise {
    @Attribute(.unique) var id: UUID
    var lessonID: UUID
    var exerciseType: String
    var prompt: String
    var correctAnswer: String?
    var explanation: String?
    var explanationES: String?
    var hint: String?
    var difficulty: String
    var xpReward: Int
    var sortOrder: Int
    var metadataJSON: String
    var promptAudioURL: String?
    var promptImageURL: String?

    @Relationship(deleteRule: .cascade) var options: [CachedExerciseOption]
    @Relationship(inverse: \CachedLesson.exercises) var lesson: CachedLesson?

    init(id: UUID, lessonID: UUID, exerciseType: String, prompt: String, correctAnswer: String?,
         explanation: String?, explanationES: String?, hint: String?, difficulty: String,
         xpReward: Int, sortOrder: Int, metadataJSON: String, promptAudioURL: String?,
         promptImageURL: String?, options: [CachedExerciseOption] = []) {
        self.id = id; self.lessonID = lessonID; self.exerciseType = exerciseType
        self.prompt = prompt; self.correctAnswer = correctAnswer; self.explanation = explanation
        self.explanationES = explanationES; self.hint = hint; self.difficulty = difficulty
        self.xpReward = xpReward; self.sortOrder = sortOrder; self.metadataJSON = metadataJSON
        self.promptAudioURL = promptAudioURL; self.promptImageURL = promptImageURL
        self.options = options
    }
}

@Model
final class CachedExerciseOption {
    @Attribute(.unique) var id: UUID
    var exerciseID: UUID
    var optionText: String
    var isCorrect: Bool
    var sortOrder: Int
    var optionAudioURL: String?
    var optionImageURL: String?

    @Relationship(inverse: \CachedExercise.options) var exercise: CachedExercise?

    init(id: UUID, exerciseID: UUID, optionText: String, isCorrect: Bool, sortOrder: Int,
         optionAudioURL: String?, optionImageURL: String?) {
        self.id = id; self.exerciseID = exerciseID; self.optionText = optionText
        self.isCorrect = isCorrect; self.sortOrder = sortOrder
        self.optionAudioURL = optionAudioURL; self.optionImageURL = optionImageURL
    }
}

// MARK: - User data cache

@Model
final class CachedUserStats {
    @Attribute(.unique) var userID: UUID
    var totalXP: Int
    var level: Int
    var currentStreak: Int
    var longestStreak: Int
    var hearts: Int
    var heartsMax: Int
    var gems: Int
    var coins: Int
    var lessonsCompleted: Int
    var wordsLearned: Int
    var currentLeague: String
    var weeklyXP: Int
    var lastSyncedAt: Date

    init(userID: UUID, totalXP: Int, level: Int, currentStreak: Int, longestStreak: Int,
         hearts: Int, heartsMax: Int, gems: Int, coins: Int, lessonsCompleted: Int,
         wordsLearned: Int, currentLeague: String, weeklyXP: Int, lastSyncedAt: Date) {
        self.userID = userID; self.totalXP = totalXP; self.level = level
        self.currentStreak = currentStreak; self.longestStreak = longestStreak
        self.hearts = hearts; self.heartsMax = heartsMax; self.gems = gems; self.coins = coins
        self.lessonsCompleted = lessonsCompleted; self.wordsLearned = wordsLearned
        self.currentLeague = currentLeague; self.weeklyXP = weeklyXP; self.lastSyncedAt = lastSyncedAt
    }
}

@Model
final class CachedVocabularyMastery {
    @Attribute(.unique) var id: UUID
    var vocabularyID: UUID
    var word: String
    var translationES: String
    var pronunciationURL: String?
    var masteryLevel: Int
    var easeFactor: Double
    var intervalDays: Int
    var nextReviewAt: Date?
    var lastSyncedAt: Date

    init(id: UUID, vocabularyID: UUID, word: String, translationES: String,
         pronunciationURL: String?, masteryLevel: Int, easeFactor: Double,
         intervalDays: Int, nextReviewAt: Date?, lastSyncedAt: Date) {
        self.id = id; self.vocabularyID = vocabularyID; self.word = word
        self.translationES = translationES; self.pronunciationURL = pronunciationURL
        self.masteryLevel = masteryLevel; self.easeFactor = easeFactor
        self.intervalDays = intervalDays; self.nextReviewAt = nextReviewAt
        self.lastSyncedAt = lastSyncedAt
    }
}

// MARK: - Offline queue

@Model
final class PendingSyncAction {
    @Attribute(.unique) var id: UUID
    var actionType: String
    var payloadJSON: String
    var createdAt: Date
    var retryCount: Int
    var lastError: String?

    init(id: UUID = UUID(), actionType: String, payloadJSON: String,
         createdAt: Date = .now, retryCount: Int = 0, lastError: String? = nil) {
        self.id = id; self.actionType = actionType; self.payloadJSON = payloadJSON
        self.createdAt = createdAt; self.retryCount = retryCount; self.lastError = lastError
    }
}

// All cached model types, for the ModelContainer schema.
enum CachedSchema {
    static let models: [any PersistentModel.Type] = [
        CachedCourse.self, CachedModule.self, CachedLesson.self, CachedExercise.self,
        CachedExerciseOption.self, CachedUserStats.self, CachedVocabularyMastery.self,
        PendingSyncAction.self,
    ]
}
