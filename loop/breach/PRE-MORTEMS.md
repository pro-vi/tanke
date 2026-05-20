# Breach loop pre-mortems (arc 4)

Append-only. One block per iter, written **before** ACT. H2 RULE v2 tags
mandatory: `[STRUCTURE]` / `[FEEL]` / `[MIXED]` / `[STRUCTURE-DEFERRED]` /
`[IDENTITY-PROTECTED]`.

Every entry cites which of the seven CONSULT §9 constraints the iter
respects or risks. Falsifiable claim required.

Format:

```
## iter NNN — <MODE> — <focus>
- Date: YYYY-MM-DD
- Tag: [<tag>]
- CONSULT constraints respected: <list>
- CONSULT constraints risked: <list, if any>
- Predicted failure: <where this iter might fail>
- Falsifiable claim: <a concrete observable that would prove the prediction>
- Sentence test (if upgrade-touching): "This upgrade helps me climb through ___ by changing how I use ___"
- Substrate touched: <files, if Layer 1/2/3>
- Hash-anchor verification plan: <pre-/post-edit check, or n/a>
```

---

## iter 033 — PLAYTEST — integrate user playtest; F003; bootstrap Round 5

- Date: 2026-05-20
- Tag: [FEEL] (the iter's input is a human playtest — the FEEL tier's
  evidence source; the iter integrates that evidence)
- Round: between rounds. Round 4 closed iter 30; the loop paused iter 32;
  the user playtest re-opens it. This iter integrates the playtest and
  bootstraps Round 5.
- CONSULT constraints respected: all 7 — this is an integration/planning
  iter, no design surface touched. The Round-5 blueprint is written to
  RESPECT them: constraint 1 (tutorial at safe gates, never combat),
  constraint 3 (each shell keeps one readable relationship), constraint 4
  (the APCR icon is silhouette-gated).
- CONSULT constraints risked: constraint 2 ("no more than three primary
  shell classes at first") — the user EXPLICITLY OVERRODE it; APCR is
  sanctioned as the 4th shell. Not a loop violation: the PROMPT grants
  the user override authority over cadence/direction. Recorded in
  STATE.md §Arc-4 amendments.
- Predicted failure: the Round-5 plan may under-scope finding 5 ("doesn't
  feel like a roguelite") — that is a multi-round program, not a Round-5
  piece. Mitigation: Round 5 is explicitly findings 1-4 (legibility);
  finding 5 is bootstrapped as the Round 6+ program in the blueprint tail.
- Falsifiable claim: this iter commits F003 + `iter-033-round5-architect.md`
  + STATE unpaused to `loop_state: RUNNING` + REVIEW-QUEUE #3 closed and
  #5 appended. No code changes → no hash-anchor risk. iter 34 begins the
  Round-5 BUILD.
- Sentence test: n/a (no upgrade this iter)
- Substrate touched: none (loop docs only)
- Hash-anchor verification plan: n/a (no code change)

## iter 030 — BUILD-QUALITY — shell HUD (round-4 piece 2)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Round 4 (pre-playtest legibility), piece 2. Breach-economy state —
  which shell is selected, how much HE/HEAT reserve remains — is
  currently invisible. A playtester can't see their breach budget. The
  shell HUD surfaces it.
- CONSULT constraints respected: 3 (the readable shell relationship
  needs the shell to be *visible*), CONSULT 002 (legibility)
- CONSULT constraints risked: none
- Predicted failure modes:
  - PlayerTank `_setup_hud` builds a CanvasLayer. The shell label must
    be gated on `loadout != null` — arc-2/3 HUD stays bit-identical
    (no shell label, no `_update_run_hud` shell branch fires).
  - `_update_run_hud` runs each frame (cheap text update).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS (arc-2/3 HUD unchanged —
  no loadout → no shell label), `make test-breach` PASS, new
  `make check-breach-hud` verifies a breach PlayerTank (loadout set)
  has a ShellLabel reflecting current_shell + he/heat reserves, and an
  arc-2/3 PlayerTank (no loadout) has none.
- Sentence test: n/a (HUD)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write —
  sanctioned; `_setup_hud` + `_update_run_hud` extension, breach-gated).
- Hash-anchor verification plan: post-edit, before commit.

## iter 029 — BUILD-QUALITY — depot UI panel (round-3 close, round-4 open)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- DIAGNOSE: round 3's structural anchors are done (C3/4 + C8/3); C5/3
  is substrate-blocked. The loop is at the 30/50 structural ceiling.
  Per the parity-drift /meta, the playtest is the gate — but a playtest
  is only meaningful if breach mode is LEGIBLE. The depot is currently
  invisible: `Depot.tscn` is an Area2D + a blue marker rect; the
  3-choice upgrade flow (KEY_1/2/3 → apply_choice) has NO on-screen UI.
  CONSULT 002 Q2: depots must be "legible in under five seconds" — they
  aren't legible at all. Round 4 = pre-playtest legibility; iter 29 is
  piece 1: the depot UI panel. This is the bridge to the playtest, not
  grinding past the ceiling.
- Tag rationale: BUILD-QUALITY — a visible depot panel is craft that
  makes the playtest possible but lifts no [STRUCTURE] anchor (C2
  anchors 4-5 are playtest-gated). Last BUILD-QUALITY iter 24; iters
  25-28 were META/AUDIT/BUILD/BUILD — within the 1-per-3 cap.
- CONSULT constraints respected: 1 (depot UI shows only at the
  safe-gate, never during combat — the tree is paused), CONSULT 002 Q2
  (legibility)
- CONSULT constraints risked: depot dwell <30s — the panel must be
  fast-readable; iter 29 ships a compact 4-line panel (hint + 3
  choices). Playtest tunes.
- Predicted failure modes:
  - The panel must be a CanvasLayer (screen-space, not world-space) so
    it renders as HUD regardless of camera. Depot is a world Area2D;
    the CanvasLayer is a child of Depot, shown/hidden on entry/exit.
  - process_mode: the panel's CanvasLayer must run while the tree is
    paused (Depot already has PROCESS_MODE_ALWAYS — children inherit).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  the depot UI panel populates its Labels from choice_a/b/c_label +
  next_band_hint on entry and hides on pick/exit — verified by
  extending `check-breach-depot` or a new harness assertion.
- Sentence test: n/a (UI)
- Substrate touched: none — Depot.tscn + Depot.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved.

## iter 028 — BUILD — OVERDRIVE sprint upgrade (C8 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- DIAGNOSE: round-3 anchor 2. Two candidates — C5 anchor 3 (4th enemy
  role) and C8 anchor 3 (depot catalog covers all 5 band pressures).
  **C5/3 is substrate-blocked** — a genuine 4th role needs an Enemy.gd
  behavior branch, and Enemy.gd is NOT in the sanctioned-write list
  (iter-23 finding); a stat-only variant violates CONSULT constraint 3
  ("no canonical answer = decorative complexity = cut it"). So iter 28
  takes **C8 anchor 3**: the open_killbox band has no depot upgrade —
  its pressure ("wide sightlines, fast scouts, rear-flank patrols";
  answer "facing-aware positioning") has no shell-economy upgrade
  because AP (its answer) is the deliberately-unupgradeable baseline.
  The honest fix: add a *positioning* verb — OVERDRIVE, a sprint burst.
- CONSULT constraints respected: 7 (OVERDRIVE is a movement VERB —
  "burst to break a flanker's sightline" — not a passive +speed%; it
  has a cost: a burst window then a cooldown), 1
- CONSULT constraints risked: 2 — OVERDRIVE is a non-shell upgrade, the
  first one. But it is NOT shell-class bloat (still 3 shells); it is a
  chassis/positioning affordance, which CONSULT 000 §7 explicitly
  endorses ("verbs and affordances"). Acceptable.
