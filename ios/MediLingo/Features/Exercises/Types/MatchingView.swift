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
    /// Briefly highlights a wrong pick in red.
    @State private var flashWrongID: String?

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
                onCheck: { withAnimation(MLMotion.smooth) { phase = .checked } },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }

    private func column(ids: [String], text: @escaping (String) -> String, isLeft: Bool) -> some View {
        VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
            ForEach(ids, id: \.self) { id in
                let isMatched = matched.contains(id)
                let isSelected = isLeft && selectedLeft == id
                let isWrongFlash = !isLeft && flashWrongID == id

                Button { tap(id: id, isLeft: isLeft) } label: {
                    Text(text(id))
                        .font(MLFont.bodyMedium)
                        .foregroundStyle(tileForeground(matched: isMatched))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .padding(.horizontal, MLSpacing.sm)
                        .padding(.vertical, MLSpacing.sm)
                        .background(tileBackground(matched: isMatched, selected: isSelected, wrong: isWrongFlash))
                }
                .buttonStyle(MLPressableButtonStyle())
                .disabled(isMatched || phase == .checked)
                .accessibilityLabel(accessibilityText(text(id), matched: isMatched, selected: isSelected))
            }
        }
    }

    private func tap(id: String, isLeft: Bool) {
        MLHaptic.selection()
        if isLeft {
            withAnimation(MLMotion.snappy) { selectedLeft = id }
        } else if let left = selectedLeft {
            if left == id {
                MLHaptic.correct()
                withAnimation(MLMotion.bouncy) { matched.insert(id) }
            } else {
                mistakes += 1
                MLHaptic.incorrect()
                withAnimation(MLMotion.snappy) { flashWrongID = id }
                Task {
                    try? await Task.sleep(for: .seconds(0.45))
                    withAnimation(MLMotion.snappy) { flashWrongID = nil }
                }
            }
            withAnimation(MLMotion.snappy) { selectedLeft = nil }
        }
    }

    private func tileForeground(matched: Bool) -> Color {
        matched ? .mlEmerald : .mlTextPrimary
    }

    private func tileBackground(matched: Bool, selected: Bool, wrong: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
        let fill: Color = if wrong { Color.mlError.opacity(0.14) }
            else if matched { Color.mlEmerald.opacity(0.12) }
            else if selected { Color.mlPrimary.opacity(0.12) }
            else { Color.mlSurface }
        let stroke: Color = if wrong { .mlError }
            else if matched { .mlEmerald.opacity(0.6) }
            else if selected { .mlPrimary }
            else { .mlCardStroke }
        return shape
            .fill(fill)
            .overlay(shape.strokeBorder(stroke, lineWidth: selected || wrong ? 2 : 1))
            .shadow(color: MLShadow.soft.color, radius: MLShadow.soft.radius, y: MLShadow.soft.y)
    }

    private func accessibilityText(_ text: String, matched: Bool, selected: Bool) -> String {
        if matched { return "\(text). Emparejada" }
        if selected { return "\(text). Seleccionada" }
        return text
    }
}
