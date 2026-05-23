# Breach loop state (arc 4)

```yaml
phase: running
iter: 68
preloop_complete: yes
substrate_baseline_verified: yes
hash_anchor_at_iter_0: 23d6a2ec3bf2821f  # seed 42, default procedural config
hash_anchor_at_iter_68: 23d6a2ec3bf2821f  # bit-identical through 40 substrate writes
substrate_writes_this_arc: 40  # ProceduralLevel.gd ×5 + Bullet.gd ×8 + PlayerTank.gd ×22 + Level.gd + Spawner.gd ×4 + Enemy.gd ×1
current_round: 9-open
current_round_phase: BUILD — Round 9g (event-unlock mid-run archetype switching); blueprint iter-062-round9-architect.md
consult_001_status: adopted
consult_002_status: adopted
build_quality_iters: [10, 24, 29, 30]  # 29+30 back-to-back = the ceiling signal (see iter-30 LEDGER)
falsifications: [F001-resolved, F002-resolved, F003-open, F004-resolved]
reachability_status: all 5 bands verified — 12/12-seed sweep (100%, floor ≥80%) — refreshed iter 61 post-Round-8
audit_candidates: []
last_audit: iter 26
last_consult: iter 60  # CONSULT 006 — written self-pre-mortem, Round 8 close
playtest_log: [iter 33 — 2026-05-20 — structurally complete but illegible, F003; iter 55 — 2026-05-21 — post-Round-7 — concept didn't land as roguelite, redirected to XP/level-ups + ammo drops → Round 8; iter 62 — 2026-05-22 — post-Round-8 — positive verdict but the tank primitive is too thin, redirected to TANK ARCHETYPES (Prism/Mortar/Ram) + enemy HP primitive + /agentify assets → Round 9]
structural_ceiling: Rounds 5-6 lifted 30/50 → 39/65 (RUBRIC extended +C11/C12/C13 for the roguelite axes). The structural tier is now at its honest ceiling — the remaining ~26 points are [FEEL]/playtest-gated, and the remaining structural surfaces are substrate-blocked (C5) or unrequested scope (CONSULT 004).
loop_state: RUNNING — Round 9 opened at iter 62. The user playtested Round 8 (positive — "getting to an interesting spot") and named the next bottleneck: the "tank that shoots discrete bullets" primitive is too thin. Via AskUserQuestion (override authority) the user chose the "Full archetype program" scope — Round 9 builds 4 mechanically-distinct tanks (Default + Prism + Mortar + Ram, Red Alert / Into-the-Breach inspired) + enemy HP primitive + HP bars + BOTH selection paths + asset visuals via /agentify image_gen. Two PROMPT overrides recorded in §Arc-4 amendments (Enemy.gd HUD writes sanctioned for HP-bar; /agentify image_gen sanctioned for assets). Blueprint iter-062-round9-architect.md. The non-stop loop builds Round 9 (9a-9h + close) until the user writes playtest / halt / stop.
next_action: iter 69 — BUILD — Round 9g: event-unlock mid-run archetype switching. Read iter-062-round9-architect.md. A new Depot UpgradeKind ("Switch to <Archetype>") drawn from the depot pool, gated by the same MetaProgress tiers as the start-pick screen; picking the upgrade calls PlayerTank._pick_archetype to switch the player's archetype mid-run — "almost like switching a weapon" per the iter-55 user direction. Depot.gd (arc-4-owned). Hash-anchor verify; test-all + test-breach green; a harness for the depot offer + the switch.
score: 42/70 absolute · 42/70 effective  # C1=3,C2=3,C3=4,C4=3,C5=2,C6=3,C7=3,C8=3,C9=2,C10=4,C11=3,C12=3,C13=3,C14=3
spike_report: loop/breach/iter-001-spike-report.md
round5_blueprint: loop/breach/iter-033-round5-architect.md
round6_blueprint: loop/breach/iter-038-round6-architect.md
round6e_blueprint: loop/breach/iter-043-round6e-architect.md
round7_blueprint: loop/breach/iter-047-round7-architect.md
round8_blueprint: loop/breach/iter-055-round8-architect.md
round9_blueprint: loop/breach/iter-062-round9-architect.md
new_harness_targets: check-breach-{config,shells,depot,he-blast,loadout,depot-choice,level,harness,recap,enemies,assets,armor,dividend,swap,overdrive,hud,apcr,codex,shuffle,depot-roll,rulechangers,stakes,meta,route,xp,ammo,shield,hp,archetype,prism,mortar,ram,archetype-select} + check-silhouette-gate (34 in test-breach aggregate)
review_queue_open: [#1 round-1 scaffolding, #2 round-2 atomic verb, #4 round-3 + ceiling, #5 playtest verdict + Round 5 launch, #6 Round 5 close, #8 playtest verdict + Round 7 launch, #10 playtest verdict + Round 8 launch, #12 playtest verdict + Round 9 launch]  # #3, #7, #9, #11 CLOSED — playtests delivered
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

- 2026-05-23 — **iter 68 (BUILD).** Round 9f — start-pick selection
  screen: MetaProgress unlock tiers (PRISM@20/MORTAR@40/RAM@60); a
  HUD ArchetypePanel + KEY_1-4 picker; per-archetype `_ready` init
  refactored into `_init_archetype()` so post-pick re-init works;
  gated by `@export var force_archetype_select` (default false) so
  existing harnesses see no selection-screen leak; BreachLevel.tscn
  opts in. PlayerTank.gd substrate write; DEFAULT (no force flag)
  bit-identical. Hash anchor preserved; test-all 5/5, test-breach
  34/34 (new check-breach-archetype-select). Δ 0 (C15 at round close).
  42/70.

## Next action

**Iter 69 — BUILD — Round 9g: event-unlock mid-run archetype switching.**
Read `loop/breach/iter-062-round9-architect.md`. A new Depot
UpgradeKind ("Switch to <Archetype>") drawn from the depot pool,
gated by the same MetaProgress tiers as the start-pick screen;
picking the upgrade calls `PlayerTank._pick_archetype` to switch the
player's archetype mid-run — "almost like switching a weapon" per
the iter-55 user direction. Depot.gd (arc-4-owned). Hash-anchor
verify; test-all + test-breach green; a harness for the depot offer
+ the switch.

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
