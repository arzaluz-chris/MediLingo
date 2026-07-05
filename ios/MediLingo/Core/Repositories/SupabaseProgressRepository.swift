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

    func completeLesson(lessonID: UUID, score: Double, xpEarned: Int) async throws {
        let uid = try await currentUserID()

        // Upsert the lesson progress row (fires the streak trigger).
        let progress = ProgressUpsert(
            user_id: uid, entity_type: "lesson", entity_id: lessonID,
            status: "completed", score: score, xp_earned: xpEarned,
            completed_at: ISO8601DateFormatter().string(from: Date()),
        )
        try await client.from("user_progress")
            .upsert(progress, onConflict: "user_id,entity_type,entity_id")
            .execute()

        // Update aggregate stats: XP + weekly XP + lessons completed.
        let stats: [UserStatsMini] = try await client
            .from("user_stats").select("total_xp,weekly_xp,lessons_completed")
            .eq("user_id", value: uid).limit(1)
            .execute().value
        let current = stats.first ?? UserStatsMini(total_xp: 0, weekly_xp: 0, lessons_completed: 0)
        try await client.from("user_stats").update([
            "total_xp": current.total_xp + xpEarned,
            "weekly_xp": current.weekly_xp + xpEarned,
            "lessons_completed": current.lessons_completed + 1,
        ]).eq("user_id", value: uid).execute()
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

private struct UserStatsMini: Decodable {
    let total_xp: Int
    let weekly_xp: Int
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
