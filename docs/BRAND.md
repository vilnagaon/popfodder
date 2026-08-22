# PopFodder — Brand & Game Identity

**v1.0 · 2026-08-20 · Mara**
Pixel owns pixels (`docs/ART.md`). This file owns *what those pixels mean*.
Hiro owns systems (`docs/ROADMAP.md`). This file owns how those systems *look and speak*.

1.0 already shipped a face. We do not reinvent it. We lock it.

---

## Brand Direction / Audit Summary

PopFodder is not a war game about winning. It is a spending game about names.

The product is a two-minute order: tap a clump of people, send them into a field, watch one of them stay there. The brand must make that joke land in three seconds on an App Store card — before anyone has played. The visual system we already have does this: a split yellow disc on near-black, a monospace wordmark, a line that says TAP TO SPEND THEM. That is the identity. Everything else is a rank pip.

PopCrash (gampa.be) is the sibling: same house yellow, same noir, same refusal of polite marketing. PopCrash *collects* vinyl people. PopFodder *spends* named ones. Share the brass. Do not share Clash Display, crew slang, or Funko chrome. If a screen could be mistaken for the store, it is off-brand.

---

## Strategic Foundation

**Positioning statement**
For people who still flinch when a named unit dies, PopFodder is the pocket squad-tactics game that makes every tap a trade — not a shooter with a stick, not a Cannon Fodder clone, the only one where the roster *is* the economy.

**The only**
The only iOS tactics game whose punchline is the name on the body.

**Archetype**
Jester with a knife. Humour is the delivery. Permanence is the cut. Not Hero (we do not promise glory). Not Caregiver (we do not comfort). Not Ruler (there is no army to command, only four people).

**Personality (lock these four)**
1. **Brisk** — two-minute missions, three-word lines, no briefing novels.
2. **Named** — every person is a word you can shout. Never “Unit 3.”
3. **Cheap** — death is a drawing, not a cutscene. The joke is how little it costs the world, and how much it costs you.
4. **Original** — own maps, own list, own disc. Never the boot, never the hill copied, never Jools.

**Audience**
- Primary: 25–45, played Cannon Fodder or Advance Wars or Into the Breach, owns an iPhone, will pay a few euros for a complete game with no IAP.
- Secondary: PopCrash crew who like GAMPA making games, not just a store.
- Not: 4+ family, realistic milsim, battle-pass teens, “war has never been so much fun” nostalgia tourists.

**Price / channel**
Premium indie on the App Store. No ads, no tracking, no IAP chrome. GPL-3.0 is a brand fact, not a footnote — it sits on SOURCE in Menlo, same as a grave.

**Competitive set (visual landscape)**

| Neighbour | What they look like | We do instead |
|-----------|---------------------|---------------|
| Cannon Fodder | Copper hill, boot logos, Sensible type | Split disc, Menlo, original maps |
| Into the Breach | Grid, mechs, yellow warnings | No grid. People, not machines. |
| Retro Bowl | Names + comedy death, US football chrome | Same attachment trick, dirt not turf |
| Mini Motorways | Pastel systems, calm | Brass on noir, someone dies |
| Generic “Army Men” App Store | Camo, stencil type, 3D soldiers | Flat stamps, one typeface, no camo |
| PopCrash | Clash Display, crew, grail red | Menlo only. Yellow is shared. Voice is colder. |

**Anti-references (do not)**
Cannon Fodder title boot. “War has never been so much fun.” Jools / Jops / Stoo. Virgin / Sensible / Codemasters marks. Stencil army fonts. Olive-drab as the *primary* (too real). Skulls. Blood-red wordmark. Clash Display. UN / UK / US insignia. Photoreal soldiers. Aim-stick UI chrome.

---

## Visual Identity System

### Logo Direction

**Primary mark — the Split Disc**

A filled circle in Brass, bisected by a vertical slot in Noir, thin Ivory ring.

It is a coin you spend. It is a helmet from above. It is a medal cracked down the middle. It is a target. It is *not* a soldier silhouette (every war icon on the store is a man with a gun). It is *not* the PopCrash PC monogram.

**Construction**
- Circle. Slot width ≈ 10% of diameter.
- Slot is Noir, not transparent, so the mark holds on yellow *and* on screenshots.
- Ivory ring is optional at large size; drop the ring under 40px (App Icon uses fill + slot only).
- Clear space: one slot-width around the disc.
- Never put type inside the disc.
- Never add a second slot, a star, a rank pip, or a smile.

**Wordmark**
`POPFODDER` — one word, all caps, Menlo Bold (or the licensed mono below). Tracking slightly open so the two P’s and the two D’s read as a stamp, not a crowd.

