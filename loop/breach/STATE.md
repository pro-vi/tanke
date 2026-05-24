# Breach loop state (arc 4)

```yaml
phase: running
iter: 94
preloop_complete: yes
substrate_baseline_verified: yes
hash_anchor_at_iter_0: 23d6a2ec3bf2821f  # seed 42, default procedural config
hash_anchor_at_iter_94: 23d6a2ec3bf2821f  # bit-identical through 50 substrate writes
substrate_writes_this_arc: 50  # ProceduralLevel.gd ×5 + Bullet.gd ×8 + PlayerTank.gd ×31 + Level.gd + Spawner.gd ×4 + Enemy.gd ×2
current_round: 11-open — fix queue running; 6 of 8 code-review findings closed (iters 90-94); next P1-4 RunRecap.archetype contract
current_round_phase: BUILD — Round 11 Phase 2 fix queue from code-review-iter-090.md
consult_001_status: adopted
consult_002_status: adopted
build_quality_iters: [10, 24, 29, 30, 88]  # 29+30 back-to-back = the ceiling signal (see iter-30 LEDGER); 88 = state-hygiene fix per iter-87 audit
falsifications: [F001-resolved, F002-resolved, F003-open, F004-resolved, F005-open, F006-open]  # F006 (iter 90): iter-87 single-pass audit missed 18 real bugs; /code-review delegation at every round close is the discipline fix
reachability_status: all 5 bands verified — 12/12-seed sweep (100%, floor ≥80%) — refreshed iter 61 post-Round-8
audit_candidates: []
last_audit: iter 26
last_consult: iter 79  # CONSULT 009 — written self-pre-mortem, Round 10 close (band-shape blind spot named)
playtest_log: [iter 33 — 2026-05-20 — structurally complete but illegible, F003; iter 55 — 2026-05-21 — post-Round-7 — concept didn't land as roguelite, redirected to XP/level-ups + ammo drops → Round 8; iter 62 — 2026-05-22 — post-Round-8 — positive verdict but the tank primitive is too thin, redirected to TANK ARCHETYPES (Prism/Mortar/Ram) + enemy HP primitive + /agentify assets → Round 9]
structural_ceiling: Rounds 5-6 lifted 30/50 → 39/65 (RUBRIC extended +C11/C12/C13 for the roguelite axes). The structural tier is now at its honest ceiling — the remaining ~26 points are [FEEL]/playtest-gated, and the remaining structural surfaces are substrate-blocked (C5) or unrequested scope (CONSULT 004).
loop_state: RUNNING — Round 9 opened at iter 62. The user playtested Round 8 (positive — "getting to an interesting spot") and named the next bottleneck: the "tank that shoots discrete bullets" primitive is too thin. Via AskUserQuestion (override authority) the user chose the "Full archetype program" scope — Round 9 builds 4 mechanically-distinct tanks (Default + Prism + Mortar + Ram, Red Alert / Into-the-Breach inspired) + enemy HP primitive + HP bars + BOTH selection paths + asset visuals via /agentify image_gen. Two PROMPT overrides recorded in §Arc-4 amendments (Enemy.gd HUD writes sanctioned for HP-bar; /agentify image_gen sanctioned for assets). Blueprint iter-062-round9-architect.md. The non-stop loop builds Round 9 (9a-9h + close) until the user writes playtest / halt / stop.
next_action: iter 95 — BUILD — P1-4 fix: RunRecap.archetype reassigned on every band change → contradicts "at run start" documented contract. Read code-review-iter-090.md "P1-4" section. Three sub-fixes: (1) RunRecap.gd: clarify the field semantics — either rename to `current_archetype` (tracks live), OR keep `archetype` and stop overwriting it on band change. (2) PlayerTank.gd `_on_breach_band_changed`: REMOVE the `run_recap.archetype = archetype` line so the field reflects run-start. Add a separate one-shot capture in `_ready` (after run_recap creation) AND in `_pick_archetype` (so start-pick captures the picked archetype as run-start). (3) Optional improvement: ALSO capture the starting band (deferred read of level._current_breach_band) so signatures don't miss the initial band segment. New harness `test_breach_run_recap_archetype_contract.gd` verifying: run_recap.archetype reflects pick screen choice (not later switch); band_visit_log starts from band 0 not band 1+. Substrate write #32 on PlayerTank.gd. Hash-anchor verify; test-all + test-breach green.
score: 47/75 absolute · 47/75 effective  # C1=3,C2=3,C3=4,C4=3,C5=3,C6=3,C7=3,C8=3,C9=2,C10=4,C11=3,C12=3,C13=3,C14=3,C15=4 (iter 76 lifts C5 2→3 via PRESSURES.md canonical-answer doc)
spike_report: loop/breach/iter-001-spike-report.md
round5_blueprint: loop/breach/iter-033-round5-architect.md
round6_blueprint: loop/breach/iter-038-round6-architect.md
round6e_blueprint: loop/breach/iter-043-round6e-architect.md
round7_blueprint: loop/breach/iter-047-round7-architect.md
round8_blueprint: loop/breach/iter-055-round8-architect.md
round9_blueprint: loop/breach/iter-062-round9-architect.md
new_harness_targets: check-breach-{config,shells,depot,he-blast,loadout,depot-choice,level,harness,recap,enemies,assets,armor,dividend,swap,overdrive,hud,apcr,codex,shuffle,depot-roll,rulechangers,stakes,meta,route,xp,ammo,shield,hp,archetype,prism,mortar,ram,archetype-select,archetype-switch,distinctness-audit,pressure-probes,band-shape,band-shape-analyzer,swarm-spike,double-kill,archetype-select-pause,xp-reload-persistence,switch-archetype-validation,pick-archetype-and-mortar-guard} + check-silhouette-gate (45 in test-breach aggregate)
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

- 2026-05-24 — **iter 94 (BUILD).** P1-2 + P1-6 paired fix from
  code-review-iter-090. P1-2 (PlayerTank.gd ×31): `_pick_archetype`
  now routes through `switch_archetype`, ensuring `_revert_archetype`
  runs first if current archetype is non-DEFAULT. Latent today but
  defensive against future callers. P1-6 (MortarShell.gd, arc-4-
  owned): `_explode` + `_spawn_burst` add
  `is_instance_valid(parent_node) and not
  parent_node.is_queued_for_deletion()` guards before iterating
  children / add_child — prevents crash on scene-reload mid-shell-
  flight. New harness test_breach_pick_archetype_and_mortar_guard
  with 4 assertions (RAM start speed=38; _pick_archetype(DEFAULT)
  from RAM reverts speed to 32; MortarShell._explode against
  queued-for-deletion parent no-ops; no ColorRect burst added to
  queued parent). Substrate write ×31. Hash preserved; test-all
  5/5; test-breach 44 → 45. Δ 0. 47/75.
- 2026-05-24 — **iter 93 (BUILD).** P1-3 + P1-5 paired fix from
  code-review-iter-090. P1-3 (PlayerTank.gd ×30): switch_archetype
  validates value in [DEFAULT, RAM] range; out-of-range pushes
  warning + returns. P1-5 (Depot.gd, arc-4-owned): all 3
  SWITCH_TO_* apply_upgrade branches add `is_instance_valid(_player)`
  guard alongside the existing `!= null` + `has_method` checks.
  New harness test_breach_switch_archetype_validation with 8
  assertions (out-of-range / same-value / boundary / valid /
  null _player / freed _player). Substrate write ×30. Hash
  preserved; test-all 5/5; test-breach 43 → 44. Δ 0. 47/75.
- 2026-05-24 — **iter 92 (BUILD).** P0-2 fix from code-review-
  iter-090: FASTER_RELOAD XP bonus survives archetype switches.
  New cumulative-reduction model: `_base_default_gun_wait_time`
  (captured _ready) + `_reload_reduction` (accumulated). Per-
  archetype wait_time = max(RELOAD_MIN, arch_base − reduction).
  Modified `_apply_level_boost` FASTER_RELOAD branch,
  `_init_archetype` MORTAR branch, `_revert_archetype` MORTAR
  branch. New harness test_breach_xp_reload_persistence with 8
  assertions (DEFAULT fresh, 1 boost, DEFAULT→MORTAR carry,
  MORTAR→RAM→MORTAR round-trip, 2nd boost composes, floor).
  Empirical: 1.00 → 0.90 → 1.40 → 0.90 → 1.40 → 1.30 → 0.35.
  Substrate write ×29. Hash preserved; test-all 5/5; test-breach
  42 → 43. Δ 0. 47/75.
- 2026-05-23 — **iter 91 (BUILD).** P0-1 fix from code-review-
  iter-090: archetype-select now pauses the world. Three changes
  in PlayerTank.gd (substrate write ×28): `_show_archetype_select`
  sets `get_tree().paused = true` + `process_mode = PROCESS_MODE_
  ALWAYS` on self; new `_exit_archetype_select` helper centralizes
  cleanup; `_pick_archetype` routes through it; `_physics_process`
  dead-during-selector branch escapes cleanly. New regression
  harness test_breach_archetype_select_pause.gd verifies 6
  assertions (tree paused, player process_mode ALWAYS, stub Node
  ticks=0 while paused, _pick_archetype unpause + restore, stub
  resumes, dead-during-selector escape). All pass. Hash preserved;
  test-all 5/5; test-breach 41 → 42. Δ 0. 47/75.
- 2026-05-23 — **iter 90 (META + BUILD).** Resumed loop per user
  feedback ("u havent done enough to deserve a pause"). Invoked
  /code-review on Round 9-10-11 substrate: 5 personas + codex
  cross-model in parallel returned 18 anchor-≥75 findings (2 P0,
  6 P1, 10 P2). Full report in code-review-iter-090.md. F006
  codified: iter-87 single-pass self-audit missed all 18.
  **Discipline update: /code-review at every round close, not
  self-audit.** Fixed P1-1 inline (Enemy.take_damage idempotency
  guard, 1 line). New regression harness test_breach_double_kill
  (41 in test-breach). Fix queue for iters 091-096+ enumerated.
  Substrate write Enemy.gd ×2. Hash preserved; test-all 5/5;
  test-breach 40 → 41. Δ 0. 47/75.
- 2026-05-23 — **iter 89 (META).** Clean loop pause per loop-skill
  step 6 + iter-54/61/72 reconciliation. Meta-trigger: user keeps
  invoking /loop; loop keeps manufacturing work; both are weak
  proxies for actual intent. Honest move = put direction-choice
  back in user's hands. All pre-playtest deliverables shipped;
  remaining Round-11 candidates gated on playtest evidence. No
  ScheduleWakeup. Resume signals listed in next_action. No
  substrate; hash preserved. Δ 0. 47/75.
- 2026-05-23 — **iter 88 (BUILD-QUALITY).** Resolved S1/S2/S3
  cleanup observations from iter-87 audit. Extended
  `_revert_archetype` to clear `_ram_swing_timer` (S1),
  `_beam_dmg_timer` (S2), and stop GunTimer + reset can_shoot (S3)
  on switch. Side effect: SWITCH cancels MORTAR reload (instant
  fire on switched archetype) — consistent with the iter-69
  "switching like a weapon" direction; flag for playtest feedback.
  Extended test_breach_archetype_switch with S1/S2/S3 assertions
  — all pass. Substrate write ×27. Hash preserved; test-all 5/5;
  test-breach 40/40. Δ 0 ([QUALITY] tag). 47/75.
- 2026-05-23 — **iter 87 (SWEEP).** Round 9-10-11 substrate
  audit. Read-only audit of per-archetype state machine
  (PlayerTank.gd 491-605). 3 cleanup-tier state-hygiene
  observations: S1 `_ram_swing_timer` not reverted; S2
  `_beam_dmg_timer` not reverted; S3 GunTimer running with stale
  wait_time after MORTAR→other switch (one-shot timing anomaly;
  self-corrects). All harmless — state-leaks with no observable
  effect. No correctness bugs found. Substrate is
  playtest-5-ready. Hash preserved. Δ 0. 47/75.
- 2026-05-23 — **iter 86 (META).** Round 11 candidate (c)
  armor-asymmetry resolution — design doc shipped
  (iter-086-armor-asymmetry-design.md). Names both readings —
  (a) universal armor (add per-archetype armor-piercing depot
  upgrades) vs (b) armor-bypass-as-verb (current, asymmetry as
  design intent). Key finding: armor question is DOWNSTREAM of
  REVIEW-QUEUE #15 identities-vs-weapons (a≈weapons,
  b≈identities). Recommendation: pause until #15 settles via
  playtest 5. Both implementation paths sketched (~3-5 iters
  each). No code; no hash impact; doc-only iter. Δ 0. 47/75.
- 2026-05-23 — **iter 85 (SPIKE).** Round 11 Phase 2: SWARM
  α/β/γ comparison — **F005 falsified the iter-84 blueprint**.
  All 3 variants VIOLATE the cross-archetype hierarchy rule under
  the iter-77-style single-event probe (α/β: 3 archetypes tie
  COSTLY; γ: 4-way tie BAD). Root cause: probe measures kills-
  per-event (one fire burst) — captures MORTAR's one-shell-AoE
  pattern but undercounts PRISM continuous-DPS, RAM multi-swing,
  DEFAULT discrete-over-cooldowns. Iter-77 stub-probe pattern
  doesn't extend to sustained-DPS hierarchy verification.
  Codified F005 in FALSIFICATIONS.md. SWARM commit DEFERRED
  until playtest 5 data feeds the iter-83 analyzer. Loop has
  built everything it can pre-playtest; iter 86 = idle heartbeat
  awaiting playtest. test-all 5/5; test-breach 39 → 40. Δ 0.
  47/75.
- 2026-05-23 — **iter 84 (META).** Round 11 Phase 2 SPIKE
  architect blueprint. Wrote iter-084-round11-phase2-spike.md
  naming 3 SWARM variants: α swarmlet (4-5 Light chevron pack —
  predicted 3 distinct outcomes; favored), β Fast-rusher pack
  (DEFAULT=PRISM both bad — violates hierarchy rule; reject), γ
  Heavy-pair "spinet" (different pressure — Round 12 candidate).
  iter 85 SPIKE harness compares variants. Loop-discipline note:
  Phase 2 is CONTENT (speculative per Pro's H5); iter 84 META
  only, iter 85 SPIKE only if engagement continues. No substrate;
  hash preserved. Δ 0. 47/75.
- 2026-05-23 — **iter 83 (BUILD).** Round 11 Phase 1 continuation:
  band-shape analyzer + death-screen surface. New
  scripts/RunRecapAnalyzer.gd (arc-4-owned) with static
  compare_signatures returning pairwise sequence-distance +
  time-distance + verdict ("similar" / "distinct" per threshold).
  PlayerTank._die updated to append "bands visited: ..." to the
  _breach_prompt_label text — substrate write ×26 inside the
  existing breach-mode gate. Resized the prompt panel/label to
  fit. Harness verifies 4 micro-cases + 4-archetype mock
  (DEFAULT↔PRISM=0 same seq; DEFAULT↔MORTAR=1 tail mismatch;
  DEFAULT↔RAM=2 reorder; verdict "similar" when any pair=0).
  Hash preserved; test-all 5/5; test-breach 38 → 39. Phase 1
  COMPLETE. Δ 0. 47/75.
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

**Iter 95 — BUILD — P1-4 fix: RunRecap.archetype contract.**

Read `loop/breach/code-review-iter-090.md` "P1-4" section.

The field is documented as "PlayerTank.TankArchetype value at run
start" but PlayerTank `_on_breach_band_changed` reassigns it on
every band crossing. Cross-archetype distinctness analysis
(iter-82/83) is corrupted by any mid-run SWITCH_TO_* upgrade.

Three sub-fixes:

1. **PlayerTank.gd `_on_breach_band_changed`**: REMOVE the
   `run_recap.archetype = archetype` line. Field becomes
   immutable from this code path.

2. **PlayerTank.gd `_ready`**: after `run_recap = RunRecapT.new()`,
   add `run_recap.archetype = archetype`. This captures the
   START-OF-RUN archetype (DEFAULT for non-force-select runs).

3. **PlayerTank.gd `_pick_archetype` (and now `switch_archetype`
   if called from selector)**: the start-pick screen happens
   AFTER `_ready`, so update `run_recap.archetype` on the pick
   too — that's the actual "run start" once the user has chosen.

Optional improvement (defer if scope grows): also capture the
starting band (deferred read of `level._current_breach_band`
after parent `_ready`) so signatures include the initial band.

Regression harness `test_breach_run_recap_archetype_contract.gd`:
- Spawn PlayerTank with DEFAULT, _ready runs → run_recap.archetype
  should be 0 (DEFAULT)
- Switch to PRISM via switch_archetype → run_recap.archetype
  should STAY 0 (run-start contract)
- Simulate band crossing → run_recap.archetype should STAY 0
- (For the future) Test that _pick_archetype updates
  run_recap.archetype when called from selector

Substrate write #32 on PlayerTank.gd; RunRecap.gd doc-only
update. Hash-anchor verify; test-all + test-breach green.

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
