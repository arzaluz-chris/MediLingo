import Foundation
import Supabase

// Supabase-backed content reads. Row DTOs use snake_case property names so they
// decode directly from PostgREST responses; `toDomain()` maps to the app models.
// Every successful remote read is written through to the SwiftData cache; when
// the network fails, reads fall back to the cache (offline-first, CLAUDE-ios.md).
struct SupabaseContentRepository: ContentRepositoryProtocol {
    let client: SupabaseClient
    let cache: ContentCacheStore

    init(client: SupabaseClient, cache: ContentCacheStore? = nil) {
        self.client = client
        self.cache = cache ?? ContentCacheStore(modelContainer: AppModelContainer.shared)
    }

    func fetchCourses() async throws -> [Course] {
        do {
            let rows: [CourseRow] = try await client
                .from("courses")
                .select()
                .eq("is_published", value: true)
                .order("sort_order")
                .execute().value
            let courses = rows.map { $0.toDomain() }
            await cache.saveCourses(courses)
            return courses
        } catch {
            let cached = await cache.loadCourses()
            guard !cached.isEmpty else { throw error }
            return cached
        }
    }

    func fetchModules(courseID: UUID) async throws -> [Module] {
        do {
            let rows: [ModuleRow] = try await client
                .from("modules")
                .select()
                .eq("course_id", value: courseID)
                .eq("is_published", value: true)
                .order("sort_order")
                .execute().value
            let modules = rows.map { $0.toDomain() }
            await cache.saveModules(modules)
            return modules
        } catch {
            let cached = await cache.loadModules(courseID: courseID)
            guard !cached.isEmpty else { throw error }
            return cached
        }
    }

    func fetchLessons(moduleID: UUID) async throws -> [Lesson] {
        do {
            let rows: [LessonRow] = try await client
                .from("lessons")
                .select()
                .eq("module_id", value: moduleID)
                .eq("is_published", value: true)
                .order("sort_order")
                .execute().value
            let lessons = rows.map { $0.toDomain() }
            await cache.saveLessons(lessons)
            return lessons
        } catch {
            let cached = await cache.loadLessons(moduleID: moduleID)
            guard !cached.isEmpty else { throw error }
            return cached
        }
    }

    func fetchExercises(lessonID: UUID) async throws -> [Exercise] {
        do {
            let exercises = try await fetchExercisesRemote(lessonID: lessonID)
            await cache.saveExercises(exercises)
            return exercises
        } catch {
            let cached = await cache.loadExercises(lessonID: lessonID)
            guard !cached.isEmpty else { throw error }
            return cached
        }
    }

    private func fetchExercisesRemote(lessonID: UUID) async throws -> [Exercise] {
        let rows: [ExerciseRow] = try await client
            .from("exercises")
            .select()
            .eq("lesson_id", value: lessonID)
            .eq("is_published", value: true)
            .order("sort_order")
            .execute().value

        guard !rows.isEmpty else { return [] }

        // Fetch all options for these exercises in one round-trip, then group.
        let optionRows: [ExerciseOptionRow] = try await client
            .from("exercise_options")
            .select()
            .in("exercise_id", values: rows.map { $0.id })
            .order("sort_order")
            .execute().value
        let optionsByExercise = Dictionary(grouping: optionRows) { $0.exercise_id }

        return rows.map { row in
            row.toDomain(options: (optionsByExercise[row.id] ?? []).map { $0.toDomain() })
        }
    }

    func fetchVocabulary(lessonID: UUID) async throws -> [VocabularyWord] {
        // lesson_vocabulary joins lessons ↔ vocabulary; fetch the linked ids then the words.
        let links: [LessonVocabRow] = try await client
            .from("lesson_vocabulary")
            .select()
            .eq("lesson_id", value: lessonID)
            .order("sort_order")
            .execute().value
        guard !links.isEmpty else { return [] }

        let rows: [VocabularyRow] = try await client
            .from("vocabulary")
            .select()
            .in("id", values: links.map { $0.vocabulary_id })
            .execute().value
        return rows.map { $0.toDomain() }
    }

    func searchVocabulary(query: String) async throws -> [VocabularyWord] {
        let rows: [VocabularyRow] = try await client
            .from("vocabulary")
            .select()
            .eq("is_published", value: true)
            .ilike("word", pattern: "%\(query)%")
            .limit(30)
            .execute().value
        return rows.map { $0.toDomain() }
    }

