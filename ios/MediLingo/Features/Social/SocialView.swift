import SwiftUI

// Weekly league leaderboard (CLAUDE-ios.md § Social). Top 10 promote, bottom
// tier demotes — mirrored from the server's rollover_leagues rotation.
//
// Redesign: league medallion header, medal-colored top 3, and an explicit
// "promotion zone" divider so the weekly stakes are legible at a glance.
struct SocialView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: SocialViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("Liga")
        }
        .task {
            if viewModel == nil {
                viewModel = SocialViewModel(gamification: dependencies.gamificationRepository)
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            if viewModel.isLoading {
                MLSkeletonList(rows: 8, rowHeight: 64)
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.members.isEmpty {
                MLEmptyState(systemImage: "person.3.fill", title: "Aún no hay liga",
                             subtitle: "Completa lecciones esta semana para entrar en la liga y competir con otros profesionales.",
                             tint: .mlGold)
            } else {
                leaderboard(viewModel)
            }
        } else {
            MLSkeletonList(rows: 8, rowHeight: 64)
        }
    }

    private func leaderboard(_ viewModel: SocialViewModel) -> some View {
        ScrollView {
            VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                header(viewModel)

                ForEach(Array(viewModel.members.enumerated()), id: \.element.id) { index, member in
                    row(rank: index + 1, member: member)
                    if index == 9 && viewModel.members.count > 10 {
                        promotionDivider
                    }
                }
            }
            .padding(MLSpacing.md)
            .padding(.bottom, MLSpacing.xl)
        }
        .refreshable { await viewModel.load() }
    }

    private func header(_ viewModel: SocialViewModel) -> some View {
        MLCard(padding: MLSpacing.lg) {
            VStack(spacing: MLSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(MLGradient.streak)
                        .frame(width: 72, height: 72)
                        .mlShadow(.card)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.mlOnAccent)
                }
                .accessibilityHidden(true)

                Text(viewModel.tierDisplayName)
                    .font(MLFont.title2)
                    .foregroundStyle(Color.mlTextPrimary)
                Text("Los 10 primeros suben de liga esta semana")
                    .font(MLFont.footnote)
                    .foregroundStyle(Color.mlTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .combine)
    }

    private var promotionDivider: some View {
        HStack(spacing: MLSpacing.sm) {
            line
            Label("Zona de ascenso", systemImage: "arrow.up")
                .font(MLFont.caption)
                .foregroundStyle(Color.mlEmerald)
                .fixedSize()
            line
        }
        .padding(.vertical, MLSpacing.xs)
        .accessibilityLabel("Fin de la zona de ascenso")
    }

    private var line: some View {
        Rectangle().fill(Color.mlEmerald.opacity(0.35)).frame(height: 1.5)
    }

    private func row(rank: Int, member: LeagueMember) -> some View {
        MLCard(padding: MLSpacing.sm + MLSpacing.xs) {
            HStack(spacing: MLSpacing.md) {
                rankBadge(rank)
                Text(member.displayName.isEmpty ? "Estudiante" : member.displayName)
                    .font(MLFont.bodyMedium)
                    .foregroundStyle(Color.mlTextPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("\(member.weeklyXP) XP")
                    .font(MLFont.subheadline.weight(.bold))
                    .foregroundStyle(Color.mlXP)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Puesto \(rank): \(member.displayName.isEmpty ? "Estudiante" : member.displayName), \(member.weeklyXP) puntos")
    }

    @ViewBuilder
    private func rankBadge(_ rank: Int) -> some View {
        ZStack {
            Circle()
                .fill(rankColor(rank).opacity(rank <= 3 ? 1 : 0.12))
                .frame(width: 36, height: 36)
            if rank <= 3 {
                Image(systemName: "medal.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.mlOnAccent)
            } else {
                Text("\(rank)")
                    .font(MLFont.subheadline.weight(.bold))
                    .foregroundStyle(rank <= 10 ? Color.mlEmerald : Color.mlTextSecondary)
                    .monospacedDigit()
            }
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: .mlGold
        case 2: .mlSilver
        case 3: .mlBronze
        case 4...10: .mlEmerald
        default: .mlTextTertiary
        }
    }
}
