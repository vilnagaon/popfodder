import SpriteKit
import UIKit

enum Art {
    private static var cache: [String: SKTexture] = [:]

    /// 32px top-down infantry. Helmet is the person (faction disc). Idle 8-dir (0=E).
    /// `walk`: 0 idle, 1/2 stride. Dead is one pose. Do not rotate the sprite.
    static func infantry(
        player: Bool,
        group: Int,
        dead: Bool,
        facing: CGFloat = .pi / 2,
        walk: Int = 0
    ) -> SKTexture {
        let dir = dead ? 2 : dir8(facing)
        let step = dead ? 0 : max(0, min(2, walk))
        return memo("inf32-\(player)-\(group)-\(dead)-\(dir)-\(step)") {
            let body: RGB
            if dead {
                body = (70, 70, 70)
            } else if !player {
                body = (220, 40, 36)
            } else if group == 0 {
                body = (56, 200, 82)
            } else {
                body = (38, 158, 184)
            }
            let outline: RGB = dead ? (40, 40, 40) : (16, 16, 14)
            let visor: RGB = dead ? (48, 48, 48) : (28, 28, 26)
            let shine = shade(body, 1.18)
            let dark = shade(body, 0.62)
            let pack: RGB? = (dead || !player) ? nil : (255, 214, 0)
            let rifle: RGB = dead ? (58, 58, 56) : (210, 210, 198)
            let boot: RGB = dead ? (48, 48, 48) : (22, 22, 20)
            return stamp(32) { set, _ in
                if dead {
                    disk(16, 18, 8, outline, set)
                    disk(16, 18, 7, body, set)
                    disk(16, 16, 3, visor, set)
                    disk(11, 24, 2.2, boot, set)
                    disk(21, 24, 2.2, boot, set)
                    return
                }
                let ang = Double(dir) * .pi / 4
                let fx = cos(ang)
                let fy = -sin(ang)
                var bob = 0.0
                var lx = 12.0, ly = 26.5, rx = 20.0, ry = 26.5
                if step == 1 {
                    bob = -0.7
                    lx = 11.2 + fx * 1.6; ly = 24.2 + fy * 1.4
                    rx = 20.8 - fx * 1.6; ry = 27.8 - fy * 1.4
                } else if step == 2 {
                    bob = 0.5
                    lx = 12.8 - fx * 1.6; ly = 27.8 - fy * 1.4
                    rx = 19.2 + fx * 1.6; ry = 24.2 + fy * 1.4
                }
                let hy = 12 + bob
                let by = 21 + bob * 0.6
                disk(16, hy, 8, outline, set)
                disk(16, hy, 7, body, set)
                disk(16 - fx * 2.2, hy - fy * 2.2 - 0.8, 2.4, shine, set)
                disk(16 + fx * 3.2, hy + fy * 3.2, 2.6, visor, set)
                if let pack {
                    disk(16 - fx * 5.5, hy - fy * 5.5, 2.2, pack, set)
                }
                disk(16, by, 5.2, outline, set)
                disk(16, by - 0.5, 4.4, dark, set)
                disk(16, by - 1.5, 3.6, body, set)
                disk(lx, ly, 2.1, boot, set)
                disk(rx, ry, 2.1, boot, set)
                thickLine(
                    16 + fx * 6.5, hy + fy * 6.5,
                    16 + fx * 13.5, hy + fy * 13.5,
                    rifle, set
                )
            }
        }
    }

    /// atan2: 0=E, π/2=N. Eight sectors, no wrap seam at ±π.
    private static func dir8(_ facing: CGFloat) -> Int {
        var i = Int((facing / (.pi / 4)).rounded()) % 8
        if i < 0 { i += 8 }
        return i
    }

