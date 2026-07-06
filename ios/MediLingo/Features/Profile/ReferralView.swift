import SwiftUI

// Invite a colleague, redeem a code — both parties earn gems (docs/GAMIFICATION
// § Referrals; backed by get_referral_code / redeem_referral RPCs).
struct ReferralView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: ReferralViewModel?

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Invita y gana")
        .task {
            if viewModel == nil {
                viewModel = ReferralViewModel(gamification: dependencies.gamificationRepository)
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
                    codeCard(viewModel)
                    redeemCard(viewModel)
                }
                .padding(MLSpacing.md)
            }
        } else {
            MLLoadingView()
        }
    }

    private var header: some View {
        VStack(spacing: MLSpacing.sm) {
            Image(systemName: "gift.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.mlGems)
            Text("Comparte tu código y ambos ganan 100 gemas.")
                .font(MLFont.body())
                .foregroundStyle(Color.mlTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, MLSpacing.md)
    }

    private func codeCard(_ viewModel: ReferralViewModel) -> some View {
        MLCard {
            VStack(spacing: MLSpacing.sm) {
                Text("Tu código")
                    .font(MLFont.caption())
                    .foregroundStyle(Color.mlTextSecondary)
                if viewModel.isLoadingCode {
                    ProgressView()
                } else {
                    Text(viewModel.code ?? "—")
                        .font(MLFont.title(28))
                        .foregroundStyle(Color.mlTextPrimary)
                        .monospaced()
                        .textSelection(.enabled)
                }
                if let code = viewModel.code {
                    ShareLink(item: "Aprende inglés médico conmigo en MediLingo. Usa mi código: \(code)") {
                        Text("Compartir")
                            .font(MLFont.heading(15))
                            .foregroundStyle(Color.mlPrimary)
                    }
                    .accessibilityLabel("Compartir código \(code)")
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func redeemCard(_ viewModel: ReferralViewModel) -> some View {
        MLCard {
            VStack(alignment: .leading, spacing: MLSpacing.sm) {
                Text("¿Tienes un código?")
                    .font(MLFont.heading(16))
                    .foregroundStyle(Color.mlTextPrimary)
                TextField("Ingresa el código", text: Binding(
                    get: { viewModel.redeemInput },
                    set: { viewModel.redeemInput = $0 },
                ))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(MLSpacing.sm)
                .background(Color.mlSurfaceElevated, in: RoundedRectangle(cornerRadius: 10))
                MLButton(title: "Canjear", style: .primary) {
                    Task { await viewModel.redeem() }
                }
                .disabled(viewModel.redeemInput.isEmpty || viewModel.isRedeeming)
                if let message = viewModel.redeemMessage {
                    Text(message)
                        .font(MLFont.caption())
                        .foregroundStyle(viewModel.redeemSucceeded ? Color.mlSuccess : Color.mlHearts)
                }
            }
        }
    }
}
