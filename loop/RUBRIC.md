# tanke — Loop Rubric (Procedural Engine Focus)

10 criteria, 0–5 scale. Score > 2 requires citation (file:line or tool output excerpt).
Rubric is a discovered artifact — revise anchors when a ceiling is hit.

Gameplay features (destruction, enemies) are out of scope for this loop.
They live on a future `feat/gameplay` branch.

---

## 1. Headless Oracle Quality (0–5)

Does `loop/test_runner.gd` give a reliable, information-rich signal?

| Score | Anchor |
|-------|--------|
| 0 | test_runner.gd doesn't exist |
| 1 | Exists but crashes or prints nothing useful |
| 2 | Prints PASS/FAIL; no tile-level data |
| 3 | Prints tile counts per type + Eller set metrics (avg size, max size, merge rate) — cite output |
| 4 | Prints reproducibility check: two runs with same seed → identical tile map hash |
| 5 | Structured JSON output; loop can parse and diff across iterations without reading text |

**Reference output (iter 0 bootstrap):**
```
=== tanke headless oracle ===
brick: 380  water: 88  steel: 32  grass: 156  total: 656
eller_sets: 12  avg_size: 1.67  max_size: 5
tile_hash: e55b96e4256a8acf
PASS
```

**Current state:** 4 — `loop/test_runner.gd` prints per-type counts, Eller metrics, SHA-256 fingerprint, seed used, PASS/FAIL. CLI `--seed N` accepted. Same-seed reproducibility verified (iter 1: two runs of seed 42 produced identical hash `619cb88ffed7e906`). To reach 5: switch to JSON output.

---

## 2. Algorithm Variety (0–5)

Does the Eller's algorithm parameter space produce meaningfully different level characters?

| Score | Anchor |
|-------|--------|
| 0 | Single hardcoded merge probability (`randi() % 3 > 0`) |
| 1 | Merge probability is a named var; still one value |
| 2 | Two parameters exposed (merge prob, vertical density); default behavior unchanged |
| 3 | 3 distinct parameter sets produce visually distinguishable levels — cite stdout oracle diff |
| 4 | Parameters exposed on LevelConfig; agent can mutate one field and change level feel |
| 5 | Continuous parameter space documented; loop has run a mini-sweep (≥5 seeds × ≥3 configs) and charted output variance |

**Current state:** 3 — `merge_probability` and 5 terrain weights exposed on `LevelConfig`. Three presets (`default.tres`, `watery.tres`, `fortress.tres`) at seed 42 produce visibly distinguishable distributions: default 37/19/23/21 brick/water/steel/grass, watery 22/66/6/6, fortress 15/4/64/17. Distinct tile_hashes `6159ef2f`, `74e4d9ad`, `60feb24a`. To reach 4: agent mutates a single field on a .tres → oracle confirms shift. To reach 5: SWEEP across ≥5 seeds × ≥3 configs.

---

## 3. LevelConfig Mutability (0–5)

| Score | Anchor |
|-------|--------|
| 0 | No LevelConfig; tile distribution is hardcoded modular arithmetic in `_pave_set` |
| 1 | LevelConfig class exists; not wired to generation |
| 2 | LevelConfig loaded and passed to `_pave_set`; defaults replicate old behavior |
| 3 | Changing a weight in LevelConfig produces measurably different tile distribution — cite oracle output before/after |
| 4 | LevelConfig is a `.tres` Godot Resource; editable without touching `.gd` files |
| 5 | Named presets exist ("dense", "open", "swamp", "fortress"); agent swaps preset → confirmed by oracle diff |

**Current state:** 4 — `LevelConfig` is a `class_name` Resource (`scripts/LevelConfig.gd`); `.tres` instances live under `configs/`. ProceduralLevel exposes `@export var config: LevelConfig`. Editing `configs/watery.tres` field `water_weight = 0.60` shifts oracle output from 19% water → 66% water at seed 42 with no `.gd` changes. To reach 5: presets exist (default/watery/fortress) — bumping to 5 next iter once `loop/AGENTS.md` is wired into agent prompts.

