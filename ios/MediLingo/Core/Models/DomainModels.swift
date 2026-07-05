import Foundation

// Domain models — the app's in-memory value types. These decode from Supabase
// (snake_case → camelCase via CodingKeys where needed) and are cached locally by
// the SwiftData `Cached*` models. Kept intentionally lean for Phase 0.

// MARK: - Identity

struct User: Identifiable, Hashable, Sendable {
    let id: UUID
    let email: String
    var displayName: String
}

// MARK: - Content

enum ExerciseType: String, Codable, CaseIterable, Sendable {
    case multipleChoice = "multiple_choice"
    case imageSelection = "image_selection"
    case listening
    case pronunciation
    case fillInBlank = "fill_in_blank"
    case sentenceOrdering = "sentence_ordering"
    case translation
    case flashcard
    case matching
    case typing
    case rolePlaying = "role_playing"
    case aiConversation = "ai_conversation"
    case clinicalCase = "clinical_case"
    case patientInterview = "patient_interview"
    case memoryGame = "memory_game"
}

enum Difficulty: String, Codable, Sendable {
    case beginner, intermediate, advanced
}

struct Course: Identifiable, Hashable, Sendable {
    let id: UUID
    let slug: String
    let title: String
    var shortDesc: String
    var colorHex: String
    var difficulty: Difficulty
    var isPremium: Bool
    var sortOrder: Int
}

struct Module: Identifiable, Hashable, Sendable {
    let id: UUID
    let courseID: UUID
    let title: String
    var sortOrder: Int
}

struct Lesson: Identifiable, Hashable, Sendable {
    let id: UUID
    let moduleID: UUID
    let title: String
    var lessonType: String
    var difficulty: Difficulty
    var estimatedMinutes: Int
    var xpReward: Int
    var sortOrder: Int
    var isPremium: Bool
}

struct ExerciseOption: Identifiable, Hashable, Sendable {
    let id: UUID
    var text: String
    var isCorrect: Bool
    var sortOrder: Int
    var audioURL: String?
    var imageURL: String?
    var matchPairID: String?
}

struct Exercise: Identifiable, Hashable, Sendable {
    let id: UUID
    let lessonID: UUID
    let type: ExerciseType
    var prompt: String
    var promptAudioURL: String?
    var promptImageURL: String?
    var correctAnswer: String?
    var explanation: String?
    var explanationES: String?
    var hint: String?
    var difficulty: Difficulty
    var xpReward: Int
    var sortOrder: Int
    /// Raw JSON of the type-specific metadata (see /shared/schemas).
    var metadataJSON: String
    var options: [ExerciseOption]
}

struct VocabularyWord: Identifiable, Hashable, Sendable {
    let id: UUID
    var word: String
    var phonetic: String?
    var translationES: String
    var definitionEN: String
    var exampleEN: String
    var pronunciationURL: String?
}

// MARK: - Progress

struct CourseProgress: Sendable {
    let courseID: UUID
    var completedLessons: Int
    var totalLessons: Int
    var xpEarned: Int
}

struct ExerciseAttempt: Sendable {
    let exerciseID: UUID
    let lessonID: UUID
    var userAnswer: String?
    var isCorrect: Bool
    var timeSpentMs: Int
}

struct ExerciseResult: Sendable {
    let isCorrect: Bool
    let xpEarned: Int
    var explanation: String?
}

// MARK: - Gamification

struct UserStats: Sendable {
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

    static let empty = UserStats(
        totalXP: 0, level: 1, currentStreak: 0, longestStreak: 0,
        hearts: 5, heartsMax: 5, gems: 0, coins: 0,
        lessonsCompleted: 0, wordsLearned: 0, currentLeague: "bronze", weeklyXP: 0,
    )
}

struct DailyQuest: Identifiable, Sendable {
    let id: UUID
    var title: String
    var description: String
    var questType: String
    var targetValue: Int
    var currentValue: Int
    var isCompleted: Bool
}

struct Achievement: Identifiable, Sendable {
    let id: UUID
    var slug: String
    var title: String
    var description: String
    var category: String
    var xpReward: Int
    var gemReward: Int
    var isUnlocked: Bool
}

struct LeagueStandings: Sendable {
    let tier: String
    var members: [LeagueMember]
}

struct LeagueMember: Identifiable, Sendable {
    let id: UUID
    var displayName: String
    var weeklyXP: Int
    var rank: Int
}

// MARK: - Flashcards

struct FlashcardItem: Identifiable, Sendable {
    let id: UUID
    let vocabularyID: UUID
    var word: String
    var translationES: String
    var masteryLevel: Int
}

struct FlashcardStats: Sendable {
    var due: Int
    var learned: Int
    var mastered: Int
}

// MARK: - AI

enum ConversationType: String, Codable, Sendable, Hashable {
    case patientConsultation = "patient_consultation"
    case phoneTriage = "phone_triage"
    case erScenario = "er_scenario"
    case medicalInterview = "medical_interview"
    case colleagueDiscussion = "colleague_discussion"
    case freePractice = "free_practice"
    case clinicalCase = "clinical_case"
}

struct Scenario: Codable, Sendable, Hashable {
    var patientName: String
    var chiefComplaint: String
}

struct AIConversation: Identifiable, Sendable {
    let id: UUID
    let type: ConversationType
}

struct AIResponse: Sendable {
    let content: String
    var scores: [String: Double]?
}

struct PronunciationResult: Sendable {
    let overallScore: Double
    let pronunciationScore: Double
    let fluencyScore: Double
    let accuracy: Double
    let corrections: [PronunciationCorrection]
    let feedback: String
}

struct PronunciationCorrection: Sendable {
    let word: String
    let expected: String
    let detected: String
    let suggestion: String
}

struct SpeechResult: Sendable {
    let transcription: String
    let confidence: Double
}

// MARK: - Subscriptions

struct SubscriptionInfo: Sendable {
    let productID: String
    let expiresAt: Date?
    let isTrial: Bool
}

struct SubscriptionProduct: Identifiable, Sendable {
    let id: String
    let displayName: String
    let price: String
}

enum PurchaseResult: Sendable {
    case success, cancelled, pending, failed
}

// MARK: - Clinical case (route payload)

struct ClinicalCase: Identifiable, Hashable, Sendable {
    let id: UUID
    var title: String
}

// MARK: - Analytics

enum AnalyticsEvent: Sendable {
    case appOpened
    case onboardingStarted
    case onboardingCompleted(role: String, level: String, goal: String)
    case lessonStarted(lessonID: String, courseID: String)
    case lessonCompleted(lessonID: String, score: Double, xp: Int, time: Int)
    case exerciseAttempted(type: String, correct: Bool, time: Int)
    case levelUp(newLevel: Int)
    case achievementUnlocked(slug: String)
    case paywallViewed(source: String)
    case purchaseCompleted(productID: String, price: Double)
}
