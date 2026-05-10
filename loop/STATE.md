# tanke — Loop State

## Phase

```
phase: build
iteration: 14
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
| 11. Spatial Coherence | 3 | iter 11 vert_persistence metric; cited 0.647/0.727/0.710/0.692 across configs |
| **Total** | **43/55** | iter 11 added criterion 11; proportional score 78% (was 80% on /50) |

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
Iter 13 BUILD: vert_persistence refined with two new derived metrics.
- vert_above_floor = (vp - 0.5) / 0.5
- vert_structure_lift = vp / iid_expected (Σ p_i² over observed distribution)
Survey (seed 42):
  default     structure_lift 2.388×    (balanced)
  watery      structure_lift 2.357×    (water-heavy concentration)
  fortress    structure_lift 1.529×    ← LOWEST despite huge sets
  biome       structure_lift 2.464×    ← HIGHEST (more than its endpoints!)
  high p_merge structure_lift 2.291×   (still slightly down from default)

3 findings unmasked:
  1. Fortress's high raw persistence was concentration; structurally weakest
  2. Default ≈ watery on structure once concentration is normalized
  3. Biome creates MORE structure than either flat endpoint — real architecture
     from depth-modulation, not just count-shifting

Iter 12 falsification holds under refined metric (now -4.1% vs -2.9% raw).
Bigger Eller sets really do reduce per-cell structural lift.
Criterion 11 stays 3/5 (no new mutation cycle with confirmed direction).
```

---

## Stale Scores

None.

---

## Next Action

`Iter 14 BUILD: biome enable/disable as proper cited mutation cycle. Prediction
(refined): enabling biome on a level should INCREASE structure_lift vs flat
default (today's survey supports this: 2.388 → 2.464, +3.2%). Run as
single-fixture before/after with the Edit tool. If predicted Δ confirmed,
criterion 11 lifts 3 → 4 — the loop's first re-prediction after a falsification.`

External CONSULT retry: iter 20.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
