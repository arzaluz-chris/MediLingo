import Foundation
import Speech
import AVFoundation

// On-device speech recognition (CLAUDE-ios.md § Pronunciation Engine). Captures
// mic audio, streams it to the Speech framework, and returns the best
// transcription + average confidence when stopped.
@Observable
final class SpeechService: SpeechServiceProtocol {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    private var latestTranscription = ""
    private var latestConfidence: Double = 0
    var isRecording: Bool = false

    var isAvailable: Bool { recognizer?.isAvailable ?? false }

    func requestAuthorization() async -> Bool {
        let speech = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0 == .authorized) }
        }
        let mic = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { continuation.resume(returning: $0) }
        }
        return speech && mic
    }

    func startRecording() async throws {
        guard let recognizer, recognizer.isAvailable else { throw AppError.speechNotAvailable }
        latestTranscription = ""
        latestConfidence = 0

        let newRequest = SFSpeechAudioBufferRecognitionRequest()
        newRequest.shouldReportPartialResults = true
        request = newRequest

        try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        task = recognizer.recognitionTask(with: newRequest) { [weak self] result, _ in
            guard let self, let result else { return }
            self.latestTranscription = result.bestTranscription.formattedString
            let segments = result.bestTranscription.segments
            self.latestConfidence = segments.isEmpty
                ? 0
                : Double(segments.map { $0.confidence }.reduce(0, +)) / Double(segments.count)
        }
    }

    func stopRecording() async throws -> SpeechResult {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.finish()
        request = nil
        task = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        // Give the recognizer a moment to emit its final result.
        try? await Task.sleep(for: .milliseconds(300))
        return SpeechResult(transcription: latestTranscription, confidence: latestConfidence)
    }
}
