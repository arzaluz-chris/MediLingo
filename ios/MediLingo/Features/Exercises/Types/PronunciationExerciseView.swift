import SwiftUI

// Speak the term aloud; on-device STT transcribes it and (when the AI provider
// is configured) Gemini scores it. Falls back to a local match so the exercise
// works without an AI key.
struct PronunciationExerciseView: View {
    @Environment(AppDependencies.self) private var dependencies
    let exercise: Exercise
    let onComplete: (ExerciseResult) -> Void

    enum Phase { case idle, recording, evaluating, result }
    @State private var phase: Phase = .idle
    @State private var transcription = ""
    @State private var score: Double = 0
    @State private var feedback = ""
    @State private var isCorrect = false

    private var meta: PronunciationMeta {
        ExerciseMetadata.decode(PronunciationMeta.self, from: exercise.metadataJSON, fallback: .default)
    }
    private var word: String { meta.word.isEmpty ? (exercise.correctAnswer ?? exercise.prompt) : meta.word }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: MLSpacing.lg) {
                    Text(exercise.prompt)
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)

                    VStack(spacing: MLSpacing.sm) {
                        Text(word)
                            .font(MLFont.hero)
                            .foregroundStyle(Color.mlTextPrimary)
                            .multilineTextAlignment(.center)
                        if let phonetic = meta.phonetic {
                            Text(phonetic)
                                .font(MLFont.mono)
                                .foregroundStyle(Color.mlTextSecondary)
                        }
                    }
                    .padding(MLSpacing.lg)
                    .frame(maxWidth: .infinity)
                    .mlCardStyle(cornerRadius: MLRadius.xl)

                    micButton
                        .padding(.top, MLSpacing.md)

                    Text(stateHint)
                        .font(MLFont.footnote)
                        .foregroundStyle(Color.mlTextTertiary)

                    if phase == .result { resultCard }
                }
                .padding(MLSpacing.lg)
            }
            footer
        }
    }

    private var stateHint: String {
        switch phase {
        case .idle: "Toca el micrófono y pronuncia el término"
        case .recording: "Escuchando… toca para terminar"
        case .evaluating: "Evaluando tu pronunciación…"
        case .result: isCorrect ? "¡Bien dicho!" : "Inténtalo de nuevo en el siguiente repaso"
        }
    }

    private var micButton: some View {
        Button {
            Task { await toggleRecording() }
        } label: {
            ZStack {
                if phase == .recording {
                    PulsingRing(tint: .mlError)
                }
                Circle()
                    .fill(phase == .recording ? AnyShapeStyle(Color.mlError) : AnyShapeStyle(MLGradient.brand))
                    .frame(width: 96, height: 96)
                    .mlShadow(.card)
                Image(systemName: phase == .recording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.mlOnAccent)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .buttonStyle(MLPressableButtonStyle(scale: 0.92))
        .disabled(phase == .evaluating)
        .accessibilityLabel(phase == .recording ? "Detener grabación" : "Grabar pronunciación")
    }

    private var resultCard: some View {
        MLCard {
            VStack(spacing: MLSpacing.sm) {
                MLProgressRing(
                    progress: score / 100,
                    lineWidth: 8,
                    tint: isCorrect ? .mlEmerald : .mlWarning,
                    label: "\(Int(score))%",
                )
                .frame(width: 88, height: 88)

                if !transcription.isEmpty {
                    Text("Escuché: “\(transcription)”")
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)
                        .multilineTextAlignment(.center)
                }
                if !feedback.isEmpty {
                    Text(feedback)
                        .font(MLFont.body)
                        .foregroundStyle(Color.mlTextPrimary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var footer: some View {
        VStack {
            if phase == .evaluating {
                MLLoadingView(message: "Evaluando…").frame(height: 60)
            }
            MLButton(
                title: phase == .result ? "Continuar" : "Saltar",
                style: phase == .result ? .primary : .outline,
            ) {
                onComplete(ExerciseResult(
                    isCorrect: phase == .result ? isCorrect : false,
                    xpEarned: (phase == .result && isCorrect) ? exercise.xpReward : 0,
                    explanation: exercise.explanation,
                ))
            }
        }
        .padding(MLSpacing.md)
        .background(.bar)
    }

    private func toggleRecording() async {
        let speech = dependencies.speechService
        if phase == .recording {
            withAnimation(MLMotion.smooth) { phase = .evaluating }
            let result = try? await speech.stopRecording()
            transcription = result?.transcription ?? ""
            await evaluate(confidence: result?.confidence ?? 0)
        } else {
            guard await speech.requestAuthorization() else { return }
            do {
                MLHaptic.medium()
                try await speech.startRecording()
                withAnimation(MLMotion.smooth) { phase = .recording }
            } catch {
                phase = .idle
            }
        }
    }

    private func evaluate(confidence: Double) async {
        // Prefer AI scoring; fall back to a local match if unavailable.
        do {
            let result = try await dependencies.aiService.evaluatePronunciation(
                word: word, phonetic: meta.phonetic, transcription: transcription, confidence: confidence,
            )
            score = result.overallScore
            feedback = result.feedback
        } catch {
            let matched = transcription.lowercased().contains(word.lowercased())
            score = matched ? max(70, confidence * 100) : 40
            feedback = matched ? "¡Bien! Sigue practicando." : "Intenta pronunciar con más claridad."
        }
        isCorrect = score >= Double(meta.minimumScore)
        if isCorrect { MLHaptic.correct() } else { MLHaptic.incorrect() }
        withAnimation(MLMotion.bouncy) { phase = .result }
    }
}

// Expanding ring around the mic while recording. Static under Reduce Motion.
private struct PulsingRing: View {
    let tint: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    var body: some View {
        Circle()
            .stroke(tint.opacity(0.35), lineWidth: 6)
            .frame(width: 120, height: 120)
            .scaleEffect(reduceMotion ? 1 : (pulsing ? 1.15 : 0.95))
            .opacity(reduceMotion ? 1 : (pulsing ? 0.4 : 1))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
            .accessibilityHidden(true)
    }
}
