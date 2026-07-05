import Foundation
import Speech

// On-device speech recognition wrapper (CLAUDE-ios.md § Pronunciation Engine).
// Phase 0 wires authorization + availability; full audio-engine transcription
// lands in Phase 1.
@Observable
final class SpeechService: SpeechServiceProtocol {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var isRecording: Bool = false

    var isAvailable: Bool {
        recognizer?.isAvailable ?? false
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startRecording() async throws {
        guard let recognizer, recognizer.isAvailable else {
            throw AppError.speechNotAvailable
        }
        isRecording = true
        // TODO(phase-1): install audio-engine tap + SFSpeechAudioBufferRecognitionRequest.
    }

    func stopRecording() async throws -> SpeechResult {
        isRecording = false
        // TODO(phase-1): return the accumulated transcription + confidence.
        return SpeechResult(transcription: "", confidence: 0)
    }
}
