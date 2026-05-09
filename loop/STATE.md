# tanke — Loop State

## Phase

```
phase: preloop
iteration: 0
preloop_complete: no
```

---

## Preloop Checklist

```
[x] Open project in Godot 4 editor — done (user ran Extract on TileMaps)
[x] source_id + atlas_coords resolved from scene files (see below)
[ ] Verify: player tank moves, camera follows, no console errors (hit F5 in editor)
[ ] Verify: ProceduralLevel.tscn generates terrain without errors
[ ] Flip preloop_complete: yes above
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
| Headless oracle | 0 | test_runner.gd not yet written |
| Algorithm variety | 0 | merge prob hardcoded ProceduralStep.gd:12 |
| LevelConfig mutability | 0 | ProceduralLevel.gd:69 hardcoded |
| Level DNA | 0 | no stored seed |
| Tile visual coherence | 1 | TileSet migration not run; source_id unknown |
| Screencapture oracle | 0 | analyze_frame.py not yet written |
| Agent edit friction | 1 | only PlayerTank.gd exports exist |
| Procedural richness | 1 | flat modular distribution |
| Pipeline completeness | 0 | blocked on TileSet migration |
| GDScript correctness | 2 | converted, TileMap deprecated warnings |
| **Total** | **5/50** | |

---

## Open Seams

1. TileSet migration → source_id/atlas_coords unknown (blocks pipeline completeness, tile coherence)
2. test_runner.gd not written (blocks oracle quality scoring above 0)
3. analyze_frame.py not written (blocks screencapture oracle)
4. LevelConfig doesn't exist (blocks mutability, richness, Level DNA)
5. No stored seed in ProceduralLevel (blocks Level DNA)

---

## Last Action

```
Rewrote loop to procedural-only focus + dual oracle (headless + screencapture).
Committed baseline on exp/godot4-loop (db6338f).
```

---

## Stale Scores

None.

---

## Next Action

`HALT — awaiting preloop_complete: yes`

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
