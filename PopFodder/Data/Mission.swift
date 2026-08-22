import CoreGraphics
import Foundation

struct Mission: Codable {
    let id: String
    let name: String
    let blurb: String?
    let objective: Objective
    let tileSize: CGFloat
    let tiles: [String]
    let biome: String?
    let aggression: Int?
    let grenadeLoadout: Int?
    let rocketLoadout: Int?
    let squad: [Spawn]
    let enemies: [EnemySpawn]
    let turret: Spawn?
    let grenades: [Spawn]?
    let rockets: [Spawn]?
    let jeep: Spawn?
    let barracks: Spawn?
    let vip: Spawn?
    let extract: Spawn?

    enum Objective: String, Codable {
        case destroyTurret = "destroy_turret"
        case killAll = "kill_all"
        case destroyBarracks = "destroy_barracks"
        case extractVip = "extract_vip"
    }

    struct Spawn: Codable {
        let x: CGFloat
        let y: CGFloat
        let name: String?
    }

    struct EnemySpawn: Codable {
        let x: CGFloat
        let y: CGFloat
        let patrol: [Spawn]?
    }

    var columns: Int { tiles.first?.count ?? 0 }
    var rows: Int { tiles.count }
    var mapSize: CGSize {
        CGSize(width: CGFloat(columns) * tileSize, height: CGFloat(rows) * tileSize)
    }
    var origin: CGPoint {
        CGPoint(x: -mapSize.width / 2, y: -mapSize.height / 2)
    }

    enum Tile: Character {
        case grass = "G"
        case dirt = "D"
        case wall = "W"
        case sink = "S"
        case ice = "I"
        case bush = "B"
    }

    func tile(column: Int, rowFromTop: Int) -> Tile {
        guard rowFromTop >= 0, rowFromTop < rows, column >= 0, column < columns else { return .grass }
        let chars = Array(tiles[rowFromTop])
        return Tile(rawValue: chars[column]) ?? .grass
    }

    func tile(at point: CGPoint) -> Tile {
        let g = grid(point)
        return tile(column: g.col, rowFromTop: g.row)
    }

    func tileRect(column: Int, rowFromTop: Int) -> CGRect {
        let worldRow = rows - 1 - rowFromTop
        return CGRect(
            x: origin.x + CGFloat(column) * tileSize,
            y: origin.y + CGFloat(worldRow) * tileSize,
            width: tileSize,
            height: tileSize
        )
    }

    func grid(_ point: CGPoint) -> TileIndex {
        TileIndex(
            col: Int(floor((point.x - origin.x) / tileSize)),
            row: rows - 1 - Int(floor((point.y - origin.y) / tileSize))
        )
    }

    func center(of index: TileIndex) -> CGPoint {
        let rect = tileRect(column: index.col, rowFromTop: index.row)
        return CGPoint(x: rect.midX, y: rect.midY)
    }

    func inBounds(_ i: TileIndex) -> Bool {
        i.col >= 0 && i.col < columns && i.row >= 0 && i.row < rows
    }

    var wallRects: [CGRect] {
        var rects: [CGRect] = []
        for r in 0..<rows {
            for c in 0..<columns where tile(column: c, rowFromTop: r) == .wall {
                rects.append(tileRect(column: c, rowFromTop: r))
            }
        }
        return rects
    }

    var objectiveLine: String {
        switch objective {
        case .destroyTurret: return "DESTROY THE TURRET"
        case .killAll: return "KILL ALL HOSTILES"
        case .destroyBarracks: return "DESTROY THE BARRACKS"
        case .extractVip: return "GET THE PACKAGE HOME"
        }
    }

    static func loadNamed(_ name: String) -> Mission {
        let url = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Missions")
            ?? Bundle.main.url(forResource: name, withExtension: "json")
        guard let url, let data = try? Data(contentsOf: url) else {
            fatalError("Missing mission \(name).json")
        }
        do {
            return try JSONDecoder().decode(Mission.self, from: data)
        } catch {
            fatalError("Mission \(name): \(error)")
        }
    }
}
