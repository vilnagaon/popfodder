import SwiftUI
import SpriteKit

@main
struct PopFodderApp: App {
    var body: some Scene {
        WindowGroup {
            SpriteView(scene: Self.launchScene())
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }

    private static func launchScene() -> SKScene {
        let size = UIScreen.main.bounds.size
        if ProcessInfo.processInfo.arguments.contains("-graveyard") {
            let campaign = Campaign()
            campaign.buryFromPool(8)
            return GraveyardScene(
                size: size,
                campaign: campaign,
                mission: campaign.currentMission,
                deployed: [],
                survivors: [],
                won: true
            )
        }
        return TitleScene(size: size)
    }
}
