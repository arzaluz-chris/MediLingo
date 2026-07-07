import Foundation
import StoreKit

// StoreKit 2 subscription service (CLAUDE-ios.md § Subscriptions). Loads the
// auto-renewable products, runs purchases with on-device verification, tracks
// entitlements live via Transaction.updates, and exposes premium status.
//
// Product IDs are configured in Products.storekit (local testing) and must
// match App Store Connect. RevenueCat analytics wrapping is layered on later;
// entitlement truth stays with StoreKit.
@MainActor
@Observable
final class StoreKitSubscriptionService: SubscriptionServiceProtocol {
    static let productIDs = [
        "com.christian-arzaluz.MediLingo.premium.monthly",
        "com.christian-arzaluz.MediLingo.premium.annual",
    ]

    private(set) var isPremium = false
    // Fully qualified: StoreKit also declares a `SubscriptionInfo` type.
    private(set) var currentSubscription: MediLingo.SubscriptionInfo?

    private var products: [Product] = []

    init() {
        // The transaction listener runs for the app's lifetime (this service is
        // a singleton held by AppDependencies).
        _ = listenForTransactions()
        Task { await refreshEntitlements() }
    }

    func fetchProducts() async throws -> [SubscriptionProduct] {
        products = try await Product.products(for: Self.productIDs)
            .sorted { $0.price < $1.price }
        return products.map {
            SubscriptionProduct(id: $0.id, displayName: $0.displayName, price: $0.displayPrice)
        }
    }

    func purchase(_ product: SubscriptionProduct) async throws -> PurchaseResult {
        let storeProduct = try await resolveProduct(product.id)
        let result = try await storeProduct.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await refreshEntitlements()
            await transaction.finish()
            return .success
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .failed
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    func checkEntitlements() async throws -> Bool {
        await refreshEntitlements()
        return isPremium
    }

    // MARK: - Private

    private func resolveProduct(_ id: String) async throws -> Product {
        if let cached = products.first(where: { $0.id == id }) { return cached }
        guard let fetched = try await Product.products(for: [id]).first else {
            throw AppError.productNotFound
        }
        return fetched
    }

    /// Recompute premium status from the current entitlements.
    private func refreshEntitlements() async {
        var active = false
        var info: MediLingo.SubscriptionInfo?

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            guard Self.productIDs.contains(transaction.productID),
                  transaction.revocationDate == nil else { continue }
            // Ignore expired subscriptions.
            if let expiry = transaction.expirationDate, expiry < Date() { continue }
            active = true
            info = MediLingo.SubscriptionInfo(
                productID: transaction.productID,
                expiresAt: transaction.expirationDate,
                isTrial: transaction.offerType == .introductory,
            )
        }

        isPremium = active
        currentSubscription = info
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                guard let transaction = try? Self.staticVerify(result) else { continue }
                await self.refreshEntitlements()
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        try Self.staticVerify(result)
    }

    private nonisolated static func staticVerify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw AppError.purchaseFailed("Transaction verification failed.")
        case .verified(let safe):
            return safe
        }
    }
}
