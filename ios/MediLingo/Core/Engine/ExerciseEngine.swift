import SwiftUI

// Exercise engine contracts (CLAUDE-ios.md § Exercise Engine). Exercises render
// from data, never hardcoded views. Each concrete exercise view model conforms
// to ExerciseEngineProtocol.

enum ExerciseState: Sendable {
    case answering
    case checking
    case correct
    case incorrect
    case skipped
}

@MainActor
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

// Routes an Exercise to its type-specific view (CLAUDE-ios.md § Exercise Engine).
// The 9 MVP types have dedicated views; heavier AI/game types fall back to a
// generic placeholder until implemented in a later phase.
struct ExerciseContainerView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    var body: some View {
        switch exercise.type {
        case .multipleChoice: MultipleChoiceView(exercise: exercise, onComplete: onComplete)
        case .imageSelection: ImageSelectionView(exercise: exercise, onComplete: onComplete)
        case .listening: ListeningView(exercise: exercise, onComplete: onComplete)
        case .fillInBlank: FillInBlankView(exercise: exercise, onComplete: onComplete)
        case .translation: TranslationView(exercise: exercise, onComplete: onComplete)
        case .sentenceOrdering: SentenceOrderingView(exercise: exercise, onComplete: onComplete)
        case .flashcard: FlashcardExerciseView(exercise: exercise, onComplete: onComplete)
        case .matching: MatchingView(exercise: exercise, onComplete: onComplete)
        case .typing: TypingView(exercise: exercise, onComplete: onComplete)
        case .pronunciation: PronunciationExerciseView(exercise: exercise, onComplete: onComplete)
        case .rolePlaying, .aiConversation, .clinicalCase, .patientInterview, .memoryGame:
            ExercisePlaceholderView(exercise: exercise, onComplete: onComplete)
        }
    }
}

private struct ExercisePlaceholderView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    var body: some View {
        VStack(spacing: MLSpacing.lg) {
            Text(exercise.type.rawValue)
                .font(MLFont.caption())
                .foregroundStyle(Color.mlTextTertiary)
            Text(exercise.prompt)
                .font(MLFont.heading())
                .foregroundStyle(Color.mlTextPrimary)
                .multilineTextAlignment(.center)
            MLButton(title: "Continuar") {
                onComplete(ExerciseResult(isCorrect: true, xpEarned: exercise.xpReward, explanation: exercise.explanation))
            }
            .fixedSize()
        }
        .padding(MLSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
