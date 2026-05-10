# tanke — Loop State

## Phase

```
phase: build
iteration: 19
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
| 11. Spatial Coherence | 5 | iter 18 biome_balanced: most-dom 30% + structure_lift 2.522× (high+high quadrant filled) |
| **Total** | **48/55** | +1 from iter 17; 87.3% on expanded rubric |

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
Iter 18 BUILD: high-diversity AND high-structure_lift quadrant filled.
- Created configs/balanced_steel.tres (b 0.20/s 0.30/g 0.25/w 0.20, p_merge 0.4)
- Created configs/biome_balanced.tres (default ⇄ balanced_steel)
- biome_balanced @ seed 42:
    distribution: brick 29% / water 17% / steel 30% / grass 24%
    most-dominant: 30%   structure_lift: 2.522×
  Strictly better than prior champion biome_default_to_watery (40% / 2.464×).
- Side finding: balanced_steel flat alone → structure_lift 2.456× (>default 2.388×)
  Moderate-merge balanced configs are productive even without biome.
- Criterion 11: 4 → 5. Total 47 → 48/55 (87.3%).

Anchor 5 of C11 explicitly required "Spatial-coherence axis is independent of
distribution axis" — demonstrated.
```

---

## Stale Scores

None.

---

## Next Action

`Iter 19 BUILD: criterion 10 (GDScript correctness) 3 → 4. Anchor 4:
"TileMap → TileMapLayer migration complete; zero deprecation warnings."
Flatten the Node2D-as-TileMap wrappers in ProceduralLevel.tscn (e.g.
"BrickTileMap" Node2D containing "Layer0" TileMapLayer) into direct
TileMapLayer children of Tiles. Update Level.gd onready paths.
Verify with godot --headless --quit and grep for warnings.`

External CONSULT retry: iter 20 (1 iter away — prep notes after iter 19).

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
