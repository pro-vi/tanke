# tanke — Loop Rubric (Procedural Engine Focus)

11 criteria (max /55), 0–5 scale. Score > 2 requires citation (file:line or tool output excerpt).
Rubric is a discovered artifact — revise anchors when a ceiling is hit. Add
criteria when the rubric proves blind (iter 11: criterion 11 added when
CONSULT surfaced that no axis measured spatial structure).

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

**Current state:** 5 — iter 15 added `--json` flag to `test_runner.gd`; emits a single JSON object with 16 fields (seed, terrain counts, Eller metrics, tile_hash, vert_* metrics) instead of text. Verified: `godot --headless ... --json | grep '^{' | python3 -m json.tool` parses cleanly. End-to-end diff demonstrated via `jq -n --slurpfile a ... --slurpfile b ...` producing structured Δ for every field (`brick_delta`, `structure_lift_delta`, etc.). Loop can now diff across iterations without reading text.

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

**Current state:** 4 — iter 7 cited mutation cycle: agent used `Edit` tool to set `water_weight: 0.60 → 0.20` on `configs/watery.tres`. Oracle Δ at seed 42: water 688→392 (-43%), grass 60→212 (+253%), hash 74e4d9ad → 9e0b9fa4. Single-field mutation produced predictable redistribution. To reach 5 (NEW anchor — see Revision Log): loop must identify a non-obvious parameter interaction (e.g. merge_probability × weight scale → emergent set sizes) and cite oracle evidence.

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

**Current state:** 5 — all of: (a) `.tres` Resource editable without `.gd` changes, (b) named presets (default/watery/fortress) exist, (c) iter 7 cited end-to-end agent cycle: AGENTS.md → Edit tool → rerun → cite Δ. To exceed 5 (NEW anchor — see Revision Log): loop must SYNTHESIZE a novel preset by reasoning about weights (not edit an existing field), apply, oracle confirms it differs from all prior presets — capped at 5.

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

**Current state:** 5 — all of: roundtrip OK, DNA-driven hash matches baseline, iter 7 cited mutation cycle (single Edit on a config referenced by DNA → oracle Δ). To exceed 5 (NEW anchor — see Revision Log): goal-directed DNA search — loop states a target ("maximize steel coverage at seed 42"), iterates ≥3 mutations, hits goal, cites trajectory — capped at 5.

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

