import SwiftUI

// Fetches the caller's referral code and redeems others' codes.
@MainActor
@Observable
final class ReferralViewModel {
    var code: String?
    var isLoadingCode = false
    var redeemInput = ""
    var isRedeeming = false
    var redeemMessage: String?
    var redeemSucceeded = false

    private let gamification: GamificationRepositoryProtocol

    init(gamification: GamificationRepositoryProtocol) {
        self.gamification = gamification
    }

    func load() async {
        isLoadingCode = true
        defer { isLoadingCode = false }
        code = try? await gamification.getReferralCode()
    }

    func redeem() async {
        let trimmed = redeemInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return }
        isRedeeming = true
        redeemMessage = nil
        defer { isRedeeming = false }
        do {
            let ok = try await gamification.redeemReferral(code: trimmed)
            redeemSucceeded = ok
            redeemMessage = ok ? "¡Código canjeado! Ganaste 100 gemas." : "No se pudo canjear el código."
            if ok { redeemInput = "" }
        } catch {
            redeemSucceeded = false
            redeemMessage = (error as? LocalizedError)?.errorDescription ?? "Código inválido o ya usado."
        }
    }
}
