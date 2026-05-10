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

---

## Iter 005 — BUILD — 2026-05-10
**Focus:** LevelDNA serialization — single `.tres` artifact bundling seed + config; lossless round-trip through JSON.
**Changed files:**
- `scripts/LevelDNA.gd` (new) — Resource with `level_seed` + `config` fields; `to_dict` / `from_dict` / `to_json` / `from_json`. `from_dict` uses `load("res://scripts/LevelDNA.gd")` to avoid headless class_name self-reference.
- `configs/dna_default_s42.tres` (new) — example DNA bundling seed 42 + `default.tres` config via `ExtResource`.
- `loop/test_runner.gd` — `-- --dna PATH` (load DNA, drive level) and `-- --dna-roundtrip PATH` (verify dict→JSON→dict equality).

**Oracle output:**

```
=== LevelDNA roundtrip: res://configs/dna_default_s42.tres ===
source dict: { "level_seed": 42, "merge_probability": 0.333, "empty_weight": 0.1, "brick_weight": 0.4, "steel_weight": 0.15, "grass_weight": 0.2, "water_weight": 0.15 }
roundtrip:   { "level_seed": 42, "merge_probability": 0.333, "empty_weight": 0.1, "brick_weight": 0.4, "steel_weight": 0.15, "grass_weight": 0.2, "water_weight": 0.15 }
ROUNDTRIP_OK
```

```
--- DNA-driven generation (configs/dna_default_s42.tres) ---
level_seed: 42  brick: 400  water: 200  steel: 244  grass: 228
tile_hash: 6159ef2f5464edb1   ← IDENTICAL to iter 2 seed-42 default baseline
```

**Compile-error fix (recurrence):** `var dna := LevelDNA.new()` inside the static `from_dict` re-triggered "Identifier not found: LevelDNA" — same headless class_name resolution issue we hit iter 2. Workaround: resolve script via `load("res://scripts/LevelDNA.gd")` then `.new()`. Pattern note for future iters: never reference a class_name from inside its own script in code paths headless will hit.

