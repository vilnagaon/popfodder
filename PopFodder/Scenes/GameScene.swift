import SpriteKit
import UIKit

final class GameScene: SKScene {
    private let campaign: Campaign
    private let mission: Mission
    private let squad: [Trooper]
    let battle: Battle
    private let world = SKNode()
    private let cameraNode = SKCameraNode()
    private let hud = SKNode()
    private let nameStrip = SKLabelNode(fontNamed: "Menlo-Bold")
    private let holdStrip = SKLabelNode(fontNamed: "Menlo")
    private let hint = SKLabelNode(fontNamed: "Menlo")

    private let grenadeHit = SKShapeNode(rectOf: CGSize(width: 124, height: 36), cornerRadius: 6)
    private let rocketHit = SKShapeNode(rectOf: CGSize(width: 124, height: 36), cornerRadius: 6)
    private let jeepHit = SKShapeNode(rectOf: CGSize(width: 148, height: 44), cornerRadius: 6)
    private let grenadeButton = SKLabelNode(fontNamed: "Menlo-Bold")
    private let rocketButton = SKLabelNode(fontNamed: "Menlo-Bold")
    private let jeepButton = SKLabelNode(fontNamed: "Menlo-Bold")
    private let menuHit = SKShapeNode(rectOf: CGSize(width: 100, height: 36), cornerRadius: 6)
    private let menuButton = SKLabelNode(fontNamed: "Menlo-Bold")
    private let menuPanel = SKNode()
    private let menuDim = SKShapeNode()
    private let abortHit = SKShapeNode(rectOf: CGSize(width: 220, height: 40), cornerRadius: 6)
    private let abortButton = SKLabelNode(fontNamed: "Menlo-Bold")
    private let resumeHit = SKShapeNode(rectOf: CGSize(width: 220, height: 40), cornerRadius: 6)
    private let resumeButton = SKLabelNode(fontNamed: "Menlo-Bold")
    private var menuOpen = false

    private var bodies: [UUID: SKShapeNode] = [:]
    private var rings: [UUID: SKShapeNode] = [:]
    private var pickupNodes: [SKNode] = []
    private var jeepNode: SKSpriteNode?
    private var barracksNode: SKSpriteNode?
    private var waypointDots: [SKShapeNode] = []
    private var lastAlive = 0
    private var livingIDs: Set<UUID> = []
    private var lastTaken = 0
    private var wasInJeep = false
    private var panStart: CGPoint?
    private var isPanning = false
    private var lastTapTime: TimeInterval = 0
    private var lastTapId: UUID?
    private var cameraTarget: CGPoint?
    private var lastUpdate: TimeInterval = 0
    private var clock: TimeInterval = 0
    private var finished = false
    private var aiming = false
    private let aimRing = SKShapeNode()
    private let aimCrossH = SKShapeNode(rectOf: CGSize(width: 18, height: 2))
    private let aimCrossV = SKShapeNode(rectOf: CGSize(width: 2, height: 18))

