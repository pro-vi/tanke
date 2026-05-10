# tanke — Loop State

## Phase

```
phase: build
iteration: 28
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
| GDScript correctness | 5 | iter 27 typed throughout; every var + function annotated; make test clean |
| 11. Spatial Coherence | 5 | iter 18 biome_balanced: most-dom 30% + structure_lift 2.522× (high+high quadrant filled) |
| **Total** | **50/55** | +1 from iter 26; 90.9% on expanded rubric; natural pause point |

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
Iter 27 BUILD: typed GDScript pass — criterion 10 → 5.

7 scripts received type annotations (Constants/Level/PlayerTank/
TankSprite/BrickBlock/ProceduralLevel/ProceduralStep). Every var
typed; every function param/return typed where nontrivial.

Verification (seed 42 default):
  hash 1f80435080844dce   ← matches iter-21 post-bug-fix anchor
  structure_lift 2.414×, all metrics consistent

Logic unchanged. Typing is cosmetic. Total 49 → 50/55 (90.9%).

Score landscape:
  5/5: criteria 1, 3, 4, 7, 10, 11 (six)
  4/5: criteria 2, 5, 6, 8, 9 (five — all need NEW mechanisms or user-look)
```

---

## Stale Scores

None. Hash anchor 1f80435080844dce is the post-iter-21 baseline (preserved
through iter 22 CC metric, iter 27 typing pass).

USER-LOOK GATE: 7 iters open. Multiple remaining 4-anchors explicitly need it.

---

## Next Action

`Iter 28 META: write loop/META-RETRO.md.

Natural pause point. The remaining 4-anchors (criteria 2, 5, 6, 8, 9)
all need new mechanisms — search-style experimentation, seam-check
oracle, automation, multi-config playtest with HUMAN feedback, single-
iter generate-import-render. None are tunings; all are real new work.

The retro should:
  - Summarize the 27-iter trajectory (build → stress-test → cap)
  - Cite the four falsifications and the meta-findings
  - Catalog what each remaining 4-criterion would actually need
  - Make explicit what user-look would unlock
  - Decide: does the loop continue (substantive new work) or pause
    (rubric is honestly capped without human input)

Per greenfield-loop META protocol, this is the right moment for a
written summary before either a pivot or a halt.`

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
