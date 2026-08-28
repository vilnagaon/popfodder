import CoreGraphics
import Foundation

final class Battle {
    let mission: Mission
    private let pathfinder: Pathfinder
    private(set) var soldiers: [Soldier]
    private(set) var blockers: [CGRect]
    private(set) var activeGroupId = 0
    private(set) var shotLines: [(CGPoint, CGPoint, Faction)] = []
    private(set) var blasts: [(CGPoint, CGFloat)] = []
    private(set) var now: TimeInterval = 0
    private(set) var groupGrenades = [0, 0]
    private(set) var groupRockets = [0, 0]
    private(set) var armed: ArmedWeapon = .none
    private(set) var pickups: [Pickup] = []
    private(set) var jeep: Jeep?
    private(set) var barracks: Barracks?
    private(set) var extract: CGPoint?
    private(set) var outcome: Outcome = .playing

    var enemyKills: Int {
        soldiers.filter { $0.faction == .enemy && $0.kind == .infantry && !$0.alive }.count
    }

    private var mergeSuppressedUntil: TimeInterval = 0
    private var jeepBailUntil: TimeInterval = 0
    private var nextEnemyRifle: TimeInterval = 0
    private var rng: UInt64 = 0xC0FFEE
    private let aggression: CGFloat

    init(mission: Mission, squad: [Trooper]) {
        self.mission = mission
        pathfinder = Pathfinder(mission: mission)
        blockers = mission.wallRects
        aggression = CGFloat(mission.aggression ?? 5)
        rng = 0xC0FFEE ^ UInt64(truncatingIfNeeded: mission.id.hashValue)
        groupGrenades[0] = mission.grenadeLoadout ?? 0
        groupRockets[0] = mission.rocketLoadout ?? 0
        pickups = (mission.grenades ?? []).map { Pickup(position: CGPoint(x: $0.x, y: $0.y), grenade: true, taken: false) }
            + (mission.rockets ?? []).map { Pickup(position: CGPoint(x: $0.x, y: $0.y), grenade: false, taken: false) }
        if let j = mission.jeep {
            jeep = Jeep(position: CGPoint(x: j.x, y: j.y), alive: true, facing: .pi / 2, occupants: [], path: [], fireCooldown: 0)
        }
        if let b = mission.barracks {
            barracks = Barracks(position: CGPoint(x: b.x, y: b.y), alive: true, spawnTimer: BattleConfig.barracksPeriod)
        }
        extract = mission.extract.map { CGPoint(x: $0.x, y: $0.y) }

        soldiers = Self.makeSquad(mission, squad)
        soldiers += Self.makeEnemies(mission)
        if let turret = mission.turret {
            soldiers.append(Self.makeTurret(turret))
        }
        if let vip = mission.vip {
            soldiers.append(Self.makeVIP(vip))
        }
    }

    var grenades: Int { groupGrenades[safe: activeGroupId] ?? 0 }
    var rockets: Int { groupRockets[safe: activeGroupId] ?? 0 }

    var activeNames: [String] {
        soldiers.filter { $0.controllable && $0.alive && $0.groupId == activeGroupId }.map(\.name)
    }

    var holdingNames: [String] {
        soldiers.filter { $0.controllable && $0.alive && $0.groupId != activeGroupId }.map(\.name)
    }

    var playerSoldiers: [Soldier] {
        soldiers.filter { $0.faction == .player && $0.kind == .infantry }
    }

    var inJeep: Bool { jeep?.occupied == true }

    var activeGroupMoving: Bool {
        if let jeep, jeep.occupied, !jeep.path.isEmpty { return true }
        return soldiers.contains { $0.controllable && $0.alive && $0.groupId == activeGroupId && !$0.path.isEmpty }
    }

    var activeWaypoints: [CGPoint] {
        if let jeep, jeep.occupied { return jeep.path }
        return soldiers.first { $0.controllable && $0.alive && $0.groupId == activeGroupId }?.path ?? []
    }

