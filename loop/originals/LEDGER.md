# tanke — Originals Loop LEDGER (arc 3)

Append-only. One block per iteration. Iter 0 is bootstrap (no scoring).

Parallel to `loop/LEDGER.md` (arc 1, engine, closed iter 28) and
`loop/gameplay/LEDGER.md` (arc 2, gameplay, closed iter 100).

---

## Iter 000 — BOOTSTRAP

**Mode:** BOOTSTRAP (no scoring)
**Date:** 2026-05-15
**Branch:** `exp/godot4-loop` (deleted + recreated this session for the arc-3 reset)

### Preloop resolution

All six gate items pass.

- Read `loop/META-RETRO.md` (arc 1 engine retro, iters 0–28, closed at 50/55).
- Read `loop/gameplay/META-RETRO-iter100.md` (arc 2 gameplay retro, iters 0–100, closed at 34/50 under `HALT_META_REFRAME`).
- Read `.research/synthesis-bc-level-sources-2026-05-13.md` (arc-3 research substrate, confirms krystiankaluzny/Tanks is MIT primary source with 35 canonical BC stages in 26×26 ASCII grids).
- Verified `.research/repos/Tanks/resources/stages/1` byte-for-byte matches the synthesis-cited Stage 1 layout: alternating brick columns × 6, embedded `@@` steel at rows 6-7, central brick island at rows 11-12, edge steel + bricks at rows 13-14, eagle brick fortress `#..#` at rows 25-26.
- Verified `make test` exit 0 (procedural scene runs 120 headless frames with no script errors).
- Verified reachability oracle still passes on procedural scene (`playable: true`, `reachable_cells: 676`, `rows_climbed: 29`).

### Substrate baseline (cross-arc invariant)

| Field | Value |
|-------|-------|
| Active arc-2 scene | `scenes/ProceduralLevel.tscn` |
| Active arc-2 config | `configs/playable.tres` |
| Seed | 42 (oracle reference) |
| `playable` | **true** |
| `reachable_cells` | 676 |
| `rows_climbed` | 29 |
| `min_reachable_row` | 0 |
| `cc_count` / `cc_avg` / `cc_max` | 51 / 12.86 / 60 |
| `eller_sets` / `eller_avg_size` / `eller_max_size` | 15 / 1.33 / 3 |
| `vert_structure_lift` | 2.14 |
| `tile_hash` (seed 42) | `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` |
| Headless boot | `make test` exit 0, no errors |

**Hash anchor `23d6a2ec…` matches the arc-2-close iter-100 LEDGER record exactly** — arc-2 procedural mode regression detector intact. Any future drift on this 64-char fingerprint while arc-3 work proceeds indicates an arc-2 substrate violation (halt + investigate per HALT CONDITIONS).

### Stage source inventory

`.research/repos/Tanks/resources/stages/` contains 36 files: `0` (title-screen logo per synthesis) + `1..35` (the canonical NES BC stages). All present. Read-only per H2 tripwire — any parse work copies to `configs/stages/` before mutation.

### Substrate internalized from retros

From arc 1 (`loop/META-RETRO.md`):
- Hash-anchor pattern as regression detector.
- Cited mutation cycles (edit → rerun → cite Δ).
- Dual-oracle (headless + screencapture) discipline.
- Single-seed metric reliability table: `structure_lift` reliable; `cc_max` requires ≥3 seeds.

From arc 2 (`loop/gameplay/META-RETRO-iter100.md`):
- STRUCTURE / FEEL / MIXED / STRUCTURE-DEFERRED tag system (H2 RULE v2).
- H1 tripwire: never add gameplay siblings to `ProceduralLevel.tscn` — arc 3 builds NEW scenes.
- Sprint authorization as user-driven cadence override.
- Identity isn't a rubric criterion — but arc 3's rubric is binary per stage, which sidesteps this.
- F014 lesson: procedural variety invisible to players without an external reference set — arc 3 *is* that reference set.

### Arc-3 specific commitments captured

- **H2 tripwire (new)**: `.research/repos/Tanks/` is read-only. Parse-from-copy.
- **Reachability floor** applies to every imported stage.
- **PNG-diff floor** caps rubric criteria 7/8/9 at the count of stages passing automated diff < 5%.
- Eagle goes in iter 1-3, before mass stage import (anti-pattern: deferring eagle to "after all stages").
- Ice (`-` symbol) is a phase-1 explicit decision iter — not a hidden shortcut.

### Next iter

Iter 1 — BUILD / CAPABILITY. Scaffolding:
- `scripts/LevelLoader.gd` skeleton (parses Tanks ASCII grid → `set_cell`).
- `scenes/OriginalLevel.tscn` skeleton (new scene, parallel to procedural).
- `loop/test_runner.gd` extension: `--scene` and `--og-stage K` flags so reachability oracle can score OG stages without a refactor.

Pre-mortem due at iter-1 start. H2 RULE v2 tags mandatory.

### Commit

`chore(originals): iter 000 — BOOTSTRAP — substrate verified, sources inventoried`

---

## Iter 001 — BUILD / CAPABILITY

**Mode:** BUILD (with CAPABILITY sub-focus on `loop/test_runner.gd` extension)
**Date:** 2026-05-15
**Branch:** `arc-3-originals`
**Focus:** Scaffolding — LevelLoader.gd + OriginalLevel.gd/.tscn + test_runner --scene/--og-stage flags

### Pre-mortem (cited; full text in `PRE-MORTEMS.md` iter 001)

Falsifiable claim: procedural hash anchor `23d6a2ec…` preserved AND OriginalLevel loads stage 1 with `brick > 0`, `steel > 0`, `playable: true`. Four [STRUCTURE] failure modes pre-listed (F1 dotfile-path, F2 row-count, F3 coord-swap, F4 spawn-overlap).

**Result: claim verified.** None of the four pre-listed failure modes fired. F1 mitigated by `ProjectSettings.globalize_path("res://")` going through OS layer. F2 row stripping worked. F3 coords correct. F4 player spawn at (160, 220) lands in passable cell.

### Actions

