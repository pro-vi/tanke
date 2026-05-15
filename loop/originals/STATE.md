# tanke — Originals Loop State (arc 3)

## Phase

```
phase: loop
iteration: 3 (BUILD ice + eagle — complete; iter 4 scheduled)
arc: 3 (Originals — BC NES stages import)
loop_type: frontier-loop with /story-loop per-stage verification
preloop_complete: yes
score: 15/50  (C1=4, C2=2, C3=2, C4=3, C7=2, C8=1, C10=1 — all [STRUCTURE] or [STRUCTURE-DEFERRED])
```

**Iter-2 score correction**: previously reported as 8/50 but the rubric-correct score was 10/50 (C7 should have read 2 — RUBRIC.md asks for 3 gates while STAGES.md tracks 6 gates; I conflated the bars). Cumulative path: iter 1 = 5, iter 2 = 10, iter 3 = 15. The correction is logged in `loop/originals/LEDGER.md` iter 003.

---

## Preloop Checklist

```
[x] Read loop/META-RETRO.md (arc 1, engine retro)
[x] Read loop/gameplay/META-RETRO-iter100.md (arc 2, gameplay retro)
[x] Read .research/synthesis-bc-level-sources-2026-05-13.md (arc-3 research)
[x] Verify .research/repos/Tanks/resources/stages/1 exists and matches synthesis sample
[x] Verify `make test` exit 0 (arc-2 procedural baseline still works)
[x] Confirm arc-2 hash anchor (current iter-100 baseline) holds — record for cross-arc invariant
[x] Flip preloop_complete: yes
```

Iter-0 verification: hash anchor `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` reproduced on procedural scene (seed 42); `playable: true`, `reachable_cells: 676`, `rows_climbed: 29`. Cited in `loop/originals/LEDGER.md` iter 000.

---

## Substrate baseline (record at iter 0)

Layer 1 (engine, frozen since arc 1):
- `scripts/LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`
- `scripts/ProceduralStep.gd`, `ProceduralLevel.gd`
- `tools/gen_tile.py`, `tools/analyze_frame.py`
- `loop/test_runner.gd` (extend; never refactor)

Layer 2 (gameplay, frozen as of arc-2 close iter 100):
- `scripts/Bullet.gd`, `Enemy.gd`, `EnemyLight.gd`, `EnemyHeavy.gd`
- `scripts/Spawner.gd` (will be EXTENDED for OG per-stage rosters — arc-3 soft-substrate write)
- `scripts/PlayerTank.gd` (will be EXTENDED for eagle-protect mechanic — arc-3 soft-substrate write)
- `scripts/BrickBlock.gd`
- `configs/playable.tres`
- Arc-2 hash anchor: `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291`

Layer 3 (BC source, read-only canonical):
- `.research/repos/Tanks/resources/stages/{1..35}`
- `.research/repos/Tanks/src/` — read-only for enemy roster mining
- `.research/synthesis-bc-level-sources-2026-05-13.md` — research record

Cross-arc invariant: arc-2 procedural mode must continue working unchanged.
Hash anchor `23d6a2ec…` is the regression detector.

---

## Current Scores (post iter 003)

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Loader correctness | **4** | All 35 stages parse exact; ice now placed (not skipped); anchor 5 awaits `make test` edge-case coverage |
| 2. Eagle gameplay | **2** | Anchors 1+2 ✓ — eagle at canonical fortress; HP=1; eagle_destroyed signal; take_damage method. Anchor 3 (game-over state) iter 4+ |
| 3. Ice physics | **2** | Anchors 1+2 ✓ — pass-through decision shipped; ice renders distinctly. Capped at 2/5 per rubric ("ship-but-don't-claim-faithful") |
| 4. PNG-diff oracle | **3** | Anchor 3 ✓ (iter 002); anchor 4 awaits first IMPORT iter |
| 5. Enemy roster fidelity | 0 | Per-stage data not extracted from Tanks src |
| 6. Mode selection | 0 | No title/picker scene |
| 7. Stages 1-12 complete | **2** | Stages 1, 4, 7 pass all 3 rubric gates (parse + reachable + PNG <5%) → anchor 2 (3-5 stages). Corrected from iter-2 under-score |
| 8. Stages 13-24 complete | **1** | Stage 17 at 1.642% — passes all 3 rubric gates → anchor 1 (1-2 stages) |
| 9. Stages 25-35 complete | 0 | No stages diffed in this third yet |
| 10. End-to-end playable | **1** | Stage 1 loads headless [STRUCTURE-DEFERRED]; "plays" awaits PLAYTEST |
| **Total** | **15/50** | post iter 003 |

