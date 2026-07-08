import SwiftUI

// AI patient conversation chat (CLAUDE-ios.md § AI Conversation).
//
// Redesign: proper chat look — assistant avatar, asymmetric bubble corners,
// animated typing indicator, auto-scroll to the latest message, and a
// material input bar with a springy send button.
struct AIConversationView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: AIConversationViewModel?
    var type: ConversationType = .patientConsultation

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            if let viewModel {
                VStack(spacing: 0) {
                    messagesList(viewModel)
                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(MLFont.caption)
                            .foregroundStyle(Color.mlError)
                            .padding(.horizontal, MLSpacing.md)
                    }
                    inputBar(viewModel)
                }
            } else {
                MLLoadingView(message: "Preparando la consulta…")
            }
        }
        .navigationTitle("Práctica con IA")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = AIConversationViewModel(type: type, ai: dependencies.aiService, gamification: dependencies.gamificationRepository)
                await viewModel?.start()
            }
        }
    }

    // MARK: Messages

    private func messagesList(_ vm: AIConversationViewModel) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                    ForEach(vm.messages) { message in
                        bubble(message)
                            .id(message.id)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    if vm.isSending {
                        typingIndicator
                            .id("typing")
                    }
                }
                .padding(MLSpacing.md)
                .animation(MLMotion.smooth, value: vm.messages.count)
            }
            .onChange(of: vm.messages.count) { _, _ in
                if let last = vm.messages.last {
                    withAnimation(MLMotion.smooth) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: vm.isSending) { _, sending in
                if sending {
                    withAnimation(MLMotion.smooth) { proxy.scrollTo("typing", anchor: .bottom) }
                }
            }
        }
    }

    private func bubble(_ message: AIConversationViewModel.Message) -> some View {
        let isUser = message.role == .user
        return HStack(alignment: .bottom, spacing: MLSpacing.sm) {
            if isUser {
                Spacer(minLength: MLSpacing.xxl)
            } else {
                avatar
            }

            Text(message.text)
                .font(MLFont.body)
                .foregroundStyle(isUser ? Color.mlOnAccent : Color.mlTextPrimary)
                .padding(.horizontal, MLSpacing.md)
                .padding(.vertical, MLSpacing.sm + MLSpacing.xs)
                .background(bubbleBackground(isUser: isUser))

            if !isUser { Spacer(minLength: MLSpacing.xxl) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(isUser ? "Tú" : "Paciente"): \(message.text)")
    }

    @ViewBuilder
    private func bubbleBackground(isUser: Bool) -> some View {
        let radii = RectangleCornerRadii(
            topLeading: MLRadius.lg,
            bottomLeading: isUser ? MLRadius.lg : MLRadius.xs,
            bottomTrailing: isUser ? MLRadius.xs : MLRadius.lg,
            topTrailing: MLRadius.lg,
        )
        if isUser {
            UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
                .fill(MLGradient.brand)
        } else {
            UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
                .fill(Color.mlSurface)
                .overlay(
                    UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
                        .strokeBorder(Color.mlCardStroke, lineWidth: 1)
                )
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.mlCyan.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.subheadline)
                .foregroundStyle(Color.mlCyan)
        }
        .accessibilityHidden(true)
    }

    private var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: MLSpacing.sm) {
            avatar
            TypingDots()
                .padding(.horizontal, MLSpacing.md)
                .padding(.vertical, MLSpacing.sm + MLSpacing.xs)
                .background(Color.mlSurface, in: Capsule())
            Spacer(minLength: MLSpacing.xxl)
        }
        .accessibilityLabel("El paciente está escribiendo")
    }

    // MARK: Input

    private func inputBar(_ vm: AIConversationViewModel) -> some View {
        @Bindable var vm = vm
        return HStack(alignment: .bottom, spacing: MLSpacing.sm) {
            TextField("Escribe en inglés…", text: $vm.input, axis: .vertical)
                .lineLimit(1...4)
                .font(MLFont.body)
                .foregroundStyle(Color.mlTextPrimary)
                .padding(.horizontal, MLSpacing.md)
                .padding(.vertical, MLSpacing.sm + MLSpacing.xs)
                .background(Color.mlSurface, in: RoundedRectangle(cornerRadius: MLRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MLRadius.lg, style: .continuous)
                        .strokeBorder(Color.mlCardStroke, lineWidth: 1)
                )

            Button {
                MLHaptic.tap()
                Task { await vm.send() }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.body.weight(.bold))
                    .foregroundStyle(Color.mlOnAccent)
                    .frame(width: 44, height: 44)
                    .background(vm.canSend ? AnyShapeStyle(MLGradient.brand) : AnyShapeStyle(Color.mlTextTertiary.opacity(0.4)))
                    .clipShape(Circle())
            }
            .buttonStyle(MLPressableButtonStyle(scale: 0.88))
            .disabled(!vm.canSend)
            .accessibilityLabel("Enviar mensaje")
        }
        .padding(MLSpacing.md)
        .background(.bar)
    }
}

// Three bouncing dots — the universal "typing" affordance.
private struct TypingDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.mlTextTertiary)
                    .frame(width: 7, height: 7)
                    .offset(y: reduceMotion ? 0 : (animating ? -4 : 2))
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.16),
                        value: animating,
                    )
            }
        }
        .onAppear { animating = true }
        .accessibilityHidden(true)
    }
}
