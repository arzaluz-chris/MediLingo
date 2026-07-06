import SwiftUI

// Drives the paywall: loads StoreKit products and runs purchase/restore
// (CLAUDE-ios.md § Subscription).
@MainActor
@Observable
final class PaywallViewModel {
    var products: [SubscriptionProduct] = []
    var isLoading = false
    var isPurchasing = false
    var errorMessage: String?

    private let subscription: SubscriptionServiceProtocol

    init(subscription: SubscriptionServiceProtocol) {
        self.subscription = subscription
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            products = try await subscription.fetchProducts()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    /// Returns true when the purchase succeeded (caller dismisses the paywall).
    func purchase(_ product: SubscriptionProduct) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        do {
            let result = try await subscription.purchase(product)
            switch result {
            case .success:
                return true
            case .cancelled:
                return false
            case .pending:
                errorMessage = "Tu compra está pendiente de aprobación."
                return false
            case .failed:
                errorMessage = "No se pudo completar la compra."
                return false
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }

    func restore() async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        do {
            try await subscription.restorePurchases()
            let active = try await subscription.checkEntitlements()
            if !active { errorMessage = "No encontramos compras para restaurar." }
            return active
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }
}
