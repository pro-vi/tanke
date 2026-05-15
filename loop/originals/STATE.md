# tanke — Originals Loop State (arc 3)

## Phase

```
phase: preloop
iteration: 0
arc: 3 (Originals — BC NES stages import)
loop_type: frontier-loop with /story-loop per-stage verification
preloop_complete: no
score: 0/50
```

---

## Preloop Checklist

```
[ ] Read loop/META-RETRO.md (arc 1, engine retro)
[ ] Read loop/gameplay/META-RETRO-iter100.md (arc 2, gameplay retro)
[ ] Read .research/synthesis-bc-level-sources-2026-05-13.md (arc-3 research)
[ ] Verify .research/repos/Tanks/resources/stages/1 exists and matches synthesis sample
[ ] Verify `make test` exit 0 (arc-2 procedural baseline still works)
[ ] Confirm arc-2 hash anchor (current iter-100 baseline) holds — record for cross-arc invariant
[ ] Flip preloop_complete: yes
```

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

## Current Scores (set at iter 1+ after BOOTSTRAP)

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Loader correctness | 0 | LevelLoader.gd doesn't exist |
| 2. Eagle gameplay | 0 | No Eagle.gd / Eagle.tscn |
| 3. Ice physics | 0 | `-` symbol unhandled |
| 4. PNG-diff oracle | 0 | tools/png_diff.py doesn't exist |
| 5. Enemy roster fidelity | 0 | Per-stage data not extracted from Tanks src |
| 6. Mode selection | 0 | No title/picker scene |
| 7. Stages 1-12 complete | 0 | 0/12 |
| 8. Stages 13-24 complete | 0 | 0/12 |
| 9. Stages 25-35 complete | 0 | 0/11 |
| 10. End-to-end playable | 0 | No OriginalLevel.tscn |
| **Total** | **0/50** | Floor |

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
Loop scaffolding written. PROMPT.md / RUBRIC.md / STATE.md / STAGES.md
/ README.md / ACCEPTANCE-TEMPLATE.md created. Substrate frozen across
3 layers. Research source cloned + synthesized.

Next: iter 0 BOOTSTRAP — verify preloop checklist, commit, schedule iter 1.
```

---

## Stale Scores

None (new arc).

---

## Next Action

```
Iter 0 BOOTSTRAP:
  - Read both prior retros + arc-3 synthesis (per preloop checklist)
  - Verify .research/repos/Tanks/resources/stages/1 matches synthesis sample
  - Verify make test exit 0 (arc-2 baseline intact)
  - Record arc-2 hash anchor in LEDGER for cross-arc regression detection
  - Flip preloop_complete: yes
  - Commit "chore(originals): iter 000 — BOOTSTRAP — substrate verified, sources confirmed"
  - Schedule iter 1: BUILD — LevelLoader.gd skeleton + OriginalLevel.tscn skeleton + test_runner flags
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
