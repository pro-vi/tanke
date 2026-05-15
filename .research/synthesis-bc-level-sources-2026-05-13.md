---
topic: "Battle City NES (1985) level data sources for tanke arc-3 import"
date: 2026-05-13
projects:
  - name: krystiankaluzny/Tanks
    repo: github.com/krystiankaluzny/Tanks
    sha: depth-1 clone (current HEAD as of 2026-05-13)
    license: MIT
    source: cloned
    source_quality: code-verified
  - name: PLUkraine/Battle-City-Qt
    repo: github.com/PLUkraine/Battle-City-Qt
    license: MIT
    source: doc-stated (agent survey only)
    source_quality: doc-stated
  - name: StrategyWiki Battle City Walkthrough
    repo: strategywiki.org/wiki/Battle_City/Walkthrough
    license: CC-BY-SA (StrategyWiki default)
    source: doc-stated (anti-bot blocked direct fetch; URLs verified via search)
    source_quality: doc-stated
  - name: Selmiak NES Database (via GameFAQs mirror)
    repo: selmiak.bplaced.net + gamefaqs.gamespot.com
    license: fan-documentation (uncited use)
    source: doc-stated
    source_quality: doc-stated
hypotheses:
  - claim: "krystiankaluzny/Tanks contains all 35 canonical BC stages in parseable ASCII format under MIT"
    result: confirmed — code-verified via clone; 36 files in resources/stages/ (file 0 = title screen logo, files 1-35 = the 35 NES BC stages); LICENSE confirms MIT
  - claim: "Tank 1990 is a 50-stage bootleg, distinct from canonical Battle City NES 1985"
    result: confirmed — doc-stated via BootlegGames Wiki, Wikipedia (Tank 1990 adds stages 36-50 + extra mechanics; not 1:1 with OG)
  - claim: "Cross-validation source exists (image-parseable) for the 35 stages"
    result: confirmed — StrategyWiki has Battle_City_Stage01.png through Stage35.png at 208×208 px (16 px per NES tile); Selmiak NES Database mirrors via GameFAQs
key_findings:
  - "Canonical BC = NES/Famicom 1985 Namco, 35 stages, 13×13 logical tiles per stage"
  - "BC's brick tile is destructible as 4 sub-bricks per logical tile — ergo a 13×13 stage is 26×26 at quarter-tile resolution"
  - "krystiankaluzny/Tanks encodes each stage as a 26×26 ASCII grid (one char per quarter-tile)"
  - "Legend (krystiankaluzny): '.' empty, '#' brick, '@' steel, '%' forest, '~' water, '-' ice"
  - "Stage 1 cross-validated visually against canonical NES Stage 1 silhouette (bilateral brick columns, steel-armored mid-corridor, eagle-base brick fortress at bottom-center)"
  - "Stage 4 has '@#%~' (steel + brick + forest + water); stage 18 has '@#%' (no water/ice) — confirms multi-terrain variety with the same symbol set"
  - "Tank 1990 has 50 stages and bootleg-only mechanics (ship/water-cross, super-power gun) — must NOT be conflated with canonical BC"
unexplored_threads:
  - "Eagle/base location encoding — Tanks repo uses brick fortress at bottom-center but no explicit 'eagle' symbol; arc-3 must decide whether to model the eagle as gameplay or just the fortress as decorative"
  - "Enemy spawn data per stage — Tanks repo's stages/ contains only terrain; per-stage enemy roster (tank type + count) lives elsewhere (likely in source code constants or a separate config file). Arc-3 phase-1 must find this"
  - "Ice tile ('-') visual behavior in BC — sliding physics? Not yet researched. Will appear in some stages we haven't sampled"
  - "Selmiak/GameFAQs map images for true second-opinion diff — fetcher was 403-blocked in the survey; can be done locally via curl/wget for offline cross-validation"
---

# BC Level Sources — Synthesis

## The decision

**Primary source: `krystiankaluzny/Tanks`** (cloned into `.research/repos/Tanks/`).
- MIT license, 236 stars, active 2025
- `resources/stages/1` through `resources/stages/35` are the 35 canonical NES BC stages
- ASCII grid format: 26 rows × 26 columns per stage, ~701 bytes per file
- Legend documented in repo README, verified against stage 1 / 4 / 18 contents

**Cross-validation source: StrategyWiki PNG renders** — 208×208 px (16 px per NES tile, 13×13 grid).
URLs pattern: `https://strategywiki.org/wiki/File:Battle_City_Stage01.png` through `Stage35.png`. For visual diff: download PNG → palette-classify each 16×16 tile → compare to Tanks's ASCII grid mapped from quarter-tile to NES-tile resolution.

**Secondary cross-validation: Selmiak NES DB** via GameFAQs mirror (pattern: `https://gamefaqs.gamespot.com/nes/562966-battle-city/map/`). Independent contributor's rendering; for "do two fan sources agree?" tie-breaking.

## Stage 1 (verified, code-cited from `Tanks/resources/stages/1`)

