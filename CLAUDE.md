# CLAUDE.md — PopFodder

## What this is

PopFodder is an iOS squad-tactics action game in the spirit of Sensible Software's *Cannon Fodder* (tap/select a soldier, move it across a battlefield, take on missions). It is not a Cannon Fodder reskin — no Codemasters/Sensible Software names, characters, or assets are reused. Own name, own art, own story.

## License

**GPL-3.0**, inherited from [OpenFodder](https://github.com/OpenFodder/openfodder) (GPL-3.0), which this project forks/derives engine ideas and possibly code from. Because of this:

- The full PopFodder source must stay open under GPL-3.0.
- Any code copied or adapted from OpenFodder keeps its GPL-3.0 obligations.
- App Store distribution of GPL-3.0 code is allowed as long as you (the copyright holder for your own code, or licensee for OpenFodder's) don't add further restrictions beyond the App Store's terms — no DRM added on top. Re-check this before shipping; GPLv3 + App Store has occasional friction over section 6 (anti-tivoization) that doesn't apply to a normal iOS app binary but is worth a sanity check with a source familiar with current App Store policy.

See `LICENSE` for the full GPL-3.0 text.

## Tech

- **Language:** Swift 5.10
- **Engine:** SpriteKit (native, no Unity/third-party engine)
- **Project generation:** XcodeGen — edit `project.yml`, then run `xcodegen generate`. Never edit `.xcodeproj` directly (same convention as `../popcrash-ios`).

## Current state

M4 content alpha: 12 missions / 17 maps, 3 biomes, 220 names, pixel stamps, SFX, App Icon, play log. Campaign in `Resources/campaign.json`.

**Design + roadmap:** [`docs/ROADMAP.md`](docs/ROADMAP.md) — living spec. Engine decision is locked: Swift reimplementation, OpenFodder as rules reference only. Identity: [`docs/BRAND.md`](docs/BRAND.md). Pixel gameplay: [`docs/PIXELS.md`](docs/PIXELS.md). Art: [`docs/ART.md`](docs/ART.md) — original only; do not import OpenFodder/Cannon Fodder graphics.

**1.0.0 in-tree (M6).** Trailer in `docs/trailer/`. Public GPL source: [github.com/vilnagaon/popfodder](https://github.com/vilnagaon/popfodder). Notes: `docs/APPSTORE.md`.

```
PopFodder/
├── App/           # Entry point (PopFodderApp.swift), Info.plist
├── Scenes/        # SpriteKit scenes (GameScene.swift)
└── Resources/     # Assets, will hold Assets.xcassets
docs/
└── ROADMAP.md     # Design spec + phase gates
```

## Apple credentials

- **Team ID:** GZYFXW9AWA
- **Bundle ID:** be.gampa.popfodder

## Immediate TODOs

1. ~~Port vs reimplement~~ **Locked:** reimplement in Swift. See `docs/ROADMAP.md`.
2. ~~**M1** squad loop~~ **Code done.** Playtest: pick one guy, pick the squad, bait, notice a name die.
3. ~~**M2** slice~~ **Code done.** Human gate: a stranger feels a death. Then M3 or stop.
4. ~~**M3** systems~~ **Code done.** 3-mission run. M4 is twelve maps + original art, only if the run is fun.
5. Assets.xcassets + AppIcon — original art, after M2 gate. Nothing from Cannon Fodder.
6. Public GPL-3.0 repo: [vilnagaon/popfodder](https://github.com/vilnagaon/popfodder).
