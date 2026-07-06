import Foundation
import Supabase

// Supabase-backed learning progress. completeLesson upserts the progress row
// (which fires the streak trigger) and updates aggregate stats. Per-attempt XP
// verification moves server-side in Phase 3.
struct SupabaseProgressRepository: ProgressRepositoryProtocol {
    let client: SupabaseClient

    private func currentUserID() async throws -> UUID {
        try await client.auth.session.user.id
    }

    func getUserProgress(courseID: UUID) async throws -> CourseProgress {
        let uid = try await currentUserID()
        let rows: [ProgressRow] = try await client
            .from("user_progress").select()
            .eq("user_id", value: uid)
            .eq("entity_type", value: "lesson")
            .eq("status", value: "completed")
            .execute().value
        let xp = rows.reduce(0) { $0 + $1.xp_earned }
        return CourseProgress(courseID: courseID, completedLessons: rows.count, totalLessons: 0, xpEarned: xp)
    }

    func submitExerciseAttempt(_ attempt: ExerciseAttempt) async throws -> ExerciseResult {
        let uid = try await currentUserID()
        let row = ExerciseAttemptInsert(
            user_id: uid,
            exercise_id: attempt.exerciseID,
            lesson_id: attempt.lessonID,
            user_answer: attempt.userAnswer,
            is_correct: attempt.isCorrect,
            time_spent_ms: attempt.timeSpentMs,
            hearts_lost: attempt.isCorrect ? 0 : 1,
        )
        try await client.from("exercise_attempts").insert(row).execute()
        return ExerciseResult(isCorrect: attempt.isCorrect, xpEarned: 0, explanation: nil)
    }

    func completeLesson(lessonID: UUID, score: Double, perfect: Bool,
                        timeMinutes: Int, exerciseCount: Int) async throws {
        let uid = try await currentUserID()

        // The server derives authoritative XP from the published lesson row and
        // updates counters + quest progress atomically. Read it back for the
        // XP actually awarded so the progress row is consistent.
        let stats: UserStatsRow = try await client
            .rpc("record_lesson_completion", params: LessonCompletionParams(
                p_lesson_id: lessonID.uuidString,
                p_score: score,
                p_perfect: perfect,
                p_time_minutes: timeMinutes,
                p_exercise_count: exerciseCount,
            ))
            .single().execute().value
        _ = stats

        // Upsert the lesson progress row (fires the streak trigger). XP mirrors
        // the lesson's reward for local display; the RPC is the source of truth.
        let progress = ProgressUpsert(
            user_id: uid, entity_type: "lesson", entity_id: lessonID,
            status: "completed", score: score, xp_earned: 0,
            completed_at: ISO8601DateFormatter().string(from: Date()),
        )
        try await client.from("user_progress")
            .upsert(progress, onConflict: "user_id,entity_type,entity_id")
            .execute()
    }

    func getCompletedLessons(moduleID: UUID) async throws -> Set<UUID> {
        let uid = try await currentUserID()
        let rows: [ProgressRow] = try await client
            .from("user_progress").select()
            .eq("user_id", value: uid)
            .eq("entity_type", value: "lesson")
            .eq("status", value: "completed")
            .execute().value
        return Set(rows.map { $0.entity_id })
    }

    func syncProgress() async throws {
        // TODO(phase-2): push queued PendingSyncAction rows, then pull latest.
    }
}

// MARK: - Row DTOs

private struct ProgressRow: Decodable {
    let entity_id: UUID
    let xp_earned: Int
}

private struct LessonCompletionParams: Encodable {
    let p_lesson_id: String
    let p_score: Double
    let p_perfect: Bool
    let p_time_minutes: Int
    let p_exercise_count: Int
}

// Minimal projection of the user_stats row returned by record_lesson_completion.
private struct UserStatsRow: Decodable {
    let total_xp: Int
    let lessons_completed: Int
}

private struct ExerciseAttemptInsert: Encodable {
    let user_id: UUID
    let exercise_id: UUID
    let lesson_id: UUID
    let user_answer: String?
    let is_correct: Bool
    let time_spent_ms: Int
    let hearts_lost: Int
}

private struct ProgressUpsert: Encodable {
    let user_id: UUID
    let entity_type: String
    let entity_id: UUID
    let status: String
    let score: Double
    let xp_earned: Int
    let completed_at: String
}
