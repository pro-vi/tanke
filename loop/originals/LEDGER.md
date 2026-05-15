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
