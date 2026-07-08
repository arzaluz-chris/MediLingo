import SwiftUI

// Welcome + sign-in screen (CLAUDE-ios.md § Authentication & Onboarding).
//
// Redesign: gradient hero with the brand mark and value proposition on top,
// a floating form card, and HIG-styled OAuth buttons (Apple black/white).
// The screen has one focal point — the brand hero — and one primary action.
struct AuthView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: AuthViewModel?
    @State private var heroVisible = false
    let onAuthenticated: () -> Void

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            content
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(auth: dependencies.authService)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            ScrollView {
                VStack(spacing: MLSpacing.lg) {
                    hero
                    formCard(viewModel)
                    oauthButtons(viewModel)
                    toggleModeButton(viewModel)
                }
                .padding(MLSpacing.md)
                .padding(.bottom, MLSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            MLLoadingView()
        }
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: MLSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: MLRadius.xl, style: .continuous)
                    .fill(MLGradient.hero)
                    .frame(width: 96, height: 96)
                    .mlShadow(.card)
                Image(systemName: "stethoscope")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.mlOnAccent)
            }
            .scaleEffect(heroVisible ? 1 : 0.6)
            .opacity(heroVisible ? 1 : 0)
            .accessibilityHidden(true)

            VStack(spacing: MLSpacing.xs) {
                Text("MediLingo")
                    .font(MLFont.hero)
                    .foregroundStyle(Color.mlTextPrimary)
                Text("Inglés médico para profesionales de la salud")
                    .font(MLFont.subheadline)
                    .foregroundStyle(Color.mlTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, MLSpacing.xl)
        .onAppear {
            withAnimation(MLMotion.bouncy.delay(0.1)) { heroVisible = true }
        }
    }

    // MARK: Email form

    private func formCard(_ viewModel: AuthViewModel) -> some View {
        @Bindable var vm = viewModel
        return MLCard(padding: MLSpacing.md) {
            VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                if vm.mode == .signUp {
                    field(icon: "person.fill", title: "Nombre", text: $vm.name)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                field(icon: "envelope.fill", title: "Correo", text: $vm.email, keyboard: .emailAddress)
                secureField(icon: "lock.fill", title: "Contraseña", text: $vm.password)

                if let error = vm.errorMessage {
                    Label(error, systemImage: "exclamationmark.circle.fill")
                        .font(MLFont.caption)
                        .foregroundStyle(Color.mlError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                MLButton(
                    title: vm.mode == .signIn ? "Entrar" : "Crear cuenta",
                    isLoading: vm.isLoading,
                    isEnabled: vm.canSubmit,
                ) {
                    Task { if await vm.submit() { onAuthenticated() } }
                }
            }
        }
        .animation(MLMotion.smooth, value: vm.mode == .signUp)
    }

    private func field(icon: String, title: String, text: Binding<String>,
                       keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: MLSpacing.sm) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.mlTextTertiary)
                .frame(width: 22)
            TextField(title, text: text)
                .textInputAutocapitalization(.never)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .font(MLFont.body)
                .foregroundStyle(Color.mlTextPrimary)
        }
        .padding(MLSpacing.md)
        .background(Color.mlSurfaceElevated, in: RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }

    private func secureField(icon: String, title: String, text: Binding<String>) -> some View {
        HStack(spacing: MLSpacing.sm) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.mlTextTertiary)
                .frame(width: 22)
            SecureField(title, text: text)
                .font(MLFont.body)
                .foregroundStyle(Color.mlTextPrimary)
        }
        .padding(MLSpacing.md)
        .background(Color.mlSurfaceElevated, in: RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }

    // MARK: OAuth

    @ViewBuilder
    private func oauthButtons(_ vm: AuthViewModel) -> some View {
        VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
            HStack(spacing: MLSpacing.sm) {
                divider
                Text("o continúa con")
                    .font(MLFont.caption)
                    .foregroundStyle(Color.mlTextTertiary)
                    .fixedSize()
                divider
            }

            // Sign in with Apple — HIG: black button in light mode, white in dark.
            oauthButton(
                label: "Apple", symbol: "apple.logo",
                background: colorScheme == .dark ? .white : .black,
                foreground: colorScheme == .dark ? .black : .white,
            ) {
                Task { if await vm.signInWithApple() { onAuthenticated() } }
            }

            oauthButton(
                label: "Google", symbol: "globe",
                background: Color.mlSurface,
                foreground: Color.mlTextPrimary,
                stroked: true,
            ) {
                Task { if await vm.signInWithGoogle() { onAuthenticated() } }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.mlTextTertiary.opacity(0.3))
            .frame(height: 1)
    }

    private func oauthButton(label: String, symbol: String, background: Color,
                             foreground: Color, stroked: Bool = false,
                             action: @escaping () -> Void) -> some View {
        let shape = RoundedRectangle(cornerRadius: MLRadius.button, style: .continuous)
        return Button {
            MLHaptic.tap()
            action()
        } label: {
            HStack(spacing: MLSpacing.sm) {
                Image(systemName: symbol)
                    .font(.body.weight(.semibold))
                Text("Continuar con \(label)")
                    .font(MLFont.headline)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(background)
            .clipShape(shape)
            .overlay(shape.strokeBorder(stroked ? Color.mlCardStroke : .clear, lineWidth: 1))
        }
        .buttonStyle(MLPressableButtonStyle())
        .accessibilityLabel("Continuar con \(label)")
    }

    private func toggleModeButton(_ vm: AuthViewModel) -> some View {
        Button {
            MLHaptic.selection()
            withAnimation(MLMotion.smooth) {
                vm.mode = vm.mode == .signIn ? .signUp : .signIn
            }
            vm.errorMessage = nil
        } label: {
            Text(vm.mode == .signIn ? "¿No tienes cuenta? **Regístrate**" : "¿Ya tienes cuenta? **Entra**")
                .font(MLFont.subheadline)
                .foregroundStyle(Color.mlPrimary)
        }
        .padding(.top, MLSpacing.xs)
    }
}
