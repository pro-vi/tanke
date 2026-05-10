# tanke — Loop State

## Phase

```
phase: build
iteration: 3
preloop_complete: yes
```

---

## Preloop Checklist

```
[x] Open project in Godot 4 editor — done
[x] source_id + atlas_coords resolved from scene files (see below)
[x] ProceduralLevel.tscn generates terrain without errors — make test clean
[x] Screencapture oracle working — make screenshot + make analyze produce valid oracle output
[x] Verify interactively: player tank moves, camera follows, no console errors (F5 in editor)
[x] Flip preloop_complete: yes above
```

---

## Tile Source IDs

```
tile_source_ids:
  brick:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(40,0) in sprites_1.png
  steel:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(16,0) in sprites_1.png
  grass:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(24,0) in sprites_1.png
  water:  source_id=0  atlas_coords=Vector2i(0,0)  margins=Vector2i(24,8) in sprites_1.png
```

---

## Current Scores (post iter 2)

| Criterion | Score | Notes |
|-----------|-------|-------|
| Headless oracle | 4 | seed + config-aware; reproducible hash |
| Algorithm variety | 3 | 3 configs (default/watery/fortress) → 3 distinct distributions @ seed 42 |
| LevelConfig mutability | 4 | `.tres` Resource; weights editable without `.gd` changes |
| Level DNA | 3 | level_seed + config combine for full reproducibility |
| Tile visual coherence | 3 | 4/4 palettes render; all configs visually correct |
| Screencapture oracle | 3 | analyze_frame.py classifies by palette; entropy 3.9 |
| Agent edit friction | 4 | `loop/AGENTS.md` documents all 7 mutable params |
| Procedural richness | 2 | 4 types reliable; awaiting multi-seed SWEEP for variance |
| Pipeline completeness | 2 | set_cell correct; PIL→TileSet path unexercised |
| GDScript correctness | 3 | make test clean; test_runner clean across configs |
| **Total** | **31/50** | +11 from iter 1; ceiling check at 35 |

---

## Oracle Reading (iter 0)

```
frame: frame00000004.png
coverage:     100.0%  score 5/5
variety:      1/4     score 1/4   ← primary target
distribution: 0.000 bits  score 0.0/5.0  ← primary target
brick: 76800px  steel: 0  grass: 0  water: 0
```

Root cause: `_pave_set()` brick condition (2≤size≤7, sid%2==0) catches nearly all
sets in elif chain before steel/grass/water checks fire. First loop task: fix.

---

## Open Seams

1. `_pave_set()` distribution algorithm — brick dominates, oracle score 0/5; needs LevelConfig weights
2. LevelConfig resource doesn't exist — blocks mutability, Level DNA
3. No stored seed in ProceduralLevel — blocks Level DNA
4. BrickBlock destruction — bullet impact TODOs in BrickBlock.gd
5. Enemy tank AI not implemented
6. World rebasing — Camera2D limit_top defaults to -10,000,000 (not infinite); infinite upward scroll will eventually hit it; needs chunk recycling / world origin rebase before approaching that bound

---

## Last Action

```
Iter 2 BUILD: LevelConfig as Resource (.tres).
- LevelConfig.gd with merge_probability + 5 terrain weights + sample_terrain()
- 3 .tres presets: default / watery / fortress
- _pave_set rewritten as weighted sample → tilemap dispatch
- ProceduralStep accepts merge_probability through _init
- test_runner.gd accepts -- --config PATH
- AGENTS.md documents all 7 mutable params
- Quad-axis lift: criteria 2 (0→3), 3 (0→4), 7 (1→4), 8 (1→2). Total 20→31.
```

---

## Stale Scores

None. Old seed-42 baseline (brick 56%/grass 28%/water 11%/steel 5%, hash 619cb88f) was a modular-arithmetic artifact — replaced with weighted baseline (37/19/23/21, hash 6159ef2f).

---

## Next Action

`Iter 3 SWEEP: ≥5 seeds × default config — measure inter-seed variance, score Procedural Richness criterion 8. If <20% variance, follow with BUILD to add structural variation (biome zones / Perlin overlay).`

Approaching ceiling rule (35/50). If iter 3 lands above 35, raise rubric score-4/5 anchors before iter 4.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
