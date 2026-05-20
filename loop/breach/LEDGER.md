# Breach loop ledger (arc 4)

Append-only. One entry per iter. Format:

```
## iter NNN — <MODE> — <focus>
- Date: YYYY-MM-DD
- Tag: [STRUCTURE] / [FEEL] / [MIXED] / [STRUCTURE-DEFERRED] / [IDENTITY-PROTECTED] / [QUALITY]
- Score: NN/MM effective · NN/50 absolute   (Δ vs prior: ±N)
- Constraints respected: <list of CONSULT §9 constraints>
- Constraints risked: <list, if any>
- Hash anchor: 23d6a2ec… verified | broken | n/a (no substrate touch)
- Falsifications: F0NN added | none
- Files: <touched paths>
- Finding: <one-sentence>
```

---

## iter 012 — CAPABILITY — per-band reachability oracle; closes F001 caveat

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **13/50 absolute · 13/50 effective** (Δ 0 — CAPABILITY iter;
  extends tooling, derisks C4=2 rather than lifting a new anchor)
  - C1=1, C2=2, C3=2, C4=2, C8=1, C9=2, C10=3 unchanged. C4=2 is now
    **solid** (was at-risk under the F001 reachability caveat).
- CAPABILITY justification: the breach reachability oracle is the
  PROMPT §REACHABILITY FLOOR verification tool for C4. Without it the
  F001 caveat (bands 2+3 unverified) couldn't close.
- Constraints respected: 5 (verified each band is a *playable* climb
  problem, not an impassable wall)
- Constraints risked: none
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (only
  breach_default.tres retuned — no flag-off codepath touched).
  `make test` exit 0. `make test-all` PASS (5 arc-3 targets).
  `make test-breach` PASS (8 arc-4 harnesses).
