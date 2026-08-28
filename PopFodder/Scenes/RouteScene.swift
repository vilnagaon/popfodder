import SpriteKit

/// v1.4: shown when the mission just completed has 2+ `next` options.
/// Left/right tap picks the route; both sides always reconverge later in
/// the DAG, so this is a real trade-off, not a permanent fork.
final class RouteScene: SKScene {
    private let campaign: Campaign
    private let options: [CampaignDef.Item]

    init(size: CGSize, campaign: Campaign) {
        self.campaign = campaign
        self.options = campaign.pendingRoute
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

        line("CHOOSE THE NEXT JOB", y: 100, size: 14, color: SKColor(red: 1, green: 0.84, blue: 0, alpha: 1))

        let sides: [CGFloat] = [-140, 140]
        for (i, item) in options.prefix(2).enumerated() {
            let x = sides[i]
            line(item.title, y: 30, x: x, size: 17, color: SKColor(red: 0.22, green: 0.78, blue: 0.32, alpha: 1))
            if let hint = item.hint {
                line(hint, y: 6, x: x, size: 9)
            }
        }

        line("TAP LEFT OR RIGHT", y: -70, size: 12, color: SKColor(white: 0.7, alpha: 1))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !options.isEmpty else { return }
        let index = touch.location(in: self).x < 0 ? 0 : 1
        let chosen = options[min(index, options.count - 1)]
        campaign.chooseRoute(chosen.id)
        view?.presentScene(RunFlow.next(size: size, campaign: campaign), transition: .fade(with: .black, duration: 0.2))
    }
}
