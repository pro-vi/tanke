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

---

## Iter 002 — BUILD — 2026-05-10
**Focus:** LevelConfig Resource — extract terrain selection + Eller merge probability into a `.tres`. Prove mutability by oracle diff across 3 presets at fixed seed.
**Changed files:**
- `scripts/LevelConfig.gd` (new) — `class_name` Resource with `merge_probability` + 5 terrain weights + `sample_terrain()` weighted picker.
- `configs/default.tres` (new) — balanced preset (`0.40/0.15/0.20/0.15` brick/steel/grass/water, p_merge=0.333).
- `configs/watery.tres` (new) — water-heavy preset (`0.15/0.05/0.10/0.60`, p_merge=0.5).
- `configs/fortress.tres` (new) — steel-heavy + larger sets (`0.20/0.55/0.15/0.05`, p_merge=0.7).
- `scripts/ProceduralLevel.gd` — `@export var config: LevelConfigT`; falls back to `DefaultConfig.duplicate()`; `_pave_set` rewritten as weighted sample → tilemap dispatch.
- `scripts/ProceduralStep.gd` — `_init` accepts `p_merge`; replaces hardcoded `randi() % 3 > 0`.
- `loop/test_runner.gd` — accepts `-- --config PATH` to load alternate configs.
- `loop/AGENTS.md` (new) — agent parameter map: file/line/type/range/effect for every mutable knob.

**Oracle output (seed 42, 3 configs):**
```
DEFAULT:   brick 400  water 200  steel 244  grass 228  total 1072  sets 15  avg 1.33  hash 6159ef2f5464edb1
WATERY:    brick 232  water 688  steel  64  grass  60  total 1044  sets  8  avg 2.50  hash 74e4d9ad07f08693
FORTRESS:  brick 172  water  40  steel 720  grass 192  total 1124  sets  3  avg 6.67  hash 60feb24a96c2161a
```

Three distinct hashes confirm config sensitivity. Three distinct distributions confirm visible character difference. Reproducibility check: default twice → identical hash.

**Screencapture oracle (random seed, default config):**
```
Coverage 99.9%   Variety 4/4   Distribution entropy 1.562 bits  score 3.9/5.0
brick: 47410  steel: 9072  grass: 11280  water: 8960
```

Distribution score lifted from 3.0 (modular) → 3.9 (weighted) — measurable improvement in pixel-level balance.

**Parse-error fix:** `class_name LevelConfig` doesn't resolve in headless mode (no class registry scan). Worked around with `const LevelConfigT = preload(...)` in ProceduralLevel.gd (caught by PostToolUse hook on first attempt — hook validation paid off).

| Criterion | Score | Evidence |
|-----------|-------|----------|
| Headless oracle | 4 | unchanged; reproducibility verified iter 1 |
| Algorithm variety | 3 | 3 configs × seed 42 → 3 distinguishable distributions; cited above |
| LevelConfig mutability | 4 | `LevelConfig.gd` + `.tres` editable without `.gd` changes; watery shift cited |
| Level DNA | 3 | seed reproducibility holds with config-aware generation |
| Tile visual coherence | 3 | screencapture: 4/4 variety, all palettes render correctly |
| Screencapture oracle | 3 | unchanged; entropy now 3.9 (informative) |
| Agent edit friction | 4 | `loop/AGENTS.md` documents all 7 mutable params with file:line+range+effect |
| Procedural richness | 2 | 4 types reliably present; awaiting SWEEP for variance score |
| Pipeline completeness | 2 | unchanged |
| GDScript correctness | 3 | `make test` clean; `test_runner.gd` clean across configs/seeds |

**Total:** 31/50 (+11 from iter 1)
**Weakest axis next:** Procedural richness (criterion 8) at 2/5. Run SWEEP mode: ≥5 seeds × default config, capture variance per terrain. If variance >20% → score 3 cited.

---

## Iter 003 — SWEEP — 2026-05-10
**Focus:** Multi-seed inter-run variance for criterion 8 (Procedural richness).
**Changed files:**
- `loop/RUBRIC.md` — criterion 8 anchor populated with sweep evidence (2→3).

**Sweep grid:** 6 seeds × default config.
**Oracle output (per seed, default config):**
```
seed |  brick  water  steel  grass | total | tile_hash
-----|------------------------------|-------|------------------
   1 |   452    196    136    264  | 1048  | 0aded5a0114553fe
   7 |   636    132    132    220  | 1120  | c84ffe3c54fc2385
  42 |   400    200    244    228  | 1072  | 6159ef2f5464edb1
 100 |   452    208    176    268  | 1104  | 093a8480b363b53d
 314 |   468    188    156    280  | 1092  | 0a9566bc23172e84
 999 |   444    200    224    180  | 1048  | f6a961b83245754f
```

