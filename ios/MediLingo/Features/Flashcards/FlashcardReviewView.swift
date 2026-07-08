import SwiftUI

// Spaced-repetition flashcard review (CLAUDE-ios.md § Flashcards).
//
// Redesign: a 3D-flipping card with a peeking stack behind it, animated
// progress, and four SM-2 quality buttons with clear color semantics.
// Ends with a celebratory session summary.
struct FlashcardReviewView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                MLSkeletonList(rows: 3, rowHeight: 120)
            } else if let error = viewModel.errorMessage {
                MLErrorView(message: error) { Task { await viewModel.load() } }
            } else if viewModel.cards.isEmpty {
                MLEmptyState(systemImage: "checkmark.circle.fill", title: "¡Todo al día!",
                             subtitle: "No tienes tarjetas pendientes por ahora. Aprende nuevas palabras en tus lecciones.",
                             tint: .mlEmerald)
            } else if viewModel.isDone {
                summary(reviewed: viewModel.reviewedCount)
            } else if let card = viewModel.current {
                session(card: card, viewModel: viewModel)
            }
        } else {
            MLSkeletonList(rows: 3, rowHeight: 120)
        }
    }

    // MARK: Session

    private func session(card: FlashcardItem, viewModel: FlashcardReviewViewModel) -> some View {
        VStack(spacing: MLSpacing.lg) {
            HStack(spacing: MLSpacing.md) {
                MLProgressBar(progress: viewModel.progress, tint: .mlCyan)
                Text("\(viewModel.index + 1)/\(viewModel.cards.count)")
                    .font(MLFont.caption)
                    .foregroundStyle(Color.mlTextSecondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, MLSpacing.md)

            Spacer()

            cardStack(card, viewModel: viewModel)
                .onTapGesture { flip(viewModel) }

            Spacer()

            if viewModel.revealed {
                qualityButtons(viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                MLButton(title: "Mostrar respuesta", icon: "arrow.uturn.left") {
                    flip(viewModel)
                }
                .padding(.horizontal, MLSpacing.md)
            }
        }
        .padding(.vertical, MLSpacing.md)
        .animation(MLMotion.smooth, value: viewModel.revealed)
    }

    private func flip(_ viewModel: FlashcardReviewViewModel) {
        MLHaptic.medium()
        withAnimation(reduceMotion ? nil : MLMotion.smooth) {
            viewModel.revealed.toggle()
        }
    }

    /// Current card with two "upcoming" cards peeking behind it.
    private func cardStack(_ card: FlashcardItem, viewModel: FlashcardReviewViewModel) -> some View {
        ZStack {
            let upcoming = min(2, viewModel.cards.count - viewModel.index - 1)
            ForEach((0..<upcoming).reversed(), id: \.self) { depth in
                RoundedRectangle(cornerRadius: MLRadius.xl, style: .continuous)
                    .fill(Color.mlSurface.opacity(0.7))
                    .frame(height: 300)
                    .scaleEffect(1 - CGFloat(depth + 1) * 0.045)
                    .offset(y: CGFloat(depth + 1) * 14)
                    .accessibilityHidden(true)
            }
            flipCard(card, revealed: viewModel.revealed)
        }
        .padding(.horizontal, MLSpacing.md)
    }

    private func flipCard(_ card: FlashcardItem, revealed: Bool) -> some View {
        ZStack {
            cardFace(front: true, card: card)
                .opacity(revealed ? 0 : 1)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : (revealed ? 180 : 0)), axis: (x: 0, y: 1, z: 0))
            cardFace(front: false, card: card)
                .opacity(revealed ? 1 : 0)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : (revealed ? 0 : -180)), axis: (x: 0, y: 1, z: 0))
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Toca para voltear")
    }

    @ViewBuilder
    private func cardFace(front: Bool, card: FlashcardItem) -> some View {
        let shape = RoundedRectangle(cornerRadius: MLRadius.xl, style: .continuous)
        VStack(spacing: MLSpacing.md) {
            if front {
                Text(card.word)
                    .font(MLFont.hero)
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                if let phonetic = card.phonetic {
                    Text(phonetic)
                        .font(MLFont.mono)
                        .foregroundStyle(Color.mlTextSecondary)
                }
                Label("Toca para voltear", systemImage: "hand.tap.fill")
                    .font(MLFont.caption)
                    .foregroundStyle(Color.mlTextTertiary)
                    .padding(.top, MLSpacing.sm)
            } else {
                Text(card.translationES)
                    .font(MLFont.title)
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.center)
                Text(card.definitionEN)
                    .font(MLFont.body)
                    .foregroundStyle(Color.mlTextSecondary)
                    .multilineTextAlignment(.center)
                if let example = card.exampleEN {
                    Text(example)
                        .font(MLFont.subheadline)
                        .italic()
                        .foregroundStyle(Color.mlTextTertiary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(MLSpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.mlSurface)
        .clipShape(shape)
        .overlay(
            shape.strokeBorder(
                front ? Color.mlCardStroke : Color.mlCyan.opacity(0.35),
                lineWidth: front ? 1 : 1.5,
            )
        )
        .mlShadow(.card)
    }

    // MARK: Quality buttons (SM-2)

    private func qualityButtons(_ viewModel: FlashcardReviewViewModel) -> some View {
        HStack(spacing: MLSpacing.sm) {
            qualityButton("Otra vez", icon: "arrow.counterclockwise", rating: .again, color: .mlError, viewModel)
            qualityButton("Difícil", icon: "tortoise.fill", rating: .hard, color: .mlWarning, viewModel)
            qualityButton("Bien", icon: "hand.thumbsup.fill", rating: .good, color: .mlCyan, viewModel)
            qualityButton("Fácil", icon: "hare.fill", rating: .easy, color: .mlEmerald, viewModel)
        }
        .padding(.horizontal, MLSpacing.md)
    }

    private func qualityButton(_ label: String, icon: String,
                               rating: FlashcardReviewViewModel.Rating, color: Color,
                               _ viewModel: FlashcardReviewViewModel) -> some View {
        Button {
            withAnimation(MLMotion.smooth) { viewModel.rate(rating) }
        } label: {
            VStack(spacing: MLSpacing.xs) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                Text(label)
                    .font(MLFont.caption)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
                    .strokeBorder(color.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(MLPressableButtonStyle())
        .accessibilityLabel(label)
    }

    // MARK: Summary

    private func summary(reviewed: Int) -> some View {
        ZStack {
            VStack(spacing: MLSpacing.lg) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.mlCyan.opacity(0.12))
                        .frame(width: 128, height: 128)
                    Image(systemName: "sparkles")
                        .font(.system(size: 52))
                        .foregroundStyle(Color.mlCyan)
                }
                .accessibilityHidden(true)

                VStack(spacing: MLSpacing.xs) {
                    Text("¡Sesión completada!")
                        .font(MLFont.largeTitle)
                        .foregroundStyle(Color.mlTextPrimary)
                    Text("Repasaste \(reviewed) \(reviewed == 1 ? "tarjeta" : "tarjetas"). Tu memoria a largo plazo lo agradece.")
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .padding(MLSpacing.lg)
            MLConfettiView(duration: 2)
        }
        .onAppear { MLHaptic.levelUp() }
    }
}