Lock:
- UI and icon: `POPFODDER`
- Sentences: `PopFodder`
- Never `Pop Fodder`, `POP FODDER`, `Popfodder`, `PF` as a public acronym.

**Lockups**
1. Disc stacked over wordmark (title screen — already live).
2. Disc left, wordmark right (App Store, GitHub, press).
3. Disc alone (App Icon, TestFlight, notification).

**App Icon**
Brass split disc on Noir. No word. No soldier. No landscape. Must read at 29pt. If it looks like a coin or a helmet from a thumb away, it is correct.

### Color Palette

60% Noir, 30% field (biome), 10% Brass. Red is a weapon, not a brand colour — save it for them, for fail states, for the objective line.

| Color | Role | Pantone | HEX | RGB | CMYK | Where |
|-------|------|---------|-----|-----|------|--------|
| **Noir** | Ground, chrome, slot | Black 6 C | `#0D0D0D` | 13 13 13 | 70 65 60 75 | Title, roster, graveyard, icon field |
| **Brass** | Mark, win, selection, POPFODDER | 116 C | `#FFD600` | 255 214 0 | 0 12 95 0 | Disc, rings, mission-complete, crate |
| **Ivory** | Primary type on Noir | 11-0602 TPX | `#F2F0EB` | 242 240 235 | 4 3 6 0 | Wordmark on title, grave names |
| **Ash** | Secondary type | Cool Gray 8 C | `#75787B` | 117 120 123 | 50 40 35 15 | Blurbs, pool counts, TAP TO… |
| **Ours** | Player group 0 | 7488 C | `#38C852` | 56 200 82 | 70 0 85 0 | Infantry stamp, living queue |
| **Split** | Player group 1 | 7703 C | `#269EB8` | 38 158 184 | 80 20 20 0 | Second group only |
| **Theirs** | Enemy, fail, objective | 1795 C | `#DC2824` | 220 40 36 | 0 95 90 5 | Infantry, turret, ALL DEAD, objective line |
| **Hill** | Graveyard ground | 5743 C | `#38472E` | 56 71 46 | 60 40 70 40 | The mountain |
| **Pack** | Rank glint on our helmet | 116 C | `#FFD600` | 255 214 0 | — | Tiny Brass on player heads (already in stamps) |

**Biome fields (in-play only — never on chrome)**

| Biome | Backdrop HEX | Feel |
|-------|----------------|------|
| Grass (default) | `#1A2414` | Wet, cheap, first maps |
| Dirt | `#2E2414` | Hot, yard, compound |
| Snow | `#24282E` | Cold, icebox — *cool grey, not white* (white kills silhouette) |

**Rules**
- Ours / Theirs / Split are *faction*, not decoration. Do not use Ours on type except the living queue.
- Brass is the only yellow. Do not drift to gold, amber, or PopCrash’s CTA yellow-on-button pattern for menus.
- Selection ring = Brass, fattest stroke in the game. If you remember one sprite, it is this.
- Dead = desaturated grey `(70,70,70)`. No blood palette. Death is a drawing.
- Contrast: Ivory on Noir, Brass on Noir, Ours on Noir all clear WCAG AA at HUD sizes. Do not put Theirs on dirt-red tiles.

### Typography

One family. That is the brand.

| Use | Typeface | Weight | Size (iPhone landscape) | Notes |
|-----|----------|--------|-------------------------|-------|
| Wordmark | Menlo | Bold | 22–28 | Title 28, roster 22 |
| Mission title | Menlo | Bold | 16 | `THE GAP` |
| HUD names | Menlo | Bold | 12–13 | Active group strip |
| Body / blurbs | Menlo | Regular | 10–11 | Never wrap into a paragraph if a clause will do |
| Chrome verbs | Menlo | Regular | 12 | `TAP TO DEPLOY`, always uppercase |
| Legal / SOURCE | Menlo | Regular | 9–10 | GPL is part of the voice, set small, not greyed into shame |
| Grave names | Menlo | Bold | 10 | The hill is a typesetting job |

**Why Menlo, not Clash, not a stencil**
Menlo is a roster. A grave list. A terminal that happens to be a war. Clash Display is PopCrash. Army stencil is every $0.99 camo game. If we later license a mono, pick **IBM Plex Mono** (warmer, still a list) — never a display face.

**Case**
- Screens: ALL CAPS.
- App Store long description: sentence case, still short.
- Mission titles: `THE` + one noun, all caps. Sage already did this. Do not get poetic (`Operation Silent Garden` is off).

