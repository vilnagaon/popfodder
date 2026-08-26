import Foundation

struct Trooper: Identifiable, Equatable {
    let id: UUID
    let name: String
    var rank: Int

    var rankName: String { RankNames.abbrev[min(RankNames.abbrev.count - 1, max(0, rank))] }
}

/// Enlisted ladder, 0-7. No officers — everyone here is expendable.
enum RankNames {
    static let abbrev = ["PVT", "PFC", "CPL", "SGT", "SSG", "SFC", "MSG", "SGM"]
}

struct CampaignDef: Codable {
    struct Item: Codable {
        let title: String
        let maps: [String]
    }
    let missions: [Item]
}

final class Campaign {
    private(set) var pool: [Trooper]
    private(set) var graves: [Trooper] = []
    private(set) var missionIndex = 0
    private(set) var phaseIndex = 0
    private(set) var nextName = 0
    private(set) var heldSquad: [Trooper]?
    private(set) var casualtiesThisRun = 0
    private(set) var kills = 0
    let def: CampaignDef

    init() {
        def = CampaignDef.load()
        pool = []
        for _ in 0..<15 {
            pool.append(nextTrooper(rank: 0))
        }
        PlayLog.line("campaign_start pool=\(pool.count) missions=\(def.missions.count)")
    }

    var currentMission: Mission {
        Mission.loadNamed(def.missions[missionIndex].maps[phaseIndex])
    }

    var missionTitle: String { def.missions[missionIndex].title }
    var missionCount: Int { def.missions.count }
    var missionNumber: Int { missionIndex + 1 }
    var phaseCount: Int { def.missions[missionIndex].maps.count }
    var phaseNumber: Int { phaseIndex + 1 }
    var isLastPhase: Bool { phaseIndex >= phaseCount - 1 }
    var finished: Bool { missionIndex >= def.missions.count }
    var poolExhausted: Bool { pool.count < 2 }

    func deploy() -> [Trooper] {
        if let held = heldSquad, !held.isEmpty { return held }
        return Array(pool.prefix(min(4, pool.count)))
    }

    /// Screenshot / `-graveyard` launch. Moves `n` names from the pool onto the hill.
    func buryFromPool(_ n: Int) {
        let k = min(n, pool.count)
        for i in 0..<k {
            var t = pool.removeFirst()
            t.rank = min(7, i)
            graves.append(t)
        }
    }

    func advancePhase(deployed: [Trooper], survivors: [Soldier], kills: Int) {
        self.kills += kills
        apply(deployed: deployed, survivors: survivors)
        heldSquad = deployed.compactMap { t in
            pool.first { $0.id == t.id }
        }
        phaseIndex += 1
        PlayLog.line("phase_win mission=\(missionNumber) next_phase=\(phaseNumber) held=\(heldSquad?.count ?? 0) pool=\(pool.count)")
    }

    func resolveMission(deployed: [Trooper], survivors: [Soldier], won: Bool, kills: Int) {
        self.kills += kills
        apply(deployed: deployed, survivors: survivors)
        heldSquad = nil
        if won {
            let incoming = (missionIndex + 1) / 3
            replenish(rank: incoming)
            PlayLog.line("mission_win \(missionTitle) graves=\(graves.count) pool=\(pool.count) casualties=\(casualtiesThisRun)")
            missionIndex += 1
            phaseIndex = 0
        } else {
            PlayLog.line("mission_lose \(missionTitle) pool=\(pool.count) exhausted=\(poolExhausted)")
        }
        GameCenter.submit(missionsSurvived: missionIndex, kills: self.kills)
    }

    private func apply(deployed: [Trooper], survivors: [Soldier]) {
        let liveIDs = Set(survivors.filter { $0.alive && $0.faction == .player && $0.kind == .infantry }.map(\.id))
        for trooper in deployed {
            if liveIDs.contains(trooper.id) {
                if let i = pool.firstIndex(where: { $0.id == trooper.id }) {
                    pool[i].rank = min(7, pool[i].rank + 1)
                }
            } else if let i = pool.firstIndex(where: { $0.id == trooper.id }) {
                graves.append(pool.remove(at: i))
                casualtiesThisRun += 1
                PlayLog.line("died \(trooper.name) rank=\(trooper.rank)")
            }
        }
    }

    private func replenish(rank: Int) {
        for _ in 0..<15 {
            pool.append(nextTrooper(rank: rank))
        }
    }

    private func nextTrooper(rank: Int) -> Trooper {
        let names = RecruitNames.pool
        let name = names[nextName % names.count]
        nextName += 1
        return Trooper(id: UUID(), name: name, rank: rank)
    }
}

extension CampaignDef {
    static func load() -> CampaignDef {
        let url = Bundle.main.url(forResource: "campaign", withExtension: "json")
        guard let url, let data = try? Data(contentsOf: url),
              let def = try? JSONDecoder().decode(CampaignDef.self, from: data) else {
            return CampaignDef(missions: [
                .init(title: "THE GAP", maps: ["the-gap"])
            ])
        }
        return def
    }
}

enum PlayLog {
    static func line(_ text: String) {
        let stamp = ISO8601DateFormatter().string(from: Date())
        let row = "\(stamp) \(text)\n"
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let url = dir?.appendingPathComponent("playlog.txt") else { return }
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(Data(row.utf8))
            try? handle.close()
        } else {
            try? Data(row.utf8).write(to: url)
        }
        print("[playlog] \(text)")
    }
}
