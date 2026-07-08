import SwiftUI

// Multi-step onboarding: role → level → goal → daily goal.
//
// Redesign: each step gets a big rounded title + supporting subtitle, choice
// cards with tinted icon capsules and spring selection, and pushed
// step transitions. The footer CTA floats above the content.
struct OnboardingView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: OnboardingViewModel?
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            if let viewModel {
                VStack(spacing: 0) {
                    topBar(viewModel)
                    ScrollView {
                        stepContent(viewModel)
                            .padding(MLSpacing.md)
                            .padding(.bottom, MLSpacing.xl)
                    }
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

    // MARK: Top bar

    private func topBar(_ vm: OnboardingViewModel) -> some View {
        HStack(spacing: MLSpacing.md) {
            Button {
                withAnimation(MLMotion.smooth) { vm.back() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.mlTextSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Atrás")
            .opacity(vm.step == .role ? 0 : 1)
            .disabled(vm.step == .role)

            MLProgressBar(progress: vm.progress, tint: .mlPrimary, height: 12)
                .padding(.trailing, MLSpacing.md)
        }
        .padding(.horizontal, MLSpacing.sm)
        .padding(.top, MLSpacing.sm)
    }

    // MARK: Steps

    @ViewBuilder
    private func stepContent(_ vm: OnboardingViewModel) -> some View {
        Group {
            switch vm.step {
            case .role:
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    header("¿Cuál es tu profesión?",
                           subtitle: "Personalizaremos tu contenido médico.")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                              spacing: MLSpacing.sm + MLSpacing.xs) {
                        ForEach(HealthcareRole.allCases) { role in
                            choiceTile(role.label, icon: role.icon, selected: vm.role == role) {
                                vm.role = role
                            }
                        }
                    }
                }
            case .level:
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    header("¿Cuál es tu nivel de inglés?",
                           subtitle: "Sé honesto: así el reto será el adecuado.")
                    VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                        ForEach(EnglishLevel.allCases) { level in
                            choiceRow(level.label, subtitle: level.subtitle,
                                      icon: levelIcon(level), selected: vm.level == level) {
                                vm.level = level
                            }
                        }
                    }
                }
            case .goal:
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    header("¿Cuál es tu objetivo principal?",
                           subtitle: "Priorizaremos las lecciones que te acerquen a él.")
                    VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                        ForEach(LearningGoal.allCases) { goal in
                            choiceRow(goal.label, subtitle: nil,
                                      icon: goalIcon(goal), selected: vm.goal == goal) {
                                vm.goal = goal
                            }
                        }
                    }
                }
            case .dailyGoal:
                VStack(alignment: .leading, spacing: MLSpacing.md) {
                    header("¿Cuánto quieres practicar al día?",
                           subtitle: "Puedes cambiarlo cuando quieras.")
                    VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                        ForEach(DailyGoal.allCases) { dg in
                            choiceRow(dg.label, subtitle: dg.minutes,
                                      icon: dailyGoalIcon(dg), selected: vm.dailyGoal == dg) {
                                vm.dailyGoal = dg
                            }
                        }
                    }
                }
            }
        }
        .id(vm.step)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity),
        ))
        .animation(MLMotion.smooth, value: vm.step)
    }

    private func header(_ text: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: MLSpacing.xs) {
            Text(text)
                .font(MLFont.title)
                .foregroundStyle(Color.mlTextPrimary)
            Text(subtitle)
                .font(MLFont.subheadline)
                .foregroundStyle(Color.mlTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, MLSpacing.sm)
    }

    // MARK: Footer

    private func footer(_ vm: OnboardingViewModel) -> some View {
        VStack(spacing: MLSpacing.sm) {
            if let error = vm.errorMessage {
                Text(error)
                    .font(MLFont.caption)
                    .foregroundStyle(Color.mlError)
            }
            MLButton(
                title: vm.isLastStep ? "¡Empezar!" : "Continuar",
                isLoading: vm.isSaving,
                isEnabled: vm.canProceed,
            ) {
                if vm.isLastStep {
                    Task { if await vm.finish() { onComplete() } }
                } else {
                    withAnimation(MLMotion.smooth) { vm.next() }
                }
            }
        }
        .padding(MLSpacing.md)
        .background(.bar)
    }

    // MARK: Choice components

    private func choiceTile(_ label: String, icon: String, selected: Bool,
                            action: @escaping () -> Void) -> some View {
        Button {
            MLHaptic.selection()
            withAnimation(MLMotion.snappy) { action() }
        } label: {
            VStack(spacing: MLSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(selected ? AnyShapeStyle(MLGradient.brand) : AnyShapeStyle(Color.mlPrimary.opacity(0.1)))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(selected ? Color.mlOnAccent : Color.mlPrimary)
                }
                Text(label)
                    .font(MLFont.subheadline.weight(.semibold))
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 116)
            .padding(MLSpacing.sm)
            .background(selectionBackground(selected))
        }
        .buttonStyle(MLPressableButtonStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }

    private func choiceRow(_ label: String, subtitle: String?, icon: String,
                           selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            MLHaptic.selection()
            withAnimation(MLMotion.snappy) { action() }
        } label: {
            HStack(spacing: MLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(selected ? AnyShapeStyle(MLGradient.brand) : AnyShapeStyle(Color.mlPrimary.opacity(0.1)))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(selected ? Color.mlOnAccent : Color.mlPrimary)
                }
                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    Text(label)
                        .font(MLFont.headline)
                        .foregroundStyle(Color.mlTextPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(MLFont.footnote)
                            .foregroundStyle(Color.mlTextSecondary)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? Color.mlPrimary : Color.mlTextTertiary.opacity(0.5))
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(MLSpacing.md)
            .background(selectionBackground(selected))
        }
        .buttonStyle(MLPressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(subtitle == nil ? label : "\(label). \(subtitle ?? "")")
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }

    private func selectionBackground(_ selected: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: MLRadius.lg, style: .continuous)
        return shape
            .fill(selected ? Color.mlPrimary.opacity(0.08) : Color.mlSurface)
            .overlay(shape.strokeBorder(selected ? Color.mlPrimary : Color.mlCardStroke,
                                        lineWidth: selected ? 2 : 1))
            .shadow(color: MLShadow.soft.color, radius: MLShadow.soft.radius, y: MLShadow.soft.y)
    }

    // MARK: Option icons

    private func levelIcon(_ level: EnglishLevel) -> String {
        switch level {
        case .beginner: "leaf.fill"
        case .intermediate: "figure.walk"
        case .advanced: "figure.run"
        }
    }

    private func goalIcon(_ goal: LearningGoal) -> String {
        switch goal {
        case .enarm: "doc.text.magnifyingglass"
        case .research: "book.and.wrench"
        case .patientCare: "heart.text.square.fill"
        case .remoteWork: "laptopcomputer"
        case .travelMedicine: "airplane"
        case .usmle: "graduationcap.fill"
        case .general: "sparkles"
        }
    }

    private func dailyGoalIcon(_ goal: DailyGoal) -> String {
        switch goal {
        case .casual: "cup.and.saucer.fill"
        case .regular: "clock.fill"
        case .serious: "flame.fill"
        case .intense: "bolt.fill"
        }
    }
}
