# tanke — Loop State

## Phase

```
phase: build
iteration: 17
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
| Tile visual coherence | 2 | iter 16 swap regressed: gen_tile grass palette too far from sprite_1; classifier loses grass |
| Screencapture oracle | 4 | iter 8 --diff mode + make diff CONFIG=<preset>; per-terrain Δ + shift_detected |
| Agent edit friction | 5 | iter 7 zero-human-step cycle: AGENTS→Edit→rerun→Δ in one iter |
| Procedural richness | 4 | iter 9 biome interp: visible top-vs-bottom gradient; water +20.8% Δ |
| Pipeline completeness | 4 | iter 16 all 4 terrains regenerated via gen_tile + atlas swap; full-sheet chain |
| GDScript correctness | 3 | make test clean; test_runner clean across configs |
| 11. Spatial Coherence | 4 | iter 14 cycle: depth_scale 14→100 → structure_lift 2.464×→2.236× (predicted DOWN, confirmed) |
| **Total** | **45/55** | +1 from iter 14; 81.8% on expanded rubric |

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
Iter 16 BUILD: full-sheet PIL pipeline; trade-off iter.
- Generated steel/grass/water variants via gen_tile.py (variant 7)
- Imported all (UIDs btw4..., dqcy..., dg7t...)
- Swapped each atlas source in ProceduralLevel.tscn (load_steps 12→15)
- Headless: seed-42 hash 6159ef2f5464edb1 PRESERVED — game logic untouched
- Screencap: coverage 93.9%, variety 3/4 — grass classified as 0 px
  (gen_tile grass palette is too far from sprites_1.png reference)
- ASSET-MANIFEST: full provenance entry for steel/grass/water_007
- Score trade: C5 3→2 (regression), C9 3→4 (advance). Net 0; total 45/55.
- Honest finding: gen_tile palettes were never grounded in sprite sheet.
  This was knowable in advance; iter 17 fixes by extracting from sprites_1.png.
```

---

## Stale Scores

C5 dropped to 2. The drop is from ungrounded palettes in gen_tile.py;
iter 17 should recover and lift further.

---

## Next Action

`Iter 17 BUILD: palette extraction in gen_tile.py. Add helper that reads
top-3 frequent colors from sprites_1.png at given margins; use them as
the palette for that terrain. Re-generate variant 7 for all 4 terrains
with extracted palettes; re-import; re-screencap. Predicted: variety 4/4
classifier returns (C5 → 3); palette-extraction satisfies C5 anchor 4
(C5 → 4); C9 stays at 4. Total: 45 → 47/55 if both lift.`

External CONSULT retry: iter 20 (3 iters away).

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
