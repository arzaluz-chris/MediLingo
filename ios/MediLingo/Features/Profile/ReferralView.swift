import SwiftUI

// Invite a colleague, redeem a code — both parties earn gems (docs/GAMIFICATION
// § Referrals; backed by get_referral_code / redeem_referral RPCs).
//
// Redesign: gradient gift hero, ticket-style code card with dashed border and
// a prominent share action, and a separate redeem card.
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
                VStack(spacing: MLSpacing.md) {
                    hero
                    codeCard(viewModel)
                    redeemCard(viewModel)
                }
                .padding(MLSpacing.md)
                .padding(.bottom, MLSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            MLLoadingView()
        }
    }

    private var hero: some View {
        MLHeroCard(gradient: MLGradient.premium) {
            HStack(spacing: MLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.mlOnAccent.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Image(systemName: "gift.fill")
                        .font(.title2)
                        .foregroundStyle(Color.mlOnAccent)
                }
                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    Text("Invita a un colega")
                        .font(MLFont.title3)
                        .foregroundStyle(Color.mlOnAccent)
                    Text("Ambos ganan 100 gemas cuando use tu código.")
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlOnAccent.opacity(0.85))
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func codeCard(_ viewModel: ReferralViewModel) -> some View {
        MLCard(padding: MLSpacing.lg) {
            VStack(spacing: MLSpacing.md) {
                Text("TU CÓDIGO")
                    .font(MLFont.caption)
                    .foregroundStyle(Color.mlTextSecondary)
                    .kerning(1.2)

                Group {
                    if viewModel.isLoadingCode {
                        ProgressView().tint(.mlPrimary)
                    } else {
                        Text(viewModel.code ?? "—")
                            .font(MLFont.title)
                            .foregroundStyle(Color.mlPrimary)
                            .monospaced()
                            .kerning(2)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
                        .fill(Color.mlPrimary.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
                        .strokeBorder(Color.mlPrimary.opacity(0.4),
                                      style: StrokeStyle(lineWidth: 1.5, dash: [7, 5]))
                )

                if let code = viewModel.code {
                    ShareLink(item: "Aprende inglés médico conmigo en MediLingo. Usa mi código: \(code)") {
                        HStack(spacing: MLSpacing.sm) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.semibold))
                            Text("Compartir código")
                                .font(MLFont.headline)
                        }
                        .foregroundStyle(Color.mlOnAccent)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(MLGradient.brand)
                        .clipShape(RoundedRectangle(cornerRadius: MLRadius.button, style: .continuous))
                    }
                    .buttonStyle(MLPressableButtonStyle())
                    .accessibilityLabel("Compartir código \(code)")
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func redeemCard(_ viewModel: ReferralViewModel) -> some View {
        MLCard {
            VStack(alignment: .leading, spacing: MLSpacing.sm + MLSpacing.xs) {
                Text("¿Tienes un código?")
                    .font(MLFont.headline)
                    .foregroundStyle(Color.mlTextPrimary)
                TextField("Ingresa el código", text: Binding(
                    get: { viewModel.redeemInput },
                    set: { viewModel.redeemInput = $0 },
                ))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(MLFont.body)
                .padding(MLSpacing.md)
                .background(Color.mlSurfaceElevated, in: RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous))
                .accessibilityLabel("Código de invitación")

                MLButton(title: "Canjear", style: .secondary,
                         isLoading: viewModel.isRedeeming,
                         isEnabled: !viewModel.redeemInput.isEmpty) {
                    Task { await viewModel.redeem() }
                }

                if let message = viewModel.redeemMessage {
                    Label(message, systemImage: viewModel.redeemSucceeded
                          ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(MLFont.caption)
                        .foregroundStyle(viewModel.redeemSucceeded ? Color.mlEmerald : Color.mlError)
                }
            }
        }
    }
}