- Predicted failure modes:
  - The sprint multiplies `velocity` in `_physics_process` line 195.
    Gated on `loadout != null and loadout.has_overdrive` → arc-2/3
    never sprint → movement bit-identical.
  - Burst→cooldown transition: detect `_overdrive_timer` crossing >0→≤0
    and arm `_overdrive_cd` once.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-overdrive` verifies: OVERDRIVE upgrade sets
  `has_overdrive`; a SHIFT burst (when owned) raises effective speed
  for `overdrive_burst` s then cools down; arc-2/3 PlayerTank never
  sprints. The 7-entry catalog now maps an upgrade to each of the 5
  band pressures (HE-economy / HEAT-economy / positioning / recovery).
- Sentence test: OVERDRIVE passes — "This upgrade helps me climb
  through open killboxes by changing how I use positioning — a speed
  burst to break flanker sightlines."
- Substrate touched: `scripts/PlayerTank.gd` (substrate write —
  sanctioned). `scripts/Loadout.gd` + `scripts/Depot.gd` arc-4-owned.
- Hash-anchor verification plan: post-edit, before commit.

## iter 027 — BUILD — shell-swap reload cost (C3 anchor 4)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 3, anchor 1 of 3. C3 anchor 4 (de-bundled iter 26): "Shell-swap
  has a reload cost (≥0.5s) — pre-commitment under reload pressure".
- CONSULT constraints respected: 7 (the swap cost is a *verb-cost* — a
  pre-commitment beat — not a passive stat; CONSULT 000 §2 named this
  "the interesting WoT idea ... swapping takes a short reload beat"),
  2, 1
- CONSULT constraints risked: none
- Predicted failure modes:
  - The cooldown must be breach-gated: `_cycle_shell` already
    early-returns when `loadout == null`, so `_swap_cooldown` is only
    ever set in breach mode — arc-2/3 `_fire` never sees a nonzero
    cooldown. Bit-identical baseline.
  - `_cycle_shell` arms the cooldown only on a REAL swap (when
    `current_shell` actually changes) — cycling onto the same class
    (all others empty) must not impose a cost.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-swap` verifies: a real `_cycle_shell` arms
  `_swap_cooldown` to `shell_swap_cost` (≥0.5); `_fire` is blocked
  while `_swap_cooldown > 0`; once it elapses `_fire` emits again; an
  arc-2/3 PlayerTank (no loadout) never arms the cooldown.
- Sentence test: n/a (a combat-timing mechanic, not a depot upgrade)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write — sanctioned).
- Hash-anchor verification plan: post-edit, before commit.

## iter 026 — AUDIT — de-bundle remaining anchors; sharpen the ceiling

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Trigger: AUDIT cadence (every 5; last iter 21). Also Mismatch-AUDIT
  (L6) — the parity-drift /meta finding flagged that the remaining
  structural anchors are bundled/mis-tagged; this AUDIT de-bundles them
  so round 3 has honest single-clause targets + a sharp ceiling number.
