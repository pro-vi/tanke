# tanke — Originals Loop State (arc 3)

## Phase

```
phase: loop
iteration: 7 (BUILD StageDirector + spawn correction — complete; iter 8 scheduled)
arc: 3 (Originals — BC NES stages import)
loop_type: frontier-loop with /story-loop per-stage verification
preloop_complete: yes
score: 34/50  (C1=4, C2=3, C3=2, C4=4, C5=1, C6=3, C7=5, C8=5, C9=5, C10=2)
playtest_halt_counter: 1 of 3 (iter 6 opened gate; iter 7 first unfulfilled)
```

**PLAYTEST gate open, no user response yet. Halt-rule counter: 1/3.** Cumulative path: 5 → 10 → 15 → 20 → 29 → 33 → 34 (+1 in iter 7, C10 anchor-2 via StageDirector). Ceiling watch: 34/50 (would trigger at 35); iter 8 likely either PLAYTEST score-lift (if user responds) or AUDIT to resolve C5 rubric/data shape mismatch.

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

## Current Scores (post iter 007)

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Loader correctness | **4** | |
| 2. Eagle gameplay | **3** | Anchor 4 (feel-cited) awaits PLAYTEST |
| 3. Ice physics | **2** | Pass-through (rubric cap) |
| 4. PNG-diff oracle | **4** | |
| 5. Enemy roster fidelity | **1** | Anchor-2 letter unmet (no per-stage .tres); spirit exceeded (formula in Roster.gd covers all 35). **Rubric mismatch logged for iter-8 AUDIT** |
| 6. Mode selection | **3** | Anchor 4+5 await PLAYTEST |
| 7. Stages 1-12 complete | **5** | |
| 8. Stages 13-24 complete | **5** | |
| 9. Stages 25-35 complete | **5** | |
| 10. End-to-end playable | **2** | Anchor 2 ✓ — StageDirector + dev N-key advance code-cited. [STRUCTURE-DEFERRED] for natural clear-condition (Spawner integration iter 9+) |
| **Total** | **34/50** | post iter 007 |

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
Iter 007 BUILD alternate complete (2026-05-15).

- PLAYTEST gate open since iter 6; iter 7 = 1/3 unfulfilled.
- Pre-mortem with generalization clause on stage bookends (1, 18, 35).
- scripts/StageDirector.gd — current_stage tracker; advance/restart/goto;
  arc_complete signal on STAGE_MAX.
- scripts/Roster.gd — Tanks formula constants + armored_probability(stage)
  + is_armored_spawn(stage). Cites file:line; RUBRIC MISMATCH NOTE for
  iter-8 AUDIT (anchor 2 wants .tres encoding; BC roster is uniform formula).
- OriginalLevel.gd extended — instantiates StageDirector; dev N-key →
  _advance_to_next_stage sets TANKE_OG_STAGE env + reloads scene;
  arc_complete → ARC COMPLETE green overlay.
- OriginalLevel.tscn — PlayerTank (124, 220) → (124, 212), matches Tanks
  canonical (8, 24) tile coord per iter-4 cite.
- Verification: 4-stage re-diff post-spawn-fix all neutral-to-improved;
  Roster formula bookends match iter-4 (0.1000/0.2249/0.3499);
  procedural hash anchor 23d6a2ec… preserved; make test exit 0.
- Re-issued PLAYTEST request in closing message.
- Scores: C10 1→2. Total 33 → 34/50 (+1).
- Commit: chore(originals): iter 007 — BUILD — StageDirector + Roster +
  spawn correction.
- Iter 8 wakeup scheduled.
```

```
Iter 006 BUILD complete (2026-05-15).

- Pre-mortem with generalization clause = both modes launchable from one
  TitleScreen session. F1 cured by _launching latch. F5 cured by raw keycodes.
- scenes/TitleScreen.tscn + scripts/TitleScreen.gd — mode-picker with title,
  subtitle, 2 options (ORIGINALS, PROCEDURAL), yellow > cursor, hint text.
- project.godot run/main_scene → TitleScreen.tscn (pre-existing window-config
  diff stashed before edit, popped after commit; isolated).
- OriginalLevel.gd extended: _process polls game-over input (R / Esc);
  _show_game_over builds CanvasLayer with dim ColorRect + GAME OVER label +
  restart hint; _on_eagle_destroyed triggers the overlay.
- Verification: TitleScreen renders (78 bright pixels in title area);
  procedural hash anchor 23d6a2ec… preserved; make test exit 0;
  OriginalLevel still loads cleanly (brick=220 steel=8 playable=true).
- USER-LOOK gate: FIRST PLAYTEST REQUEST officially OPEN.
- Scores: C2 2→3, C6 0→3. Total 29 → 33/50 (+4).
- Commit: chore(originals): iter 006 — BUILD — TitleScreen mode-select +
  Eagle game-over.
