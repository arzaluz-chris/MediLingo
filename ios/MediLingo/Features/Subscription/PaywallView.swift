import SwiftUI

// Premium paywall (CLAUDE-ios.md § Subscription). Loads StoreKit products and
// runs the purchase/restore flow through SubscriptionServiceProtocol.
//
// Redesign: gradient crown hero, benefit rows with tinted icon circles,
// selectable pricing cards (annual highlighted as best value) and a single
// prominent CTA — the standard premium-app paywall pattern.
struct PaywallView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PaywallViewModel?
    @State private var selectedProductID: String?

    private static let benefits: [(icon: String, tint: Color, text: String)] = [
        ("infinity", .mlPrimary, "Lecciones y corazones ilimitados"),
        ("brain.head.profile", .mlGems, "Conversaciones con IA sin límite"),
        ("arrow.down.circle.fill", .mlCyan, "Modo sin conexión"),
        ("chart.line.uptrend.xyaxis", .mlEmerald, "Estadísticas avanzadas de progreso"),
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
                    hero
                    benefitList

                    if viewModel.isLoading {
                        MLSkeletonList(rows: 2, rowHeight: 72)
                            .frame(height: 180)
                    } else if let error = viewModel.errorMessage {
                        MLErrorView(message: error) { Task { await viewModel.load() } }
                            .frame(height: 220)
                    } else {
                        productPicker(viewModel)
                        purchaseButton(viewModel)
                    }

                    restoreButton(viewModel)
                }
                .padding(MLSpacing.md)
                .padding(.bottom, MLSpacing.xl)
            }
        } else {
            MLLoadingView()
        }
    }

    // MARK: Hero

    private var hero: some View {
        MLHeroCard(gradient: MLGradient.premium) {
            VStack(spacing: MLSpacing.sm) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.mlOnAccent)
                    .accessibilityHidden(true)
                Text("MediLingo Premium")
                    .font(MLFont.title)
                    .foregroundStyle(Color.mlOnAccent)
                Text("Aprende inglés médico sin límites.")
                    .font(MLFont.subheadline)
                    .foregroundStyle(Color.mlOnAccent.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, MLSpacing.sm)
    }

    // MARK: Benefits

    private var benefitList: some View {
        MLCard {
            VStack(alignment: .leading, spacing: MLSpacing.md) {
                ForEach(Self.benefits, id: \.text) { benefit in
                    HStack(spacing: MLSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(benefit.tint.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: benefit.icon)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(benefit.tint)
                        }
                        Text(benefit.text)
                            .font(MLFont.bodyMedium)
                            .foregroundStyle(Color.mlTextPrimary)
                        Spacer(minLength: 0)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    // MARK: Products

    private func productPicker(_ viewModel: PaywallViewModel) -> some View {
        VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
            if viewModel.products.isEmpty {
                MLEmptyState(systemImage: "cart", title: "Sin planes disponibles",
                             subtitle: "Inténtalo de nuevo más tarde.", tint: .mlGold)
                    .frame(height: 220)
            }
            ForEach(viewModel.products) { product in
                productCard(product, isSelected: selectedID(viewModel) == product.id) {
                    MLHaptic.selection()
                    withAnimation(MLMotion.snappy) { selectedProductID = product.id }
                }
            }
        }
        .onAppear {
            // Preselect the annual plan (best value) when available.
            if selectedProductID == nil {
                selectedProductID = viewModel.products.first(where: { isAnnual($0) })?.id
                    ?? viewModel.products.first?.id
            }
        }
    }

    private func selectedID(_ viewModel: PaywallViewModel) -> String? {
        selectedProductID ?? viewModel.products.first?.id
    }

    private func isAnnual(_ product: SubscriptionProduct) -> Bool {
        product.id.localizedCaseInsensitiveContains("annual")
            || product.displayName.localizedCaseInsensitiveContains("anual")
    }

    private func productCard(_ product: SubscriptionProduct, isSelected: Bool,
                             action: @escaping () -> Void) -> some View {
        let shape = RoundedRectangle(cornerRadius: MLRadius.lg, style: .continuous)
        return Button(action: action) {
            HStack(spacing: MLSpacing.md) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.mlPrimary : Color.mlTextTertiary.opacity(0.5))
                    .contentTransition(.symbolEffect(.replace))

                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    HStack(spacing: MLSpacing.sm) {
                        Text(product.displayName)
                            .font(MLFont.headline)
                            .foregroundStyle(Color.mlTextPrimary)
                        if isAnnual(product) {
                            Text("MEJOR PRECIO")
                                .font(MLFont.caption2)
                                .foregroundStyle(Color.mlOnAccent)
                                .padding(.horizontal, MLSpacing.sm)
                                .padding(.vertical, MLSpacing.xxs)
                                .background(Color.mlEmerald, in: Capsule())
                        }
                    }
                    Text(product.price)
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(MLSpacing.md)
            .background(shape.fill(isSelected ? Color.mlPrimary.opacity(0.08) : Color.mlSurface))
            .overlay(shape.strokeBorder(isSelected ? Color.mlPrimary : Color.mlCardStroke,
                                        lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(MLPressableButtonStyle())
        .accessibilityLabel("\(product.displayName), \(product.price)\(isAnnual(product) ? ". Mejor precio" : "")")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func purchaseButton(_ viewModel: PaywallViewModel) -> some View {
        MLButton(
            title: "Hazte Premium",
            icon: "crown.fill",
            isLoading: viewModel.isPurchasing,
            isEnabled: selectedID(viewModel) != nil,
        ) {
            guard let id = selectedID(viewModel),
                  let product = viewModel.products.first(where: { $0.id == id }) else { return }
            Task {
                if await viewModel.purchase(product) { dismiss() }
            }
        }
    }

    private func restoreButton(_ viewModel: PaywallViewModel) -> some View {
        Button {
            Task { if await viewModel.restore() { dismiss() } }
        } label: {
            Text("Restaurar compras")
                .font(MLFont.subheadline)
                .foregroundStyle(Color.mlTextSecondary)
                .underline()
        }
        .disabled(viewModel.isPurchasing)
        .accessibilityLabel("Restaurar compras")
    }
}
