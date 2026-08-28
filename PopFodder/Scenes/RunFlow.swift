import SpriteKit

/// The scene chain after a mission resolves: promotion picks, then a route
/// choice if the mission just branched, then the roster. Shared by
/// GraveyardScene / PromotionScene / RouteScene so the order stays in one place.
enum RunFlow {
    static func next(size: CGSize, campaign: Campaign) -> SKScene {
        if let id = campaign.pendingPromotions.first {
            return PromotionScene(size: size, campaign: campaign, trooperId: id)
        }
        if campaign.pendingRoute.count > 1 {
            return RouteScene(size: size, campaign: campaign)
        }
        return RosterScene(size: size, campaign: campaign)
    }
}
