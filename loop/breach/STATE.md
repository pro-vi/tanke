# Breach loop state (arc 4)

```yaml
phase: running
iter: 82
preloop_complete: yes
substrate_baseline_verified: yes
hash_anchor_at_iter_0: 23d6a2ec3bf2821f  # seed 42, default procedural config
hash_anchor_at_iter_82: 23d6a2ec3bf2821f  # bit-identical through 43 substrate writes
substrate_writes_this_arc: 43  # ProceduralLevel.gd ×5 + Bullet.gd ×8 + PlayerTank.gd ×25 + Level.gd + Spawner.gd ×4 + Enemy.gd ×1
current_round: 11-open — Phase 1 band-shape recorder shipped iter 82 (collapsed heartbeat-#2 since user actively prompting); blueprint iter-080-round11-diagnose.md, default (a) chosen
current_round_phase: BUILD — Round 11 Phase 1 continuation iter 83 (band-shape ANALYZER + death-recap surfacing)
consult_001_status: adopted
consult_002_status: adopted
build_quality_iters: [10, 24, 29, 30]  # 29+30 back-to-back = the ceiling signal (see iter-30 LEDGER)
falsifications: [F001-resolved, F002-resolved, F003-open, F004-resolved]
reachability_status: all 5 bands verified — 12/12-seed sweep (100%, floor ≥80%) — refreshed iter 61 post-Round-8
audit_candidates: []
last_audit: iter 26
last_consult: iter 79  # CONSULT 009 — written self-pre-mortem, Round 10 close (band-shape blind spot named)
playtest_log: [iter 33 — 2026-05-20 — structurally complete but illegible, F003; iter 55 — 2026-05-21 — post-Round-7 — concept didn't land as roguelite, redirected to XP/level-ups + ammo drops → Round 8; iter 62 — 2026-05-22 — post-Round-8 — positive verdict but the tank primitive is too thin, redirected to TANK ARCHETYPES (Prism/Mortar/Ram) + enemy HP primitive + /agentify assets → Round 9]
structural_ceiling: Rounds 5-6 lifted 30/50 → 39/65 (RUBRIC extended +C11/C12/C13 for the roguelite axes). The structural tier is now at its honest ceiling — the remaining ~26 points are [FEEL]/playtest-gated, and the remaining structural surfaces are substrate-blocked (C5) or unrequested scope (CONSULT 004).
loop_state: RUNNING — Round 9 opened at iter 62. The user playtested Round 8 (positive — "getting to an interesting spot") and named the next bottleneck: the "tank that shoots discrete bullets" primitive is too thin. Via AskUserQuestion (override authority) the user chose the "Full archetype program" scope — Round 9 builds 4 mechanically-distinct tanks (Default + Prism + Mortar + Ram, Red Alert / Into-the-Breach inspired) + enemy HP primitive + HP bars + BOTH selection paths + asset visuals via /agentify image_gen. Two PROMPT overrides recorded in §Arc-4 amendments (Enemy.gd HUD writes sanctioned for HP-bar; /agentify image_gen sanctioned for assets). Blueprint iter-062-round9-architect.md. The non-stop loop builds Round 9 (9a-9h + close) until the user writes playtest / halt / stop.
next_action: iter 83 — BUILD — Round 11 Phase 1 continuation: band-shape ANALYZER + death-recap surfacing. Read iter-080-round11-diagnose.md. The iter-82 recorder captures per-band visit telemetry into RunRecap.band_visit_log. Iter 83 extends this with: (1) analyzer — given N RunRecap instances (one per archetype on the same seed/scenario), compute pairwise band-sequence distance + entry-time distance + total-run-ms distance; emit per-archetype run-shape signatures + a convergence verdict ("similar" / "distinct" per threshold) — analogous to iter-74 distinctness audit at the RUN scale. (2) surface the band-sequence in the death-screen recap visibly (one extra line in _death_label.text or a sibling label gated on run_recap != null). Hash-anchor verify; test-all + test-breach green.
score: 47/75 absolute · 47/75 effective  # C1=3,C2=3,C3=4,C4=3,C5=3,C6=3,C7=3,C8=3,C9=2,C10=4,C11=3,C12=3,C13=3,C14=3,C15=4 (iter 76 lifts C5 2→3 via PRESSURES.md canonical-answer doc)
spike_report: loop/breach/iter-001-spike-report.md
round5_blueprint: loop/breach/iter-033-round5-architect.md
round6_blueprint: loop/breach/iter-038-round6-architect.md
round6e_blueprint: loop/breach/iter-043-round6e-architect.md
round7_blueprint: loop/breach/iter-047-round7-architect.md
round8_blueprint: loop/breach/iter-055-round8-architect.md
round9_blueprint: loop/breach/iter-062-round9-architect.md
new_harness_targets: check-breach-{config,shells,depot,he-blast,loadout,depot-choice,level,harness,recap,enemies,assets,armor,dividend,swap,overdrive,hud,apcr,codex,shuffle,depot-roll,rulechangers,stakes,meta,route,xp,ammo,shield,hp,archetype,prism,mortar,ram,archetype-select,archetype-switch,distinctness-audit,pressure-probes,band-shape} + check-silhouette-gate (38 in test-breach aggregate)
review_queue_open: [#1 round-1 scaffolding, #2 round-2 atomic verb, #4 round-3 + ceiling, #5 playtest verdict + Round 5 launch, #6 Round 5 close, #8 playtest verdict + Round 7 launch, #10 playtest verdict + Round 8 launch, #12 playtest verdict + Round 9 launch, #13 archetype-sprite integration path (decision-needed), #14 ★ PLAYTEST REQUEST Round 9 complete (playtest gate), #15 archetypes-as-identities vs archetypes-as-weapons (design-direction question), #16 pressure matrix + distinctness audit (Round 10 internal)]  # #3, #7, #9, #11 CLOSED — playtests delivered
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
- **2026-05-21, playtest (iter 55):** the user playtested after Round
  7 and the breach-economy concept did not land as roguelite
  progression — "where is the roguelite element like level ups?" Via
  AskUserQuestion the user OVERRODE the arc-4 ANCHOR SENTENCE ("the
  tank is not becoming numerically stronger"): Round 8 adds a
  conventional roguelite power curve — XP level-ups with stat growth
  + a pick-1-of-3 upgrade card after every phase ("Both") — plus enemy
  ammo drops and longer shields. CONSULT constraint 7 ("verbs not
  passive stats") is relaxed for Round 8; constraint 1 (no choice in
  combat) is preserved. The breach economy (finite shells spent to
  breach) is KEPT as a layer, not removed. This is the Round 8
  program; blueprint iter-055-round8-architect.md.
- **2026-05-22, playtest (iter 62):** the user playtested Round 8 —
  positive verdict ("getting to an interesting spot"); the bottleneck
  is the "tank that shoots discrete bullets" primitive, too thin for
  the variety they want. Via AskUserQuestion the user redirected:
  Round 9 builds a TANK ARCHETYPE PROGRAM — 4 archetypes (Default +
  Prism + Mortar + Ram, each mechanically distinct per Into the
  Breach) + enemy HP primitive + HP bars + start-pick + event-unlock
  mid-run switching + visuals via /agentify image_gen. Two PROMPT
  overrides recorded: (a) Enemy.gd HUD writes are SANCTIONED for the
  HP-bar primitive (the Layer-2 substrate freeze relaxed for this
  HUD-only addition; hash trivially preserved); (b) /agentify
  image_gen for asset visuals is SANCTIONED, overriding the
  MLX-SD-style NO-GO (the PROMPT's intent was avoiding arc-1
  MLX-phantom-deps; /agentify is a different MCP channel under user
  control). Constraint 1 (no choice in combat) preserved; constraint
  4 (silhouette grammar) still gates generated assets. The breach
  economy + Round 8 systems STAY universal across archetypes. This
  is the Round 9 program; blueprint iter-062-round9-architect.md.

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

- 2026-05-23 — **iter 82 (BUILD).** Round 11 Phase 1 start:
  band-shape recorder. Collapsed iter-81's heartbeat-#2 into the
  BUILD path — user actively prompting. RunRecap.gd extended
  with `archetype` + `band_visit_log` fields + `enter_band()` +
  `band_signature()` + extended `format()`; PlayerTank.gd
  `_on_breach_band_changed` wired to call `run_recap.enter_band`
  (inside existing run_recap-null guard; no new gating). Harness
  verifies idempotency, order preservation, signature schema, and
  format() integration (8 in-harness checks). Substrate write ×25
  on PlayerTank.gd. Hash preserved; test-all 5/5; test-breach
  37 → 38. Δ 0. 47/75.
- 2026-05-23 — **iter 81 (META).** Idle heartbeat #1. No
  playtest signal at the 1800s wakeup. Extending cadence to
  3600s for iter 82 per the iter-54/61/72 reconciliation
  pattern. No work this iter — pure log + reschedule. Δ 0. 47/75.
- 2026-05-23 — **iter 80 (META).** Round 11 diagnose. Named 5
  candidates: (a) **band-shape recorder** (NEW DEFAULT —
  addresses CONSULT 009 blind spot; 3-5 iters), (b) enemy roster
  expansion (4 PRESSURES gaps), (c) armor-asymmetry resolution
  (design call), (d) identity-vs-weapons clarification (REVIEW-
  QUEUE #15 settles via playtest), (e) defer to playtest 5 (this
  iter's choice). Recommendation: (e). Loop enters idle heartbeat
  1800s. The iter-072 diagnose's "enemy roster" default is
  SUPERSEDED by (a) — CONSULT 009's correction. iter-080-round11-
  diagnose.md is the readable artifact. No substrate; hash
  preserved. Δ 0. 47/75.
- 2026-05-23 — **iter 79 (META).** Round 10-close. Three artifacts:
  (1) CONSULT 009 — written self-pre-mortem; key reframe is that
  Round 10's instrumentation is single-moment-strong but
  multi-band-blind — every artifact tests one moment, not a
  run-shape across 5 bands. The PLAYTEST-5-BRIEF mitigates
  cognitively; no harness measures run-shape distinctness yet.
  (2) REVIEW-QUEUE #14 upgrade — re-headed the ★ PLAYTEST REQUEST
  with pointers to PLAYTEST-5-BRIEF, the on-death overlay, and
  the open #15 / armor-asymmetry / band-shape-blind-spot
  questions. (3) RUBRIC reflection — no new criterion; C5 lift
  scored at iter 76. Round 10 carried 1 rubric anchor (46/75 →
  47/75). No substrate; hash preserved. Δ 0 at close. 47/75.
- 2026-05-23 — **iter 78 (BUILD).** Round 10 Phase 3: playtest
  instrumentation. Two artifacts: (1) on-death structured prompt
  — new `_breach_prompt_panel`/`_breach_prompt_label` in
  PlayerTank.gd, gated on `loadout != null`, shown in `_die()`
  flow; text: "which moment did you regret? right archetype?
  would switching help?" — the three questions focus on the open
  C15 anchor 5 / identity-vs-weapons axis. (2) PLAYTEST-5-BRIEF.md
  — one-page brief covering the four characteristic-mistake
  temptations (PRISM overcommit / MORTAR lazy safety / RAM
  reckless pathing / Default shell waste), 5-run playtest spec,
  6 specific things to learn. Substrate write #24 on PlayerTank.gd;
  hash preserved; test-all 5/5; test-breach 37/37. Phase 3 COMPLETE
  — iter 79 = Round-10 close. Δ 0. 47/75.
- 2026-05-23 — **iter 77 (BUILD).** Round 10 Phase 2 continuation:
  pressure-probe harness. 5 focused probes vs an armored Heavy
  stub confirmed the PRESSURES.md armor-bypass asymmetry:
  DEFAULT+AP=0 (BLOCKED), DEFAULT+HEAT=2 (bypass+×2), PRISM=1,
  MORTAR AoE=2, RAM swing=2. Empirically validates the iter-73
  spine "every archetype must buy passage differently" — DEFAULT
  pays in shell economy; the other three pay in
  exposure/positioning/HP. No substrate; hash preserved; test-all
  5/5; test-breach 36 → 37. Phase 2 COMPLETE; iter 78 = Phase 3
  instrumentation. Δ 0. 47/75.
- 2026-05-23 — **iter 76 (BUILD).** Round 10 Phase 2: PRESSURES.md
  per-archetype × per-pressure matrix shipped. 10 pressure rows ×
  4 archetypes; every pressure has ≥1 best answer; 4 ROSTER GAPS
  identified for Round 11 (DENSE SWARM has no spawn cluster;
  LONG-LOS lacks a sniper to punish PRISM exposure; HEAVY ARMOR
  beyond 3hp Heavy is undertested; TRUE SUPPRESSION undertested).
  Matrix surfaced a real design question: armor logic lives ONLY
  in Bullet.gd — PRISM/MORTAR/RAM call take_damage
  unconditionally. Two readings (universal armor vs per-archetype
  bypass-as-verb) — captured for Round 11 user direction.
  C5 lifts 2→3 (anchor 2 "documented canonical answer"). No
  substrate; hash preserved. test-all/test-breach not re-run
  (doc-only). Δ +1. 47/75.
- 2026-05-23 — **iter 75 (BUILD).** Round 10 Phase 1 continuation:
  added 4 play-relevant derived axes (damage_rate_hz / magnitude /
  persistence / range_shape) to the distinctness audit. 10-axis
  vector; threshold ≥5 of 10. ALL 6 pairs now 9-10/10 distinct
  (min 9, max 10) — play-relevant axes are MORE distinct than
  structural axes; residual tie is `move_blocked: no` for the
  three non-PRISM archetypes. CALIBRATION WARNING fires as
  designed: min ratio 0.90 > 0.80 ceiling — audit too easy,
  Phase 2 must add tighter signals. No substrate; hash preserved;
  test-all 5/5; test-breach 36/36. Δ 0. 46/75.
- 2026-05-23 — **iter 74 (BUILD).** Round 10 Phase 1: distinctness-
  audit harness scaffold. Per Consult 008's H4 reframe, built
  loop/breach/test_breach_distinctness_audit.gd — compares per-
  archetype 6-axis STRUCTURAL signal vectors (weapon_kind /
  move_blocked / range_class / cadence_class / damage_source / live
  fingerprint); asserts pairwise distance ≥3 of 6. Min pairwise
  5/6 — DEFAULT↔PRISM and PRISM↔MORTAR and PRISM↔RAM all 6/6
  (PRISM is the most distinct); DEFAULT/MORTAR/RAM share only the
  `move_blocked: no` signal. Honest baseline; 2-buffer above
  threshold. Phase-1 continuation iter 75 adds play-sim signals
  (kill distance / time stationary / wall interaction). No
  substrate; hash anchor preserved. test-all 5/5; test-breach
  35 → 36. Δ 0 (C5 lifts at Phase 2 close). 46/75.
- 2026-05-23 — **iter 73 (META).** Consult 008 captured + Round 10
  rethesis. User-initiated /second-opinion fired iter 72; GPT Pro
  extended thinking (~6 min) returned a sharp reframe: **"Round 9
  solved INPUT POVERTY, not yet DECISION POVERTY"** — different
  verbs ≠ different games. The iter-072 "enemy roster expansion"
  default became rubric-chasing per Pro; the stronger Round-10
  thesis is **archetype pressure design + distinctness
  instrumentation**. Three-phase rethesis written
  (iter-073-round10-rethesis.md): Phase 1 distinctness-audit harness
  (iters 74-75); Phase 2 PRESSURES.md matrix (76-77); Phase 3
  curated playtest instrumentation (78); close iter 79.
  REVIEW-QUEUE #15 (identities-vs-weapons design question) +
  #16 (pressure matrix + distinctness audit) opened. Loop exits
  idle-heartbeat — Phase 1 build is non-speculative. No substrate;
  hash anchor preserved. Δ 0 (the pressure matrix will plausibly
  lift C5 anchor 2 at Phase 2 close). 46/75.
- 2026-05-23 — **iter 72 (META).** Round 10 diagnose. Named 3
  candidates: (a) enemy roster expansion against the new archetypes
  (lifts C5 from 2 → 4; 4-7 BUILD iters); (b) arc-3 OG roster
  import (lifts C5 from 2 → 3; cheaper, 2-4 SPIKE + 3-5 BUILD); (c)
  defer to playtest verdict. Recommendation: (c) — every prior round
  (5/6/7/8/9) was direction-set by a user playtest; building speculative
  SPIKE work before #14 closes is high-variance. Written
  loop/breach/iter-072-round10-diagnose.md (L2 compaction-safe).
  Loop enters idle heartbeat at 1800s per iter-54/61 reconciliation.
  No substrate; hash anchor preserved. Δ 0. 46/75.
- 2026-05-23 — **iter 71 (META).** Round 9-close. Three artifacts:
  (1) CONSULT 007 — written self-pre-mortem on the 3 permanent
  questions + Round-9 distinctness + rubric, captured to
  creative-consults.md. Key reframe: Round 9 re-establishes CONSULT
  constraint 7 (verbs+affordances) maximally; the structural ceiling
  is reached, the cognitive ceiling is playtest-gated. (2) REVIEW-
  QUEUE #14 — ★ PLAYTEST REQUEST — Round 9 complete; summarizes all
  8 sub-rounds + the open #13 integration-path decision. (3) RUBRIC
  +C15 "Tank archetypes" — 15 criteria, 75-pt absolute ceiling; C15
  lands at 4 (structural ceiling), anchor 5 identity-protected.
  Score 42/70 → 46/75. No substrate; hash anchor preserved; test-all
  5/5; test-breach 35/35.
- 2026-05-23 — **iter 70 (BUILD).** Round 9h — visual assets via
  /agentify image_gen. 3 parallel ChatGPT image_gen calls returned 3
  concept sprites (~300×300) saved to
  img/archetype_{prism,mortar,ram}_concept.png. CONSULT constraint 4
  silhouette gate PASSES at concept tier: cyan beam-aperture / olive
  angled-barrel / red plow — each archetype's verb is readable from
  silhouette alone. REVIEW-QUEUE #13 opened with 3 integration paths;
  default if no answer = algorithmic tint+overlay via extended
  gen_tile.py. No substrate touched; hash anchor preserved.
  Δ 0 (C15 at round close). 42/70.
- 2026-05-23 — **iter 69 (BUILD).** Round 9g — event-unlock mid-run
  archetype switching: new Depot.UpgradeKind SWITCH_TO_PRISM/MORTAR/RAM
  (gated by MetaProgress tiers @20/40/60); apply_upgrade calls the
  player's new `switch_archetype` (reverts current archetype mods via
  `_revert_archetype` then re-inits, so speed/GunTimer/beam-line stay
  clean across multiple switches); `_build_beam_line` made
  idempotent. test_breach_meta + test_breach_overdrive updated for
  the wider catalog. Hash anchor preserved (only PlayerTank substrate
  write, gated); test-all 5/5, test-breach 35/35 (new
  check-breach-archetype-switch). Δ 0 (C15 at round close). 42/70.

## Next action

**Iter 83 — BUILD — Round 11 Phase 1 continuation: band-shape ANALYZER + death-recap surfacing.**

Read `loop/breach/iter-080-round11-diagnose.md`.

The iter-82 recorder captures per-band visit telemetry into
RunRecap.band_visit_log. Iter 83 extends this with:

  1. **Analyzer** — given N RunRecap instances (one per archetype
     on the same seed/scenario), compute pairwise:
       - band-sequence distance (Levenshtein or count of
         differing positions)
       - entry-time distance (sum of |t_i - t_j| per band)
       - total-run-ms distance
     Emit per-archetype run-shape signatures + a convergence
     verdict ("similar" / "distinct" per threshold) — analogous
     to iter-74 distinctness audit at the RUN scale.

  2. **Death-recap surfacing** — surface the band-sequence in the
     death-screen recap visibly (one extra line in
     `_death_label.text` or a sibling label) gated on
     `run_recap != null`.

Hash-anchor verify (substrate write if death-label is touched —
keep flag-off bit-identical); test-all + test-breach green.

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires.

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires.

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires.

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires (hash anchor break, test-all
regression, unsanctioned substrate write, unfixed band reachability).

The loop runs non-stop until the user writes `playtest` / `halt` /
`stop`, or a correctness violation fires (hash anchor break, test-all
regression, unsanctioned substrate write, unfixed band reachability).

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
