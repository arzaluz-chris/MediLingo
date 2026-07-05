import Foundation

// Modified SM-2 spaced repetition (CLAUDE-content.md § Spaced Repetition).
// Pure, deterministic — no I/O, fully unit-testable.
struct SpacedRepetitionEngine {

    /// Quality ratings 0–5:
    /// 0 = complete blackout … 3 = correct with difficulty … 5 = perfect recall.
    struct ReviewResult: Equatable {
        let newInterval: Int
        let newEaseFactor: Double
        let newRepetitions: Int
        let newMasteryLevel: Int
    }

    static func calculateReview(
        quality: Int,
        repetitions: Int,
        previousInterval: Int,
        easeFactor: Double,
    ) -> ReviewResult {
        var newInterval: Int
        var newReps: Int

        if quality >= 3 {
            switch repetitions {
            case 0: newInterval = 1
            case 1: newInterval = 6
            default: newInterval = Int((Double(previousInterval) * easeFactor).rounded())
            }
            newReps = repetitions + 1
        } else {
            newInterval = 1
            newReps = 0
        }

        // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)); floor at 1.3.
        var newEF = easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        newEF = max(1.3, newEF)

        let masteryLevel: Int
        switch newReps {
        case 0: masteryLevel = 0
        case 1: masteryLevel = 1
        case 2...3: masteryLevel = 2
        case 4...6: masteryLevel = 3
        case 7...10: masteryLevel = 4
        default: masteryLevel = 5
        }

        return ReviewResult(
            newInterval: newInterval,
            newEaseFactor: newEF,
            newRepetitions: newReps,
            newMasteryLevel: masteryLevel,
        )
    }
}