**Do not**
Mix SF Pro into chrome “to look more iOS.” System font is a leak. Menlo or nothing.

### Photography / Image Direction

There is no photography. The world is stamps.

**Illustration language**
- Top-down, slight height, Y-sorted. Not iso, not side-view, not 3/4 hero portraits.
- Nearest-neighbour pixel stamps. One language. Do not mix vector-smooth UI with chunky soldiers.
- Silhouette first: a 16px body must read on grass, dirt, and snow.
- Limited colours per sprite (body, head, one accent). The accent on *ours* is Brass. On *theirs*, none — they are the red.
- Lighting: none. No rim light, no normal maps. The “sunset” in current key-art is a field gradient, allowed on marketing stills, not on tiles.

**Marketing stills (key art, screenshots, trailer)**
- Camera: play-view, not cinematic 3D.
- Always show: (1) a Brass selection ring, (2) at least two readable names or the implication of names, (3) a threat that is red.
- One still may show the graveyard as a green mountain of slab tombstones with names as type. Crosses are church. We typeset the dead on stones.
- Trailer: 6 seconds is the format. Loop the joke, do not explain the systems.

**Key-art already in tree** (`docs/trailer/key-art.jpg`) is on-model: green clump, Brass rings, red turret, gold crate, dirt field. Treat that still as the illustration north star when Pixel redraws stamps. The in-engine 16px blocks are the *placeholder dialect* of the same language, not a second style.

### Pattern / Texture

- No camo.
- No hatching as decoration.
- Tile fields may have sparse grass nubs (already in key-art). Keep them as noise, not a pattern that competes with soldiers.
- Split-disc may be used as a 5–10% opacity watermark on press sheets only. Never tiled on the battlefield.

### In-game visual grammar (this *is* game design)

| Moment | What you see | Why |
|--------|----------------|-----|
| Boot | Noir, disc scales in, `POPFODDER`, `TAP TO SPEND THEM` | The whole pitch before a menu |
| Roster | Brass name, red objective, green living line, `POOL / GRAVES` | Economy on one screen |
| Select | Brass ring, names in the strip | The finger’s only friend |
| Split | Second group turns Split (cyan). Strip shows who you hold. | Colour *is* the second stick |
| Fire | Tiny tracer; no HP bar | One shot is the joke |
| Death | Grey stamp stays. Name leaves the strip. | The body is the memorial |
| Win | `MISSION COMPLETE` in Brass | Same yellow as the disc |
| Wipe | `ALL DEAD` in Theirs | Same red as the turret |
| Empty pool | `NO ONE LEFT` | The brand promise, inverted |
| Campaign end | `CAMPAIGN DONE` / `THE HILL IS FULL` | Typesetting, not fireworks |
| SOURCE | Yellow name, GPL in Ash | Honesty as chrome |

HUD is a *strip*, not an RTS panel. Names, grenade count, rank as a character in the name (`ADA·3`). No minimap art, no portraits, no camo buttons.

---

## Verbal Identity

**Voice**
A sergeant who has stopped shouting. Short. Exact. A little funny. Never ironic-online, never patriotic, never sadcore.

| Axis | We are | We are not |
|------|--------|------------|
| Length | Three to seven words | Lore dumps |
| Person | Imperative, or no person | “You and your brave squad…” |
| Feeling | Dry | Edgy, wholesome, military-official |
| Names | Shoutable, 2–8 letters | Surnames, callsigns, OpenFodder names |
| War | A field with a job | A cause |

**Tone by screen**

| Screen | Tone |
|--------|------|
| Title | One blade. TAP TO SPEND THEM. |
| Roster | Inventory. Mission name, objective, who you are about to lose. |
| Play | Almost mute. Names and counts only. |
| Graveyard | Roll-call. THE HILL IS FULL is the only poetry allowed. |
| About | Clerk. GPL, no tracking, age 12+. |
| App Store | Same blade, then one paragraph of facts. |

**Tagline options**
1. **Primary (live):** `TAP TO SPEND THEM`
2. Challenger (store subtitle): `Named. Spent. Remembered.`
3. Long (press only): `Tap your squad. Take the objective. Try not to spend the people you like.`

Reco: keep #1 on the title and icon-adjacent. Use #3 as the App Store promo line (already the README sentence). Never print Cannon Fodder’s line, even as homage.

**Key messages**

| Slot | Line |
|------|------|
| Elevator | Pocket squad tactics. You spend names. |
| Boilerplate | PopFodder is a landscape iOS game from GAMPA: tap a named squad, take the field, live with the hill. Original maps, original art, GPL-3.0. |
| Social bio | Tap them. Spend them. Try not to like them. |
| Age | Cartoon war. People die. 12+. |
| Legal beat | No tracking. No ads. Source ships with the binary. |

