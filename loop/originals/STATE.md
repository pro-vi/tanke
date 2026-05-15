# tanke — Originals Loop State (arc 3)

## Phase

```
phase: loop
iteration: 2 (BUILD/CAPABILITY png_diff oracle — complete; iter 3 scheduled)
arc: 3 (Originals — BC NES stages import)
loop_type: frontier-loop with /story-loop per-stage verification
preloop_complete: yes
score: 8/50  (C1=4, C4=3, C10=1 — all [STRUCTURE] or [STRUCTURE-DEFERRED])
```

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

## Current Scores (post iter 001)

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Loader correctness | **4** | All 35 stages parse exact (iter 001); anchor 5 awaits `make test` coverage of edge cases |
| 2. Eagle gameplay | 0 | No Eagle.gd / Eagle.tscn |
| 3. Ice physics | 0 | Loader skips `-` silently; phase-1 decision iter still pending |
| 4. PNG-diff oracle | **3** | Tool exists; auto-detects palette; tested on stages 1/4/7/17 (anchor 3 — per-stage report + per-coord mismatch + confusion matrix); anchor 4 awaits first IMPORT iter |
| 5. Enemy roster fidelity | 0 | Per-stage data not extracted from Tanks src |
| 6. Mode selection | 0 | No title/picker scene |
| 7. Stages 1-12 complete | 0 | Gates 1+2+3 ✓ all 12; gate 5 ✓ stages 1/4/7 (iter 002); full-completion still blocked by gates 4 (eagle) + 6 (roster) |
| 8. Stages 13-24 complete | 0 | Gates 1+2+3 ✓ all 12; gate 5 ✗ stage 17 (ice-skip); gates 4/6 pending |
| 9. Stages 25-35 complete | 0 | Gates 1+2+3 ✓ all 11; PNG-diff not yet run on this third; gates 4/6 pending |
| 10. End-to-end playable | **1** | Stage 1 loads headless [STRUCTURE-DEFERRED]; "plays" awaits PLAYTEST |
| **Total** | **5/50** | iter 001 baseline |

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
Iter 3 — BUILD (phase-1 ice decision + eagle entity):
  - Step 1: PRE-MORTEM (iter-003 block with generalization clause for eagle
            placement: per-stage eagle coord derivation from #..# brick fortress
            pattern across stages 1, 4, 35 — vary stage to verify the rule).
  - Step 2: DIAGNOSE — weakest axis joint:
            (a) criterion 3 (ice physics) at 0 — iter-2 PNG-diff made the
                ice gap concrete (206 cells dominate stage-17 mismatch)
            (b) criterion 2 (eagle gameplay) at 0 — unblocks stage gate 4
                and is the BC identity anchor (PROMPT anti-pattern: defer eagle).
  - Step 3: SELECT MODE — BUILD (with explicit ice-decision sub-step;
            no CAPABILITY new tooling unless eagle exposes a need).
  - Step 4: ACT:
      1. ICE DECISION: recommend pass-through for v1 (criterion 3 cap = 2/5).
         Document the decision; extend LevelLoader to set_cell on a new
         IceTileMapLayer (decorative, no collision); add Ice TileMapLayer to
         OriginalLevel.tscn. Re-render stage 17, re-diff — should drop to <5%.
      2. EAGLE ENTITY: scripts/Eagle.gd (HP=1, eagle_destroyed signal);
         scenes/Eagle.tscn (16×16 sprite, StaticBody2D for bullet collision).
         Position from per-stage canonical coord: detect the #..# fortress
         row in the parsed grid; place eagle at the empty cells inside.
         GENERALIZATION CHECK: verify on stages 1 + 4 + 35 (eagle position is
         canonical in BC; same fortress shape used across all stages).
      3. PNG-diff re-run on stages 1, 4, 7, 17 after both changes — should
         remain <5% (or stage 17 should DROP to <5% after ice-rendering lands).
  - Step 5: SCORE — Criterion 3 → 1 or 2 (decision iter); criterion 2 → 2 or 3
            (eagle code-cited; "feels like BC eagle" needs PLAYTEST for higher);
            criterion 4 → 4 (first IMPORT-style iter that runs png-diff-og and
            cites result inline; anchor 4 demonstration).
  - Step 6: COMMIT — chore(originals): iter 003 — BUILD — ice decision (pass-through) + Eagle entity
  - Step 7: SCHEDULE — 240s wakeup for iter 4 (likely first true IMPORT iter)
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
