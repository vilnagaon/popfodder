import SpriteKit

final class TitleScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.05, alpha: 1)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .resizeFill
        SFX.boot()

        let mark = SKShapeNode(circleOfRadius: 42)
        mark.fillColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        mark.strokeColor = SKColor(white: 0.95, alpha: 1)
        mark.lineWidth = 6
        mark.position = CGPoint(x: 0, y: 36)
        addChild(mark)

        let split = SKShapeNode(rectOf: CGSize(width: 8, height: 84))
        split.fillColor = SKColor(white: 0.05, alpha: 1)
        split.strokeColor = .clear
        mark.addChild(split)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "POPFODDER"
        title.fontSize = 28
        title.fontColor = SKColor(white: 0.95, alpha: 1)
        title.position = CGPoint(x: 0, y: -40)
        addChild(title)

        let sub = SKLabelNode(fontNamed: "Menlo")
        sub.text = "TAP TO SPEND THEM"
        sub.fontSize = 11
        sub.fontColor = SKColor(white: 0.5, alpha: 1)
        sub.position = CGPoint(x: 0, y: -68)
        addChild(sub)

        mark.setScale(0.4)
        mark.alpha = 0
        title.alpha = 0
        mark.run(.group([.fadeIn(withDuration: 0.35), .scale(to: 1, duration: 0.4)]))
        title.run(.sequence([.wait(forDuration: 0.2), .fadeIn(withDuration: 0.3)]))
        SFX.play("win")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Juice.haptic(.medium)
        view?.presentScene(
            RosterScene(size: size, campaign: Campaign()),
            transition: .fade(with: SKColor(white: 0.05, alpha: 1), duration: 0.35)
        )
    }
}