    func soldier(near point: CGPoint, faction: Faction) -> Soldier? {
        soldiers
            .filter { $0.alive && $0.faction == faction && $0.kind == .infantry && !$0.inVehicle }
            .compactMap { s -> (Soldier, CGFloat)? in
                let d = hypot(s.position.x - point.x, s.position.y - point.y)
                return d <= BattleConfig.selectRadius ? (s, d) : nil
            }
            .min { $0.1 < $1.1 }?
            .0
    }

    func tapSoldier(_ id: UUID) {
        guard let s = soldiers.first(where: { $0.id == id }), s.alive else { return }
        if s.groupId != activeGroupId { activeGroupId = s.groupId }
    }

    func splitSoldier(_ id: UUID) {
        guard let index = soldiers.firstIndex(where: { $0.id == id }) else { return }
        guard soldiers[index].alive, soldiers[index].controllable else { return }
        let from = soldiers[index].groupId
        guard from == activeGroupId else {
            activeGroupId = from
            return
        }
        let mates = soldiers.filter { $0.controllable && $0.alive && $0.groupId == from }
        guard mates.count >= 2 else { return }

        let other = 1 - from
        let takeG = groupGrenades[from] / 2
        let takeR = groupRockets[from] / 2
        groupGrenades[from] -= takeG
        groupRockets[from] -= takeR
        groupGrenades[other] += takeG
        groupRockets[other] += takeR

        soldiers[index].groupId = other
        soldiers[index].goals.removeAll()
        soldiers[index].path.removeAll()
        activeGroupId = other
        mergeSuppressedUntil = now + BattleConfig.mergeSuppress
    }

    func cancelPath() {
        if var jeep, jeep.occupied {
            jeep.path.removeAll()
            self.jeep = jeep
            return
        }
        for i in soldiers.indices where soldiers[i].controllable && soldiers[i].groupId == activeGroupId {
            soldiers[i].goals.removeAll()
            soldiers[i].path.removeAll()
        }
    }

    func orderMove(to point: CGPoint) {
        if var jeep, jeep.occupied, jeep.alive {
            let appending = !jeep.path.isEmpty
            if appending {
                jeep.path += pathfinder.path(from: jeep.path.last ?? jeep.position, to: point)
            } else {
                jeep.path = pathfinder.path(from: jeep.position, to: point)
            }
            self.jeep = jeep
            return
        }
        let movers = soldiers.indices.filter {
            soldiers[$0].controllable && soldiers[$0].alive && soldiers[$0].groupId == activeGroupId
        }
        guard !movers.isEmpty else { return }
        let appending = movers.contains { !soldiers[$0].goals.isEmpty || !soldiers[$0].path.isEmpty }
        let offsets = Self.formationOffsets(count: movers.count)
        for (i, idx) in movers.enumerated() {
            let dest = CGPoint(x: point.x + offsets[i].dx, y: point.y + offsets[i].dy)
            if appending {
                guard soldiers[idx].goals.count < BattleConfig.maxWaypoints else { continue }
                soldiers[idx].goals.append(dest)
            } else {
                soldiers[idx].goals = [dest]
                soldiers[idx].path = pathfinder.path(from: soldiers[idx].position, to: dest)
            }
        }
    }

    func toggleArm(_ weapon: ArmedWeapon) {
        let has = weapon == .grenade ? grenades > 0 : rockets > 0
        guard has, outcome == .playing else { return }
        armed = (armed == weapon) ? .none : weapon
    }

    func exitJeep() {
        guard var jeep, jeep.alive, !jeep.occupants.isEmpty else { return }
        let back: CGFloat = BattleConfig.pickupRadius + BattleConfig.formationSpacing + 8
        let ox = -cos(jeep.facing) * back
        let oy = -sin(jeep.facing) * back
        let offsets = Self.formationOffsets(count: jeep.occupants.count)
        for (i, id) in jeep.occupants.enumerated() {
            if let idx = soldiers.firstIndex(where: { $0.id == id }) {
                soldiers[idx].inVehicle = false
                soldiers[idx].path.removeAll()
                soldiers[idx].goals.removeAll()
                soldiers[idx].position = CGPoint(
                    x: jeep.position.x + ox + offsets[i].dx,
                    y: jeep.position.y + oy + offsets[i].dy
                )
            }
        }
        jeep.occupants.removeAll()
        jeep.path.removeAll()
        self.jeep = jeep
        jeepBailUntil = now + 1.15
    }

