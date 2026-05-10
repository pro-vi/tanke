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
| `level_seed` | `ProceduralLevel.gd` | 7 | int | any int (0 = random) | RNG seed. Same seed + same config → identical tile_hash. |
| `config` | `ProceduralLevel.gd` | 8 | LevelConfig | any `.tres` matching `LevelConfig.gd` | Distribution recipe; null falls back to `configs/default.tres`. |
| `debug` | `ProceduralLevel.gd` | 5 | bool | true/false | Overlay numeric set IDs on each cell — visual debugging only. |

**Mutate via:** edit `scenes/ProceduralLevel.tscn` to set defaults persistently,
or pass via `test_runner.gd` `-- --seed N --config PATH`.

---

## Verification

After any mutation:
```bash
# Headless oracle: deterministic distribution + tile_hash
godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --config <PATH>

# Screencapture oracle: pixel-level per-terrain coverage
make screenshot && make analyze
```

A change is "real" only if (a) `tile_hash` changes vs baseline, AND (b) at least
one terrain count changes by ≥10%.
