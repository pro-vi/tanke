# Breach loop state (arc 4)

```yaml
phase: running
iter: 35
preloop_complete: yes
substrate_baseline_verified: yes
hash_anchor_at_iter_0: 23d6a2ec3bf2821f  # seed 42, default procedural config
hash_anchor_at_iter_35: 23d6a2ec3bf2821f  # bit-identical through 19 substrate writes
substrate_writes_this_arc: 19  # ProceduralLevel.gd ×4 + Bullet.gd ×5 + PlayerTank.gd ×8 + Level.gd + Spawner.gd ×2
current_round: 5-open
current_round_phase: BUILD — Round 5 piece 3 (shell codex/tutorial); blueprint iter-033-round5-architect.md
consult_001_status: adopted
consult_002_status: adopted
build_quality_iters: [10, 24, 29, 30]  # 29+30 back-to-back = the ceiling signal (see iter-30 LEDGER)
falsifications: [F001-resolved, F002-resolved, F003-open]
reachability_status: all 5 bands verified — 9/10-seed sweep (90%, floor ≥80%)
audit_candidates: []
last_audit: iter 26
last_consult: iter 21
playtest_log: [iter 33 — 2026-05-20 — verdict: structurally complete but illegible; F003 logged]
structural_ceiling: RE-OPENED at iter 33. The iter-32 "30/50 ceiling" assumed harness-green structure would read as breach economy; the iter-33 playtest falsified that (F003). Real work exists above 30/50 — Round 5 (legibility), then Round 6+ (roguelite feel).
loop_state: RUNNING (resumed iter 33). User playtested 2026-05-20; the loop integrated the verdict, logged F003, opened Round 5. The non-stop loop continues per PROMPT until the user writes `playtest` / `halt` / `stop`.
next_action: iter 36 — BUILD — Round 5 piece 3: shell codex / tutorial layer. Read iter-033-round5-architect.md. Constraint 1 (no combat-time reading): the explanation lives at a safe gate — a one-time intro overlay before band 1 + a codex section in the depot UI. Each shell: icon + one-line "use when…" from the grammar table. Answers playtest findings 2-3 (no tutorial; illegible roles).
score: 30/50 absolute · 30/50 effective  # C1=3,C2=3,C3=4,C4=3,C5=2,C6=3,C7=3,C8=3,C9=2,C10=4
spike_report: loop/breach/iter-001-spike-report.md
round5_blueprint: loop/breach/iter-033-round5-architect.md
new_harness_targets: check-breach-{config,shells,depot,he-blast,loadout,depot-choice,level,harness,recap,enemies,assets,armor,dividend,swap,overdrive,hud,apcr} + check-silhouette-gate (18 in test-breach aggregate)
review_queue_open: [#1 round-1 scaffolding, #2 round-2 atomic verb, #4 round-3 + ceiling, #5 playtest verdict + Round 5 launch]  # #3 CLOSED — playtest delivered 2026-05-20
```

---

## Arc-4 amendments (user overrides — recorded iter 33)

The user has override authority over cadence and direction (PROMPT
§USER-LOOK PROTOCOL). Recorded amendments:

- **2026-05-20, playtest (iter 33):** PROMPT CONSULT constraint 2
  ("no more than three primary shell classes at first — AP/HE/HEAT")
  is **overridden**. APCR is sanctioned as the 4th shell class. Each
  shell must still keep one crisp, distinct job (constraint 3 stands):
  AP cheap/precise, HE brick-zone breacher, HEAT 2× anti-armor burst,
  APCR steel-terrain breacher + armor-piercing at 1× damage.
- **2026-05-20, playtest (iter 33):** the loop's mandate is extended
  past structural completeness — the user wants all four roguelite
  ingredients (run-to-run variety, build divergence, stakes &
  escalation, meta-progression). This is the Round 6+ program; see the
  blueprint tail in `iter-033-round5-architect.md`.

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

- 2026-05-20 — **iter 35 (BUILD-QUALITY).** Round 5 piece 2 — the
  4-slot shell panel (ShellPanel: AP/HE/HEAT/APCR, colour chip + name +
  reserve, selection highlight) + the gen_shell_apcr icon (silhouette
  gate passes 4 assets). PlayerTank HUD substrate write; hash anchor
  preserved; test-all 5/5, test-breach 18/18. Δ 0 — legibility craft.
  In-flight shape-diff deferred (unverifiable headless — F003). 30/50.

## Next action

**Iter 36 — BUILD — Round 5 piece 3: shell codex / tutorial.**
Read `loop/breach/iter-033-round5-architect.md`. Constraint 1 (no
combat-time reading): the explanation lives at a safe gate — a one-time
intro overlay before band 1 + a codex section in the depot UI. Each
shell: icon/chip + one-line "use when…" from the grammar table (AP
cheap, HE brick walls, HEAT armored heavies, APCR steel walls).
Answers playtest findings 2-3 (no tutorial; illegible roles).

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires (hash anchor break, test-all
regression, unsanctioned substrate write, unfixed band reachability).

---

## Compaction notes (carry across sessions)

If a future session needs to pick up arc 4:
1. Read this file for phase + last action + next action
2. Read `loop/breach/PROMPT.md` for full protocol
3. Read `loop/breach/LEDGER.md` for iter history
4. Read `loop/breach/REVIEW-QUEUE.md` for pending user decisions
5. Read most recent `loop/breach/iter-NNN-MMM-architect.md` for active blueprint
6. Read `loop/breach/FALSIFICATIONS.md` for known traps
