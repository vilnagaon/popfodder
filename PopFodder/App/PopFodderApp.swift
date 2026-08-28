import SwiftUI
import SpriteKit

/// SwiftUI's App lifecycle doesn't reliably enforce Info.plist's landscape-only
/// lock on iPad without this hook — without it the app can be handed a portrait
/// window.
private final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .landscape
    }
}

@main
struct PopFodderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

    static func authenticateGameCenter() {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first(where: \.isKeyWindow) })
            .first?.rootViewController
        else { return }
        GameCenter.authenticate { vc in root.present(vc, animated: true) }
    }

    /// `UIScreen.main.bounds` doesn't reflect the real window size under iPadOS
    /// multitasking (Stage Manager, Split View) — the scene must be sized from
    /// the actual view geometry instead, captured once at launch.
    static func launchScene(size: CGSize) -> SKScene {
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
        if ProcessInfo.processInfo.arguments.contains("-roster") {
            return RosterScene(size: size, campaign: Campaign())
        }
        if ProcessInfo.processInfo.arguments.contains("-promo") {
            let campaign = Campaign()
            let id = campaign.pool[0].id
            return PromotionScene(size: size, campaign: campaign, trooperId: id)
        }
        if ProcessInfo.processInfo.arguments.contains("-gap") {
            let campaign = Campaign()
            return GameScene(size: size, campaign: campaign, mission: campaign.currentMission, squad: campaign.deploy())
        }
        if ProcessInfo.processInfo.arguments.contains("-split") {
            let campaign = Campaign()
            let squad = campaign.deploy()
            let scene = GameScene(size: size, campaign: campaign, mission: campaign.currentMission, squad: squad)
            if let id = squad.first?.id {
                scene.battle.splitSoldier(id)
                if let mover = scene.battle.soldiers.first(where: { $0.id == id }) {
                    scene.battle.orderMove(to: CGPoint(x: mover.position.x + 90, y: mover.position.y + 70))
                }
            }
            return scene
        }
        if ProcessInfo.processInfo.arguments.contains("-jeep") {
            let campaign = Campaign()
            let mission = Mission.loadNamed("the-yard")
            let scene = GameScene(size: size, campaign: campaign, mission: mission, squad: campaign.deploy())
            if let jeep = scene.battle.jeep { scene.battle.orderMove(to: jeep.position) }
            return scene
        }
        return TitleScene(size: size)
    }
}

/// Sizes the scene from real view geometry (not `UIScreen.main.bounds`, which is
/// wrong under iPadOS Stage Manager/Split View) and constructs it exactly once.
private struct RootView: View {
    @State private var scene: SKScene?

    var body: some View {
        GeometryReader { proxy in
            Group {
                if let scene {
                    SpriteView(scene: scene)
                } else {
                    Color.black.onAppear {
                        scene = PopFodderApp.launchScene(size: proxy.size)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .statusBarHidden(true)
        .onAppear { PopFodderApp.authenticateGameCenter() }
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
