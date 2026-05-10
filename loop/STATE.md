# tanke — Loop State

## Phase

```
phase: build
iteration: 13
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
Iter 12 BUILD: HYPOTHESIS FALSIFIED — and that's a good thing.
- Created configs/test_p_merge.tres (initially identical to default)
- Edit tool: merge_probability 0.333 → 0.7 (single-line surgical)
- BEFORE: vert_persistence 0.647, eller_sets=15, avg_size=1.33
- AFTER:  vert_persistence 0.628, eller_sets=3,  avg_size=6.67  (sets grew 5×)
- Predicted UP, got DOWN slightly. Set mechanics worked perfectly; metric
  doesn't measure what I named it.
- DIAGNOSIS: vert_persistence has a 0.5 "block floor" from the 2x2 paving;
  what's above the floor measures concentration (which terrain dominates),
  not pure spatial structure. Iter 10 H2 (Goodhart) bleeding through.
- Honest score: criterion 11 stays 3/5 (predicted direction wrong).
- The loop's first empirical disconfirmation. Confirms measurement honesty.
```

---

## Stale Scores

None — but criterion 11 reading needs a refined metric to be trustable as
a structure measure.

---

## Next Action

`Iter 13 BUILD: refine vert_persistence. Options ranked by leverage:
  (1) subtract 0.5 block floor → "above-floor coherence", normalized 0-1
  (2) normalize against IID baseline (decouples from concentration)
  (3) sample at block level (every-other), avoid the floor entirely
Pick (1) for iter 13 — cheapest reveal. Plan (2) for iter 14.`

External CONSULT retry: iter 20.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
