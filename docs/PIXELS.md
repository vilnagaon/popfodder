# PopFodder — Pixel design (gameplay)

**Hiro · 2026-08-21.** How stamps *play*. Palette and mark: [`BRAND.md`](BRAND.md). What to draw: [`ART.md`](ART.md).
If a prettier pixel does not change a decision, it is juice. Juice ships after the tell.

Pixels are the UI. Auto-fire means the player never aims. They only *read the field* and spend names. If Ours and Theirs collide at 22pt, the economy is invisible and the game is a noise toy.

---

## Design Summary

A PopFodder stamp has one job: make the next tap honest.

The 30-second loop is **select → walk → someone dies**. The pixel loop is **ring → path → body on the grass**. Rank, grenades, jeeps, turrets exist so that picture has a trade: bunch vs split, open vs wall, rookie vs the name you like. Faces do not belong on the field. Names belong in the strip. The body that stays is the receipt.

---

## Core Loop (what pixels must answer)

```
TAP (whose ring?) → ORDER (where is the dirt?) → AUTO-FIGHT (who faces whom?)
        → CASUALTY (grey stamp + name leaves the strip) → NEXT TAP
```

| Timescale | Pixel job |
|-----------|-----------|
| **30 seconds** | Ring, faction colour, a corpse that stays |
| **30 minutes** | Same body, dearer name. Rank is a digit, not a new costume |
| **30 hours** | A hill of *words*, not of crosses. Play-view never grows portraits |

Sid Meier test, every stamp: **does this picture create or explain a trade?** If not, cut it.

---

## Information budget (strict)

At default camera, infantry draws at **32×32 pt** (1:1 with a 32px stamp). Pinch goes 0.55–2.2, so the same stamp must silhouette at ~18 pt. 16px was too few pixels for a round helmet; **48px is a portrait, not fodder.** 32 is the lock.

Read order, top to bottom. Nothing below a line may fight the line above.

| Rank | Channel | Live in 1.0 | Rule |
|------|---------|-------------|------|
| 1 | **Selection ring** | Brass pulse / ivory hold | Fattest stroke in the game. Finger-sized. Not a costume |
| 2 | **Faction colour** | Ours `#38C852` / Split `#269EB8` / Theirs `#DC2824` | Same rig, palette swap. No extra kit |
| 3 | **Silhouette** | Infantry blob, turret box, VIP gold, jeep slab, hut + door | Kind must parse before colour |
| 4 | **State** | Dead grey, jeep occupied/empty, barracks alive/dead, crate taken | Binary. No HP bar, no wound frames |
| 5 | **Facing** | 8-dir idle on the 32px stamp | Who is shooting. Rifle + visor. No `zRotation` on infantry |
| 6 | **Name / rank** | HUD strip `ADA·3` | Never on the sprite. The veteran looks like the rookie |

If two channels say the same thing, delete one. Rank-on-helmet *and* `·3` is twice the same fact and ruins the joke (they all look like fodder).

---

## Systems Breakdown

### 1. Infantry (the resource)

**Intent:** People are cheap to look at and expensive to like. One silhouette. Colour is team. Death is a recolour, not a ragdoll.

**Rules**

1. One body for Recruit through General. Rank does **not** grow a hat.
2. Player group 0 = Ours. Group 1 = Split. Enemy = Theirs. Dead = `(70,70,70)` head+body, no Brass pack.
3. Facing follows target, else walk vector. Sheet is 8 directions when it exists; until then rotate the stamp (current).
4. Walk cycle: **2 frames**. Idle = frame 0. More frames are juice.
5. Corpse keeps the same footprint and stays until the mission ends. Walkable. Memory, not geography.
6. In jeep: hide body + ring. The jeep *is* the squad.

**Parameters**

| Param | Default | Why |
|-------|---------|-----|
| Source stamp | **32 px**, nearest | Room for a round faction helmet. Not 16 (blob), not 48 (portrait) |
| Draw size | **32 pt** infantry / 40 pt turret | 1:1 pixels at default zoom. Turret must stay bigger than a man |
| Directions | 8 | Facing is the combat tell |
| Walk frames | 2 | Readable at 12 pt; 4-frame is polish |
| Dead alpha | 0.85 | Present, not a ghost |

**UI:** ring around the body, names in the strip. No floating nameplates (they hide the field).

**Edge cases:** two overlapping soldiers → nearest to touch (already). Dead tap is a no-op. Split group’s ivory ring must still read on snow.

**Dependencies:** Combat (facing), Soldiers (names), Selection (ring).

### 2. Selection ring (the verb)

**Intent:** The only verb is “these people.” The ring is the cursor. It is more important than the soldier art.

**Rules**

1. Active group: Brass, line 2.5, pulse. Hold group: Ivory, line 1.2, no pulse.
2. Hidden in vehicle. Hidden on corpses.
3. Radius = `soldierRadius + 5` so the finger has a donut, not a halo on the helmet.
4. Waypoint crumbs: Brass dots, z below soldiers. Max 4. They are the queued path, not decoration.

