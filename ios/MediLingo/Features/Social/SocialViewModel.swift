import SwiftUI

// Loads the caller's weekly league standings (CLAUDE-ios.md § Social,
// docs/GAMIFICATION.md § Leagues). join_league seats the user server-side.
@MainActor
@Observable
final class SocialViewModel {
    var tier: String = ""
    var members: [LeagueMember] = []
    var isLoading = false
    var errorMessage: String?

    private let gamification: GamificationRepositoryProtocol

    init(gamification: GamificationRepositoryProtocol) {
        self.gamification = gamification
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let standings = try await gamification.getLeagueStandings()
            tier = standings.tier
            members = standings.members
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    var tierDisplayName: String {
        switch tier {
        case "bronze": "Liga Bronce"
        case "silver": "Liga Plata"
        case "gold": "Liga Oro"
        case "diamond": "Liga Diamante"
        case "master": "Liga Maestra"
        default: tier.capitalized
        }
    }
}
