# Breach loop state (arc 4)

```yaml
phase: loop
iter: 0
preloop_complete: yes
substrate_baseline_verified: yes
hash_anchor_at_iter_0: 23d6a2ec3bf2821f  # seed 42, default procedural config
current_round: 1-pending
current_round_phase: between-rounds  # SPIKE round 1 fires iter 1
next_action: iter 1 — SPIKE mode-integration path A (default-on breach_mode_enabled flag) vs path B (sibling BreachLevel.tscn)
```

---

## Preloop checklist

Loop halts if any unchecked when iter > 0:

- [x] Read `loop/META-RETRO.md` (arc 1 close) — 50/55, 1.78 pts/iter, engine substrate
- [x] Read `loop/gameplay/META-RETRO-iter100.md` (arc 2 close) — 34/50, identity-not-mechanics lesson
- [x] Read `loop/originals/iter027-meta-arc3-ceiling.md` (arc 3 close) — 51/60, structural ceiling
- [x] Read `loop/session-learnings-2026-05-18.md` (L1 SPIKE / L2 blueprint / L3 BUILD-QUALITY / L4 ceiling-paused / L5 default-on gating / L6 AUDIT trigger taxonomy; R1 bundled-anchor / R2 IDENTITY-PROTECTED / R3 three-tier ceiling / R4 quality-iter signal)
- [x] Read `.research/synthesis-arc4-creative-consult-2026-05-19.md` — "breach economy" stone, 7 constraints, sentence test
- [x] Verify `make test` exits 0
- [x] Verify procedural mode loads + `playable: true` (reachable=676 cells, seed 42)
- [x] Verify OG mode: `check-loader` PASS + `check-chain` reports `CHAIN_25_OK`
- [x] Verify hash anchor `23d6a2ec3bf2821f…` on procedural baseline (seed 42, default config)
- [x] `preloop_complete: yes` flipped

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
- 2026-05-19 — PROMPT v1 reframed: non-stop loop, REVIEW-QUEUE pattern,
  SPIKE → DECISION → BUILD×N → CONSULT → QUEUE → bootstrap-next cadence.
- 2026-05-19 — **iter 0 (this entry).** Preloop reads + substrate verify
  complete. Machinery files scaffolded (LEDGER, PRE-MORTEMS, REVIEW-QUEUE,
  FALSIFICATIONS, creative-consults). `preloop_complete: yes`.
  `tile_hash[:16]=23d6a2ec3bf2821f` confirmed on seed 42 / default
  procedural config. OG `check-chain` 25 stages PASS.

## Next action

**Iter 1 — SPIKE.** Two parallel investigations of the mode-integration fork
(PROMPT §SUBSTRATE FREEZE: "Mode integration — iter 1 DECISION, gated"):

- **Path A spike:** Add `@export var breach_mode_enabled: bool = false`
  to `ProceduralLevel.gd` behind the default-on gating template (L5 +
  PATTERN 2). Probe: is the surface large enough to fit
  Depot/Shell/Loadout hooks without snowballing PlayerTank / Spawner /
  Bullet writes beyond the sanctioned set? Hash-anchor verify post-edit
  on flag-off codepath.
- **Path B spike:** Sketch `scenes/BreachLevel.tscn` as a sibling. Probe:
  how much ProceduralStep wiring duplicates? Does it cleanly avoid an H1
  surface multiplication?

SPIKE outputs a DECISION (iter 2) with a winning blueprint stashed at
`loop/breach/iter-001-NNN-architect.md` (L2 compaction discipline).

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