**Do not** replace the ring with a highlight shader, a triangle, or a CF-style mouse target. Touch has no cursor.

### 3. Terrain (the map of trades)

**Intent:** Tiles are decisions, not wallpaper. If a bush looks like a wall, players turtle. If sink looks like a puddle, they walk in and call it a bug.

| Tile | Decision | Must look like | Must not look like |
|------|----------|----------------|--------------------|
| Grass / dirt / ice | Mood. Walkable | Biome field from BRAND | Camo, paths that fake cover |
| **Wall** | Blocks walk + LOS | Dark slab, hard edge | Bush, crate, hut |
| **Bush** | Slows. Does **not** hide | Sparse tufts, you still see the soldier | Wall, shadow, concealment |
| **Sink** | Lethal | A hole. Darkest thing on the map | Water you can ford, pretty lake |
| Extract `HOME` | Leave | Brass ring + word | A building |

Biome palettes (grass / dirt / snow) retint **fields only**. Faction colours never retint. Ours on snow must still be Ours.

Current 1.0 tiles are flat `SKSpriteNode` colours. That is legal until Pixel stamps. The *roles* above do not change when the texture arrives.

### 4. Threats and tools

Each prop exists because rifles are not enough (M0: turrets ignore bullets; grenades tax bunches).

| Thing | Decision it creates | Pixel tell |
|-------|---------------------|------------|
| **Turret** | Spend a grenade / rocket or go around | Box, bigger than a man, Theirs, gun snout. Rifles spark, it does not flinch |
| **Barracks** | Kill the mouth or it keeps pouring | Plank hut, **black doorway**. Dead = door gone / grey |
| **Crate G** | Pickup grenade | Brass crate + X or `G`. Colour = Brass |
| **Crate R** | Pickup rocket | Orange crate + `R`. Distinct from G at 16 pt |
| **Jeep** | Speed vs sitting-duck | Slab from above. Empty / occupied (Ours tint) / dead grey |
| **VIP** | Save them vs save the veteran | Gold body, different silhouette, no rifle |
| **Blast** | Don’t stand here | Filled Brass/orange circle at grenade radius **before** it kills, or the puff is a lie |
| **Tracer** | Who fired | 1–2 px Theirs or Ivory line. Tiny. Optional if muzzle exists |

Letters on crates (`G`/`R`) are allowed. They are comprehension, not HUD chrome. A painted X alone cannot tell grenade from rocket — keep two colours.

### 5. Death and the hill

**Intent:** Cheap on the field, dear on the roster.

- Field: grey stamp, same pose, stays.
- Strip: name vanishes this frame. That is the flinch.
- Graveyard: green mountain, **slab tombstones + type**, never crosses. `ALL DEAD` in Theirs. Living names in Ours, infantry stamps queued under them.

No blood trail in v1. Optional juice after the grey stamp is readable. Gore-porn fails 12+ and fails “death is a drawing.”

### 6. Chrome (not a battlefield)

Title disc, Menlo, `TAP TO SPEND THEM` — Mara. Play HUD is a strip: names, `G n  R n`, jeep affordance. Buttons stay type, not illustrated icons, until the strip is crowded. An illustrated grenade that is smaller than the word `G` is a downgrade.

---

## Economy Model (visual)

The resource is **named bodies**. Pixels are the ledger.

| Resource | Source (see) | Sink (see) | Exchange |
|----------|--------------|------------|----------|
| Living name | Ours/Split stamp + strip | Grey stamp, name gone | Who walks point |
| Rank | Digit in strip | Same body | Accuracy, not HP |
| Grenade / rocket | Brass / orange crate | Blast circle | Turret vs clump |
| Time / position | Facing + waypoints | Corpse where you left them | Path vs open ground |
| Second group | Split colour + ivory ring | Merge on contact | Bunch tax vs micro |

Scarcity: later maps must still *look* like four tiny people against a red box. Do not grow the soldier art to feel “epic.” Epic is a General’s name on the hill.

---

## Balancing Notes

**Levers that are pixels, not numbers**

| Lever | If the game feels… | Tune |
|-------|--------------------|------|
| Can’t tell who is selected | muddy | Thicker Brass ring, slower pulse |
| Can’t tell Ours / Theirs | muddy | Push saturation; never recode via outline only (colourblind: ring + silhouette still work) |
| Bush used as cover | wrong read | Lighten bush, keep soldier fully opaque on it |
| Sink deaths feel cheap | sink looks like ice | Darker hole, slight inset, no sparkle |
| Turret melted by rifles | silhouette too “man-like” | Bigger box, no helmet |
| Veteran hoarded as a different unit | rank costume crept in | Revert body; keep `·N` |
| Zoom-out chaos | stamps busy | Drop walk-frame 2, drop tufts, keep ring |

