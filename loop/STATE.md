# tanke — Loop State

## Phase

```
phase: build
iteration: 2
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

## Current Scores (post iter 1)

| Criterion | Score | Notes |
|-----------|-------|-------|
| Headless oracle | 4 | seed-aware reproducibility; same seed → same hash |
| Algorithm variety | 0 | merge prob `randi() % 3 > 0` still hardcoded ProceduralStep.gd:18 |
| LevelConfig mutability | 0 | LevelConfig resource doesn't exist |
| Level DNA | 3 | `ProceduralLevel.gd:6` level_seed export; verified via tile_hash |
| Tile visual coherence | 3 | 4/4 palettes render correctly per analyze_frame.py |
| Screencapture oracle | 3 | analyze_frame.py classifies by palette; coverage/variety/entropy |
| Agent edit friction | 1 | only level_seed, debug, PlayerTank.speed exported |
| Procedural richness | 1 | seed 42: 56% brick, 28% grass, 11% water, 5% steel — flat |
| Pipeline completeness | 2 | set_cell calls correct; PIL→TileSet path not yet exercised |
| GDScript correctness | 3 | make test + test_runner clean across seeds |
| **Total** | **20/50** | |

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
Iter 1 BUILD: Level DNA — stored seed.
- @export level_seed on ProceduralLevel.gd; seed() called in _ready before generation
- test_runner.gd accepts -- --seed N (defaults 42)
- Reproducibility verified: seed 42 × 2 → hash 619cb88ffed7e906; seed 7 → beac3183dc58e335
- 5 rubric criteria lifted; total 17 → 20
```

---

## Stale Scores

Resolved: distribution score was non-deterministic; now deterministic at seed 42 baseline (brick 56% / grass 28% / water 11% / steel 5%).

---

## Next Action

`Iter 2 BUILD: LevelConfig resource — extract _pave_set hardcoded conditionals into a Resource with weights per terrain. Force multiplier across criteria 2, 3, 7, 8.`

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
