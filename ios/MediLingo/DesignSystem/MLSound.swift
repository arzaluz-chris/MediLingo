import AVFoundation
import Foundation

// Sound-effect catalog (CLAUDE-ios.md § Sound Effects).
enum MLSound {
    case correct
    case incorrect
    case xpGain
    case levelUp
    case achievementUnlocked
    case streakMaintained
    case lessonComplete
    case heartLost
    case buttonTap
    case countdown

    var filename: String {
        switch self {
        case .correct: "correct.wav"
        case .incorrect: "incorrect.wav"
        case .xpGain: "xp_gain.wav"
        case .levelUp: "level_up.wav"
        case .achievementUnlocked: "achievement.wav"
        case .streakMaintained: "streak.wav"
        case .lessonComplete: "lesson_complete.wav"
        case .heartLost: "heart_lost.wav"
        case .buttonTap: "button_tap.wav"
        case .countdown: "countdown.wav"
        }
    }
}

// Plays short sound effects from Resources/Sounds. Degrades silently when the
// asset is missing (so the app is fully functional before audio ships) and
// respects the user's silent switch via the ambient audio session.
@MainActor
enum MLSoundPlayer {
    private static var players: [String: AVAudioPlayer] = [:]
    private static var sessionConfigured = false
    static var isEnabled = true

    static func play(_ sound: MLSound) {
        guard isEnabled else { return }
        guard let player = player(for: sound) else { return }
        configureSessionIfNeeded()
        player.currentTime = 0
        player.play()
    }

    private static func player(for sound: MLSound) -> AVAudioPlayer? {
        if let cached = players[sound.filename] { return cached }
        let name = (sound.filename as NSString).deletingPathExtension
        let ext = (sound.filename as NSString).pathExtension
        // Look in a Sounds/ subdirectory first, then the bundle root.
        let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Sounds")
            ?? Bundle.main.url(forResource: name, withExtension: ext)
        guard let url, let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.prepareToPlay()
        players[sound.filename] = player
        return player
    }

    private static func configureSessionIfNeeded() {
        guard !sessionConfigured else { return }
        sessionConfigured = true
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
