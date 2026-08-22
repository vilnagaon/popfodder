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
        if ProcessInfo.processInfo.arguments.contains("-infantry") {
            return InfantrySheetScene(size: size)
        }
        return TitleScene(size: size)
    }
}

/// Screenshot helper: 8-dir Ours / Theirs / Split / Dead. Launch with `-infantry`.
private final class InfantrySheetScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.16, blue: 0.1, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .resizeFill
        removeAllChildren()
        let facings: [CGFloat] = [0, .pi / 4, .pi / 2, 3 * .pi / 4, .pi, -3 * .pi / 4, -.pi / 2, -.pi / 4]
        let rows: [(label: String, player: Bool, group: Int, dead: Bool)] = [
            ("OURS", true, 0, false),
            ("THEIRS", false, 0, false),
            ("SPLIT", true, 1, false),
            ("DEAD", true, 0, true)
        ]
        for (r, row) in rows.enumerated() {
            let tag = SKLabelNode(fontNamed: "Menlo-Bold")
            tag.text = row.label
            tag.fontSize = 10
            tag.fontColor = SKColor(white: 0.75, alpha: 1)
            tag.position = CGPoint(x: -210, y: 88 - CGFloat(r) * 56)
            addChild(tag)
            for (c, face) in facings.enumerated() {
                let sprite = SKSpriteNode(texture: Art.infantry(
                    player: row.player, group: row.group, dead: row.dead, facing: face, walk: c % 3
                ))
                sprite.size = CGSize(width: 40, height: 40)
                sprite.position = CGPoint(x: -150 + CGFloat(c) * 44, y: 92 - CGFloat(r) * 56)
                addChild(sprite)
            }
        }
    }
}