- Falsifications: **F001 RESOLVED.** The original scene-instantiation
  deep harness went quadratic (thousands of accumulating BrickBlock
  nodes — killed after minutes). Rewrote `test_breach_harness.gd` as
  pure-data generation (ProceduralStep + per-band LevelConfig sampling,
  no scene/nodes — <1s). Two replication bugs found + fixed mid-iter:
  (a) flood-fill escaped into ungenerated space (bounded it);
  (b) missed ProceduralLevel._ready's `row == START_ROW-1` skip — the
  guaranteed-clear spawn row — which walled the spawn. Also corrected
  the reachability *model*: a single global flood-fill to depth 120 is
  wrong (no 120-row stochastic stretch is brick-corridor-clear; arc-2
  itself would fail it). The arc-1/2/3 precedent is *local first-screen*
  reachability — so each band is checked the way arc-2 checks its
  start (generate that band's config, flood-fill, require ≥10 tile-rows).
- Falsification meta: F001's fix surfaced that breach band terrain
  density needs retuning — all 3 bands softened to empty 0.50-0.52 /
  merge 0.24-0.26. 10-seed sweep: 9/10 pass (seed 77 fails — spawn-area
  Eller artifact, not tunable). Reachability floor codified: **≥80% of
  a 10-seed sweep**.
- Files: `loop/breach/test_breach_harness.gd` (full rewrite — pure-data
  per-band oracle, shallow + deep modes), `configs/breach_default.tres`
  (all 3 band configs retuned for reachability), `Makefile`
  (check-breach-harness now runs --deep seed 42), `loop/breach/
  FALSIFICATIONS.md` (F001 resolved), `loop/breach/PRE-MORTEMS.md`,
  `loop/breach/LEDGER.md`, `loop/breach/STATE.md`
- Finding: **Breach reachability is now a fast, honest oracle.** All 3
  bands verified locally reachable (90% of 10 seeds; canonical seed 42
  solid at 41/23/41 tile-rows). The per-band model is the correct one
  — it caught + drove F001's resolution. Pre-mortem predicted "F001
  strongly predicts bands 2+3 will fail on first deep run" — CONFIRMED
  (brick_maze + bunker_zone both failed multi-seed before retune).
  Next iter 13: BUILD — extend BANDS.md roster to 5 bands
  (breach_default.tres → 5 bands, bands 4-5 reachability-verified),
  unlocking C4 anchor 3.

## iter 011 — BUILD — depth-band terrain wiring + reachability oracle (C4 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **13/50 absolute · 13/50 effective** (Δ +1 vs prior — C4 anchor 2)
  - C4 (Depth bands): 1 → 2 (anchor 2: ≥3 bands, each with a stated
    dominant pressure in config — code-cited via `make
    check-breach-config` showing tutorial_choke / brick_maze /
    bunker_zone, each with a `dominant_pressure` string). **Reachability
    caveat**: band 1 (tutorial_choke) verified `playable: true` across
    7 seeds (1/7/13/42/100/333/777); bands 2+3 softened proactively
    but NOT yet reachability-verified — iter-11's 30-frame harness only
    generates the band-1 region. iter-12 deep-climb harness verifies
    bands 2+3. If they fail then, reachability floor retroactively
    caps C4 → 0 until fixed.
  - C1=1, C2=2, C3=2, C8=1, C9=2, C10=3 unchanged
- Constraints respected: 5 (each band's dominant terrain pressure is
  now ENFORCED at generation — `_active_config` routes per-band
  LevelConfig into row generation, not just declared in config), 7
  - Constraints risked: 5's reachability flip-side — surfaced as F001.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #7. The `_active_config` breach branch is gated on
  `breach_mode_enabled` — flag-off procedural baseline bit-identical.
  `make test` exit 0. `make test-all` PASS. `make test-breach` PASS
  (all 8 arc-4 harnesses including the new reachability oracle).
- Falsifications: **F001 logged** — breach band terrain density
  eyeballed, not reachability-verified. The oracle caught
  tutorial_choke producing `playable: false` (impassable brick walls).
  Fixed within-iter per PROMPT §HALT CONDITIONS: retuned tutorial_choke
  (empty 0.20→0.46, brick 0.55→0.32, merge 0.45→0.30) to pass 7/7
  seeds; proactively softened brick_maze + bunker_zone applying the
  same lesson.
- Files: `scripts/ProceduralLevel.gd` (substrate write #7 — filled the
  iter-2 `_init_breach_mode` / `_process_breach_depth` stubs +
  `_active_config` breach branch + `_rows_climbed_at` helpers +
  `breach_band_changed` signal), `configs/breach_default.tres` (3rd
  band bunker_zone + all 3 band configs retuned for reachability),
  `loop/breach/test_breach_harness.gd` (NEW — the PROMPT-named breach
  reachability oracle), `Makefile` (new `check-breach-harness` target;
  test-breach aggregate now 8 harnesses), `loop/breach/FALSIFICATIONS.md`
  (F001), `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **The depth-band experience is live.** `_active_config` now
  routes per-band `LevelConfig` into procedural row generation when
  breach mode is on — terrain pressure genuinely shifts per band
  (tutorial_choke → brick_maze → bunker_zone). `_process_breach_depth`
  tracks the current band + emits `breach_band_changed`.
  `_init_breach_mode` resolves the starting band. The breach
  reachability oracle (`test_breach_harness.gd`) is the PROMPT-mandated
  §REACHABILITY FLOOR check — it caught F001 immediately. Next iter 12:
  CAPABILITY — deep-climb harness that forces generation through all 3
  bands' depth ranges + verifies bands 2+3 reachability (closes the
  F001 caveat; unlocks C4 anchor 3).

## iter 010 — BUILD-QUALITY — BreachLevel.tscn integration scene

- Date: 2026-05-19
- Tag: [STRUCTURE] [QUALITY] (integration milestone; no NEW rubric
  anchor ticks — honest use of the L3/R4 BUILD-QUALITY release valve.
  First BUILD-QUALITY iter of arc 4; within the 1-per-3-BUILDs cap
  — iters 7/8/9 were all anchor-lifting BUILDs.)
- Score: **12/50 absolute · 12/50 effective** (Δ 0 — no anchor lift;
  this iter integrates prior pieces into one playable scene)
  - C1=1, C2=2, C3=2, C4=1, C8=1, C9=2, C10=3 — unchanged
- Constraints respected: all 7 structurally (integration scene; no new
  design surface)
- Constraints risked: 5 — band-aware procedural generation still not
  wired (`_init_breach_mode` / `_process_breach_depth` stubs empty);
  BreachLevel generates terrain identically to arc-2 procedural. The
  depth-band *experience* is iter 11+ work.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** — BreachLevel
  is a NEW inherited scene; ProceduralLevel.tscn / .gd byte-identical.
  `make test` exit 0. `make test-all` PASS. New `make test-breach`
  aggregate (all 7 arc-4 harnesses) PASS.
- Falsifications: none. Pre-mortem prediction "inherited-scene syntax
  may fail" — confirmed quirk-free; Godot 4.6 inherited scene with
  `[node name="BreachLevel" instance=ExtResource(base)]` root rename +
  child-override-by-path works cleanly.
- Files: `scenes/BreachLevel.tscn` (NEW — inherited from
  ProceduralLevel.tscn; overrides breach_mode_enabled=true +
  breach_config + PlayerTank.loadout; adds 1 Depot child),
  `configs/breach_starter_loadout.tres` (NEW — 2 HE / 1 HEAT starter),
  `loop/breach/test_breach_level.gd` (NEW verifier), `Makefile` (new
  `check-breach-level` + `test-breach` aggregate targets),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **First end-to-end breach scene exists.** BreachLevel.tscn
  is an inherited scene — thin override layer over ProceduralLevel.tscn
  (no sub-resource duplication; changes to the base scene propagate;
  H1 surface burden minimized per Scout B's iter-1 concern). It wires:
  breach_mode_enabled=true, breach_config=breach_default.tres,
  PlayerTank.loadout=breach_starter_loadout (2 HE / 1 HEAT), + a Depot1
  placed at y=-248 (≈band-1 exit). `make check-breach-level` confirms
  bands=2, he_reserve=2, depots=1, 30 frames clean. **The pieces now
  co-exist in a playable surface** — but the band *experience* (terrain
  shifting per depth) is still inert because the breach stubs are
  empty. Next iter 11: wire `_process_breach_depth` to drive per-band
  LevelConfig selection from breach_config + extend breach_default.tres
  to ≥3 bands. Target C4 anchor 2.

## iter 009 — BUILD — Depot 3-choice upgrade catalog (C2 anchor 2, C8 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **12/50 absolute · 12/50 effective** (Δ +2 vs prior — C2 anchor 2, C8 anchor 1)
  - C2 (Field depot system): 1 → 2 (anchor 2: Depot offers ≥3 meaningful
    upgrade choices on entry + previews next band's dominant pressure —
    code-cited via `make check-breach-depot-choice` reporting 3 distinct
    effects + next_band_hint preview field)
  - C8 (Sentence test compliance): 0 → 1 (anchor 1: ≥1 upgrade exists
    and passes sentence test — 3 upgrades all pass, cited verbatim in
    iter-9 PRE-MORTEM. HE_REFILL_2 / HEAT_REFILL_1 / HE_MAX_EXPAND_2)
  - C1=1, C3=2, C4=1, C9=2, C10=3 unchanged
- Constraints respected: 1 (depot is the safe-gate; key-based pick is
  ≤1-frame fast — sub-30s by construction), 7 (verbs not stats — each
  upgrade is an action: "refill HE", "refill HEAT", "expand HE
  capacity"; no passive %damage cards)
- Constraints risked: 1's flip-side (30s dwell) — iter 9 ships no dwell
  timer; harness verifies single-frame applicability. Iter 10+ adds
  enforcement if playtest reveals drag.
- Sentence tests per upgrade (all PASS):
  - HE_REFILL_2: "This upgrade helps me climb through brick mazes by
    changing how I use HE shells"
  - HEAT_REFILL_1: "This upgrade helps me climb through bunker bands
    by changing how I use HEAT shells"
  - HE_MAX_EXPAND_2: "This upgrade helps me climb through long
    HE-required runs by changing how I use my shell economy"
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (no Layer 1/2/3
  substrate touched; only Depot.gd + Depot.tscn extended). `make test`
  exit 0. `make test-all` PASS. All 6 arc-4 harnesses PASS.
- Falsifications: none. Pre-mortem prediction "input-during-pause works
  with PROCESS_MODE_ALWAYS" — confirmed (harness invokes apply_choice
  directly, real input path uses same code with input gating; visual
  playtest defers to iter 10+).
- Files: `scripts/Depot.gd` (extended — UpgradeKind enum + 3 choices +
  apply_choice + next_band_hint + _player_loadout capture; iter-5
  pause-on-entry preserved),  `loop/breach/test_breach_depot_choice.gd`
  (NEW verifier), `Makefile` (new `check-breach-depot-choice` target),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **Depot upgrade flow shipped.** UpgradeKind enum with 3
  values (HE_REFILL_2 / HEAT_REFILL_1 / HE_MAX_EXPAND_2); each surfaces
  a verb (refill / expand), all 3 pass sentence test. Depot captures
  player.loadout on entry, applies effect on apply_choice(N), clears on
  exit. Single-pick semantics (`_picked` flag) prevents re-application.
  next_band_hint String field present for preview text. Per CONSULT 001
  Q2: "options legible in <5s, no scrolling/build tree/stat salad" —
  3-choice keyboard select respects this. Next iter 10: ship a
  BreachLevel.tscn that wires bands + depot placements + spawns the
  player with a loadout (the first end-to-end breach mode scene).

## iter 008 — BUILD — Loadout.gd + PlayerTank finite reserves + shell cycle (C1 anchor 1, C9 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **10/50 absolute · 10/50 effective** (Δ +2 vs prior — C1 anchor 1, C9 anchor 2)
  - C1 (Breach build identity): 0 → 1 (anchor 1: Loadout struct exists;
    player has ≥1 build-axis differentiator — code-cited; we have 2
    differentiators: he_reserve + heat_reserve as separate finite
    resources)
  - C9 (Identity singularity): 1 → 2 (anchor 2: build identity (C1=1) +
    depots (C2=1) + bands (C4=1) all functional — code-cited via the 4
    arc-4 harness targets)
  - C2=1, C3=2, C4=1, C10=3 unchanged; total = 1+1+2+1+0+0+0+0+2+3 = 10
- Constraints respected: 1 (shell-cycle is a key tap, not a menu; no
  combat-modal added), 2 (≤3 classes), 3 (each shell has its readable
  answer + now a cost), 6 (Loadout reserve is the canonical death-recap
  data shape for iter 11+ recap work), 7 (verbs not stats — `he_reserve`
  is a finite resource the player spends, not a passive multiplier)
- Constraints risked: 5 — band-aware spawning still not wired. Iter
  9-10 work.
- Sentence test: applies to HE; PASSES per iter 7 cite. C8 anchor 1
  held back: shells are base capabilities + the *upgrade* surface
  arrives with depot inventory iter 9+.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  writes #5 (PlayerTank.gd) + #6 (Level.gd). `make test` exit 0.
  `make test-all` PASS — all 5 arc-3 targets including the 25/35-stage
  chains (which fire AP bullets via the new 4-arg signal path with
  default shell_class=AP). All 5 arc-4 harnesses PASS.
- Falsifications: none. Pre-mortem predictions all held — signal arity
  mismatch handled by atomic update; hash anchor preserved; OG chain
  intact via default shell_class arg.
- CONSULT 001 status: ADOPTED. Tab reported error/timeout at 10:02
  elapsed; response landed on conversation page (arc-4 documented
  behavior — "tab-status=error ≠ consult-failed"). Findings:
  - Q1: "BC-plus-typed-shells-in-waiting" until shell choice changes
    route topology → iter 7 (HE radius) + iter 8 (finite reserve)
    answer this jointly
  - Q2: depots earned only after "visible breach cost" — iter 9+ wires
    2-choice depot AFTER a HE-choke band
  - Q3: "no player has yet sacrificed one resource to alter one route
    — that is the atomic verb" → iter 8 (this) ships the atomic verb
- Files: `scripts/Loadout.gd` (NEW Resource), `scripts/PlayerTank.gd`
  (substrate write #5 — sanctioned), `scripts/Level.gd` (substrate
  write #6 — extends shoot signal handler with shell_class default arg),
  `loop/breach/test_breach_loadout.gd` (NEW verifier), `Makefile` (new
  `check-breach-loadout` target), `loop/breach/creative-consults.md`
  (CONSULT 001 marked ADOPTED + full findings), `loop/breach/REVIEW-
  QUEUE.md` (item #2 — round 2 atomic verb), `loop/breach/PRE-MORTEMS.md`,
  `loop/breach/LEDGER.md`, `loop/breach/STATE.md`
- Finding: **The atomic verb landed.** Player has a finite HE reserve.
  KEY_TAB cycles AP→HE→HEAT, skipping empty mags. _fire() consumes the
  current shell from Loadout (AP unlimited; HE/HEAT decrement). Extended
  shoot signal: 4-arg `(bullet_scene, pos, dir, shell_class)`. Level
  handler accepts the 4th arg with default `shell_class = 0` (AP),
  preserving arc-3 OG chain-25/35 bit-identically (default arg means
  arc-3 callers don't need to update). The arc-2 procedural test fires
  no bullets in its 120-frame window so hash anchor untouched. **Round
  2 has shipped the CONSULT-named atomic verb in 2 iters (7+8)**. Next
  iter 9: 2-choice depot upgrade catalog (CONSULT 001 Q2 + Q3
  implication).

## iter 007 — BUILD — Bullet.gd HE radius + HEAT 2x (C3 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **8/50 absolute · 8/50 effective** (Δ +1 vs prior — C3 anchor 2)
  - C3 (Ammo as logistics): 1 → 2 (anchor 2: all 3 shells with distinct
    combat behavior — code-cited via `make check-breach-he-blast`
    reporting AP primary=1/radius=0, HE primary=1/radius=3,
    HEAT primary=2/radius=0)
  - C2=1, C4=1, C9=1, C10=3 unchanged
- Constraints respected: 2 (still 3 classes), 3 (each shell has a
  readable answer — HE→brick clusters, HEAT→2x damage, AP→precise), 7
  (HE is an affordance "creates lane through bricks" not "+18% splash";
  HEAT is a verb "doubles damage on hit")
- Constraints risked: 5 (band-aware enemy/terrain mapping not yet wired
  — HEAT 2x doesn't yet pair with heavy bunkers since no Heavy enemy
  spawns in breach mode yet; honest gap)
- Sentence test: HE passes — *"This upgrade helps me climb through brick
  mazes by changing how I use HE shells."* C8 anchor 1 candidate
  (eligible) but withheld this iter: shells are base capabilities, not
  upgrades; the iter that adds a depot-offered "HE Reserves +N"
  upgrade card lifts C8 cleanly.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #4 on Bullet.gd. `make test` exit 0. `make test-all` PASS (all
  5 arc-3 targets). All 4 arc-4 harnesses PASS (config, shells, depot,
  he-blast).
- Falsifications: none. Pre-mortem prediction "HE blast radius via
  sibling iteration may hit perf" — n/a in test (4 sibling stubs); arc-2
  brick cap ≤350 keeps it bounded.
- Files: `scripts/Bullet.gd` (substrate write #4 — second extension of
  same file, sanctioned), `loop/breach/test_breach_he_blast.gd` (NEW
  verifier), `Makefile` (new `check-breach-he-blast` target),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **First behavior-level breach landed.** `_on_body_entered`
  routes by shell_class: AP = arc-2 baseline (bit-identical),
  HEAT = damage × 2 on direct hit, HE = direct hit + radius blast to
  sibling bodies within 18px (≈1.1 tile radius). Breaks the
  "schema-before-mechanic" trap named in iter-6 CONSULT 001
  self-pre-mortem. CONSULT 001 still running (queryId 3ae82231…) — next
  iter checks back. Next iter 8 candidates: (a) wire shell-swap player
  input (PlayerTank substrate write — sanctioned), (b) extend HEAT for
  armor-bypass via EnemyHeavy facing, (c) read CONSULT 001 if returned
  and adjust.

## iter 006 — META + CONSULT — round 1 close + round 2 bootstrap-pending

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **7/50 absolute · 7/50 effective** (Δ 0 — META iter; no anchor lift expected)
  - Same buckets as iter 5: C2=1, C3=1, C4=1, C9=1, C10=3
- Constraints respected: all 7 (META iter; no design surface touched)
- Constraints risked: none
- Hash anchor: `23d6a2ec3bf2821f` trivially preserved (no code touched)
- Falsifications: none
- Files: `loop/breach/creative-consults.md` (consult 001 record),
  `loop/breach/REVIEW-QUEUE.md` (item #1 — round 1 finding),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **Round 1 closed (4 BUILD iters + this META). CONSULT 001
  fired fire-and-forget** via /agentify with the 3 permanent questions
  + my own embedded self-pre-mortem ("schema-before-mechanic risk;
  structural completion theater"). queryId
  `3ae82231-9889-4859-bfea-9ef0b78ae9b4`. Tab status: async dispatch
  confirmed. Per PROMPT trigger list, "After first end-to-end
  depot+band+breach-build run" — slightly liberal trigger interpretation
  (round 1 shipped schema for all 4 pieces; full integration in
  BreachLevel.tscn pending). REVIEW-QUEUE #1 logged with the
  schema-before-mechanic risk named for user awareness. Next iter 7:
  read CONSULT response + decide round-2 SPIKE target. Tentative plan
  pending CONSULT: HE-as-terrain-cracking (BrickBlock destruction by HE
  shells, creating breach lanes) — answers Q1 "is breach economy
  distinct from BC" by wiring the first *behavior*-level breach.

## iter 005 — BUILD — Depot.gd + Depot.tscn + pause-on-entry (C2 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **7/50 absolute · 7/50 effective** (Δ +3 vs prior — C2 anchor 1, C9 anchor 1, C10 anchor 3)
  - C2 (Field depot system): 0 → 1 (anchor 1: Depot.gd + Depot.tscn
    exist; combat pauses on entry — code-cited via `make
    check-breach-depot` reporting `BREACH_DEPOT_OK pause-on-entry
    contract verified`)
  - C9 (Identity / breach-roguelite singularity): 0 → 1 (anchor 1: ≥1
    mechanic with no analog in arc 2 — code-cited via three: shell-class
    schema (iter 4), depot pause-on-entry (this iter), depth-band
    structure (iter 3). Conservatively held this anchor until depots
    landed to consolidate the cite; arc-2 had no depot, no shell-class,
    no band structure)
  - C10 (Substrate preservation): 2 → 3 (anchor 3: arc-2 procedural mode
    plays identically when `breach_mode_enabled = false` — harness
    check: tile_hash 23d6a2ec3bf2821f bit-identical through all 4
    substrate writes; `make test` 120-frame runtime green at every
    iter)
  - C3=1, C4=1 unchanged; others still 0
- Constraints respected: 1 (no upgrade choices during active combat —
  depot's pause-on-entry IS the load-bearing protector of constraint 1;
  the schema *forces* upgrade flow to live at safe gates), 6 (depot is
  a natural segmentation point for death recap + pre/post-band metrics)
- Constraints risked: 1's flip-side — depot dwell must stay <30s; rubric
  anti-pattern names "depot dwell >30s OR depot UI requires reading
  during pursuit by enemies = automatic 0 on C2". This iter doesn't
  yet implement upgrade flow so dwell is unbounded by design (just
  walk in/out). Iter 6+ adds the choice + the 30s budget; honest gap.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (no substrate
  touched). `make test` exit 0. `make test-all` PASS. `make
  check-breach-config` PASS. `make check-breach-shells` PASS. `make
  check-breach-depot` PASS (NEW).
- Falsifications: minor — predicted SceneTree subclass timing issue in
  the depot harness; confirmed (needed `_initialize()` + `await
  process_frame` per arc-3 `loop/test_chain_25.gd` precedent rather
  than `_init()`). Not codified — single-session lesson; pattern lives
  in arc-3's PROMPT v3 candidate pattern 5 already.
- Files: `scripts/Depot.gd` (NEW), `scenes/Depot.tscn` (NEW),
  `loop/breach/test_breach_depot.gd` (NEW verifier), `Makefile` (new
  `check-breach-depot` target), `loop/breach/PRE-MORTEMS.md`,
  `loop/breach/LEDGER.md`, `loop/breach/STATE.md`
- Finding: **Depot pause-on-entry contract landed.** Depot.gd is an
  Area2D with `process_mode = PROCESS_MODE_ALWAYS` (so `body_exited`
  can fire while tree is paused). `_on_body_entered` filters to player
  via group tag (`player` group) or duck-type fallback
  (`_on_PlayerTank_shoot` method) — does NOT pause for enemies passing
  through the depot zone. Combat-pause is the structural protection of
  CONSULT constraint 1 (no upgrade choices during active combat). Iter
  6+ adds the upgrade-choice UI + the 30s dwell budget. **Next iter
  candidates**: (a) C4 anchor 2 trivial lift (add band 3 to .tres),
  (b) C5/C6/C8 schema scaffolding (Loadout / RunRecap / first upgrade
  with sentence-test cite), (c) iter-5 round-close + CONSULT.

## iter 004 — BUILD — Bullet.gd shell_class flag + AP/HE/HEAT constants

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **4/50 absolute · 4/50 effective** (Δ +2 vs prior — C3 anchor 1, C10 anchor 2)
  - C3 (Ammo as logistics): 0 → 1 (anchor 1: 3 shell types in code,
    player can fire any via @export or start() override — code-cited via
    `make check-breach-shells` reporting `BREACH_SHELLS_OK 3 distinct
    shell classes, default = AP`)
  - C10 (Substrate preservation): 1 → 2 (anchor 2: same + `make test-all`
    passes through all substrate-touching iters — iters 2, 3, 4 all
    green on 5 arc-3 targets after substrate edits)
  - C4 still at 1; others still at 0
- Constraints respected: 2 (exactly 3 primary shell classes — AP/HE/HEAT,
  no more), 1 (no combat modal — flag is data-only), 7 (verbs not stats
  — shell class routes to terrain/behavior affordances in later iters,
  not to +damage% upgrades), 4 (silhouette grammar — Bullet sprite gets
  modulate-only diff per shell; full silhouette work deferred to gen_tile
  pipeline)
- Constraints risked: 3 (every enemy must have readable shell/positioning
  relationship) — shell_class field exists but per-class **behavior**
  not yet wired (HE→terrain, HEAT→armor). Iter 5+ implements; honest
  scaffolding gap documented + scheduled per the iter-5 plan.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #3 (Bullet.gd). `make test` exit 0. `make test-all` PASS (all 5
  arc-3 targets). `make check-breach-config` PASS. `make
  check-breach-shells` PASS (NEW).
- Falsifications: none
- Files: `scripts/Bullet.gd` (substrate write #3 — sanctioned per PROMPT
  §SUBSTRATE FREEZE; chose extend-vs-new-Shell.gd per Scout A's spike),
  `loop/breach/test_breach_shells.gd` (NEW verifier), `Makefile` (new
  `check-breach-shells` target), `loop/breach/PRE-MORTEMS.md`,
  `loop/breach/LEDGER.md`, `loop/breach/STATE.md`
- Finding: **Bullet.gd shell-class schema landed.** 3 constants
  (SHELL_CLASS_AP=0, _HE=1, _HEAT=2) + `@export var shell_class: int =
  SHELL_CLASS_AP` + `start()` extended with optional `shell: int = -1`
  override param + visual modulate hint per non-AP class. Arc-2 baseline
  bullet fires AP identically (no override); hash anchor preserved.
  Per-shell-class **behavior** (HE terrain-cracking, HEAT armor-bypass)
  is iter 5+ work. Next iter: scripts/Depot.gd + scenes/Depot.tscn (C2
  anchor 1).

## iter 003 — BUILD — BreachConfig + BreachBand + breach_default.tres (2 bands)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **2/50 absolute · 2/50 effective** (Δ +1 vs prior — C4 anchor 1)
  - C4 (Depth bands): 0 → 1 (anchor 1: BreachConfig.gd encodes ≥2
    distinct bands with different terrain weights — code-cited via
    `make check-breach-config` reporting `BREACH_CONFIG_OK 2 bands,
    distinct terrain weights`)
  - C10 (Substrate preservation): still 1 (hash anchor preserved through
    iter 3's substrate write #2 — type tightening on `breach_config`
    @export)
  - All other 8 criteria still at 0
- Constraints respected: 4 (silhouette grammar — BreachBand schema
  constrains bands to declared terrain rosters, can't invent mechanics),
  5 (each band has a dominant terrain pressure — `dominant_pressure`
  field), 7 (verbs not stats — BreachBand has no damage/stat fields, only
  terrain + canonical-answer descriptors). Others n/a (no shell, no
  depot, no enemy this iter).
- Constraints risked: 5 if future bands ship without filled
  `dominant_pressure` (schema-defended; runtime check possible)
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #2. `make test` exit 0. `make test-all` PASS (all 5 arc-3
  targets). `make check-breach-config` PASS (new arc-4 target).
- Falsifications: none. Pre-mortem prediction "typed-Array .tres syntax
  may have a quirk" — confirmed quirk-free (`Array[Resource]([...])`
  works). Pre-mortem prediction "preload may be needed for cross-script
  type refs" — confirmed: 3 files needed preload+alias pattern
  (BreachBand.gd preloads LevelConfig; BreachConfig.gd preloads
  BreachBand; ProceduralLevel.gd preloads BreachConfig). Same pattern
  as arc-1 LevelConfigT precedent.
- Files: `scripts/BreachBand.gd` (NEW), `scripts/BreachConfig.gd` (NEW),
  `configs/breach_default.tres` (NEW), `scripts/ProceduralLevel.gd`
  (substrate write #2 — tightened @export type), `Makefile` (new
  `check-breach-config` target), `loop/breach/test_breach_config.gd`
  (NEW verifier), `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **BreachConfig schema landed.** Two-band sample
  (tutorial_choke @ depth 0-30 / brick_maze @ depth 30-70) with distinct
  LevelConfig sub-resources per band (brick_weight 0.55 vs 0.70,
  water_weight 0.10 vs 0.05). Schema directly mirrors BANDS.md roadmap.
  C4 anchor 1 cited via the new harness target. Depth-band runtime
  tracking (looking up the active BreachBand in `_process_breach_depth`)
  is still a stub — iter 4 or 5 will wire that. Next iter: shells.

## iter 002 — BUILD — DECISION (adopt path A) + first substrate hook on ProceduralLevel.gd

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **1/50 absolute · 1/50 effective** (Δ +1 vs prior — C10 anchor 1)
  - C10 (Substrate preservation): 0 → 1 (anchor 1: hash anchor verified
    iter 0 + preserved through ≥3 iters of arc-4 work — iters 0/1/2 with
    iter 2 being the first substrate-touching write)
  - All other 9 criteria still at 0 (no feature surface yet)
- Constraints respected: all 7 (substrate plumbing; flag-off codepath
  bit-identical to arc-2 baseline)
- Constraints risked: none this iter
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED bit-identical post-edit**
  (procedural oracle on seed 42 / default config). `make test` exit 0.
  `make test-all` PASS on all five arc-3 targets (ALL_LOADER_TESTS_PASS,
  CHAIN_25_OK, CHAIN_35_OK, ARC_COMPLETE_OVERLAY_OK, TITLESCREEN_NAV_OK).
- Falsifications: none
- Files: `scripts/ProceduralLevel.gd` (substrate write #1; sanctioned per
  PROMPT §SUBSTRATE FREEZE iter-1 path A + §DEFAULT-ON SUBSTRATE GATING
  TEMPLATE), `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **Path A landed cleanly.** Added two `@export` vars
  (`breach_mode_enabled: bool = false`, `breach_config: Resource = null`)
  + two conditional branches after the RNG-touching baseline (after
  `force_update_scroll()` in `_ready`; after row-generation block in
  `_process`) + two stub methods at file tail. Flag-off codepath produces
  bit-identical tile_hash on seed 42. The pre-mortem's `[QUALITY]` hedge
  was conservatively pessimistic — C10's substrate-preservation anchor
  did lift on this iter, so the iter is honestly BUILD not BUILD-QUALITY.
  Next iter: BreachConfig.gd + `breach_config: BreachConfig` typed +
  first depth-band stub (lifts C4 anchor 1).

## iter 001 — SPIKE — mode-integration path A vs B

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: 0/50 (Δ 0 vs prior — SPIKE iters are investigation, not anchor lift)
- Constraints respected: all 7 (read-only investigation; no design surface touched)
- Constraints risked: none
- Hash anchor: n/a (no substrate touch; verification deferred to iter 2 BUILD)
- Falsifications: none
- Files: `loop/breach/iter-001-spike-report.md` (blueprint stash per L2),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`
- Finding: **Path A SHIP (default-on `breach_mode_enabled` flag on
  `ProceduralLevel.gd`). Path B REFINE (do not adopt as default).** Two
  parallel scouts converged independently. Load-bearing argument is
  hash-anchor bit-identicality: `ProceduralLevel.gd:42-77` (RNG-touching
  baseline) precedes any flag branch, so `tile_hash=23d6a2ec3bf2821f` is
  preserved when `breach_mode_enabled=false`. Path B's only saving is
  one default-off boolean; H1 surface burden + ProceduralStep row-regen
  fork risk make it strictly worse. Effort estimate: ~5-7 BUILD iters
  from flag-added to first end-to-end breach run.

## iter 000 — META — preloop complete + substrate verified

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: 0/50 (baseline; rubric exists, no work scored yet)
- Constraints respected: n/a (no design work this iter)
- Constraints risked: n/a
- Hash anchor: `23d6a2ec3bf2821f…` verified on seed 42 / default procedural config
- Falsifications: none
- Files: `loop/breach/STATE.md`, `loop/breach/LEDGER.md`, `loop/breach/PRE-MORTEMS.md`, `loop/breach/REVIEW-QUEUE.md`, `loop/breach/FALSIFICATIONS.md`, `loop/breach/creative-consults.md` (scaffolded)
- Finding: All three substrate layers green. `make test` exit 0. Procedural
  oracle on seed 42 reports `tile_hash=23d6a2ec3bf2821f`, `reachable=676`,
  `playable=true`. OG `check-loader` + `check-chain` (25 stages) pass.
  Preloop reads (arc-1/2/3 retros + cross-arc lessons L1-L6/R1-R4 + arc-4
  CONSULT) complete. `preloop_complete: yes`. Next iter: SPIKE on
  mode-integration path A (default-on `breach_mode_enabled` flag on
  `ProceduralLevel.tscn`) vs path B (sibling `BreachLevel.tscn`), per
  PROMPT first-iter note + L1 (spike-before-build).
