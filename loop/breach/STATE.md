# Breach loop state (arc 4)

```yaml
phase: preloop
iter: 0
preloop_complete: no
substrate_baseline_verified: no
hash_anchor_at_iter_0: pending
current_round: none
current_round_phase: none  # SPIKE / DECISION / BUILD / CONSULT / between-rounds
next_action: loop diagnoses each iter; no pre-allocated trajectory
```

---

## Preloop checklist

Loop halts if any unchecked when iter > 0:

- [ ] Read `loop/META-RETRO.md` (arc 1 close)
- [ ] Read `loop/gameplay/META-RETRO-iter100.md` (arc 2 close)
- [ ] Read `loop/originals/iter027-meta-arc3-ceiling.md` (arc 3 close)
- [ ] Read `loop/session-learnings-2026-05-18.md` (cross-arc lessons L1-L6 + R1-R4)
- [ ] Read `.research/synthesis-arc4-creative-consult-2026-05-19.md` (THE CONSULT — design substrate)
- [ ] Verify `make test` exits 0
- [ ] Verify procedural mode (`scenes/ProceduralLevel.tscn`) loads + reachability passes
- [ ] Verify OG mode (`scenes/OriginalLevel.tscn`) loads + at least Stage 1 plays
- [ ] Verify cross-arc hash anchor `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` on procedural baseline (seed 42)
- [ ] Flip `preloop_complete: yes` here

---

## Substrate layers (do not modify without default-on gating + hash verification)

- Layer 1: engine (arc 1) — `LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`, `ProceduralStep.gd`, `ProceduralLevel.gd`, `tools/gen_tile.py` (extendable), `tools/analyze_frame.py`, `loop/test_runner.gd` (extendable)
- Layer 2: gameplay (arc 2) — `Bullet.gd`, `Enemy*.gd`, `Spawner.gd`, `PlayerTank.gd`, `BrickBlock.gd`, `configs/playable.tres`
- Layer 3: originals (arc 3) — `LevelLoader.gd`, `Eagle.gd`, `StageDirector.gd`, `Roster.gd`, `OriginalLevel.tscn`, `Eagle.tscn`, `TitleScreen.tscn`, `configs/stages/*.tres`, `tools/{png_diff,og_metrics,band_check}.py`
- Layer 4: BC source (read-only) — `.research/repos/Tanks/`, all `.research/synthesis-*.md`

---

## Arc-4 stone (from CONSULT §9)

> Battle City as a vertical breach roguelite: a single-life tank climbs
> through fortified depth bands by managing shells, terrain destruction,
> and depot-based upgrades.

## Identity anchor

**Breach economy.** *What are you willing to spend to open the next vertical lane?*

## Sentence test (every upgrade must pass)

*"This upgrade helps me climb through ___ by changing how I use ___."*

---

## Score (at iter 0)

Not yet scored. All 10 criteria at 0/5. Absolute ceiling: 50.

---

## Last action

- 2026-05-19 — Scaffolding written (PROMPT, RUBRIC, STATE, BANDS, README).
  CONSULT captured to `.research/synthesis-arc4-creative-consult-2026-05-19.md`.
  Self-pre-mortem on breach economy completed inline (7 critiques surfaced;
  4 codified as PROMPT anti-patterns).
- 2026-05-19 — PROMPT v1 reframed: removed iter-prescription, ceiling-stop,
  HALTED conditions on score plateau. Loop is now non-stop until user
  writes `playtest`. Macro cadence: SPIKE → DECISION → BUILD×N → CONSULT
  → QUEUE → bootstrap-next.

## Next action

The loop diagnoses each iter. No pre-allocated trajectory. First iter
likely: complete preloop reads + substrate verification + flip
`preloop_complete: yes` + open the first SPIKE round.

The only exits are user signal (`playtest` / `halt` / `stop`) and
correctness violations (hash anchor break, test-all regression, hard
substrate violation, band reachability failure not fixed same-iter).

---

## Compaction notes (carry across sessions)

If a future session needs to pick up arc 4:
1. Read this file for phase + last action + next action
2. Read `loop/breach/PROMPT.md` for full protocol
3. Read `loop/breach/LEDGER.md` for iter history
4. Read `loop/breach/REVIEW-QUEUE.md` for pending user decisions
5. Read most recent `loop/breach/iter-NNN-MMM-architect.md` for active blueprint
6. Read `loop/breach/FALSIFICATIONS.md` for known traps
