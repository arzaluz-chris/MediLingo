import SwiftUI

// Gem shop (CLAUDE-ios.md § Shop, docs/GAMIFICATION.md § Shop).
@MainActor
@Observable
final class ShopViewModel {
    var items: [ShopItem] = []
    var gems: Int = 0
    var isLoading = false
    var message: String?

    private let gamification: GamificationRepositoryProtocol

    init(gamification: GamificationRepositoryProtocol) {
        self.gamification = gamification
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        gems = (try? await gamification.getUserStats().gems) ?? 0
        items = (try? await gamification.getShopItems()) ?? []
    }

    func buy(_ item: ShopItem) async {
        message = nil
        do {
            let stats = try await gamification.purchase(itemID: item.id)
            gems = stats.gems
            await load()
            message = "¡Compraste \(item.title)!"
        } catch AppError.insufficientGems {
            message = "No tienes suficientes gemas."
        } catch {
            message = (error as? LocalizedError)?.errorDescription ?? "No se pudo completar la compra."
        }
    }
}