    init(size: CGSize, campaign: Campaign, mission: Mission, squad: [Trooper]) {
        self.campaign = campaign
        self.mission = mission
        self.squad = squad
        self.battle = Battle(mission: mission, squad: squad)
        super.init(size: size)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        backgroundColor = biomeBackdrop()
        addChild(world)
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.addChild(hud)

        SFX.boot()
        aimRing.fillColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.12)
        aimRing.strokeColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.95)
        aimRing.lineWidth = 2
        aimRing.zPosition = 8
        aimRing.isHidden = true
        aimCrossH.fillColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        aimCrossH.strokeColor = .clear
        aimCrossH.zPosition = 8.1
        aimCrossV.fillColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        aimCrossV.strokeColor = .clear
        aimCrossV.zPosition = 8.1
        aimCrossH.isHidden = true
        aimCrossV.isHidden = true
        world.addChild(aimRing)
        world.addChild(aimCrossH)
        world.addChild(aimCrossV)
        menuButton.text = "MENU"
        abortButton.text = "ABORT MISSION"
        resumeButton.text = "RESUME"
        menuPanel.isHidden = true
        menuPanel.zPosition = 40
        hud.addChild(menuPanel)
        drawTiles()
        drawExtract()
        layoutHUD()
        syncSoldiers()
        lastAlive = battle.playerSoldiers.filter(\.alive).count
        livingIDs = Set(battle.playerSoldiers.filter(\.alive).map(\.id))
        if let spawn = mission.squad.first {
            cameraNode.position = CGPoint(x: spawn.x, y: spawn.y)
        }

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinch.cancelsTouchesInView = true
        view.gestureRecognizers?
            .compactMap { $0 as? UIPinchGestureRecognizer }
            .forEach { view.removeGestureRecognizer($0) }
        view.addGestureRecognizer(pinch)
    }

    override func didChangeSize(_ oldSize: CGSize) { layoutHUD() }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdate == 0 ? 1.0 / 60.0 : min(currentTime - lastUpdate, 0.05)
        lastUpdate = currentTime
        clock += dt
        battle.update(dt: dt)
        syncSoldiers()
        syncWorldProps()
        syncWaypoints()
        drawShots()
        drawBlasts()
        if !battle.shotLines.isEmpty {
            SFX.play("shot")
            Juice.haptic(.light)
        }
        if !battle.blasts.isEmpty {
            SFX.play("explode")
            Juice.haptic(.heavy)
            Juice.shake(cameraNode, amount: 11)
        }
        let liveNow = Set(battle.playerSoldiers.filter(\.alive).map(\.id))
        if liveNow.count < lastAlive {
            SFX.play("death")
            Juice.haptic(.medium)
            Juice.shake(cameraNode, amount: 5)
            for id in livingIDs.subtracting(liveNow) {
                if let body = bodies[id] {
                    Juice.puff(at: body.position, color: SKColor(white: 0.5, alpha: 1), in: world)
                    Juice.flash(body)
                }
            }
        }
        lastAlive = liveNow.count
        livingIDs = liveNow
        let taken = battle.pickups.filter(\.taken).count
        if taken > lastTaken {
            SFX.play("pickup")
            Juice.haptic(.light)
        }
        lastTaken = taken
        if battle.inJeep && !wasInJeep { SFX.play("jeep") }
        wasInJeep = battle.inJeep
        easeCamera(dt: dt)
        refreshHUD()
        if !finished, battle.outcome != .playing {
            finished = true
            let troops = battle.playerSoldiers
            let won = battle.outcome == .won
            SFX.play(won ? "win" : "lose")
            run(.sequence([
                .wait(forDuration: 0.8),
                .run { [weak self] in
                    guard let self else { return }
                    if won, !self.campaign.isLastPhase {
                        self.campaign.advancePhase(deployed: self.squad, survivors: troops, kills: self.battle.enemyKills)
                        let next = GameScene(
                            size: self.size,
                            campaign: self.campaign,
                            mission: self.campaign.currentMission,
                            squad: self.campaign.deploy()
                        )
                        self.view?.presentScene(next, transition: .fade(with: .black, duration: 0.35))
                    } else {
                        self.campaign.resolveMission(deployed: self.squad, survivors: troops, won: won, kills: self.battle.enemyKills)
                        let grave = GraveyardScene(
                            size: self.size,
                            campaign: self.campaign,
                            mission: self.mission,
                            deployed: self.squad,
                            survivors: troops,
                            won: won
                        )
                        self.view?.presentScene(grave, transition: .fade(with: .black, duration: 0.4))
                    }
                }
            ]))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view else { return }
        let hudPoint = touch.location(in: hud)
        if menuOpen || fat(menuHit.frame).contains(hudPoint) {
            panStart = nil
            isPanning = false
            aiming = false
            return
        }
        if fat(grenadeHit.frame).contains(hudPoint)
            || fat(rocketHit.frame).contains(hudPoint)
            || (battle.inJeep && fat(jeepHit.frame).contains(hudPoint)) {
            panStart = touch.location(in: view)
            isPanning = false
            aiming = false
            return
        }
        if battle.armed != .none {
            aiming = true
            isPanning = false
            panStart = nil
            showAim(at: touch.location(in: world))
            return
        }
        panStart = touch.location(in: view)
        isPanning = false
        aiming = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view else { return }
        if aiming {
            showAim(at: touch.location(in: world))
            return
        }
        guard let start = panStart else { return }
        let loc = touch.location(in: view)
        if hypot(loc.x - start.x, loc.y - start.y) > BattleConfig.panSlop { isPanning = true }
        guard isPanning else { return }
        cameraTarget = nil
        let prev = touch.previousLocation(in: view)
        cameraNode.position.x -= (loc.x - prev.x) * cameraNode.xScale
        cameraNode.position.y += (loc.y - prev.y) * cameraNode.yScale
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            panStart = nil
            isPanning = false
            if !aiming { hideAim() }
        }
        guard let touch = touches.first else { return }
        let hudPoint = touch.location(in: hud)
        if menuOpen {
            if fat(abortHit.frame).contains(touch.location(in: menuPanel)) {
                abortMission()
                return
            }
            setMenuOpen(false)
            return
        }
        if fat(menuHit.frame).contains(hudPoint) {
            aiming = false
            hideAim()
            setMenuOpen(true)
            return
        }
        if fat(grenadeHit.frame).contains(hudPoint) {
            aiming = false
            battle.toggleArm(.grenade)
            if battle.armed != .none, let from = battle.throwerPosition() {
                showAim(at: CGPoint(x: from.x, y: from.y + 72))
            } else {
                hideAim()
            }
            refreshHUD()
            return
        }
        if fat(rocketHit.frame).contains(hudPoint) {
            aiming = false
            battle.toggleArm(.rocket)
            if battle.armed != .none, let from = battle.throwerPosition() {
                showAim(at: CGPoint(x: from.x, y: from.y + 72))
            } else {
                hideAim()
            }
            refreshHUD()
            return
        }
        if battle.inJeep, fat(jeepHit.frame).contains(hudPoint) {
            battle.exitJeep()
            return
        }
        if aiming {
            aiming = false
            hideAim()
            lob(at: touch.location(in: world))
            return
        }
        guard !isPanning else { return }
        handleTap(at: touch.location(in: world))
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        panStart = nil
        isPanning = false
        aiming = false
        hideAim()
    }

    private func handleTap(at point: CGPoint) {
        if let soldier = battle.soldier(near: point, faction: .player) {
            if soldier.groupId != battle.activeGroupId {
                battle.tapSoldier(soldier.id)
                lastTapId = nil
                lastTapTime = 0
                return
            }
            let doubleTap = soldier.id == lastTapId && (battle.now - lastTapTime) <= BattleConfig.doubleTap
            lastTapId = soldier.id
            lastTapTime = battle.now
            if doubleTap {
                battle.splitSoldier(soldier.id)
            } else if battle.activeGroupMoving {
                battle.cancelPath()
            }
            return
        }
        lastTapId = nil
        battle.orderMove(to: point)
        cameraTarget = point
        Juice.puff(at: point, color: SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.7), in: world)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .changed else { return }
        cameraNode.setScale(min(2.2, max(0.55, cameraNode.xScale / gesture.scale)))
        gesture.scale = 1
    }

    private func showAim(at point: CGPoint) {
        let grenade = battle.armed == .grenade
        let inRange = battle.inTossRange(point)
        let brass = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        let orange = SKColor(red: 0.95, green: 0.45, blue: 0.08, alpha: 1)
        let theirs = SKColor(red: 0.86, green: 0.16, blue: 0.14, alpha: 1)
        let accent = inRange ? (grenade ? brass : orange) : theirs
        aimRing.path = CGPath(ellipseIn: CGRect(
            x: -battle.tossRadius(),
            y: -battle.tossRadius(),
            width: battle.tossRadius() * 2,
            height: battle.tossRadius() * 2
        ), transform: nil)
        aimRing.position = point
        aimRing.fillColor = accent.withAlphaComponent(0.12)
        aimRing.strokeColor = accent
        aimRing.isHidden = false
        aimCrossH.position = point
        aimCrossV.position = point
        aimCrossH.fillColor = accent
        aimCrossV.fillColor = accent
        aimCrossH.isHidden = false
        aimCrossV.isHidden = false
    }

    private func hideAim() {
        aimRing.isHidden = true
        aimCrossH.isHidden = true
        aimCrossV.isHidden = true
    }

    private func lob(at point: CGPoint) {
        guard let toss = battle.prepareToss(at: point) else { return }
        cameraTarget = toss.to
        let ball = SKSpriteNode(texture: Art.nade(grenade: toss.grenade))
        ball.size = CGSize(width: toss.grenade ? 12 : 10, height: toss.grenade ? 12 : 10)
        ball.zPosition = 9
        ball.position = toss.from
        let shadow = SKShapeNode(circleOfRadius: toss.grenade ? 4 : 3)
        shadow.fillColor = SKColor(white: 0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.zPosition = 4
        shadow.position = toss.from
        world.addChild(shadow)
        world.addChild(ball)
        let dur: TimeInterval = toss.grenade ? 0.58 : 0.36
        let peak: CGFloat = toss.grenade ? 58 : 26
        let bouncePeak: CGFloat = toss.grenade ? 16 : 0
        let action = SKAction.customAction(withDuration: dur) { _, elapsed in
            let u = max(0, min(1, CGFloat(elapsed / dur)))
            let ground = CGPoint(
                x: toss.from.x + (toss.to.x - toss.from.x) * u,
                y: toss.from.y + (toss.to.y - toss.from.y) * u
            )
            let hop = 4 * u * (1 - u) * peak
            let b: CGFloat
            if toss.grenade, u > 0.72 {
                let t = (u - 0.72) / 0.28
                b = 4 * t * (1 - t) * bouncePeak
            } else {
                b = 0
            }
            let h = hop + b
            shadow.position = ground
            shadow.setScale(max(0.35, 1 - h / (peak + 8) * 0.55))
            ball.position = CGPoint(x: ground.x, y: ground.y + h)
            ball.setScale(1 + h / peak * 0.22)
            ball.zRotation = u * .pi * (toss.grenade ? 2.2 : 1.1)
        }
        ball.run(.sequence([
            action,
            .run { [weak self] in
                shadow.removeFromParent()
                ball.removeFromParent()
                guard let self else { return }
                self.battle.detonate(toss)
                self.playBlast(at: toss.to, radius: toss.radius)
                SFX.play("explode")
                Juice.haptic(.heavy)
                Juice.shake(self.cameraNode, amount: 11)
            }
        ]))
    }

    private func playBlast(at point: CGPoint, radius: CGFloat) {
        let grenade = radius >= 50
        let fill = grenade
            ? SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.28)
            : SKColor(red: 0.95, green: 0.45, blue: 0.08, alpha: 0.32)
        let stroke = grenade
            ? SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            : SKColor(red: 0.95, green: 0.45, blue: 0.08, alpha: 1)
        let boom = SKShapeNode(circleOfRadius: radius)
        boom.position = point
        boom.fillColor = fill
        boom.strokeColor = stroke
        boom.lineWidth = 2.5
        boom.zPosition = 7
        world.addChild(boom)
        boom.run(.sequence([
            .wait(forDuration: 0.08),
            .fadeOut(withDuration: 0.22),
            .removeFromParent()
        ]))
        Juice.puff(at: point, color: stroke, in: world)
    }

    private func drawTiles() {
        let fill: Mission.Tile
        switch mission.biome {
        case "dirt": fill = .dirt
        case "snow": fill = .ice
        default: fill = .grass
        }
        let back = SKSpriteNode(color: tileColor(fill), size: mission.mapSize)
        back.zPosition = 0
        world.addChild(back)
        for r in 0..<mission.rows {
            for c in 0..<mission.columns {
                let t = mission.tile(column: c, rowFromTop: r)
                guard t != fill else { continue }
                let rect = mission.tileRect(column: c, rowFromTop: r)
                let node: SKSpriteNode
                switch t {
                case .wall:
                    node = SKSpriteNode(texture: Art.wall())
                case .sink:
                    node = SKSpriteNode(texture: Art.sink())
                case .bush:
                    node = SKSpriteNode(texture: Art.bush())
                default:
                    node = SKSpriteNode(color: tileColor(t), size: rect.size)
                }
                node.size = rect.size
                node.position = CGPoint(x: rect.midX, y: rect.midY)
                node.zPosition = t == .bush ? 0.2 : 0.1
                world.addChild(node)
            }
        }
        scatterTufts()
    }

    /// Mood only. Hash of tile coords, never on wall/sink/bush, under soldiers.
    private func scatterTufts() {
        let biome = mission.biome ?? "grass"
        let every = biome == "snow" ? 7 : 4
        for r in 0..<mission.rows {
            for c in 0..<mission.columns {
                let t = mission.tile(column: c, rowFromTop: r)
                if t == .wall || t == .sink || t == .bush { continue }
                let h = c * 73 + r * 19
                if h % every != 0 { continue }
                let rect = mission.tileRect(column: c, rowFromTop: r)
                let jitter = CGFloat(h % 11) - 5
                let node = SKSpriteNode(texture: Art.tuft(variant: h % 3, biome: biome))
                node.size = CGSize(width: 12, height: 12)
                node.position = CGPoint(x: rect.midX + jitter, y: rect.midY - jitter * 0.4)
                node.zPosition = 0.12
                world.addChild(node)
            }
        }
    }

    private func drawExtract() {
        guard let extract = battle.extract else { return }
        let zone = SKShapeNode(circleOfRadius: BattleConfig.extractRadius)
        zone.position = extract
        zone.fillColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.12)
        zone.strokeColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.8)
        zone.lineWidth = 2
        zone.zPosition = 1
        world.addChild(zone)
        let mark = SKLabelNode(fontNamed: "Menlo-Bold")
        mark.text = "HOME"
        mark.fontSize = 9
        mark.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        mark.verticalAlignmentMode = .center
        zone.addChild(mark)
    }

    private func biomeBackdrop() -> SKColor {
        switch mission.biome {
        case "dirt": return SKColor(red: 0.18, green: 0.14, blue: 0.08, alpha: 1)
        case "snow": return SKColor(red: 0.14, green: 0.16, blue: 0.18, alpha: 1)
        default: return SKColor(red: 0.10, green: 0.14, blue: 0.08, alpha: 1)
        }
    }

    private func tileColor(_ tile: Mission.Tile) -> SKColor {
        let dirt = mission.biome == "dirt"
        let snow = mission.biome == "snow"
        switch tile {
        case .grass:
            if snow { return SKColor(red: 0.72, green: 0.78, blue: 0.82, alpha: 1) }
            if dirt { return SKColor(red: 0.42, green: 0.32, blue: 0.18, alpha: 1) }
            return SKColor(red: 0.20, green: 0.36, blue: 0.16, alpha: 1)
        case .dirt:
            if snow { return SKColor(red: 0.62, green: 0.66, blue: 0.70, alpha: 1) }
            return SKColor(red: 0.36, green: 0.28, blue: 0.16, alpha: 1)
        case .ice: return SKColor(red: 0.78, green: 0.84, blue: 0.88, alpha: 1)
        case .sink: return SKColor(red: 0.12, green: 0.08, blue: 0.16, alpha: 1)
        case .bush: return SKColor(red: 0.12, green: 0.28, blue: 0.12, alpha: 1)
        case .wall: return SKColor(red: 0.16, green: 0.16, blue: 0.18, alpha: 1)
        }
    }

    private func syncSoldiers() {
        for soldier in battle.soldiers {
            let body = bodies[soldier.id] ?? makeBody(for: soldier)
            let ring = rings[soldier.id] ?? makeRing(for: soldier)
            bodies[soldier.id] = body
            rings[soldier.id] = ring
            body.isHidden = soldier.inVehicle
            body.position = soldier.position
            ring.position = soldier.position
            body.zRotation = 0
            body.fillColor = .clear
            body.strokeColor = .clear
            if let sprite = body.childNode(withName: "sprite") as? SKSpriteNode {
                switch soldier.kind {
                case .infantry:
                    sprite.texture = Art.infantry(
                        player: soldier.faction == .player,
                        group: soldier.groupId,
                        dead: !soldier.alive,
                        facing: soldier.facing,
                        walk: walkFrame(for: soldier)
                    )
                case .vip:
                    sprite.texture = Art.vip(
                        dead: !soldier.alive,
                        facing: soldier.facing,
                        walk: walkFrame(for: soldier)
                    )
                case .turret:
                    sprite.texture = Art.turret()
                }
            }
            let isActive = soldier.controllable && soldier.alive && soldier.groupId == battle.activeGroupId
            let isHold = soldier.faction == .player && soldier.kind == .infantry && soldier.alive && soldier.groupId != battle.activeGroupId && !soldier.inVehicle
            ring.isHidden = (!isActive && !isHold) || soldier.inVehicle
            ring.strokeColor = isActive ? SKColor(red: 1, green: 0.84, blue: 0, alpha: 1) : SKColor(white: 0.85, alpha: 1)
            ring.lineWidth = isActive ? 2.5 : 1.2
            ring.zPosition = 4
            if isActive { Juice.pulseRing(ring) } else { ring.removeAction(forKey: "pulse"); ring.setScale(1) }
            body.zPosition = soldier.alive ? 3 : 2
            body.alpha = soldier.alive ? 1 : 0.85
        }
    }

    private func makeBody(for soldier: Soldier) -> SKShapeNode {
        let node: SKShapeNode
        let tex: SKTexture
        switch soldier.kind {
        case .turret:
            node = SKShapeNode(rectOf: CGSize(width: 30, height: 30), cornerRadius: 3)
            tex = Art.turret()
        case .vip:
            node = SKShapeNode(circleOfRadius: 11)
            tex = Art.vip(
                dead: !soldier.alive,
                facing: soldier.facing,
                walk: walkFrame(for: soldier)
            )
        case .infantry:
            node = SKShapeNode(circleOfRadius: BattleConfig.soldierRadius)
            tex = Art.infantry(
                player: soldier.faction == .player,
                group: soldier.groupId,
                dead: !soldier.alive,
                facing: soldier.facing,
                walk: walkFrame(for: soldier)
            )
        }
        node.fillColor = .clear
        node.strokeColor = .clear
        node.lineWidth = 0
        let sprite = SKSpriteNode(texture: tex)
        let side: CGFloat = soldier.kind == .turret ? 40 : 32
        sprite.size = CGSize(width: side, height: side)
        sprite.name = "sprite"
        node.addChild(sprite)
        world.addChild(node)
        return node
    }

    /// 0 idle, 1/2 stride. ~8 fps while a path remains.
    private func walkFrame(for soldier: Soldier) -> Int {
        guard soldier.alive, soldier.kind != .turret, !soldier.path.isEmpty else { return 0 }
        return Int(clock / 0.12) % 2 + 1
    }

    private func makeRing(for soldier: Soldier) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: soldier.radius + 8)
        node.fillColor = .clear
        world.addChild(node)
        return node
    }

    private func fill(for soldier: Soldier) -> SKColor {
        if !soldier.alive { return SKColor(white: 0.28, alpha: 1) }
        if soldier.kind == .turret { return SKColor(red: 0.45, green: 0.10, blue: 0.10, alpha: 1) }
        if soldier.kind == .vip { return SKColor(red: 0.95, green: 0.85, blue: 0.35, alpha: 1) }
        switch soldier.faction {
        case .player:
            return soldier.groupId == 0
                ? SKColor(red: 0.22, green: 0.78, blue: 0.32, alpha: 1)
                : SKColor(red: 0.15, green: 0.62, blue: 0.72, alpha: 1)
        case .enemy:
            return SKColor(red: 0.86, green: 0.16, blue: 0.14, alpha: 1)
        }
    }

    private func syncWorldProps() {
        if pickupNodes.isEmpty {
            for pickup in battle.pickups {
                let crate = SKSpriteNode(texture: Art.crate(grenade: pickup.grenade))
                crate.size = CGSize(width: 24, height: 24)
                crate.zPosition = 3
                world.addChild(crate)
                pickupNodes.append(crate)
            }
        }
        for (i, pickup) in battle.pickups.enumerated() where i < pickupNodes.count {
            pickupNodes[i].position = pickup.position
            pickupNodes[i].isHidden = pickup.taken
        }

        if jeepNode == nil, battle.jeep != nil {
            let node = SKSpriteNode(texture: Art.jeep(occupied: false, dead: false))
            node.size = CGSize(width: 56, height: 40)
            node.zPosition = 3.5
            world.addChild(node)
            jeepNode = node
        }
        if let jeep = battle.jeep, let node = jeepNode {
            node.position = jeep.position
            node.zRotation = jeep.facing
            node.texture = Art.jeep(occupied: jeep.occupied, dead: !jeep.alive)
            node.alpha = jeep.alive ? 1 : 0.7
        }

        if barracksNode == nil, let barracks = battle.barracks {
            let node = SKSpriteNode(texture: Art.barracks(alive: barracks.alive))
            node.size = CGSize(width: 48, height: 48)
            node.position = barracks.position
            node.zPosition = 2.5
            world.addChild(node)
            barracksNode = node
        }
        if let barracks = battle.barracks, let node = barracksNode {
            node.texture = Art.barracks(alive: barracks.alive)
            node.alpha = barracks.alive ? 1 : 0.6
        }
    }

    private func syncWaypoints() {
        let points = battle.activeWaypoints
        while waypointDots.count < points.count {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.55)
            dot.strokeColor = .clear
            dot.zPosition = 2
            world.addChild(dot)
            waypointDots.append(dot)
        }
        for (i, dot) in waypointDots.enumerated() {
            if i < points.count {
                dot.isHidden = false
                dot.position = points[i]
            } else {
                dot.isHidden = true
            }
        }
    }

    private func drawShots() {
        for (from, to, faction) in battle.shotLines {
            let ivory = SKColor(red: 0.95, green: 0.94, blue: 0.90, alpha: 1)
            let theirs = SKColor(red: 0.86, green: 0.16, blue: 0.14, alpha: 1)
            let color = faction == .player ? ivory : theirs
            let path = CGMutablePath()
            path.move(to: from)
            path.addLine(to: to)
            let line = SKShapeNode(path: path)
            line.strokeColor = color
            line.lineWidth = 1.25
            line.lineCap = .round
            line.zPosition = 6
            world.addChild(line)
            line.run(.sequence([.fadeOut(withDuration: 0.10), .removeFromParent()]))
            let spark = SKShapeNode(circleOfRadius: 2)
            spark.fillColor = color
            spark.strokeColor = .clear
            spark.position = from
            spark.zPosition = 7
            world.addChild(spark)
            spark.run(.sequence([
                .group([.scale(to: 1.8, duration: 0.06), .fadeOut(withDuration: 0.08)]),
                .removeFromParent()
            ]))
        }
    }

    private func drawBlasts() {
        for (point, radius) in battle.blasts {
            let grenade = radius >= 50
            let fill = grenade
                ? SKColor(red: 1, green: 0.84, blue: 0, alpha: 0.28)
                : SKColor(red: 0.95, green: 0.45, blue: 0.08, alpha: 0.32)
            let stroke = grenade
                ? SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
                : SKColor(red: 0.95, green: 0.45, blue: 0.08, alpha: 1)
            // Full kill radius on the first frame — the disc is the tell, not a grow-in.
            let boom = SKShapeNode(circleOfRadius: radius)
            boom.position = point
            boom.fillColor = fill
            boom.strokeColor = stroke
            boom.lineWidth = 2.5
            boom.zPosition = 7
            world.addChild(boom)
            boom.run(.sequence([
                .wait(forDuration: 0.08),
                .fadeOut(withDuration: 0.22),
                .removeFromParent()
            ]))
            Juice.puff(at: point, color: stroke, in: world)
        }
    }

    private func easeCamera(dt: TimeInterval) {
        guard let target = cameraTarget else { return }
        let pos = cameraNode.position
        let dx = target.x - pos.x
        let dy = target.y - pos.y
        if hypot(dx, dy) < 4 {
            cameraNode.position = target
            cameraTarget = nil
            return
        }
        let t = 1 - pow(0.08, dt * 60)
        cameraNode.position = CGPoint(x: pos.x + dx * t, y: pos.y + dy * t)
    }

    private func layoutHUD() {
        let halfH = size.height / 2
        let halfW = size.width / 2
        nameStrip.fontSize = 14
        nameStrip.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        nameStrip.horizontalAlignmentMode = .center
        nameStrip.verticalAlignmentMode = .top
        nameStrip.position = CGPoint(x: 0, y: halfH - 10)
        nameStrip.zPosition = 20

        holdStrip.fontSize = 11
        holdStrip.fontColor = SKColor(white: 0.7, alpha: 1)
        holdStrip.horizontalAlignmentMode = .center
        holdStrip.verticalAlignmentMode = .top
        holdStrip.position = CGPoint(x: 0, y: halfH - 28)
        holdStrip.zPosition = 20

        hint.fontSize = 9
        hint.fontColor = SKColor(white: 0.45, alpha: 1)
        hint.horizontalAlignmentMode = .center
        hint.verticalAlignmentMode = .bottom
        hint.position = CGPoint(x: 0, y: -halfH + 10)
        hint.zPosition = 20

        placeButton(menuHit, menuButton, at: CGPoint(x: -halfW + 62, y: halfH - 28))
        placeButton(grenadeHit, grenadeButton, at: CGPoint(x: halfW - 78, y: halfH - 28))
        placeButton(rocketHit, rocketButton, at: CGPoint(x: halfW - 78, y: halfH - 70))
        placeButton(jeepHit, jeepButton, at: CGPoint(x: halfW - 90, y: -halfH + 36))

        menuDim.path = CGPath(rect: CGRect(x: -halfW, y: -halfH, width: size.width, height: size.height), transform: nil)
        menuDim.fillColor = SKColor(white: 0, alpha: 0.62)
        menuDim.strokeColor = .clear
        menuDim.zPosition = 0
        placeButton(abortHit, abortButton, at: CGPoint(x: 0, y: 16))
        placeButton(resumeHit, resumeButton, at: CGPoint(x: 0, y: -36))
        abortHit.zPosition = 1
        abortButton.zPosition = 2
        resumeHit.zPosition = 1
        resumeButton.zPosition = 2
        abortButton.fontSize = 13
        resumeButton.fontSize = 13

        if nameStrip.parent == nil {
            hud.addChild(nameStrip)
            hud.addChild(holdStrip)
            hud.addChild(hint)
            hud.addChild(menuHit)
            hud.addChild(menuButton)
            hud.addChild(grenadeHit)
            hud.addChild(grenadeButton)
            hud.addChild(rocketHit)
            hud.addChild(rocketButton)
            hud.addChild(jeepHit)
            hud.addChild(jeepButton)
            menuPanel.addChild(menuDim)
            let title = SKLabelNode(fontNamed: "Menlo-Bold")
            title.text = "MENU"
            title.fontSize = 16
            title.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            title.position = CGPoint(x: 0, y: 64)
            title.zPosition = 2
            menuPanel.addChild(title)
            menuPanel.addChild(abortHit)
            menuPanel.addChild(abortButton)
            menuPanel.addChild(resumeHit)
            menuPanel.addChild(resumeButton)
        }
    }

    private func setMenuOpen(_ open: Bool) {
        menuOpen = open
        menuPanel.isHidden = !open
        isPaused = open
    }

    private func abortMission() {
        finished = true
        isPaused = false
        campaign.resolveMission(deployed: squad, survivors: battle.playerSoldiers, won: false, kills: battle.enemyKills)
        view?.presentScene(
            RosterScene(size: size, campaign: campaign),
            transition: .fade(with: SKColor(white: 0.05, alpha: 1), duration: 0.3)
        )
    }

    private func placeButton(_ hit: SKShapeNode, _ label: SKLabelNode, at point: CGPoint) {
        hit.fillColor = SKColor(white: 0.12, alpha: 0.85)
        hit.strokeColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        hit.lineWidth = 1
        hit.position = point
        hit.zPosition = 19
        label.fontSize = 10
        label.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = point
        label.zPosition = 20
    }

    private func fat(_ rect: CGRect) -> CGRect {
        rect.insetBy(dx: -12, dy: -10)
    }

    private func refreshHUD() {
        let names = battle.activeNames
        nameStrip.text = names.isEmpty ? (battle.inJeep ? "JEEP" : "—") : names.joined(separator: "   ")
        let holding = battle.holdingNames
        holdStrip.text = holding.isEmpty ? "" : "HOLD  " + holding.joined(separator: "   ")
        grenadeButton.text = battle.armed == .grenade ? "THROW G" : "G  \(battle.grenades)"
        rocketButton.text = battle.armed == .rocket ? "THROW R" : "R  \(battle.rockets)"
        jeepButton.text = battle.inJeep ? "EXIT JEEP" : " "
        jeepHit.isHidden = !battle.inJeep
        jeepButton.isHidden = !battle.inJeep
        if battle.armed == .grenade {
            hint.text = "TAP A TARGET  ·  BLAST HITS EVERYONE"
        } else if battle.armed == .rocket {
            hint.text = "ROCKET KILLS THE JEEP  ·  TAP A TARGET"
        } else if battle.inJeep {
            hint.text = "TAP GROUND TO DRIVE  ·  EXIT TO BAIL"
        } else {
            hint.text = "MOVE  ·  QUEUE  ·  DOUBLE-TAP SPLIT  ·  WALK INTO JEEP"
        }
    }
}
