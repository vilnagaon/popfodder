import SpriteKit

final class RosterScene: SKScene {
    private let campaign: Campaign
    private let mission: Mission
    private let squad: [Trooper]

    init(size: CGSize, campaign: Campaign) {
        self.campaign = campaign
        self.mission = campaign.currentMission
        self.squad = campaign.deploy()
        super.init(size: size)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.05, alpha: 1)
        removeAllChildren()

        addLabel("POPFODDER", font: "Menlo-Bold", size: 22, color: SKColor(red: 1, green: 0.84, blue: 0, alpha: 1), y: 120)
        var job = "MISSION \(campaign.missionNumber) / \(campaign.missionCount)"
        if campaign.phaseCount > 1 { job += "  ·  PHASE \(campaign.phaseNumber)/\(campaign.phaseCount)" }
        addLabel(job, font: "Menlo", size: 11, color: SKColor(white: 0.55, alpha: 1), y: 96)
        addLabel(campaign.missionTitle, font: "Menlo-Bold", size: 16, color: .white, y: 72)
        addLabel(mission.objectiveLine, font: "Menlo", size: 12, color: SKColor(red: 0.86, green: 0.16, blue: 0.14, alpha: 1), y: 48)
        addLabel(mission.blurb ?? "", font: "Menlo", size: 10, color: SKColor(white: 0.55, alpha: 1), y: 28)

        let names = squad.map { "\($0.name)·\($0.rank)" }.joined(separator: "   ")
        addLabel(names, font: "Menlo-Bold", size: 13, color: SKColor(red: 0.22, green: 0.78, blue: 0.32, alpha: 1), y: -16)
        addLabel("POOL \(campaign.pool.count)   GRAVES \(campaign.graves.count)", font: "Menlo", size: 10, color: SKColor(white: 0.45, alpha: 1), y: -42)
        addLabel("TAP TO DEPLOY", font: "Menlo", size: 12, color: SKColor(white: 0.7, alpha: 1), y: -88)
        addLabel("SOURCE / GPL", font: "Menlo", size: 9, color: SKColor(white: 0.4, alpha: 1), y: -118)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.location(in: self).y < -104 {
            view?.presentScene(AboutScene(size: size, campaign: campaign), transition: .fade(with: .black, duration: 0.2))
            return
        }
        let game = GameScene(size: size, campaign: campaign, mission: mission, squad: squad)
        view?.presentScene(game, transition: .fade(with: .black, duration: 0.25))
    }

    private func addLabel(_ text: String, font: String, size: CGFloat, color: SKColor, y: CGFloat) {
        let node = SKLabelNode(fontNamed: font)
        node.text = text
        node.fontSize = size
        node.fontColor = color
        node.position = CGPoint(x: 0, y: y)
        node.horizontalAlignmentMode = .center
        addChild(node)
    }
}
