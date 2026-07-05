# CLAUDE-ios.md — MediLingo iOS App Specification

> Full spec for iOS app built with SwiftUI.
> Architecture, view hierarchy, data models, services, features, integrations.

---

## Table of Contents

1. [Architecture](#architecture)
2. [Project Configuration](#project-configuration)
3. [Design System](#design-system)
4. [SwiftData Models](#swiftdata-models)
5. [Service Layer](#service-layer)
6. [Repository Layer](#repository-layer)
7. [Feature Modules](#feature-modules)
8. [Exercise Engine](#exercise-engine)
9. [Audio Pipeline](#audio-pipeline)
10. [Pronunciation Engine](#pronunciation-engine)
11. [Offline Sync Strategy](#offline-sync-strategy)
12. [StoreKit 2 Integration](#storekit-2-integration)
13. [Push Notifications](#push-notifications)
14. [Widgets & Live Activities](#widgets--live-activities)
15. [Accessibility](#accessibility)
16. [Analytics Integration](#analytics-integration)
17. [Performance Optimization](#performance-optimization)
18. [Error Handling](#error-handling)

---

## Architecture

### MVVM + Repository + Service

```
┌──────────────────────────────────────────────────────┐
│                       Views                           │
│  (SwiftUI Views — pure UI, no business logic)         │
│  Observe ViewModels via @Observable                   │
└──────────────┬───────────────────────────────────────┘
               │ owns
               ▼
┌──────────────────────────────────────────────────────┐
│                    ViewModels                         │
│  @Observable classes                                  │
│  Handle UI state, user actions, navigation            │
│  Call Repository methods                              │
│  Transform data for display                           │
└──────────────┬───────────────────────────────────────┘
               │ uses
               ▼
┌──────────────────────────────────────────────────────┐
│                   Repositories                        │
│  Data access layer                                    │
│  Coordinate between remote (Supabase) and local       │
│  (SwiftData) data sources                             │
│  Handle caching strategy and offline sync             │
└───────┬──────────────────┬───────────────────────────┘
        │                  │
        ▼                  ▼
┌───────────────┐  ┌───────────────┐
│   Services    │  │   SwiftData   │
│ (Supabase,    │  │ (Local cache, │
│  AI, Audio,   │  │  offline      │
│  Speech,      │  │  data)        │
│  StoreKit)    │  │               │
└───────────────┘  └───────────────┘
```

### Dependency Injection

Use `@Observable` `AppDependencies` container registered in SwiftUI environment:

```swift
@Observable
final class AppDependencies {
    let authService: AuthServiceProtocol
    let contentRepository: ContentRepositoryProtocol
    let progressRepository: ProgressRepositoryProtocol
    let gamificationRepository: GamificationRepositoryProtocol
    let aiService: AIServiceProtocol
    let audioService: AudioServiceProtocol
    let speechService: SpeechServiceProtocol
    let subscriptionService: SubscriptionServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    let syncService: SyncServiceProtocol

    init() {
        // Initialize all services and repositories
        // Use protocols for testability
    }
}
```

### Navigation

Use `NavigationStack` with type-safe `NavigationPath` and `enum`-based routing:

```swift
enum AppRoute: Hashable {
    case courseDetail(Course)
    case lesson(Lesson)
    case exercise(Exercise)
    case flashcardReview
    case aiConversation(ConversationType)
    case clinicalCase(ClinicalCase)
    case profile
    case settings
    case achievements
    case leaderboard
    case friends
    case shop
    case subscription
}
```

---

## Project Configuration

### Deployment Target
- **iOS 17.0** min (for @Observable, SwiftData, new SwiftUI APIs)
- **Xcode 16+**
- **Swift 6** (strict concurrency when stable)

### Capabilities Required
- **Sign in with Apple**
- **Push Notifications**
- **Background Modes** (Audio, Background Fetch, Remote Notifications)
- **App Groups** (Widget data sharing)
- **In-App Purchase** (StoreKit 2)
- **Speech Recognition** (NSSpeechRecognitionUsageDescription)
- **Microphone** (NSMicrophoneUsageDescription)

### Info.plist Keys

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>MediLingo uses speech recognition to evaluate your medical English pronunciation.</string>
<key>NSMicrophoneUsageDescription</key>
<string>MediLingo needs microphone access to practice speaking medical English.</string>
```

### Third-Party Dependencies (SPM)

| Package | Purpose | Critical? |
|---------|---------|-----------|
| `supabase-swift` | Supabase client (Auth, DB, Storage, Realtime) | ✅ Yes |
| `RevenueCat` | Subscription mgmt | ✅ Yes |
| `Lottie` | Animations | ✅ Yes |
| `PostHog` | Product analytics | ✅ Yes |
| `FirebaseAnalytics` | Analytics | ✅ Yes |
| `FirebaseCrashlytics` | Crash reporting | ✅ Yes |
| `Rive` | Interactive animations (optional, characters) | ⚠️ Nice to have |
| `swift-snapshot-testing` | UI snapshot tests | 🧪 Dev only |

**Rule**: Minimize deps. Apple provides framework, use it instead.

---

## Design System

### Color Palette

```swift
extension Color {
    // Brand
    static let mlPrimary = Color(hex: "#4F46E5")       // Indigo — main brand
    static let mlSecondary = Color(hex: "#06B6D4")      // Cyan — secondary actions
    static let mlAccent = Color(hex: "#F59E0B")         // Amber — XP, rewards, highlights

    // Feedback
    static let mlSuccess = Color(hex: "#10B981")        // Green — correct answers
    static let mlError = Color(hex: "#EF4444")          // Red — wrong answers, hearts
    static let mlWarning = Color(hex: "#F59E0B")        // Amber — warnings
    static let mlInfo = Color(hex: "#3B82F6")           // Blue — info

    // Surfaces
    static let mlBackground = Color(hex: "#0F172A")     // Dark background
    static let mlSurface = Color(hex: "#1E293B")        // Card surface
    static let mlSurfaceElevated = Color(hex: "#334155") // Elevated surface

    // Text
    static let mlTextPrimary = Color(hex: "#F8FAFC")
    static let mlTextSecondary = Color(hex: "#94A3B8")
    static let mlTextTertiary = Color(hex: "#64748B")

    // Gamification
    static let mlXP = Color(hex: "#FBBF24")             // XP gold
    static let mlStreak = Color(hex: "#F97316")          // Streak orange/fire
    static let mlGems = Color(hex: "#8B5CF6")            // Gems purple
    static let mlHearts = Color(hex: "#EF4444")          // Hearts red

    // Leagues
    static let mlBronze = Color(hex: "#CD7F32")
    static let mlSilver = Color(hex: "#C0C0C0")
    static let mlGold = Color(hex: "#FFD700")
    static let mlDiamond = Color(hex: "#B9F2FF")
    static let mlMaster = Color(hex: "#9333EA")
}
```

### Typography

```swift
// Use system fonts with medical-professional feel
// Consider: SF Pro (system), or add Inter/Outfit from Google Fonts

enum MLFont {
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func heading(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular)
    }
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium)
    }
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}
```

### Component Library

Build these reusable components first, before any feature screens:

| Component | Description |
|-----------|-------------|
| `MLButton` | Primary, secondary, destructive, icon variants |
| `MLCard` | Surface card, shadow, rounded corners |
| `MLProgressBar` | Linear progress (lesson progress, XP bar) |
| `MLCircularProgress` | Circular progress (daily goal) |
| `MLStreakBadge` | Flame icon with streak count |
| `MLHeartDisplay` | Heart icons with count |
| `MLXPBadge` | XP display, animation on gain |
| `MLGemBadge` | Gem count display |
| `MLLevelBadge` | Level indicator |
| `MLAchievementCard` | Achievement unlock display |
| `MLLeagueIcon` | League tier icon (Bronze–Master) |
| `MLAudioPlayer` | Inline audio player with waveform |
| `MLExerciseHeader` | Progress bar + hearts for exercise flow |
| `MLAnswerFeedback` | Correct/incorrect overlay with explanation |
| `MLCharacterView` | Animated character illustration |
| `MLEmptyState` | Placeholder for empty lists |
| `MLLoadingView` | Skeleton loading states |
| `MLErrorView` | Error state with retry |

### Haptic Feedback

```swift
enum MLHaptic {
    static func correct() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func incorrect() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func levelUp() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        // + custom pattern via CoreHaptics
    }
    static func achievement() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
```

### Sound Effects

```swift
enum MLSound {
    case correct
    case incorrect
    case xpGain
    case levelUp
    case achievementUnlocked
    case streakMaintained
    case lessonComplete
    case heartLost
    case buttonTap
    case countdown

    var filename: String {
        switch self {
        case .correct: "correct.wav"
        case .incorrect: "incorrect.wav"
        // ... etc
        }
    }
}
```

---

## SwiftData Models

SwiftData ONLY for local caching and offline support. Source of truth always Supabase.

```swift
import SwiftData

// ============================================================
// CONTENT CACHE
// ============================================================

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
}

@Model
final class CachedModule {
    @Attribute(.unique) var id: UUID
    var courseID: UUID
    var title: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade) var lessons: [CachedLesson]
    @Relationship(inverse: \CachedCourse.modules) var course: CachedCourse?
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
    var isDownloaded: Bool = false  // for offline mode

    @Relationship(deleteRule: .cascade) var exercises: [CachedExercise]
    @Relationship(inverse: \CachedModule.lessons) var module: CachedModule?
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
    var metadataJSON: String    // JSON string of metadata JSONB
    var promptAudioURL: String?
    var promptImageURL: String?

    @Relationship(deleteRule: .cascade) var options: [CachedExerciseOption]
    @Relationship(inverse: \CachedLesson.exercises) var lesson: CachedLesson?
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
}

// ============================================================
// USER DATA CACHE
// ============================================================

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
}

// ============================================================
// OFFLINE QUEUE
// ============================================================

@Model
final class PendingSyncAction {
    @Attribute(.unique) var id: UUID
    var actionType: String   // "exercise_attempt", "flashcard_review", "xp_update"
    var payloadJSON: String  // JSON payload to send when online
    var createdAt: Date
    var retryCount: Int = 0
    var lastError: String?
}
```

---

## Service Layer

### Protocols

```swift
// ============================================================
// AUTH
// ============================================================
protocol AuthServiceProtocol: Sendable {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }

    func signInWithApple() async throws -> User
    func signInWithGoogle() async throws -> User
    func signInWithEmail(_ email: String, password: String) async throws -> User
    func signUp(email: String, password: String, name: String) async throws -> User
    func signOut() async throws
    func deleteAccount() async throws
    func refreshSession() async throws
}

// ============================================================
// AI
// ============================================================
protocol AIServiceProtocol: Sendable {
    func startConversation(type: ConversationType, scenario: Scenario?) async throws -> AIConversation
    func sendMessage(conversationID: UUID, message: String) async throws -> AIResponse
    func evaluatePronunciation(audioData: Data, expectedText: String) async throws -> PronunciationResult
    func generateExplanation(exercise: Exercise, userAnswer: String) async throws -> String
}

// ============================================================
// AUDIO
// ============================================================
protocol AudioServiceProtocol: Sendable {
    func play(url: URL) async throws
    func playLocal(filename: String) async throws
    func pause()
    func stop()
    func setPlaybackSpeed(_ speed: Float)
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
}

// ============================================================
// SPEECH RECOGNITION
// ============================================================
protocol SpeechServiceProtocol: Sendable {
    func startRecording() async throws
    func stopRecording() async throws -> SpeechResult
    func requestAuthorization() async -> Bool
    var isRecording: Bool { get }
    var isAvailable: Bool { get }
}

// ============================================================
// SUBSCRIPTIONS
// ============================================================
protocol SubscriptionServiceProtocol: Sendable {
    var isPremium: Bool { get }
    var currentSubscription: SubscriptionInfo? { get }

    func fetchProducts() async throws -> [SubscriptionProduct]
    func purchase(_ product: SubscriptionProduct) async throws -> PurchaseResult
    func restorePurchases() async throws
    func checkEntitlements() async throws -> Bool
}

// ============================================================
// ANALYTICS
// ============================================================
protocol AnalyticsServiceProtocol: Sendable {
    func track(_ event: AnalyticsEvent)
    func setUser(_ userID: String)
    func setUserProperty(_ key: String, value: String)
}
```

---

## Repository Layer

```swift
// ============================================================
// CONTENT REPOSITORY
// ============================================================
protocol ContentRepositoryProtocol {
    func fetchCourses() async throws -> [Course]
    func fetchModules(courseID: UUID) async throws -> [Module]
    func fetchLessons(moduleID: UUID) async throws -> [Lesson]
    func fetchExercises(lessonID: UUID) async throws -> [Exercise]
    func fetchVocabulary(lessonID: UUID) async throws -> [VocabularyWord]
    func searchVocabulary(query: String) async throws -> [VocabularyWord]
    func downloadLessonForOffline(lessonID: UUID) async throws
    func syncContent() async throws  // Pull latest from server
}

// ============================================================
// PROGRESS REPOSITORY
// ============================================================
protocol ProgressRepositoryProtocol {
    func getUserProgress(courseID: UUID) async throws -> CourseProgress
    func submitExerciseAttempt(_ attempt: ExerciseAttempt) async throws -> ExerciseResult
    func completeLesson(lessonID: UUID, score: Double, xpEarned: Int) async throws
    func getCompletedLessons(moduleID: UUID) async throws -> Set<UUID>
    func syncProgress() async throws  // Push pending, pull latest
}

// ============================================================
// GAMIFICATION REPOSITORY
// ============================================================
protocol GamificationRepositoryProtocol {
    func getUserStats() async throws -> UserStats
    func addXP(_ amount: Int) async throws -> UserStats
    func consumeHeart() async throws -> Int  // returns remaining hearts
    func refillHearts() async throws -> Int
    func getDailyQuests() async throws -> [DailyQuest]
    func updateQuestProgress(questID: UUID, increment: Int) async throws
    func getAchievements() async throws -> [Achievement]
    func getUnlockedAchievements() async throws -> Set<UUID>
    func checkAndUnlockAchievements() async throws -> [Achievement]  // newly unlocked
    func getLeagueStandings() async throws -> LeagueStandings
}

// ============================================================
// FLASHCARD REPOSITORY
// ============================================================
protocol FlashcardRepositoryProtocol {
    func getDueFlashcards(limit: Int) async throws -> [FlashcardItem]
    func submitReview(vocabularyID: UUID, quality: Int) async throws
    func getStats() async throws -> FlashcardStats
    func addWord(vocabularyID: UUID) async throws
}
```

---

## Feature Modules

### 1. Authentication & Onboarding

```
Auth/
├── AuthView.swift              ← Welcome screen with sign-in options
├── AuthViewModel.swift
├── OnboardingView.swift         ← Multi-step onboarding flow
├── OnboardingViewModel.swift
├── Views/
│   ├── WelcomeHeroView.swift   ← Animated hero with characters
│   ├── RoleSelectionView.swift  ← Select profession
│   ├── LevelSelectionView.swift ← English proficiency
│   ├── GoalSelectionView.swift  ← Primary learning goal
│   ├── SpecialtyView.swift      ← Optional specialty
│   └── DailyGoalView.swift      ← Time commitment
```

### 2. Home / Dashboard

```
Home/
├── HomeView.swift               ← Main tab — daily stats, continue learning
├── HomeViewModel.swift
├── Views/
│   ├── DailyStatsCard.swift     ← XP today, streak, hearts, daily goal ring
│   ├── ContinueLearningCard.swift ← Resume last lesson
│   ├── DailyQuestsView.swift    ← Today's 3 quests with progress
│   ├── StreakCalendarView.swift  ← Calendar heatmap of activity
│   └── WordOfTheDayCard.swift   ← Featured vocabulary word
```

### 3. Learning / Course Tree

```
Learning/
├── CourseListView.swift          ← Browse all courses
├── CourseDetailView.swift        ← Modules as Duolingo-style tree
├── CourseViewModel.swift
├── ModuleView.swift              ← Expanded module with lessons
├── LessonFlowView.swift          ← Exercise-by-exercise flow (full screen)
├── LessonFlowViewModel.swift     ← Manages exercise queue, hearts, XP
├── LessonCompleteView.swift      ← Score summary, XP gained, rewards
├── Views/
│   ├── CourseCard.swift
│   ├── ModuleNode.swift          ← Circular node in learning tree
│   ├── LessonCell.swift
│   ├── LessonProgressPath.swift  ← SVG-like path between nodes
│   └── PremiumLockOverlay.swift
```

### 4. Exercise Views

```
Exercises/
├── ExerciseContainerView.swift   ← Routes to correct exercise type view
├── Types/
│   ├── MultipleChoiceView.swift
│   ├── ImageSelectionView.swift
│   ├── ListeningView.swift
│   ├── PronunciationView.swift
│   ├── FillInBlankView.swift
│   ├── SentenceOrderingView.swift
│   ├── TranslationView.swift
│   ├── FlashcardExerciseView.swift
│   ├── MatchingView.swift
│   ├── TypingView.swift
│   ├── RolePlayingView.swift
│   ├── ClinicalCaseView.swift
│   ├── PatientInterviewView.swift
│   └── MemoryGameView.swift
├── Components/
│   ├── ExerciseProgressBar.swift
│   ├── AnswerButton.swift
│   ├── AudioPlayButton.swift
│   ├── CheckAnswerButton.swift
│   ├── CorrectAnswerOverlay.swift
│   ├── IncorrectAnswerOverlay.swift
│   └── HintButton.swift
```

### 5. AI Conversation

```
AIConversation/
├── AIConversationView.swift      ← Chat interface with AI patient
├── AIConversationViewModel.swift
├── Views/
│   ├── MessageBubble.swift
│   ├── PatientProfileCard.swift
│   ├── ScenarioIntroView.swift
│   ├── ConversationScoreView.swift
│   ├── SpeakButton.swift
│   └── SuggestionsBar.swift
```

### 6. Flashcards

```
Flashcards/
├── FlashcardReviewView.swift     ← Swipeable card stack
├── FlashcardReviewViewModel.swift
├── Views/
│   ├── FlashcardView.swift       ← Flippable card (front: English, back: Spanish + details)
│   ├── FlashcardStatsView.swift
│   ├── QualityButtons.swift      ← SM-2 quality rating (Again, Hard, Good, Easy)
│   └── ReviewSummaryView.swift
```

### 7. Profile & Stats

```
Profile/
├── ProfileView.swift
├── ProfileViewModel.swift
├── Views/
│   ├── StatsOverview.swift       ← XP, Level, Streak, Words, Time
│   ├── StreakHistoryView.swift
│   ├── LearningChartView.swift   ← Swift Charts — XP over time
│   ├── VocabularyListView.swift  ← All learned words with mastery level
│   ├── AchievementsGridView.swift
│   └── CertificatesView.swift
```

### 8. Social

```
Social/
├── FriendsView.swift
├── LeaderboardView.swift
├── LeagueView.swift
├── Views/
│   ├── FriendCell.swift
│   ├── LeaderboardRow.swift
│   ├── LeagueTierBadge.swift
│   ├── AddFriendView.swift
│   └── ChallengeView.swift
```

### 9. Subscription

```
Subscription/
├── PaywallView.swift             ← Premium upsell screen
├── PaywallViewModel.swift
├── Views/
│   ├── PremiumFeatureRow.swift
│   ├── PricingCard.swift
│   ├── TrialBanner.swift
│   └── RestorePurchasesButton.swift
```

### 10. Shop

```
Shop/
├── ShopView.swift
├── ShopViewModel.swift
├── Views/
│   ├── ShopItemCard.swift
│   ├── GemBalanceView.swift
│   ├── PurchaseConfirmation.swift
│   └── InventoryView.swift
```

---

## Exercise Engine

Exercise Engine = critical system component. Renders exercises from data (JSON/database), NOT from hardcoded views.

### Architecture

```swift
/// Protocol that all exercise view models conform to
protocol ExerciseEngineProtocol: Observable {
    var exercise: Exercise { get }
    var state: ExerciseState { get }
    var isAnswered: Bool { get }
    var isCorrect: Bool? { get }
    var canSubmit: Bool { get }

    func submit() async
    func showHint()
    func skip()
}

enum ExerciseState {
    case answering      // User is working on it
    case checking       // Evaluating answer
    case correct        // Answered correctly
    case incorrect      // Answered incorrectly
    case skipped        // User skipped
}

/// Main container that routes to the right exercise view
struct ExerciseContainerView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    var body: some View {
        switch exercise.type {
        case .multipleChoice:
            MultipleChoiceView(exercise: exercise, onComplete: onComplete)
        case .listening:
            ListeningView(exercise: exercise, onComplete: onComplete)
        case .pronunciation:
            PronunciationView(exercise: exercise, onComplete: onComplete)
        // ... all 15 types
        }
    }
}
```

### Lesson Flow Controller

```swift
@Observable
final class LessonFlowViewModel {
    let lesson: Lesson
    var exercises: [Exercise]
    var currentIndex: Int = 0
    var hearts: Int
    var xpEarned: Int = 0
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var startTime: Date = .now
    var state: LessonFlowState = .exercise

    enum LessonFlowState {
        case exercise       // Showing an exercise
        case feedback       // Showing correct/incorrect feedback
        case complete       // Lesson finished
        case outOfHearts    // No hearts left
    }

    var currentExercise: Exercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }

    var progress: Double {
        Double(currentIndex) / Double(exercises.count)
    }

    func handleExerciseResult(_ result: ExerciseResult) async {
        if result.isCorrect {
            correctCount += 1
            xpEarned += result.xpEarned
            MLHaptic.correct()
            MLSoundPlayer.play(.correct)
        } else {
            incorrectCount += 1
            hearts -= 1
            MLHaptic.incorrect()
            MLSoundPlayer.play(.incorrect)

            if hearts <= 0 && !isPremium {
                state = .outOfHearts
                return
            }

            // Re-queue incorrect exercise for later
            exercises.append(exercises[currentIndex])
        }

        state = .feedback

        // After feedback delay, advance
        try? await Task.sleep(for: .seconds(1.5))
        advanceToNext()
    }

    func advanceToNext() {
        currentIndex += 1
        if currentIndex >= exercises.count {
            state = .complete
            // Submit results to repository
        } else {
            state = .exercise
        }
    }
}
```

---

## Audio Pipeline

### Playback (AVFoundation)

```swift
@Observable
final class AudioService: AudioServiceProtocol {
    private var player: AVAudioPlayer?
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    func play(url: URL) async throws {
        // Download if remote URL, then play
        let data: Data
        if url.isFileURL {
            data = try Data(contentsOf: url)
        } else {
            let (downloaded, _) = try await URLSession.shared.data(from: url)
            data = downloaded
        }

        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        player = try AVAudioPlayer(data: data)
        player?.prepareToPlay()
        player?.play()
        isPlaying = true
        duration = player?.duration ?? 0
    }

    func setPlaybackSpeed(_ speed: Float) {
        player?.enableRate = true
        player?.rate = speed
    }
}
```

### Recording (for pronunciation)

```swift
@Observable
final class AudioRecorder {
    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?
    var isRecording: Bool = false

    func startRecording() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        recordingURL = url
        isRecording = true
    }

    func stopRecording() -> URL? {
        recorder?.stop()
        isRecording = false
        return recordingURL
    }
}
```

---

## Pronunciation Engine

### Architecture

```
User speaks → Speech Framework (on-device STT) →
  Transcription + confidence scores →
  Compare against expected text →
  Send audio to Edge Function for detailed AI evaluation →
  Return: pronunciation score, specific corrections, phoneme feedback
```

### On-Device (Apple Speech Framework)

```swift
@Observable
final class SpeechService: SpeechServiceProtocol {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var isRecording: Bool = false

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startRecording() async throws {
        guard let recognizer, recognizer.isAvailable else {
            throw AppError.speechNotAvailable
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            // Process results...
        }
    }
}
```

### Server-Side AI Evaluation

After on-device STT, send audio + transcription to Edge Function:

```swift
func evaluatePronunciation(
    audioURL: URL,
    expectedText: String,
    userTranscription: String
) async throws -> PronunciationResult {
    // 1. Upload audio to Supabase Storage (temporary)
    // 2. Call Edge Function with audio URL + expected text
    // 3. AI evaluates: pronunciation accuracy, fluency, medical terminology
    // 4. Return structured score
}

struct PronunciationResult {
    let overallScore: Double          // 0-100
    let pronunciationScore: Double    // 0-100
    let fluencyScore: Double          // 0-100
    let accuracy: Double              // 0-100 (word-level accuracy)
    let corrections: [PronunciationCorrection]
    let feedback: String              // Natural language feedback
}

struct PronunciationCorrection {
    let word: String
    let expected: String              // How it should sound (IPA)
    let detected: String              // What was detected
    let suggestion: String            // Tip for improvement
}
```

---

## Offline Sync Strategy

### Principle: Offline-First with Eventually Consistent Sync

```
┌─────────────────────────────────────────────┐
│              APP (Online)                    │
│                                              │
│  Read: SwiftData cache → fallback Supabase   │
│  Write: SwiftData immediately + queue sync   │
│  Sync: Background task pushes pending queue  │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│              APP (Offline)                   │
│                                              │
│  Read: SwiftData cache only                  │
│  Write: SwiftData + add to PendingSyncQueue  │
│  Sync: Retry when connectivity restored      │
└─────────────────────────────────────────────┘
```

### Sync Service

```swift
@Observable
final class SyncService {
    private let modelContext: ModelContext
    private let supabase: SupabaseClient
    private var networkMonitor = NWPathMonitor()

    /// Sync all pending actions to server
    func syncPendingActions() async throws {
        let pending = try modelContext.fetch(
            FetchDescriptor<PendingSyncAction>(
                sortBy: [SortDescriptor(\.createdAt)]
            )
        )

        for action in pending {
            do {
                try await processAction(action)
                modelContext.delete(action)
            } catch {
                action.retryCount += 1
                action.lastError = error.localizedDescription
                if action.retryCount > 5 {
                    // Log and skip after 5 retries
                    modelContext.delete(action)
                }
            }
        }

        try modelContext.save()
    }

    /// Pull latest content from server
    func syncContent() async throws {
        // 1. Fetch courses updated since last sync
        // 2. Fetch modules, lessons, exercises
        // 3. Update SwiftData cache
        // 4. Update lastSyncedAt timestamps
    }
}
```

### Background Sync

```swift
// Register background task in AppDelegate
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.medilingo.sync",
    using: nil
) { task in
    self.handleBackgroundSync(task as! BGAppRefreshTask)
}
```

---

## StoreKit 2 Integration

```swift
@Observable
final class SubscriptionService: SubscriptionServiceProtocol {
    var isPremium: Bool = false
    var products: [Product] = []

    static let monthlyID = "com.medilingo.premium.monthly"
    static let annualID = "com.medilingo.premium.annual"

    func fetchProducts() async throws -> [SubscriptionProduct] {
        let storeProducts = try await Product.products(for: [
            Self.monthlyID,
            Self.annualID
        ])
        // Map to domain models
    }

    func purchase(_ product: SubscriptionProduct) async throws -> PurchaseResult {
        guard let storeProduct = products.first(where: { $0.id == product.id }) else {
            throw AppError.productNotFound
        }

        let result = try await storeProduct.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerification(verification)
            await transaction.finish()
            isPremium = true
            // Update Supabase profile
            // Sync with RevenueCat
            return .success
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .failed
        }
    }

    /// Listen for transaction updates (renewals, revocations)
    func listenForTransactions() async {
        for await result in Transaction.updates {
            guard let transaction = try? checkVerification(result) else { continue }
            await transaction.finish()
            await updateSubscriptionStatus()
        }
    }
}
```

---

## Push Notifications

### Notification Types

| Type | Trigger | Content |
|------|---------|---------|
| **Streak Reminder** | Daily at user's preferred time | "Don't break your 15-day streak! 🔥" |
| **Streak at Risk** | 2 hours before midnight if no activity | "Your streak ends in 2 hours!" |
| **Daily Quest** | Morning | "Your daily quests are ready! 📋" |
| **Friend Activity** | Friend completes milestone | "Dr. Ana just reached Level 10! 🎉" |
| **Challenge** | Received a challenge | "Dr. Carlos challenged you! ⚔️" |
| **New Content** | Weekly | "New lesson: Emergency Cardiology 🫀" |
| **Achievement** | Earned an achievement | "Achievement unlocked: First Diagnosis 🏆" |
| **Re-engagement** | 3 days inactive | "We miss you! Your patients are waiting 🩺" |

### Implementation

```swift
func scheduleStreakReminder(time: DateComponents) {
    let content = UNMutableNotificationContent()
    content.title = "Time to practice! 🩺"
    content.body = "Keep your \(streak)-day streak alive!"
    content.sound = .default
    content.badge = 1

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: time,
        repeats: true
    )

    let request = UNNotificationRequest(
        identifier: "streak-reminder",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
}
```

---

## Widgets & Live Activities

### Widget: Daily Streak

```swift
struct StreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "StreakWidget",
            provider: StreakTimelineProvider()
        ) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Streak")
        .description("See your learning streak at a glance")
        .supportedFamilies([.systemSmall])
    }
}
```

### Widget: Word of the Day

```swift
struct WordOfDayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "WordOfDayWidget",
            provider: WordOfDayProvider()
        ) { entry in
            WordOfDayWidgetView(entry: entry)
                // Shows: word, pronunciation, translation
        }
        .configurationDisplayName("Word of the Day")
        .description("Learn a new medical term every day")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

### Live Activity: Lesson in Progress

```swift
struct LessonActivity: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let exerciseNumber: Int
        let totalExercises: Int
        let xpEarned: Int
        let hearts: Int
        let lessonTitle: String
    }
}
```

---

## Accessibility

### Requirements

- **VoiceOver**: All interactive elements have meaningful labels
- **Dynamic Type**: All text scales with user font size preference
- **Reduce Motion**: Disable animations when `UIAccessibility.isReduceMotionEnabled`
- **Color Contrast**: Min 4.5:1 contrast ratio for text
- **Audio descriptions**: Alt text for audio-only exercises
- **Keyboard navigation**: Full support for external keyboards
- **Switch Control**: Compatible interaction patterns

### Implementation Pattern

```swift
Button(action: { /* ... */ }) {
    HStack {
        Image(systemName: "checkmark.circle.fill")
        Text("Submit Answer")
    }
}
.accessibilityLabel("Submit your answer")
.accessibilityHint("Double tap to check if your answer is correct")
.accessibilityAddTraits(.isButton)
```

---

## Analytics Integration

### Event Taxonomy

```swift
enum AnalyticsEvent {
    // Onboarding
    case onboardingStarted
    case onboardingRoleSelected(role: String)
    case onboardingCompleted(role: String, level: String, goal: String)

    // Learning
    case lessonStarted(lessonID: String, courseID: String)
    case lessonCompleted(lessonID: String, score: Double, xp: Int, time: Int)
    case exerciseAttempted(type: String, correct: Bool, time: Int)
    case exerciseSkipped(type: String)

    // Gamification
    case streakMaintained(days: Int)
    case streakBroken(previousDays: Int)
    case levelUp(newLevel: Int)
    case achievementUnlocked(slug: String)
    case dailyQuestCompleted(questType: String)

    // AI
    case aiConversationStarted(type: String)
    case aiConversationCompleted(type: String, duration: Int, score: Double)
    case pronunciationEvaluated(score: Double, word: String)

    // Monetization
    case paywallViewed(source: String)
    case purchaseStarted(productID: String)
    case purchaseCompleted(productID: String, price: Double)
    case purchaseCancelled(productID: String)

    // Engagement
    case appOpened
    case sessionEnded(duration: Int)
    case flashcardReviewed(count: Int)
    case vocabularySearched(query: String)
}
```

---

## Performance Optimization

### Image Loading
- Use `AsyncImage` with placeholder
- Cache images with `URLCache` or custom disk cache
- Use WebP format for illustrations where possible

### Audio Preloading
- Preload next exercise audio while current one answered
- Cache frequently used audio (common medical terms) on disk

### SwiftData Optimization
- Use `FetchDescriptor` with `fetchLimit` for large result sets
- Use `@Query` with sort descriptors for automatic UI updates
- Batch inserts for sync operations

### Memory Management
- Weak references in closures
- Cancel unnecessary network requests on navigation away
- Release audio resources when not in use

---

## Error Handling

```swift
enum AppError: LocalizedError {
    // Network
    case networkUnavailable
    case serverError(statusCode: Int, message: String)
    case timeout

    // Auth
    case authenticationRequired
    case sessionExpired
    case accountDeleted

    // Content
    case contentNotFound
    case contentNotDownloaded
    case exerciseCorrupted

    // Audio
    case microphonePermissionDenied
    case speechNotAvailable
    case audioPlaybackFailed

    // Subscription
    case productNotFound
    case purchaseFailed(String)
    case notPremium

    // Game
    case insufficientHearts
    case insufficientGems

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Some features require connectivity."
        case .insufficientHearts:
            return "You've run out of hearts! Wait for them to refill or upgrade to Premium."
        // ... etc
        }
    }
}
```

### Error Recovery Strategy

| Error | Recovery |
|-------|----------|
| Network unavailable | Switch to offline mode, queue actions |
| Session expired | Auto-refresh token, re-authenticate if needed |
| Insufficient hearts | Show paywall or wait timer |
| Audio permission denied | Show settings prompt |
| Content not found | Force sync, show error with retry |
| Purchase failed | Show error, suggest retry or contact support |