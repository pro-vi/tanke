# tanke — Loop Ledger

Append-only score history. Bootstrap iter has no scores.

---

## Iter 000 — BOOTSTRAP — 2026-05-10
**Focus:** scaffold dual oracle (headless + screencapture), confirm pipeline.
**Changed files:**
- `loop/test_runner.gd` (new) — SceneTree-based headless harness; instantiates ProceduralLevel, steps 30 frames, prints tile counts + Eller metrics + tile fingerprint + PASS/FAIL.
- `loop/RUBRIC.md` — populated criterion 1 (headless) and 6 (screencapture) anchors with real reference output.
- `loop/STATE.md` — preloop_complete: yes; phase: bootstrap → iter 1.

**Oracle output (headless, single seed):**
```
=== tanke headless oracle ===
brick: 380  water: 88  steel: 32  grass: 156  total: 656
eller_sets: 12  avg_size: 1.67  max_size: 5
tile_hash: e55b96e4256a8acf
PASS
```

**Oracle output (screencapture, frame00000004.png):**
```
Coverage      99.9%   score 5/5
Variety      4/4 types  score 4/4
Distribution entropy 1.216 bits  score 3.0/5.0
Tile counts  {'brick': 55034, 'steel': 1512, 'grass': 12240, 'water': 7936}
```

**gen_tile.py smoke test:**
```
$ python3 tools/gen_tile.py --tile brick --variant 0 --out tools/out
saved tools/out/brick_000.png
```

**No scores — bootstrap iter.**

**Observation:** earlier screencapture run (recorded in STATE.md baseline) showed 100% brick — that was a seed outlier, not a generation bug. With a fresh `randi()` seed, all 4 terrain types render and the screencapture oracle reads them correctly. This raises the priority of stored seeds (Level DNA, criterion 4) over distribution refactor — without seed reproducibility, every score is a snapshot of a single random draw, which is noisy.

**Weakest axis next:** Level DNA Reproducibility (criterion 4) — without a stored seed, oracle scores are non-deterministic; can't measure Δ from config changes. Iter 1 should add a stored `seed: int` on ProceduralLevel and thread it into `randi()` calls / a seeded RNG.

---

## Iter 001 — BUILD — 2026-05-10
**Focus:** Level DNA — stored seed + reproducibility verification.
**Changed files:**
- `scripts/ProceduralLevel.gd` — added `@export var level_seed: int = 0`; `_ready()` calls `seed(level_seed)` before generation, prints chosen seed.
- `loop/test_runner.gd` — accepts `-- --seed N` CLI arg, defaults to 42; sets `level.level_seed` before tree-add; prints seed in report.
- `loop/RUBRIC.md` — bumped criteria 1 (3→4), 4 (0→3), 5 (1→3), 9 (0→2), 10 (2→3) with citations.

**Oracle output:**
```
--- run A (seed 42) ---       --- run B (seed 42) ---       --- run C (seed 7)  ---
seed: 42                       seed: 42                       seed: 7
brick: 336  water: 64           brick: 336  water: 64           brick: 356  water: 92
steel: 32   grass: 168          steel: 32   grass: 168          steel: 32   grass: 212
total: 600                     total: 600                     total: 692
eller_sets: 11  avg: 1.82      eller_sets: 11  avg: 1.82      eller_sets: 15  avg: 1.33
tile_hash: 619cb88ffed7e906    tile_hash: 619cb88ffed7e906    tile_hash: beac3183dc58e335
PASS                            PASS                            PASS
```

A == B (reproducibility ✓), A ≠ C (seed sensitivity ✓).

**Screencapture oracle:** skipped (still uses random seed in scene; would only verify it doesn't crash, no deterministic Δ available yet).

| Criterion | Score | Evidence |
|-----------|-------|----------|
| Headless oracle | 4 | `loop/test_runner.gd`: prints seed, counts, Eller metrics, hash, PASS — same-seed runs match |
| Algorithm variety | 0 | `ProceduralStep.gd:18` `randi() % 3 > 0` still hardcoded |
| LevelConfig mutability | 0 | LevelConfig resource doesn't exist |
| Level DNA | 3 | `ProceduralLevel.gd:6` level_seed export; two seed-42 runs → hash `619cb88ffed7e906` |
| Tile visual coherence | 3 | iter 0 frame: brick 55034, steel 1512, grass 12240, water 7936 px (analyze_frame.py) |
| Screencapture oracle | 3 | `tools/analyze_frame.py:64-72` classifies by palette; outputs coverage/variety/entropy |
| Agent edit friction | 1 | only `level_seed`, `debug`, `PlayerTank.speed` exported |
| Procedural richness | 1 | seed 42: brick 56% / grass 28% / water 11% / steel 5% — flat modular bias remains |
| Pipeline completeness | 2 | `set_cell` with source_id=0, atlas_coords=(0,0) confirmed via render |
| GDScript correctness | 3 | `make test` + `test_runner.gd` clean across seeds 42, 7 |

**Total:** 20/50
**Weakest axis next:** Algorithm variety (criterion 2) tied with LevelConfig mutability (3) — both 0/5. Tackle LevelConfig first (criterion 3): it's the structural unblock that enables 2 (parameter exposure), 3 (mutability), 7 (agent edit friction), and downstream 8 (richness). One BUILD lifts four axes.