    private static func disk(_ cx: Double, _ cy: Double, _ r: Double, _ rgb: RGB, _ set: (Int, Int, RGB) -> Void) {
        let r2 = r * r
        let x0 = max(0, Int(floor(cx - r)))
        let x1 = min(31, Int(ceil(cx + r)))
        let y0 = max(0, Int(floor(cy - r)))
        let y1 = min(31, Int(ceil(cy + r)))
        guard x0 <= x1, y0 <= y1 else { return }
        for y in y0...y1 {
            for x in x0...x1 {
                let dx = Double(x) + 0.5 - cx
                let dy = Double(y) + 0.5 - cy
                if dx * dx + dy * dy <= r2 { set(x, y, rgb) }
            }
        }
    }

    private static func thickLine(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ rgb: RGB, _ set: (Int, Int, RGB) -> Void) {
        let steps = max(1, Int(hypot(x1 - x0, y1 - y0) * 2))
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let cx = x0 + (x1 - x0) * t
            let cy = y0 + (y1 - y0) * t
            disk(cx, cy, 1.15, rgb, set)
        }
    }

    private typealias RGB = (Int, Int, Int)

    private static func shade(_ rgb: RGB, _ k: Double) -> RGB {
        (
            min(255, Int(Double(rgb.0) * k)),
            min(255, Int(Double(rgb.1) * k)),
            min(255, Int(Double(rgb.2) * k))
        )
    }

    /// 32px escort. Gold disc, no rifle, no pack. Wider helmet than infantry.
    static func vip(dead: Bool = false, facing: CGFloat = .pi / 2, walk: Int = 0) -> SKTexture {
        let dir = dead ? 2 : dir8(facing)
        let step = dead ? 0 : max(0, min(2, walk))
        return memo("vip32b-\(dead)-\(dir)-\(step)") {
            let body: RGB = dead ? (90, 82, 48) : (240, 210, 70)
            let outline: RGB = dead ? (40, 38, 28) : (48, 36, 12)
            let shine = shade(body, 1.15)
            let dark = shade(body, 0.62)
            let boot: RGB = dead ? (48, 48, 48) : (22, 22, 20)
            let collar: RGB = dead ? (70, 70, 68) : (242, 240, 235)
            return stamp(32) { set, _ in
                if dead {
                    disk(16, 18, 9, outline, set)
                    disk(16, 18, 8, body, set)
                    disk(16, 16, 3, dark, set)
                    disk(11, 24, 2.2, boot, set)
                    disk(21, 24, 2.2, boot, set)
                    return
                }
                let ang = Double(dir) * .pi / 4
                let fx = cos(ang)
                let fy = -sin(ang)
                var bob = 0.0
                var lx = 12.0, ly = 26.5, rx = 20.0, ry = 26.5
                if step == 1 {
                    bob = -0.7
                    lx = 11.2 + fx * 1.6; ly = 24.2 + fy * 1.4
                    rx = 20.8 - fx * 1.6; ry = 27.8 - fy * 1.4
                } else if step == 2 {
                    bob = 0.5
                    lx = 12.8 - fx * 1.6; ly = 27.8 - fy * 1.4
                    rx = 19.2 + fx * 1.6; ry = 24.2 + fy * 1.4
                }
                let hy = 12 + bob
                let by = 21 + bob * 0.6
                disk(16, hy, 9, outline, set)
                disk(16, hy, 8, body, set)
                disk(16 - fx * 2.0, hy - fy * 2.0 - 0.6, 2.6, shine, set)
                disk(16 + fx * 2.4, hy + fy * 2.4, 2.0, collar, set)
                disk(16, by, 5.6, outline, set)
                disk(16, by - 0.5, 4.8, dark, set)
                disk(16, by - 1.5, 4.0, body, set)
                disk(lx, ly, 2.1, boot, set)
                disk(rx, ry, 2.1, boot, set)
            }
        }
    }

    static func turret() -> SKTexture {
        memo("turret32") {
            return stamp(32) { set, _ in
                let hull: RGB = (176, 36, 36)
                let dark: RGB = (40, 40, 40)
                let lip: RGB = (110, 24, 24)
                for y in 10...28 {
                    for x in 6...25 { set(x, y, y < 12 || x < 8 || x > 23 ? dark : hull) }
                }
                for y in 12...26 {
                    for x in 8...23 { set(x, y, hull) }
                }
                for y in 2...14 {
                    for x in 13...18 { set(x, y, dark) }
                }
                for y in 4...12 {
                    for x in 14...17 { set(x, y, lip) }
                }
            }
        }
    }

    static func nade(grenade: Bool) -> SKTexture {
        memo("nade-\(grenade)") {
            let fill: RGB = grenade ? (255, 214, 0) : (242, 115, 20)
            let ink: RGB = (22, 16, 10)
            return stamp(12) { set, _ in
                for y in 0..<12 {
                    for x in 0..<12 {
                        let dx = Double(x) + 0.5 - 6
                        let dy = Double(y) + 0.5 - 6
                        if dx * dx + dy * dy <= 25 { set(x, y, ink) }
                        if dx * dx + dy * dy <= 16 { set(x, y, fill) }
                    }
                }
            }
        }
    }

    /// 32px pickup. Brass + G vs orange + R. Fat X on the grenade lid only.
    static func crate(grenade: Bool) -> SKTexture {
        memo("crate32-\(grenade)") {
            let face: RGB = grenade ? (255, 214, 0) : (242, 115, 20)
            let shadeC: RGB = grenade ? (186, 148, 0) : (168, 72, 14)
            let lid: RGB = grenade ? (255, 230, 80) : (255, 150, 60)
            let outline: RGB = (22, 16, 10)
            let ink: RGB = (16, 16, 14)
            return stamp(32) { set, _ in
                func box(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ rgb: RGB) {
                    for y in y0...y1 {
                        for x in x0...x1 where (0..<32).contains(x) && (0..<32).contains(y) {
                            set(x, y, rgb)
                        }
                    }
                }
                func inkAt(_ pts: [(Int, Int)]) {
                    for (x, y) in pts { set(x, y, ink) }
                }
                // Lid (slight height).
                box(6, 5, 23, 13, outline)
                box(7, 6, 22, 12, lid)
                box(8, 7, 21, 11, face)
                if grenade {
                    // Fat X on the lid.
                    for i in 0...8 {
                        set(9 + i, 7 + i / 2, ink)
                        set(10 + i, 7 + i / 2, ink)
                        set(20 - i, 7 + i / 2, ink)
                        set(19 - i, 7 + i / 2, ink)
                    }
                } else {
                    // Chevron / rocket mark on the lid.
                    for i in 0...5 {
                        set(16 - i, 7 + i, ink)
                        set(16 + i, 7 + i, ink)
                        set(15 - i, 7 + i, ink)
                        set(17 + i, 7 + i, ink)
                    }
                    box(15, 10, 17, 12, ink)
                }
                // Front.
                box(6, 13, 21, 28, outline)
                box(7, 14, 20, 27, face)
                box(7, 26, 20, 27, shadeC)
                // Side.
                box(21, 13, 27, 28, outline)
                box(22, 14, 26, 27, shadeC)
                // Letter on the front face (Menlo-ish, 5×7).
                let ox = 11, oy = 17
                if grenade {
                    inkAt([
                        (ox+1, oy), (ox+2, oy), (ox+3, oy),
                        (ox, oy+1), (ox+4, oy+1),
                        (ox, oy+2),
                        (ox, oy+3), (ox+2, oy+3), (ox+3, oy+3), (ox+4, oy+3),
                        (ox, oy+4), (ox+4, oy+4),
                        (ox, oy+5), (ox+4, oy+5),
                        (ox+1, oy+6), (ox+2, oy+6), (ox+3, oy+6)
                    ])
                } else {
                    inkAt([
                        (ox, oy), (ox+1, oy), (ox+2, oy), (ox+3, oy),
                        (ox, oy+1), (ox+4, oy+1),
                        (ox, oy+2), (ox+4, oy+2),
                        (ox, oy+3), (ox+1, oy+3), (ox+2, oy+3), (ox+3, oy+3),
                        (ox, oy+4), (ox+2, oy+4),
                        (ox, oy+5), (ox+3, oy+5),
                        (ox, oy+6), (ox+4, oy+6)
                    ])
                }
            }
        }
    }

    /// 40px top-down jeep, hood faces +X (east) so `zRotation = facing` aims it.
    /// Empty khaki, occupied Ours, dead grey. Helmets in seats when occupied.
    static func jeep(occupied: Bool, dead: Bool) -> SKTexture {
        memo("jeep40b-\(occupied)-\(dead)") {
            let hull: RGB
            if dead {
                hull = (58, 58, 58)
            } else if occupied {
                hull = (56, 200, 82)
            } else {
                hull = (88, 96, 62)
            }
            let dark: RGB = dead ? (36, 36, 36) : (28, 30, 22)
            let mid = shade(hull, 0.72)
            let light = shade(hull, 1.12)
            let outline: RGB = dead ? (24, 24, 24) : (16, 16, 14)
            let wheel: RGB = (18, 18, 18)
            let glass: RGB = dead ? (48, 48, 50) : (40, 70, 90)
            let lamp: RGB = dead ? (70, 70, 68) : (255, 230, 140)
            let helm: RGB = occupied && !dead ? (56, 200, 82) : (32, 34, 28)
            let visor: RGB = occupied && !dead ? (28, 28, 26) : (22, 22, 20)
            return stamp(40) { set, _ in
                func box(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ rgb: RGB) {
                    for y in y0...y1 {
                        for x in x0...x1 where (0..<40).contains(x) && (0..<40).contains(y) {
                            set(x, y, rgb)
                        }
                    }
                }
                // Wheels — four corners, long axis = east.
                box(6, 8, 12, 11, wheel)
                box(6, 28, 12, 31, wheel)
                box(26, 8, 32, 11, wheel)
                box(26, 28, 32, 31, wheel)
                // Hull.
                box(4, 12, 36, 27, outline)
                box(5, 13, 35, 26, hull)
                box(5, 13, 35, 14, light)
                box(5, 25, 35, 26, mid)
                // Hood (east / right).
                box(26, 14, 35, 25, mid)
                box(28, 16, 34, 23, hull)
                box(33, 17, 35, 18, lamp)
                box(33, 21, 35, 22, lamp)
                // Cabin well.
                box(8, 15, 24, 24, outline)
                box(9, 16, 23, 23, dark)
                if occupied && !dead {
                    // Two helmets in the well.
                    box(11, 17, 16, 22, outline)
                    box(12, 18, 15, 21, helm)
                    box(14, 19, 15, 20, visor)
                    box(18, 17, 23, 22, outline)
                    box(19, 18, 22, 21, helm)
                    box(21, 19, 22, 20, visor)
                } else if dead {
                    box(12, 18, 15, 21, (48, 48, 48))
                    box(19, 18, 22, 21, (44, 44, 44))
                    box(10, 16, 22, 16, outline)
                    box(16, 16, 16, 23, outline)
                }
                // Windscreen lip.
                box(24, 15, 26, 24, glass)
            }
        }
    }

    /// 40px hut. Doorway is the spawner mouth. Dead = grey, mouth gone.
    static func barracks(alive: Bool) -> SKTexture {
        memo("hq40b-\(alive)") {
            let plank: RGB = alive ? (110, 56, 40) : (58, 58, 58)
            let groove: RGB = alive ? (78, 38, 28) : (44, 44, 44)
            let light: RGB = alive ? (148, 86, 56) : (78, 78, 76)
            let roof: RGB = alive ? (72, 42, 32) : (48, 48, 48)
            let ridge: RGB = alive ? (48, 28, 22) : (36, 36, 36)
            let outline: RGB = alive ? (22, 12, 10) : (32, 32, 32)
            let door: RGB = (10, 9, 9)
            let pit: RGB = (6, 6, 6)
            return stamp(40) { set, _ in
                func box(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ rgb: RGB) {
                    for y in y0...y1 {
                        for x in x0...x1 where (0..<40).contains(x) && (0..<40).contains(y) {
                            set(x, y, rgb)
                        }
                    }
                }
                // Roof slope (slight height): wide at eaves, narrow at ridge.
                for y in 4...16 {
                    let t = Double(y - 4) / 12.0
                    let half = Int(4 + t * 14)
                    box(20 - half, y, 19 + half, y, y <= 6 ? ridge : roof)
                }
                box(5, 16, 34, 16, outline)
                // Plank walls, grooves every 3 rows.
                box(5, 17, 34, 37, plank)
                for y in stride(from: 19, through: 36, by: 3) {
                    box(6, y, 33, y, groove)
                }
                // Highlight on the left edge of a few planks.
                for y in [18, 24, 30] {
                    box(6, y, 8, y, light)
                }
                box(5, 17, 5, 37, outline)
                box(34, 17, 34, 37, outline)
                box(5, 37, 34, 37, outline)
                if alive {
                    // Mouth: tall black door, south face, darker pit inside.
                    box(14, 21, 25, 36, outline)
                    box(15, 22, 24, 36, door)
                    box(16, 24, 23, 35, pit)
                    box(15, 36, 24, 36, (40, 24, 18))
                } else {
                    // Rubble where the mouth was — no hole.
                    box(14, 24, 25, 36, groove)
                    box(16, 28, 19, 31, outline)
                    box(21, 26, 24, 29, light)
                }
            }
        }
    }

    /// 32px field tells. Wall = slab, sink = hole, bush = sparse tufts (alpha).
    static func wall() -> SKTexture {
        memo("tile-wall") {
            let brick: RGB = (72, 74, 80)
            let mortar: RGB = (28, 28, 30)
            let lite: RGB = (102, 104, 110)
            let outline: RGB = (16, 16, 18)
            return stamp(32) { set, _ in
                for y in 0..<32 {
                    for x in 0..<32 { set(x, y, mortar) }
                }
                let rowH = 7
                var y = 1
                var stagger = false
                while y < 31 {
                    var x = stagger ? -4 : 1
                    while x < 31 {
                        let x0 = max(1, x)
                        let x1 = min(30, x + 9)
                        let y1 = min(30, y + rowH - 2)
                        if x1 > x0 {
                            for yy in y...y1 {
                                for xx in x0...x1 {
                                    set(xx, yy, yy == y ? lite : brick)
                                }
                            }
                        }
                        x += 11
                    }
                    y += rowH
                    stagger.toggle()
                }
                for i in 0..<32 {
                    set(i, 0, outline); set(i, 31, outline)
                    set(0, i, outline); set(31, i, outline)
                }
            }
        }
    }

    static func sink() -> SKTexture {
        memo("tile-sink") {
            let rim: RGB = (42, 32, 48)
            let mid: RGB = (22, 14, 28)
            let hole: RGB = (8, 6, 12)
            let pit: RGB = (4, 3, 6)
            return stamp(32) { set, _ in
                for y in 0..<32 {
                    for x in 0..<32 { set(x, y, rim) }
                }
                disk(16, 16, 13, mid, set)
                disk(16, 16, 9, hole, set)
                disk(16, 16, 5, pit, set)
            }
        }
    }

    /// 16px grave marker. Rounded slab, never a cross. Rank stretches the stone.
    static func tombstone(rank: Int) -> SKTexture {
        let r = max(0, min(7, rank))
        return memo("tomb16-\(r)") {
            let outline: RGB = (36, 36, 32)
            let stone: RGB = (176, 176, 166)
            let face: RGB = (204, 204, 194)
            let shadeC: RGB = (118, 118, 110)
            let brass: RGB = (255, 214, 0)
            let top = 3 - min(2, r / 3)
            let base = 14
            return stamp(16) { set, _ in
                func box(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ rgb: RGB) {
                    for y in y0...y1 {
                        for x in x0...x1 where (0..<16).contains(x) && (0..<16).contains(y) {
                            set(x, y, rgb)
                        }
                    }
                }
                for y in top...base {
                    let inset: Int
                    if y == top { inset = 3 }
                    else if y == top + 1 { inset = 2 }
                    else if y >= base - 1 { inset = 1 }
                    else { inset = 1 }
                    box(3 + inset, y, 12 - inset, y, outline)
                    if y > top && y < base {
                        box(4 + inset, y, 11 - inset, y, y > base - 3 ? shadeC : stone)
                    }
                }
                box(6, top + 2, 9, top + 3, face)
                if r >= 4 {
                    box(6, top + 1, 9, top + 1, brass)
                }
                box(5, base, 10, min(15, base + 1), shadeC)
            }
        }
    }

    /// 16px field noise. Not cover. Three clumps, biome-tinted.
    static func tuft(variant: Int, biome: String) -> SKTexture {
        let v = ((variant % 3) + 3) % 3
        return memo("tuft-\(v)-\(biome)") {
            let blade: RGB
            let tip: RGB
            switch biome {
            case "dirt":
                blade = (140, 108, 48)
                tip = (186, 148, 64)
            case "snow":
                blade = (168, 180, 188)
                tip = (220, 228, 232)
            default:
                blade = (72, 118, 42)
                tip = (168, 156, 48)
            }
            return stamp(16) { set, _ in
                let clumps: [[(Int, Int, Bool)]] = [
                    [(7, 10, false), (8, 8, true), (9, 11, false), (6, 12, false)],
                    [(4, 9, false), (5, 7, true), (11, 10, false), (12, 8, true), (10, 12, false)],
                    [(8, 9, true), (7, 12, false), (9, 12, false)]
                ]
                for (x, y, isTip) in clumps[v] {
                    set(x, y, isTip ? tip : blade)
                    if y + 1 < 16 { set(x, y + 1, blade) }
                }
            }
        }
    }

    static func bush() -> SKTexture {
        memo("tile-bush") {
            let leaf: RGB = (46, 118, 50)
            let dark: RGB = (22, 68, 26)
            let tip: RGB = (70, 150, 64)
            return stamp(32) { set, _ in
                func tuft(_ cx: Double, _ cy: Double, _ r: Double) {
                    disk(cx, cy, r, dark, set)
                    disk(cx, cy - 0.8, r - 1.2, leaf, set)
                    disk(cx + 1.2, cy - r + 1.5, 1.6, tip, set)
                }
                tuft(8, 11, 5)
                tuft(22, 9, 4.5)
                tuft(16, 21, 5.5)
                tuft(7, 24, 3.8)
                tuft(25, 23, 3.5)
            }
        }
    }

    private static func memo(_ key: String, _ make: () -> SKTexture) -> SKTexture {
        if let hit = cache[key] { return hit }
        let tex = make()
        cache[key] = tex
        return tex
    }

    private static func stamp(_ size: Int, draw: (@escaping (Int, Int, (Int, Int, Int)) -> Void, Int) -> Void) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
            func set(_ x: Int, _ y: Int, _ rgb: (Int, Int, Int)) {
                UIColor(red: CGFloat(rgb.0) / 255, green: CGFloat(rgb.1) / 255, blue: CGFloat(rgb.2) / 255, alpha: 1).setFill()
                ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
            draw(set, size)
        }
        let tex = SKTexture(image: image)
        tex.filteringMode = .nearest
        return tex
    }
}
