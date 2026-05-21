# Breach loop state (arc 4)

```yaml
phase: running
iter: 54
preloop_complete: yes
substrate_baseline_verified: yes
hash_anchor_at_iter_0: 23d6a2ec3bf2821f  # seed 42, default procedural config
hash_anchor_at_iter_52: 23d6a2ec3bf2821f  # bit-identical through 30 substrate writes
substrate_writes_this_arc: 30  # ProceduralLevel.gd ×5 + Bullet.gd ×8 + PlayerTank.gd ×15 + Level.gd + Spawner.gd ×2
current_round: 7-closed
current_round_phase: Round 7 CLOSED; iter-54 SWEEP verified the build coherent (12/12 reachability). At the playtest-gated ceiling — idle heartbeat until REVIEW-QUEUE #9 playtest
consult_001_status: adopted
consult_002_status: adopted
build_quality_iters: [10, 24, 29, 30]  # 29+30 back-to-back = the ceiling signal (see iter-30 LEDGER)
falsifications: [F001-resolved, F002-resolved, F003-open, F004-resolved]
reachability_status: all 5 bands verified — 12/12-seed sweep (100%, floor ≥80%) — refreshed iter 54 post-Round-7
audit_candidates: []
last_audit: iter 26
last_consult: iter 53  # CONSULT 005 — written self-pre-mortem, Round 7 close
playtest_log: [iter 33 — 2026-05-20 — verdict: structurally complete but illegible; F003 logged]
structural_ceiling: Rounds 5-6 lifted 30/50 → 39/65 (RUBRIC extended +C11/C12/C13 for the roguelite axes). The structural tier is now at its honest ceiling — the remaining ~26 points are [FEEL]/playtest-gated, and the remaining structural surfaces are substrate-blocked (C5) or unrequested scope (CONSULT 004).
loop_state: RUNNING (idle heartbeat) — Round 7 closed at iter 53; iter-54 SWEEP verified the post-Round-7 build coherent (12/12 reachability, 25 breach + 5 arc-3 harnesses, hash anchor intact). The loop is at the playtest-gated autonomous ceiling (CONSULT 004/005): all remaining rubric value is [FEEL]-gated, and building more before a playtest is the documented seductive-but-hollow anti-pattern. With no honest non-speculative work left, the loop slows to a long idle heartbeat (1800s) — still non-stop (scheduled, not halted), resuming on the user's playtest or a manual /loop. REVIEW-QUEUE #9 requests the Round-7 playtest.
next_action: iter 55 — re-assess at the playtest-gated ceiling. If the user has playtested (REVIEW-QUEUE #9), integrate the findings + open Round 8. If not: the build is verified coherent (iter-54 SWEEP) and there is no non-speculative autonomous work left — re-confirm green state, re-surface the #9 playtest ask, and continue the idle heartbeat. Do NOT open a speculative new mechanic round ahead of the playtest (CONSULT 005 Q3 — "legibility theater" / arc-2's "structure since the last human signal").
score: 39/65 absolute · 39/65 effective  # C1=3,C2=3,C3=4,C4=3,C5=2,C6=3,C7=3,C8=3,C9=2,C10=4,C11=3,C12=3,C13=3
spike_report: loop/breach/iter-001-spike-report.md
round5_blueprint: loop/breach/iter-033-round5-architect.md
round6_blueprint: loop/breach/iter-038-round6-architect.md
round6e_blueprint: loop/breach/iter-043-round6e-architect.md
round7_blueprint: loop/breach/iter-047-round7-architect.md
new_harness_targets: check-breach-{config,shells,depot,he-blast,loadout,depot-choice,level,harness,recap,enemies,assets,armor,dividend,swap,overdrive,hud,apcr,codex,shuffle,depot-roll,rulechangers,stakes,meta,route} + check-silhouette-gate (25 in test-breach aggregate)
review_queue_open: [#1 round-1 scaffolding, #2 round-2 atomic verb, #4 round-3 + ceiling, #5 playtest verdict + Round 5 launch, #6 Round 5 close, #8 playtest verdict + Round 7 launch, #9 PLAYTEST REQUEST — Round 7 complete]  # #3, #7 CLOSED — playtests delivered
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
- **2026-05-20, playtest (iter 47):** APCR's steel behaviour is
  redesigned per the user — APCR PENETRATES steel (drills through,
  breaking 1 block per hit, like AP on brick; no radius cluster); the
  bullet continues until its lifetime ends. Supersedes the iter-34
  radius-breach design.

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

- 2026-05-20 — **iter 54 (SWEEP).** Post-Round-7 verification grid,
  all green: reachability 12/12 seeds × 5 bands (100%, up from the
  iter-26 90% baseline); test-breach 25/25; test-all 5/5; hash anchor
  23d6a2ec3bf2821f. The post-Round-7 build is verified coherent. No
  code touched. Δ 0. 39/65. With the build verified and no honest
  non-speculative work left, the loop slows to a 1800s idle heartbeat
  — still non-stop, awaiting the REVIEW-QUEUE #9 playtest.

## Next action

**Iter 55 — re-assess at the playtest-gated ceiling.**
iter-54 SWEEP verified the post-Round-7 build coherent (12/12
reachability, 25 breach + 5 arc-3 harnesses, hash anchor). The loop
is at the autonomous ceiling — 39/65, all remaining value [FEEL]-
gated. If the user has playtested (REVIEW-QUEUE #9), integrate the
findings + open Round 8. If not: re-confirm green, re-surface the #9
playtest ask, hold the idle heartbeat. Do NOT open a speculative new
mechanic round ahead of the playtest (CONSULT 005 Q3).

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires (hash anchor break, test-all
regression, unsanctioned substrate write, unfixed band reachability).
At the playtest-gated ceiling it idles at a long heartbeat rather
than spin Δ-0 iters — it has not halted.

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires (hash anchor break, test-all
regression, unsanctioned substrate write, unfixed band reachability).

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
