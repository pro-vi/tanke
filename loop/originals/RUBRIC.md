# tanke — Originals Loop Rubric (arc 3, v1)

10 criteria, 0–5 scale. **Score > 2 on stage-count criteria (7/8/9) requires
PNG-diff cross-validation pass per stage.** Score > 2 on feel criteria
(2, 6, 10) requires playtest citation.

**Reachability floor**: any criterion's score is capped at 0 if any included
stage fails reachability (`playable: false`). Arc-1 carry.

**PNG-diff floor** (NEW for arc 3): criteria 7/8/9 cap at the count of stages
that pass `tools/png_diff.py` with <5% cell mismatch against StrategyWiki
reference. Cite per-stage diff result.

---

## 1. Loader correctness (0–5)

`scripts/LevelLoader.gd` parses Tanks ASCII format → emits correct
`set_cell` calls on the appropriate TileMapLayers.

| Score | Anchor |
|-------|--------|
| 0 | LevelLoader doesn't exist |
| 1 | Parses one stage; some cells may be wrong |
| 2 | Parses one stage; every cell correct (manual diff vs Tanks source) |
| 3 | Parses 5+ stages correctly; legend coverage (`.#@%~-`) all handled — code-cited |
| 4 | Parses all 35 Tanks stages without parse error AND emits identical render to Tanks's text — automated diff cited |
| 5 | Loader handles edge cases (empty stages, malformed input, missing files) gracefully; covered by `make test` |

---

## 2. Eagle gameplay (0–5) — *feel criterion*

Eagle entity exists; protect-or-die mechanic functions.

| Score | Anchor |
|-------|--------|
| 0 | No eagle entity |
| 1 | Eagle sprite placed at correct stage position; static decoration |
| 2 | Eagle has HP=1; bullets can hit it; emits `eagle_destroyed` signal — code-cited |
| 3 | Eagle destroyed = game-over state; restart returns cleanly — code-cited |
| 4 | Eagle gameplay verified via playtest — "the eagle felt like BC's eagle" — feel-cited |
| 5 | Eagle survival creates real tension in playtest — user prioritizes defense over kills, cites this unprompted |

---

## 3. Ice physics (0–5)

`-` tile behavior decided + implemented.