1. **`scripts/LevelLoader.gd`** (NEW) — RefCounted static parser. `parse_stage(level, stage_number, col_offset=7, row_offset=2) -> Dictionary`. Reads `.research/repos/Tanks/resources/stages/N` via OS-layer FileAccess (bypasses Godot's res-filter for dotfile dirs). Legend `. # @ % ~` mapped to set_cell on brick/steel/grass/water TileMapLayers; `-` (ice) counted in `ice_skipped` pending phase-1 decision. Returns report dict with per-terrain counts + error string.
2. **`scripts/OriginalLevel.gd`** (NEW) — extends `scripts/Level.gd` (H1 tripwire respected — inherits `_replace_blocks()` from Level.gd without touching it). `_ready` wires player.shoot signal, reads `TANKE_OG_STAGE` env override, calls `LevelLoaderT.parse_stage(self, ...)`, then runs inherited `_replace_blocks()` which converts brick + water TileMapLayer cells to BrickBlock/WaterBlock StaticBody2D instances (same machinery as procedural mode).
3. **`scenes/OriginalLevel.tscn`** (NEW) — parallel to `ProceduralLevel.tscn`. Same 4 TileMapLayers (Steel/Brick/Grass/Water with identical TileSet defs), PlayerTank at (160, 220), Camera2D, side Walls. NO Spawner (iter 2+ work alongside eagle/roster). Default `stage_number=1`, `col_offset=7`, `row_offset=2` — centers 26×26 stage in 40×30 viewport.
4. **`loop/test_runner.gd`** (EXTENDED, not refactored) — added `--scene PATH` and `--og-stage K` flags. When `--scene` given, loads that PackedScene instead of preloaded ProceduralLevelScene; when `--og-stage K` given, sets `level.stage_number = K` before `add_child` (so `_ready` sees the right stage). Made `_collect()` defensive: `level.ps` and `level.level_seed` are guarded with `in level` checks (OriginalLevel lacks both — by design, terrain is deterministic from ASCII not from a seed).

### Verification (Step 4d + 4e)

**Procedural hash anchor preserved** — `godot ... --seed 42 --json` on default scene returns `tile_hash: 23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` exactly. Arc-2 cross-arc regression detector intact. **`make test` exit 0.**

**OriginalLevel stage-1 parse + reachable** — `godot ... --scene res://scenes/OriginalLevel.tscn --og-stage 1 --json` returns `brick:220 steel:8 grass:0 water:0 ice_skipped:0` exactly matching `grep -o '#'` (220), `grep -o '@'` (8), `grep -o '%'` (0), `grep -o '~'` (0), `grep -o '\-'` (0) on the source. `playable: true`, `reachable_cells: 972`, `rows_climbed: 27`.

**Full 35-stage sweep** — 35/35 stages parse with exact per-cell terrain match (automated cell-count diff via `grep -o` on source vs LevelLoader emit counts) AND all 35 report `playable: true`. Four stages (17, 24, 28, 32) contain ice — total 954 ice cells skipped pending phase-1 decision iter; no crashes.

### Scores (Step 5)

| C# | Name | Score | Tag | Cite |
|----|------|-------|-----|------|
| 1 | Loader correctness | **4** | [STRUCTURE] | All 35 Tanks stages parse without error; automated cell-count diff (grep vs emit) yields 35/35 exact match per terrain bucket; legend `.#@%~-` all handled in code. Anchor 5 (`make test` covers edge cases) deferred — error handling exists but isn't yet exercised by test target. |
| 2 | Eagle gameplay | 0 | — | No eagle entity (iter 2-3 work). |
| 3 | Ice physics | 0 | — | Loader skips `-` silently with counter; phase-1 decision iter pending. Cannot claim anchor 1 yet — that requires the explicit decision ("pass-through OR slide chosen + cited"), and "deferred" isn't a decision. |
| 4 | PNG-diff oracle | 0 | — | `tools/png_diff.py` not built (iter 2-3 work). |
| 5 | Enemy roster fidelity | 0 | — | Tanks `src/` not yet mined (iter 1-2 sub-research per PROMPT KNOWN GAPS). |
| 6 | Mode selection | 0 | — | No title/picker scene. |
| 7 | Stages 1-12 complete | 0 | — | Gates 1+2+3 ✓ for all 12 in this third (iter 001 sweep); gates 4 (eagle), 5 (PNG diff), 6 (roster) pending. PNG-diff floor blocks any score > 0 here. |
| 8 | Stages 13-24 complete | 0 | — | Same — gates 1+2+3 ✓ for all 12; gates 4-6 pending. |
| 9 | Stages 25-35 complete | 0 | — | Same — gates 1+2+3 ✓ for all 11; gates 4-6 pending. |
| 10 | End-to-end playable run | **1** | [STRUCTURE-DEFERRED] | Stage 1 loads in headless oracle; "plays" half of anchor 1 awaits PLAYTEST. PLAYTEST gate (mode-select + stage-1 load) not fully open — mode-select still 0. |
| **Total** | | **5/50** | | |

### Tag balance

- [STRUCTURE]: 1 cite (C1). Arc-3 expected pattern — terrain match is code-verifiable.
- [STRUCTURE-DEFERRED]: 1 cite (C10). Awaits PLAYTEST.
- [FEEL]: 0. None of iter 1's lifts touched feel territory.
- [MIXED]: 0.

### Substrate guardrails verified

- `scripts/Level.gd` — UNTOUCHED. OriginalLevel.gd inherits cleanly.
- `scripts/ProceduralLevel.gd` — UNTOUCHED. Hash anchor `23d6a2ec…` unchanged.
- All other hard substrate (LevelConfig, BiomeConfig, ProceduralStep, LevelDNA, Bullet, Enemy*, Spawner, PlayerTank, BrickBlock, playable.tres) — UNTOUCHED.
- `.research/repos/Tanks/` — read-only access only (H2 tripwire respected).
- `loop/test_runner.gd` — EXTENDED with new flags + defensive lookups; existing code paths unchanged.

### Stage progress this iter

`STAGES.md`: all 35 stages annotated with gates 1+2+3 ✓ + symbol coverage + per-stage cell breakdown for stages 1-10. No checkboxes flipped yet (full 6-gate completion still pending eagle/PNG/roster).

### Next iter

Iter 2 priorities (in order of unblock value):
1. **PNG-diff oracle scaffold** (criterion 4) — build `tools/png_diff.py` that compares rendered-stage screencap to a reference PNG and reports per-tile mismatch %. Iter-2 anchor: tool exists, runs on stage 1.
2. **Eagle entity** (criterion 2) — `scripts/Eagle.gd` + `scenes/Eagle.tscn` (HP=1, eagle_destroyed signal). Iter 2-3.
3. **Per-stage enemy roster mining** (criterion 5) — read `.research/repos/Tanks/src/` for canonical spawn data.

Pre-mortem due at iter 2 start. Halt-rule countdown: PLAYTEST gate not yet open (no mode-select). Sprint authorization: none active.

### Commit

`chore(originals): iter 001 — BUILD/CAPABILITY — LevelLoader + OriginalLevel + test_runner --scene/--og-stage`

---

## Iter 002 — BUILD / CAPABILITY (PNG-diff oracle)

**Mode:** BUILD (with CAPABILITY sub-focus on `tools/png_diff.py`)
**Date:** 2026-05-15
**Branch:** `arc-3-originals`
**Focus:** PNG-diff oracle (criterion 4) — unblocks PNG-diff floor on criteria 7/8/9

### Pre-mortem (cited; full text in `PRE-MORTEMS.md` iter 002)

Carry from iter-001 Nat-13 meta: **falsifiable claim must include a generalization clause — N > 1 test cases drawn from the actual variation space, not just the example case.** This iter applies the cure.

Falsifiable claim: tool runs on **stages 1, 4, 7, 17** (deliberate variety: brick+steel only / four-terrain / steel-heavy / first-ice) producing coherent reports; self-diff returns 0%; <30% mismatch on real reference (the iter-2 plausibility threshold).

**Result: claim verified, generalization clause satisfied, anchor pre-mortem F2/F3 both partially fired and mitigated:**
- F1 (StrategyWiki anti-bot): did NOT fire — CDN URL with a normal user-agent fetched cleanly.
- F2 (palette classifier confusion): partially fired — stage 4 produces a "forest → steel" misclassification (1 cell); root cause is the placeholder TANKE_ANCHORS forest color. Below the 5% threshold; iter-3 work to refine.
- F3 (render-resolution mismatch): pre-empted by `_auto_region` that picks crop offset from image size — also fixed a self-diff crash that the pre-mortem didn't predict (208×208 vs 320×240 region mismatch).
- F4 (pixel-vs-tile diff): non-issue — tool designed at tile-classification granularity from the start.

### Actions

1. **`tools/refs/`** (NEW) — cached StrategyWiki reference PNGs. Stages 01/04/07/17 fetched via `curl` against `cdn.wikimg.net`. Each 208×208 indexed-color (`P` mode) per synthesis spec.
2. **`tools/png_diff.py`** (NEW) — PIL pipeline. CLI: `--reference REF --render RND [--stage K] [--ascii-source PATH] [--no-mask-player] [--json]`. Classifies each 8-px sub-brick (676 cells = 26×26) to {empty, brick, steel, forest, water, ice} via per-palette nearest-color match. Auto-detects palette (NES black-background vs tanke gray-background) by sampling crop origin. Outputs mismatch %, per-cell mismatch list, confusion matrix; with `--ascii-source`, adds triple-diff (ASCII source vs ref vs render). Exit code 0 if `<5%`, 1 if `≥5%`, 2 on error.
3. **`scripts/OriginalLevel.gd`** — env var `TANKE_OG_STAGE` already wired in iter 1; verified the `make screenshot-og` path actually overrides `stage_number` correctly (the env override fires before `_ready` runs `LevelLoader.parse_stage`).
4. **`Makefile`** (EXTENDED) — added `screenshot-og STAGE=K` (renders OriginalLevel.tscn with TANKE_OG_STAGE=K via the existing `--write-movie` capture path) + `png-diff-og STAGE=K` (depends on screenshot-og; runs png_diff.py against `tools/refs/Battle_City_StageKK.png`). Procedural `screenshot`, `test`, `check`, `analyze`, `diff` targets untouched.

### Verification (Step 4)

| Stage | Ref-vs-render | ASCII-vs-ref | ASCII-vs-render | Notes |
|-------|---------------|--------------|-----------------|-------|
| 1 | **0.299%** ✓ | 0.0% | 0.299% | 2 cells: empty→steel + empty→ice (PlayerTank leak outside mask) |
| 4 | **0.448%** ✓ | 0.0% | 0.448% | 3 cells: forest→steel + forest→ice + forest→empty (TANKE_ANCHORS forest color placeholder; refine iter 3+) |
| 7 | **0.299%** ✓ | 0.0% | 0.299% | Same 2-cell PlayerTank artifact pattern as stage 1 |
| 17 | 32.239% (expected) | 1.194% | 31.045% | **206 ice→empty confusions = the loader skipping ice (known limitation; phase-1 decision pending). Tool correctly detects loader gap.** |

**Self-diff sanity baselines** (pre-mortem promise): NES ref vs itself → 0.0% mismatch; tanke render vs itself → 0.0% mismatch. Both pass.

**Edge cases handled** (anchor-5 prep): missing reference PNG → exit 2 with clear message; unsupported image size → exit 2 with clear message.

**Procedural hash anchor `23d6a2ec…` preserved exactly.** `make test` exit 0. Arc-2 baseline intact.

### Scores (Step 5)

| C# | Name | Before | After | Tag | Cite |
|----|------|--------|-------|-----|------|
| 1 | Loader correctness | 4 | **4** | [STRUCTURE] | Unchanged. PNG-level diff additionally confirms the iter-1 cell-count cite at sub-brick granularity (0.299–0.448% on stages 1/4/7, exact 206-cell ice gap on stage 17). Anchor 5 (`make test` covers edge cases) still requires loader edge cases in the make test target — incomplete. |
| 2 | Eagle gameplay | 0 | 0 | — | Iter 3+. |
| 3 | Ice physics | 0 | 0 | — | Iter-2 evidence shows ice-skip is the dominant stage-17 mismatch source; the loop now has empirical pressure for the phase-1 ice-decision iter. Still no anchor 1 (explicit decision iter not yet held). |
| 4 | PNG-diff oracle | 0 | **3** | [STRUCTURE] | Anchor 1: tool exists, runs on one stage, reports % ✓. Anchor 2: reads StrategyWiki PNG, classifies tiles, accuracy hand-verified on 1 stage ✓ (verified on 4). Anchor 3: per-stage report with mismatch % and per-coord diffs ✓. Anchor 4: integrated into loop workflow ("every IMPORT iter runs it") — *capable* via `make png-diff-og` but no IMPORT iter has fired yet to demonstrate the cite. Anchor 5: handles palette variants ✓ + missing reference ✓ + size variants ✓; "stage rotation" N/A for canonical BC. Conservative 3/5 — anchor 4 lands in the first IMPORT iter. |
| 5 | Enemy roster fidelity | 0 | 0 | — | Iter 3+ sub-research. |
| 6 | Mode selection | 0 | 0 | — | Iter 5+. |
| 7 | Stages 1-12 complete | 0 | 0 | — | PNG-diff floor now permits stages 1/4/7 (3 stages <5%). But full-6-gate completion still blocked by gates 4 (eagle) and 6 (roster). Floor permits up to 3 once gates 4+6 land. |
| 8 | Stages 13-24 complete | 0 | 0 | — | Same; PNG-diff floor permits 0 stages here (stage 17 is the only verified one and it fails the 5% threshold due to known ice-skip). |
| 9 | Stages 25-35 complete | 0 | 0 | — | No stages diffed in this third yet. |
| 10 | End-to-end playable run | 1 | 1 | [STRUCTURE-DEFERRED] | Unchanged; "plays" awaits PLAYTEST. |
| **Total** | | **5** | **8/50** | | |

### Tag balance (cumulative across iters 1+2)

- [STRUCTURE]: 2 cites (C1 iter 1, C4 iter 2). Arc-3 expected pattern (terrain match is code-verifiable).
- [STRUCTURE-DEFERRED]: 1 cite (C10).
- [FEEL]: 0.
- [MIXED]: 0.

### Substrate guardrails verified

- All Layer 1 + Layer 2 substrate UNTOUCHED.
- `.research/repos/Tanks/` — read-only access only (H2 tripwire respected).
- `tools/refs/` — NEW directory for cached references; contents are derivative of canonical sources (StrategyWiki PNGs).
- `Makefile` — extended with TWO new targets; existing procedural targets unchanged.
- Procedural hash anchor `23d6a2ec…` preserved.

### Nat-13 meta carry forward

Iter-2 pre-mortem opened with the generalization-clause cure. The clause held: tool was tested on 4 deliberately-varied stages, not just stage 1. Two implicit predictions verified that would have been missed on stage 1 alone:
1. Forest-color classification needs refinement (caught on stage 4, invisible on stage 1).
2. The loader's ice-skip is the dominant stage-17 mismatch (caught on stage 17, invisible on stage 1).

The discipline produced two iter-3+ work items that pure stage-1 testing would have shipped without surfacing. **Cure validated.**

### Next iter

Iter 3 priorities:
1. **Phase-1 ice decision iter** (criterion 3) — the synthesis flagged this; the iter-2 stage-17 result makes it concrete. Decision: pass-through (cap C3 at 2) OR slide-physics (path to C3=5). Recommend pass-through for v1 to unblock criteria 7/8/9 floor (the 206-cell ice gap is the dominant stage-17 failure; making the loader place a distinct ice tile fixes the diff even with pass-through semantics).
2. **Eagle entity** (criterion 2) — `scripts/Eagle.gd` + `scenes/Eagle.tscn`; HP=1; eagle_destroyed signal. Per-stage canonical eagle position derives from the brick-fortress `#..#` pattern at rows 24-25.
3. **PNG-diff workflow demo** (criterion 4 → 4) — first IMPORT iter that cites the diff result inline.

PLAYTEST gate: still not open (no mode-select). No halt-rule countdown.

### Commit

`chore(originals): iter 002 — BUILD/CAPABILITY — png_diff oracle + 4-stage generalization`

---

## Iter 003 — BUILD (ice pass-through + Eagle entity)

**Mode:** BUILD
**Date:** 2026-05-15
**Branch:** `arc-3-originals`
**Focus:** Phase-1 ice decision (pass-through) + Eagle entity (criterion 2) + player spawn fix + full re-diff sweep

### Pre-mortem (cited; full text in `PRE-MORTEMS.md` iter 003)

Falsifiable claim with generalization clause (Nat-13 cure carried): all 4 stages (1, 4, 7, 17) finish <5% mismatch — including stage 17 which was 32.239% in iter 2. Procedural hash anchor preserved. F1-F4 pre-listed; F3 mitigated pre-build by a 35-stage fortress survey (canonical `#..#` at cols 11-14 of rows 24-25 is UNIVERSAL across all 35 stages — confirmed by `sed` survey before writing eagle code).

**Result: claim verified.** Two pre-listed mitigations triggered correctly:
- F4 (ice color anchor mismatch) → set tanke ice texture to (200,200,200) exactly matching the existing `TANKE_ANCHORS["ice"]` value. Zero classifier confusion on the new ice cells.
- F3 (fortress non-canonical) → pre-build survey confirmed 35/35 stages share the fortress pattern. Hardcoded `EAGLE_SCREEN_POS = (160, 216)` is safe.

One unanticipated failure surfaced and was fixed mid-iter:
- **First-run import hang**: new PNGs (`img/ice_007.png`, `img/eagle_007.png`) and scenes (`Eagle.tscn`) lacked `.import` sidecars; `godot --headless` hung trying to silently import. Pattern: never assume Godot auto-imports new resources in `--headless --script` mode. Mitigation applied: ran `godot --headless --import` once to force-generate sidecars. Also removed two invalid hand-written `uid://` strings I'd put on the new scenes (Godot UIDs must be 13-char `[a-z0-9]` base32; mine contained `g`, `l`). Lesson: leave UIDs blank on new scenes — Godot generates valid ones on first import.

### Actions

1. **`img/ice_007.png`** (NEW) — 8×8 solid `(200,200,200)` RGBA. Matches `TANKE_ANCHORS["ice"]` so classifier reads it as "ice" with zero ambiguity.
2. **`img/eagle_007.png`** (NEW) — 16×16 placeholder: yellow-gold background with brown bird silhouette (body + 2 wings + head, 4 rectangles via PIL). Visually identifiable; iter-4+ can upgrade to a real NES-style sprite.
3. **`scenes/Eagle.tscn`** (NEW) — `StaticBody2D` with `collision_layer=1` (Environment) so Bullet's `mask=9` (Environment|Enemy) catches it via `_on_body_entered`. Sprite2D + 16×16 RectangleShape2D collision.
4. **`scripts/Eagle.gd`** (NEW) — HP=1; `take_damage(amount)` (matches `Bullet._on_body_entered` duck-typed contract; same shape as `BrickBlock.take_damage`); emits `eagle_destroyed` signal then `queue_free`s.
5. **`scripts/LevelLoader.gd`** (extended within iter-1 introduced file) — `-` symbol now writes to `iceTileMap` if the level exposes one; falls back to `ice_skipped++` otherwise (preserves the iter-1 behavior contract for any caller that doesn't add an Ice TileMapLayer).
6. **`scripts/OriginalLevel.gd`** (extended within iter-1 file) — added `@onready var iceTileMap: TileMapLayer` (queries `Ice` child of `tiles`), added `_spawn_eagle()` (instantiates Eagle at `EAGLE_SCREEN_POS = (160, 216)` = scene cells 19-20 × 26-27 = play-area cells 12-13 × 24-25, the canonical fortress inner cells), wired `eagle_destroyed` → `_on_eagle_destroyed` (logs only — game-over state machine is iter 4+).
7. **`scenes/OriginalLevel.tscn`** (extended) — added Ice TileMapLayer + Eagle ext_resource + ice TileSet sub-resources. Moved PlayerTank from `(160, 220)` (which overlapped the eagle) to `(124, 220)` (4 scene cells left of eagle, on bottom row; verified passable on stages 1/4/35).
8. **No edits to** `Level.gd`, `Bullet.gd`, `Spawner.gd`, `PlayerTank.gd`, `BrickBlock.gd`, or any arc-1/arc-2 substrate.

### Verification (Step 4)

| Stage | Iter-2 diff | Iter-3 diff | Δ | Notes |
|-------|-------------|-------------|---|-------|
| 1 | 0.299% | **0.448%** | +0.149% | Eagle + player-spawn move add ~1 cell mismatch outside the mask |
| 4 | 0.448% | **0.597%** | +0.149% | Same pattern; forest placeholder anchor still the dominant non-trivial confusion |
| 7 | 0.299% | **0.448%** | +0.149% | Same pattern |
| 17 | 32.239% | **1.642%** | **−30.6%** | **Headline cure**: 206 ice cells now render. `ascii_vs_render` is 0.448% — render matches ASCII source nearly exactly; the 1.6% vs reference is dominated by `ascii_vs_ref` = 1.194% (reference-PNG residual noise that's not in our control). |

**All 4 stages now under 5%.** Generalization clause fully satisfied.

**Procedural hash anchor `23d6a2ec…` preserved exactly.** `make test` exit 0. Arc-2 baseline intact.

### Scores (Step 5)

| C# | Name | Before | After | Tag | Cite |
|----|------|--------|-------|-----|------|
| 1 | Loader correctness | 4 | **4** | [STRUCTURE] | Unchanged. Ice now placed (no longer "skipped") — strengthens the cite but anchor 5 (`make test` covers edge cases) still requires test-target additions. |
| 2 | Eagle gameplay | 0 | **2** | [STRUCTURE] | Anchor 1 (eagle sprite placed at correct stage position; static decoration) ✓ — eagle visible in all 4 rendered stages. Anchor 2 (HP=1; bullets can hit it; emits eagle_destroyed signal — code-cited) ✓ — `scripts/Eagle.gd:13-21` declares HP+signal+take_damage; collision_layer=1 matches Bullet's mask. Anchor 3 (game-over state on destroy) ✗ — handler currently just prints; iter 4+ work. |
| 3 | Ice physics | 0 | **2** | [STRUCTURE] | Anchor 1 (phase-1 decision iter — pass-through OR slide — chosen + shipped + cited) ✓ — pass-through chosen, shipped, cited here. Anchor 2 (ice tile renders distinctly) ✓ — gray (200,200,200) tiles visible on stage 17 render. Rubric caps at 2/5 for pass-through: "If pass-through chosen, cap at 2/5 (ship-but-don't-claim-faithful)." |
| 4 | PNG-diff oracle | 3 | **3** | [STRUCTURE] | Unchanged. Iter 3 demonstrated the workflow (4 stages cited) but anchor 4 wording is "every IMPORT iter runs it and cites result" — iter 3 is BUILD, not IMPORT. First IMPORT iter (iter 4+) will bump to 4. |
| 5 | Enemy roster fidelity | 0 | 0 | — | Iter 4+ sub-research. |
| 6 | Mode selection | 0 | 0 | — | Iter 5+. |
| 7 | Stages 1-12 complete | 0 | **2** | [STRUCTURE] | **Iter-2 LEDGER correction**: I previously under-scored C7 by reading STAGES.md's 6-gate completion bar instead of RUBRIC.md's 3-gate scoring bar. The rubric says C7 = count of stages that "parse via LevelLoader, pass reachability, PNG diff <5% mismatch" — three gates, not six. Stages 1, 4, 7 all hit all three: 3 stages complete → anchor 2 (3-5 stages) ✓. Score 2/5. |
| 8 | Stages 13-24 complete | 0 | **1** | [STRUCTURE] | Stage 17 now at 1.642% — passes all 3 rubric gates (parse + reachable + PNG <5%). 1 stage of 12 → anchor 1 (1-2 stages) ✓. Score 1/5. |
| 9 | Stages 25-35 complete | 0 | 0 | — | No stages in this third diffed yet. Iter 4+ should fetch additional references and diff. |
| 10 | End-to-end playable run | 1 | 1 | [STRUCTURE-DEFERRED] | Unchanged. Stage 1 still loads headless with eagle visible; "plays" half (anchor 1 stricter reading) needs PLAYTEST. Anchor 2 (linear progression) needs StageDirector — iter 4+. |
| **Total** | | **8** | **15/50** | | Iter-3 lift of 7 (= +2 from C2, +2 from C3, +2 from C7 correction, +1 from C8). |

### LEDGER correction acknowledgment

Iter 2 reported 8/50; the honest score by RUBRIC.md's literal wording was 10/50 (C7=2 should have been awarded then). Iter 3 corrects the bookkeeping while making the C8 lift earned-in-iter. Cumulative arc-3 score history (corrected):
- Iter 0: 0/50 (no scoring)
- Iter 1: 5/50 (correct at the time)
- Iter 2: **10/50** (corrected from 8/50 — C7 should have been 2)
- Iter 3: **15/50** (C2 +2, C3 +2, C8 +1)

The correction itself is the type of Nat-13 over-strictness the meta lens has surfaced before. Logging here to avoid silent inflation later.

### Tag balance (cumulative)

- [STRUCTURE]: 6 cites (C1, C2, C3, C4, C7, C8). Arc-3 expected pattern.
- [STRUCTURE-DEFERRED]: 1 cite (C10).
- [FEEL]: 0.
- [MIXED]: 0.

### Substrate guardrails verified

- Hard substrate (Layer 1) UNTOUCHED.
- Gameplay substrate (Layer 2): Bullet/Enemy/Spawner/PlayerTank/BrickBlock UNTOUCHED. (PlayerTank's *spawn position in OriginalLevel.tscn* moved — scene-level data, not the PlayerTank script.)
- `.research/repos/Tanks/` read-only.
- Procedural hash anchor `23d6a2ec…` preserved.

### Stage progress (STAGES.md updates)

Stages with all 5 first-gates (parse + cell-match + reachable + eagle + PNG <5%):
- 1, 4, 7, 17 ✓ in this iter. Eagle gate technically lands for all 35 simultaneously (canonical position), but PNG-diff only verified for these 4.
- Gate 6 (enemy roster) still pending across the board.

### Next iter

Iter 4 priorities:
1. **First IMPORT iter** (criterion 4 → 4): fetch references for stages 2, 3, 5, 6, 8, 9, 10, 11, 12 (the rest of the first third); render + PNG-diff; if all <5%, C7 lifts to 4 (9-11 stages) or 5 (all 12).
2. **Enemy roster mining** (criterion 5 → 1): grep `.research/repos/Tanks/src/` for canonical per-stage spawn data.
3. **Game-over signal handling** (criterion 2 → 3, criterion 10 enabler): when eagle_destroyed fires, transition to a game-over state; restart on input.

PLAYTEST gate: still not open (no mode-select). No halt-rule countdown.

### Commit

`chore(originals): iter 003 — BUILD — ice pass-through decision + Eagle entity + 35-stage fortress survey`

---

## Iter 004 — IMPORT (first-third PNG-diff sweep)

**Mode:** IMPORT (sub-mode of BUILD)
**Date:** 2026-05-15
**Branch:** `arc-3-originals`
**Focus:** Sweep PNG-diff across remaining first-third stages (2, 3, 5, 6, 8, 9, 10, 11, 12) + stretch enemy-roster mining (criterion 5)

### Pre-mortem (cited; full text in `PRE-MORTEMS.md` iter 004)

Generalization clause: all 9 new first-third stages produce <5% mismatch with current loader, eagle, ice rendering — no per-stage adjustment needed. F1-F5 pre-listed. F3 pre-mitigated by 35-stage spawn-cell passability survey (cols 8-9 of row 25 across all 35 stages — zero conflicts).

**Result: claim verified for all 9 stages, zero per-stage adjustment, zero loader tweaks.** F1/F2 (water + forest classifier drift) didn't fire — even stage 5 (60 water cells) and stages 6/8/9/10/11 (forest-heavy) classify under 0.5%. F4 (roster mining yields nothing) didn't fire — formula located + cited.

### Actions

1. **Fetched 9 new StrategyWiki references** to `tools/refs/Battle_City_Stage{02,03,05,06,08,09,10,11,12}.png` — all 208×208 indexed-color, all `http 200` from `cdn.wikimg.net`.
2. **Rendered 9 stages** via `make screenshot-og STAGE=K` — all produced clean 320×240 outputs in `tools/out/og/`.
3. **Ran PNG-diff sweep** on all 12 first-third stages (3 from iter 2-3 + 9 new).
4. **Enemy-roster source-mining** in `.research/repos/Tanks/src/`. Per arc-3 H2 tripwire: READ-ONLY.

### Verification (Step 4) — full first-third diff table

| Stage | mismatch% | ascii_v_ref | ascii_v_render | Top confusion |
|-------|-----------|-------------|-----------------|----------------|
| 1 | **0.448** | 0.000 | 0.448 | empty→steel:2 (PlayerTank artifact) |
| 2 | **2.090** | 1.791 | 0.299 | brick→empty:8 (StrategyWiki PNG has 12 cells the ASCII doesn't — UI markers) |
| 3 | **1.045** | 0.597 | 0.448 | brick→empty:4 (same ref-PNG-noise pattern) |
| 4 | **0.597** | 0.000 | 0.597 | forest→steel:1 (TANKE forest anchor placeholder; iter-5 refine) |
| 5 | **0.448** | 0.000 | 0.448 | empty→steel:2 |
| 6 | **0.448** | 0.000 | 0.448 | empty→steel:2 |
| 7 | **0.448** | 0.000 | 0.448 | empty→steel:2 |
| 8 | **0.448** | 0.000 | 0.448 | empty→steel:2 |
| 9 | **0.299** | 0.000 | 0.299 | empty→steel:1 |
| 10 | **0.448** | 0.000 | 0.448 | empty→steel:2 |
| 11 | **0.448** | 0.000 | 0.448 | empty→steel:2 |
| 12 | **0.448** | 0.000 | 0.448 | empty→steel:2 |

**All 12 first-third stages pass <5%.** Median mismatch 0.448%, max 2.090% (stage 2; dominated by reference-PNG residual noise of 1.791%, not our render). The `ascii_vs_render` column shows our render matches the canonical Tanks ASCII source nearly perfectly across the board — median 0.448%, max 0.597%.

The "empty→steel:2" pattern recurring across stages 1, 5-8, 10-12 is the PlayerTank sprite leaking 1-2 cells outside the iter-2 mask. Consistent artifact, well below 5%.

**Procedural hash anchor `23d6a2ec…` preserved exactly.** `make test` exit 0.

### Enemy roster source — criterion 5 unblock

Cited file:line from `.research/repos/Tanks/src/` (read-only per H2 tripwire):

1. **`appconfig.h:79`** — `inline unsigned enemies_to_kill_total_count = 20;` — **20 enemies per stage**, constant across all 35.
2. **`appconfig.h:80`** — `inline unsigned enemies_max_count_on_map = 4;` — max 4 simultaneous enemies.
3. **`appconfig.h:81`** — `inline unsigned stages_count = 35;` — stage count confirms BC canonical (not Tank 1990's 50).
4. **`app_state/game/game.cpp:518`** — **enemy type formula**: `SpriteType type = static_cast<SpriteType>(p < (0.00735 * m_current_stage + 0.09265) ? ST_TANK_D : (rand() % (ST_TANK_C - ST_TANK_A + 1) + ST_TANK_A));`
5. **`appconfig.h:39-43`** — player spawn at tile-coords `(8, 24)` and `(16, 24)` × 16-px tile_size = pixel `(128, 384)` and `(256, 384)` in their 416×416 viewport. *NOTE: my iter-3 PlayerTank at scene (124, 220) is approximately at Tanks's `(8*8, 24*8) + (col_offset*8, row_offset*8) = (120, 208)` — minor mismatch (current y=220 vs canonical y=212). Spot-check correction is iter-5 work.*

**Key finding:** enemy roster is FORMULA-DRIVEN, not per-stage-table. Probability of `ST_TANK_D` (armored, highest health) scales linearly with stage:
- Stage 1: p_armored = 0.00735 + 0.09265 ≈ **0.10** (10% chance per spawn)
- Stage 18 (mid): p_armored ≈ 0.225
- Stage 35: p_armored ≈ 0.349 (35% chance)

4 enemy types: `ST_TANK_A`, `ST_TANK_B`, `ST_TANK_C`, `ST_TANK_D` (basic → armored continuum). arc-2's `EnemyLight` / `EnemyHeavy` map cleanly: Light = A/B/C distribution; Heavy = D. arc-3 integration plan: extend `scripts/Spawner.gd` (arc-2 soft-substrate) to read `stage_number` and apply the per-stage Heavy probability formula. **Reserved for iter 5-6.** (This will be arc-3's only soft-substrate write to arc-2's Spawner per PROMPT Layer-2 spec.)

**Disambiguation correction**: my pre-mortem said "Java source" — the actual Tanks repo is C++ (just like the synthesis's first paragraph implies but later sections drift). Logged here for synthesis correction in iter 5 audit if relevant.

### Scores (Step 5)

| C# | Name | Before | After | Tag | Cite |
|----|------|--------|-------|-----|------|
| 1 | Loader correctness | 4 | **4** | [STRUCTURE] | Unchanged. |
| 2 | Eagle gameplay | 2 | **2** | [STRUCTURE] | Unchanged (anchor 3 game-over state still iter 4+; this iter was IMPORT, not eagle-deepening). |
| 3 | Ice physics | 2 | **2** | [STRUCTURE] | Rubric-capped at pass-through. |
| 4 | PNG-diff oracle | 3 | **4** | [STRUCTURE] | Anchor 4 ✓ — "Tool integrated into the loop's verification flow; every IMPORT iter runs it and cites result." This IS the first IMPORT iter; 12-stage table cited inline above; STAGES.md updated. Anchor 5 (stage rotation handling) N/A for canonical BC — practical ceiling. |
| 5 | Enemy roster fidelity | 0 | **1** | [STRUCTURE] | Anchor 1 ✓ — "Sub-research iter run: per-stage roster located in Tanks source — cited file:line." 4 specific file:line citations above. Anchors 2+ require encoding into `configs/stages/` + Spawner integration. |
| 6 | Mode selection | 0 | 0 | — | No title/picker scene. |
| 7 | Stages 1-12 complete | 2 | **5** | [STRUCTURE] | **All 12 stages pass parse + reachable + PNG diff <5%.** Anchor 5 ("All 12 complete"). Cited in table above. |
| 8 | Stages 13-24 complete | 1 | **1** | [STRUCTURE] | Unchanged (stage 17 verified iter 3; other middle-third stages await iter 5+ sweep). |
| 9 | Stages 25-35 complete | 0 | 0 | — | No diffs yet in final third. |
| 10 | End-to-end playable run | 1 | 1 | [STRUCTURE-DEFERRED] | Unchanged. |
| **Total** | | **15** | **20/50** | | +5 in iter 4 (+1 C4, +1 C5, +3 C7). |

### Tag balance (cumulative)

- [STRUCTURE]: 7 cites (C1, C2, C3, C4, C5, C7, C8). Arc-3 expected pattern.
- [STRUCTURE-DEFERRED]: 1 cite (C10).
- [FEEL]: 0.
- [MIXED]: 0.

### Substrate guardrails verified

- Hard substrate UNTOUCHED.
- Gameplay substrate (Layer 2) UNTOUCHED.
- `.research/repos/Tanks/` read-only (grep + cat only).
- Procedural hash anchor `23d6a2ec…` preserved.
- No code edits this iter — only data fetches + diff runs + LEDGER cites.

### Stage progress (STAGES.md updates this iter)

Stages 2, 3, 5, 6, 8, 9, 10, 11, 12 — gate 5 ✓ added for each.
Gate 6 (enemy roster) — partial unblock: roster source located + cited, but per-stage data not yet encoded to `configs/stages/`. Gate 6 stays unchecked.

### Next iter

Iter 5 priorities:
1. **Middle-third sweep** (criterion 8 → 5): fetch references for stages 13-16, 18-24 (10 new) + render + diff. Likely all pass <5% based on iter-4 generalization confidence.
2. **Final-third sweep** (criterion 9 → 5): same for stages 25-35 (11 new).
3. **Mode selection scene** (criterion 6 → 1+): title screen + Originals/Procedural picker. Unblocks the USER-LOOK PROTOCOL first-playtest gate.
4. **Player spawn correction**: move PlayerTank from (124, 220) to (120, 212) per Tanks's canonical `(8*16, 24*16)` mapped through arc-3's 8-px tile size.

Pragmatic ordering: probably iter 5 = middle+final third sweep (mechanical, fast); iter 6 = mode selection (enables first PLAYTEST); iter 7 = first PLAYTEST + roster encoding + spawn fix.

PLAYTEST gate still closed — no mode-select. After mode-select lands, the first PLAYTEST request fires; the 3-iter halt-rule countdown begins from there.

### Commit

`chore(originals): iter 004 — IMPORT — first-third sweep (12/12 pass) + enemy-roster source located`

---

## Iter 005 — IMPORT (middle + final third sweep) + classifier robustness fix

**Mode:** IMPORT (with mid-iter CAPABILITY: classifier palette-detector hardening)
**Date:** 2026-05-15
**Branch:** `arc-3-originals`
**Focus:** Sweep PNG-diff across all unverified stages (13-16, 18-24, 25-35 = 22 stages)

### Pre-mortem (cited; full text in `PRE-MORTEMS.md` iter 005)

Falsifiable claim: all 22 unverified stages pass <5%. Scope overshoot acknowledged (PROMPT suggests "2-5 stages" per IMPORT iter; sweeping 22 is mechanically justified given iter-4's verified zero-tweak generalization). F1 (per-stage terrain combo) was the predicted failure mode — and one variant fired (stage 32 dominated by ice cells; palette-detector heuristic broke). Cured mid-iter with a structural fix to the classifier.

**Result: 35/35 stages pass <5% after mid-iter classifier fix.** F1 fired on stage 32 in a specific way the pre-mortem hadn't fully anticipated, surfaced a real classifier robustness gap, and the fix landed in the same iter.

### Actions

1. **Fetched 22 StrategyWiki references** to `tools/refs/Battle_City_Stage{13-16,18-24,25-35}.png`. All 208×208 indexed-color, all `http 200` from `cdn.wikimg.net`.
2. **Rendered 22 stages** via `make screenshot-og STAGE=K`. All produced clean 320×240 outputs.
3. **Full 35-stage diff sweep** — first run revealed stage 32 at 79.254% mismatch.
4. **Classifier fix (mid-iter CAPABILITY work)** — `tools/png_diff.py:_detect_palette` was using a single-pixel sample at (x+1, y+1) of the play-area region. Stage 32's top-left cell is ice gray (127,127,127), not empty black. The anti-aliased edge between adjacent ice cells produced (188, 188, 188) at pixel (1, 1) — which the heuristic `max(px) < 30` classified as TANKE palette → render and ref both classified with TANKE_ANCHORS → 311 cells of "ice on render maps to steel on ref" because TANKE steel anchor (173,173,173) is closer to gray (127,127,127) than TANKE ice anchor (200,200,200). Fix: detect palette by image mode (NES references are 8-bit indexed `P`; tanke `--write-movie` output is `RGB`/`RGBA`), with multi-cell fallback for RGB images that need content inspection.
5. **Re-ran 35-stage sweep post-fix** — full 35/35 pass.

### Verification — full 35-stage table

| Stage | Mismatch% | Stage | Mismatch% | Stage | Mismatch% |
|-------|-----------|-------|-----------|-------|-----------|
| 1 | **0.448** | 13 | **1.045** | 25 | **0.448** |
| 2 | **2.090** | 14 | **0.597** | 26 | **0.448** |
| 3 | **1.045** | 15 | **2.090** | 27 | **0.597** |
| 4 | **0.597** | 16 | **0.299** | 28 | **0.299** |
| 5 | **0.448** | 17 | **1.642** | 29 | **0.448** |
| 6 | **0.448** | 18 | **0.597** | 30 | **0.448** |
| 7 | **0.448** | 19 | **0.448** | 31 | **0.448** |
| 8 | **0.448** | 20 | **0.448** | 32 | **1.493** |
| 9 | **0.299** | 21 | **0.448** | 33 | **0.448** |
| 10 | **0.448** | 22 | **0.448** | 34 | **0.448** |
| 11 | **0.448** | 23 | **0.448** | 35 | **0.448** |
| 12 | **0.448** | 24 | **0.448** |  |  |

**35/35 PASS. Median 0.448%. Max 2.090% (stages 2 and 15, dominated by ref-PNG residual noise — `ascii_vs_render` is 0.299–0.448% on those). Stage 32 (the ex-failure) at 1.493% post-fix.**

**Procedural hash anchor `23d6a2ec…` preserved.** `make test` exit 0.

### Classifier-fix structural detail

Before: `_detect_palette` was 5 lines, one sample point. Brittle against any stage whose top-left isn't a clear background cell.

After: 20 lines, primary signal is image mode (deterministic), fallback is 16-cell distributed sampling that requires only ONE pure-black sample to commit to NES palette. The fix is structurally honest — it leverages a real distinguishing feature of the input (encoding format) rather than guessing from content.

### Scores (Step 5)

| C# | Name | Before | After | Tag | Cite |
|----|------|--------|-------|-----|------|
| 1 | Loader correctness | 4 | **4** | [STRUCTURE] | Unchanged. |
| 2 | Eagle gameplay | 2 | **2** | [STRUCTURE] | Unchanged (anchor 3 still iter 6+). |
| 3 | Ice physics | 2 | **2** | [STRUCTURE] | Rubric-capped at pass-through. |
| 4 | PNG-diff oracle | 4 | **4** | [STRUCTURE] | Unchanged. Iter-5 palette-detector hardening brings anchor 5 closer (palette variants ✓) but "stage rotation" anchor-5 list item is N/A for canonical BC; stay at 4 honestly. |
| 5 | Enemy roster fidelity | 1 | **1** | [STRUCTURE] | Unchanged (anchor 2 awaits per-stage data encoding). |
| 6 | Mode selection | 0 | 0 | — | No title/picker scene. |
| 7 | Stages 1-12 complete | 5 | **5** | [STRUCTURE] | Unchanged (already at 5 in iter 4). |
| 8 | Stages 13-24 complete | 1 | **5** | [STRUCTURE] | All 12 middle-third stages pass <5%. Stages 13, 14, 15, 16, 17 (carry from iter 3), 18, 19, 20, 21, 22, 23, 24 — table above. |
| 9 | Stages 25-35 complete | 0 | **5** | [STRUCTURE] | All 11 final-third stages pass <5%. Stages 25, 26, 27, 28, 29, 30, 31, 32 (post-classifier-fix), 33, 34, 35 — table above. |
| 10 | End-to-end playable run | 1 | 1 | [STRUCTURE-DEFERRED] | Unchanged. |
| **Total** | | **20** | **29/50** | | +9 in iter 5 (+4 C8, +5 C9). |

### Ceiling rule check

Per PROMPT: "If total hits 35/50 before iter 15, the rubric was too easy." Current 29/50 at iter 5. Iter 6 (mode selection + likely C2 anchor-3 lift) plausibly hits 32-35. **Pre-emptive note**: if iter 6 brings score to ≥35, the CEILING RULE fires — iter 7 should be a MODE=AUDIT iter that either (a) adds 2 new criteria, (b) raises score-4/5 anchor definitions, or (c) renames criteria via reframe protocol. Likely candidates for new criteria: "identity test" (does it feel like BC to a fan in 60-second playtest), "feedback to procedural" (arc-3 → arc-2 metric handshake from PROMPT).

### Tag balance (cumulative)

- [STRUCTURE]: 8 cites.
- [STRUCTURE-DEFERRED]: 1 cite.
- [FEEL]: 0.
- [MIXED]: 0.

### Substrate guardrails verified

- Hard substrate UNTOUCHED.
- Gameplay substrate (Layer 2) UNTOUCHED.
- `.research/repos/Tanks/` read-only.
- Procedural hash anchor `23d6a2ec…` preserved exactly.
- `tools/png_diff.py` edited (capability tooling layer, not substrate): palette detector hardened; existing API unchanged; all 4 prior-passing stages still pass at identical mismatch %.

### Stage progress

35/35 stages now have gates 1+2+3+4+5 ✓. Gate 6 (per-stage enemy roster) is the last hold-out — the formula source is located (iter 4 cite) but per-stage data isn't encoded to `configs/stages/`. Once gate 6 lands, all 35 STAGES.md checkboxes can flip.

### Next iter

Iter 6 priorities (high-leverage):
1. **Mode selection scene** (criterion 6 → 1+): opens the PLAYTEST gate per USER-LOOK protocol.
2. **Eagle game-over state** (criterion 2 → 3): `_on_eagle_destroyed` should transition to a `game_over` state with restart input.
3. **StageDirector skeleton** (criterion 10 → 2): linear stage progression on game-clear (basic — load stage K+1 when all enemies dead OR eagle destroyed = game over).

Iter 6 likely brings score to 32-35; AUDIT iter 7 if ceiling fires.

PLAYTEST gate opens after mode-select lands. First playtest expected iter 6 or 7. 3-iter halt-rule countdown begins from then.

### Commit

`chore(originals): iter 005 — IMPORT — 22-stage sweep + classifier palette-detector hardening`

---

## Iter 006 — BUILD (TitleScreen + Eagle game-over)

**Mode:** BUILD
**Date:** 2026-05-15
**Branch:** `arc-3-originals`
**Focus:** Mode-selection scene (criterion 6) + eagle game-over state (criterion 2 anchor 3)

### Pre-mortem (cited; full text in `PRE-MORTEMS.md` iter 006)

Falsifiable claim: both Original and Procedural modes launchable from a single TitleScreen session; `make test` still exits 0; procedural hash anchor `23d6a2ec…` preserved; shooting eagle triggers GAME OVER overlay. F1-F5 pre-listed.

**Result: claim verified for structural axes; runtime mode-transition awaits PLAYTEST.** F2 pre-mitigated correctly (make test bypasses main_scene). F5 (raw-keycode approach) avoided InputMap dependency. F1 (double-launch race) cured by `_launching` latch in TitleScreen.gd.

### Actions

1. **`scenes/TitleScreen.tscn`** (NEW) — 320×240 layout: TANKE title (size 24), subtitle, two centered options (ORIGINALS, PROCEDURAL), yellow cursor `>` Label that moves between them, hint text at bottom.
2. **`scripts/TitleScreen.gd`** (NEW) — `_process()` polls raw keycodes (KEY_UP/DOWN/W/S to navigate, KEY_ENTER/SPACE to launch); `_launching` boolean latch prevents double-fire on async `change_scene_to_file`; targets `OriginalLevel.tscn` (selection 0) or `ProceduralLevel.tscn` (selection 1).
3. **`scripts/OriginalLevel.gd`** (extended within iter-1 file) — new `_process()` checks for game-over input (R reload, Esc back to title); new `_show_game_over()` builds a CanvasLayer (layer=10) with dim ColorRect + "GAME OVER" Label + restart hint; `_on_eagle_destroyed` now triggers the overlay instead of just logging.
4. **`project.godot`** — single-line edit: `run/main_scene` from `ProceduralLevel.tscn` to `TitleScreen.tscn`. Pre-existing window-config diff (carried unstaged across iters 1-5) was stashed before this edit and restored after the iter-6 commit, keeping the user's working-tree state untouched.

### Verification

- **Procedural hash anchor `23d6a2ec…` preserved** — `godot --script loop/test_runner.gd -- --seed 42 --json` on default config reproduces the exact 64-char fingerprint.
- **`make test` exit 0** — Makefile's `test` target loads `$(PROC_SCENE)` directly, bypassing the new TitleScreen as main_scene.
- **TitleScreen renders** — `--write-movie` capture shows 78 bright pixels in the title area; dominant colors are (255,255,255) for text + (255,255,0)-ish for the cursor. Screen geometry matches scene layout.
- **OriginalLevel still loads cleanly** with eagle entity: stage 1 oracle reports `brick=220 steel=8 playable=true ice=0`. No script errors from the iter-6 `_process()` / `_show_game_over()` additions.
- **TitleScreen headless boot**: zero script errors.

### Structural confidence for C6 anchor 2

Anchor 2 ("Both options load their respective mode without crashes") is code-cited via:
- `change_scene_to_file()` is Godot's canonical scene-transition API
- Both target paths (`res://scenes/OriginalLevel.tscn`, `res://scenes/ProceduralLevel.tscn`) load cleanly when directly invoked
- The `_launching` latch prevents the only realistic crash path (double-load race on rapid Enter)

Tagged `[STRUCTURE-DEFERRED]` for the runtime "both modes launchable from ONE session" half — that requires interactive playtest. Headless can't drive scene-change input the way the user can.

### Scores

| C# | Name | Before | After | Tag | Cite |
|----|------|--------|-------|-----|------|
| 1 | Loader correctness | 4 | 4 | [STRUCTURE] | Unchanged. |
| 2 | Eagle gameplay | 2 | **3** | [STRUCTURE] | Anchor 3 ✓ — `OriginalLevel.gd:_on_eagle_destroyed` shows GAME OVER overlay; R reloads; Esc → title. Bullet→eagle hit verified by collision-layer math (eagle layer 1 ∩ bullet mask 9). Anchor 4 (feel-cited) awaits PLAYTEST. |
| 3 | Ice physics | 2 | 2 | [STRUCTURE] | Rubric cap. |
| 4 | PNG-diff oracle | 4 | 4 | [STRUCTURE] | Unchanged. |
| 5 | Enemy roster fidelity | 1 | 1 | [STRUCTURE] | Unchanged (per-stage encoding still pending). |
| 6 | Mode selection | 0 | **3** | [STRUCTURE] / [STRUCTURE-DEFERRED] | Anchor 1 ✓ (text labels ORIGINALS / PROCEDURAL render). Anchor 2 ✓ [STRUCTURE-DEFERRED] (change_scene_to_file paths verified loadable individually; both-from-one-session awaits PLAYTEST). Anchor 3 ✓ (visible cursor `>` Label code-cited at `TitleScreen.gd:_update_cursor`). |
| 7 | Stages 1-12 complete | 5 | 5 | [STRUCTURE] | Unchanged. |
| 8 | Stages 13-24 complete | 5 | 5 | [STRUCTURE] | Unchanged. |
| 9 | Stages 25-35 complete | 5 | 5 | [STRUCTURE] | Unchanged. |
| 10 | End-to-end playable run | 1 | 1 | [STRUCTURE-DEFERRED] | Unchanged. Linear stage advance (anchor 2) still needs StageDirector + clear-condition. |
| **Total** | | **29** | **33/50** | | +4 (C2 +1, C6 +3). |

### Tag balance (cumulative)

- [STRUCTURE]: 9 cites.
- [STRUCTURE-DEFERRED]: 2 cites (C6 anchor-2 runtime, C10).
- [FEEL]: 0.
- [MIXED]: 0.

### Substrate guardrails verified

- Hard substrate UNTOUCHED.
- Gameplay substrate (Layer 2) UNTOUCHED.
- `.research/repos/Tanks/` read-only.
- Procedural hash anchor `23d6a2ec…` preserved exactly.
- `project.godot:run/main_scene` change is data; not in substrate freeze list. `make test` continues to load `ProceduralLevel.tscn` directly.

### USER-LOOK PROTOCOL — first PLAYTEST gate now OPEN

Per PROMPT user-look protocol: "Iter 1 (or first iter where mode-select + stage-1 load works): PLAYTEST." Both conditions now hold. The **first PLAYTEST request is officially open** and the 3-iter halt-rule countdown begins from the next iter where action is needed from the user.

Playtest deliverable (from `loop/gameplay/playtest-template.md`-style 2-question format):
1. Does the TitleScreen feel intentional? Can you navigate to either mode without fumbling?
2. Does Stage 1 look like Battle City Stage 1 — bilateral brick columns, steel-armored mid-corridor, eagle's brick fortress at bottom-center?

Halt-rule countdown: iter 6 = open. Iter 7 / 8 / 9 unfulfilled = `HALTED.md`.

### Next iter

Iter 7 priorities (in increasing risk to ceiling rule):
1. **PLAYTEST request** (USER-LOOK protocol) — mandatory; AWAITs user response per Step 7 rule "PLAYTEST: AWAIT user response (no scheduled retry)".
2. **Player spawn correction** (iter-4 cite): move PlayerTank from (124, 220) to (120, 212) per Tanks's canonical `(8*16, 24*16)` mapped through arc-3 tile-size. Minor STRUCTURE-only fix.
3. **Roster encoding** (criterion 5 → 2): write per-stage rosters to `configs/stages/stage_KK.tres` for the 35 stages. Uses iter-4-located formula.

If the playtest happens in iter 7 with both Q1 and Q2 positive, C2 and C6 can lift to 4 (feel-cited). That would push to 35/50 → **CEILING RULE fires**, iter 8 = AUDIT with rubric adjustment.

If playtest is not run in iter 7-8-9, halt-rule fires at iter 9.

### Commit

`chore(originals): iter 006 — BUILD — TitleScreen mode-select + Eagle game-over`
