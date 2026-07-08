import SwiftUI

// Listen to a clip, then choose what was described. Audio in prompt_audio_url.
struct ListeningView: View {
    @Environment(AppDependencies.self) private var dependencies
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    @State private var selectedID: UUID?
    @State private var phase: AnswerPhase = .answering
    @State private var replays = 0
    @State private var playCount = 0

    private var meta: ListeningMeta {
        ExerciseMetadata.decode(ListeningMeta.self, from: exercise.metadataJSON, fallback: .default)
    }
    private var options: [ExerciseOption] {
        exercise.options.sorted { $0.sortOrder < $1.sortOrder }
    }
    private var isCorrect: Bool {
        options.first { $0.id == selectedID }?.isCorrect ?? false
    }
    private var canReplay: Bool {
        meta.allowReplay && replays < meta.maxReplays
    }

    var body: some View {
        ExerciseScaffold(
            prompt: exercise.prompt,
            content: {
                VStack(spacing: MLSpacing.lg) {
                    audioButton
                        .frame(maxWidth: .infinity)

                    VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                        ForEach(options) { option in
                            AnswerButton(
                                text: option.text,
                                isSelected: selectedID == option.id,
                                correctness: correctness(for: option),
                            ) {
                                if phase == .answering { selectedID = option.id }
                            }
                            .disabled(phase == .checked)
                        }
                    }
                }
            },
            footer: ExerciseFooter(
                phase: phase,
                canCheck: selectedID != nil,
                isCorrect: isCorrect,
                explanation: exercise.explanationES ?? exercise.explanation,
                onCheck: { withAnimation(MLMotion.smooth) { phase = .checked } },
                onContinue: {
                    onComplete(ExerciseResult(isCorrect: isCorrect, xpEarned: isCorrect ? exercise.xpReward : 0, explanation: exercise.explanation))
                },
            ),
        )
    }

    /// Big round speaker button — the focal point of a listening exercise.
    private var audioButton: some View {
        Button {
            play()
        } label: {
            ZStack {
                Circle()
                    .fill(canReplay ? AnyShapeStyle(MLGradient.brand) : AnyShapeStyle(Color.mlSurfaceElevated))
                    .frame(width: 96, height: 96)
                    .mlShadow(.card)
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(canReplay ? Color.mlOnAccent : Color.mlTextTertiary)
                    .symbolEffect(.bounce, value: playCount)
            }
        }
        .buttonStyle(MLPressableButtonStyle(scale: 0.92))
        .disabled(!canReplay)
        .accessibilityLabel(canReplay ? "Reproducir audio" : "Sin reproducciones restantes")
    }

    private func play() {
        guard let urlString = exercise.promptAudioURL, let url = URL(string: urlString) else { return }
        MLHaptic.tap()
        replays += 1
        playCount += 1
        Task { try? await dependencies.audioService.play(url: url) }
    }

    private func correctness(for option: ExerciseOption) -> Bool? {
        guard phase == .checked else { return nil }
        if option.isCorrect { return true }
        return option.id == selectedID ? false : nil
    }
}
