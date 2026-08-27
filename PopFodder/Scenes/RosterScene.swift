import SpriteKit

/// v1.1: the player picks the squad instead of the pool auto-filling it.
/// Mid-mission phases (a held squad from advancePhase) skip picking — that
/// squad is already committed for this run.
final class RosterScene: SKScene {
    private let campaign: Campaign
    private let mission: Mission
    private let choosing: Bool
    private let heldSquad: [Trooper]
    private let requiredCount: Int
    // ponytail: first 8 of the pool only, no scroll. Add paging when pool
    // browsing (not just picking) becomes a thing worth designing for.
    private let displayPool: [Trooper]
    private var selectedIDs: [UUID] = []

    private var poolNodes: [(trooper: Trooper, label: SKLabelNode)] = []
    private let statusLabel = SKLabelNode(fontNamed: "Menlo")
    private let deployLabel = SKLabelNode(fontNamed: "Menlo")

    init(size: CGSize, campaign: Campaign) {
        self.campaign = campaign
        self.mission = campaign.currentMission
        if let held = campaign.heldSquad, !held.isEmpty {
            heldSquad = held
            choosing = false
            requiredCount = held.count
            displayPool = []
        } else {
            heldSquad = []
            choosing = true
            requiredCount = min(4, campaign.pool.count)
            displayPool = Array(campaign.pool.prefix(8))
        }
        super.init(size: size)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.05, alpha: 1)
        removeAllChildren()
        poolNodes = []

        addLabel("POPFODDER", font: "Menlo-Bold", size: 22, color: SKColor(red: 1, green: 0.84, blue: 0, alpha: 1), y: 120)
        var job = "MISSION \(campaign.missionNumber) / \(campaign.missionCount)"
        if campaign.phaseCount > 1 { job += "  ·  PHASE \(campaign.phaseNumber)/\(campaign.phaseCount)" }
        addLabel(job, font: "Menlo", size: 11, color: SKColor(white: 0.55, alpha: 1), y: 96)
        addLabel(campaign.missionTitle, font: "Menlo-Bold", size: 16, color: .white, y: 72)
        addLabel(mission.objectiveLine, font: "Menlo", size: 12, color: SKColor(red: 0.86, green: 0.16, blue: 0.14, alpha: 1), y: 48)
        addLabel(mission.blurb ?? "", font: "Menlo", size: 10, color: SKColor(white: 0.55, alpha: 1), y: 28)

        if choosing {
            let columns: CGFloat = 4
            let colWidth: CGFloat = 180
            let startX = -colWidth * (columns - 1) / 2
            for (i, trooper) in displayPool.enumerated() {
                let row = i / Int(columns)
                let col = i % Int(columns)
                let label = SKLabelNode(fontNamed: "Menlo-Bold")
                label.fontSize = 13
                label.horizontalAlignmentMode = .center
                label.position = CGPoint(x: startX + colWidth * CGFloat(col), y: -6 - CGFloat(row) * 26)
                addChild(label)
                poolNodes.append((trooper, label))
            }
            statusLabel.fontSize = 10
            statusLabel.fontColor = SKColor(white: 0.45, alpha: 1)
            statusLabel.position = CGPoint(x: 0, y: -66)
            statusLabel.horizontalAlignmentMode = .center
            addChild(statusLabel)
        } else {
            let names = heldSquad.map { "\($0.rankName) \($0.name)" }.joined(separator: "   ")
            addLabel(names, font: "Menlo-Bold", size: 13, color: SKColor(red: 0.22, green: 0.78, blue: 0.32, alpha: 1), y: -16)
            addLabel("POOL \(campaign.pool.count)   GRAVES \(campaign.graves.count)", font: "Menlo", size: 10, color: SKColor(white: 0.45, alpha: 1), y: -42)
        }

        deployLabel.fontSize = 12
        deployLabel.position = CGPoint(x: 0, y: -88)
        deployLabel.horizontalAlignmentMode = .center
        addChild(deployLabel)

        addLabel("SOURCE / GPL", font: "Menlo", size: 9, color: SKColor(white: 0.4, alpha: 1), y: -118)

        refreshPickUI()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        if loc.y < -104 {
            view?.presentScene(AboutScene(size: size, campaign: campaign), transition: .fade(with: .black, duration: 0.2))
            return
        }
        if choosing {
            for node in poolNodes where node.label.frame.insetBy(dx: -14, dy: -10).contains(loc) {
                toggle(node.trooper.id)
                return
            }
            guard selectedIDs.count == requiredCount else { return }
        }
        let squad = choosing ? displayPool.filter { selectedIDs.contains($0.id) } : heldSquad
        let game = GameScene(size: size, campaign: campaign, mission: mission, squad: squad)
        view?.presentScene(game, transition: .fade(with: .black, duration: 0.25))
    }

    private func toggle(_ id: UUID) {
        if let i = selectedIDs.firstIndex(of: id) {
            selectedIDs.remove(at: i)
        } else if selectedIDs.count < requiredCount {
            selectedIDs.append(id)
        }
        refreshPickUI()
    }

    private func refreshPickUI() {
        let selected = SKColor(red: 0.22, green: 0.78, blue: 0.32, alpha: 1)
        let unselected = SKColor(white: 0.5, alpha: 1)
        for node in poolNodes {
            let isOn = selectedIDs.contains(node.trooper.id)
            node.label.text = "\(isOn ? "▸" : " ")\(node.trooper.rankName) \(node.trooper.name)"
            node.label.fontColor = isOn ? selected : unselected
        }
        let ready = !choosing || selectedIDs.count == requiredCount
        if choosing {
            statusLabel.text = "PICK \(requiredCount)   ·   \(selectedIDs.count)/\(requiredCount) SELECTED"
        }
        deployLabel.text = ready ? "TAP TO DEPLOY" : "PICK \(requiredCount - selectedIDs.count) MORE"
        deployLabel.fontColor = ready ? SKColor(white: 0.7, alpha: 1) : SKColor(white: 0.35, alpha: 1)
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
