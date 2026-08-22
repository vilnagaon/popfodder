import SpriteKit
import UIKit

enum Juice {
    static func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func shake(_ node: SKNode, amount: CGFloat = 7, duration: TimeInterval = 0.12) {
        node.removeAction(forKey: "shake")
        let origin = node.position
        let n = 5
        var steps: [SKAction] = []
        for i in 0..<n {
            let t = CGFloat(n - i) / CGFloat(n)
            steps.append(.moveBy(x: CGFloat.random(in: -amount...amount) * t,
                                 y: CGFloat.random(in: -amount...amount) * t,
                                 duration: duration / Double(n)))
        }
        steps.append(.move(to: origin, duration: 0.04))
        node.run(.sequence(steps), withKey: "shake")
    }

    static func puff(at point: CGPoint, color: SKColor, in parent: SKNode) {
        for _ in 0..<8 {
            let bit = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3.5))
            bit.fillColor = color
            bit.strokeColor = .clear
            bit.position = point
            bit.zPosition = 8
            parent.addChild(bit)
            let dest = CGPoint(
                x: point.x + CGFloat.random(in: -18...18),
                y: point.y + CGFloat.random(in: -18...18)
            )
            bit.run(.sequence([
                .group([
                    .move(to: dest, duration: 0.28),
                    .fadeOut(withDuration: 0.28),
                    .scale(to: 0.2, duration: 0.28)
                ]),
                .removeFromParent()
            ]))
        }
    }

    static func flash(_ node: SKNode) {
        node.run(.sequence([
            .fadeAlpha(to: 0.35, duration: 0.04),
            .fadeAlpha(to: 1, duration: 0.08)
        ]))
    }

    static func pulseRing(_ ring: SKShapeNode) {
        guard ring.action(forKey: "pulse") == nil else { return }
        let up = SKAction.scale(to: 1.12, duration: 0.35)
        up.timingMode = .easeInEaseOut
        let down = SKAction.scale(to: 1.0, duration: 0.35)
        down.timingMode = .easeInEaseOut
        ring.run(.repeatForever(.sequence([up, down])), withKey: "pulse")
    }
}