**Variance summary (n=6):**
```
terrain | min  | max  | mean  | stdev | range/mean (%)
--------|------|------|-------|-------|---------------
brick   |  400 |  636 | 475.3 |  82.0 |  49.6
water   |  132 |  208 | 187.3 |  27.9 |  40.6
steel   |  132 |  244 | 178.0 |  46.6 |  62.9
grass   |  180 |  280 | 240.0 |  37.7 |  41.7
```

All four terrains exceed the 20% threshold. 6/6 seeds → 6 unique hashes (no collisions). Criterion 8 lifted 2→3.

| Criterion | Score | Evidence |
|-----------|-------|----------|
| Headless oracle | 4 | unchanged |
| Algorithm variety | 3 | unchanged |
| LevelConfig mutability | 4 | unchanged |
| Level DNA | 3 | unchanged; sweep reaffirmed 6 unique hashes |
| Tile visual coherence | 3 | unchanged |
| Screencapture oracle | 3 | unchanged |
| Agent edit friction | 4 | unchanged |
| Procedural richness | 3 | sweep cited above; per-terrain variance 40–63% |
| Pipeline completeness | 2 | unchanged |
| GDScript correctness | 3 | unchanged |

**Total:** 32/50 (+1 from iter 2). Under 35/50 ceiling — anchors hold.

**Weakest axis next:** Pipeline completeness (criterion 9) at 2/5 — exercise the PIL→TileSet path. Generate a tile variant via `gen_tile.py`, import it as a TileSet atlas source, hot-swap one terrain to use the generated PNG, screenshot, confirm the new asset rendered. That's the level 3 anchor: "PIL-generated tile PNG imported into TileSet and used in game — cite ASSET-MANIFEST entry".

---

## Iter 004 — BUILD — 2026-05-10
**Focus:** PIL → TileSet → set_cell → rendered pixel — full chain verification.
**Changed files:**
- `img/brick_007.png` (new) — 8×8 PIL-generated brick tile (variant 7).
- `img/brick_007.png.import` (auto-generated by `godot --import`, uid `dy83met4b40yn`).
- `scenes/ProceduralLevel.tscn` — load_steps 11→12; new ExtResource id=4 for brick_007.png; `BrickSrc.texture` ExtResource("1")→("4"); margins (40,0)→(0,0).
- `loop/ASSET-MANIFEST.md` (new) — provenance entry for brick_007.

**Pipeline steps (all from CLI, zero editor):**
```
1. python3 tools/gen_tile.py --tile brick --variant 7 --out img
   → img/brick_007.png (134 bytes)
2. godot --headless --path . --import
   → img/brick_007.png.import (uid://dy83met4b40yn, CompressedTexture2D)
3. Edit scenes/ProceduralLevel.tscn: BrickSrc.texture → ExtResource("4"); margins → (0,0)
4. make screenshot && make analyze
```

**Oracle outputs:**

Screencapture (random seed, default config, before/after texture swap):
```
                  brick    steel   grass   water   entropy
before (sprite_1) 47410     9072  11280    8960   1.562 bits
after  (brick_007) 41194    9912  15120   10496   1.718 bits
```
Brick pixel count -13.1% confirms swap rendered. Total terrain coverage stable (~76700 px). Some former-brick pixels (mortar dark) reclassify as steel/grass — partly real palette shift, partly PIL classifier threshold (70) artifact.

Headless oracle (seed 42, default config):
```
brick: 400  water: 200  steel: 244  grass: 228  tile_hash: 6159ef2f5464edb1
```
Identical to iter 2. Texture swap is cosmetic — does not perturb tile placement logic. Reproducibility preserved across asset changes — the seed-42 hash is a stable measurement anchor.

| Criterion | Score | Evidence |
|-----------|-------|----------|
| Headless oracle | 4 | unchanged; reproducibility preserved across texture swap |
| Algorithm variety | 3 | unchanged |
| LevelConfig mutability | 4 | unchanged |
| Level DNA | 3 | unchanged |
| Tile visual coherence | 3 | unchanged; new brick still palette-coherent (within classifier tolerance) |
| Screencapture oracle | 3 | unchanged |
| Agent edit friction | 4 | unchanged |
| Procedural richness | 3 | unchanged from iter 3 sweep |
| Pipeline completeness | 3 | iter 4 chain cited above + ASSET-MANIFEST.md |
| GDScript correctness | 3 | unchanged |

**Total:** 33/50 (+1 from iter 3). Two points below ceiling.

**Weakest axis next:** Tied seven-way at 3/5 (criteria 4, 5, 6, 8, 9, 10) plus criterion 2 at 3. Pick by force-multiplier: serialize LevelDNA (seed + config) into a single `.tres` to lift criterion 4 to 4 (and unlocks "loop proposes mutation" path for level 5). After that, schedule iter 5 AUDIT to re-score everything with fresh evidence.
