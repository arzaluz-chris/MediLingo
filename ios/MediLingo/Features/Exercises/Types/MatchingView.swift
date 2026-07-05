import SwiftUI

// Match terms with meanings. Pairs are grouped by exercise_options.match_pair_id.
struct MatchingView: View {
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var selectedLeft: String?
    @State private var matched: Set<String> = []
    @State private var mistakes = 0
    @State private var rightOrder: [String] = []
    @State private var phase: AnswerPhase = .answering

    private struct Pair { let id: String; let left: String; let right: String }

    private var pairs: [Pair] {
        let groups = Dictionary(grouping: exercise.options) { $0.matchPairID ?? $0.id.uuidString }
        return groups.compactMap { key, opts -> Pair? in
            let sorted = opts.sorted { $0.sortOrder < $1.sortOrder }
            guard sorted.count >= 2 else { return nil }
            return Pair(id: key, left: sorted[0].text, right: sorted[1].text)
        }
        .sorted { $0.id < $1.id }
    }
    private var allMatched: Bool { matched.count == pairs.count && !pairs.isEmpty }
    private var isCorrect: Bool { mistakes == 0 }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            content: {
                HStack(alignment: .top, spacing: MLSpacing.md) {
                    column(ids: pairs.map(\.id), text: { id in pairs.first { $0.id == id }?.left ?? "" }, isLeft: true)
                    column(ids: rightOrder, text: { id in pairs.first { $0.id == id }?.right ?? "" }, isLeft: false)
                }
                .onAppear { if rightOrder.isEmpty { rightOrder = pairs.map(\.id).shuffled() } }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: allMatched,
                isCorrect: isCorrect,
                explanation: isCorrect ? exercise.explanation : "Errores: \(mistakes)",
                onCheck: { phase = .checked },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }

    private func column(ids: [String], text: @escaping (String) -> String, isLeft: Bool) -> some View {
        VStack(spacing: MLSpacing.sm) {
            ForEach(ids, id: \.self) { id in
                let isMatched = matched.contains(id)
                let isSelected = isLeft && selectedLeft == id
                Button { tap(id: id, isLeft: isLeft) } label: {
                    Text(text(id))
                        .font(MLFont.body())
                        .foregroundStyle(Color.mlTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .padding(.horizontal, MLSpacing.sm)
                        .background(background(matched: isMatched, selected: isSelected))
                        .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                }
                .disabled(isMatched || phase == .checked)
                .opacity(isMatched ? 0.5 : 1)
            }
        }
    }

    private func tap(id: String, isLeft: Bool) {
        MLHaptic.tap()
        if isLeft {
            selectedLeft = id
        } else if let left = selectedLeft {
            if left == id {
                matched.insert(id)
            } else {
                mistakes += 1
                MLHaptic.incorrect()
            }
            selectedLeft = nil
        }
    }

    private func background(matched: Bool, selected: Bool) -> Color {
        if matched { return Color.mlSuccess.opacity(0.25) }
        if selected { return Color.mlPrimary.opacity(0.25) }
        return Color.mlSurface
    }
}