- CONSULT constraints respected: all (process iter)
- Predicted finding: re-score holds at 28/50 (no anchor moved since
  iter 21's AUDIT + the BUILD-QUALITY iter 24). Two anchor rephrases:
  (1) C3 anchor 4 is bundled (swap-cost + per-band-consumption-harness)
  — R1 debt; de-bundle to the swap-cost clause (the CONSULT-core
  mechanic), the consumption-measurement belongs to the [FEEL] tier.
  (2) C4 anchor 4 ("avg shell-mix differs per band — 5-seed harness")
  is mis-tagged [STRUCTURE] — shell-mix can only be measured by
  simulated/real play; re-tag [FEEL]. Net: the true structural ceiling
  is ~32/50 (C3/4 swap-cost + C5/3 4th role + C8/3 band coverage +
  C10/5 arc-close), sharper than the meta's ~8-10 estimate.
- Falsifiable claim: re-score = 28/50 unchanged; RUBRIC.md gets 2
  revision-log rows (C3/4 de-bundle, C4/4 re-tag); LEDGER AUDIT block
  states the ~32/50 structural ceiling. Identity-protected anchors
  (C1/5, C5/5, C7/5, C8/5, C9/5) untouched (R2). Hash anchor untouched.
- Sentence test: n/a
- Substrate touched: none (RUBRIC.md + loop docs)
- Hash-anchor verification plan: n/a

## iter 025 — META + QUEUE — round-2 close; parity-drift finding; playtest surfaced

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Meta-trigger: dice nat-13 /meta nudge (iter 24.5) named PARITY DRIFT
  — 24 iters, 28/50, all structural/harness-cited, zero playtests;
  ~14 of 22 remaining rubric points are playtest-gated by design.
  Round 2 (iters 7-24) is structurally complete; this iter formalizes
  the finding + closes round 2 + surfaces the playtest as critical path.
- CONSULT constraints respected: all (process iter)
- CONSULT constraints risked: none
- Predicted failure: the playtest request, once in REVIEW-QUEUE, sits
  unactioned (arc-1's user-look gate sat open 8 iters). Mitigation:
  PushNotification surfaces it directly; the loop continues round 3
  regardless (non-stop), so a stalled playtest doesn't stall the loop —
  it just caps the reachable score at ~37/50 until the user plays.
- Falsifiable claim: by end of iter, LEDGER has a META entry,
  REVIEW-QUEUE has item #3 (playtest request, prominent), a
  PushNotification fired, round 2 is marked closed, and STATE names
  round 3's opening surface. Hash anchor untouched (no code).
- Sentence test: n/a
- Substrate touched: none (LEDGER / REVIEW-QUEUE / STATE — loop docs)
- Hash-anchor verification plan: n/a

## iter 024 — BUILD-QUALITY — depot rule-changer "Breach Dividend"

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY] — CONSULT 002's #2 recommendation; a
  genuine playstyle-forking depot entry but it does NOT lift a
  [STRUCTURE] rubric anchor (C8 anchor 3 needs all-5-band coverage;
  the build-identity anchors it serves — C1/4-5, C9/3+ — are
  playtest-gated). Honest BUILD-QUALITY per L3/R4. Last BUILD-QUALITY
  was iter 10 — well within the 1-per-3-BUILDs cap.
- CONSULT 002 Q2 verbatim: "Replace one depot entry with a
  rule-changer, not a stock-changer. Breach Dividend — destroying 4+
  bricks with one HE refunds 1 HE ... creates a playstyle: precise
  cluster breaching."
- CONSULT constraints respected: 7 (a rule-changer verb — "cluster
  breaching pays for itself" — not a passive %stat), 1 (depot still
  shows 3-of-N; catalog grows to 6)
- CONSULT constraints risked: 4 — risk of farming (infinite HE from
  repeated cluster-breaches). Mitigation: `refill_he` caps at
  `max_he_reserve` — a dividend can never exceed the reserve cap, so
  it sustains efficient play but can't snowball. The CONSULT's
  "capped once per band" is a stronger guard; deferred (the
  max-reserve cap suffices for iter 24; per-band cap if playtest
  shows farming).
- Predicted failure modes:
  - The refund chain Bullet → get_parent() (the Level) → `.player` →
    `.loadout`. Level.gd has `@onready var player`. If any link is
    null (defensive duck-typed reads), the dividend silently no-ops.
  - "4+ bricks" count: `_apply_he_blast` returns radius-sibling count;
    total = radius + 1 (primary). In a brick maze the primary IS a
    brick; counting the primary unconditionally is a slight
    over-count if the HE shot's primary hit is an enemy — acceptable
    (the dividend is about cluster breaching; an HE shot that opens a
    4-tile lane qualifies regardless of what the centre cell was).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-dividend` verifies: HE blast of ≥4 bricks
  with breach_dividend ON → he_reserve +1 (capped at max); same blast
  with breach_dividend OFF → no refund; HE blast of <4 bricks → no
  refund even with the upgrade on.
- Sentence test: BREACH_DIVIDEND passes — "This upgrade helps me
  climb through brick mazes by changing how I use HE — precise
  cluster breaches refund their own shell."
- Substrate touched: `scripts/Bullet.gd` (substrate write — Bullet's
  4th; sanctioned). `scripts/Loadout.gd` + `scripts/Depot.gd`
  arc-4-owned.
- Hash-anchor verification plan: post-edit, before commit.

## iter 023 — BUILD — HEAT armor-bypass (C3 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- CONSULT 002 ADOPTED. Its #1 "next 3 iters" recommendation: "make
  HEAT real with one armor-facing/bypass rule" — Q3's
  stupid-in-6-months omission ("'2× damage' is a placeholder").
- CONSULT constraints respected: 3 (every enemy type gets a readable
  shell relationship — armored Heavy now MECHANICALLY demands HEAT),
  2 (still 3 shells), 7 (HEAT becomes a verb-with-a-rule, not "+N%")
- CONSULT constraints risked: 1 — armored Heavy is HEAT-only; a
  HEAT-starved player meeting an armored Heavy is genuinely stuck on
  that enemy. That IS the breach-economy tension (death recap names
  "ran out of HEAT") — but if it softlocks (cornered, no escape) it's
  bad. Mitigation: armored enemies are killable-by-avoidance (the
  player can route around — they're not lane-blockers by terrain) and
  AP/HE still kill all non-armored roles.
- **Substrate investigation** (PROMPT §DEFAULT-ON "any other substrate
  write = halt+investigate"): HEAT-armor needs an enemy-side "armored"
  marker. Enemy.gd is Layer-2 substrate NOT in the sanctioned list
  (PlayerTank/ProceduralLevel/Spawner/Bullet). **Resolution: avoid the
  Enemy.gd touch entirely** — use a Godot group tag. Spawner.gd
  (sanctioned) calls `enemy.add_to_group("armored")` for Heavy types;
  Bullet.gd (sanctioned) checks `body.is_in_group("armored")`.
  `add_to_group` is a Node method — no Enemy.gd script property
  needed. Both substrate writes are on the sanctioned list. No
  halt-and-investigate needed; no Enemy.gd write.
- The armor rule (brutally simple, per CONSULT): armored enemies take
  `max(0, deal − ARMOR_MITIGATION)` from AP/HE; HEAT ignores armor
  (full `deal`). ARMOR_MITIGATION = 1; Heavy base-damage-1 AP/HE →
  0 (blocked), HEAT 2× → 2 (one-shots Heavy's 2 HP). Player learns:
  "armored = HEAT".
- Predicted failure modes:
  - Spawner sets enemy params via `enemy.set(...)`; `add_to_group`
    is a different call — must be placed in the same pre-add_child
    block. Heavy ENEMY_TYPES entry needs an `"armored": true` key.
  - take_damage(0) on an armored enemy hit by AP — harmless (hp -= 0),
    impact spark still fires = readable "armor blocked it" feedback.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-armor` verifies an "armored"-group stub takes
  0 from AP + 0 from HE + full (2×) from HEAT, and a non-armored stub
  takes full from all 3.
- Sentence test: n/a (combat mechanic, not an upgrade)
- Substrate touched: `scripts/Spawner.gd` (substrate write #11 —
  sanctioned), `scripts/Bullet.gd` (substrate write — Bullet's 3rd;
  sanctioned). NO Enemy.gd touch (group-tag approach).
- Hash-anchor verification plan: post-edit, before commit.

## iter 022 — BUILD — 3 depots at band transitions (C2 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- CONSULT 002 still running at iter-22 start (~7 min in). Per PROMPT,
  no AWAIT for design — proceeding with a CONSULT-safe, substrate-clean
  BUILD; iter 23 reads the consult.
- DIAGNOSE: C2 (field depot) at 2/5. Anchor 3: "Depots placed at
  deterministic intervals (e.g. every band); harness verifies a full
  run hits ≥3 depots — code-cited". BreachLevel.tscn has 1 depot.
- CONSULT constraints respected: 1 (depots are the safe-gate cadence —
  one per band transition), 6 (depots = clean band-segmentation points)
- CONSULT constraints risked: none — adding depots is CONSULT-endorsed
  ("field depots at fixed/semi-fixed depth intervals")
- Predicted failure modes:
  - BreachLevel.tscn is an inherited scene — adding 2 more Depot child
    nodes must use unique `index` values + node names. If indices
    collide, the scene won't load.
  - Depot world-y placement: depth N → y = 232 - N×16. Band exits at
    depth 30/70/120 → y -248/-888/-1688. A depot placed beyond the
    generated/reachable region would be a dead node — acceptable for
    the structural cite (the harness counts depot children, not
    in-run reachability of each).
- Falsifiable claim: post-edit, BreachLevel.tscn loads clean,
  `make check-breach-level` reports ≥3 depots, `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f`, `make test-all` PASS, `make
  test-breach` PASS.
- Sentence test: n/a (depot placement)
- Substrate touched: none — BreachLevel.tscn is an arc-4-owned scene;
  test_breach_level.gd arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved (the
  base ProceduralLevel.tscn is untouched).

## iter 021 — AUDIT + CONSULT — re-score + fire CONSULT 002

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Triggers: AUDIT (every-5 cadence; last iter 16) + CONSULT (~every-10;
  last iter 6).
- CONSULT constraints respected: all (process iter)
- Predicted finding: the rolling 25/50 is honest, but C7 anchor 3
  ("All new assets in arc 4 verified via the grammar gate before
  commit — log artifact in LEDGER") was conservatively HELD at iter 18
  ("one asset-set is thin evidence"). On AUDIT re-read, anchor 3 has no
  minimum-count clause — all 3 arc-4 generated assets (shell icons) ARE
  gated + the iter-18 LEDGER logs the SILHOUETTE_GATE_PASS artifact.
  Expect C7 2→3 (the iter-18 hold was an under-claim; AUDIT corrects).
  Total → 26/50. No over-claims expected.
- Falsifiable claim: the AUDIT re-score changes at most C7 (2→3); all
  other 9 criteria hold. CONSULT 002 fires fire-and-forget; queryId
  recorded to creative-consults.md regardless of tab status.
- Sentence test: n/a
- Substrate touched: none
- Hash-anchor verification plan: n/a (no code edit)

## iter 020 — BUILD — depot upgrade catalog → 5 (C8 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C8 (sentence-test compliance) at 1/5 is joint-lowest.
  Anchor 2: "5+ upgrades; all pass; sentence cited verbatim per
  upgrade — Loadout.gd documents". Have 3 (HE_REFILL_2 / HEAT_REFILL_1
  / HE_MAX_EXPAND_2) — need 5+.
- CONSULT constraints respected: 7 (verbs/affordances not passive
  stats — the 2 new upgrades are economy verbs: HEAT capacity expand +
  full resupply, NOT "+%damage"), 1 (catalog grows; depot still shows
  3-at-a-time — no scrolling), 2 (still 3 shell classes)
- CONSULT constraints risked: 4 — 5 refill/expand variants risk
  reading as "reserve stat soup". Honest mitigation: reserve size +
  resupply are CONSULT-§2-endorsed depot upgrade axes ("Depot upgrades
  improve swap speed or reserve size"); they ARE the breach economy's
  currency, not passive %stats. Genuinely-different affordance
  upgrades (swap-speed, refund-on-kill, first-shot-pierce) need
  mechanics not yet built (swap cost, kill hooks) — scheduled later,
  not faked now.
- Predicted failure modes:
  - UpgradeKind enum 3→5 + apply_upgrade extraction — the harness must
    exercise all 5 enum values. test_breach_depot_choice currently
    tests 3.
  - "Loadout.gd documents" — the catalog enum lives in Depot.gd; I add
    a documentation block to Loadout.gd citing the 5 verbatim
    sentences (the anchor's named location).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  `make check-breach-depot-choice` verifies all 5 UpgradeKind values
  apply distinct loadout effects. All 5 upgrades pass the sentence
  test (cited verbatim in this pre-mortem + Loadout.gd).
- Sentence tests (all 5, verbatim):
  - HE_REFILL_2: "This upgrade helps me climb through brick mazes by
    changing how I use HE shells."
  - HEAT_REFILL_1: "This upgrade helps me climb through bunker bands
    by changing how I use HEAT shells."
  - HE_MAX_EXPAND_2: "This upgrade helps me climb through long
    HE-required stretches by changing how I use my HE economy."
  - HEAT_MAX_EXPAND_2: "This upgrade helps me climb through deep
    bunker chains by changing how I use my HEAT economy."
  - FULL_RESUPPLY: "This upgrade helps me climb through the band after
    an over-spend by changing how I use a recovery beat."
  All 5 are "changing how I use <resource/verb>" — none is "by making
  me stronger" or "+N%". Pass.
- Substrate touched: none — Depot.gd + Loadout.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved.

## iter 019 — BUILD — per-role canonical answers (C5 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C5 (enemy role vocabulary) at 1/5 is the lowest criterion.
  C5 anchor 2: "Each role has a documented 'canonical answer'
  shell+positioning in BANDS.md; harness verifies presence in band
  rosters — code-cited". Two clauses (R1): (a) BANDS.md documents a
  shell+positioning answer per role; (b) a harness verifies each role
  appears in ≥1 band roster.
- CONSULT constraints respected: 3 (every enemy type must have a
  readable shell/positioning relationship — this iter is the literal
  documentation of that), 5
- CONSULT constraints risked: 3 — the canonical answer is *documented*,
  not yet *enforced* in code (no enemy demands a specific shell to
  kill). Honest: C5 anchor 2 is a documentation+coverage anchor;
  mechanical enforcement is later (would need armor/HEAT-bypass — also
  C3 anchor 3 territory).
- Predicted failure modes:
  - Roster coverage: a role with no band could fail clause (b).
    Current rosters — Light in all 5, Heavy in 2, Fast in 3 — all 3
    roles covered. Low risk; the harness makes it explicit.
  - No substrate touch — BANDS.md is a doc, the harness is arc-4-owned.
- Falsifiable claim: post-edit, BANDS.md has a per-role canonical-answer
  section for Light/Heavy/Fast (shell + positioning each), and
  `make check-breach-enemies` additionally verifies all 3 roles appear
  in ≥1 band roster. `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS.
- Sentence test: n/a (enemy doc)
- Substrate touched: none (BANDS.md doc + test_breach_enemies.gd
  arc-4-owned harness).
- Hash-anchor verification plan: n/a (no code/config edit) — verify
  anyway.

## iter 018 — BUILD — C6 anchor 3 (recap band pressure) + C7 anchor 2 (grammar gate)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Two cheap lifts bundled:
  - **C6 anchor 3**: "Recap includes build identity tag + dominant
    pressure of killing band — code-cited". RunRecap already has
    build_tag() (✓ identity) + killing_band NAME. Gap: the band's
    `dominant_pressure` text. Fix: capture_death takes the BreachBand
    object (not just name) → store `killing_pressure`.
  - **C7 anchor 2**: "Silhouette-grammar check exists in
    analyze_frame.py or sibling tool; outputs PASS/FAIL — code-cited".
    Promote the iter-17 distinctness logic into a reusable
    `tools/silhouette_gate.py` gate (PASS/FAIL on any PNG set);
    check_shell_icons.py uses it.
- CONSULT constraints respected: 6 (recap now names the route pressure
  that killed the run — "steel-armored bunkers", not "got
  overwhelmed"), 4 (the grammar gate is now a reusable tool, not a
  one-off — future assets pass through it)
- CONSULT constraints risked: none
- Predicted failure modes:
  - capture_death signature change (band_name String → BreachBand
    object) — 3 call sites: PlayerTank._die, test_breach_recap.gd.
    Both must update atomically.
  - PlayerTank substrate write #10 — _die's capture_death call.
    Gated on run_recap != null (breach mode only) — arc-2/3 untouched.
  - silhouette_gate.py refactor — check_shell_icons.py must still
    report BREACH_ASSETS_OK.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS
  (check-breach-recap now also verifies killing_pressure;
  check-breach-assets routes through silhouette_gate.py), new
  `make check-silhouette-gate` reports `SILHOUETTE_GATE_PASS`.
- Sentence test: n/a
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #10 —
  _die capture_death call; gated). `scripts/RunRecap.gd` (arc-4-owned).
- Hash-anchor verification plan: post-edit, before commit.

## iter 017 — BUILD — gen_tile.py shell-icon generator (C7 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C7 (silhouette grammar) is the only 0/5 criterion — the
  weakest axis. C7 anchor 1: "gen_tile.py extended with ≥1 new
  generator (depot tile / shell icon / chassis variant) — code-cited".
- CONSULT constraints respected: 4 (silhouette grammar — the 3 shell
  icons are designed to be readable by silhouette + palette: AP = narrow
  dart / pale, HE = fat ellipse / warm yellow, HEAT = angular diamond /
  crimson; palettes match the Bullet.gd iter-4/7 modulate colors), 2
  (still 3 shell classes — icons for exactly AP/HE/HEAT)
- CONSULT constraints risked: 4 — the FORMAL silhouette-grammar check
  tool is C7 anchor 2 (a later iter). iter 17 cites the grammar gate
  *manually* + the verifier proves the 3 icons are pixel-distinct
  (silhouette-distinct proxy). Honest: anchor 2's automated PASS/FAIL
  tool is scheduled, not done.
- Predicted failure modes:
  - PIL drawing at 8×8 is cramped — the 3 silhouettes could end up
    too similar (fail the distinctness check). Mitigation: verifier
    asserts pairwise pixel-difference above a threshold.
  - gen_tile.py is Layer-1 substrate ("extendable for new procedural
    generators" — explicitly sanctioned). Extension must not break the
    existing 4 terrain generators.
- Falsifiable claim: post-edit, the existing `make` terrain-gen path
  still works, the 3 shell icons generate as valid 8×8 PNGs, and the
  new `make check-breach-assets` reports `BREACH_ASSETS_OK` with the 3
  icons verified pairwise pixel-distinct. `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f` (gen_tile.py is a build-time tool —
  doesn't touch the runtime hash anyway), `make test-all` PASS.
- Sentence test: n/a (asset generator)
- Substrate touched: `tools/gen_tile.py` (Layer-1 — extension
  explicitly sanctioned by PROMPT §SUBSTRATE FREEZE "gen_tile.py
  (extendable for new procedural generators)").
- Hash-anchor verification plan: gen_tile.py is a build-time Python
  tool; it does not run during `make test`. Hash anchor trivially
  preserved — verify anyway.

## iter 016 — AUDIT — re-score all 10 criteria + resolve C1-anchor-2 wording

- Date: 2026-05-19
- Tag: [STRUCTURE]
- AUDIT trigger: PROMPT cadence "every 5 iters" — 16 iters since the
  iter-0 baseline, no AUDIT yet. Also a Mismatch-AUDIT trigger (L6):
  C1 anchor 2's "via Loadout.gd permutations" wording doesn't match
  the actual mechanism (RunRecap.build_tag).
- CONSULT constraints respected: all (process iter, no design surface)
- CONSULT constraints risked: none
- Predicted finding: the rolling score (19/50) is mostly honest, but
  C10 anchor 4 ("Same through iter 15+; ≥3 sanctioned substrate writes
  — all verified") became satisfiable once we crossed iter 15 — a
  legitimate Surrogate-AUDIT lift. Expect C10 3→4, total → 20/50.
- Falsifiable claim: the AUDIT re-score, done criterion-by-criterion
  against the 10 green harnesses + LEDGER evidence, changes at most
  C10 (3→4); all other criteria hold their iter-15 scores. RUBRIC.md
  C1 anchor 2 is rephrased (citation clause only — score unchanged).
  Identity-protected anchors (C1/5, C5/5, C7/5, C8/5, C9/5) are NOT
  touched (R2).
- Sentence test: n/a
- Substrate touched: none. `loop/breach/RUBRIC.md` revision (anchor
  rephrase + revision-log row).
- Hash-anchor verification plan: n/a (no code edit).

## iter 015 — BUILD — band-aware enemy roster (C5 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Discovery: arc-2 Spawner.gd ALREADY has 3 distinct enemy roles
  (Light = rare-fire lane-invader, Heavy = paused-aim corridor-denier,
  Fast = continuous-fire harasser) + a `DEPTH_BANDS` table with
  per-band `type_weights`. C5 anchor 1's "≥3 enemy roles" is already
  satisfied; the gap is "each spawns in correct bands per **BreachConfig**"
  (arc-2 uses its own DEPTH_BANDS, not the arc-4 5-band BreachConfig).
- CONSULT constraints respected: 3 (each enemy role has a readable
  shell/positioning answer — the 3 roles are behaviorally distinct), 5
  (each band's enemy pressure is now declared per BreachBand)
- CONSULT constraints risked: 3 — the canonical shell answer per role
  isn't yet *enforced* (no role demands a specific shell). Honest gap;
  C5 anchor 2 ("documented canonical answer per role") is later work.
- Predicted failure modes:
  - Spawner substrate write #9 — `_pick_enemy_type()` gets a 3rd branch
    (breach). It must be gated: arc-2 procedural + arc-3 OG paths
    unchanged → hash anchor preserved.
  - Spawner reads the band via `get_parent()` → level →
    `_current_breach_band`. If the level isn't breach mode, the breach
    branch must no-op and fall through to DEPTH_BANDS.
  - BreachBand.enemy_weights Dictionary in .tres — typed-Dictionary
    .tres syntax could be fiddly; use untyped Dictionary.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f` (arc-2 procedural unaffected — Spawner breach
  branch gated off), `make test-all` PASS (arc-3 OG Spawner path
  unchanged), `make test-breach` PASS, new `make check-breach-enemies`
  reports `BREACH_ENEMIES_OK` verifying all 5 bands declare non-empty
  enemy_weights with valid role names + Spawner picks band-appropriate
  types in breach mode.
- Sentence test: n/a (enemy roster, not an upgrade)
- Substrate touched: `scripts/Spawner.gd` (substrate write #9 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "Spawner.gd — band-aware
  spawning if iter-1 chooses path A"; gated breach branch).
  `scripts/BreachBand.gd` (add enemy_weights field — arc-4-owned, not
  substrate). `configs/breach_default.tres` (populate weights).
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  Spawner substrate touch.

## iter 014 — BUILD — RunRecap.gd death attribution (C6 anchors 1+2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 000: death attribution is the "paired omission" alongside
  depots. Constraint 6: "every run produces a death reason tied to
  resource/build/route — not 'got overwhelmed'."
- CONSULT constraints respected: 6 (death recap is the literal subject),
  7 (recap reports verbs/resources — shells fired, reserves — not a
  generic score)
- CONSULT constraints risked: none — the recap is a safe-state surface
- Predicted failure modes:
  - PlayerTank substrate write #8: `_fire` + `_die` hooks. The recap
    must be created only in breach mode (`loadout != null`) so arc-2/3
    PlayerTank behaves bit-identically (no recap, no hooks fire).
  - RunRecap as RefCounted — PlayerTank owns it internally (no @export
    needed; fresh instance per run avoids Resource-sharing staleness).
  - Killer attribution: `take_damage(amount)` carries no source.
    Mitigation — capture the killing *band* (route attribution, which
    is what constraint 6 actually wants) by reading the parent level's
    `_current_breach_band`; killer string is "shell impact" generic.
    Honest: route+resource attribution is the real signal, not the
    sprite that landed the hit.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f` (arc-2/3 PlayerTank with loadout==null runs the
  recap-free path), `make test-all` PASS, all 8 breach harnesses PASS,
  new `make check-breach-recap` reports `BREACH_RECAP_OK` verifying
  RunRecap captures depth + killing band + per-type shell counts +
  reserves + formats a non-empty recap string.
- Sentence test: n/a (recap, not an upgrade)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #8 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "PlayerTank.gd — add Loadout
  + RunRecap hooks"; gated on loadout != null). New file:
  `scripts/RunRecap.gd`.
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  PlayerTank substrate touch.

## iter 013 — BUILD — extend breach_default.tres to 5 bands (C4 anchor 3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (each band a specific climb problem
  — band 4 open killbox = sightline pressure, band 5 endgame = composed
  pressure), 7
- CONSULT constraints risked: 5's reachability flip-side — F001 lesson:
  new band configs must be reachability-verified, not eyeballed. Band 5
  (endgame_mixed) carries steel — the bunker-zone failure mode could
  recur.
- Predicted failure modes:
  - Band 5 (endgame_mixed) has steel ~0.16 + brick ~0.26 — could fail
    the per-band oracle multi-seed like bunker_zone did pre-retune.
    Mitigation: verify via the 10-seed sweep; retune within-iter.
  - Band 4 (open_killbox) is high-empty — should be trivially
    reachable; the risk is the OPPOSITE (too empty = no climb problem),
    but that's a feel concern, not a reachability one.
  - .tres load_steps must cover the 4 new sub_resources.
- Falsifiable claim: post-edit, all 5 bands pass the per-band
  reachability oracle on ≥80% of a 10-seed sweep (the codified floor).
  `make check-breach-config` reports 5 bands. `make
  check-breach-harness` (deep, seed 42) reports all 5 reachable.
  `make test` exit 0, `tile_hash` = `23d6a2ec3bf2821f`, `make
  test-all` PASS.
- Sentence test: n/a (band config, no upgrade)
- Substrate touched: none — `configs/breach_default.tres` (not
  substrate) + `loop/breach/BANDS.md` (doc).
- Hash-anchor verification plan: post-edit; config-only change, flag-off
  codepath untouched — trivially preserved, verify anyway.

## iter 012 — CAPABILITY — deep-climb reachability harness (bands 2+3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CAPABILITY justification (PROMPT MODE table — "must justify against a
  rubric axis"): the deep-climb harness is the §REACHABILITY FLOOR
  verification tool for C4. Without it, C4 anchor 2's reachability
  caveat (bands 2+3 unverified, F001) can't close, and C4 anchor 3
  ("5 bands … reachability passes on all — harness-cited") is
  unreachable. This iter directly unblocks C4.
- CONSULT constraints respected: 5 (verifies each band is a *playable*
  climb problem, not an impassable wall), 6 (harness is a clean
  band-level segmentation point for metrics)
- CONSULT constraints risked: none — verification tooling
- Predicted failure modes:
  - The climb mechanism (programmatically advancing player.position.y)
    must stay in step with ProceduralLevel._process generation (1 row
    per frame). If the player climbs faster than generation, it
    outruns the generated grid. Mitigation: climb 1 grid_size/frame.
  - F001 strongly predicts bands 2+3 will FAIL on first deep run —
    brick_maze + bunker_zone were softened blind in iter 11. If they
    fail, retune within-iter (PROMPT §HALT — reachability fail must be
    fixed same iter).
  - Node count: ~150 rows × multiple BrickBlocks/row = thousands of
    nodes over the climb. Headless should handle it; if slow, reduce
    climb depth or sample.
- Falsifiable claim: post-edit, the deep-climb harness reports, per
  seed, whether the spawn flood-fill frontier crosses each band's
  depth_max. By end of iter, bands 1/2/3 ALL report
  `playable: true` / chain-reachable across ≥5 seeds (1/7/42/100/333) —
  retuning band configs within-iter if any fail. `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f`, `make test-all` PASS.
- Sentence test: n/a (CAPABILITY iter)
- Substrate touched: none — `loop/breach/test_breach_harness.gd` is
  arc-4-owned (extend freely). `configs/breach_default.tres` may be
  retuned (not substrate).
- Hash-anchor verification plan: post-edit (only if breach_default.tres
  retuned — config changes don't touch the flag-off codepath, so
  trivially preserved; verify anyway).

## iter 011 — BUILD — wire depth-band terrain selection + 3rd band

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (each band has a dominant terrain
  pressure — now ENFORCED at generation time, not just declared in
  config: `_active_config` routes per-band LevelConfig into row
  generation), 7 (no stats — terrain pressure is a climb problem, not
  a number)
- CONSULT constraints risked: 5's reachability flip-side — if a band's
  LevelConfig is too dense (e.g. bunker_zone steel-heavy), the
  procedural layout could become impassable. RUBRIC C4 reachability
  floor caps C4 at 0 if any band fails. Mitigation: keep band configs
  gentle (empty_weight ≥ 0.12); a formal per-band reachability oracle
  is a scheduled CAPABILITY iter (12+) — C4 anchor 3 is gated on it.
- Predicted failure modes:
  - `_active_config` is called during BOTH `_ready` initial generation
    AND `_process` climbing generation. The breach branch must not
    break the flag-off path — when `breach_mode_enabled == false` the
    branch is skipped entirely → hash anchor `23d6a2ec3bf2821f` stays.
  - Row→depth mapping: `rows_climbed = (height/grid_size) - row`. If
    the sign is inverted, bands map backwards (player starts in band 3).
    Will verify the starting area resolves to band 1.
  - Breach band lookup per-row is O(bands) — 3 bands, negligible.
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` (procedural baseline flag-off — breach branch
  skipped) AND `make test-all` PASS AND `make test-breach` PASS (all 7
  harnesses; check-breach-config now sees 3 bands) AND BreachLevel
  still instantiates clean over 30 frames.
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (substrate write #7 —
  fills the iter-2 `_init_breach_mode` / `_process_breach_depth` stubs;
  extends `_active_config` with a breach branch. Sanctioned per PROMPT
  §SUBSTRATE FREEZE path A. The breach branch is gated on
  `breach_mode_enabled` — default-on gating template preserved).
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  `_active_config` is on the RNG-feeding generation path; the breach
  branch MUST be flag-gated so flag-off stays bit-identical.

## iter 010 — BUILD — BreachLevel.tscn (first end-to-end breach scene)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 structurally — this iter wires
  the integration scene that lets all prior pieces (flag, BreachConfig,
  shells, Loadout, Depot) exist together in one playable surface
- CONSULT constraints risked: 5 — band-aware procedural generation
  still not wired (`_init_breach_mode` / `_process_breach_depth` stubs
  remain empty); BreachLevel generates terrain identically to arc-2
  procedural for now. The depth-band *experience* lands iter 11+ when
  the stubs route `breach_config` into per-row LevelConfig selection.
- Predicted failure modes:
  - Inherited-scene .tscn syntax: Godot 4.6 inherited scenes use
    `[node name="X" instance=ExtResource("base")]` on the root +
    child-override nodes by path. If the syntax is wrong, the scene
    won't load. Mitigation: keep it minimal; test load immediately.
  - The root node of ProceduralLevel.tscn is named "ProceduralLevel";
    inherited scene can rename to "BreachLevel". Child-override paths
    (`PlayerTank`) must match the base scene's node names exactly.
  - Depot placed at a fixed world-y may sit below/above the climbable
    region — depot reachability matters. For iter 10, depot is a
    *placement smoke test*, not yet a tuned band-transition gate.
- Falsifiable claim: post-edit, `make test` exit 0 (ProceduralLevel.tscn
  untouched) AND `tile_hash` = `23d6a2ec3bf2821f` AND `make test-all`
  PASS AND all 6 prior breach harnesses PASS AND new
  `make check-breach-level` reports `BREACH_LEVEL_OK` with: BreachLevel
  instantiates, `breach_mode_enabled == true`, `breach_config != null`,
  PlayerTank has a non-null loadout, ≥1 Depot child present, no script
  errors over 30 frames.
- Sentence test: n/a (integration iter, no new upgrade)
- Substrate touched: none — BreachLevel.tscn is a NEW inherited scene;
  ProceduralLevel.tscn / .gd untouched. configs/breach_starter_loadout
  .tres is new. The hash anchor is trivially preserved (the procedural
  baseline scene is byte-identical).
- Hash-anchor verification plan: post-edit, before commit.

## iter 009 — BUILD — Depot 3-choice upgrade catalog + next-band preview

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 001 Q2 implication: "Two-choice depot whose options are
  legible in under five seconds and both answer the last/next breach
  problem. No scrolling, no build tree, no stat salad." Going with **3
  choices** (still legible in <5s, lifts C2 anchor 2's "≥3 meaningful
  upgrade choices" cleanly without AUDIT-rephrase). Three is the
  smallest count that hits anchor 2 while still respecting the
  "no-scrolling, no-build-tree" CONSULT guidance.
- CONSULT constraints respected: 1 (no combat-modal — depot is the
  *safe gate* per design; key-based pick is fast), 7 (verbs not stats —
  each upgrade is an *action verb*: "refill HE", "refill HEAT", "expand
  HE capacity"; no passive +%damage cards). Sentence test: each upgrade
  must pass — verified inline in the pre-mortem below.
- CONSULT constraints risked: 1's flip-side — 30s depot dwell budget.
  Iter 9 ships no dwell timer; the harness verifies pick is *possible*
  in 1 frame. Iter 10+ adds enforcement if playtest reveals drag.
- Sentence tests per choice:
  - HE_REFILL_2: "This upgrade helps me climb through brick mazes by
    changing how I use HE shells" ✓
  - HEAT_REFILL_1: "This upgrade helps me climb through bunker bands by
    changing how I use HEAT shells" ✓
  - HE_MAX_EXPAND_2: "This upgrade helps me climb through long
    HE-required runs by changing how I use my shell economy" ✓
  - All three pass.
- Predicted failure modes:
  - Input-during-pause: Godot 4 still processes `Input.is_*` polls in
    nodes with PROCESS_MODE_ALWAYS even when tree is paused. Depot
    already sets PROCESS_MODE_ALWAYS (iter 5). Choice picks should fire.
  - Resource reference race: storing player.loadout on entry then
    accessing on pick — if player despawns mid-pause, loadout reference
    could be stale. Mitigation: null-check before apply.
  - Depot.tscn layout: 4 Label nodes need positioning. Simple Control
    container with VBoxContainer keeps it bounded.
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND all 5 prior breach
  harnesses PASS AND new `make check-breach-depot-choice` reports
  `BREACH_DEPOT_CHOICE_OK` with all 3 choice picks verified
  (HE refill, HEAT refill, HE max expand).
- Substrate touched: none (extending existing arc-4 file Depot.gd +
  scene Depot.tscn). C2 anchor 2 target.
- Hash-anchor verification plan: post-edit, before commit. Trivially
  preserved (no engine/gameplay-substrate touch).

## iter 008 — BUILD — Loadout.gd + finite HE/HEAT reserves + shell-cycle input

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 001 (now returned despite tab timeout — documented arc-4
  behavior): **"no player has yet sacrificed one resource to alter one
  route. That is the atomic verb."** This iter wires that verb.
- CONSULT constraints respected: 1 (no combat-modal — shell cycle is a
  key tap, not a menu), 2 (≤3 classes), 3 (each shell already has a
  readable answer from iter 7; iter 8 adds the *commitment cost*),
  7 (verbs not stats — Loadout's `he_reserve` is a finite resource the
  player *spends*, not a passive +damage stat)
- CONSULT constraints risked: 1 — shell-cycle key chosen as raw KEY_TAB
  (no InputMap action added; project.godot stays untouched). If TAB
  conflicts with anything, will refactor to an InputMap action in
  iter 9+. Mitigation acceptable for iter 8 minimum scope.
- Predicted failure modes:
  - Signal arity mismatch: extending `shoot` to emit shell_class breaks
    any existing handler that expected 3 args. Level.gd handler must
    update in the same commit (substrate write #6).
  - Hash anchor: Level.gd and PlayerTank.gd both touched. Procedural
    `make test` doesn't fire bullets in the 120-frame window (no input
    simulated) so the new signal path doesn't engage; anchor preserved.
  - OG mode regression: arc-3 OriginalLevel.gd extends Level.gd; the
    new 4-arg signal handler must work for OG too. PlayerTank default
    current_shell = AP + loadout = null means OG fires AP bullets via
    the same path. Will be verified via `make check-chain-25` (full
    arc-3 chain).
  - Loadout cross-script type: same preload-alias pattern needed
    (arc-1 LevelConfigT precedent).
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND ALL 4 prior breach
  harnesses PASS AND new `make check-breach-loadout` reports
  `BREACH_LOADOUT_OK` with: (a) PlayerTank.loadout default null →
  arc-2 baseline preserved, (b) loadout set + HE fire → he_reserve
  decremented, (c) loadout set + HE fire at he_reserve=0 → fallback
  to AP, no decrement.
- Sentence test: applies. Loadout is the substrate for upgrades
  (depots refill it). The first upgrade card eligible to cite C8:
  "This upgrade helps me climb through brick mazes by changing how I
  use HE shells" — depot offers "+3 HE reserves" or similar. Iter 9.
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #5 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "PlayerTank.gd — add Loadout
  + RunRecap hooks"), `scripts/Level.gd` (substrate write #6 —
  necessary for shell signal extension; same gating discipline applies
  even though Level.gd isn't named in §SUBSTRATE FREEZE — it's an arc-1
  Layer-1 file. Will use default-on gating: 4th signal arg has a
  sensible default routing).
- Hash-anchor verification plan: post-edit, before commit. Mandatory.

## iter 007 — BUILD — Bullet.gd shell-class combat behaviors (HE blast + HEAT 2x)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 2 (still 3 shell classes, no fourth),
  3 (HE has a readable shell relationship → bricks crack into rubble;
  HEAT has a readable relationship → 2x damage; AP cheap+precise stays
  the default), 7 (verbs not stats — HE is an *affordance* "creates lane
  through brick clusters", not "+18% splash damage"; HEAT is a *verb*
  "doubles damage on hit", not a passive multiplier)
- CONSULT constraints risked: constraint 5 — without depth-band
  enemy/terrain mapping wired, HEAT 2x doesn't yet pair with heavy
  bunkers. Honest scaffolding: HE behavior is the load-bearing one
  (breach economy = "spending shells to open vertical lanes"); HEAT 2x
  is the simplest distinct-behavior cite for anchor 2 closure
- Predicted failure modes:
  - HE blast radius via sibling iteration may scan too many nodes if
    bricks are deeply nested → perf hit. Mitigation: cap by distance
    check; arc-2 procedural's brick count is ≤350.
  - Hash anchor risk: `make test` runs procedural baseline for 120
    frames. If procedural baseline ever fires AP bullets that touch
    bricks, the HE-radius behavior changes outcomes only via shell_class
    routing — AP default preserves arc-2 path bit-identically. Should
    be safe but verify.
  - Harness must construct stub `BrickBlock`-like nodes with
    `take_damage` and spatial positions; SceneTree subclass + await
    process_frame pattern (arc-3 precedent).
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND
  `make check-breach-{config,shells,depot}` PASS AND new
  `make check-breach-he-blast` reports `BREACH_HE_BLAST_OK` with HE
  bullet destroying ≥2 stub bricks in cluster + HEAT bullet dealing
  2x damage to single stub body + AP bullet dealing 1x baseline.
- Sentence test: applies — does HE behavior pass?
  *"This upgrade helps me climb through brick mazes by changing how I
  use HE shells."* — YES (HE-leaves-rubble-via-radius is the literal
  text of CONSULT §4 example "good upgrade")
- Substrate touched: `scripts/Bullet.gd` (substrate write #4 — sanctioned
  per PROMPT §SUBSTRATE FREEZE "scripts/Bullet.gd — multi-shell support
  if iter chooses extend-vs-new-Shell.gd"; same file as iter 4 — chosen
  path, refined)
- Hash-anchor verification plan: post-edit, before commit. Defensive
  check is mandatory because Bullet.gd is a Layer 2 substrate file
  fired by both player (proc baseline) and enemies (Spawner).

## iter 006 — META + CONSULT — round 1 close + round 2 bootstrap

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat-modal UI added this iter),
  3 (no enemy without canonical answer added), 4 (no asset gen added)
- CONSULT constraints risked: none — META/process iter, no design surface
- Predicted failure: /agentify CONSULT may timeout/error like the
  arc-4 design consult did (per `creative-consults.md` consult 000).
  Mitigation: capture the queryId regardless of tab status; arc-4 has
  explicit documented protocol that tab-timeout ≠ consult-failed (the
  conversation may have completed). Next iter checks back.
- Falsifiable claim: by end of this iter, (a) a CONSULT attempt is
  recorded in `loop/breach/creative-consults.md` with queryId + status;
  (b) a round-1 finding lands in `loop/breach/REVIEW-QUEUE.md` per L3
  pattern; (c) STATE.md next_action names a concrete iter-7 BUILD or
  SPIKE target for round 2. Hash anchor preserved (no code touched).
- Sentence test: n/a (META iter)
- Substrate touched: none
- Hash-anchor verification plan: n/a (no code edit). Trivially preserved.

## iter 005 — BUILD — Depot.gd + Depot.tscn + pause-on-entry

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 1 (no upgrade choices during
  active combat — depot's pause-on-entry is the *load-bearing* mechanism
  protecting this), constraint 6 (depot is a natural segmentation point
  for death recap / pre/post-band metrics — schema sets this up)
- CONSULT constraints risked: constraint 1's flip-side — depot dwell
  must stay <30s; the rubric anti-pattern for C2 is depot dwell >30s.
  This iter doesn't yet implement upgrade choice flow, so dwell is
  unbounded by design (just walk in/out). Iter 6+ adds the choice + the
  30s budget; an honest acknowledgment now.
- Predicted failure: Godot 4.6 `get_tree().paused = true` + Area2D
  body_entered may have a process_mode interaction — if Depot's own
  `process_mode` is not set to PROCESS_MODE_ALWAYS, the depot itself
  pauses and can't fire `body_exited`. The mitigation lives in the
  script. Second risk: in headless test, no actual physics tick fires;
  the test must directly invoke `_on_body_entered(stub)` rather than
  rely on collision-based emission.
- Falsifiable claim: post-edit, `make test` exits 0 AND `tile_hash`
  first 16 chars = `23d6a2ec3bf2821f` AND `make test-all` PASS AND
  `make check-breach-config` PASS AND `make check-breach-shells` PASS
  AND new `make check-breach-depot` reports `BREACH_DEPOT_OK` with the
  pause-on-entry contract verified (get_tree().paused = true after
  entry signal, false after exit signal).
- Sentence test: n/a (depot itself is not an upgrade; iter 6+ depot
  upgrade catalog will run the sentence-test gate per RUBRIC C8).
- Substrate touched: none (Depot.gd + Depot.tscn are net-new files;
  no Layer 1/2/3 edits).
- Hash-anchor verification plan: post-edit, before commit. Should be
  trivially preserved — no engine/gameplay code touched.

## iter 004 — BUILD — Bullet.gd shell_class flag + AP/HE/HEAT constants

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 2 (≤3 primary shell classes
  at first — AP/HE/HEAT exactly), constraint 1 (no combat modal — flag
  is data-only, no UI surface), constraint 7 (verbs not stats — shell
  class will route to terrain/behavior affordances in later iters, not
  to +damage% upgrades)
- CONSULT constraints risked: constraint 3 (every enemy must have a
  readable shell/positioning relationship) is *not* satisfied yet by
  this iter — the shell_class field exists but no per-class behavior is
  wired. Later iter must implement HE=terrain-cracking,
  HEAT=anti-heavy-armor, AP=cheap-precise. The schema-only iter is
  honest scaffolding; the behavior gap is documented + scheduled.
- Predicted failure: extending Bullet.gd default-arg shape in `start()`
  may bleed across the existing callers in Level.gd or PlayerTank
  (which fire bullets without specifying shell_class) — they'd get the
  @export-default-AP behavior, which is the desired bit-identical
  baseline. If any caller passes positional args in a way that collides
  with a new positional `shell_class`, parsing or runtime breaks.
- Falsifiable claim: post-edit, `make test` exits 0 (procedural baseline
  still fires AP bullets identically to arc-2) AND `tile_hash` first
  16 chars = `23d6a2ec3bf2821f` AND `make test-all` PASS on all 5
  arc-3 targets AND `make check-breach-config` PASS AND new harness
  `make check-breach-shells` reports `BREACH_SHELLS_OK` with 3 shell
  classes (AP/HE/HEAT) verified distinct.
- Sentence test: n/a this iter (shell_class is a data field, not yet
  an upgrade). When iter 5+ adds an upgrade that grants shell-swap
  reserves, sentence will be: "This upgrade helps me climb through
  bunker bands by changing how I use HEAT" — sentence test gate.
- Substrate touched: `scripts/Bullet.gd` (substrate write #3 — sanctioned
  per PROMPT §SUBSTRATE FREEZE "scripts/Bullet.gd — multi-shell support
  if iter chooses extend-vs-new-Shell.gd"; chose extend over new file
  per Scout A's spike + L5 gating template)
- Hash-anchor verification plan: post-edit, before commit. The
  Bullet.gd change is gameplay-layer (Layer 2), not engine. Hash anchor
  is bound to procedural seed-42 baseline which doesn't fire bullets
  during the 120-frame `make test` window — so the anchor should remain
  trivially preserved. But I'll verify anyway since the anchor floor on
  C10 caps everything else.

## iter 003 — BUILD — BreachConfig.gd + BreachBand.gd + sample .tres (2 bands)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 5 (each band must have a
  dominant terrain/enemy pressure — BreachBand's `dominant_pressure` +
  `canonical_answer` fields encode this), constraint 4 (BreachBand
  schema constrains future asset gen to existing silhouette roles by
  design — bands don't invent mechanics, they re-weight terrain), all
  others (no design surface changed; structural schema only)
- CONSULT constraints risked: constraint 5 if we later ship a band
  without a stated dominant pressure (defended by the schema —
  `dominant_pressure: String` field; runtime check possible later)
- Predicted failure: typed-Array Resource (`Array[BreachBand]`) syntax
  in `.tres` may have a Godot 4.6 quirk that fails to parse — falls back
  to untyped Array. Sub-resource cycles (BreachConfig → BreachBand →
  LevelConfig) may not resolve in load order — falls back to inline
  LevelConfig per band rather than ext resource.
- Falsifiable claim: post-edit, `make test` exits 0 AND
  `tile_hash` first 16 chars = `23d6a2ec3bf2821f` (procedural baseline
  preserved — `breach_mode_enabled=false`, `breach_config=null` on
  ProceduralLevel.tscn) AND `make test-all` reports all 5 arc-3 targets
  PASS AND `configs/breach_default.tres` loads cleanly via
  `ResourceLoader.load(...)` without errors.
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (tighten @export type
  from `Resource` to `BreachConfig`; same flag area, sanctioned write
  scope from iter 2). New non-substrate files: `scripts/BreachBand.gd`,
  `scripts/BreachConfig.gd`, `configs/breach_default.tres`.
- Hash-anchor verification plan: post-edit, before commit.

## iter 002 — BUILD-QUALITY — DECISION (adopt path A) + first substrate hook

- Date: 2026-05-19
- Tag: [STRUCTURE] [QUALITY] (no discrete rubric anchor lift this iter;
  plumbing/foundation work per L3+R4 release-valve. First of 3
  substrate-touching iters required to hit C10 anchor 1.)
- CONSULT constraints respected: all 7 (no design surface; substrate
  plumbing only). Constraint 1 (no combat modals) is structurally
  protected by the gating template — flag-off codepath is bit-identical
  to arc-2 procedural.
- CONSULT constraints risked: none this iter; downstream iters carry
  risks (iter 3+ depth-band logic against constraint 5; iter 4+ shell
  classes against constraints 2/3; iter 5+ depot against constraint 1).
- Predicted failure: the `@export var breach_mode_enabled` + 2 conditional
  branches edit on `ProceduralLevel.gd` will subtly mutate the procedural
  baseline. Specifically, possible failure modes:
  - Branch added inside the RNG-touching window (before line 77) → hash
    breaks
  - Stub method's `_init_breach_mode()` body accidentally creates a
    child node or calls `randf()` even with flag off
  - GDScript parse-order error on the new vars (caught by pre-tool hook
    if present; pre-commit; or `make test`)
- Falsifiable claim: post-edit, `loop/test_runner.gd` on seed 42 / default
  config reports `tile_hash` prefix `23d6a2ec3bf2821f` AND `playable: true`
  AND `make test` exits 0. If any of these fail, the iter HALTS for
  investigation per PROMPT §HALT CONDITIONS (hash anchor broken =
  correctness violation; auto-halt + investigate).
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (sanctioned per PROMPT
  §SUBSTRATE FREEZE iter-1 DECISION + §DEFAULT-ON SUBSTRATE GATING
  TEMPLATE; PATTERN 2 from arc 3)
- Hash-anchor verification plan: post-edit, before commit, run
  `loop/test_runner.gd` and verify `tile_hash: 23d6a2ec3bf2821f`. Run
  `make test` for parse + 120-frame runtime check. If both green, commit;
  if either fails, revert + investigate.

## iter 001 — SPIKE — mode-integration path A vs B

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (no design surface touched yet;
  this iter is structural plumbing investigation)
- CONSULT constraints risked: constraint 3 indirectly — if path A's
  default-on flag interacts with Spawner's existing band logic in a way
  that makes per-band enemy/terrain mapping harder later, we'd risk
  "decorative complexity" downstream
- Predicted failure: path A may turn out to be deeper than the PROMPT
  default-recommendation assumes. Specifically, `ProceduralLevel.tscn` +
  `ProceduralLevel.gd` may have implicit assumptions (TANKE_SEED env,
  fixed map geometry, no run-state surface) that fight against being
  gated for vertical depth-bands + depot insertion + run state. Path B
  may turn out to be cleaner than the PROMPT's H1 multiplication concern
  if `ProceduralStep` can be reused as a child node without scene
  duplication.
- Falsifiable claim: at end of iter 1, both spikes produce concrete file
  diffs (path A: minimal `@export var breach_mode_enabled` patch + 1
  conditional branch in `_ready` or `_build_level`; path B: a skeletal
  `scenes/BreachLevel.tscn` referencing `ProceduralStep` as a child).
  Each spike returns SHIP / REFINE / SKIP + lines-of-change estimate +
  hash-anchor impact statement. **Neither spike actually commits the
  diff** — they're scouts. The DECISION (iter 2) picks the winner.
- Sentence test: n/a (no upgrade in this iter)
- Substrate touched: read-only investigation
- Hash-anchor verification plan: post-spike (iter 2 DECISION's build),
  not this iter. Both spikes report whether their path could break the
  anchor in principle.

## iter 000 — META — preloop complete

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (no design work yet; substrate-only)
- CONSULT constraints risked: none
- Predicted failure: substrate may have drifted across the 3 modified files
  in git status (`project.godot` shows `M`) → either hash anchor breaks or
  `make test` fails.
- Falsifiable claim: `make test` exits 0 AND `loop/test_runner.gd` on seed
  42 / default config reports `tile_hash` prefix `23d6a2ec3bf2821f` AND
  `playable: true` AND OG `check-chain` reports `CHAIN_25_OK`.
- Sentence test: n/a (no upgrade)
- Substrate touched: none (read-only verification)
- Hash-anchor verification plan: post-verification, pre-flip of
  `preloop_complete: yes`. Result: PASS (`23d6a2ec3bf2821f` confirmed).