**Naming conventions**
- Missions: `THE` + concrete noun (`THE GAP`, `THE HILL`). Max two words.
- Soldiers: original list, shoutable, never OpenFodder’s 360.
- Ranks: eight steps, spoken as a number beside the name, not a title on a portrait.
- Buttons: `TAP TO` + verb. Deploy, go back. Not PLAY, not START, not CONTINUE YOUR JOURNEY.

**Words we do not use**
Fodder as a joke about real armies. Jools, Jops, Sensible, Cannon. Grail, crew, choper (those are PopCrash). Hero. Sacrifice. Honour. Respawn. Skin. Loot.

**Copy already on-model (lock)**
`TAP TO SPEND THEM` · `TAP TO DEPLOY` · `ALL DEAD` · `NO ONE LEFT` · `THE HILL IS FULL` · `CAMPAIGN DONE` · `MISSION COMPLETE` · `SOURCE / GPL`

---

## Touchpoint Priorities

The “shelf” is the App Store search row. Design for 3 seconds at thumb size, then for the first title tap.

| Rank | Touchpoint | Job | Status |
|------|------------|-----|--------|
| 1 | **App Icon** | Split disc on Noir, readable at 29pt | Exists; audit vs this spec before 1.0 store |
| 2 | **Title screen** | Disc + POPFODDER + TAP TO SPEND THEM | Live. Lock. |
| 3 | **Screenshot 1 (Roster)** | Names + `POOL / GRAVES` + a THE mission | Capture per `docs/APPSTORE.md` |
| 4 | **Screenshot 2 (THE GAP)** | Brass rings + red turret | Key-art already shows the shot |
| 5 | **Graveyard still** | Names on slabs on a green mountain, not crosses | Live scene; screenshot it |
| 6 | **Wordmark lockup** | Disc + POPFODDER for GitHub / press | Title scene is the master; export SVG later |
| 7 | **Trailer** | 6s loop | `docs/trailer/` — keep format |
| 8 | **SOURCE screen** | GPL as chrome | Live |
| 9 | **TestFlight / ASC name** | `PopFodder` | App 6803626462 |
| 10 | **Pixel stamp pass** | Same language as key-art, in-engine | After this lock; Pixel |

Do not design: box art, camo merch, animated logo sting longer than the current disc scale-in, a website that looks like PopCrash.

---

## Production Notes

**Digital**
- SpriteKit nearest-neighbour. 16px infantry, 20px jeep/hq. 2×/3× from integer stamps.
- Export mark as PDF/SVG from the geometric spec (circle, slot 10%, Brass fill) — do not photograph the SKShapeNode.
- App Icon: single well in `AppIcon.appiconset`; no season variants.
- Screenshots: landscape 6.7" and 6.1", no device chrome, no “NEW” stickers.

**Type licensing**
Menlo ships on iOS. GitHub README / web: use **IBM Plex Mono Bold** as the public stand-in (OFL), not a screenshot of Menlo if we lack desktop embedding rights. Do not download Clash Display “because GAMPA.”

**Audio (for Lyra, not a rebrand)**
8-bit, short, original. The voice is visual-first; SFX should sound like toys, not Call of Duty. Already the direction of `scripts/generate_sfx.py`.

**Print / press (if we ever need it)**
- Stock: uncoated black, Brass spot or 116 C. No gloss war-poster.
- Do not foil the disc — it becomes a coin too literally and looks like a lager badge.

**Governance**
- Mara: identity, copy lock, store stills composition.
- Pixel: stamps, tiles, biome palettes *inside* this system.
- Sage: names and mission titles *inside* the `THE` + noun / shoutable rules.
- Hiro: does not add a UI widget that needs a new colour.
- New colour or type = this file changes first.

**Brand metrics (practical)**
- Icon test: disc readable at 29pt on Noir.
- Screenshot test: a stranger can point at “your guys” vs “the turret” in one second.
- Copy test: every chrome line ≤ 7 words.
- Sibling test: a PopCrash tab and a PopFodder title cannot be swapped without someone noticing the type.

---

## What 1.0 already got right (do not “polish” away)

The split disc. Menlo. TAP TO SPEND THEM. Brass rings. Green clump vs red turret. `POOL / GRAVES` as the economy. The hill as a typesetting of names. GPL on a game screen. Mission titles that sound like places you die, not operations you win.

The gap is not strategy. The gap is making the in-engine stamps as articulate as the key-art, and making the App Store five stills tell the same joke in order: roster → gap → split → jeep → hill.