---

## 4. Level DNA Reproducibility (0–5)

| Score | Anchor |
|-------|--------|
| 0 | No seed stored; levels are not reproducible |
| 1 | LevelDNA struct exists with seed field; not used |
| 2 | Seed passed into ProceduralStep; same seed → same layout on one run |
| 3 | `seed + config` fully determines a level — oracle prints tile hash; two runs match — cite hash output |
| 4 | LevelDNA serializable to JSON/dict; round-trips without loss |
| 5 | Loop proposes a LevelDNA mutation, applies it, oracle confirms change, loop scores result — full agent-iteration cycle |

**Current state:** 3 — `ProceduralLevel.gd:6` exposes `@export var level_seed: int = 0`; `_ready()` (line 17) calls `seed(level_seed)` before any generation. Verified iter 1: two runs at seed 42 → identical tile_hash `619cb88ffed7e906`; seed 7 → distinct hash `beac3183dc58e335`. To reach 4: serialize LevelDNA (seed + future LevelConfig) to a `.tres` resource.

---

## 5. Tile Visual Coherence (0–5)

Do tiles look like they belong together? Assessed via screencapture oracle + PIL analysis.

| Score | Anchor |
|-------|--------|
| 0 | Missing tiles; pink/error squares |
| 1 | Default Godot placeholder or wrong tile mapping (wrong source_id) |
| 2 | Correct tiles render; no palette consistency with original sprites |
| 3 | PIL analysis of screencapture: dominant colors match expected palette per terrain type — cite `analyze_frame.py` output |
| 4 | PIL-generated tile variants used in game; palette extracted from `sprites_0.png` applied — cite ASSET-MANIFEST entry |
| 5 | Screencapture at any seed looks like a coherent pixel art level; no tile bleeds or misaligned seams |

**Current state:** 3 — TileSet operational (`scenes/ProceduralLevel.tscn:7-49`); `tools/analyze_frame.py` confirms all 4 terrain palettes render to expected colors (iter 0 frame: brick 55034, steel 1512, grass 12240, water 7936 px; classifier threshold 70 from `sprites_1.png` palette).

---

## 6. Screencapture Oracle Quality (0–5)

Can the loop take a screenshot and extract game-state information from pixels?

| Score | Anchor |
|-------|--------|
| 0 | No screencapture pipeline |
| 1 | `screencapture -x` runs; image saved but not analyzed |
| 2 | `tools/analyze_frame.py` exists; reads PNG and counts pixel color buckets |
| 3 | Oracle identifies terrain regions by color; outputs terrain coverage % — cite output |
| 4 | Oracle diffs two frames (before/after LevelConfig change) and detects distribution shift |
| 5 | Oracle used as loop scoring signal: loop changes config, screenshots before/after, reports Δ coverage |

**Reference output (iter 0 bootstrap, frame00000004.png):**
```
=== Oracle: frame00000004.png ===
Coverage      99.9%   score 5/5
Variety      4/4 types  score 4/4
Distribution entropy 1.216 bits  score 3.0/5.0
Tile counts  {'brick': 55034, 'steel': 1512, 'grass': 12240, 'water': 7936}
```

**Current state:** 3 — `tools/analyze_frame.py:64-72` classifies pixels by nearest reference color from `sprites_1.png`; outputs per-type pixel counts, coverage %, variety, entropy. Reachable via `make screenshot && make analyze`. To reach 4: implement diff-mode across two frames. To reach 5: wire the diff into loop scoring.

---

## 7. Agent Edit Friction (0–5)

How many files/lines must change to alter one behavior?

| Score | Anchor |
|-------|--------|
| 0 | Behavior scattered across 3+ files with no named constants |
| 1 | Key params are named but buried in logic |
| 2 | `Constants.gd` holds some values; LevelConfig doesn't exist yet |
| 3 | One config change → one file edit → oracle confirms effect — cite the single file:line |
| 4 | `loop/AGENTS.md` documents every mutable param: file, line, type, valid range |
| 5 | Agent can propose mutation as a diff, apply it with `Edit` tool, oracle confirms in same iteration — zero human steps |

