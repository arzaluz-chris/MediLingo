import SwiftUI

// Multi-step onboarding: role → level → goal → daily goal.
struct OnboardingView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: OnboardingViewModel?
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            if let viewModel {
                VStack(spacing: MLSpacing.lg) {
                    topBar(viewModel)
                    ScrollView { stepContent(viewModel).padding(MLSpacing.md) }
                    footer(viewModel)
                }
            } else {
                MLLoadingView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = OnboardingViewModel(profile: dependencies.profileRepository)
            }
        }
    }

    private func topBar(_ vm: OnboardingViewModel) -> some View {
        HStack(spacing: MLSpacing.md) {
            if vm.step != .role {
                Button { vm.back() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(Color.mlTextSecondary)
                }
                .accessibilityLabel("Atrás")
            }
            MLProgressBar(progress: vm.progress, tint: .mlPrimary)
        }
        .padding(.horizontal, MLSpacing.md)
        .padding(.top, MLSpacing.md)
    }

    @ViewBuilder
    private func stepContent(_ vm: OnboardingViewModel) -> some View {
        @Bindable var vm = vm
        switch vm.step {
        case .role:
            title("¿Cuál es tu profesión?")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MLSpacing.sm) {
                ForEach(HealthcareRole.allCases) { role in
                    choiceTile(role.label, icon: role.icon, selected: vm.role == role) { vm.role = role }
                }
            }
        case .level:
            title("¿Cuál es tu nivel de inglés?")
            VStack(spacing: MLSpacing.sm) {
                ForEach(EnglishLevel.allCases) { level in
                    choiceRow(level.label, subtitle: level.subtitle, selected: vm.level == level) { vm.level = level }
                }
            }
        case .goal:
            title("¿Cuál es tu objetivo principal?")
            VStack(spacing: MLSpacing.sm) {
                ForEach(LearningGoal.allCases) { goal in
                    choiceRow(goal.label, subtitle: nil, selected: vm.goal == goal) { vm.goal = goal }
                }
            }
        case .dailyGoal:
            title("¿Cuánto quieres practicar al día?")
            VStack(spacing: MLSpacing.sm) {
                ForEach(DailyGoal.allCases) { dg in
                    choiceRow(dg.label, subtitle: dg.minutes, selected: vm.dailyGoal == dg) { vm.dailyGoal = dg }
                }
            }
        }
    }

    private func footer(_ vm: OnboardingViewModel) -> some View {
        VStack(spacing: MLSpacing.sm) {
            if let error = vm.errorMessage {
                Text(error).font(MLFont.caption()).foregroundStyle(Color.mlError)
            }
            MLButton(
                title: vm.isLastStep ? "¡Empezar!" : "Continuar",
                isLoading: vm.isSaving,
                isEnabled: vm.canProceed,
            ) {
                if vm.isLastStep {
                    Task { if await vm.finish() { onComplete() } }
                } else {
                    vm.next()
                }
            }
        }
        .padding(MLSpacing.md)
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(MLFont.title(26))
            .foregroundStyle(Color.mlTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, MLSpacing.sm)
    }

    private func choiceTile(_ label: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            MLHaptic.tap(); action()
        } label: {
            VStack(spacing: MLSpacing.sm) {
                Image(systemName: icon).font(.system(size: 28)).foregroundStyle(selected ? Color.mlPrimary : Color.mlTextSecondary)
                Text(label).font(MLFont.body()).foregroundStyle(Color.mlTextPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(selected ? Color.mlPrimary.opacity(0.2) : Color.mlSurface)
            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
            .overlay(RoundedRectangle(cornerRadius: MLRadius.md).strokeBorder(selected ? Color.mlPrimary : .clear, lineWidth: 2))
        }
    }

    private func choiceRow(_ label: String, subtitle: String?, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            MLHaptic.tap(); action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(MLFont.heading(17)).foregroundStyle(Color.mlTextPrimary)
                    if let subtitle {
                        Text(subtitle).font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
                    }
                }
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.mlPrimary) }
            }
            .padding(MLSpacing.md)
            .background(selected ? Color.mlPrimary.opacity(0.15) : Color.mlSurface)
            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
            .overlay(RoundedRectangle(cornerRadius: MLRadius.md).strokeBorder(selected ? Color.mlPrimary : .clear, lineWidth: 2))
        }
    }
}
