import Foundation
import Supabase

// Calls the AI Edge Functions (Gemini-backed) through the Supabase client.
// Returns the app's `{data,error,metadata}` envelope, decoded per endpoint.
struct SupabaseAIService: AIServiceProtocol {
    let client: SupabaseClient

    func startConversation(type: ConversationType, scenario: Scenario?) async throws -> AIConversation {
        // A conversation id is minted client-side; turns go through sendMessage.
        AIConversation(id: UUID(), type: type)
    }

    func sendMessage(conversationID: UUID, message: String) async throws -> AIResponse {
        let env: Envelope<ConversationData> = try await invoke(
            "ai-conversation", body: ["message": message],
        )
        guard let data = env.data else { throw apiError(env) }
        return AIResponse(content: data.response, scores: nil)
    }

    func evaluatePronunciation(word: String, phonetic: String?, transcription: String, confidence: Double) async throws -> PronunciationResult {
        let env: Envelope<PronunciationData> = try await invoke("evaluate-pronunciation", body: [
            "word": word,
            "phonetic": phonetic ?? "",
            "transcription": transcription,
            "confidence": String(confidence),
        ])
        guard let d = env.data else { throw apiError(env) }
        return PronunciationResult(
            overallScore: d.overall_score, pronunciationScore: d.overall_score,
            fluencyScore: d.overall_score, accuracy: d.overall_score,
            corrections: [], feedback: d.feedback,
        )
    }

    func generateExplanation(prompt: String, userAnswer: String, correctAnswer: String?, isCorrect: Bool) async throws -> String {
        let env: Envelope<ExplanationData> = try await invoke("generate-exercise-feedback", body: [
            "prompt": prompt, "userAnswer": userAnswer,
            "correctAnswer": correctAnswer ?? "", "isCorrect": String(isCorrect),
        ])
        guard let d = env.data else { throw apiError(env) }
        return d.explanation
    }

    // MARK: - Helpers

    private func invoke<T: Decodable>(_ name: String, body: [String: String]) async throws -> Envelope<T> {
        try await client.functions.invoke(name, options: FunctionInvokeOptions(body: body))
    }

    private func apiError<T>(_ env: Envelope<T>) -> AppError {
        .serverError(statusCode: 0, message: env.error?.message ?? "AI request failed")
    }
}

// MARK: - Envelope + payloads

private struct Envelope<T: Decodable>: Decodable {
    let data: T?
    let error: EnvelopeError?
}

private struct EnvelopeError: Decodable {
    let code: String
    let message: String
}

private struct ConversationData: Decodable { let response: String }
private struct ExplanationData: Decodable { let explanation: String }
private struct PronunciationData: Decodable {
    let overall_score: Double
    let feedback: String
}
