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
