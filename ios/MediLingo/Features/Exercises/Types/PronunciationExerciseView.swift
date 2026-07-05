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
                    Text(exercise.prompt).font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
                    Text(word).font(MLFont.title(34)).foregroundStyle(Color.mlTextPrimary)
                    if let phonetic = meta.phonetic {
                        Text(phonetic).font(MLFont.mono(16)).foregroundStyle(Color.mlTextSecondary)
                    }
                    micButton
                    if phase == .result { resultCard }
                }
                .padding(MLSpacing.lg)
            }
            footer
        }
    }

    private var micButton: some View {
        Button {
            Task { await toggleRecording() }
        } label: {
            Image(systemName: phase == .recording ? "stop.circle.fill" : "mic.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(phase == .recording ? Color.mlError : Color.mlPrimary)
        }
        .disabled(phase == .evaluating)
        .accessibilityLabel(phase == .recording ? "Detener grabación" : "Grabar pronunciación")
    }

    private var resultCard: some View {
        MLCard {
            VStack(spacing: MLSpacing.sm) {
                Text("\(Int(score))%")
                    .font(MLFont.title(28))
                    .foregroundStyle(isCorrect ? Color.mlSuccess : Color.mlWarning)
                if !transcription.isEmpty {
                    Text("Escuché: \"\(transcription)\"").font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
                }
                if !feedback.isEmpty {
                    Text(feedback).font(MLFont.body()).foregroundStyle(Color.mlTextSecondary).multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var footer: some View {
        VStack {
            if phase == .evaluating { MLLoadingView(message: "Evaluando…").frame(height: 60) }
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
    }

    private func toggleRecording() async {
        let speech = dependencies.speechService
        if phase == .recording {
            phase = .evaluating
            let result = try? await speech.stopRecording()
            transcription = result?.transcription ?? ""
            await evaluate(confidence: result?.confidence ?? 0)
        } else {
            guard await speech.requestAuthorization() else { return }
            do {
                try await speech.startRecording()
                phase = .recording
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
        phase = .result
    }
}