    func downloadLessonForOffline(lessonID: UUID) async throws {
        let exercises = try await fetchExercisesRemote(lessonID: lessonID)
        await cache.saveExercises(exercises, markDownloaded: true)
    }

    /// Refresh the whole published content tree into the cache (courses →
    /// modules → lessons). Exercises download lazily per lesson.
    func syncContent() async throws {
        let courses = try await fetchCourses()
        for course in courses {
            let modules = try await fetchModules(courseID: course.id)
            for module in modules {
                _ = try await fetchLessons(moduleID: module.id)
            }
        }
    }
}

// MARK: - Row DTOs

private struct CourseRow: Decodable {
    let id: UUID
    let slug: String
    let title: String
    let short_desc: String
    let color_hex: String
    let difficulty: String
    let is_premium: Bool
    let sort_order: Int

    func toDomain() -> Course {
        Course(id: id, slug: slug, title: title, shortDesc: short_desc, colorHex: color_hex,
               difficulty: Difficulty(rawValue: difficulty) ?? .beginner,
               isPremium: is_premium, sortOrder: sort_order)
    }
}

private struct ModuleRow: Decodable {
    let id: UUID
    let course_id: UUID
    let title: String
    let sort_order: Int
    func toDomain() -> Module { Module(id: id, courseID: course_id, title: title, sortOrder: sort_order) }
}

private struct LessonRow: Decodable {
    let id: UUID
    let module_id: UUID
    let title: String
    let lesson_type: String
    let difficulty: String
    let estimated_minutes: Int
    let xp_reward: Int
    let sort_order: Int
    let is_premium: Bool
    func toDomain() -> Lesson {
        Lesson(id: id, moduleID: module_id, title: title, lessonType: lesson_type,
               difficulty: Difficulty(rawValue: difficulty) ?? .beginner,
               estimatedMinutes: estimated_minutes, xpReward: xp_reward,
               sortOrder: sort_order, isPremium: is_premium)
    }
}

private struct ExerciseRow: Decodable {
    let id: UUID
    let lesson_id: UUID
    let exercise_type: String
    let prompt: String
    let prompt_audio_url: String?
    let prompt_image_url: String?
    let correct_answer: String?
    let explanation: String?
    let explanation_es: String?
    let hint: String?
    let difficulty: String
    let xp_reward: Int
    let sort_order: Int
    let metadata: AnyJSON

    func toDomain(options: [ExerciseOption]) -> Exercise {
        let json = (try? JSONEncoder().encode(metadata)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        return Exercise(
            id: id, lessonID: lesson_id,
            type: ExerciseType(rawValue: exercise_type) ?? .multipleChoice,
            prompt: prompt, promptAudioURL: prompt_audio_url, promptImageURL: prompt_image_url,
            correctAnswer: correct_answer, explanation: explanation, explanationES: explanation_es,
            hint: hint, difficulty: Difficulty(rawValue: difficulty) ?? .beginner,
            xpReward: xp_reward, sortOrder: sort_order, metadataJSON: json, options: options,
        )
    }
}

private struct ExerciseOptionRow: Decodable {
    let id: UUID
    let exercise_id: UUID
    let option_text: String
    let is_correct: Bool
    let sort_order: Int
    let option_audio_url: String?
    let option_image_url: String?
    let match_pair_id: String?
    func toDomain() -> ExerciseOption {
        ExerciseOption(id: id, text: option_text, isCorrect: is_correct, sortOrder: sort_order,
                       audioURL: option_audio_url, imageURL: option_image_url, matchPairID: match_pair_id)
    }
}

private struct LessonVocabRow: Decodable {
    let vocabulary_id: UUID
}

private struct VocabularyRow: Decodable {
    let id: UUID
    let word: String
    let phonetic: String?
    let translation_es: String
    let definition_en: String
    let example_en: String
    let pronunciation_url: String?
    func toDomain() -> VocabularyWord {
        VocabularyWord(id: id, word: word, phonetic: phonetic, translationES: translation_es,
                       definitionEN: definition_en, exampleEN: example_en, pronunciationURL: pronunciation_url)
    }
}