**Colourblind:** faction is colour *and* (player = Brass pack glint, enemy = none). Ring is shape. Do not ship a red/green-only tell without the pack glint.

**Degenerate art**

- Camo tiles that hide enemies → forbidden (transparent complexity).
- Unique veteran skins → forbidden (economy is names).
- Side-view faces on the map → forbidden (camera split, ART.md).
- HP pips → forbidden (one-shot is the joke).

---

## Player Experience Timeline

| Moment | What they must see |
|--------|--------------------|
| First 5 s | Brass ring on green blobs. Tap dirt. They walk |
| First death | Grey stamp stays. Name missing from strip. The joke lands |
| First turret | Red box does not fall over. Crate `G` exists on the map |
| First split | One clump green, one cyan. Ivory ring on the idle group |
| First jeep | Bodies vanish, slab tints Ours, they are fast and stupid |
| Graveyard | Slabs on a green mountain. Same Menlo as the strip. Recruits queued below the names |

If Pixel’s sheet ships and a stranger still needs a tutorial overlay, the silhouettes failed. Teach with THE GAP, not with a coach mark.

---

## Implementation Priority

Engine already has stamps. Replace in this order so each drop changes play, not wallpaper.

| # | Asset | Why first | Owner |
|---|--------|-----------|-------|
| 1 | Infantry 16px: Ours / Split / Theirs / Dead, 1 dir | Economy is these four | **In `Art.infantry` 2026-08-21.** Same rig, Brass pack on player only. `GameScene` rotates facing − π/2 |
| 2 | Same, **8 directions** (idle) | Facing = who dies | **32px idle 2026-08-21.** Helmet = faction disc. `zRotation` 0 |
| 3 | Walk 2-frame on those 8 | Motion is the order feedback | **In `Art.infantry` 2026-08-21.** Stride while `path` is non-empty, 0.12s/frame |
| 4 | Turret 20px | Makes grenades a decision | Pixel |
| 5 | Barracks + black door / dead | Spawner is a mouth | **In `Art.barracks` 2026-08-21.** 40px planks; dead fills the mouth |
| 6 | Crate G / crate R | Pickup without letters-only | **In `Art.crate` 2026-08-21.** Brass+X+G vs orange+chevron+R |
| 7 | Jeep empty / occupied / dead | Vehicle is a state machine | **In `Art.jeep` 2026-08-21.** Hood +X; empty khaki, occupied Ours+helmets, dead grey |
| 8 | VIP gold | Escort reads | **In `Art.vip` 2026-08-21.** Gold disc, no rifle, ivory collar; 8-dir + walk + dead |
| 9 | Wall / sink / bush tiles | Terrain trades | **In `Art.wall/sink/bush` 2026-08-21.** 32px 1:1. Bush is tufts on alpha |
| 10 | Blast disc + tracer | Cause → effect | **2026-08-21.** Disc at true radius on frame 0 (Brass G / orange R). Tracer 1.25px Ivory/Theirs |
| 11 | Grass tufts as noise | Last. Mood only | **In `Art.tuft` 2026-08-21.** 16px, 1-in-4 grass / 1-in-7 snow, z under units |

Do **not** start with recruit-card faces, 4-frame walks, blood, or biome wallpaper. Those fail the Sid Meier test.

Sheet contract when Pixel leaves `Art.swift` stamps:

- PNG, nearest-neighbour, **32 px** infantry, 40 px jeep/hut.
- Magenta or empty alpha, no baked grass.
- Layout: rows = direction (N, NE, E, SE, S, SW, W, NW), columns = idle / walk1 / walk2 / dead.
- One sheet per faction **or** one sheet + palette swap. Palette swap is cheaper and keeps the “same body” rule honest.

Ada/presentation: `GameScene` already swaps `Art.*` textures. New frames = new `Art` keys, not a new node graph.

---

## References

| Game | What we steal | What we don’t |
|------|---------------|----------------|
| Cannon Fodder | Tiny top-down tells, corpse stays, sidebar-as-strip | Their pixels, hill, boot, faces |
| Into the Breach | One glance = the whole trade | Grid, mechs, yellow threat tiles as a system |
| Advance Wars | Faction palette = team | Portraits, HP pips |
| RimWorld | Bodies as memory | Detail zoom, blood |
| The Settlers | Goods (here: crates, door) readable at a distance | Iso camera |
| Theme Hospital | Cause/effect in the picture (sink = hole, turret = box) | Comedy gibs |

---

## Owner split

| File | Who | Pixels mean |
|------|-----|-------------|
| This file | Hiro | Decisions, order of work, tells |
| `BRAND.md` | Mara | Brass, Menlo, disc, voice |
| `ART.md` | Pixel | Inventory, inspiration lock, pipeline |
| `Art.swift` | Ada | What is on screen today |

A stamp that violates this file does not ship, even if it looks like the 2018 hut card.