    func throwerPosition() -> CGPoint? {
        if let jeep, jeep.occupied { return jeep.position }
        return soldiers.first { $0.controllable && $0.alive && $0.groupId == activeGroupId }?.position
    }

    func tossRange() -> CGFloat {
        switch armed {
        case .grenade: return BattleConfig.grenadeRange
        case .rocket: return BattleConfig.rocketRange
        case .none: return 0
        }
    }

    func tossRadius() -> CGFloat {
        switch armed {
        case .grenade: return BattleConfig.grenadeRadius
        case .rocket: return BattleConfig.rocketRadius
        case .none: return 0
        }
    }

    func inTossRange(_ point: CGPoint) -> Bool {
        guard let from = throwerPosition() else { return false }
        return hypot(from.x - point.x, from.y - point.y) <= tossRange()
    }

    /// Spends ammo and unarms. Detonate after the lob lands.
    func prepareToss(at point: CGPoint) -> Toss? {
        guard outcome == .playing, let from = throwerPosition() else { return nil }
        switch armed {
        case .none: return nil
        case .grenade:
            guard groupGrenades[activeGroupId] > 0 else { return nil }
            guard hypot(from.x - point.x, from.y - point.y) <= BattleConfig.grenadeRange else { return nil }
            groupGrenades[activeGroupId] -= 1
            armed = .none
            return Toss(from: from, to: point, radius: BattleConfig.grenadeRadius, grenade: true)
        case .rocket:
            guard groupRockets[activeGroupId] > 0 else { return nil }
            guard hypot(from.x - point.x, from.y - point.y) <= BattleConfig.rocketRange else { return nil }
            groupRockets[activeGroupId] -= 1
            armed = .none
            return Toss(from: from, to: point, radius: BattleConfig.rocketRadius, grenade: false)
        }
    }

    func detonate(_ toss: Toss) {
        guard outcome == .playing else { return }
        blasts.append((toss.to, toss.radius))
        for i in soldiers.indices where soldiers[i].alive && !soldiers[i].inVehicle {
            if hypot(soldiers[i].position.x - toss.to.x, soldiers[i].position.y - toss.to.y) <= toss.radius {
                if !medicSaves(i) { soldiers[i].kill() }
            }
        }
        if var jeep, jeep.alive,
           hypot(jeep.position.x - toss.to.x, jeep.position.y - toss.to.y) <= toss.radius,
           !toss.grenade {
            killJeep(&jeep)
            self.jeep = jeep
        }
        if var barracks, barracks.alive,
           hypot(barracks.position.x - toss.to.x, barracks.position.y - toss.to.y) <= toss.radius {
            barracks.alive = false
            self.barracks = barracks
        }
        resolveOutcome()
    }

    func update(dt: TimeInterval) {
        guard outcome == .playing else {
            shotLines.removeAll()
            blasts.removeAll()
            return
        }
        now += dt
        shotLines.removeAll(keepingCapacity: true)
        blasts.removeAll(keepingCapacity: true)
        move(dt: dt)
        moveJeep(dt: dt)
        enterJeepIfNeeded()
        followVIP()
        patrolAndHunt()
        pickup()
        sinkCheck()
        spawnBarracks(dt: dt)
        combat(dt: dt)
        jeepGun(dt: dt)
        mergeIfNeeded()
        resolveOutcome()
    }

    // MARK: - Move

