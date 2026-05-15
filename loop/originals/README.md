# tanke Originals loop (arc 3)

**Frontier-loop** dialect: reproduce all 35 Battle City NES (1985 Namco)
stages as a Godot 4 game mode parallel to arc-2's procedural mode.

Distinct from arcs 1+2 (both `/greenfield-loop`-shaped) because the
artifact + evaluator + target are all defined or constructable at iter 0.

## How to fire

```
/loop Read ./loop/originals/PROMPT.md and follow its instructions exactly.
```

Works cold — the PROMPT references everything else explicitly and assumes
no prior session context.

## What this arc produces

- `scenes/OriginalLevel.tscn` — new mode scene, parallel to ProceduralLevel.tscn
- `scripts/LevelLoader.gd` — parses Tanks ASCII format
- `scripts/Eagle.gd` + `scenes/Eagle.tscn` — BC eagle entity (HP=1, protect-or-die)
- `scripts/StageDirector.gd` — stage progression (1 → 35)
- `scenes/TitleScreen.tscn` — mode picker
- `configs/stages/stage_{01..35}.tres` — per-stage data (terrain ref + enemy roster + ice flag)
- `tools/png_diff.py` — visual cross-validation oracle

## Substrate boundaries (3 layers — strict)

| Layer | Contents | Status |
|-------|----------|--------|
| **L1** | Engine (`LevelConfig`, `ProceduralStep`, etc.) | frozen since arc 1 |
| **L2** | Gameplay (`Bullet`, `Enemy*`, `Spawner`, `PlayerTank`, configs) | frozen as of arc-2 iter 100; `Spawner` + `PlayerTank` may be EXTENDED (not refactored) for OG-specific work |
| **L3** | BC source (`.research/repos/Tanks/`) | read-only canonical |

Arc 3 writes its own files. It does NOT modify L1 or `ProceduralLevel.tscn`.

## How arc 3 feeds back into arc 2

After all 35 stages import, the loop computes their structural metrics
(terrain density, room sizes, cc_max, ascent geometry) and produces an
empirical reference distribution. Arc 2's procedural mode can then be
tuned to land within OG-stage ranges — resolving arc-2's F014
(procedural variety unperceived) by giving the generator a ground truth
instead of self-comparison.

This is the **second arc-handoff**: arc 1 → arc 2 was substrate; arc 3 → arc 2
is calibration data.

## Halt

- Write "stop" or "halt"
- Set `Next action: HALT` in STATE.md
- 3 unfulfilled PLAYTEST requests → `HALTED.md` (carried halt rule)
- All 35 stages complete + eagle + ice + end-to-end playable + PNG diff all-passing → **arc closes successfully** (write META-RETRO-iter-NNN.md, file final retrospective)

## Files

| File | Purpose |
|------|---------|
| `PROMPT.md` | Loop instruction. Read every iter. |
| `RUBRIC.md` | 10 arc-3 criteria. |
| `STATE.md` | Phase / iter / open seams. Updated every iter. |
| `STAGES.md` | 35-stage checklist; flip checkboxes as stages complete. |
| `LEDGER.md` | Append-only iter history. Created iter 0. |
| `PRE-MORTEMS.md` | Per-iter predictions. H2 RULE v2. Created iter 1. |
| `FALSIFICATIONS.md` | F-numbered falsifications + lessons. |
| `creative-consults.md` | Consult records. First at ~iter 10. |

## Reference docs

- `loop/META-RETRO.md` — arc 1 retro (engine, iters 0-28)
- `loop/gameplay/META-RETRO-iter100.md` — arc 2 retro (gameplay, iters 0-100)
- `loop/gameplay/PROMPT.md` — arc-2 PROMPT v2 (much of arc-3's protocol carries from here)
- `.research/synthesis-bc-level-sources-2026-05-13.md` — arc-3's research record

## Milestones

| Milestone | Meaning |
|-----------|---------|
| Loader + 1 stage imports | criterion 1 → 2, criterion 7 → 1 (stage 1 in 1-12 bucket) |
| Eagle gameplay shipped | criterion 2 → 3+ |
| PNG-diff oracle working | criterion 4 → 3+ |
| Stages 1-12 all pass | criterion 7 → 5 |
| Stages 13-24 all pass | criterion 8 → 5 |
| Stages 25-35 all pass | criterion 9 → 5 |
| End-to-end run 1→35 | criterion 10 → 5 |
| Total ≥ 35/50 | If hit before iter 15, anchors raised per CEILING RULE |
| Total ≥ 45/50 | Ship candidate — extended user-look gate before claiming done |
