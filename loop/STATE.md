# tanke — Loop State

## Phase

```
phase: build
iteration: 8
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
| Screencapture oracle | 3 | analyze_frame.py classifies by palette; entropy 3.9 |
| Agent edit friction | 5 | iter 7 zero-human-step cycle: AGENTS→Edit→rerun→Δ in one iter |
| Procedural richness | 3 | 6-seed sweep: per-terrain variance 40–63% (>20% threshold met) |
| Pipeline completeness | 3 | gen_tile→import→TileSet→render chain verified iter 4 (brick_007) |
| GDScript correctness | 3 | make test clean; test_runner clean across configs |
| **Total** | **38/50** | +4 from iter 6; **CEILING TRIPPED**; anchors raised iter 7 |

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
Iter 7 BUILD: cited mutation cycle (anticipated quad-lift, anticipated ceiling trip).
- BEFORE: watery.tres water_weight=0.60 → water 688
- Edit tool: water_weight 0.60 → 0.20 (single line, surgical)
- AFTER: water 392 (-43%), grass 60 → 212 (+253%), distinct hash
- Hypothesis confirmed: smallest competitor (grass) gains most when dominant weight shrinks
- Quad-lift: C2 3→4, C3 4→5, C4 4→5, C7 4→5
- Total 34→38/50; CEILING RULE TRIPPED
- Anchor revision: C2/3/4/7 score-5 anchors raised (Revision Log)
```

---

## Stale Scores

watery.tres now permanently at water_weight=0.20 (was 0.60). Prior LEDGER cites of "watery → water 688" are historical; current state is water 392.

---

## Next Action

`Iter 8 BUILD: implement diff-mode in analyze_frame.py — compare two frames, output distribution shift. Targets criterion 6 (Screencapture oracle 3→4). Force-multiplier: enables future C5/C8 measurements via screencapture Δ.`

Iter 10 CONSULT gate looms. Pre-staged hollow-points: (a) no spatial coherence in terrain, (b) merge_probability is depth-invariant, (c) entropy oracle is goodhart-able.

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