    private func move(dt: TimeInterval) {
        for i in soldiers.indices {
            guard soldiers[i].alive, !soldiers[i].inVehicle else { continue }
            if soldiers[i].kind == .turret { continue }
            if soldiers[i].path.isEmpty, let goal = soldiers[i].goals.first {
                soldiers[i].path = pathfinder.path(from: soldiers[i].position, to: goal)
                soldiers[i].goals.removeFirst()
            }
            guard let dest = soldiers[i].path.first else { continue }
            let tile = mission.tile(at: soldiers[i].position)
            var speed = BattleConfig.walkSpeed
            if tile == .ice { speed *= 0.7 }
            if tile == .bush { speed *= 0.75 }
            if soldiers[i].kind == .vip { speed *= 0.92 }
            let step = speed * CGFloat(dt)
            let pos = soldiers[i].position
            let dx = dest.x - pos.x
            let dy = dest.y - pos.y
            let dist = hypot(dx, dy)
            let next: CGPoint
            if dist <= step || dist < 0.5 {
                next = dest
                soldiers[i].path.removeFirst()
            } else {
                next = CGPoint(x: pos.x + dx / dist * step, y: pos.y + dy / dist * step)
            }
            if hitsBlocker(next, radius: soldiers[i].radius) {
                soldiers[i].path.removeAll()
                soldiers[i].goals.removeAll()
                continue
            }
            soldiers[i].facing = atan2(dy, dx)
            soldiers[i].position = next
        }
    }

    private func moveJeep(dt: TimeInterval) {
        guard var jeep, jeep.alive else { return }
        if let dest = jeep.path.first {
            let step = BattleConfig.jeepSpeed * CGFloat(dt)
            let dx = dest.x - jeep.position.x
            let dy = dest.y - jeep.position.y
            let dist = hypot(dx, dy)
            if dist <= step || dist < 0.5 {
                jeep.position = dest
                jeep.path.removeFirst()
            } else {
                jeep.position = CGPoint(x: jeep.position.x + dx / dist * step, y: jeep.position.y + dy / dist * step)
            }
            if hitsBlocker(jeep.position, radius: BattleConfig.jeepRadius) {
                jeep.path.removeAll()
            } else {
                jeep.facing = atan2(dy, dx)
            }
        }
        for id in jeep.occupants {
            if let idx = soldiers.firstIndex(where: { $0.id == id }) {
                soldiers[idx].position = jeep.position
                soldiers[idx].facing = jeep.facing
            }
        }
        self.jeep = jeep
    }

    private func enterJeepIfNeeded() {
        guard now >= jeepBailUntil else { return }
        guard var jeep, jeep.alive, jeep.occupants.isEmpty else { return }
        let near = soldiers.indices.filter {
            soldiers[$0].controllable && soldiers[$0].alive && soldiers[$0].groupId == activeGroupId
                && hypot(soldiers[$0].position.x - jeep.position.x, soldiers[$0].position.y - jeep.position.y) <= BattleConfig.pickupRadius + 6
        }
        guard !near.isEmpty else { return }
        for i in near {
            soldiers[i].inVehicle = true
            soldiers[i].path.removeAll()
            soldiers[i].goals.removeAll()
            soldiers[i].position = jeep.position
            jeep.occupants.append(soldiers[i].id)
        }
        self.jeep = jeep
    }

    private func followVIP() {
        guard let i = soldiers.firstIndex(where: { $0.kind == .vip && $0.alive }) else { return }
        let players = soldiers.filter { $0.faction == .player && $0.kind == .infantry && $0.alive }
        guard let target = players.min(by: {
            hypot($0.position.x - soldiers[i].position.x, $0.position.y - soldiers[i].position.y)
                < hypot($1.position.x - soldiers[i].position.x, $1.position.y - soldiers[i].position.y)
        }) else { return }
        let d = hypot(target.position.x - soldiers[i].position.x, target.position.y - soldiers[i].position.y)
        if d > BattleConfig.vipFollow + 8 {
            soldiers[i].goals = [target.position]
        } else {
            soldiers[i].goals.removeAll()
            soldiers[i].path.removeAll()
        }
    }

    private func patrolAndHunt() {
        let huntRange = BattleConfig.rifleRange * (0.38 + aggression / 14)
        let players = soldiers.filter { $0.faction == .player && $0.alive && $0.kind != .turret }
        for i in soldiers.indices where soldiers[i].faction == .enemy && soldiers[i].alive && soldiers[i].kind == .infantry {
            var hunting: CGPoint?
            for p in players {
                let d = hypot(p.position.x - soldiers[i].position.x, p.position.y - soldiers[i].position.y)
                if d <= huntRange, hasLOS(soldiers[i].position, p.position) {
                    hunting = p.position
                    break
                }
            }
            if let hunting {
                soldiers[i].goals = [hunting]
                continue
            }
            guard soldiers[i].path.isEmpty, soldiers[i].goals.isEmpty, !soldiers[i].patrol.isEmpty else { continue }
            let idx = soldiers[i].patrolIndex % soldiers[i].patrol.count
            soldiers[i].goals = [soldiers[i].patrol[idx]]
            soldiers[i].patrolIndex += 1
        }
    }

