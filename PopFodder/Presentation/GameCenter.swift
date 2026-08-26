import GameKit
import UIKit

/// Game Center only — Apple's own auth, no PopFodder account, no server, no new PII collected by us.
enum GameCenter {
    static let missionsSurvivedID = "missions_survived"
    static let killsID = "enemy_kills"

    private static var authenticated: Bool { GKLocalPlayer.local.isAuthenticated }

    static func authenticate(presenting: @escaping (UIViewController) -> Void) {
        GKLocalPlayer.local.authenticateHandler = { vc, _ in
            if let vc { presenting(vc) }
        }
    }

    static func submit(missionsSurvived: Int, kills: Int) {
        guard authenticated else { return }
        GKLeaderboard.submitScore(
            missionsSurvived, context: 0, player: GKLocalPlayer.local,
            leaderboardIDs: [missionsSurvivedID]
        ) { _ in }
        GKLeaderboard.submitScore(
            kills, context: 0, player: GKLocalPlayer.local,
            leaderboardIDs: [killsID]
        ) { _ in }
    }

    static func showLeaderboards(from viewController: UIViewController) {
        guard authenticated else { return }
        let gc = GKGameCenterViewController(state: .leaderboards)
        gc.gameCenterDelegate = GameCenterDismisser.shared
        viewController.present(gc, animated: true)
    }
}

private final class GameCenterDismisser: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterDismisser()
    func gameCenterViewControllerDidFinish(_ controller: GKGameCenterViewController) {
        controller.dismiss(animated: true)
    }
}
