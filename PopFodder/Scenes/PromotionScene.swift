import SpriteKit

/// v1.2: shown once per trooper, at their first promotion. Chains through
/// `campaign.pendingPromotions` one at a time, then hands off to Roster.
final class PromotionScene: SKScene {
    private let campaign: Campaign
    private let trooperId: UUID
    private let trooperName: String

    init(size: CGSize, campaign: Campaign, trooperId: UUID) {
        self.campaign = campaign
        self.trooperId = trooperId
        self.trooperName = campaign.pool.first { $0.id == trooperId }?.name ?? "TROOPER"
        super.init(size: size)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.05, alpha: 1)
        removeAllChildren()

        func line(_ text: String, y: CGFloat, x: CGFloat = 0, size: CGFloat, color: SKColor = SKColor(white: 0.75, alpha: 1)) {
            let n = SKLabelNode(fontNamed: "Menlo")
            n.text = text
            n.fontSize = size
            n.fontColor = color
            n.position = CGPoint(x: x, y: y)
            n.horizontalAlignmentMode = .center
            addChild(n)
        }

        line(trooperName, y: 100, size: 20, color: SKColor(red: 1, green: 0.84, blue: 0, alpha: 1))
        line("FIRST STRIPE. PICK A HABIT.", y: 70, size: 11)

        line("MARKSMAN", y: 10, x: -140, size: 16, color: SKColor(red: 0.22, green: 0.78, blue: 0.32, alpha: 1))
        line("Half the miss chance.", y: -12, x: -140, size: 10)
        line("Fewer wasted rifle rounds.", y: -28, x: -140, size: 10)

        line("MEDIC", y: 10, x: 140, size: 16, color: SKColor(red: 0.38, green: 0.58, blue: 1.0, alpha: 1))
        line("A chance to patch a", y: -12, x: 140, size: 10)
        line("dying squadmate nearby.", y: -28, x: 140, size: 10)

        line("TAP LEFT OR RIGHT", y: -80, size: 12, color: SKColor(white: 0.7, alpha: 1))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        campaign.choose(x < 0 ? .marksman : .medic, for: trooperId)
        view?.presentScene(RunFlow.next(size: size, campaign: campaign), transition: .fade(with: .black, duration: 0.2))
    }
}
