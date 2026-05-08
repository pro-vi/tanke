# tanke — Loop State

## Phase

`phase: preloop`
`iteration: 0`
`preloop_complete: no`

---

## Preloop Checklist

```
[ ] Open project in Godot 4 editor (File → Import → select project.godot)
    Accept TileSet conversion when prompted.
[ ] Note source_id and atlas_coords for each terrain tile after conversion.
    Write them below under "tile_source_ids".
[ ] Verify: player tank moves, camera follows, no console errors.
[ ] Verify: ProceduralLevel.tscn generates terrain without errors.
[ ] Flip preloop_complete: yes in this file.
```

---

## Tile Source IDs (fill after editor migration)

```
tile_source_ids:
  brick: source_id=?, atlas_coords=Vector2i(?,?)
  steel: source_id=?, atlas_coords=Vector2i(?,?)
  grass: source_id=?, atlas_coords=Vector2i(?,?)
  water: source_id=?, atlas_coords=Vector2i(?,?)
```

---

## Current Scores (iter 0 — pre-bootstrap)

| Criterion | Score |
|-----------|-------|
| Gameplay loop | 1 |
| BrickBlock destruction | 0 |
| Enemy AI | 0 |
| Procedural variety | 2 |
| LevelConfig mutability | 0 |
| Level DNA | 0 |
| Visual coherence | 2 |
| Agent editability | 1 |
| GDScript correctness | 2 |
| Asset pipeline | 2 |
| **Total** | **10/50** |

---

## Open Seams

1. TileMap `set_cell` source_id/atlas_coords unknown until editor migration — blocks all terrain gen BUILD work
2. test_runner.gd not written — limits GDScript correctness scoring to "runs" not "verified"
3. BrickBlock has no collision response — blocks gameplay loop score
4. No enemy scene — enemy AI at 0

---

## Last Action

`Bootstrap: migrated project Godot 3→4 via godot --convert-3to4, fixed Callable bug in Level.gd:42, updated TileMap set_cell API calls, scaffolded tools/`

---

## Stale Scores

None yet.

---

## Next Action

`HALT — awaiting preloop_complete: yes from user`

---

## Consult Log

None yet. First consult scheduled for iter 10.

---

## User-Look Gates

- Iter 20: first playtest gate
- Iter 40: second playtest gate