    private func pickup() {
        for p in pickups.indices where !pickups[p].taken {
            let grabbed = soldiers.first {
                $0.controllable && $0.alive
                    && hypot($0.position.x - pickups[p].position.x, $0.position.y - pickups[p].position.y) <= BattleConfig.pickupRadius
            }
            guard let grabber = grabbed else { continue }
            pickups[p].taken = true
            if pickups[p].grenade {
                groupGrenades[grabber.groupId] += 1
            } else {
                groupRockets[grabber.groupId] += 1
            }
        }
    }

    private func sinkCheck() {
        for i in soldiers.indices where soldiers[i].alive && !soldiers[i].inVehicle {
            if mission.tile(at: soldiers[i].position) == .sink {
                soldiers[i].kill()
            }
        }
        if var jeep, jeep.alive, mission.tile(at: jeep.position) == .sink {
            killJeep(&jeep)
            self.jeep = jeep
        }
    }

    private func spawnBarracks(dt: TimeInterval) {
        guard var barracks, barracks.alive else { return }
        barracks.spawnTimer -= dt
        if barracks.spawnTimer <= 0 {
            barracks.spawnTimer = BattleConfig.barracksPeriod
            let hostiles = soldiers.filter { $0.faction == .enemy && $0.alive && $0.kind == .infantry }.count
            if hostiles < 7 {
                let offset = CGPoint(x: barracks.position.x + 24, y: barracks.position.y - 10)
                soldiers.append(
                    Soldier(
                        id: UUID(),
                        name: "SPAWN",
                        rank: 0,
                        alive: true,
                        position: offset,
                        groupId: 0,
                        faction: .enemy,
                        kind: .infantry,
                        goals: [],
                        path: [],
                        facing: -.pi / 2,
                        fireCooldown: 0.4,
                        inVehicle: false,
                        patrol: [],
                        patrolIndex: 0
                    )
                )
            }
        }
        self.barracks = barracks
    }

    // MARK: - Combat

    private func combat(dt: TimeInterval) {
        for i in soldiers.indices {
            guard soldiers[i].alive, !soldiers[i].inVehicle, soldiers[i].kind != .vip else { continue }
            soldiers[i].fireCooldown = max(0, soldiers[i].fireCooldown - dt)
            guard let targetIndex = nearestTarget(from: i) else { continue }
            let from = soldiers[i].position
            let to = soldiers[targetIndex].position
            soldiers[i].facing = atan2(to.y - from.y, to.x - from.x)
            guard soldiers[i].fireCooldown <= 0 else { continue }
            if soldiers[i].faction == .enemy && soldiers[i].kind == .infantry {
                if now < nextEnemyRifle { continue }
                nextEnemyRifle = now + BattleConfig.enemyRifleGap
            }
            soldiers[i].fireCooldown = soldiers[i].kind == .turret ? BattleConfig.turretCooldown : BattleConfig.rifleCooldown
            shotLines.append((from, to, soldiers[i].faction))
            if soldiers[targetIndex].rifleImmune { continue }
            if soldiers[i].kind == .infantry {
                var miss = BattleConfig.missChance(rank: soldiers[i].rank)
                if soldiers[i].faction == .player && soldiers[i].trait == .marksman {
                    miss *= BattleConfig.marksmanMissMultiplier
                }
                if rand() < miss { continue }
            }
            if !medicSaves(targetIndex) {
                soldiers[targetIndex].kill()
            }
        }
    }

    /// v1.2: a nearby medic sometimes patches a wound that would have killed.
    private func medicSaves(_ index: Int) -> Bool {
        let target = soldiers[index]
        guard target.faction == .player, target.kind == .infantry else { return false }
        let hasMedic = soldiers.contains {
            $0.id != target.id && $0.alive && $0.faction == .player && $0.trait == .medic
                && hypot($0.position.x - target.position.x, $0.position.y - target.position.y) <= BattleConfig.medicSaveRadius
        }
        return hasMedic && rand() < BattleConfig.medicSaveChance
    }

