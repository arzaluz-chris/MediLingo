import Foundation

// Typed decoders for the per-type `metadata` JSON (canonical shapes live in
// /shared/schemas/*.schema.json). Each Exercise carries `metadataJSON`; a view
// decodes the struct it needs. All fields optional-tolerant so partial/legacy
// rows never crash the engine.

enum ExerciseMetadata {
    /// Decode a typed metadata struct from an exercise's raw JSON string.
    /// Returns a default-constructed value when the JSON is empty or malformed.
    static func decode<T: Decodable>(_ type: T.Type, from json: String, fallback: T) -> T {
        guard let data = json.data(using: .utf8), !data.isEmpty else { return fallback }
        return (try? JSONDecoder().decode(T.self, from: data)) ?? fallback
    }
}

struct MultipleChoiceMeta: Decodable {
    var shuffleOptions: Bool = true
    var showAudioForOptions: Bool = false
    enum CodingKeys: String, CodingKey {
        case shuffleOptions = "shuffle_options"
        case showAudioForOptions = "show_audio_for_options"
    }
    static let `default` = MultipleChoiceMeta()
}

struct ImageSelectionMeta: Decodable {
    var columns: Int = 2
    var shuffleOptions: Bool = true
    enum CodingKeys: String, CodingKey {
        case columns
        case shuffleOptions = "shuffle_options"
    }
    static let `default` = ImageSelectionMeta()
}

struct ListeningMeta: Decodable {
    var allowReplay: Bool = true
    var maxReplays: Int = 3
    var playbackSpeeds: [Double] = [0.75, 1.0, 1.25]
    var transcript: String?
    enum CodingKeys: String, CodingKey {
        case allowReplay = "allow_replay"
        case maxReplays = "max_replays"
        case playbackSpeeds = "playback_speeds"
        case transcript
    }
    static let `default` = ListeningMeta()
}

struct FillInBlankMeta: Decodable {
    var acceptableAnswers: [String] = []
    var caseSensitive: Bool = false
    var wordBank: [String]?
    enum CodingKeys: String, CodingKey {
        case acceptableAnswers = "acceptable_answers"
        case caseSensitive = "case_sensitive"
        case wordBank = "word_bank"
    }
    static let `default` = FillInBlankMeta()
}

struct TranslationMeta: Decodable {
    var sourceLanguage: String = "es"
    var targetLanguage: String = "en"
    var sourceText: String = ""
    var acceptableTranslations: [String] = []
    var keyTerms: [String]?
    var useAIEvaluation: Bool = false
    enum CodingKeys: String, CodingKey {
        case sourceLanguage = "source_language"
        case targetLanguage = "target_language"
        case sourceText = "source_text"
        case acceptableTranslations = "acceptable_translations"
        case keyTerms = "key_terms"
        case useAIEvaluation = "use_ai_evaluation"
    }
    static let `default` = TranslationMeta()
}

struct SentenceOrderingMeta: Decodable {
    var words: [String] = []
    var extraWords: [String] = []
    var showPunctuation: Bool = true
    enum CodingKeys: String, CodingKey {
        case words
        case extraWords = "extra_words"
        case showPunctuation = "show_punctuation"
    }
    static let `default` = SentenceOrderingMeta()
}

struct FlashcardMeta: Decodable {
    struct Front: Decodable { var text: String = ""; var subtext: String? }
    struct Back: Decodable {
        var text: String = ""
        var translation: String?
        var explanation: String?
        var example: String?
    }
    var front = Front()
    var back = Back()
    var showPronunciation: Bool = true
    enum CodingKeys: String, CodingKey {
        case front, back
        case showPronunciation = "show_pronunciation"
    }
    static let `default` = FlashcardMeta()
}

struct TypingMeta: Decodable {
    var acceptableAnswers: [String] = []
    var caseSensitive: Bool = false
    var maxLength: Int = 100
    var placeholder: String = "Type your answer..."
    enum CodingKeys: String, CodingKey {
        case acceptableAnswers = "acceptable_answers"
        case caseSensitive = "case_sensitive"
        case maxLength = "max_length"
        case placeholder
    }
    static let `default` = TypingMeta()
}

struct PronunciationMeta: Decodable {
    var word: String = ""
    var phonetic: String?
    var minimumScore: Int = 60
    var syllables: [String]?
    var definitionES: String?
    enum CodingKeys: String, CodingKey {
        case word, phonetic, syllables
        case minimumScore = "minimum_score"
        case definitionES = "definition_es"
    }
    static let `default` = PronunciationMeta()
}
