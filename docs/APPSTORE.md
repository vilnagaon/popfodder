# PopFodder — App Store / GPL notes

Beta (M5). Not a ship checklist for 1.0 (that's M6).

## Privacy nutrition

| Question | Answer |
|----------|--------|
| Tracking | No |
| Data collected | None. Optional local play log in the app sandbox (`Documents/playlog.txt`). Not uploaded. |
| Account | None |
| Encryption | Exempt (`ITSAppUsesNonExemptEncryption` = false). No custom crypto, no network. |
| Privacy Manifest | `Resources/PrivacyInfo.xcprivacy` — File Timestamp C617.1 for the local log |

## Age rating (suggested)

**12+.** Cartoon military violence, permanent death, no blood spray, no real-world insignia. Not 4+ (people die). Not 17+ (no gore, no sexual content).

App Store Connect: Violence → Cartoon or Fantasy Frequent; Realistic none.

## Screenshots

Capture on iPhone 15/16/17 landscape, 6.7" and 6.1":

1. Roster (names + mission)
2. THE GAP (squad + turret)
3. Split / two groups
4. Jeep on THE YARD
5. Graveyard hill

No Cannon Fodder UI, no Sensible marks.

## GPLv3 and the App Store

Edouard / current policy sanity check (do this before first binary upload, not after):

- GPL-3.0 is the license of this tree (`LICENSE`).
- App Store distribution is possible if we **do not add restrictions beyond Apple's standard terms** and we **offer complete corresponding source** to anyone who has the binary.
- Anti-tivoization (GPLv3 §6) is the known friction. A normal iOS app binary that is not a locked "User Product" installation key, plus a public source repo, is the usual indie reading. Re-check with someone who has current App Store + GPL practice.
- Do **not** wrap the app in extra DRM, account gates for the GPL'd code, or a EULA that forbids reverse engineering beyond Apple's terms.
- Publish this repo (or a tarball of the exact tag you shipped) **before** the binary is available.
- In-app SOURCE screen is the written offer.

We have not added network copy-protection, IAP, or a proprietary SDK.

## Version

Marketing **1.0.0**. Trailer: `docs/trailer/popfodder-1.0.mp4`.

## What we did not do

Public source: [`vilnagaon/popfodder`](https://github.com/vilnagaon/popfodder). The in-app SOURCE screen points here.
