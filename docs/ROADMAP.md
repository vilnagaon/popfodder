# PopFodder — Design & Roadmap

Living spec. If a system is not in this file, it is not in the game yet.
Last updated: 2026-08-20 (OpenFodder archaeology pass). Owner: Hiro (design), Rex (phase gates).
**M0 signed off 2026-08-20:** 2-group cap, one-shot infantry, no aim stick.
**1.0.0 in-tree.** Trailer in `docs/trailer/`. Publish GPL source before any binary.
OpenFodder (`github.com/OpenFodder/openfodder`) was read as **rules archaeology**, not as a port. See appendix. No OpenFodder source, assets, or names enter this tree.
Graphics: CF pixels are **not** in the engine repo; they are copyrighted data ([OpenFodder/data](https://github.com/OpenFodder/data) demos + retail DAT). We do not import them. Rebuild list: [`docs/ART.md`](ART.md). How stamps play: [`docs/PIXELS.md`](PIXELS.md). Brand lock: [`docs/BRAND.md`](BRAND.md).

---

## Design Summary

PopFodder is a top-down iOS squad-tactics action game. You tap named soldiers, send them across a battlefield, and they die with their names still on the roster.

The shooting is automatic. The game is **who you spend**. Every order is a trade: speed versus cover, bunch versus split, rookies versus the veteran you have been keeping alive. War is loud, short, and a little funny. It is never a Codemasters/Sensible reskin — original names, original maps, original art.

**One sentence:** Tap your squad. Take the objective. Try not to spend the people you like.

**Platform:** iPhone / iPad, iOS 17+, SpriteKit, landscape.
**Quality bar:** Cannon Fodder's *feel* (direct orders, cheap death, named bodies), not its content. Touch-native, 2–5 minute missions.
**Team:** Stephan + Gampa agents. Treat velocity as one focused builder, not a studio floor.
**Engine decision (locked):** reimplement in Swift. OpenFodder is a rules reference, not a port. GPL-3.0 stays.

**Kill criterion:** if the vertical slice is not tense and a bit funny, stop. Do not produce twelve maps of a dull loop.

---

## Core Loop

```
SELECT → ORDER (move / hold / split) → AUTO-FIGHT → CASUALTY OR GROUND TAKEN → NEXT ORDER
         ↑                                                                    |
         +--------------------- named soldier is cheaper or dearer -----------+
```

| Timescale | Loop | Payoff |
|-----------|------|--------|
| **30 seconds** | Tap, walk, someone shoots or dies | A corner taken, a body on the grass |
| **30 minutes** | 3–4 missions, one soldier ranks up | You start protecting a name |
| **30 hours** | Full campaign + graveyard | A General. Or a hill of people you remember. |

Sid Meier test, every minute:

1. Bunch (safer vs rifles, dead vs a grenade) vs split (coverage, micro, friendly-fire risk).
2. Open ground vs cover vs a longer route.
3. Who walks point — the rookie you can spare, or the veteran who will actually hit.
4. Spend the grenade now, or keep it for the turret you have not seen yet.
5. Push the objective vs extract the wounded name you like.
6. Straight line vs a queued path around cover (once waypoints exist).
7. Save the VIP vs save the veteran (once escort exists).

If a feature does not create one of those, it does not ship.

---

## Systems Breakdown

### 1. Selection & Movement

**Intent:** Cannon Fodder's mouse, translated to a finger. The squad is a clump you steer, not an RTS box-select.

**Verb:** tap people, tap dirt.

**Rules**

1. Tap a soldier → that soldier is the selection. Others deselect unless already in the same group.
2. Tap empty ground → selected group walks there in formation (clump, not a parade). **M1:** one destination. **M2 Should:** taps *append* a short waypoint queue (max 4). Tap the selected leader to cancel the path. This is Cannon Fodder's actual move model (queued clicks, not one point).
3. Double-tap a soldier, or tap an already-selected soldier → add/remove from selection (split).
4. Tap a soldier in the *other* group → switch control to that group. Unselected group holds and auto-fires.
5. Two groups that walk into each other merge (if the cap allows). That is how you regroup without a menu.
6. Two groups max in v1. OpenFodder's engine hard-cap is 3; a third split on a phone is cruelty.
7. Soldiers walk in straight lines until terrain blocks them. No A* in M1. Add pathfinding when the first wall exists.
8. Camera: drag to pan, pinch to zoom. After an order, the camera eases toward the destination (CF pans to the click). The finger that orders is not the finger that looks.

**Parameters**

| Param | Default | Min | Max | Why |
|-------|---------|-----|-----|-----|
| Walk speed | 120 pt/s | 80 | 180 | Readable on iPhone; must feel brisk |
| Formation spacing | 28 pt | 20 | 40 | Tight enough to read as a squad |
| Select radius | 28 pt | 22 | 36 | Fat finger, small sprites |
| Max squad on map | 4 | 2 | 6 | CF cap was 6; 4 is the iOS default |
| Max simultaneous groups | 2 | 1 | 2 | v1. Raise only after playtest |
| Waypoint queue | 1 (M1) / 4 (M2+) | 1 | 4 | CF queues up to 30; four is a finger, not a mouse |

**UI:** selected soldiers get a ring. Names of the active group sit in a thin strip (top or bottom). No analog sticks. No aim joystick.

**Edge cases:** tap two overlapping soldiers → nearest to touch. Dead soldier taps do nothing. Order issued into fog/off-map → clamp to walkable.

### 2. Combat

**Intent:** you command position, not shots. Auto-fire is the point of the genre on touch.

**Translation (locked):** Cannon Fodder aims with the *right mouse* at the cursor while the left click queues a walk. That is a mouse dual-stick. On iPhone it becomes an aim joystick, which M0 forbade. We keep **auto-fire at nearest visible enemy**. Skill lives in where you stand and which path you queued, not in a stick.

**Verb:** none. Combat is a consequence of where you stood.

**Rules**

1. A living soldier auto-fires at the nearest visible enemy in range and line of sight.
2. Infantry bullets kill infantry in one hit. That is the joke and the tension. Do not add HP bars to grunts.
3. Line of sight is blocked by walls, buildings, dense trees. Bushes slow; they do not hide.
4. Facing follows the current target, else the move vector.
5. Friendly fire: bullets do not hurt allies. Grenades do. That is the split-vs-bunch tax.
6. Enemies use the same combat rules. They are not given extra HP or omniscience.
7. No manual aim in v1.
8. Rank changes **accuracy** (shot spread), not HP and not a big range bump. Rookies spray. Veterans hit. That is OpenFodder's `mDeviatePotential` from rank. We keep 8 display ranks; spread is the lever.
9. Enemy **turrets** (and later vehicles) ignore rifles. They exist so grenades/rockets are a decision, not a toy.

**Parameters**

| Param | Default | Notes |
|-------|---------|-------|
| Rifle range | 180 pt | Shorter than a screen; closing is a decision |
| Rifle cooldown | 0.35 s | Brisk; deaths cluster |
| LOS sample | 8 Hz | Cheap; SpriteKit |
| Enemy reaction delay | 0.15–0.40 s | High-aggression maps sit at the low end (OpenFodder per-phase `sAggression`) |
| Shot spread (recruit → general) | wide → tight | Rank's only real combat bonus |
| Grenade blast radius | 64 pt | Must punish a bunched squad |

**Degenerate strategies to watch**

- Turtle in a corner → maps need patrols that hunt, or a mission timer that fails you.
- Suicide rush → allowed on early maps; later maps require a veteran who only exists if you didn't rush.
- Four micro-squads → blocked by the 2-group cap.

### 3. Soldiers (the economy)

**Intent:** people are the resource. Names create attachment. Rank is the scar that makes the next death worse.

**Rules**

1. Every soldier has a unique name from an original list (short, shoutable, 2–8 letters). Never Jools, Jops, Stoo, RJ, or any name in OpenFodder's `mRecruits[]` (360 entries, JOOLS…FODDER).
2. Death is permanent for that name. The body stays until the mission ends. The graveyard keeps them. Kill count may sit on the grave quietly; do not make a stats screen.
3. Survivors of a *phase* gain one rank (OpenFodder: `mPhaseCount` then `Promote()`, cap 15). We cap at 8 display ranks.
4. Rank's mechanical bonus is **accuracy** (tighter spread). Narrative is the rest.
5. New recruits do not stay green forever. Incoming rank ≈ `floor((missionIndex - 1) / 3)` so the campaign's later fodder can shoot, and a *surviving* veteran is still special.
6. After a won mission the pool gains **+15** names (OpenFodder: `mRecruits_Available_Count += 0x0F`). You do not buy soldiers. Cap = name-list length, fail if living pool < 2.
7. The soldier you like is the one you should not send first. The system must make that hurt.

**Parameters**

| Param | Default |
|-------|---------|
| Starting pool | 15 |
| Replenish per won mission | +15 |
| Name list | 200+ original names (Sage). Engine names 360; we do not copy them. |
| Ranks | 8 steps, Recruit → General |
| Incoming recruit rank | `floor((mission - 1) / 3)` |
| Squad on a map | 2–4 (OpenFodder allocates up to 9; CF play is 2–6). iOS default 4. |

**UI:** roster before the mission (names + rank). In-mission: names of the active group. After: who lived, who didn't, one line, no sermon.

### 4. Terrain

**Intent:** the map is the other player. Open ground is a bet.

**Rules**

1. Tiles: grass, dirt, water, wall, bush, building, **sink** (lethal: quicksand / deep), snow/ice (slow).
2. Walls and buildings block walk and LOS. Some buildings are **spawners** (barracks door): kill the building or it keeps producing. That is why "destroy buildings" is a different objective from "kill all".
3. Water is walkable and slow (0.5×). No swimming minigame. Bodies can float. Deep/sink tiles kill; do not stand there.
4. Bushes slow (0.75×) and do not block LOS. Snow/ice slow (0.7×).
5. Map size for v1 missions: roughly 2–3 screens. Maps bigger than that get a peek/minimap in M4 (OpenFodder retail `M` show-map).
6. OpenFodder also has jump tiles, rocky height, flyable vs driveable vs walkable masks. We only need walk/block/slow/kill for v1.

Pathfinding arrives with the first wall, not before. Vehicles use a stricter "not driveable" mask when they exist.

### 5. Mission

**Intent:** a mission is a short, complete sentence. Kill, destroy, or reach. Then get out or the next phase starts.

**Rules**

1. A mission is 1–3 phases (maps in sequence, same squad). Each phase can set **aggression min/max** (OpenFodder `sAggression`) — how eagerly enemies close and shoot.
2. Objectives. OpenFodder has ten (`ePhaseObjective`). v1 uses four, one primary per phase:
   - (a) kill all hostiles
   - (b) destroy tagged buildings (spawners, not flavour huts)
   - (c) reach an extract zone
   - (d) extract a VIP/hostage to a tent or zone — **this is the other half of the genre.** Kill-all is the tutorial; escort is the interesting decision.
3. Optional **protect** modifier: flagged civilians/VIP dying fails the phase. Do not spray.
4. Fail if the whole squad is dead. Fail if the pool cannot fill a minimum squad of 2. Abort/retry the *phase* (OpenFodder ESC) — deaths already spent stay spent.
5. Win the campaign by finishing the mission list. There is no meta city-builder.
6. Missions are data (JSON), not code. Phase may also list starting grenades/rockets (OpenFodder `cPhase.mGrenades` / `mRockets`, -1 = default).

Cut from OpenFodder's list until after v1: kidnap leader, destroy factory/computer as separate types (use tagged-destroy), activate all switches (CF2), spear-natives as a faction.

**Tutorial (Sage later, structure now):**

```
Tap-to-move (empty field, no enemies)
  → first contact (one enemy, you will probably win)
  → first death (scripted or likely; the name stays on the graveyard)
  → split (two groups, a bait)
  → grenade (one pickup, a bunched enemy)
  → escort (one VIP, one tent) — later mission, not the first five minutes
  → player is free
```

One concept per beat. No popup walls.

### 6. Meta: the graveyard

**Intent:** this is the 30-hour game. The hill of names is the product.

**Rules**

1. After every mission you see the graveyard: a green mountain of the dead, living names, then a line of infantry stamps queuing for the next job.
2. Higher rank → a slightly taller slab. Cheap to do, high meaning. Markers are tombstones, never crosses.
3. No sermons, no stats dump. Names on the stones are enough.
4. A "protect this one" pin is **not** in v1. Attachment must be earned, not a UI toggle.

### 7. Explosives (M3, not M1)

Grenades and rockets come from two sources: **phase loadout** (a few in the pocket) and **map boxes**. Shared by the group. On split, the leaving group takes **half** (OpenFodder: All / Half / None UI — we skip the widget, always half). Tap an explosives button, then tap a point. Infantry rifles cannot kill vehicles or turrets. That creates the "save it" decision.

### 8. Vehicles (M3, one type)

One jeep (or equivalent): faster, has a mounted gun, dies to rockets, traps everyone inside if it explodes. Enter by walking into it as a group (OpenFodder: walk in, `eSprite_Anim_Vehicle_Enter`). Exit on command.

No helicopters, call-pads, tanks, boats, homing missiles, or invulnerable turrets in v1. OpenFodder's `eVehicles` list is a warning, not a backlog.

---

## Economy Model

Soldiers are the only resource that matters.

```
POOL (source) → DEPLOY → COMBAT (converter: rank, or death) → GRAVEYARD (sink)
                     ↓
              OBJECTIVE (progress)
```

| Flow | What |
|------|------|
| Source | Starting 15 + 15 per won mission. Name list is the hard cap. |
| Converter | Survive a phase → +1 rank (accuracy). New bodies enter at campaign-scaled rank. |
| Sink | Death. Also: fail the campaign if pool < 2 |
| Informal exchange | A veteran "costs" more than a recruit because replacing *their* accuracy takes phases you may not have |

There is no money, no shop, no XP grind, no gacha. Rank-from-survival is the whole progression curve.

**Scarcity:** early missions leak a little (you can afford to be sloppy). Mid missions leak at replacement rate. Late missions leak faster than replenish unless you play well. If the player finishes the campaign with a full pool and no favorite dead, we made it too easy.

---

## Balancing Notes

**Three knobs (difficulty, later):** enemy count, patrol aggression, explosive scarcity. Never give enemies extra HP on "hard."

**Levers we will actually turn**

| Lever | Effect |
|-------|--------|
| Rifle range | How early the decision starts |
| Formation spacing | Grenade punish |
| Replenish rate | How much a death "costs" the campaign |
| Phase length | How long you can babysit a veteran |
| Patrol hunt radius | Anti-turtle |

**Known risks**

- Auto-fire feels like the game is playing itself → fix with map geometry, not with a joystick.
- Names don't stick because they flash too fast → keep the graveyard visit mandatory and short.
- Touch mis-taps cause cheap deaths → generous select radius, undo is **not** allowed (death is the point) but mis-select must be rare.
- Clone accusations → original art, original names, original maps, no Sensible audio.

**Power curve:** a General should *hit* more often than a Recruit, not tank more. If veterans become immortal the graveyard dies.

---

## Player Experience Timeline

| Time | What they learn | What they feel |
|------|-----------------|----------------|
| 0–30 s | Tap moves the clump | "This is simple" |
| First death | Names are real | "...oh" |
| First split | I can bait | Clever |
| First grenade on my own bunch | I did that | Funny-awful |
| Mission 4 | I have a favorite | Protective |
| Mission 10 | The favorite is now too valuable to use and too useful not to | The actual game |
| Credits | The hill is full | One more run, fewer names |

Replayability: casualty-count pride, "get someone to General," later daily/seeded maps if anyone asks. Not in v1.

---

## Original identity (non-negotiable)

PopFodder is **in the spirit of** Cannon Fodder. It is not a skin.

| Keep (system) | Leave (IP) |
|---------------|------------|
| Tap-to-order squad | Sensible/Codemasters names, boots, map art |
| Auto-fire + split | "War has never been so much fun" and any CF audio |
| Named permanent death | Jungle/Arctic/Desert as 1:1 copies |
| Graveyard as meta | OpenFodder C++, assets, or map files |

**Working fiction (Sage to replace):** a staffing desk for wars that are already over in the papers. You send people. The credits roll either way. Tone: dry, short, Belgian-bleak not Hollywood-heroic.

Pixel: readability first. Tiny soldiers must silhouette against grass, dirt, snow. Selected ring is the most important sprite in the game. Programmer art until M2 is fun.

Lyra: a short, whistling theme and punchy gun/grenade barks. No licensed anything.

---

## Implementation Priority

Build in this order. Do not skip a gate.

### M0 — Concept lock ✅ 2026-08-20

**Proves:** we know what the game is, and what it is not.

- [x] Swift reimplementation, not an OpenFodder port
- [x] GPL-3.0 retained
- [x] Core loop and soldier-as-resource economy written down
- [x] Sign-off: 2-group cap, one-shot infantry, no aim stick

**Exit:** this document is the spec. Arguments happen here, not in code. Locked.

### M1 — Prototype ✅ code 2026-08-20 — **playtest next**

**Theme:** four named circles that already feel like a squad.

**Must**

- [x] `Soldier` as data (id, name, rank, alive, position, groupId)
- [x] 4 soldiers, tap-select, tap-move, formation clump (single destination)
- [x] Split / merge (2 groups); tap the other group to switch
- [x] Auto-fire + LOS (empty map is fine; a few dummy blockers). Rank may exist as data; spread can wait.
- [x] One-shot death, body stays
- [x] Programmer art only (circles + selected ring + name strip)
- [x] Camera pan + pinch zoom (Should)

**Must not:** tilemap polish, vehicles, explosives, App Icon, ComfyUI, pathfinding beyond "stop at wall."

**Exit / playtest:** can you pick one guy, pick the squad, bait with the unselected group, and lose someone whose name you noticed? If no, iterate here. Do not start M2.

**Size:** S/M tasks, one sprint.

### M2 — Vertical slice ✅ code 2026-08-20 — **playtest / kill-pivot next**

**Theme:** one complete mission you can win or lose, including the joke at the end.

**Must**

- [x] One tilemap, a few walls, grass/dirt
- [x] 4 player vs ~6 infantry **and one turret** that rifles cannot kill
- [x] One grenade pickup (even if the full explosives system is stubby)
- [x] Win (destroy the turret) / lose (squad wiped)
- [x] Named roster in, graveyard out
- [x] Pan/zoom camera; camera eases toward the last order
- [x] Mission as JSON (`Resources/Missions/the-gap.json`)
- [x] Should: waypoint queue, max 4 points

**Art:** still placeholders, but silhouettes and faction colors must read at iPhone distance.

**Exit:** a stranger plays it once and says some version of "I felt that death." If they say "cool demo" and forget the names, the slice failed.

**Kill / pivot gate:** this is the only official one. Fun here → continue. Flat here → redesign the loop, do not add maps.

### M3 — Systems complete ✅ code 2026-08-20

**Theme:** every v1 system exists once.

- [x] Explosives (grenade + rocket): loadout + boxes; split takes half
- [x] Cover/LOS on tiles; ice slow; lethal sink
- [x] A* around walls (no corner-cutting)
- [x] Jeep: walk-in, drive, mounted gun, rocket kills it and the riders
- [x] Barracks spawns until destroyed
- [x] VIP extract (`THE WALK`)
- [x] Patrols hunt; per-map aggression
- [x] 3 maps, 3 palettes: `the-gap` (choke/grenade), `the-yard` (jeep/barracks), `the-walk` (escort/sink)
- [x] Pool of 15, +15 on win, incoming rank `(mission-1)/3`

**Exit:** play the three-job run. Feature-complete for *systems*, not content.

### M4 — Content alpha ✅ code 2026-08-20

**Theme:** a short campaign that has a beginning, a cruel middle, and an ending.

- [x] 12 missions, 1–3 phases (17 maps). See `Resources/campaign.json`
- [x] 3 biomes (grass / dirt / snow palettes)
- [x] Original pixel stamps + App Icon (no CF art, no ComfyUI yet — Pixel still owns a later pass)
- [x] 220 original names (`names.txt`) + hill of graves
- [x] SFX: shot, explode, death, pickup, jeep, win, lose
- [x] Pool exhausted ends the war
- [x] Play log: `Documents/playlog.txt`

**Cut list used:** 9–12 remix earlier jobs, harder. No extra vehicle skins.

**Exit:** campaign playable start to finish. Bugs allowed. Content frozen.

### M5 — Beta ✅ code 2026-08-20

- [x] Balance: enemy rifle volley gated (0.2s), rank miss chance, slower turret, slower barracks, shorter hunt
- [x] Touch: fatter select (36pt), pan slop 24pt, larger HUD hit boxes
- [x] Perf: cached pixel textures; map is a backdrop + non-fill tiles, not 400 sprites
- [x] GPL offer in-app (SOURCE screen) + README. Public repo: [vilnagaon/popfodder](https://github.com/vilnagaon/popfodder).
- [x] Privacy manifest, encryption exempt, 12+ note, screenshot list: `docs/APPSTORE.md`
- [x] GPLv3 vs App Store written down for Edouard — no extra DRM

**Exit:** no same-frame squad wipe. Campaign still needs a human playthrough for the 20–40% loss band. Version **0.5.0**.

### M6 — Ship ✅ 2026-08-20  **1.0.0**

- [x] Juice: shake, haptics, muzzle sparks, blast puff, death puff, move dust, pulsing rings, title sting
- [x] App Icon (existing original split disc)
- [x] Trailer: `docs/trailer/popfodder-1.0.mp4` + gif
- [x] Version 1.0.0

No new systems.

**v1 is out of scope on purpose:** helicopters and call-pads, boats, tanks, 3rd squad, aim stick, CF2 switches/UFO, random JS maps, 72-mission campaign, PvP, IAP, seasonal maps, OpenFodder workshop. Spear-natives as a faction, kidnap-leader, invuln bonuses — later list. Do not start them.

---

## Current sprint (M1) ✅ code

**Goal:** four named circles, two groups, auto-fire, a death that sticks.

| Task | Size | Pri | Dep | Status |
|------|------|-----|-----|--------|
| Soldier model + squad/group ids | S | Must | — | done |
| Tap select / tap move / formation | M | Must | model | done |
| Split & merge (2 groups); tap other group to switch | S | Must | select | done |
| Auto-fire + simple LOS | M | Must | model | done |
| Death + corpse + name strip | S | Must | combat | done |
| 4 dummy enemies on an empty field | S | Must | combat | done |
| Camera pan + pinch | S | Should | — | done |
| Rank stub (data only) | S | Could | model | done |

Definition of done: playable on Simulator (built 2026-08-20). Human playtest still the M1 gate.

---

## Risk Register

| Risk | P | I | Mitigation |
|------|---|---|------------|
| Slice isn't fun | M | Kill | Gate at M2. No content production before. |
| Touch control feels worse than mouse CF | H | H | Fat select radius, auto-fire, 2-group cap. Play on device weekly from M1. |
| Scope creep (vehicles, 72 maps, "engine") | H | H | This file is the backstop. Rex cuts, Hiro does not add. |
| Clone / IP complaint | M | H | Original everything. No OpenFodder assets or map data. |
| GPLv3 vs App Store | L | H | Check at M5, not M1. Source repo public before binary ships. |
| Attachment never forms | M | H | Mandatory short graveyard. Small rank bonuses. One-shot deaths. |
| One-person bandwidth | H | M | M1–M2 are code-only. Art/audio start at M2 exit, not before. |

---

## Workstreams (when, not who-in-parallel-from-day-one)

| Stream | Lead | Starts |
|--------|------|--------|
| Design | Hiro | M0 (now) |
| Engineering | Ada | M1 |
| Narrative / names / tutorial | Sage | M2 (lists), M4 (voice) |
| Maps | Quinn | M3 |
| Art | Pixel | After M2 gate |
| Audio | Lyra | After M2 gate |
| QA | Nova | M2 playtest, serious from M4 |
| Production gates | Rex | every M |

---

## References

| Game | Steal this | Do not steal that |
|------|------------|-------------------|
| **Cannon Fodder** (Sensible, 1993) | Order-not-aim, named death, graveyard, split-as-skill | Names, maps, audio, copy, "boot on the title" |
| **Cannon Fodder 2** | Harder map grammar | Scope |
| **Syndicate** (Bullfrog) | Squad as a tool you spend | Cyber overlays, research tree |
| **Desperados / Shadow Tactics** | Split and bait | Pause-planning, huge toolkits (too slow for this loop) |
| **Into the Breach** | Every move is a sacrifice | Grid + rewind (wrong tempo) |
| **Mini Metro** | Touch, short sessions, death-as-score | Abstraction level |
| **Theme Hospital** | Humor as feedback, not cutscenes | Management sim |

OpenFodder: read for *rule archaeology* (how CF counted a phase, how vehicles seat, how grenades share). Do not copy source into this tree.

---

## Appendix — OpenFodder archaeology (2026-08-20)

Source: [OpenFodder/openfodder](https://github.com/OpenFodder/openfodder) `Source/` headers and sprite handlers. **Rules only.** No code, assets, map files, or `mRecruits[]` names are copied here.

### What Cannon Fodder actually is (from the engine)

| System | OpenFodder fact |
|--------|-----------------|
| Input | Left click = queue walk waypoints (`mSquad_WalkTargets[10][30]`). Right hold = aim/fire at cursor (`Squad_Member_Target_Set`). Space = switch grenade/rocket. Keys 1–3 = squads. |
| Squads | Hard cap **3**. Split from sidebar; ammo split All / Half / None. Merge via join-target. |
| Combat | Walk target ≠ weapon target. Rank 0–15 feeds `mDeviatePotential` (bullet spread). Infantry is one-shot. |
| Economy | 360 six-letter names. +15 after a mission (`+= 0x0F`). New recruit rank `(mission-1)/3`. Promote per **phase**. Heroes store rank + kills for the hill. |
| Objectives | Kill all, destroy buildings, rescue hostages, protect civilians, kidnap leader, destroy factory, destroy computer, get civilian home, CF2: switches, rescue hostage. |
| Map | Tilesets jungle / desert / ice / moors / interior. Terrain: land, rocky, block, **quicksand**, water, snow, drop, sink, jump. Walk/drive/fly masks. Barracks doors spawn. |
| Threats | Infantry, jeep, jeep-rocket, tank, heli (grenade/missile/homing/unarmed), turrets, mines, spikes, call-pads. |
| Loop screens | Briefing (heli intro), phase, abort, try-again, service/debrief, hill/graveyard, recruit truck. |

### We already had (confirmed)

Core loop, named permanent death, graveyard, 2-group split as skill, auto-fire *as an iOS translation*, one-shot infantry, grenades that punish bunches, rifles-don't-kill-vehicles, jeep as the one vehicle, missions as data, phase structure, aggression as a difficulty knob, original IP.

### Missed, now in the spec

| Miss | Where it landed |
|------|-----------------|
| Walk is a **waypoint queue**, not one tap | M2 Should, max 4 |
| Right-mouse aim | Documented; **not taken.** M0 auto-fire stays. |
| Rank = **accuracy**, recruits enter mid-campaign already ranked | Soldiers + economy |
| +15 replenish, 360-scale name list | Economy (our names, not theirs) |
| Hostage / escort / protect as real objectives | Mission (d) + protect modifier; M3 |
| Turrets as the reason rockets exist | Combat + M2 |
| Barracks spawn until destroyed | Terrain + M3 |
| Phase grenade/rocket loadout; split takes half | Explosives |
| Lethal sink tiles, snow slow | Terrain |
| Switch group by tapping the other clump; merge by walking together | Selection |
| Camera eases toward the order | Movement |
| Per-phase aggression | Mission |
| Abort retries the phase; spent deaths stay spent | Mission |
| Show-map on large maps | Terrain / M4 |

### Looked at, still cut (on purpose)

Helicopters, call-pads, tanks, boats, 3rd squad, All/None ammo widget, CF2 switches/UFO/invuln turrets, jump tiles, spear-natives, kidnap-leader as its own type, bonus invuln/homing/rank-to-general pickups, armour (fights one-shot; do not add), JS random maps, campaign workshop, 72 missions, demo recorder, copy protection, Amiga/PC version toggle.

M0 does not reopen.

---

## Sign-off

| Question | Answer |
|----------|--------|
| What's the game? | Tap a named squad across a battlefield. They die. You send more. |
| What's the core loop? | Select → order → auto-fight → casualty or ground → next order |
| What's v1? | 12 missions, 4-man squad, 2 groups, grenades, one jeep, one escort type, graveyard |
| What's not v1? | Helicopters, 72 maps, aim stick, shop, OpenFodder port |
| Next action | **M1.** See Current sprint. |
