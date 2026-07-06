import Foundation
import SwiftData

// SwiftData-backed offline cache for content (CLAUDE-ios.md § Offline).
// Write-through from SupabaseContentRepository on every successful remote read;
// read path when the network is unavailable. Content is public data — user
// progress stays server-side and is NOT cached here.
@ModelActor
actor ContentCacheStore {

    // MARK: - Save (write-through)

    func saveCourses(_ courses: [Course]) {
        for course in courses {
            let id = course.id
            let existing = try? modelContext.fetch(
                FetchDescriptor<CachedCourse>(predicate: #Predicate { $0.id == id })
            ).first
            if let cached = existing {
                cached.slug = course.slug
                cached.title = course.title
                cached.shortDesc = course.shortDesc
                cached.colorHex = course.colorHex
                cached.difficulty = course.difficulty.rawValue
                cached.isPremium = course.isPremium
                cached.sortOrder = course.sortOrder
                cached.lastSyncedAt = .now
            } else {
                modelContext.insert(CachedCourse(
                    id: course.id, slug: course.slug, title: course.title,
                    shortDesc: course.shortDesc, iconURL: nil, colorHex: course.colorHex,
                    difficulty: course.difficulty.rawValue, category: "general",
                    isPremium: course.isPremium, sortOrder: course.sortOrder,
                    lastSyncedAt: .now,
                ))
            }
        }
        try? modelContext.save()
    }

    func saveModules(_ modules: [Module]) {
        for module in modules {
            let id = module.id
            let existing = try? modelContext.fetch(
                FetchDescriptor<CachedModule>(predicate: #Predicate { $0.id == id })
            ).first
            if let cached = existing {
                cached.title = module.title
                cached.sortOrder = module.sortOrder
            } else {
                modelContext.insert(CachedModule(
                    id: module.id, courseID: module.courseID,
                    title: module.title, sortOrder: module.sortOrder,
                ))
            }
        }
        try? modelContext.save()
    }

    func saveLessons(_ lessons: [Lesson]) {
        for lesson in lessons {
            let id = lesson.id
            let existing = try? modelContext.fetch(
                FetchDescriptor<CachedLesson>(predicate: #Predicate { $0.id == id })
            ).first
            if let cached = existing {
                cached.title = lesson.title
                cached.lessonType = lesson.lessonType
                cached.difficulty = lesson.difficulty.rawValue
                cached.estimatedMinutes = lesson.estimatedMinutes
                cached.xpReward = lesson.xpReward
                cached.sortOrder = lesson.sortOrder
                cached.isPremium = lesson.isPremium
            } else {
                modelContext.insert(CachedLesson(
                    id: lesson.id, moduleID: lesson.moduleID, title: lesson.title,
                    lessonType: lesson.lessonType, difficulty: lesson.difficulty.rawValue,
                    estimatedMinutes: lesson.estimatedMinutes, xpReward: lesson.xpReward,
                    sortOrder: lesson.sortOrder, isPremium: lesson.isPremium,
                ))
            }
        }
        try? modelContext.save()
    }

    func saveExercises(_ exercises: [Exercise], markDownloaded: Bool = false) {
        for exercise in exercises {
            let id = exercise.id
            // Replace wholesale: options may have changed.
            if let existing = try? modelContext.fetch(
                FetchDescriptor<CachedExercise>(predicate: #Predicate { $0.id == id })
            ).first {
                modelContext.delete(existing)
            }
            let options = exercise.options.map {
                CachedExerciseOption(
                    id: $0.id, exerciseID: exercise.id, optionText: $0.text,
                    isCorrect: $0.isCorrect, sortOrder: $0.sortOrder,
                    optionAudioURL: $0.audioURL, optionImageURL: $0.imageURL,
                )
            }
            modelContext.insert(CachedExercise(
                id: exercise.id, lessonID: exercise.lessonID,
                exerciseType: exercise.type.rawValue, prompt: exercise.prompt,
                correctAnswer: exercise.correctAnswer, explanation: exercise.explanation,
                explanationES: exercise.explanationES, hint: exercise.hint,
                difficulty: exercise.difficulty.rawValue, xpReward: exercise.xpReward,
                sortOrder: exercise.sortOrder, metadataJSON: exercise.metadataJSON,
                promptAudioURL: exercise.promptAudioURL, promptImageURL: exercise.promptImageURL,
                options: options,
            ))
        }
        if markDownloaded, let lessonID = exercises.first?.lessonID {
            if let lesson = try? modelContext.fetch(
                FetchDescriptor<CachedLesson>(predicate: #Predicate { $0.id == lessonID })
            ).first {
                lesson.isDownloaded = true
            }
        }
        try? modelContext.save()
    }

    // MARK: - Load (offline fallback)

    func loadCourses() -> [Course] {
        let cached = (try? modelContext.fetch(
            FetchDescriptor<CachedCourse>(sortBy: [SortDescriptor(\.sortOrder)])
        )) ?? []
        return cached.map {
            Course(id: $0.id, slug: $0.slug, title: $0.title, shortDesc: $0.shortDesc,
                   colorHex: $0.colorHex, difficulty: Difficulty(rawValue: $0.difficulty) ?? .beginner,
                   isPremium: $0.isPremium, sortOrder: $0.sortOrder)
        }
    }

    func loadModules(courseID: UUID) -> [Module] {
        let cached = (try? modelContext.fetch(
            FetchDescriptor<CachedModule>(
                predicate: #Predicate { $0.courseID == courseID },
                sortBy: [SortDescriptor(\.sortOrder)],
            )
        )) ?? []
        return cached.map { Module(id: $0.id, courseID: $0.courseID, title: $0.title, sortOrder: $0.sortOrder) }
    }

    func loadLessons(moduleID: UUID) -> [Lesson] {
        let cached = (try? modelContext.fetch(
            FetchDescriptor<CachedLesson>(
                predicate: #Predicate { $0.moduleID == moduleID },
                sortBy: [SortDescriptor(\.sortOrder)],
            )
        )) ?? []
        return cached.map {
            Lesson(id: $0.id, moduleID: $0.moduleID, title: $0.title, lessonType: $0.lessonType,
                   difficulty: Difficulty(rawValue: $0.difficulty) ?? .beginner,
                   estimatedMinutes: $0.estimatedMinutes, xpReward: $0.xpReward,
                   sortOrder: $0.sortOrder, isPremium: $0.isPremium)
        }
    }

    func loadExercises(lessonID: UUID) -> [Exercise] {
        let cached = (try? modelContext.fetch(
            FetchDescriptor<CachedExercise>(
                predicate: #Predicate { $0.lessonID == lessonID },
                sortBy: [SortDescriptor(\.sortOrder)],
            )
        )) ?? []
        return cached.map { exercise in
            let options = exercise.options
                .sorted { $0.sortOrder < $1.sortOrder }
                .map {
                    ExerciseOption(id: $0.id, text: $0.optionText, isCorrect: $0.isCorrect,
                                   sortOrder: $0.sortOrder, audioURL: $0.optionAudioURL,
                                   imageURL: $0.optionImageURL, matchPairID: nil)
                }
            return Exercise(
                id: exercise.id, lessonID: exercise.lessonID,
                type: ExerciseType(rawValue: exercise.exerciseType) ?? .multipleChoice,
                prompt: exercise.prompt, promptAudioURL: exercise.promptAudioURL,
                promptImageURL: exercise.promptImageURL, correctAnswer: exercise.correctAnswer,
                explanation: exercise.explanation, explanationES: exercise.explanationES,
                hint: exercise.hint, difficulty: Difficulty(rawValue: exercise.difficulty) ?? .beginner,
                xpReward: exercise.xpReward, sortOrder: exercise.sortOrder,
                metadataJSON: exercise.metadataJSON, options: options,
            )
        }
    }
}