    private func rand() -> CGFloat {
        rng = rng &* 6_364_136_223_846_793_005 &+ 1
        return CGFloat(rng >> 32) / CGFloat(UInt32.max)
    }

    private func jeepGun(dt: TimeInterval) {
        guard var jeep, jeep.alive, jeep.occupied else { return }
        jeep.fireCooldown = max(0, jeep.fireCooldown - dt)
        var best: (Int, CGFloat)?
        for (j, other) in soldiers.enumerated() where other.alive && other.faction == .enemy && other.kind == .infantry {
            let d = hypot(other.position.x - jeep.position.x, other.position.y - jeep.position.y)
            guard d <= BattleConfig.rifleRange, hasLOS(jeep.position, other.position) else { continue }
            if best == nil || d < best!.1 { best = (j, d) }
        }
        if let best, jeep.fireCooldown <= 0 {
            jeep.fireCooldown = BattleConfig.rifleCooldown
            shotLines.append((jeep.position, soldiers[best.0].position, .player))
            soldiers[best.0].kill()
        }
        self.jeep = jeep
    }

    private func nearestTarget(from shooter: Int) -> Int? {
        let s = soldiers[shooter]
        let range = s.kind == .turret ? BattleConfig.turretRange : BattleConfig.rifleRange
        var best: (Int, CGFloat)?
        for (j, other) in soldiers.enumerated() where j != shooter {
            guard other.alive, other.faction != s.faction else { continue }
            if other.inVehicle { continue }
            if s.kind == .infantry && other.rifleImmune { continue }
            let d = hypot(other.position.x - s.position.x, other.position.y - s.position.y)
            guard d <= range else { continue }
            guard hasLOS(s.position, other.position) else { continue }
            if best == nil || d < best!.1 { best = (j, d) }
        }
        return best?.0
    }

    private func killJeep(_ jeep: inout Jeep) {
        for id in jeep.occupants {
            if let idx = soldiers.firstIndex(where: { $0.id == id }) {
                soldiers[idx].kill()
            }
        }
        jeep.occupants.removeAll()
        jeep.alive = false
        jeep.path.removeAll()
    }

    private func hasLOS(_ a: CGPoint, _ b: CGPoint) -> Bool {
        !blockers.contains { Geom.segment(a, b, intersects: $0) }
    }

    private func hitsBlocker(_ point: CGPoint, radius: CGFloat) -> Bool {
        blockers.contains { $0.insetBy(dx: -radius, dy: -radius).contains(point) }
    }

    private func mergeIfNeeded() {
        guard now >= mergeSuppressedUntil, !inJeep else { return }
        let g0 = soldiers.filter { $0.controllable && $0.alive && $0.groupId == 0 }
        let g1 = soldiers.filter { $0.controllable && $0.alive && $0.groupId == 1 }
        guard !g0.isEmpty, !g1.isEmpty else { return }
        let close = g0.contains { a in
            g1.contains { b in hypot(a.position.x - b.position.x, a.position.y - b.position.y) < BattleConfig.mergeRadius }
        }
        guard close else { return }
        let keep = activeGroupId
        let other = 1 - keep
        groupGrenades[keep] += groupGrenades[other]
        groupRockets[keep] += groupRockets[other]
        groupGrenades[other] = 0
        groupRockets[other] = 0
        for i in soldiers.indices where soldiers[i].faction == .player && soldiers[i].alive && soldiers[i].kind == .infantry {
            soldiers[i].groupId = keep
        }
    }

