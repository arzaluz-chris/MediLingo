import SwiftUI

// AI patient conversation chat (CLAUDE-ios.md § AI Conversation).
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
                        Text(error).font(MLFont.caption()).foregroundStyle(Color.mlError).padding(.horizontal, MLSpacing.md)
                    }
                    inputBar(viewModel)
                }
            } else {
                MLLoadingView()
            }
        }
        .navigationTitle("Práctica con IA")
        .task {
            if viewModel == nil {
                viewModel = AIConversationViewModel(type: type, ai: dependencies.aiService)
                await viewModel?.start()
            }
        }
    }

    private func messagesList(_ vm: AIConversationViewModel) -> some View {
        ScrollView {
            VStack(spacing: MLSpacing.sm) {
                ForEach(vm.messages) { message in bubble(message) }
                if vm.isSending {
                    HStack { ProgressView().tint(.mlSecondary); Spacer() }
                        .padding(.horizontal, MLSpacing.md)
                }
            }
            .padding(MLSpacing.md)
        }
    }

    private func bubble(_ message: AIConversationViewModel.Message) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.text)
                .font(MLFont.body())
                .foregroundStyle(message.role == .user ? .white : Color.mlTextPrimary)
                .padding(MLSpacing.md)
                .background(message.role == .user ? Color.mlPrimary : Color.mlSurface)
                .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }

    private func inputBar(_ vm: AIConversationViewModel) -> some View {
        @Bindable var vm = vm
        return HStack(spacing: MLSpacing.sm) {
            TextField("Escribe en inglés…", text: $vm.input, axis: .vertical)
                .lineLimit(1...3)
                .padding(MLSpacing.sm)
                .background(Color.mlSurface)
                .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                .foregroundStyle(Color.mlTextPrimary)
            Button {
                Task { await vm.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(vm.canSend ? Color.mlPrimary : Color.mlTextTertiary)
            }
            .disabled(!vm.canSend)
            .accessibilityLabel("Enviar mensaje")
        }
        .padding(MLSpacing.md)
    }
}
