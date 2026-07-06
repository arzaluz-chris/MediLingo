import SwiftUI

// Weekly league leaderboard (CLAUDE-ios.md § Social). Top 10 promote, bottom
// tier demotes — mirrored from the server's rollover_leagues rotation.
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
                MLLoadingView(message: "Cargando la liga…")
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.members.isEmpty {
                MLEmptyState(systemImage: "person.3", title: "Aún no hay liga",
                             subtitle: "Completa lecciones para entrar en la liga semanal.")
            } else {
                leaderboard(viewModel)
            }
        } else {
            MLLoadingView()
        }
    }

    private func leaderboard(_ viewModel: SocialViewModel) -> some View {
        ScrollView {
            VStack(spacing: MLSpacing.sm) {
                Text(viewModel.tierDisplayName)
                    .font(MLFont.heading(20))
                    .foregroundStyle(Color.mlGold)
                    .padding(.top, MLSpacing.md)
                ForEach(Array(viewModel.members.enumerated()), id: \.element.id) { index, member in
                    row(rank: index + 1, member: member, promotion: index < 10)
                }
            }
            .padding(MLSpacing.md)
        }
    }

    private func row(rank: Int, member: LeagueMember, promotion: Bool) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                Text("\(rank)")
                    .font(MLFont.heading(17))
                    .foregroundStyle(promotion ? Color.mlSuccess : Color.mlTextSecondary)
                    .frame(width: 32)
                Text(member.displayName.isEmpty ? "Estudiante" : member.displayName)
                    .font(MLFont.body())
                    .foregroundStyle(Color.mlTextPrimary)
                Spacer(minLength: 0)
                Text("\(member.weeklyXP) XP")
                    .font(MLFont.caption())
                    .foregroundStyle(Color.mlXP)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Puesto \(rank): \(member.displayName), \(member.weeklyXP) XP")
    }
}