    private func resolveOutcome() {
        let playersAlive = soldiers.contains { $0.faction == .player && $0.kind == .infantry && $0.alive }
        if !playersAlive {
            outcome = .lost
            return
        }
        if mission.objective == .extractVip, soldiers.contains(where: { $0.kind == .vip && !$0.alive }) {
            outcome = .lost
            return
        }
        switch mission.objective {
        case .destroyTurret:
            if !soldiers.contains(where: { $0.kind == .turret && $0.alive }) { outcome = .won }
        case .killAll:
            let hostiles = soldiers.contains { $0.faction == .enemy && $0.alive }
            let shack = barracks?.alive == true
            if !hostiles && !shack { outcome = .won }
        case .destroyBarracks:
            if barracks?.alive != true { outcome = .won }
        case .extractVip:
            if let extract, let vip = soldiers.first(where: { $0.kind == .vip && $0.alive }) {
                if hypot(vip.position.x - extract.x, vip.position.y - extract.y) <= BattleConfig.extractRadius {
                    outcome = .won
                }
            }
        }
    }

    // MARK: - Setup

    private static func makeSquad(_ mission: Mission, _ squad: [Trooper]) -> [Soldier] {
        zip(squad, mission.squad).map { trooper, spawn in
            Soldier(
                id: trooper.id,
                name: trooper.name,
                rank: trooper.rank,
                trait: trooper.trait,
                alive: true,
                position: CGPoint(x: spawn.x, y: spawn.y),
                groupId: 0,
                faction: .player,
                kind: .infantry,
                goals: [],
                path: [],
                facing: .pi / 2,
                fireCooldown: 0,
                inVehicle: false,
                patrol: [],
                patrolIndex: 0
            )
        }
    }

    private static func makeEnemies(_ mission: Mission) -> [Soldier] {
        mission.enemies.enumerated().map { i, spawn in
            let patrol = (spawn.patrol ?? []).map { CGPoint(x: $0.x, y: $0.y) }
            return Soldier(
                id: UUID(),
                name: "HOST-\(i + 1)",
                rank: 0,
                alive: true,
                position: CGPoint(x: spawn.x, y: spawn.y),
                groupId: 0,
                faction: .enemy,
                kind: .infantry,
                goals: [],
                path: [],
                facing: -.pi / 2,
                fireCooldown: TimeInterval(i) * 0.08,
                inVehicle: false,
                patrol: patrol,
                patrolIndex: 0
            )
        }
    }

    private static func makeTurret(_ spawn: Mission.Spawn) -> Soldier {
        Soldier(
            id: UUID(), name: "GUN", rank: 0, alive: true,
            position: CGPoint(x: spawn.x, y: spawn.y), groupId: 0,
            faction: .enemy, kind: .turret, goals: [], path: [],
            facing: -.pi / 2, fireCooldown: 0.2, inVehicle: false, patrol: [], patrolIndex: 0
        )
    }

    private static func makeVIP(_ spawn: Mission.Spawn) -> Soldier {
        Soldier(
            id: UUID(), name: spawn.name ?? "PACKAGE", rank: 0, alive: true,
            position: CGPoint(x: spawn.x, y: spawn.y), groupId: 0,
            faction: .player, kind: .vip, goals: [], path: [],
            facing: .pi / 2, fireCooldown: 0, inVehicle: false, patrol: [], patrolIndex: 0
        )
    }

    private static func formationOffsets(count: Int) -> [CGVector] {
        let s = BattleConfig.formationSpacing / 2
        let slots = [
            CGVector(dx: -s, dy: -s), CGVector(dx: s, dy: -s),
            CGVector(dx: -s, dy: s), CGVector(dx: s, dy: s)
        ]
        return Array(slots.prefix(max(count, 1)))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

enum Geom {
    static func segment(_ p1: CGPoint, _ p2: CGPoint, intersects rect: CGRect) -> Bool {
        if rect.contains(p1) || rect.contains(p2) { return true }
        let corners = [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY)
        ]
        for i in 0..<4 {
            if segments(p1, p2, corners[i], corners[(i + 1) % 4]) { return true }
        }
        return false
    }

    private static func segments(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint) -> Bool {
        func orient(_ p: CGPoint, _ q: CGPoint, _ r: CGPoint) -> CGFloat {
            (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
        }
        let o1 = orient(a, b, c)
        let o2 = orient(a, b, d)
        let o3 = orient(c, d, a)
        let o4 = orient(c, d, b)
        return o1 * o2 < 0 && o3 * o4 < 0
    }
}
