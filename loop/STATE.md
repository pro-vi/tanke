# tanke — Loop State

## Phase

```
phase: build
iteration: 18
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
| Headless oracle | 5 | --json flag emits 16-field JSON; jq-based diff workflow demonstrated |
| Algorithm variety | 4 | iter 7 cited single-field mutation: water_weight 0.6→0.2 → water -43% Δ |
| LevelConfig mutability | 5 | iter 7 full agent cycle: AGENTS.md → Edit → rerun → cite Δ |
| Level DNA | 5 | DNA-referenced config mutation + oracle confirmation in iter 7 |
| Tile visual coherence | 4 | iter 17 sprite-sheet-extracted palettes; coverage 99.9%/variety 4/4/entropy 4.0 |
| Screencapture oracle | 4 | iter 8 --diff mode + make diff CONFIG=<preset>; per-terrain Δ + shift_detected |
| Agent edit friction | 5 | iter 7 zero-human-step cycle: AGENTS→Edit→rerun→Δ in one iter |
| Procedural richness | 4 | iter 9 biome interp: visible top-vs-bottom gradient; water +20.8% Δ |
| Pipeline completeness | 4 | iter 16 all 4 terrains regenerated via gen_tile + atlas swap; full-sheet chain |
| GDScript correctness | 3 | make test clean; test_runner clean across configs |
| 11. Spatial Coherence | 4 | iter 14 cycle: depth_scale 14→100 → structure_lift 2.464×→2.236× (predicted DOWN, confirmed) |
| **Total** | **47/55** | +2 from iter 16; 85.5% on expanded rubric |

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
Iter 17 BUILD: gen_tile.py --from-sheet PATH. Recovery + overshoot.
- Added extract_palette() reading top-4 frequent non-near-black colors
- SHEET_MARGINS dict matches analyze_frame.py TILE_DEFS by construction
- Regenerated all 4 variants from sprites_1.png; .import UIDs preserved
- Screencap: coverage 99.9%, variety 4/4, entropy 4.0/5.0
  (entropy BETTER than original baseline 3.9)
- Headless hash 6159ef2f5464edb1 STILL preserved — third confirmation
  that texture changes don't perturb game logic
- Criterion 5: 2 → 4 (recovers iter-16 regression + lifts further).
- Total 45 → 47/55 (85.5%).
```

---

## Stale Scores

None — iter 16 regression resolved.

---

## Next Action

`Iter 18 BUILD: criterion 11 anchor 5 attempt — find/construct config that's
high diversity AND high structure_lift simultaneously. Currently:
  - default: balanced (high diversity), structure_lift 2.388×
  - watery/fortress: concentrated (low diversity), watery 2.36× / fortress 1.53×
  - biome: medium-medium, structure_lift 2.464× (highest!)
The "high+high" quadrant is empty. A config that maintains terrain balance
WHILE creating structural runs would be a real architectural finding.
Possible path: increase merge_probability slightly (0.5?) on a balanced
config — large rooms but balanced types. Test prediction.`

External CONSULT retry: iter 20 (2 iters away).

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
