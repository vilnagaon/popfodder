import SpriteKit

final class AboutScene: SKScene {
    private let campaign: Campaign

    init(size: CGSize, campaign: Campaign) {
        self.campaign = campaign
        super.init(size: size)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.05, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .resizeFill
        removeAllChildren()

        func line(_ text: String, y: CGFloat, size: CGFloat, color: SKColor = SKColor(white: 0.75, alpha: 1)) {
            let n = SKLabelNode(fontNamed: "Menlo")
            n.text = text
            n.fontSize = size
            n.fontColor = color
            n.position = CGPoint(x: 0, y: y)
            n.horizontalAlignmentMode = .center
            addChild(n)
        }

        line("POPFODDER", y: 90, size: 18, color: SKColor(red: 1, green: 0.84, blue: 0, alpha: 1))
        line("GPL-3.0  ·  NO TRACKING  ·  NO ADS", y: 62, size: 10)
        line("Source must ship with the binary.", y: 36, size: 10)
        line("https://github.com/vilnagaon/popfodder", y: 18, size: 10, color: SKColor(white: 0.9, alpha: 1))
        line("If that URL is empty, the source is the", y: -4, size: 10)
        line("PopFodder folder you built this app from.", y: -20, size: 10)
        line("No extra DRM. No network. Play log is local.", y: -46, size: 10)
        line("Cartoon war. People die. Age 12+.", y: -64, size: 10)
        line("TAP TO GO BACK", y: -100, size: 12, color: SKColor(white: 0.7, alpha: 1))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view?.presentScene(RosterScene(size: size, campaign: campaign), transition: .fade(with: .black, duration: 0.2))
    }
}