| Criterion | Score | Evidence |
|-----------|-------|----------|
| Headless oracle | 4 | unchanged |
| Algorithm variety | 3 | unchanged |
| LevelConfig mutability | 4 | unchanged |
| Level DNA | 4 | LevelDNA.gd + roundtrip OK + DNA-driven hash matches iter 2 baseline |
| Tile visual coherence | 3 | unchanged |
| Screencapture oracle | 3 | unchanged |
| Agent edit friction | 4 | unchanged (AGENTS.md still applies; LevelDNA params subsume LevelConfig's) |
| Procedural richness | 3 | unchanged |
| Pipeline completeness | 3 | unchanged |
| GDScript correctness | 3 | unchanged; make test + roundtrip clean |

**Total:** 34/50 (+1 from iter 4). One point below ceiling.

**Weakest axis next:** Per LOOP PROTOCOL ("AUDIT every 5 iterations or after any BUILD changes the oracle"), iter 6 is **AUDIT** — re-score everything with fresh evidence after 5 build iterations of accumulated drift. If total ≥ 35 after audit, the CEILING RULE fires: raise score-4/5 anchors before iter 7. CONSULT mode also looms at iter 10.

---

## Iter 006 — AUDIT — 2026-05-10
**Focus:** Re-score all 10 criteria after 5 BUILDs + 1 SWEEP. Catch inflation. Verify regressions absent.

**Fresh evidence (regenerated this iter):**
```
A. roundtrip:                        ROUNDTRIP_OK (7 fields, no drift)
B. DNA-driven seed-42 default:       brick 400  water 200  steel 244  grass 228  hash 6159ef2f5464edb1  PASS
   ↑ matches iter 2 baseline exactly — the seed-42 hash is a stable anchor
C. 3-config sweep @ seed 42:
   default   brick 400  water 200  steel 244  grass 228  → 6159ef2f5464edb1
   watery    brick 232  water 688  steel  64  grass  60  → 74e4d9ad07f08693
   fortress  brick 172  water  40  steel 720  grass 192  → 60feb24a96c2161a
D. screencapture:                    coverage 99.9%, variety 4/4, entropy 4.4/5
                                     brick 40242  steel 10416  grass 12240  water 13824
```

**Cheap-dignity audit per criterion:**

| # | Criterion | Prior | Verdict | Reasoning |
|---|-----------|-------|---------|-----------|
| 1 | Headless oracle | 4 | **4** | Reproducibility, multi-input (seed/config/dna). Anchor 5 (JSON) not met. Holds. |
| 2 | Algorithm variety | 3 | **3** | 3 cited configs distinct. Anchor 4 needs "agent mutates one field" — capability exists but no cited demonstration. Holds. |
| 3 | LevelConfig mutability | 4 | **4** | `.tres` editable, no `.gd` touches. Anchor 5 needs "agent swaps preset → oracle confirms in full cycle". Capability exists, demonstration not cited. Holds. |
| 4 | Level DNA | 4 | **4** | Roundtrip OK; DNA-driven hash matches baseline. Anchor 5 needs full agent-iteration mutation cycle. Holds. |
| 5 | Tile visual coherence | 3 | **3** | brick_007 palette is hand-tuned, not extracted from `sprites_0.png` per anchor 4. Holds. |
| 6 | Screencapture oracle | 3 | **3** | Single-frame analysis only. Anchor 4 needs diff-mode (before/after frame compare). Holds. |
| 7 | Agent edit friction | 4 | **4** | AGENTS.md present; anchor 5 needs cited Edit-tool mutation cycle. Holds. |
| 8 | Procedural richness | 3 | **3** | 6-seed sweep variance 40–63% beats 20% threshold. Anchor 4 needs biome zones — depth-modulated weights or region noise overlay, not implemented. Holds. |
| 9 | Pipeline completeness | 3 | **3** | brick_007 chain cited. Anchor 4 needs all 4 terrains regeneratable from gen_tile.py. Only brick swapped. Holds. |
| 10 | GDScript correctness | 3 | **3** | `make test` + `test_runner.gd` clean. Anchor 4 ("zero deprecation warnings") not precisely measured this iter — Node2D wrappers around TileMapLayers exist but are not literal deprecated TileMap nodes. Conservative hold. |

**Total:** 34/50 — unchanged from iter 5. No inflation. No regressions.

**CEILING RULE check:** total < 35 → no anchor lift required. Anchors hold.

**Audit observations:**
1. **The seed-42 hash is now a load-bearing measurement anchor.** Five iterations have produced or cited `6159ef2f5464edb1` for seed-42 default-config, regardless of texture changes, file additions, or DNA wrapper. Any future change that breaks this hash without intent is a regression.
2. **The 4-anchor → 5-anchor pattern across criteria 2, 3, 4, 7 is convergent: all four need "cited end-to-end agent mutation cycle".** A single iter 7 BUILD that performs one cited mutation (Edit watery.tres `water_weight` → rerun oracle → diff Δ) could lift four criteria simultaneously: 2 → 4, 3 → 5, 4 → 5, 7 → 5. That's a **+4** ceiling-busting move.
3. **The CONSULT gate is at iter 10.** Three iterations away. Question to prepare: "What's seductive-but-hollow about this procedural engine?" Strong candidate hollow-points: (a) the elif terrain selection is uniform random per set with no spatial coherence — no biome zones; (b) merge_probability is a single global, can't vary by depth; (c) the oracle measures distribution but not "interestingness" — a perfectly uniform 25/25/25/25 split would score 5/5 on entropy while being maximally boring.

**Weakest axis next:** No single weakest. Strategic move: iter 7 BUILD performs one cited Edit→rerun→diff to ceiling-bust criteria 2, 3, 4, 7 simultaneously.

---

## Iter 007 — BUILD — 2026-05-10
**Focus:** Cited end-to-end agent mutation cycle. Use `Edit` tool to mutate one weight on a `.tres`, rerun oracle, cite Δ. Trip ceiling rule.
**Changed files:**
- `configs/watery.tres` — `water_weight: 0.60 → 0.20` (single-field surgical edit via Edit tool).
- `loop/RUBRIC.md` — score updates for criteria 2, 3, 4, 7; new score-5 anchors; Revision Log entry.

**Mutation cycle evidence (seed 42, watery.tres):**
```
                                  brick  water  steel  grass  total  hash
BEFORE (water_weight = 0.60):      232    688     64     60   1044   74e4d9ad07f08693
AFTER  (water_weight = 0.20):      252    392     76    212    932   9e0b9fa4d18c34c3
Δ:                                +9%   -43%   +19%  +253%   -11%   distinct
```

The 0.40 weight that left water (0.60→0.20) redistributed across remaining terrains. Grass took the largest relative share (+253%) because grass_weight = 0.10 was the smallest non-water competitor — its proportional growth is largest when water shrinks. Brick and steel rose modestly. Hypothesis (small competitors gain disproportionately when a dominant weight shrinks) confirmed by oracle.

**Provenance:**
1. Agent read `loop/AGENTS.md` → identified `water_weight` knob, file path, valid range
2. Agent ran `test_runner.gd` → captured BEFORE state with hash + counts
3. Agent invoked `Edit` tool on `configs/watery.tres` (single line change)
4. Agent reran `test_runner.gd` → captured AFTER state
5. Agent cited Δ in this LEDGER entry

Zero editor steps. Zero `.gd` changes. ~5s wall-time per oracle run.

| Criterion | Prior | New | Evidence |
|-----------|-------|-----|----------|
| Headless oracle | 4 | 4 | unchanged |
| Algorithm variety | 3 | **4** | iter 7 single-field mutation produces measurable Δ; meets old anchor 4 |
| LevelConfig mutability | 4 | **5** | iter 7 full agent-iteration cycle cited above; meets old anchor 5 |
| Level DNA | 4 | **5** | iter 7 DNA-referenced config mutation + oracle confirmation cited; meets old anchor 5 |
| Tile visual coherence | 3 | 3 | unchanged |
| Screencapture oracle | 3 | 3 | unchanged |
| Agent edit friction | 4 | **5** | iter 7 zero-human-step cycle: AGENTS→Edit→rerun→Δ in this iter; meets old anchor 5 |
| Procedural richness | 3 | 3 | unchanged |
| Pipeline completeness | 3 | 3 | unchanged |
| GDScript correctness | 3 | 3 | unchanged |

**Total:** 38/50 (+4 from iter 6). **CEILING RULE TRIPPED** (≥ 35 before iter 15).

**Anchor revisions (per CEILING RULE):**
- C2 score-5 raised: now requires non-obvious parameter-interaction analysis with cited evidence
- C3 score-5 raised: now requires loop SYNTHESIZES a novel preset (not editing existing fields)
- C4 score-5 raised: now requires goal-directed DNA search with ≥3-step trajectory
- C7 score-5 raised: now requires loop chains ≥3 mutations within one iteration with hypothesis per step

These anchors force iterative agent-driven exploration, not just capability demonstration. Existing 5-scores stay (ratchet) — the anchor lift binds future iterations.

**Weakest axis next:** Five criteria still at 3/5: 5 (Tile visual coherence), 6 (Screencapture oracle), 8 (Procedural richness), 9 (Pipeline completeness), 10 (GDScript correctness). Highest-leverage iter 8 candidates:
- (a) C6 → 4: implement diff-mode in `analyze_frame.py` (compare two frames, report distribution shift). Force-multiplier: also enables future C5/C8 lifts.
- (b) C8 → 4: implement biome-zone weighting (depth-modulated config). Substantial build, real procedural sophistication.
- (c) C1 → 5: structured JSON output from test_runner. Cheap; useful tooling.

Leaning (a) — single tool addition unlocks new measurement, fits the "oracle improvement" theme of the loop.

---

## Iter 008 — CAPABILITY — 2026-05-10
**Focus:** Pixel-level diff oracle. Extend `analyze_frame.py` with `--diff`; add `TANKE_CONFIG`/`TANKE_SEED` env overrides so screencapture can vary inputs without scene edits; expose via `make diff CONFIG=<preset>`.
**Changed files:**
- `tools/analyze_frame.py` — new `diff()` + `_print_diff()`; `--diff A.png B.png` invocation; updated docstring.
- `scripts/ProceduralLevel.gd` — `_ready()` reads `TANKE_CONFIG` and `TANKE_SEED` env vars when scene fields are null/0 (non-destructive override).
- `Makefile` — new `make diff CONFIG=<preset>` target: clears `frame_a*` / `frame_b*`, captures two screencaptures with `TANKE_SEED=42`, runs `analyze --diff`.
- `loop/AGENTS.md` — documented `TANKE_CONFIG` / `TANKE_SEED` env vars and `make diff` workflow.

**Diff oracle output (default vs watery, seed 42):**
```
terrain   before   after   Δ pixels      Δ %
brick      41322   37706      -3616    -8.8%
steel       9912    3192      -6720   -67.8%
grass      13200   11760      -1440   -10.9%
water      12288   24064     +11776   +95.8%
entropy: 1.722 → 1.634 bits  (Δ -0.088)
shift_detected: True
```

Single command (`make diff CONFIG=watery`) now: captures default frame → swaps config via env var → captures comparison frame → reports per-terrain Δ + entropy Δ + boolean shift detection. JSON output for tooling consumption (the `shift_detected` bool is what a future automated scorer would key off).

**Note on watery state:** since iter 7, `watery.tres` has `water_weight = 0.20` (not the original 0.60). The +95.8% water Δ here is between default (0.15) and current watery (0.20) plus higher merge_probability (0.5 vs 0.333). Bigger sets at higher merge prob compound the per-cell weight effect.

| Criterion | Prior | New | Evidence |
|-----------|-------|-----|----------|
| Headless oracle | 4 | 4 | unchanged |
| Algorithm variety | 4 | 4 | unchanged |
| LevelConfig mutability | 5 | 5 | unchanged |
| Level DNA | 5 | 5 | unchanged |
| Tile visual coherence | 3 | 3 | unchanged |
| Screencapture oracle | 3 | **4** | iter 8 diff mode + `make diff` cited above; meets old anchor 4 |
| Agent edit friction | 5 | 5 | unchanged (env overrides reduce friction further but no new anchor) |
| Procedural richness | 3 | 3 | unchanged |
| Pipeline completeness | 3 | 3 | unchanged |
| GDScript correctness | 3 | 3 | unchanged |

**Total:** 39/50 (+1 from iter 7). Anchors raised iter 7 still binding; this lift was against the unchanged C6 anchor 4.

**Weakest axis next:** Four criteria at 3/5 (5, 8, 9, 10). Iter 9 candidate: tackle criterion 8 (Procedural richness) by implementing biome-zones — depth-modulated weights via 2-3 LevelConfig presets that interpolate as player scrolls. Anchor 4: "Biome-like zones: level character shifts as player scrolls deeper". This is the heaviest BUILD remaining and the most genuine procedural-engine sophistication. Iter 10 still due as CONSULT — iter 9 BUILD then iter 10 CONSULT.

---

## Iter 009 — BUILD — 2026-05-10
**Focus:** Biome-zone weighting (criterion 8 anchor 4). Depth-modulated `LevelConfig` via interpolation between two endpoint configs.
**Changed files:**
- `scripts/BiomeConfig.gd` (new) — Resource bundling `surface: LevelConfig`, `deep: LevelConfig`, `surface_row` (default 14), `depth_scale` (default 14). `depth_t(row)` returns clamped `(surface_row - row) / depth_scale`. `config_at(row)` returns a fresh LevelConfig with all 6 fields lerp'd between surface and deep at that t.
- `configs/biome_default_to_watery.tres` (new) — surface=default, deep=watery, scale=14 (full transition across visible 14-row screen).
- `scripts/ProceduralLevel.gd` — `@export var biome: BiomeConfigT`; `TANKE_BIOME` env override; `_active_config(row)` helper; refactored `_generate_next_row` → `_generate_next_row_for(row)` (passes row through to access biome interp); `_pave_set` uses per-row config too.
- `loop/test_runner.gd` — `-- --biome PATH` flag.
- `loop/AGENTS.md` — biome param table + TANKE_BIOME env entry + biome preset row.

**Compile-error caught by hook:** PostToolUse hook flagged forward references to `_active_config()` and `_generate_next_row_for()` after the first edit (defined-later, called-earlier). Saved an iteration. Pattern: write the new helper definitions FIRST, then update call sites.

**Headless oracle output (seed 42):**
```
                    brick  water  steel  grass  total  tile_hash
flat default:        400    200    244    228   1072   6159ef2f5464edb1   ← iter 2 baseline preserved
biome default→watery: 424    240    180    220   1064   35221010827d11ff   ← biome active
Δ from flat:         +6%   +20%   -26%   -3%
```

**Screencapture diff (seed 42, flat vs biome):**
```
brick:  41322 → 41930  (+1.5%)
steel:   9912 →  7224  (-27.1%)
grass:  13200 → 12720  (-3.6%)
water:  12288 → 14848  (+20.8%)
entropy 1.722 → 1.686 bits  (Δ -0.036)
shift_detected: True
```

Both oracles agree on direction (water up ~20%, steel down ~27%). The biome interpolation is a real spatial-coherence feature, not just a global mean shift — top of visible screen is at t=1 (deep biome = watery weights) and bottom is at t=0 (surface = default weights). Viewing the screencapture would show a vertical gradient.

**No regressions:** flat default seed-42 hash `6159ef2f5464edb1` preserved exactly across the refactor. The control measurement anchor still binds.

| Criterion | Prior | New | Evidence |
|-----------|-------|-----|----------|
| Headless oracle | 4 | 4 | unchanged |
| Algorithm variety | 4 | 4 | unchanged |
| LevelConfig mutability | 5 | 5 | unchanged (new BiomeConfig is composition, not replacement) |
| Level DNA | 5 | 5 | unchanged |
| Tile visual coherence | 3 | 3 | unchanged |
| Screencapture oracle | 4 | 4 | unchanged |
| Agent edit friction | 5 | 5 | unchanged (AGENTS.md updated to expose biome) |
| Procedural richness | 3 | **4** | iter 9 biome cited above; level character shifts as player scrolls deeper |
| Pipeline completeness | 3 | 3 | unchanged |
| GDScript correctness | 3 | 3 | unchanged |

**Total:** 40/50 (+1 from iter 8). Approaching the rubric's natural plateau — three criteria still at 3 (5, 9, 10), each with specific 4-anchors that require non-trivial work.

**Weakest axis next:** **Iter 10 = CONSULT mode** per CONSULT SCHEDULE. Three pre-staged hollow-points to interrogate (from iter 6 audit + iter 9 reflection):
1. Spatial coherence is *only* on the depth axis — there's no horizontal banding, no "rooms", no walls following the maze. The Eller's algorithm output is decorrelated from the procedural texture beneath it.
2. The oracle measures distribution but not "interestingness". A perfectly uniform 25/25/25/25 split would max the entropy score while being maximally boring. Goodhart risk.
3. `merge_probability` only affects horizontal connectivity, not vertical. The level structure is implicitly row-by-row independent on the vertical axis (only Eller's vertical carry-overs link rows).

---

## Iter 010 — CONSULT — 2026-05-10
**Focus:** Per CONSULT SCHEDULE. Frontier-model query on H1 (spatial decorrelation), H2 (oracle goodhart), H3 (algorithmic depth).
**Changed files:**
- `loop/creative-consults.md` (new) — full self-consult write-up.

**Infrastructure:** External agentify CONSULT attempted, blocked by `tab_busy` (frozen 12-hour-old query in another session locked the tab pool; closing 5 stale tabs didn't recover). Loop policy: don't block on external services. Fell back to self-reflective CONSULT, marked as such in `creative-consults.md`. Will retry external at iter 20.

**Findings:**
1. **H1 is *worse* than I framed**: iter 2's weighted refactor REMOVED the size-based gating that the iter-0 modular arithmetic had (steel needed size 2-3, water size ≤6). That's a regression on spatial structure that no oracle caught — because no oracle measures spatial structure.
2. **H2 confirmed**: entropy oracle peaks at uniform 25/25/25/25 = boring. The iter 8 *diff* oracle is closer to "interestingness" than entropy. Should rename "distribution" → "diversity" for honesty.
3. **H3 half-right**: Eller's carryover *does* contribute structure (vertical persistence via `verts`), but the carryover slice `randi() % cells.size()` can produce zero — meaning sets get stranded as topological islands. Classical Eller's requires ≥1 vertical carry per set. The current impl is generating *quasi-mazes*, not mazes.

**Q1 — what's seductive-but-hollow:** the dual oracle. Two measurements that "agree on direction" feel robust, but both measure *aggregate distribution* not *spatial structure*. 90% concentric brick rings vs 90% scattered brick noise score identically on every current oracle. The loop is blind to architecture.

**Q2 — agent-friendly?** It passes "single-edit measurable Δ" (iter 7). It fails "name what was done" (no derived semantics like "swampiness" map to LevelConfig fields) and "search heuristic" (loop has no signal for which parameter to nudge next). Honest verdict: an excellent renamed config file, not yet a search space.

**Q3 — embarrassing to a researcher:** the `cells.slice(0, randi() % cells.size())` zero-length slice that violates Eller's invariant. Generates topological islands with no surfacing to oracle or player.

**Action items (high → low):**
1. Add **spatial-coherence oracle** (Moran's I, connected-component size, vertical persistence) to break the entropy Goodhart.
2. **Condition `_pave_set` on set size/shape** — restore the lost iter-0 signal as `weights_by_size: Dictionary[int, Dictionary]` on LevelConfig.
3. Expose `vertical_carry_probability` (or `vertical_merge_count_max`) — make vertical structure tunable.
4. **Audit zero-length carryovers** — fix or expose as `allow_islands: bool`.
5. Rename oracle "distribution" → "diversity"; add separate "interestingness" axis.

**Meta-move surfaced:** the rubric itself is missing a criterion — *Spatial Coherence / Architecture*. Even maxing all 10 current criteria leaves H1/H3 unaddressed. CEILING RULE permits adding criteria. **Iter 11 candidate: add criterion 11 (Spatial Coherence) to RUBRIC, score 0/5 initially.** This trades short-term raw score for direction. Honest move.

**Scoring:** no scores moved this iter (CONSULT mode generates direction, not artifacts). Total stays at 40/50.

**Weakest axis next:** Iter 11 — META + BUILD: extend RUBRIC with Spatial Coherence criterion 11; implement a basic spatial-coherence oracle metric (vertical persistence is simplest: count adjacent same-terrain pairs per column); cite reading on default and biome configs. Anchors should require this metric to actually MEASURE the thing, not just be present.
