import SwiftUI

// Drives the exercise-by-exercise lesson flow: queue, hearts, XP, re-queueing
// wrong answers (CLAUDE-ios.md § Lesson Flow Controller).
@MainActor
@Observable
final class LessonFlowViewModel {
    enum LessonFlowState: Sendable {
        case exercise
        case feedback
        case complete
        case outOfHearts
    }

    /// End-of-lesson result passed to the persistence layer. Score/XP are what
    /// the client observed; the server recomputes authoritative XP from the
    /// published lesson row in `record_lesson_completion`.
    struct Summary: Sendable {
        let lessonID: UUID
        let score: Double
        let isPerfect: Bool
        let timeMinutes: Int
        let exerciseCount: Int
        let xpEarned: Int
    }

    let lesson: Lesson
    var exercises: [Exercise]
    var currentIndex: Int = 0
    var hearts: Int
    var xpEarned: Int = 0
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var startTime: Date = .now
    var state: LessonFlowState = .exercise

    /// Count of exercises the lesson started with (re-queued misses don't inflate it).
    private let originalExerciseCount: Int
    private let isPremium: Bool
    /// Server-side heart decrement, fired on each wrong answer. Non-premium only.
    private let onHeartLost: @Sendable () async -> Void

    init(lesson: Lesson, exercises: [Exercise], hearts: Int, isPremium: Bool,
         onHeartLost: @escaping @Sendable () async -> Void = {}) {
        self.lesson = lesson
        self.exercises = exercises
        self.hearts = hearts
        self.isPremium = isPremium
        self.originalExerciseCount = exercises.count
        self.onHeartLost = onHeartLost
    }

    private func registerHeartLoss() {
        guard !isPremium else { return }
        Task { await onHeartLost() }
    }

    var summary: Summary {
        Summary(
            lessonID: lesson.id,
            score: accuracy,
            isPerfect: isPerfect,
            timeMinutes: max(0, Int(Date().timeIntervalSince(startTime) / 60)),
            exerciseCount: originalExerciseCount,
            xpEarned: xpEarned,
        )
    }

    var currentExercise: Exercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }

    var progress: Double {
        exercises.isEmpty ? 0 : Double(currentIndex) / Double(exercises.count)
    }

    /// Record a result from an exercise view (which has already shown its own
    /// correct/incorrect feedback) and advance. Returns immediately.
    func record(_ result: ExerciseResult) {
        if result.isCorrect {
            correctCount += 1
            xpEarned += result.xpEarned
        } else {
            incorrectCount += 1
            hearts -= 1
            registerHeartLoss()
            if hearts <= 0 && !isPremium {
                state = .outOfHearts
                return
            }
            // Re-queue the missed exercise for another attempt later this lesson.
            if currentIndex < exercises.count {
                exercises.append(exercises[currentIndex])
            }
        }
        advanceToNext()
    }

    var isPerfect: Bool { incorrectCount == 0 }
    var accuracy: Double {
        let total = correctCount + incorrectCount
        return total == 0 ? 0 : Double(correctCount) / Double(total)
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
            registerHeartLoss()
            MLHaptic.incorrect()
            MLSoundPlayer.play(.incorrect)

            if hearts <= 0 && !isPremium {
                state = .outOfHearts
                return
            }
            // Re-queue the missed exercise for another attempt later.
            exercises.append(exercises[currentIndex])
        }

        state = .feedback
        try? await Task.sleep(for: .seconds(1.5))
        advanceToNext()
    }

    func advanceToNext() {
        currentIndex += 1
        if currentIndex >= exercises.count {
            // Persistence (XP, quests, achievements) is driven by the view's
            // onFinish callback using `summary`; see LearningViewModel.
            state = .complete
        } else {
            state = .exercise
        }
    }
}
