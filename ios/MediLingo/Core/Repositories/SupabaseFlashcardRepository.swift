import Foundation
import Supabase

// Supabase-backed spaced repetition. Due cards come from vocabulary_mastery;
// reviews run the SM-2 engine locally, then persist mastery + a review log.
struct SupabaseFlashcardRepository: FlashcardRepositoryProtocol {
    let client: SupabaseClient

    private func currentUserID() async throws -> UUID {
        try await client.auth.session.user.id
    }

    func getDueFlashcards(limit: Int) async throws -> [FlashcardItem] {
        let uid = try await currentUserID()
        let now = ISO8601DateFormatter().string(from: Date())

        // Cards already in rotation and due for review.
        let due: [MasteryRow] = try await client
            .from("vocabulary_mastery")
            .select("vocabulary_id, mastery_level, vocabulary(id, word, phonetic, translation_es, definition_en, example_en, pronunciation_url)")
            .eq("user_id", value: uid)
            .lte("next_review_at", value: now)
            .order("next_review_at")
            .limit(limit)
            .execute().value
        var items = due.compactMap { $0.toItem() }

        // Top up with brand-new published words the user hasn't seen yet (≤5).
        if items.count < limit {
            let seen: [SeenRow] = try await client
                .from("vocabulary_mastery").select("vocabulary_id").eq("user_id", value: uid)
                .execute().value
            let seenIDs = Set(seen.map { $0.vocabulary_id })
            let fresh: [VocabRow] = try await client
                .from("vocabulary").select("id, word, phonetic, translation_es, definition_en, example_en, pronunciation_url")
                .eq("is_published", value: true)
                .limit(limit)
                .execute().value
            for row in fresh where !seenIDs.contains(row.id) && items.count < limit {
                items.append(row.toItem(masteryLevel: 0))
            }
        }
        return items
    }

    func submitReview(vocabularyID: UUID, quality: Int) async throws {
        let uid = try await currentUserID()

        // Load current mastery (defaults for a new card).
        let existing: [MasteryStateRow] = try await client
            .from("vocabulary_mastery")
            .select("ease_factor, interval_days, repetitions, correct_count, incorrect_count")
            .eq("user_id", value: uid).eq("vocabulary_id", value: vocabularyID).limit(1)
            .execute().value
        let state = existing.first ?? MasteryStateRow(ease_factor: 2.5, interval_days: 0, repetitions: 0, correct_count: 0, incorrect_count: 0)

        let result = SpacedRepetitionEngine.calculateReview(
            quality: quality,
            repetitions: state.repetitions,
            previousInterval: state.interval_days,
            easeFactor: state.ease_factor,
        )
        let next = Calendar.current.date(byAdding: .day, value: result.newInterval, to: Date()) ?? Date()

        let upsert = MasteryUpsert(
            user_id: uid, vocabulary_id: vocabularyID,
            mastery_level: result.newMasteryLevel, ease_factor: result.newEaseFactor,
            interval_days: result.newInterval, repetitions: result.newRepetitions,
            correct_count: state.correct_count + (quality >= 3 ? 1 : 0),
            incorrect_count: state.incorrect_count + (quality >= 3 ? 0 : 1),
            last_reviewed_at: ISO8601DateFormatter().string(from: Date()),
            next_review_at: ISO8601DateFormatter().string(from: next),
        )
        try await client.from("vocabulary_mastery")
            .upsert(upsert, onConflict: "user_id,vocabulary_id").execute()

        // Log the review for analytics / SM-2 history.
        let log = ReviewLog(
            user_id: uid, vocabulary_id: vocabularyID, quality: quality,
            previous_interval: state.interval_days, new_interval: result.newInterval,
            previous_ease: state.ease_factor, new_ease: result.newEaseFactor,
        )
        try await client.from("flashcard_reviews").insert(log).execute()
    }

    func getStats() async throws -> FlashcardStats {
        let uid = try await currentUserID()
        let now = ISO8601DateFormatter().string(from: Date())
        async let dueCount = client.from("vocabulary_mastery").select("vocabulary_id", head: true, count: .exact)
            .eq("user_id", value: uid).lte("next_review_at", value: now).execute().count
        async let learnedCount = client.from("vocabulary_mastery").select("vocabulary_id", head: true, count: .exact)
            .eq("user_id", value: uid).gte("mastery_level", value: 1).execute().count
        async let masteredCount = client.from("vocabulary_mastery").select("vocabulary_id", head: true, count: .exact)
            .eq("user_id", value: uid).gte("mastery_level", value: 5).execute().count
        return FlashcardStats(
            due: (try? await dueCount) ?? 0,
            learned: (try? await learnedCount) ?? 0,
            mastered: (try? await masteredCount) ?? 0,
        )
    }

    func addWord(vocabularyID: UUID) async throws {
        let uid = try await currentUserID()
        let upsert = MasteryUpsert(
            user_id: uid, vocabulary_id: vocabularyID, mastery_level: 0, ease_factor: 2.5,
            interval_days: 0, repetitions: 0, correct_count: 0, incorrect_count: 0,
            last_reviewed_at: nil, next_review_at: ISO8601DateFormatter().string(from: Date()),
        )
        try await client.from("vocabulary_mastery").upsert(upsert, onConflict: "user_id,vocabulary_id").execute()
    }
}

// MARK: - Row DTOs

private struct VocabRow: Decodable {
    let id: UUID
    let word: String
    let phonetic: String?
    let translation_es: String
    let definition_en: String
    let example_en: String?
    let pronunciation_url: String?
    func toItem(masteryLevel: Int) -> FlashcardItem {
        FlashcardItem(id: id, vocabularyID: id, word: word, translationES: translation_es,
                      definitionEN: definition_en, exampleEN: example_en, phonetic: phonetic,
                      pronunciationURL: pronunciation_url, masteryLevel: masteryLevel)
    }
}

private struct MasteryRow: Decodable {
    let vocabulary_id: UUID
    let mastery_level: Int
    let vocabulary: VocabRow?
    func toItem() -> FlashcardItem? {
        guard let v = vocabulary else { return nil }
        return v.toItem(masteryLevel: mastery_level)
    }
}

private struct SeenRow: Decodable { let vocabulary_id: UUID }

private struct MasteryStateRow: Decodable {
    let ease_factor: Double
    let interval_days: Int
    let repetitions: Int
    let correct_count: Int
    let incorrect_count: Int
}

private struct MasteryUpsert: Encodable {
    let user_id: UUID
    let vocabulary_id: UUID
    let mastery_level: Int
    let ease_factor: Double
    let interval_days: Int
    let repetitions: Int
    let correct_count: Int
    let incorrect_count: Int
    let last_reviewed_at: String?
    let next_review_at: String
}

private struct ReviewLog: Encodable {
    let user_id: UUID
    let vocabulary_id: UUID
    let quality: Int
    let previous_interval: Int
    let new_interval: Int
    let previous_ease: Double
    let new_ease: Double
}
