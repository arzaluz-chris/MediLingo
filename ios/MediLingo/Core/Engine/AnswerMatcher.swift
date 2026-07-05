import Foundation

// Normalized free-text answer matching for typing/fill-in/translation exercises.
enum AnswerMatcher {
    /// True when `input` matches any acceptable answer after normalization.
    static func matches(_ input: String, against accepted: [String], caseSensitive: Bool) -> Bool {
        let normalizedInput = normalize(input, caseSensitive: caseSensitive)
        return accepted.contains { normalize($0, caseSensitive: caseSensitive) == normalizedInput }
    }

    /// True when the input contains most key terms (loose translation grading).
    static func containsKeyTerms(_ input: String, keyTerms: [String], threshold: Double = 0.7) -> Bool {
        guard !keyTerms.isEmpty else { return false }
        let haystack = normalize(input, caseSensitive: false)
        let hits = keyTerms.filter { haystack.contains(normalize($0, caseSensitive: false)) }
        return Double(hits.count) / Double(keyTerms.count) >= threshold
    }

    private static func normalize(_ text: String, caseSensitive: Bool) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Collapse internal whitespace and drop trailing punctuation.
        result = result.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
        result = result.trimmingCharacters(in: CharacterSet(charactersIn: ".!?,;:"))
        return caseSensitive ? result : result.lowercased()
    }
}