- Stashed project.godot diff restored.
- Iter 7 wakeup scheduled — likely PLAYTEST request (AWAIT user response).
```

```
Iter 005 IMPORT complete (2026-05-15).

- Pre-mortem filed with explicit scope-overshoot disclosure (PROMPT says 2-5
  stages per IMPORT; iter 5 sweeps 22). F1 (per-stage terrain combo) fired
  on stage 32 — surfaced classifier palette-detector fragility (single-pixel
  sample false-classified ice-top-left stage as tanke palette).
- Fetched 22 new StrategyWiki references (stages 13-16, 18-24, 25-35).
- Rendered all 22 stages.
- First sweep: 34/35 pass; stage 32 at 79.254%.
- Mid-iter CAPABILITY fix to tools/png_diff.py: detect palette by image
  mode (P=NES, RGB=tanke) with multi-cell fallback for ambiguous RGB.
- Re-ran full 35-stage sweep: 35/35 PASS. Median 0.448%, max 2.090%.
  Stage 32 now at 1.493%.
- Verification: procedural hash anchor 23d6a2ec… preserved; make test exit 0.
- Scores: C8 1→5, C9 0→5. Total 20 → 29/50 (+9).
- Commit: chore(originals): iter 005 — IMPORT — 22-stage sweep + classifier
  palette-detector hardening.
- Iter 6 wakeup scheduled.
- CEILING WATCH: 29/50. Iter-6 mode-select + likely C2 lift may hit ≥35,
  triggering rubric audit per CEILING RULE.
```

```
Iter 004 IMPORT complete (2026-05-15).

- Pre-mortem filed; F3 pre-mitigated by 35-stage spawn-cell passability survey
  (zero conflicts at play-area cols 8-9 of row 25). F1/F2/F5 didn't fire.
- Fetched 9 new StrategyWiki references (stages 2, 3, 5, 6, 8, 9, 10, 11, 12).
- Rendered all 9 stages via make screenshot-og.
- Full 12-stage first-third PNG-diff sweep — all 12 pass <5% (median 0.448%,
  max 2.090% on stage 2, dominated by ref-PNG residual noise).
- Enemy-roster source mining: roster is FORMULA-driven, not table-driven.
  Cited in LEDGER: appconfig.h:79-81 (20 enemies, max 4 simul, 35 stages)
  + game.cpp:518 (p_armored = 0.00735 * stage + 0.09265 formula).
- Verification: procedural hash anchor 23d6a2ec… preserved; make test exit 0.
- Scores: C4 3→4, C5 0→1, C7 2→5. Total 15 → 20/50 (+5).
- Commit: chore(originals): iter 004 — IMPORT — first-third sweep (12/12) +
  enemy-roster source located.
- Iter 5 wakeup scheduled.
```

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
Iter 8 — branch by user availability:

  IF playtest response landed (gate fulfilled):
    Step 1: PRE-MORTEM (process feel-cites).
    Step 2: DIAGNOSE — C2/C6/C10 anchor-4 lifts possible.
    Step 3: SELECT MODE — PLAYTEST.
    Step 4: ACT — score feel-tagged anchors; cite user phrasing.
    Step 5: SCORE.  Likely +2-4 points → hits CEILING RULE → iter 9 = AUDIT.
    Step 6: COMMIT.
    Step 7: SCHEDULE — 240s.

  IF still no playtest response (halt counter → 2/3):
    Step 1: PRE-MORTEM (AUDIT pre-amble; surface 3 reframe candidates).
    Step 2: DIAGNOSE — rubric/data shape mismatches; ceiling proximity.
    Step 3: SELECT MODE — AUDIT.
    Step 4: ACT:
      - Re-score all 10 criteria with fresh evidence.
      - Resolve C5 anchor-2 rubric mismatch (rephrase or rename).
      - Check for other anchor wordings that don't fit BC's data shape.
      - Decide: add 2 new criteria (e.g., "identity test" + "arc-2 metric
        handshake") OR raise anchor 4/5 wordings.
    Step 5: SCORE — likely flat or small shift; AUDIT typically doesn't
            raise score unless it surfaces under-reported wins.
    Step 6: COMMIT — chore(originals): iter 008 — AUDIT — rubric reframe
    Step 7: SCHEDULE — 120s (AUDIT cadence per PROMPT).

  EITHER WAY: re-issue PLAYTEST request in iter-8 closing if gate still open.
```

