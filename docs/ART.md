# PopFodder — Art inventory

Pixel owns this. **No Cannon Fodder / OpenFodder pixels in the tree.**
Identity (colour, type, mark, voice): [`docs/BRAND.md`](BRAND.md) — Mara, 2026-08-20. Do not add a palette or a font that is not in that file.
Gameplay tells (what each stamp must communicate): [`docs/PIXELS.md`](PIXELS.md) — Hiro, 2026-08-21. Pretty pixels that fail that file do not ship.
Last updated: 2026-08-20.

## Why GitHub has no art we can ship

The engine repo ([OpenFodder/openfodder](https://github.com/OpenFodder/openfodder)) is C++ plus loaders. Game graphics live in a **separate data pack**:

- [OpenFodder/data](https://github.com/OpenFodder/data) — labelled “Cannon Fodder Demo Data”
- `INSTALL.md`: retail art comes from a purchased DOS/Amiga/CD copy (GOG etc.), files such as `CF_ENG.DAT`

Those files are Sensible Software / Virgin / Codemasters **copyrighted game data**. OpenFodder’s GPL covers the *engine*, not the ILBMs. Demo cover-disk art is still their art.

PopFodder rules (CLAUDE.md, ROADMAP M0): original name, original art, original maps. Importing `junplay.lbm` would make a clone and an App Store / legal problem.

Look at CF on a purchased copy or public screenshots if you need a *feel* reference. Do not copy sheets into `PopFodder/Resources`.

## How CF stored graphics (roles, not files to steal)

Engine sheet types (`eGFX_Types`):

| Slot | CF file pattern | Role |
|------|-----------------|------|
| In-game army | `{jun,des,ice,mor,int}army.lbm` | Soldiers, enemies, vehicles, FX on a map |
| In-game play | `{jun,des,ice,mor,int}play.lbm` | Terrain tiles for that biome |
| Briefing heli | `{jun,des,ice,mor,int}copt.lbm` | Briefing backdrop |
| Hill | `hills.lbm` | Graveyard |
| Recruit | (recruit screen sprites) | Truck + queue of names |
| PStuff | `pstuff.lbm` | Cursor, target, sidebar weapons, HUD chrome |
| Rank font | `rankfont.lbm` | Rank pips on the hill and sidebar |
| Font | in-game font | Tiny names |
| Service | service/debrief | After-action |
| Title | `cftitle.lbm`, `sensprod.lbm`, `virgpres.lbm` | Boot — **do not echo** |

Terrain tilesets in the engine: Jungle, Desert, Ice, Moors, Interior, plus joke sets (Hid, Amiga Format Xmas). v1: **three biomes**, original palettes.

Sprite *roles* in `eSprites` (117 ids): player, enemy, grenade, rocket, bullet, explosion, trees/shrubs, doors, rank pip, shadows, blood trail, floating corpse, helis, mines, spikes, civilians, hostages, tent, jeep, tank, turrets, bonuses, call-pad, computers, CF2 UFO. We redraw only what v1 ships (below). We do not port the sheet.

## Visual principles (what to take from the *genre*, not the pixels)

1. **Readability first.** A 12–16 px soldier must silhouette on grass, dirt, and snow. Selected ring is the most important sprite in the game.
2. **Top-down, slight height.** CF is almost plan-view with a little Y-sort. Keep that. Not iso-RPG, not side-view.
3. **Faction colour, not uniforms of a real army.** Two readable palettes: ours / theirs. No UN/UK/US insignia, no CF boot, no Sensible wordmarks.
4. **Death is a drawing.** Corpse stays. Blood trail is optional juice, not gore-porn.
5. **HUD is a strip, not an RTS panel.** Names of the active group, grenade count, rank pip. Sidebar-width chrome on CF was 32px of 320 — on iPhone, a thin top or bottom bar.
6. **Programmer art until M2 is fun.** Circles with a ring are legal. ComfyUI starts after the slice gate.

Anti-references: Cannon Fodder title boot, the “war has never been so much fun” type, Jools/Jops portraits, Amiga copper hills copied 1:1.

## Inspiration lock — 2018 hut card (Pixel, 2026-08-20)

Stephan supplied a signed 16-bit illustration (two cartoon soldiers, plank hut, grass island, marked crate, dark blue void). **It does not enter the tree.** Third-party pixels, CF-adjacent faces, side-view camera. We take *craft*, not the drawing.

| Take | Leave |
|------|--------|
| Chunky Amiga-era pixels, hard edges, few colours per object | Those two faces (Jools/Jops energy) |
| Barracks = plank box + **black doorway** (spawner reads as a mouth) | Side-view / 3/4 as the *battlefield* camera |
| Crate = wood + a fat **X** (pickup / dummy blocker) | Olive-drab as the brand primary (Ours is `#38C852`) |
| Grass as a tufted island, palms as *biome noise* not cover | Signature, watermark, this PNG in `Resources` |
| Toy-soldier boots, simple rifles, “about to do something stupid” | Real-army pockets, rank insignia, portraits in the HUD |
| Recruit/key-art *may* show original cartoon faces | Copying this composition 1:1 |

**Camera split (locked with Mara)**

- **In-play:** top-down, slight height. Helmets, not faces. See existing `docs/trailer/key-art.jpg`.
- **Roster / press stills:** this card’s *job* is allowed — a hut, a crate, two original people on a grass island — if the faces and palette are ours.

**Prop language from the card**

- Hut / barracks: olive-brown planks, roof as a simple slope, door = hole. Doorway is the silhouette, not windows.
- Crate: Brass lid or Brass X on brown. Must read at 20px.
- Foliage: grass nubs + one or two palm fronds on jungle maps only. Bushes slow; they do not hide.

Original concept stills (not engine sheets) in `docs/art-ref/`:

| File | Job |
|------|-----|
| `play-view.jpg` | Battlefield camera: hut + crate + helmets, no faces |
| `infantry-top.jpg` | Single Ours infantryman, top-down stamp target |
| `barracks.jpg` | Hut with doorway as mouth |
| `crate.jpg` | Pickup / dummy blocker, Brass X |
| `recruit-card.jpg` | Roster/press job of the 2018 card, original faces |

Engine stamps: **32px infantry** (8-dir idle), 32px turret/VIP, 40px jeep/hut. Nearest-neighbour, 1:1 at default zoom. Do not ship the `docs/art-ref/` JPGs as sprites.

## v1 production list (original)

Ship these. Nothing else until M4 has bandwidth.

### Must (M2 slice)

| Asset | Notes |
|-------|--------|
| Player soldier | 8 directions, idle + walk. One silhouette. Rank does not need a new body. |
| Enemy infantry | Same rig, different palette |
| Selected ring | Fat enough for a finger. Highest contrast in the game. |
| Corpse | One pose. Stays on the map. |
| Name strip / rank pip | Bitmap font or system font + 8 rank marks |
| Grass, dirt, wall tiles | Seamless-enough at iPhone scale |
| Dummy blocker | Crate or hut if walls aren't ready |

### Should (M2–M3)

| Asset | Notes |
|-------|--------|
| Turret | Unmistakable; rifles spark off it |
| Grenade + blast | Must read “don't stand in this” |
| Bullet / tracer | Tiny. Optional if muzzle flash is enough |
| Water + sink tile | Sink must look lethal |
| Bush | Slow, does not hide |
| Building / barracks door | Door = spawner |
| Jeep | Top-down, seats the squad visually |
| VIP / hostage + tent | Different silhouette from soldiers |
| Grave markers × rank | 8 steps, cheap grandeur |

### After M2 gate (M4)

| Asset | Notes |
|-------|--------|
| 3 biome palettes | Not jungle/desert/ice copies — same *roles* (hot, cold, wet) |
| App Icon | Original. No boot. |
| Recruit queue screen | Living names vs hill |
| Explosion / muzzle / water splash | Juice |
| Cursor is a finger — no mouse-target sprite required | |

### Not v1 art

Helicopters, tanks, call-pads, spear-natives, snowmen, birds, boiling pots, CF2 UFO, invuln turrets, title boot, Virgin/Sensible cards.

## Pipeline

```
ComfyUI (Pixel) → comfyui/output/ → review → post-process
  → PopFodder/Resources (or Assets.xcassets)
```

SpriteKit: 2×/@3x, nearest-neighbour for pixel. Language is locked in [`docs/BRAND.md`](BRAND.md): stamps, not mixed vector UI. Key-art (`docs/trailer/key-art.jpg`) is the illustration north star; in-engine 16px blocks are the same dialect, not a second style.

M1: coloured `SKShapeNode` circles. That is correct.

## If you want to *look* at CF art

1. Buy Cannon Fodder on GOG and run OpenFodder against your data.
2. Watch a playthrough.
3. Do not dump `OpenFodder/data` into this repo.

The engine sprite ID list in OpenFodder `Source/Sprites.hpp` is enough to know what *kinds* of pictures existed. We already mined that for systems. We do not need the bits.
