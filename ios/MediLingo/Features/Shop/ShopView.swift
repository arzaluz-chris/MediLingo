import SwiftUI

// Gem shop (CLAUDE-ios.md § Shop).
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
                        Text(message).font(MLFont.caption()).foregroundStyle(Color.mlSecondary)
                    }
                    if viewModel.isLoading {
                        MLLoadingView().frame(height: 120)
                    } else {
                        ForEach(viewModel.items) { item in itemRow(item, viewModel: viewModel) }
                    }
                }
                .padding(MLSpacing.md)
            }
        } else {
            MLLoadingView()
        }
    }

    private func gemBalance(_ gems: Int) -> some View {
        MLCard {
            HStack {
                Image(systemName: "diamond.fill").foregroundStyle(Color.mlGems)
                Text("Tus gemas").font(MLFont.body()).foregroundStyle(Color.mlTextPrimary)
                Spacer()
                Text("\(gems)").font(MLFont.heading()).foregroundStyle(Color.mlGems).monospacedDigit()
            }
        }
    }

    private func itemRow(_ item: ShopItem, viewModel: ShopViewModel) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title).font(MLFont.heading(16)).foregroundStyle(Color.mlTextPrimary)
                    Text(item.description).font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
                    if item.owned > 0 {
                        Text("En posesión: \(item.owned)").font(MLFont.caption(11)).foregroundStyle(Color.mlTextTertiary)
                    }
                }
                Spacer(minLength: 0)
                Button {
                    Task { await viewModel.buy(item) }
                } label: {
                    HStack(spacing: MLSpacing.xs) {
                        Image(systemName: "diamond.fill").font(.system(size: 12))
                        Text("\(item.priceGems)").monospacedDigit()
                    }
                    .font(MLFont.caption(14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, MLSpacing.md)
                    .padding(.vertical, MLSpacing.sm)
                    .background(item.canBuyMore ? Color.mlGems : Color.mlTextTertiary)
                    .clipShape(Capsule())
                }
                .disabled(!item.canBuyMore)
                .accessibilityLabel("Comprar \(item.title) por \(item.priceGems) gemas")
            }
        }
    }
}
