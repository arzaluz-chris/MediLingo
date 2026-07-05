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

    let lesson: Lesson
    var exercises: [Exercise]
    var currentIndex: Int = 0
    var hearts: Int
    var xpEarned: Int = 0
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var startTime: Date = .now
    var state: LessonFlowState = .exercise

    private let isPremium: Bool

    init(lesson: Lesson, exercises: [Exercise], hearts: Int, isPremium: Bool) {
        self.lesson = lesson
        self.exercises = exercises
        self.hearts = hearts
        self.isPremium = isPremium
    }

    var currentExercise: Exercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }

    var progress: Double {
        exercises.isEmpty ? 0 : Double(currentIndex) / Double(exercises.count)
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
            state = .complete
            // TODO(phase-1): submit results via ProgressRepository.
        } else {
            state = .exercise
        }
    }
}
