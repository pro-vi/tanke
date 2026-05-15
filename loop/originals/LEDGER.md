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
