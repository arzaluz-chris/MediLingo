import SwiftUI

// Spaced-repetition flashcard review (CLAUDE-ios.md § Flashcards).
struct FlashcardReviewView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: FlashcardReviewViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mlBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("Repaso")
        }
        .task {
            if viewModel == nil {
                viewModel = FlashcardReviewViewModel(flashcards: dependencies.flashcardRepository, gamification: dependencies.gamificationRepository)
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            if viewModel.isLoading {
                MLLoadingView(message: "Cargando tarjetas…")
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.cards.isEmpty {
                MLEmptyState(systemImage: "checkmark.circle", title: "¡Todo al día!",
                             subtitle: "No tienes tarjetas pendientes por ahora.")
            } else if viewModel.isDone {
                summary(reviewed: viewModel.reviewedCount)
            } else if let card = viewModel.current {
                session(card: card, viewModel: viewModel)
            }
        } else {
            MLLoadingView()
        }
    }

    private func session(card: FlashcardItem, viewModel: FlashcardReviewViewModel) -> some View {
        VStack(spacing: MLSpacing.lg) {
            MLProgressBar(progress: viewModel.progress, tint: .mlSecondary)
                .padding(.horizontal, MLSpacing.md)

            Spacer()
            cardView(card, revealed: viewModel.revealed)
                .onTapGesture { withAnimation(.spring) { viewModel.revealed.toggle() } }
            Spacer()

            if viewModel.revealed {
                qualityButtons(viewModel)
            } else {
                MLButton(title: "Mostrar respuesta") {
                    withAnimation(.spring) { viewModel.revealed = true }
                }
                .padding(.horizontal, MLSpacing.md)
            }
        }
        .padding(.vertical, MLSpacing.md)
    }

    private func cardView(_ card: FlashcardItem, revealed: Bool) -> some View {
        VStack(spacing: MLSpacing.md) {
            if revealed {
                Text(card.translationES).font(MLFont.title(28)).foregroundStyle(Color.mlTextPrimary)
                Text(card.definitionEN).font(MLFont.body()).foregroundStyle(Color.mlTextSecondary).multilineTextAlignment(.center)
                if let example = card.exampleEN {
                    Text(example).font(MLFont.caption()).foregroundStyle(Color.mlTextTertiary).italic()
                }
            } else {
                Text(card.word).font(MLFont.title(32)).foregroundStyle(Color.mlTextPrimary)
                if let phonetic = card.phonetic {
                    Text(phonetic).font(MLFont.mono()).foregroundStyle(Color.mlTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .padding(MLSpacing.lg)
        .background(Color.mlSurface)
        .clipShape(RoundedRectangle(cornerRadius: MLRadius.lg))
        .padding(.horizontal, MLSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Toca para voltear")
    }

    private func qualityButtons(_ viewModel: FlashcardReviewViewModel) -> some View {
        HStack(spacing: MLSpacing.sm) {
            qualityButton("Otra vez", .again, .mlError, viewModel)
            qualityButton("Difícil", .hard, .mlWarning, viewModel)
            qualityButton("Bien", .good, .mlSecondary, viewModel)
            qualityButton("Fácil", .easy, .mlSuccess, viewModel)
        }
        .padding(.horizontal, MLSpacing.md)
    }

    private func qualityButton(_ label: String, _ rating: FlashcardReviewViewModel.Rating, _ color: Color, _ viewModel: FlashcardReviewViewModel) -> some View {
        Button { viewModel.rate(rating) } label: {
            Text(label)
                .font(MLFont.caption(14))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
        }
        .accessibilityLabel(label)
    }

    private func summary(reviewed: Int) -> some View {
        MLEmptyState(systemImage: "star.circle.fill", title: "¡Sesión completada!",
                     subtitle: "Repasaste \(reviewed) tarjetas.")
    }
}
