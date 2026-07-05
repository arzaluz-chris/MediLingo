import SwiftUI

// Drives the multi-step onboarding (CLAUDE-ios.md § Authentication & Onboarding).
@MainActor
@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable { case role, level, goal, dailyGoal }

    var step: Step = .role
    var role: HealthcareRole?
    var level: EnglishLevel?
    var goal: LearningGoal?
    var dailyGoal: DailyGoal?
    var isSaving = false
    var errorMessage: String?

    private let profile: ProfileRepositoryProtocol

    init(profile: ProfileRepositoryProtocol) {
        self.profile = profile
    }

    var progress: Double {
        Double(step.rawValue + 1) / Double(Step.allCases.count)
    }

    var canProceed: Bool {
        switch step {
        case .role: role != nil
        case .level: level != nil
        case .goal: goal != nil
        case .dailyGoal: dailyGoal != nil
        }
    }

    var isLastStep: Bool { step == .dailyGoal }

    func back() {
        if let prev = Step(rawValue: step.rawValue - 1) { step = prev }
    }

    func next() {
        if let nextStep = Step(rawValue: step.rawValue + 1) { step = nextStep }
    }

    /// Persist all choices. Returns true on success.
    func finish() async -> Bool {
        guard let role, let level, let goal, let dailyGoal else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await profile.saveOnboarding(
                role: role.rawValue, englishLevel: level.rawValue,
                goal: goal.rawValue, dailyGoalXP: dailyGoal.rawValue,
            )
            return true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }
}
