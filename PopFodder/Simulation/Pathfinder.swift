import CoreGraphics
import Foundation

struct Pathfinder {
    let mission: Mission

    func path(from: CGPoint, to: CGPoint) -> [CGPoint] {
        let start = mission.grid(from)
        let goal = mission.grid(to)
        guard mission.inBounds(start), mission.inBounds(goal) else { return [to] }
        if start == goal { return [to] }
        guard walkable(goal) else { return [to] }

        var came: [TileIndex: TileIndex] = [:]
        var gScore: [TileIndex: CGFloat] = [start: 0]
        var open: [TileIndex] = [start]
        var openSet: Set<TileIndex> = [start]
        var closed: Set<TileIndex> = []

        while let current = open.min(by: { f($0, goal, gScore) < f($1, goal, gScore) }) {
            if current == goal {
                return reconstruct(came, current, final: to)
            }
            open.removeAll { $0 == current }
            openSet.remove(current)
            closed.insert(current)

            for n in neighbors(current) where !closed.contains(n) && walkable(n) {
                let step: CGFloat = (n.col != current.col && n.row != current.row) ? 1.4 : 1
                let tentative = (gScore[current] ?? 1e9) + step
                if tentative < (gScore[n] ?? 1e9) {
                    came[n] = current
                    gScore[n] = tentative
                    if !openSet.contains(n) {
                        open.append(n)
                        openSet.insert(n)
                    }
                }
            }
            if closed.count > 400 { break }
        }
        return [to]
    }

    private func walkable(_ i: TileIndex) -> Bool {
        let t = mission.tile(column: i.col, rowFromTop: i.row)
        return t != .wall && t != .sink
    }

    private func neighbors(_ i: TileIndex) -> [TileIndex] {
        var out: [TileIndex] = []
        for dr in -1...1 {
            for dc in -1...1 where !(dr == 0 && dc == 0) {
                let n = TileIndex(col: i.col + dc, row: i.row + dr)
                guard mission.inBounds(n) else { continue }
                if dr != 0 && dc != 0 {
                    let a = TileIndex(col: i.col + dc, row: i.row)
                    let b = TileIndex(col: i.col, row: i.row + dr)
                    if !walkable(a) || !walkable(b) { continue }
                }
                out.append(n)
            }
        }
        return out
    }

    private func f(_ i: TileIndex, _ goal: TileIndex, _ g: [TileIndex: CGFloat]) -> CGFloat {
        let dx = CGFloat(abs(i.col - goal.col))
        let dy = CGFloat(abs(i.row - goal.row))
        return (g[i] ?? 1e9) + max(dx, dy) + 0.001 * min(dx, dy)
    }

    private func reconstruct(_ came: [TileIndex: TileIndex], _ current: TileIndex, final: CGPoint) -> [CGPoint] {
        var chain = [current]
        var c = current
        while let p = came[c] {
            chain.append(p)
            c = p
        }
        chain.reverse()
        if chain.count > 1 { chain.removeFirst() }
        var points = chain.map { mission.center(of: $0) }
        points.append(final)
        return points
    }
}

struct TileIndex: Hashable {
    var col: Int
    var row: Int
}
