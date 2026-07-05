import Foundation
import AVFoundation

// Microphone capture for pronunciation practice (CLAUDE-ios.md § Recording).
// Records 44.1kHz mono AAC .m4a to a temp file (matches audio content spec).
@Observable
final class AudioRecorder {
    private var recorder: AVAudioRecorder?
    private(set) var recordingURL: URL?
    var isRecording: Bool = false

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        let newRecorder = try AVAudioRecorder(url: url, settings: settings)
        guard newRecorder.record() else { throw AppError.audioPlaybackFailed }
        recorder = newRecorder
        recordingURL = url
        isRecording = true
    }

    @discardableResult
    func stopRecording() -> URL? {
        recorder?.stop()
        recorder = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
        return recordingURL
    }
}
