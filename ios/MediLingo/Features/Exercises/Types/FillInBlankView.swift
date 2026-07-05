import SwiftUI

// Type (or pick from a word bank) the term that completes the sentence.
struct FillInBlankView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var answer = ""
    @State private var phase: AnswerPhase = .answering

    private var meta: FillInBlankMeta {
        ExerciseMetadata.decode(FillInBlankMeta.self, from: exercise.metadataJSON, fallback: .default)
    }
    private var acceptable: [String] {
        var all = meta.acceptableAnswers
        if let correct = exercise.correctAnswer { all.append(correct) }
        return all
    }
    private var isCorrect: Bool {
        AnswerMatcher.matches(answer, against: acceptable, caseSensitive: meta.caseSensitive)
    }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            content: {
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    TextField("Respuesta", text: $answer)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(MLSpacing.md)
                        .background(Color.mlSurface)
                        .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                        .foregroundStyle(Color.mlTextPrimary)
                        .disabled(phase == .checked)

                    if let bank = meta.wordBank, !bank.isEmpty {
                        FlowChips(items: bank) { word in
                            if phase == .answering { answer = word }
                        }
                    }
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: !answer.trimmingCharacters(in: .whitespaces).isEmpty,
                isCorrect: isCorrect,
                explanation: correctAnswerHint,
                onCheck: { phase = .checked },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }

    private var correctAnswerHint: String? {
        if isCorrect { return exercise.explanationES ?? exercise.explanation }
        return "Respuesta: \(exercise.correctAnswer ?? acceptable.first ?? "")"
    }
}

/// Simple wrapping chip row for word banks / tokens.
struct FlowChips: View {
    let items: [String]
    let onTap: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: MLSpacing.sm)], spacing: MLSpacing.sm) {
            ForEach(items, id: \.self) { item in
                Button { onTap(item) } label: {
                    Text(item)
                        .font(MLFont.body())
                        .foregroundStyle(Color.mlTextPrimary)
                        .padding(.horizontal, MLSpacing.md)
                        .padding(.vertical, MLSpacing.sm)
                        .background(Color.mlSurfaceElevated)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
