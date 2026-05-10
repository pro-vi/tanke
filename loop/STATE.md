# tanke — Loop State

## Phase

```
phase: build
iteration: 26
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
| GDScript correctness | 4 | iter 19 flattened TileMap wrappers; structurally migrated; zero deprecation warnings |
| 11. Spatial Coherence | 5 | iter 18 biome_balanced: most-dom 30% + structure_lift 2.522× (high+high quadrant filled) |
| **Total** | **49/55** | +1 from iter 18; 89.1% on expanded rubric |

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
Iter 25 SWEEP: single-variable p_merge sweep — 4th falsification.

Sweep (balanced_steel weights, vary only p_merge, seed 42):
  p=0.333  cc_max  96
  p=0.4    cc_max  96
  p=0.5    cc_max 192   ← non-monotone peak
  p=0.6    cc_max 144   ← drops back

Predicted: monotonic growth. Got: peaked-and-dropped.

structure_lift IS roughly monotonic (↓ with ↑ p_merge: 2.506 → 2.443).
That's the only stable predictable dimension.

cumulative: 4 falsified directional predictions on CC behavior (0/4
accuracy). Single-seed CC measurements are chaotic due to compound
randomness across rows. Cannot be predicted by intuitive parameter
modeling.

META-DECISION: stop framing CC iters as "predict and verify". Frame as
"explore and report". The empirical map matters more than my predictions.

No score change. Total 49/55.
```

---

## Stale Scores

The iter-22 cite "biome_balanced has cc_max=68" is single-seed
data. Multi-seed sweep at iter 26 will report mean ± stddev. If
variance is high, the cited number becomes unreliable as anchor.

USER-LOOK GATE: open 5 iters, user firing /loop without feedback —
proceeding with self-direction.

---

## Next Action

`Iter 26 SWEEP: multi-seed CC sweep on biome_balanced. Seeds {1, 7, 42,
100, 314, 999} (iter-3 grid). Report mean/stddev for cc_max, cc_count,
structure_lift. Honest measurement.

If high variance: retire single-seed CC anchors; re-cite as mean ± σ.
If low variance: the iter-22 cited values are reliable; the chaos
surfaced in iter 25 was specific to p_merge interaction.

Either way, this is the empirical map at multi-seed resolution —
overdue.`

---

## Consult Log

None. First consult: iter 10.

---

## User-Look Gates

- Iter 20: playtest gate (3 seeds, report what feels monotonous)
- Iter 40: second playtest gate
