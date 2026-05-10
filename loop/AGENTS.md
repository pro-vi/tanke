# tanke — Agent Parameter Map

Every agent-mutable parameter that affects level generation. Loop reads this to
know what knobs exist, where they live, what ranges are sane, and what they do.

Conventions:
- File path is `res://`-rooted.
- Editing a `.tres` requires no script changes; reload via `--config <path>` in test_runner.
- "Mutate via" indicates the canonical edit surface — prefer the .tres for distribution work.

---

## LevelConfig (`scripts/LevelConfig.gd`)

A `Resource` consumed by `ProceduralLevel`. Every instance is a complete,
serializable terrain-distribution recipe.

| param | file | line | type | valid_range | effect |
|-------|------|------|------|-------------|--------|
| `merge_probability` | `LevelConfig.gd` | 6 | float | 0.0–1.0 | P(merge two horizontally adjacent cells in Eller's step). 0 = max fragmentation; 1 = single-set rows. Default 0.333. |
| `empty_weight` | `LevelConfig.gd` | 10 | float | 0.0–10.0 | Relative weight that a set leaves no terrain. Larger ⇒ more open space. |
| `brick_weight` | `LevelConfig.gd` | 11 | float | 0.0–10.0 | Relative weight of brick. |
| `steel_weight` | `LevelConfig.gd` | 12 | float | 0.0–10.0 | Relative weight of steel (indestructible). |
| `grass_weight` | `LevelConfig.gd` | 13 | float | 0.0–10.0 | Relative weight of grass (passable cover). |
| `water_weight` | `LevelConfig.gd` | 14 | float | 0.0–10.0 | Relative weight of water (impassable hazard). |

**Mutate via:** edit any `.tres` under `configs/` directly with the `Edit` tool,
e.g. `configs/watery.tres` → `water_weight = 0.60`. Then run:
```
godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --config res://configs/watery.tres
```

Weights are normalized by sum; absolute scale is irrelevant.

---

## Available config presets

| Preset | File | Character | Reference oracle (seed 42) |
|--------|------|-----------|----------------------------|
| **default** | `configs/default.tres` | balanced terrain mix | brick 400, water 200, steel 244, grass 228 — `6159ef2f` |
| **watery** | `configs/watery.tres` | drowning swamp | brick 232, water 688, steel 64, grass 60 — `74e4d9ad` |
| **fortress** | `configs/fortress.tres` | steel-heavy, large rooms | brick 172, water 40, steel 720, grass 192 — `60feb24a` |

Loop may add new presets to `configs/` and re-run the oracle to test new combinations.

---

## ProceduralLevel (`scripts/ProceduralLevel.gd`)

| param | file | line | type | valid_range | effect |
|-------|------|------|------|-------------|--------|
| `level_seed` | `ProceduralLevel.gd` | 8 | int | any int (0 = random) | RNG seed. Same seed + same config → identical tile_hash. |
| `config` | `ProceduralLevel.gd` | 9 | LevelConfig | any `.tres` matching `LevelConfig.gd` | Flat distribution recipe (one config across all rows); null falls back to `configs/default.tres`. |
| `biome` | `ProceduralLevel.gd` | 10 | BiomeConfig | optional `.tres` matching `BiomeConfig.gd` | Depth-modulated config: each row uses an interpolation between `surface` and `deep` configs based on `depth_t(row)`. When set, supersedes flat `config` for per-row weighting. |
| `debug` | `ProceduralLevel.gd` | 7 | bool | true/false | Overlay numeric set IDs on each cell — visual debugging only. |

## BiomeConfig (`scripts/BiomeConfig.gd`)

A pair of LevelConfigs interpolated over depth.

| param | file | line | type | valid_range | effect |
|-------|------|------|------|-------------|--------|
| `surface` | `BiomeConfig.gd` | 14 | LevelConfig | any `.tres` | Config at depth t=0. |
| `deep` | `BiomeConfig.gd` | 15 | LevelConfig | any `.tres` | Config at depth t=1. |
| `surface_row` | `BiomeConfig.gd` | 16 | int | any | Row index considered shallowest. Default 14 (player start row). |
| `depth_scale` | `BiomeConfig.gd` | 17 | int | 1–200 | Rows over which transition completes. Smaller = sharper biome boundary. |

**Available biome presets:**
- `configs/biome_default_to_watery.tres` — surface=default, deep=watery, scale=14 (full transition over visible area)

**Mutate via:** edit `scenes/ProceduralLevel.tscn` to set defaults persistently,
or pass via `test_runner.gd` `-- --seed N --config PATH`.

---

## Environment overrides (rendering paths)

Headless paths take CLI flags (`--seed`, `--config`, `--dna`). The full
renderer (`make screenshot`, `make diff`) instead reads env vars:

| Env var | Effect | Read at |
|---------|--------|---------|
| `TANKE_SEED=N` | Sets `level_seed` (only if scene's `level_seed == 0`) | `ProceduralLevel.gd:_ready()` |
| `TANKE_CONFIG=res://...tres` | Sets `config` (only if scene's `config` is null) | `ProceduralLevel.gd:_ready()` |
| `TANKE_BIOME=res://...tres` | Sets `biome` (only if scene's `biome` is null) | `ProceduralLevel.gd:_ready()` |

Used by `make diff CONFIG=<preset>` to capture two deterministic frames at
the same seed with two different configs.

## Verification

After any mutation:
```bash
# Headless oracle: deterministic distribution + tile_hash (text)
godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --config <PATH>

# Headless oracle: structured JSON (parseable by jq/python)
godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --config <PATH> --json | grep '^{'

# Screencapture oracle: pixel-level per-terrain coverage (single frame)
make screenshot && make analyze

# Diff oracle: pixel-level Δ between default and target preset
make diff CONFIG=watery

# Headless diff: structured Δ via jq
godot ... --seed 42 --json | grep '^{' > /tmp/a.json
godot ... --seed 42 --config <NEW> --json | grep '^{' > /tmp/b.json
jq -n --slurpfile a /tmp/a.json --slurpfile b /tmp/b.json \
  '{ structure_lift_delta: ($b[0].vert_structure_lift - $a[0].vert_structure_lift) }'
```

A change is "real" only if (a) `tile_hash` changes vs baseline, AND (b) at least
one terrain count changes by ≥10%, OR (c) `make diff` reports `shift_detected: True`,
OR (d) `vert_structure_lift` shifts by ≥0.05 (about 2% relative).

## Metric reliability (iter 26 multi-seed evidence)

| Metric | Single-seed CV | Multi-seed required? |
|--------|----------------|----------------------|
| `vert_structure_lift` | 5.1% | No — single seed is diagnostic |
| `cc_count` | 11.0% | Optional — moderate variance |
| `cc_avg` | 7.8% | Optional |
| `cc_max` | **35.2%** | **Yes — single seed unreliable** |

When citing CC metrics across configs, run ≥3 seeds and report mean (or
mean ± σ). `structure_lift` can be cited at single seed.
