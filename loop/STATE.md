# tanke — Loop State

## Phase

```
phase: build
iteration: 15
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
| Algorithm variety | 4 | iter 7 cited single-field mutation: water_weight 0.6→0.2 → water -43% Δ |
| LevelConfig mutability | 5 | iter 7 full agent cycle: AGENTS.md → Edit → rerun → cite Δ |
| Level DNA | 5 | DNA-referenced config mutation + oracle confirmation in iter 7 |
| Tile visual coherence | 3 | 4/4 palettes render; all configs visually correct |
| Screencapture oracle | 4 | iter 8 --diff mode + make diff CONFIG=<preset>; per-terrain Δ + shift_detected |
| Agent edit friction | 5 | iter 7 zero-human-step cycle: AGENTS→Edit→rerun→Δ in one iter |
| Procedural richness | 4 | iter 9 biome interp: visible top-vs-bottom gradient; water +20.8% Δ |
| Pipeline completeness | 3 | gen_tile→import→TileSet→render chain verified iter 4 (brick_007) |
| GDScript correctness | 3 | make test clean; test_runner clean across configs |
| 11. Spatial Coherence | 4 | iter 14 cycle: depth_scale 14→100 → structure_lift 2.464×→2.236× (predicted DOWN, confirmed) |
| **Total** | **44/55** | +1 from iter 13; back to 80% on expanded rubric |

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
Iter 14 BUILD: cited mutation cycle on REFINED metric — predicted direction confirmed.
- New fixture configs/biome_test_depth.tres (initially identical to biome_d→w)
- Edit tool: depth_scale 14 → 100 (single-line)
- BEFORE: structure_lift 2.464×, vert_persistence 0.692
- AFTER:  structure_lift 2.236×, vert_persistence 0.675
- Δ structure_lift: -9.2%, predicted DOWN — CONFIRMED ✓
- Criterion 11: 3 → 4. Total 43→44/55, back to 80% on expanded rubric.

Epistemic milestone:
  iters 1-11: 11 cited cycles, predictions held
  iter 12: first FALSIFICATION (merge_probability)
  iter 13: instrument refined
  iter 14: re-prediction with refined instrument, CONFIRMED
The predict→falsify→refine→re-predict→verify cycle is complete.
```

---

## Stale Scores

None.

---

## Next Action

`Iter 15 BUILD: criterion 1 (Headless oracle) 4 → 5. Add --json flag to
test_runner.gd that emits structured output instead of text. Cheap;
makes the loop's measurements machine-readable for future diff/trend
tooling. Alternative: tackle criterion 11 anchor 5 (high diversity AND
high structure_lift) — but that requires search-style experimentation.`

External CONSULT retry: iter 20.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