```
Iter 7 — PLAYTEST request (USER-LOOK protocol — FIRST playtest):
  - Step 1: PRE-MORTEM (iter-007; predict which feel-cites land based on
            current artifact maturity).
  - Step 2: DIAGNOSE — weakest axes: C2 anchor 4 (eagle feels like BC's),
            C6 anchor 4 (mode-select intentional), C10 anchor 1 ("plays"
            half) — all awaiting feel-cites.
  - Step 3: SELECT MODE — PLAYTEST. Per PROMPT: "AWAIT user response (no
            scheduled retry)".
  - Step 4: ACT — issue the 2-question playtest prompt:
      Q1: "Does the TitleScreen feel intentional? Can you navigate to either
           mode without fumbling?"
      Q2: "Does Stage 1 look like Battle City Stage 1 — bilateral brick
           columns, steel-armored mid-corridor, eagle's brick fortress at
           bottom-center?"
            User runs godot --path . , uses TitleScreen, plays stage 1,
            reports findings.
  - Step 5: SCORE — only after playtest response received. Possible lifts:
            C2 → 4, C6 → 4, C10 → 2 (anchor 1 "plays" feel-cited).
  - Step 6: COMMIT (after score).
  - Step 7: SCHEDULE — PLAYTEST does NOT schedule retry. If user doesn't
            respond, iter 8/9 will fire halt-rule countdown.

CEILING WATCH: if iter 7 lifts to ≥35, iter 8 = AUDIT (add 2 criteria, raise
4/5 anchors, or RENAME via reframe). Likely candidates: identity/feel
criteria (does it feel like BC to a fan?), arc-3 → arc-2 metric handshake.

ALTERNATE (if user is not available for PLAYTEST in iter 7): iter 7 can
be a BUILD iter — roster encoding (criterion 5 → 2) and/or StageDirector
skeleton (criterion 10 → 2) — both progress without requiring playtest.
Then iter 8/9 retry the playtest gate before halt-rule fires.
```

```
Iter 6 — BUILD (mode selection scene + eagle game-over state):
  - Step 1: PRE-MORTEM (iter-006; generalization clause = mode-select must
            launch Procedural AND Original modes from the same input session).
  - Step 2: DIAGNOSE — weakest axes: C6 (mode selection) at 0 — blocks
            PLAYTEST gate; C2 (eagle) at 2 — anchor 3 (game-over state) lands
            with a minimal state machine.
  - Step 3: SELECT MODE — BUILD.
  - Step 4: ACT:
      1. scenes/TitleScreen.tscn + scripts/TitleScreen.gd — minimal:
         two labels "ORIGINAL" and "PROCEDURAL"; Up/Down to highlight,
         Enter to launch. Set project.godot run/main_scene to TitleScreen.
      2. Eagle game-over: OriginalLevel.gd _on_eagle_destroyed shows a
         "GAME OVER" overlay + accepts R to restart-to-title.
      3. (Stretch) StageDirector skeleton: track current_stage; on
         clear-condition, load next stage.
  - Step 5: SCORE — C6 → 2 or 3; C2 → 3; possibly C10 → 2 if linear advance
            code-cited.
  - Step 6: COMMIT — chore(originals): iter 006 — BUILD — mode select + eagle game-over
  - Step 7: SCHEDULE — 240s wakeup for iter 7 (likely first PLAYTEST OR
            ceiling-rule AUDIT if score ≥ 35).

NOTE (PROMPT carry): "Iter 1 (or first iter where mode-select + stage-1 load
works): PLAYTEST". Iter 7 will open the first PLAYTEST gate.
```

```
Iter 5 — IMPORT (middle + final third sweep) OR BUILD (mode selection):
  - Step 1: PRE-MORTEM — generalization clause = all 22 remaining stages
            (middle-third 13-16, 18-24 = 11; final-third 25-35 = 11) pass <5%.
  - Step 2: DIAGNOSE — weakest axes: C8 (1, can lift to 5 via sweep),
            C9 (0, can lift to 5 via sweep), C6 (mode-select) blocks PLAYTEST.
  - Step 3: SELECT MODE — choice between IMPORT (sweep remaining 22 stages,
            unlock C8+C9 to ~5 each) and BUILD (mode-selection scene,
            unlock first PLAYTEST gate).
            Recommendation: IMPORT (it's mechanical and finishes the
            terrain story); BUILD mode-select in iter 6 to unblock playtest.
  - Step 4: ACT (IMPORT path):
      1. Fetch 22 StrategyWiki references (stages 13-16, 18-24, 25-35).
      2. Batch render via make screenshot-og loop.
      3. Batch diff; collect pass-rates.
      4. Update STAGES.md.
  - Step 5: SCORE — C8 → ? (likely 5 if pattern holds), C9 → ? (similar);
            ceiling rule may fire (20 + 4 + 5 = 29; safe from 35 cap).
  - Step 6: COMMIT — chore(originals): iter 005 — IMPORT — middle+final sweep
  - Step 7: SCHEDULE — 240s wakeup for iter 6 (mode-selection BUILD)
```
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
