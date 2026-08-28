import SpriteKit

final class GraveyardScene: SKScene {
    private let campaign: Campaign
    private let mission: Mission
    private let won: Bool
    private let campaignOver: Bool

    init(size: CGSize, campaign: Campaign, mission: Mission, deployed: [Trooper], survivors: [Soldier], won: Bool) {
        self.campaign = campaign
        self.mission = mission
        self.won = won
        self.campaignOver = campaign.finished || campaign.poolExhausted
        super.init(size: size)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.05, alpha: 1)
        removeAllChildren()

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 16
        if campaign.finished && won {
            title.text = "CAMPAIGN DONE"
            title.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        } else if campaign.poolExhausted {
            title.text = "NO ONE LEFT"
            title.fontColor = SKColor(red: 0.86, green: 0.16, blue: 0.14, alpha: 1)
        } else {
            title.text = won ? "MISSION COMPLETE" : "ALL DEAD"
            title.fontColor = won
                ? SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
                : SKColor(red: 0.86, green: 0.16, blue: 0.14, alpha: 1)
        }
        title.position = CGPoint(x: 0, y: 142)
        addChild(title)

        let sub = SKLabelNode(fontNamed: "Menlo")
        sub.fontSize = 11
        sub.fontColor = SKColor(white: 0.6, alpha: 1)
        sub.text = campaign.finished ? "THE HILL IS FULL" : campaign.missionTitle
        sub.position = CGPoint(x: 0, y: 122)
        addChild(sub)

        addMountain()

        let living = Array(campaign.pool.prefix(8))
        let queue = SKLabelNode(fontNamed: "Menlo-Bold")
        queue.fontSize = 12
        queue.fontColor = SKColor(red: 0.22, green: 0.78, blue: 0.32, alpha: 1)
        queue.text = living.isEmpty ? "—" : living.map(\.name).joined(separator: "   ")
        queue.position = CGPoint(x: 0, y: -58)
        addChild(queue)

        addRecruitLine(living)

        let caption = SKLabelNode(fontNamed: "Menlo")
        caption.fontSize = 10
        caption.fontColor = SKColor(white: 0.45, alpha: 1)
        caption.text = "POOL \(campaign.pool.count)   HILL \(campaign.graves.count)"
        caption.position = CGPoint(x: 0, y: -118)
        addChild(caption)