---

## Open seams (iter 1+ priorities)

Ordered by dependency / unblock-value:

1. **LevelLoader.gd** (criterion 1) — must exist before any stage imports. Iter 1 work.
2. **OriginalLevel.tscn** (criterion 10 prereq) — new scene file; parallel to ProceduralLevel.tscn. Iter 1.
3. **test_runner.gd extension** (`--scene` + `--og-stage K` flags) — capability work to support reachability check on OG stages. Iter 1.
4. **Eagle.gd + Eagle.tscn** (criterion 2) — iter 2-3 work; the BC win/lose entity.
5. **Per-stage enemy roster mining** (criterion 5) — iter 1-2 sub-research into Tanks's src/.
6. **Ice physics decision iter** (criterion 3) — iter 3 work; phase-1 explicit decision.
7. **PNG-diff oracle** (criterion 4) — iter 2-3 capability work; needed BEFORE mass stage import.
8. **Mode selection** (criterion 6) — can be deferred until stages 1-5 import; iter 5+.
9. **Mass stage import** (criteria 7/8/9) — iter 4+ once loader + oracle + eagle are in. ~2-5 stages per iter.

Suggested iter path (rough estimate, ~25-30 iters to close):
- iters 0-3: scaffolding (loader, oracle, scene, eagle)
- iter 4-5: ice decision + first stage imports (sanity check)
- iter 5: PLAYTEST (mode select + stage 1 walks)
- iters 6-12: import stages 1-12 (criterion 7 → 5)
- iter 10: PLAYTEST + CONSULT
- iters 13-18: import stages 13-24 (criterion 8 → 5)
- iter 15: PLAYTEST
- iters 19-25: import stages 25-35 (criterion 9 → 5)
- iter 20: PLAYTEST + CONSULT
- iters 26-28: end-to-end progression + final PLAYTEST
- iter 28-30: arc-3 META-RETRO + feedback to arc-2 procedural mode

---

## Last Action

```
Iter 003 BUILD complete (2026-05-15).

- Pre-mortem filed with 4 [STRUCTURE] failure modes; F3+F4 pre-mitigated; one
  unanticipated import-hang surfaced and resolved (godot --headless --import).
- Phase-1 ICE DECISION: pass-through (caps C3 at 2/5 by design).
- img/ice_007.png (8×8 gray) + img/eagle_007.png (16×16 placeholder bird).
- Ice TileMapLayer added to OriginalLevel.tscn; LevelLoader writes '-' cells.
- scripts/Eagle.gd (StaticBody2D, HP=1, eagle_destroyed signal, take_damage)
  + scenes/Eagle.tscn (16×16 sprite, collision_layer=1).
- OriginalLevel.gd: @onready iceTileMap + _spawn_eagle at canonical (160, 216);
  35-stage fortress survey confirmed #..# at cols 11-14 rows 24-25 is UNIVERSAL.
- PlayerTank moved from (160, 220) (overlapped eagle) to (124, 220).
- Re-diff sweep: stages 1/4/7/17 all <5% (1: 0.448%, 4: 0.597%, 7: 0.448%,
  17: 1.642%). Stage 17 dropped from 32% → 1.6% — iter-3 headline cure.
- Verification: procedural hash anchor 23d6a2ec… preserved; make test exit 0.
- Scores: C2 0→2, C3 0→2, C7 0→2 (correction from iter-2 under-score), C8 0→1.
  Total 8 → 15/50.
- Iter-2 LEDGER correction: iter-2 should have been 10/50 not 8/50 — I had
  read STAGES.md's 6-gate completion bar instead of RUBRIC.md's 3-gate scoring
  bar. Logged in iter-003 LEDGER entry.
- Commit: chore(originals): iter 003 — BUILD — ice pass-through decision +
  Eagle entity + 35-stage fortress survey.
- Iter 4 wakeup scheduled.
```