**Current state:** 4 — iter 17 added `--from-sheet PATH` to `gen_tile.py`: reads top-4 frequent colors from the canonical 8x8 region of the sheet (margins per `SHEET_MARGINS` = `analyze_frame.py`'s `TILE_DEFS`); uses them as the per-terrain palette. Regenerated all 4 variant 7 PNGs from `sprites_1.png` extraction. Re-screencap (default config, random seed): coverage **99.9%**, variety **4/4**, distribution entropy **4.0/5.0** (was 2.5/5.0 in iter 16, was 3.9/5.0 with original sprite sheet — *better* than the baseline). `tools/ASSET-MANIFEST.md` updated. Anchor 4 ("PIL-generated tile variants used in game; palette extracted from sprite sheet applied") satisfied. To reach 5: zero tile bleed / misaligned seams across multiple seeds (need a seam-check oracle).

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

**Reference diff output (iter 8, default vs watery at seed 42):**
```
=== Frame Diff: frame_a → frame_b ===
terrain   before   after   Δ pixels      Δ %
brick      41322   37706      -3616    -8.8%
steel       9912    3192      -6720   -67.8%
grass      13200   11760      -1440   -10.9%
water      12288   24064     +11776   +95.8%
entropy: 1.722 → 1.634 bits  (Δ -0.088)
shift_detected: True
```

**Current state:** 4 — `tools/analyze_frame.py --diff A.png B.png` reports per-terrain Δ, % change, entropy delta, and `shift_detected` boolean (≥5% relative or ≥500 absolute on any terrain). One-command reproducibility via `make diff CONFIG=<preset>` — the `TANKE_CONFIG` / `TANKE_SEED` env overrides on `ProceduralLevel.gd` enable two deterministic captures with one config swap and zero scene edits. To reach 5: wire diff results into automated loop scoring (loop reads the JSON, decides next mutation based on Δ).

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

**Current state:** 5 — iter 7 zero-human-step cycle: agent read AGENTS.md, picked `water_weight`, applied Edit-tool diff to watery.tres, reran oracle, cited Δ — all within one iteration with no editor/manual steps. To exceed 5 (NEW anchor — see Revision Log): loop chains ≥3 distinct mutations within a single iteration with a stated hypothesis per mutation and verified Δ per step — capped at 5.

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

**Current state:** 4 — iter 9 implemented `BiomeConfig` (`scripts/BiomeConfig.gd`): two LevelConfigs interpolated linearly over `depth_scale` rows. `ProceduralLevel.gd` `_active_config(row)` returns the per-row interpolated config; both `_generate_next_row_for(row)` and `_pave_set(sid, row)` consume it. Demonstration: `configs/biome_default_to_watery.tres` (depth_scale=14) at seed 42, headless: brick 400→424, water 200→240 (+20%), steel 244→180 (-26%), hash 6159ef2f→3522101. Screencapture matches direction: water +20.8%, steel -27.1%, `shift_detected: True`. Level character measurably shifts top-of-screen vs bottom. To reach 5: 9 distinct level-feelings across 3 seeds × 3 biomes documented (full SWEEP grid + screencaptures).

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

**Current state:** 4 — iter 16 regenerated all 4 terrains via `gen_tile.py --tile {steel,grass,water} --variant 7`; imported via `godot --headless --import` (UIDs `btw4ryipmrg4n`, `dqcyr7h1gwsw3`, `dg7td6i6nfwni`); each atlas source in `scenes/ProceduralLevel.tscn` swapped to its corresponding new texture (margins all (0,0)). All 4 textures render in the screencapture without errors. Headless seed-42 hash `6159ef2f5464edb1` preserved across the full-sheet swap (texture-only mutation, no logic shift — the iter-4 measurement-anchor invariant holds across 4-tile replacement too). To reach 5: a *new* tile variant generated, imported, live in game, screencap-confirmed, in a single iteration without manual editor intervention (already nearly there — the chain is reproducible from CLI; iter 17 could automate it via Make target).

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

## 11. Spatial Coherence (0–5)

Does the level have *architecture* — structure measurable beyond aggregate
distribution? Anchor metric: **vertical persistence** = fraction of placed cells
whose vertically-adjacent below cell carries the same terrain. Sampled at
8px tilemap resolution. Computed in `loop/test_runner.gd:_collect()`.

IID baseline (placement uncorrelated across rows): ~0.25–0.37 depending on
weight distribution. Eller's carryover lifts above this floor.

| Score | Anchor |
|-------|--------|
| 0 | No spatial-structure metric exists |
| 1 | Metric implemented; no readings cited |
| 2 | Metric values cited for ≥2 configs at fixed seed |
| 3 | Metric meaningfully discriminates configs (≥3 distinct values cited; biome falls *between* its endpoints — predictive structure) |
| 4 | Metric responds to a cited mutation cycle: agent edits a parameter expected to affect spatial coherence, oracle reports predicted Δ |
| 5 | Spatial-coherence axis is independent of distribution axis: a config can score high on diversity AND high on coherence simultaneously (i.e., the engine produces architecturally distinct levels, not just uniform-vs-clumpy) |

**Reference readings (iter 11, seed 42):**
```
default       vert_persistence 0.647   (628 / 970 same-terrain pairs)
watery        vert_persistence 0.727   (570 / 784 same-terrain pairs)
fortress      vert_persistence 0.710   (728 / 1026 same-terrain pairs)
biome (d→w)   vert_persistence 0.692   (662 / 956 same-terrain pairs)
```

Watery and fortress both push high (single dominant terrain → contiguous runs).
Default lower (more transitions, more diversity). Biome lands intermediate
between its endpoints (default 0.647 → watery 0.727; biome at 0.692 ≈ midpoint
0.687 — interpolation reads structurally too, not just at the count level).

**Current state:** 5 — iter 18 constructed `configs/biome_balanced.tres` (default ⇄ `balanced_steel.tres`, both endpoints with no terrain > 33%). Result at seed 42: distribution **brick 29% / water 17% / steel 30% / grass 24%** (most-dominant only 30%, all four in [17, 30] band → high diversity), `structure_lift = 2.522×` (highest of any tested config, above the prior champion biome_default_to_watery's 2.464×). The high-diversity AND high-structure_lift quadrant is now occupied. Spatial coherence is demonstrably independent of terrain concentration: a config can score high on diversity AND high on coherence simultaneously, which was the level-5 anchor's load-bearing claim. Side finding: `balanced_steel` flat alone (no biome, p_merge=0.4) already lifts structure_lift to 2.456× — moderate-merge balanced configs are productive even without depth-modulation.

---

## Revision Log

| Iter | Change | Reason |
|------|--------|--------|
| 0 | Initial rubric: gameplay scope (destruction, enemies, LevelConfig, Level DNA) | Bootstrap |
| 0 | Rewrite: procedural engine focus only; add oracle axes | User direction: procedural-only, dual oracle |
| 7 | CEILING RULE fired (38/50 ≥ 35 by iter 7). Tightened anchors: C2 score-5, C3 score-5, C4 score-5, C7 score-5. New anchors require either parameter-interaction analysis (C2), preset SYNTHESIS rather than editing (C3), goal-directed DNA search (C4), or ≥3 chained mutations per iter (C7) — all capped at 5 going forward. | Quad-axis lift in iter 7 from a single cited mutation cycle revealed the old 5-anchors were satisfiable by demonstrating capability rather than agent-driven exploration. New anchors force the loop to *do* iterative search, not just expose the surface. |
| 11 | Added criterion 11 — Spatial Coherence. Max total now /55 (was /50). | Iter 10 CONSULT identified that all existing oracles measure aggregate distribution but are blind to spatial structure. The loop was climbing measurements that don't measure what matters most. Adding this criterion is the loop editing its own measurement instrument — short-term percent-score drops, long-term direction matches intent. |
