import SwiftUI

// Premium paywall (CLAUDE-ios.md § Subscription). Loads StoreKit products and
// runs the purchase/restore flow through SubscriptionServiceProtocol.
struct PaywallView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PaywallViewModel?

    private static let benefits: [(icon: String, text: String)] = [
        ("infinity", "Lecciones y corazones ilimitados"),
        ("brain.head.profile", "Conversaciones con IA sin límite"),
        ("arrow.down.circle", "Modo sin conexión"),
        ("chart.line.uptrend.xyaxis", "Estadísticas avanzadas de progreso"),
    ]

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            content
        }
        .task {
            if viewModel == nil {
                viewModel = PaywallViewModel(subscription: dependencies.subscriptionService)
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            ScrollView {
                VStack(spacing: MLSpacing.lg) {
                    header
                    benefitList
                    if viewModel.isLoading {
                        MLLoadingView(message: "Cargando planes…")
                    } else if let error = viewModel.errorMessage {
                        MLErrorView(message: error) { Task { await viewModel.load() } }
                    } else {
                        productButtons(viewModel)
                    }
                    restoreButton(viewModel)
                }
                .padding(MLSpacing.lg)
            }
        } else {
            MLLoadingView()
        }
    }

    private var header: some View {
        VStack(spacing: MLSpacing.sm) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.mlGold)
            Text("MediLingo Premium")
                .font(MLFont.heading(28))
                .foregroundStyle(Color.mlTextPrimary)
            Text("Aprende inglés médico sin límites.")
                .font(MLFont.body())
                .foregroundStyle(Color.mlTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, MLSpacing.lg)
    }

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: MLSpacing.md) {
            ForEach(Self.benefits, id: \.text) { benefit in
                HStack(spacing: MLSpacing.md) {
                    Image(systemName: benefit.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(Color.mlPrimary)
                        .frame(width: 28)
                    Text(benefit.text)
                        .font(MLFont.body())
                        .foregroundStyle(Color.mlTextPrimary)
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(MLSpacing.md)
        .background(Color.mlSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func productButtons(_ viewModel: PaywallViewModel) -> some View {
        VStack(spacing: MLSpacing.sm) {
            if viewModel.products.isEmpty {
                MLEmptyState(systemImage: "cart", title: "Sin planes disponibles",
                             subtitle: "Inténtalo de nuevo más tarde.")
            }
            ForEach(viewModel.products) { product in
                MLButton(title: "\(product.displayName) · \(product.price)", style: .primary) {
                    Task {
                        if await viewModel.purchase(product) { dismiss() }
                    }
                }
                .disabled(viewModel.isPurchasing)
                .accessibilityLabel("Comprar \(product.displayName) por \(product.price)")
            }
        }
    }

    private func restoreButton(_ viewModel: PaywallViewModel) -> some View {
        MLButton(title: "Restaurar compras", style: .outline) {
            Task {
                if await viewModel.restore() { dismiss() }
            }
        }
        .disabled(viewModel.isPurchasing)
    }
}
