# tanke — Originals Loop State (arc 3)

## Phase

```
phase: loop
iteration: 1 (BUILD/CAPABILITY scaffolding — complete; iter 2 scheduled)
arc: 3 (Originals — BC NES stages import)
loop_type: frontier-loop with /story-loop per-stage verification
preloop_complete: yes
score: 5/50  (C1=4 [STRUCTURE], C10=1 [STRUCTURE-DEFERRED])
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
| 4. PNG-diff oracle | 0 | tools/png_diff.py doesn't exist |
| 5. Enemy roster fidelity | 0 | Per-stage data not extracted from Tanks src |
| 6. Mode selection | 0 | No title/picker scene |
| 7. Stages 1-12 complete | 0 | Gates 1+2+3 ✓ for all 12; PNG-diff floor blocks score lift |
| 8. Stages 13-24 complete | 0 | Gates 1+2+3 ✓ for all 12; PNG-diff floor blocks score lift |
| 9. Stages 25-35 complete | 0 | Gates 1+2+3 ✓ for all 11; PNG-diff floor blocks score lift |
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
Iter 001 BUILD/CAPABILITY complete (2026-05-15).

- Pre-mortem filed with 4 [STRUCTURE] failure modes; none fired.
- LevelLoader.gd: static parse_stage; OS-layer FileAccess (bypasses res-filter).
- OriginalLevel.gd: extends Level.gd; inherits _replace_blocks() (H1 respected).
- OriginalLevel.tscn: parallel to ProceduralLevel.tscn; 4 TileMapLayers, no Spawner.
- test_runner.gd: EXTENDED with --scene PATH and --og-stage K flags + defensive
  ps/level_seed lookups for OG scene; procedural code path untouched.
- Verification: procedural hash anchor 23d6a2ec… preserved exactly; make test exit 0.
- Verification: 35/35 stages parse with exact per-cell terrain match against
  grep -o counts on source; all 35 playable=true. Four stages have ice (skipped).
- Scores: C1=4 [STRUCTURE], C10=1 [STRUCTURE-DEFERRED]; total 5/50.
- Commit: chore(originals): iter 001 — BUILD/CAPABILITY — LevelLoader +
  OriginalLevel + test_runner --scene/--og-stage.
- Iter 2 wakeup scheduled.
```

---

## Stale Scores

None (new arc).

---

## Next Action

```
Iter 2 — BUILD / CAPABILITY (PNG-diff oracle + eagle scaffolding):
  - Step 1: PRE-MORTEM (append iter-002 block to PRE-MORTEMS.md; H2 RULE v2 tags)
  - Step 2: DIAGNOSE — weakest axis = criterion 4 (PNG-diff oracle) at 0;
              criteria 7/8/9 floor-blocked until 4 ≥ 2.  Also weak: criterion 2 (eagle).
  - Step 3: SELECT MODE — BUILD with CAPABILITY focus.
  - Step 4: ACT — build in this order:
      1. tools/png_diff.py: PIL pipeline that reads a 208×208 reference PNG,
         classifies each 16×16 tile to one of {empty, brick, steel, forest, water, ice},
         compares to our rendered stage. Iter-2 minimum: runs on stage 1 + reports
         per-tile mismatch %. Downloads StrategyWiki Battle_City_Stage01.png to
         tools/refs/ (gitignored or .research-aligned).
      2. Headless render of OriginalLevel stage 1 → PNG (existing screenshot path
         repurposed, or new make target). Compare to reference.
      3. (Stretch) scripts/Eagle.gd + scenes/Eagle.tscn skeleton — HP=1,
         eagle_destroyed signal. Placement deferred to iter 3 (per-stage eagle coords).
  - Step 5: SCORE — Criterion 4 lift (anchor 1 minimum; anchor 2 if accuracy
              hand-verified). Criteria 7/8/9 STILL 0 until per-stage PNG diff < 5%.
  - Step 6: COMMIT — chore(originals): iter 002 — BUILD/CAPABILITY — png_diff oracle + (eagle skeleton)
  - Step 7: SCHEDULE — 240s wakeup for iter 3
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
