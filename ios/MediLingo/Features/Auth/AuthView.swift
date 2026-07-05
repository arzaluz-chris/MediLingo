import SwiftUI

// Welcome + sign-in screen (CLAUDE-ios.md § Authentication & Onboarding).
struct AuthView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: AuthViewModel?
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
            @Bindable var vm = viewModel
            ScrollView {
                VStack(spacing: MLSpacing.lg) {
                    header
                    fields(vm)
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(MLFont.caption())
                            .foregroundStyle(Color.mlError)
                            .multilineTextAlignment(.center)
                    }
                    MLButton(
                        title: vm.mode == .signIn ? "Entrar" : "Crear cuenta",
                        isLoading: vm.isLoading,
                        isEnabled: vm.canSubmit,
                    ) {
                        Task { if await vm.submit() { onAuthenticated() } }
                    }
                    oauthButtons(vm)
                    toggleModeButton(vm)
                }
                .padding(MLSpacing.lg)
            }
        } else {
            MLLoadingView()
        }
    }

    private var header: some View {
        VStack(spacing: MLSpacing.sm) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.mlPrimary)
                .accessibilityHidden(true)
            Text("MediLingo")
                .font(MLFont.title(34))
                .foregroundStyle(Color.mlTextPrimary)
            Text("Inglés médico para profesionales de la salud")
                .font(MLFont.body())
                .foregroundStyle(Color.mlTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, MLSpacing.xl)
    }

    @ViewBuilder
    private func fields(_ vm: AuthViewModel) -> some View {
        @Bindable var vm = vm
        VStack(spacing: MLSpacing.md) {
            if vm.mode == .signUp {
                textField("Nombre", text: $vm.name)
            }
            textField("Correo", text: $vm.email, keyboard: .emailAddress)
            secureField("Contraseña", text: $vm.password)
        }
    }

    private func textField(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.never)
            .keyboardType(keyboard)
            .autocorrectionDisabled()
            .padding(MLSpacing.md)
            .background(Color.mlSurface)
            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
            .foregroundStyle(Color.mlTextPrimary)
            .accessibilityLabel(title)
    }

    private func secureField(_ title: String, text: Binding<String>) -> some View {
        SecureField(title, text: text)
            .padding(MLSpacing.md)
            .background(Color.mlSurface)
            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
            .foregroundStyle(Color.mlTextPrimary)
            .accessibilityLabel(title)
    }

    @ViewBuilder
    private func oauthButtons(_ vm: AuthViewModel) -> some View {
        VStack(spacing: MLSpacing.sm) {
            MLButton(title: "Continuar con Apple", style: .outline) {
                Task { if await vm.signInWithApple() { onAuthenticated() } }
            }
            MLButton(title: "Continuar con Google", style: .outline) {
                Task { if await vm.signInWithGoogle() { onAuthenticated() } }
            }
        }
    }

    private func toggleModeButton(_ vm: AuthViewModel) -> some View {
        Button {
            vm.mode = vm.mode == .signIn ? .signUp : .signIn
            vm.errorMessage = nil
        } label: {
            Text(vm.mode == .signIn ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Entra")
                .font(MLFont.caption())
                .foregroundStyle(Color.mlSecondary)
        }
    }
}