| Score | Anchor |
|-------|--------|
| 0 | Ice symbol unhandled (causes parse error or treated as random) |
| 1 | Phase-1 decision iter: pass-through OR slide-physics chosen + ship one — cited |
| 2 | Ice tile renders distinctly (visual differentiation from empty/grass) — code-cited |
| 3 | Slide-physics implemented (if that's the choice): tank momentum carries over ice — code-cited |
| 4 | Ice physics feels BC-faithful in playtest |
| 5 | Ice creates meaningful gameplay consequence (cited via playtest "I slid into a wall") |

If pass-through chosen, cap at 2/5 (ship-but-don't-claim-faithful).

---

## 4. PNG-diff oracle (0–5) — *capability criterion*

`tools/png_diff.py` builds + accurately measures stage fidelity.

| Score | Anchor |
|-------|--------|
| 0 | No PNG-diff tool |
| 1 | Tool exists; runs on one stage; reports mismatch % |
| 2 | Tool reads StrategyWiki PNG, classifies each 16×16 tile, compares to our render — accuracy hand-verified on 1 stage |
| 3 | Tool produces per-stage report (X% cells match; Y mismatched at specific coords) |
| 4 | Tool integrated into the loop's verification flow — every IMPORT iter runs it and cites result |
| 5 | Tool handles edge cases (stage rotation, palette variants, downloaded PNG missing); part of `make` workflow |

---

## 5. Enemy roster fidelity (0–5)

Per-stage enemy spawn counts + types match canonical OG, mined from
Tanks's Java source.

| Score | Anchor |
|-------|--------|
| 0 | OG mode uses arc-2's existing spawn schedule (no per-stage data) |
| 1 | Sub-research iter run: per-stage roster located in Tanks source — cited file:line |
| 2 | Roster data encoded in `configs/stages/stage_KK.tres` for 5+ stages |
| 3 | All 35 stages have encoded rosters; Spawner.gd extended to read per-stage data |
| 4 | Roster accuracy cross-validated against Wikipedia / fan walkthrough for ≥5 stages |
| 5 | Roster feels BC-correct in playtest (cited "this stage is hard like OG stage K") |

---

## 6. Mode selection (0–5) — *feel criterion*

Title / mode picker scene; player can choose Originals or Procedural.

| Score | Anchor |
|-------|--------|
| 0 | No mode selection (default scene is one of the two; cannot switch in-game) |
| 1 | Title screen exists with text labels "Original" / "Procedural" |
| 2 | Both options load their respective mode without crashes |
| 3 | Title screen has visible affordance (button highlight / sprite cursor) — code-cited |
| 4 | Mode selection feels intentional in playtest (user picks deliberately, doesn't fumble) |
| 5 | First-time user can navigate to either mode without instruction — playtest cited |

---

## 7. Stages 1-12 complete (0–5)

Count of fully-imported stages in the first third. Each must: parse via
LevelLoader, pass reachability, PNG diff <5% mismatch.

| Score | Anchor |
|-------|--------|
| 0 | 0 stages |
| 1 | 1-2 stages complete |
| 2 | 3-5 stages complete |
| 3 | 6-8 stages complete |
| 4 | 9-11 stages complete |
| 5 | All 12 complete |

---

## 8. Stages 13-24 complete (0–5)

Same anchors as criterion 7 but for the middle third.

| Score | Anchor |
|-------|--------|
| 0 | 0 stages |
| 1 | 1-2 stages |
| 2 | 3-5 stages |
| 3 | 6-8 stages |
| 4 | 9-11 stages |
| 5 | All 12 complete |

---

## 9. Stages 25-35 complete (0–5)

Same anchors but for the final third (11 stages total — stages 25-35).

| Score | Anchor |
|-------|--------|
| 0 | 0 stages |
| 1 | 1-2 stages |
| 2 | 3-4 stages |
| 3 | 5-7 stages |
| 4 | 8-10 stages |
| 5 | All 11 complete |

---

## 10. End-to-end playable run (0–5) — *feel criterion*

Player starts at Stage 1, advances through to Stage 35 in a single session.

| Score | Anchor |
|-------|--------|
| 0 | Can't load even Stage 1 |
| 1 | Stage 1 loads and plays |
| 2 | Linear advance from stage to stage works (clear stage → next loads) — code-cited |
| 3 | Stages 1-10 reachable in single session without crashes |
| 4 | Stages 1-25 reachable; eagle gameplay survives the full progression |
| 5 | Full 1-35 reachable + "win" state when stage 35 cleared; full playthrough verified via playtest |

---

## Acceptance template (per stage — referenced by /story-loop verification)

Each stage is a user-story:

```
**Stage K — user story**

As a player, I can play Stage K of Battle City.

Acceptance:
- [ ] Layout loads via `LevelLoader.gd` from `.research/repos/Tanks/resources/stages/K`
- [ ] Per-cell terrain matches Tanks source: 100% match (code-diff)
- [ ] Reachability oracle reports: playable=true
- [ ] Eagle placed at canonical position (typically tile (12, 24) in 26×26 coords; verify per stage)
- [ ] PNG diff against `StrategyWiki/Battle_City_StageKK.png`: <5% cell mismatch
- [ ] Enemy roster matches per-stage canonical data (mined from Tanks source)
- [ ] Stage loads in <500ms (no perceptible hang)

Evidence: `loop/originals/LEDGER.md` iter NNN cites results; `STAGES.md` checkbox flipped.
```

Stage iters typically import 2-5 stages in one iter (BUILD/IMPORT mode).

---

## Revision Log

| Iter | Change | Reason |
|------|--------|--------|
| 0 | Initial arc-3 rubric, 10 criteria, frontier-loop shape | New arc scope: import 35 BC stages with eagle + ice + PNG diff |
