import SwiftUI

// User profile + stats (CLAUDE-ios.md § Profile & Stats).
//
// Redesign: identity hero (avatar with gradient ring, name, level), a 2×2
// stat grid, and a grouped navigation card with tinted icon squares.
struct ProfileView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: ProfileViewModel?
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("Perfil")
        }
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(
                    gamification: dependencies.gamificationRepository,
                    profiles: dependencies.profileRepository,
                    flashcardRepo: dependencies.flashcardRepository,
                )
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            ScrollView {
                VStack(spacing: MLSpacing.md) {
                    header(viewModel)
                    statGrid(viewModel)
                    linksCard
                    MLButton(title: "Cerrar sesión", style: .outline) {
                        Task {
                            try? await dependencies.authService.signOut()
                            onSignOut()
                        }
                    }
                    .padding(.top, MLSpacing.sm)
                }
                .padding(MLSpacing.md)
                .padding(.bottom, MLSpacing.xl)
            }
            .refreshable { await viewModel.load() }
        } else {
            MLSkeletonList(rows: 4, rowHeight: 100)
        }
    }

    // MARK: Identity

    private func header(_ vm: ProfileViewModel) -> some View {
        let name = vm.profile?.displayName.isEmpty == false ? vm.profile!.displayName : "Estudiante"
        return MLCard(padding: MLSpacing.lg) {
            HStack(spacing: MLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(MLGradient.hero)
                        .frame(width: 72, height: 72)
                    Text(initials(from: name))
                        .font(MLFont.title2)
                        .foregroundStyle(Color.mlOnAccent)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: MLSpacing.xs) {
                    Text(name)
                        .font(MLFont.title2)
                        .foregroundStyle(Color.mlTextPrimary)
                        .lineLimit(1)
                    HStack(spacing: MLSpacing.sm) {
                        Text("Nivel \(vm.stats.level)")
                            .font(MLFont.caption)
                            .foregroundStyle(Color.mlPrimary)
                            .padding(.horizontal, MLSpacing.sm)
                            .padding(.vertical, MLSpacing.xs)
                            .background(Color.mlPrimary.opacity(0.12), in: Capsule())
                        MLXPBadge(xp: vm.stats.totalXP)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name). Nivel \(vm.stats.level), \(vm.stats.totalXP) puntos de experiencia")
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap(\.first)
        return letters.isEmpty ? "🩺" : String(letters).uppercased()
    }

    // MARK: Stats

    private func statGrid(_ vm: ProfileViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                  spacing: MLSpacing.sm + MLSpacing.xs) {
            stat("Racha", "\(vm.stats.currentStreak) días", .mlStreak, "flame.fill")
            stat("Lecciones", "\(vm.stats.lessonsCompleted)", .mlEmerald, "checkmark.seal.fill")
            stat("Palabras", "\(vm.flashcards.learned)", .mlCyan, "text.book.closed.fill")
            stat("Dominadas", "\(vm.flashcards.mastered)", .mlXP, "star.fill")
        }
    }

    private func stat(_ title: String, _ value: String, _ tint: Color, _ icon: String) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: MLRadius.sm, style: .continuous)
                        .fill(tint.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(tint)
                }
                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    Text(value)
                        .font(MLFont.headline)
                        .foregroundStyle(Color.mlTextPrimary)
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                    Text(title)
                        .font(MLFont.caption)
                        .foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }

    // MARK: Navigation links

    private var linksCard: some View {
        VStack(spacing: 0) {
            if !dependencies.subscriptionService.isPremium {
                navRow("MediLingo Premium", icon: "crown.fill", tint: .mlGold) { PaywallView() }
                divider
            }
            navRow("Logros", icon: "trophy.fill", tint: .mlXP) { AchievementsView() }
            divider
            navRow("Vocabulario", icon: "text.book.closed.fill", tint: .mlCyan) { VocabularyView() }
            divider
            navRow("Práctica con IA", icon: "bubble.left.and.bubble.right.fill", tint: .mlPrimary) { AIConversationView() }
            divider
            navRow("Tienda", icon: "bag.fill", tint: .mlGems) { ShopView() }
            divider
            navRow("Invita y gana", icon: "gift.fill", tint: .mlEmerald) { ReferralView() }
        }
        .mlCardStyle()
    }

    private var divider: some View {
        Divider().padding(.leading, 68)
    }

    private func navRow<Destination: View>(_ title: String, icon: String, tint: Color,
                                           @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: MLRadius.sm, style: .continuous)
                        .fill(tint.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(MLFont.bodyMedium)
                    .foregroundStyle(Color.mlTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.mlTextTertiary)
            }
            .padding(MLSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(MLPressableButtonStyle(scale: 0.98))
        .accessibilityLabel(title)
    }
}
