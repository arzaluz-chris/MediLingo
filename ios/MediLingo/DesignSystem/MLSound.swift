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

// Plays short sound effects. Phase 0: no-op until audio assets are added to
// Resources. Wire AVAudioPlayer against `sound.filename` in Phase 1.
enum MLSoundPlayer {
    static func play(_ sound: MLSound) {
        // TODO(phase-1): load Resources/Sounds/<filename> and play.
        _ = sound.filename
    }
}
