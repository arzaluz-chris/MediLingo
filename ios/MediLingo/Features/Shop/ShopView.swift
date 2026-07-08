import SwiftUI

// Gem shop (CLAUDE-ios.md § Shop).
//
// Redesign: gem balance hero, item cards with category icons in tinted
// squares, and capsule buy buttons with price + gem glyph.
struct ShopView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: ShopViewModel?

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Tienda")
        .task {
            if viewModel == nil {
                viewModel = ShopViewModel(gamification: dependencies.gamificationRepository)
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            ScrollView {
                VStack(spacing: MLSpacing.md) {
                    gemBalance(viewModel.gems)

                    if let message = viewModel.message {
                        Label(message, systemImage: "info.circle.fill")
                            .font(MLFont.caption)
                            .foregroundStyle(Color.mlCyan)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if viewModel.isLoading {
                        MLSkeletonList(rows: 3, rowHeight: 88)
                    } else {
                        ForEach(viewModel.items) { item in itemRow(item, viewModel: viewModel) }
                    }
                }
                .padding(MLSpacing.md)
                .padding(.bottom, MLSpacing.xl)
            }
        } else {
            MLSkeletonList(rows: 4, rowHeight: 88)
        }
    }

    private func gemBalance(_ gems: Int) -> some View {
        MLHeroCard(gradient: MLGradient.premium) {
            HStack(spacing: MLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.mlOnAccent.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Image(systemName: "diamond.fill")
                        .font(.title2)
                        .foregroundStyle(Color.mlOnAccent)
                }
                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    Text("Tus gemas")
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlOnAccent.opacity(0.85))
                    Text("\(gems)")
                        .font(MLFont.statLarge)
                        .foregroundStyle(Color.mlOnAccent)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tienes \(gems) gemas")
    }

    private func itemRow(_ item: ShopItem, viewModel: ShopViewModel) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: MLRadius.sm, style: .continuous)
                        .fill(Color.mlGems.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: itemIcon(item.category))
                        .font(.title3)
                        .foregroundStyle(Color.mlGems)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    Text(item.title)
                        .font(MLFont.headline)
                        .foregroundStyle(Color.mlTextPrimary)
                    Text(item.description)
                        .font(MLFont.footnote)
                        .foregroundStyle(Color.mlTextSecondary)
                    if item.owned > 0 {
                        Text("En posesión: \(item.owned)")
                            .font(MLFont.caption2)
                            .foregroundStyle(Color.mlTextTertiary)
                    }
                }
                Spacer(minLength: 0)

                Button {
                    MLHaptic.medium()
                    Task { await viewModel.buy(item) }
                } label: {
                    HStack(spacing: MLSpacing.xs) {
                        Image(systemName: "diamond.fill")
                            .font(.caption)
                        Text("\(item.priceGems)")
                            .monospacedDigit()
                    }
                    .font(MLFont.subheadline.weight(.bold))
                    .foregroundStyle(Color.mlOnAccent)
                    .padding(.horizontal, MLSpacing.md)
                    .padding(.vertical, MLSpacing.sm + MLSpacing.xs)
                    .background(item.canBuyMore ? Color.mlGems : Color.mlTextTertiary, in: Capsule())
                }
                .buttonStyle(MLPressableButtonStyle())
                .disabled(!item.canBuyMore)
                .accessibilityLabel("Comprar \(item.title) por \(item.priceGems) gemas")
            }
        }
    }

    private func itemIcon(_ category: String) -> String {
        switch category {
        case let c where c.contains("heart"): "heart.fill"
        case let c where c.contains("streak") || c.contains("freeze"): "snowflake"
        case let c where c.contains("boost") || c.contains("xp"): "bolt.fill"
        default: "sparkles"
        }
    }
}
