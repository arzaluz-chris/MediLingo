import Foundation
import AVFoundation

// AVFoundation audio playback (CLAUDE-ios.md § Audio Pipeline).
@Observable
final class AudioService: NSObject, AudioServiceProtocol {
    private var player: AVAudioPlayer?
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    func play(url: URL) async throws {
        let data: Data
        if url.isFileURL {
            data = try Data(contentsOf: url)
        } else {
            let (downloaded, _) = try await URLSession.shared.data(from: url)
            data = downloaded
        }

        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        let newPlayer = try AVAudioPlayer(data: data)
        newPlayer.enableRate = true
        newPlayer.prepareToPlay()
        newPlayer.play()
        player = newPlayer
        isPlaying = true
        duration = newPlayer.duration
    }

    func playLocal(filename: String) async throws {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw AppError.contentNotFound
        }
        try await play(url: url)
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
    }

    func setPlaybackSpeed(_ speed: Float) {
        player?.enableRate = true
        player?.rate = speed
    }
}