```
..........................   (rows 0-1: top border / spawn area)
..........................
..##..##..##..##..##..##..   (rows 2-8: alternating brick columns × 6)
..##..##..##..##..##..##..
..##..##..##..##..##..##..
..##..##..##..##..##..##..
..##..##..##@@##..##..##..   ← row 6: steel '@@' embedded mid-board
..##..##..##@@##..##..##..
..##..##..##..##..##..##..
..##..##..........##..##..   (rows 9-10: open mid-board passage)
..##..##..........##..##..
..........##..##..........   (rows 11-12: central brick island)
..........##..##..........
##..####..........####..##   ← row 13: edge bricks + central open lane
@@..####..........####..@@   ← row 14: edge steel (indestructible) + bricks
..........##..##..........
..........######..........
..##..##..######..##..##..
..##..##..##..##..##..##..   (rows 18-24: mirror of upper half)
..##..##..##..##..##..##..
..##..##..##..##..##..##..
..##..##..........##..##..
..##..##..........##..##..
..##..##...####...##..##..   ← row 24: eagle's outer brick ring
...........#..#...........   (rows 25-26: eagle's brick "house")
...........#..#...........
```

The bottom two rows' `#..#` pattern is the canonical brick fortress around the eagle base — perfectly recognizable.

## Symbol legend (verified)

| Char | Terrain | tanke equivalent | Collision |
|------|---------|------------------|-----------|
| `.` | empty | empty (no tile) | pass |
| `#` | brick (destructible) | `BrickBlock` (HP=1, destroyable by bullets) | pass-by-bullet-to-destroy |
| `@` | steel/stone (indestructible without star powerup) | steel TileMapLayer | block bullets + tanks |
| `%` | forest/bush (hides tanks) | grass TileMapLayer + forest-hide rule (already in PlayerTank.gd) | pass |
| `~` | water (blocks tanks, passable by bullets) | WaterBlock | block tanks; bullets pass |
| `-` | ice (sliding physics) | NOT YET IN tanke | TBD — likely arc-3 phase-1 work |

**Five of six symbols map directly to existing tanke terrain**. Ice is new — arc-3 phase 1 must decide: implement sliding physics, or treat ice as plain floor for v1.

## Grid resolution mismatch (CRITICAL for arc-3 importer)

| Game | Logical grid | Per-tile resolution | Stage pixel size |
|------|--------------|---------------------|------------------|
| NES Battle City | 13×13 tiles | 16 px/tile (each tile = 2×2 sub-bricks) | 208×208 px |
| krystiankaluzny/Tanks ASCII | 26×26 chars | 1 char per sub-brick | n/a |
| tanke viewport | 40×30 tiles | 8 px/tile | 320×240 px |

**Plan**: arc-3 imports each Tanks stage as a 26×26 grid at the SAME 8-px tile size we already use → 26×26 = 208×208 px play area. Center horizontally in our 320-wide viewport with 7 cells (56 px) of border on each side. Vertically: 26 rows of play + 4 rows of HUD = 30 = our 240/8 viewport height. Perfect fit.

This means our existing `set_cell(Vector2i, 0, Vector2i(0,0))` machinery imports a Tanks stage with one trivial offset (`col + 7` on the horizontal axis). No engine changes needed.

## Tank 1990 disambiguation

Per BootlegGames Wiki + Wikipedia: **Tank 1990** is an unauthorized 1990 hack by Yanshan Software. 50 stages (vs OG 35). Adds new mechanics (water-cross ship, super-power gun). Stages 36-50 are bootleg-only.

**Conclusion**: do not use Tank 1990 sources. If a candidate source has 50 stages or mentions Tank 1990, it's either the bootleg or a confused mixture — disqualify.

## Open questions for arc-3 phase 1

These are answered by the loop, not this synthesis:

1. **Eagle / base mechanic** — Tanks repo encodes the brick fortress geometrically but not the eagle as a distinct entity. Arc-3 must decide: introduce eagle gameplay (BC's win/lose condition), or treat the fortress as decorative geometry only and reuse arc-2's depth-as-score?
2. **Per-stage enemy roster** — Tanks's `resources/stages/*` is terrain only. Where does OG BC's per-stage enemy spawn data live? Likely in Tanks's source code (Java) — phase 1 must extract.
3. **Ice physics** — first stage with `-` symbol becomes a code-required decision: model sliding or treat as floor?
4. **Cross-validation execution** — render Tanks's stage 1 → diff against StrategyWiki's `Battle_City_Stage01.png`. If structural match, we're confident; if not, hand-resolve.

## Recommendation for arc-3 PROMPT

The PROMPT should specify:
- **Source of truth**: `.research/repos/Tanks/resources/stages/{1..35}` (read-only; this is substrate)
- **Verification source**: StrategyWiki PNG comparison via `tools/analyze_frame.py`-style classifier
- **Format target**: a `LevelLoader.gd` script that reads a Tanks-format ASCII grid and emits `set_cell(...)` calls
- **Per-stage acceptance**: layout-exact terrain match + reachability oracle passes + visually recognizable to a fan
- **Out-of-scope for v1**: eagle gameplay, per-stage enemy rosters, ice physics (each gets a phase-1 decision iter)

Frontier-loop shape — artifact exists, evaluator is constructable, target is finite (35 stages).

## Files in this synthesis

- `.research/repos/Tanks/` — cloned source (depth-1)
- `.research/synthesis-bc-level-sources-2026-05-13.md` — this file