**Current state:** 4 — `loop/AGENTS.md` documents every mutable param: `merge_probability`, 5 terrain weights, `level_seed`. Each lists file:line, type, valid range, effect, and mutation surface (`.tres` edit, scene field, or CLI flag). Single edit + single command → oracle delta. To reach 5: agent proposes a Edit-tool diff, applies, oracle confirms in same iteration.

---

## 8. Procedural Richness (0–5)

How varied do levels feel across seeds and configs?

| Score | Anchor |
|-------|--------|
| 0 | Every level looks identical |
| 1 | Obvious randomness but no interesting structure |
| 2 | 4 terrain types appear; distribution feels random but flat |
| 3 | Some seeds produce notably dense/open/watery levels — oracle shows >20% variance in terrain distribution across 5 seeds |
| 4 | Biome-like zones: level character shifts as player scrolls deeper |
| 5 | A playtest of 3 seeds at 3 configs produces 9 clearly distinct level feelings — documented with oracle output + screencaptures |

**Current state:** 3 — SWEEP iter 3 across 6 seeds (1, 7, 42, 100, 314, 999) × default config: per-terrain range/mean variance brick 49.6%, water 40.6%, steel 62.9%, grass 41.7%. All four exceed the 20% threshold. 6/6 seeds produced distinct `tile_hash` values. To reach 4: implement biome-like zones — level character shifts as player scrolls deeper (e.g. depth-modulated weights, region noise overlay).

---

## 9. Pipeline Completeness (0–5)

Full chain: `gen_tile.py` PNG → Godot TileSet → `set_cell` → rendered pixel.

| Score | Anchor |
|-------|--------|
| 0 | Chain broken at TileSet import (source_id unknown) |
| 1 | TileSet migrated; source_id known and written to STATE.md |
| 2 | `set_cell(0, Vector2i(x,y), source_id, atlas_coords)` calls use correct values — cite STATE.md tile_source_ids |
| 3 | PIL-generated tile PNG imported into TileSet and used in game — cite ASSET-MANIFEST entry |
| 4 | All 4 terrain tile variants regenerable from `gen_tile.py` without editor intervention |
| 5 | New tile variant generated, imported, live in game, screencapture confirms render — full loop in one iteration |

**Current state:** 3 — Full chain exercised iter 4. `tools/gen_tile.py --tile brick --variant 7` → `img/brick_007.png` → `godot --headless --import` (auto-generated `.import` with uid `dy83met4b40yn`) → `BrickSrc.texture` swapped to `ExtResource("4")` in `scenes/ProceduralLevel.tscn` → `make screenshot` → `make analyze`: brick pixel count 47410 → 41194 (-13%), confirming pixel-level swap rendered. Cited in `loop/ASSET-MANIFEST.md`. Headless oracle hash for seed 42 unchanged (texture-only mutation, no logic shift). To reach 4: regenerate all 4 terrain variants via gen_tile and confirm full-sheet replacement.

---

## 10. GDScript Correctness (0–5)

| Score | Anchor |
|-------|--------|
| 0 | Parse errors; project won't load |
| 1 | Loads; runtime errors on play |
| 2 | Runs; TileMap deprecation warnings present |
| 3 | test_runner.gd output: zero errors — cite run output |
| 4 | TileMap → TileMapLayer migration complete; zero deprecation warnings |
| 5 | Typed GDScript throughout; all exported vars have type annotations |

**Current state:** 3 — `make test` clean (120-frame headless); `test_runner.gd` runs to PASS with no errors across seeds 42, 7. TileMap-as-Node2D wrappers around TileMapLayer remain (cosmetic deprecation); no functional warnings.

---

## Revision Log

| Iter | Change | Reason |
|------|--------|--------|
| 0 | Initial rubric: gameplay scope (destruction, enemies, LevelConfig, Level DNA) | Bootstrap |
| 0 | Rewrite: procedural engine focus only; add oracle axes | User direction: procedural-only, dual oracle |