```
Iter 002 BUILD/CAPABILITY complete (2026-05-15).

- Pre-mortem opened with Nat-13 generalization-clause cure (4 deliberate test stages).
- tools/refs/: 4 StrategyWiki PNGs cached (stages 1/4/7/17).
- tools/png_diff.py: PIL tile-classifier; auto-detect palette (NES vs tanke);
  triple-diff mode with --ascii-source; exit codes 0 / 1 / 2.
- Makefile: NEW screenshot-og STAGE=K and png-diff-og STAGE=K targets.
- 4-stage generalization: stages 1/4/7 at 0.299–0.448% (all <5%); stage 17 at
  32.239% (expected — 206 ice→empty matches loader's known ice-skip).
- Self-diff sanity baselines: both 0.0% mismatch.
- Edge-case handling: missing reference, unsupported size — both exit 2.
- Verification: procedural hash anchor 23d6a2ec… preserved; make test exit 0.
- Scores: C1=4 [STRUCTURE], C4=3 [STRUCTURE] (lift +3), C10=1 [STRUCTURE-DEFERRED];
  total 8/50.
- Commit: chore(originals): iter 002 — BUILD/CAPABILITY — png_diff oracle +
  4-stage generalization.
- Iter 3 wakeup scheduled.
```

---

## Stale Scores

None (new arc).

---

## Next Action

```
Iter 4 — IMPORT (first true stage-import iter):
  - Step 1: PRE-MORTEM (iter-004 block; generalization clause = all 11 remaining
            first-third stages must pass PNG-diff <5% with current loader).
  - Step 2: DIAGNOSE — criterion 7 at 2 (3 stages); fastest unblock to 5 is to
            PNG-diff all 12 first-third stages. Criterion 4 also lifts to 4
            (anchor 4: "every IMPORT iter cites result"). Optionally also
            criterion 5 sub-research into Tanks/src/ for enemy roster (gate 6).
  - Step 3: SELECT MODE — IMPORT (sub-mode of BUILD; PROMPT defines as
            "iter targets 2-5 stages, runs PNG-diff oracle, updates STAGES.md").
            Iter 4 will exceed the 2-5 stage minimum — extending to all 12
            in the first third because the loader already handles all of them.
  - Step 4: ACT:
      1. Fetch StrategyWiki references for stages 2, 3, 5, 6, 8, 9, 10, 11, 12.
      2. Batch render stages 2-12 via `make screenshot-og STAGE=K` loop.
      3. Batch run `make png-diff-og STAGE=K` against each; collect mismatch %.
      4. Update STAGES.md checkmarks for any stage that passes <5%.
      5. (Stretch) Begin enemy-roster mining: grep .research/repos/Tanks/src/
         for per-stage spawn data; cite file:line in LEDGER.
  - Step 5: SCORE — C4 → 4 (first IMPORT iter cites result inline);
            C7 → 4 or 5 (depending on per-stage pass rate); C5 → 1 if
            roster-mining sub-research lands.
  - Step 6: COMMIT — chore(originals): iter 004 — IMPORT — first-third PNG-diff sweep
  - Step 7: SCHEDULE — 240s wakeup for iter 5 (likely middle-third sweep
            OR mode-selection scene work if first PLAYTEST gate is needed)
```

---

## User-Look Gates

Per PROMPT user-look protocol:
- **Iter 1 (or first iter where stage 1 loads)**: mandatory PLAYTEST
- **Every 5 stages imported**: PLAYTEST checkpoint
- **End-to-end mode iter**: full PLAYTEST
- **Halt rule**: 3 consecutive unfulfilled PLAYTEST requests → `HALTED.md`

Sprint authorization (arc-2 carry): user may override cadence.

---

## Consult Log

None. First consult: ~iter 10.

---

## Pre-mortems

`loop/originals/PRE-MORTEMS.md` — append-only per-iter predictions.
H2 RULE v2 active (carried from arc 2): STRUCTURE / FEEL / MIXED /
STRUCTURE-DEFERRED tags mandatory on every score-lift citation.

---

## Falsifications

`loop/originals/FALSIFICATIONS.md` — F-numbered falsifications.
Arc-3 will likely produce many per-stage diffs that fail initially —
each F-number is a specific stage + coord + expected-vs-actual.
