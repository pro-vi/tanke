# tanke — Loop State

## Phase

```
phase: bootstrap
iteration: 0
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

## Current Scores

| Criterion | Score | Notes |
|-----------|-------|-------|
| Headless oracle | 3 | `make test` catches GDScript runtime errors (120 frames, headless) |
| Algorithm variety | 0 | merge prob hardcoded ProceduralStep.gd:12 |
| LevelConfig mutability | 0 | ProceduralLevel.gd:69 hardcoded modular arithmetic |
| Level DNA | 0 | no stored seed |
| Tile visual coherence | 2 | TileMaps functional, tiles render; 100% brick dominance |
| Screencapture oracle | 4 | `make screenshot` + `make analyze` working; PIL tile oracle calibrated |
| Agent edit friction | 1 | only PlayerTank.gd exports exist |
| Procedural richness | 1 | flat modular distribution; 100% brick, 0 variety (oracle confirmed) |
| Pipeline completeness | 3 | check/test/screenshot/analyze/run all working |
| GDScript correctness | 3 | collision.normal → get_normal() fixed; make test clean |
| **Total** | **17/50** | |

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
Preloop complete. All checks passing:
- make test clean (headless, 120 frames)
- make screenshot + make analyze working (320×240 oracle, 100% coverage)
- interactive playtest: tank moves, camera follows, no errors
- camera startup glide fixed (reset_smoothing + force_update_scroll)
- RemoteTransform2D rotation/scale leak fixed
- tile positioning offset fixed (map_to_local center-aware in Godot 4)
```

---

## Stale Scores

None.

---

## Next Action

`Bootstrap — iter 0: fix _pave_set() distribution (brick 100%, variety 1/4)`

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
