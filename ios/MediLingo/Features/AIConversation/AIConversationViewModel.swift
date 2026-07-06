import SwiftUI

// Chat with an AI-simulated patient (CLAUDE-ios.md § AI Conversation).
@MainActor
@Observable
final class AIConversationViewModel {
    struct Message: Identifiable {
        let id = UUID()
        let role: Role
        let text: String
        enum Role { case user, assistant }
    }

    let type: ConversationType
    var messages: [Message] = []
    var input = ""
    var isSending = false
    var errorMessage: String?

    private let ai: AIServiceProtocol
    private let gamification: GamificationRepositoryProtocol
    private var conversationID: UUID?
    private var activityRecorded = false

    init(type: ConversationType, ai: AIServiceProtocol, gamification: GamificationRepositoryProtocol) {
        self.type = type
        self.ai = ai
        self.gamification = gamification
    }

    var canSend: Bool { !input.trimmingCharacters(in: .whitespaces).isEmpty && !isSending }

    func start() async {
        let conversation = try? await ai.startConversation(type: type, scenario: nil)
        conversationID = conversation?.id ?? UUID()
        messages = [Message(role: .assistant, text: "Hello, doctor. Thank you for seeing me today.")]
    }

    func send() async {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let id = conversationID else { return }
        messages.append(Message(role: .user, text: text))
        input = ""
        isSending = true
        errorMessage = nil
        defer { isSending = false }
        do {
            let response = try await ai.sendMessage(conversationID: id, message: text)
            messages.append(Message(role: .assistant, text: response.content))
            // Count the conversation once (bumps ai_conversations + its quest).
            if !activityRecorded {
                activityRecorded = true
                try? await gamification.recordActivity("ai_conversation", amount: 1)
            }
        } catch {
            errorMessage = "La IA no está disponible. Configura GEMINI_API_KEY."
        }
    }
}