        let again = SKLabelNode(fontNamed: "Menlo")
        again.fontSize = 11
        again.fontColor = SKColor(white: 0.7, alpha: 1)
        if campaignOver {
            again.text = "TAP FOR A NEW WAR"
        } else if won {
            again.text = "TAP FOR THE NEXT JOB"
        } else {
            again.text = "TAP TO SEND MORE"
        }
        again.position = CGPoint(x: 0, y: -146)
        addChild(again)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let next = campaignOver ? RosterScene(size: size, campaign: Campaign()) : RunFlow.next(size: size, campaign: campaign)
        view?.presentScene(next, transition: .fade(with: .black, duration: 0.3))
    }

    private func addMountain() {
        let hill = SKNode()
        hill.position = CGPoint(x: 0, y: -6)
        hill.setScale(0.88)
        hill.alpha = 0
        hill.zPosition = 1
        addChild(hill)
        hill.run(.group([.fadeIn(withDuration: 0.35), .scale(to: 1, duration: 0.4)]))

        let shade = SKShapeNode(ellipseOf: CGSize(width: 300, height: 22))
        shade.fillColor = SKColor(white: 0, alpha: 0.35)
        shade.strokeColor = .clear
        shade.position = CGPoint(x: 0, y: 4)
        shade.zPosition = 0
        hill.addChild(shade)

        hill.addChild(ridge(
            width: 268, height: 86, peak: -42,
            fill: SKColor(red: 0.16, green: 0.21, blue: 0.12, alpha: 1),
            y: 18, z: 1
        ))
        hill.addChild(ridge(
            width: 348, height: 118, peak: 14,
            fill: SKColor(red: 56 / 255, green: 71 / 255, blue: 46 / 255, alpha: 1),
            y: 0, z: 2
        ))

        let sun = SKShapeNode(path: slopeFace())
        sun.fillColor = SKColor(red: 0.28, green: 0.36, blue: 0.22, alpha: 0.55)
        sun.strokeColor = .clear
        sun.zPosition = 3
        hill.addChild(sun)

        for i in 0..<9 {
            let tuft = SKSpriteNode(texture: Art.tuft(variant: i, biome: "grass"))
            tuft.size = CGSize(width: 14, height: 14)
            let t = CGFloat(i) / 8
            tuft.position = CGPoint(x: -150 + t * 300, y: 10 + sin(t * .pi) * 46 + CGFloat(i % 3) * 4)
            tuft.zPosition = 4
            tuft.alpha = 0.85
            hill.addChild(tuft)
        }

        let graves = Array(campaign.graves.suffix(12))
        let cols = 6
        for (i, grave) in graves.enumerated() {
            let row = i / cols
            let col = i % cols
            let inRow = min(cols, graves.count - row * cols)
            let u = (CGFloat(col) + 0.5) / CGFloat(max(inRow, 1)) - 0.5
            let x = u * 220 + (row == 0 ? 0 : 12)
            let y = 22 + CGFloat(row) * 32 + (1 - abs(u) * 2) * 16

            let stone = SKSpriteNode(texture: Art.tombstone(rank: grave.rank))
            stone.size = CGSize(width: 16, height: 16)
            stone.position = CGPoint(x: x, y: y)
            stone.zPosition = 6 + CGFloat(2 - row)
            stone.alpha = 0
            hill.addChild(stone)
            stone.run(.sequence([
                .wait(forDuration: 0.28 + Double(i) * 0.07),
                .fadeIn(withDuration: 0.12)
            ]))

            let mark = SKLabelNode(fontNamed: "Menlo-Bold")
            mark.fontSize = 9
            mark.fontColor = SKColor(white: 0.9, alpha: 1)
            mark.text = grave.name
            mark.verticalAlignmentMode = .bottom
            mark.position = CGPoint(x: x, y: y + 9)
            mark.zPosition = stone.zPosition + 0.1
            mark.alpha = 0
            hill.addChild(mark)
            mark.run(.sequence([
                .wait(forDuration: 0.32 + Double(i) * 0.07),
                .fadeIn(withDuration: 0.12)
            ]))
        }
    }

    private func addRecruitLine(_ living: [Trooper]) {
        guard !living.isEmpty else { return }
        let ground = SKShapeNode(rectOf: CGSize(width: CGFloat(living.count) * 30 + 16, height: 6), cornerRadius: 2)
        ground.fillColor = SKColor(red: 0.12, green: 0.14, blue: 0.1, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: 0, y: -98)
        ground.zPosition = 2
        addChild(ground)

        let span = CGFloat(living.count - 1) * 28
        for (i, _) in living.enumerated() {
            let sprite = SKSpriteNode(texture: Art.infantry(
                player: true, group: 0, dead: false, facing: 0, walk: 0
            ))
            sprite.size = CGSize(width: 24, height: 24)
            sprite.zPosition = 3
            let destX = -span / 2 + CGFloat(i) * 28
            sprite.position = CGPoint(x: destX - 120, y: -88)
            addChild(sprite)
            sprite.run(.sequence([
                .wait(forDuration: 0.2 + Double(i) * 0.05),
                .moveTo(x: destX, duration: 0.35)
            ]))
            let frames = [0, 1, 0, 2].map {
                Art.infantry(player: true, group: 0, dead: false, facing: 0, walk: $0)
            }
            sprite.run(.sequence([
                .wait(forDuration: Double(i) * 0.08),
                .repeatForever(.animate(with: frames, timePerFrame: 0.16))
            ]))
        }
    }

    private func ridge(width: CGFloat, height: CGFloat, peak: CGFloat, fill: SKColor, y: CGFloat, z: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        let l = -width / 2
        let r = width / 2
        path.move(to: CGPoint(x: l, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: peak - width * 0.1, y: height * 0.7),
            control: CGPoint(x: l + width * 0.16, y: height * 0.16)
        )
        path.addQuadCurve(
            to: CGPoint(x: peak, y: height),
            control: CGPoint(x: peak - width * 0.05, y: height * 0.94)
        )
        path.addQuadCurve(
            to: CGPoint(x: peak + width * 0.24, y: height * 0.58),
            control: CGPoint(x: peak + width * 0.1, y: height * 0.9)
        )
        path.addQuadCurve(
            to: CGPoint(x: r, y: 0),
            control: CGPoint(x: r - width * 0.14, y: height * 0.2)
        )
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor = fill
        node.strokeColor = SKColor(white: 0.08, alpha: 0.7)
        node.lineWidth = 1
        node.position.y = y
        node.zPosition = z
        return node
    }

    private func slopeFace() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 14, y: 112))
        path.addQuadCurve(to: CGPoint(x: 96, y: 68), control: CGPoint(x: 46, y: 108))
        path.addQuadCurve(to: CGPoint(x: 168, y: 4), control: CGPoint(x: 140, y: 28))
        path.addLine(to: CGPoint(x: 40, y: 8))
        path.addQuadCurve(to: CGPoint(x: 14, y: 112), control: CGPoint(x: 28, y: 56))
        path.closeSubpath()
        return path
    }
}
