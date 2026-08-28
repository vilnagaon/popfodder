import CoreGraphics
import Foundation

enum Faction {
    case player
    case enemy
}

enum UnitKind {
    case infantry
    case turret
    case vip
}

enum ArmedWeapon {
    case none
    case grenade
    case rocket
}

struct Toss {
    let from: CGPoint
    let to: CGPoint
    let radius: CGFloat
    let grenade: Bool
}

struct Soldier: Identifiable, Equatable {
    let id: UUID
    let name: String
    var rank: Int
    var trait: TrooperClass = .none
    var alive: Bool
    var position: CGPoint
    var groupId: Int
    let faction: Faction
    let kind: UnitKind
    var goals: [CGPoint]
    var path: [CGPoint]
    var facing: CGFloat
    var fireCooldown: TimeInterval
    var inVehicle: Bool
    var patrol: [CGPoint]
    var patrolIndex: Int

    var radius: CGFloat {
        switch kind {
        case .turret: return BattleConfig.turretRadius
        default: return BattleConfig.soldierRadius
        }
    }

    var rifleImmune: Bool { kind == .turret }

    var controllable: Bool { faction == .player && kind == .infantry && !inVehicle }

    mutating func kill() {
        alive = false
        goals.removeAll()
        path.removeAll()
        fireCooldown = 0
        inVehicle = false
    }
}

struct Jeep {
    var position: CGPoint
    var alive: Bool
    var facing: CGFloat
    var occupants: [UUID]
    var path: [CGPoint]
    var fireCooldown: TimeInterval

    var occupied: Bool { !occupants.isEmpty }
}

struct Barracks {
    var position: CGPoint
    var alive: Bool
    var spawnTimer: TimeInterval
}

struct Pickup {
    var position: CGPoint
    var grenade: Bool
    var taken: Bool
}

enum BattleConfig {
    static let walkSpeed: CGFloat = 120
    static let jeepSpeed: CGFloat = 190
    static let formationSpacing: CGFloat = 28
    static let selectRadius: CGFloat = 36
    static let soldierRadius: CGFloat = 10
    static let turretRadius: CGFloat = 16
    static let jeepRadius: CGFloat = 18
    static let maxGroups = 2
    static let maxWaypoints = 4
    static let rifleRange: CGFloat = 165
    static let rifleCooldown: TimeInterval = 0.38
    static let turretRange: CGFloat = 200
    static let turretCooldown: TimeInterval = 0.72
    static let grenadeRadius: CGFloat = 64
    static let grenadeRange: CGFloat = 320
    static let rocketRadius: CGFloat = 40
    static let rocketRange: CGFloat = 240
    static let pickupRadius: CGFloat = 24
    static let mergeRadius: CGFloat = 32
    static let mergeSuppress: TimeInterval = 1.2
    static let doubleTap: TimeInterval = 0.30
    static let panSlop: CGFloat = 24
    static let barracksPeriod: TimeInterval = 5.6
    static let extractRadius: CGFloat = 40
    static let vipFollow: CGFloat = 22
    static let enemyRifleGap: TimeInterval = 0.2
    static func missChance(rank: Int) -> CGFloat {
        max(0.06, 0.32 - CGFloat(rank) * 0.035)
    }
    /// v1.2 traits, picked once at first promotion.
    static let marksmanMissMultiplier: CGFloat = 0.5
    static let medicSaveChance: CGFloat = 0.35
    static let medicSaveRadius: CGFloat = 90
}

enum RecruitNames {
    /// Original short names from names.txt. Never Jools, Jops, or OpenFodder's list.
    static let pool: [String] = {
        if let url = Bundle.main.url(forResource: "names", withExtension: "txt"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            let rows = text.split(whereSeparator: \.isNewline).map { String($0) }.filter { !$0.isEmpty }
            if rows.count >= 40 { return rows }
        }
        return ["BRAM", "KOEN", "ANJA", "PIET", "LIES", "TOON", "NELS", "FONS"]
    }()
}

enum Outcome {
    case playing
    case won
    case lost
}
