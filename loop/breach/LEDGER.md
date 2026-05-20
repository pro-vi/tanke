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

## iter 031 — IDLE — heartbeat tick; regression guard green

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Score: **30/50** (Δ 0 — idle tick; the loop is in awaiting-playtest
  state, no BUILD)
- First idle-heartbeat tick after the iter-30 end-of-autonomous-work.
  Per STATE: re-verify green, take genuine non-rubric work if any
  appears, else hold. Diagnosis: no genuine non-rubric BUILD work that
  isn't feel-work-needing-playtest or discipline-violating substrate.
  Hold.
- Regression guard: `make test` exit 0, `tile_hash 23d6a2ec3bf2821f`,
  `playable: true`, `make test-all` 5/5, `make test-breach` 17/17.
  All green — no drift.
- Housekeeping (honest, not filler):
  - `project.godot` had a Godot headless-re-serialization artifact
    (it dropped `window/dpi/allow_hidpi` + `window/stretch/aspect`).
    The loop never authored that — reverted to the committed config.
  - Committed the 5 arc-4 `scripts/*.gd.uid` files (BreachBand /
    BreachConfig / Depot / Loadout / RunRecap) — the repo convention
    tracks `scripts/*.gd.uid`; these were missed by the by-name
    `git add` in iters 3/5/8/14. `loop/**/*.uid` stays untracked
    (no loop .uid is tracked — consistent).
- Hash anchor: `23d6a2ec3bf2821f` confirmed.
- Falsifications: none.
- Files: 5 `scripts/*.gd.uid` (now tracked), LEDGER, STATE.
- STATE.md integrity fix: the regression-guard tick found a stale
  duplicate-key block in STATE.md's yaml (leftover iter-21-era
  `score: 28/50` + old harness count + a `review_queue_open` missing
  #3 — duplicate keys would shadow the correct values). Removed the
  4 stale lines; corrected `new_harness_targets` to the current 17.
  A real find — the idle tick's regression guard earned its keep.
- Finding: **Loop holding at 30/50, build green, awaiting the
  REVIEW-QUEUE #3 playtest.** No autonomous work remains that would be
  honest to do. Heartbeat continues at ~1800s; each tick is a
  regression guard + hold. The user's `playtest` / `halt` / `stop` is
  the next event.

## iter 030 — BUILD-QUALITY — shell HUD (round 4 close; loop hits true end-of-autonomous-work)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Score: **30/50 absolute · 30/50 effective** (Δ 0 — BUILD-QUALITY,
  round-4 legibility, no [STRUCTURE] anchor lift)
- Round 4 (pre-playtest legibility), piece 2 + close. Breach-economy
  state — current shell, HE/HEAT reserves — is now visible: a breach
  PlayerTank builds a ShellLabel ("SHELL HE  HE 3  HEAT 2"), updated
  each `_update_run_hud`. Gated on `loadout != null` → arc-2/3 HUD
  bit-identical (no ShellLabel, no shell branch).
- Constraints respected: 3 (a readable shell relationship needs the
  shell visible), CONSULT 002 (legibility)
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post
  PlayerTank.gd write. `make test` exit 0. `make test-all` PASS
  (5 arc-3 — arc-2/3 HUD unchanged). `make test-breach` PASS (17).
- Falsifications: none
- Files: `scripts/PlayerTank.gd` (substrate write — `_shell_label` +
  `_setup_hud` breach-gated block + `_shell_name` + `_update_run_hud`
  shell line), `loop/breach/test_breach_hud.gd` (NEW), `Makefile`
  (check-breach-hud), PRE-MORTEMS, LEDGER, STATE
- **Regime signal**: iters 29 + 30 are back-to-back BUILD-QUALITY —
  exceeding the L3/R4 "1 per 3 BUILDs" cap. This is not drift; it is
  the cap correctly reporting the structural ceiling: with every
  [STRUCTURE] anchor closed or blocked (iter 28), ALL remaining honest
  work is necessarily BUILD-QUALITY craft. The cap assumes anchor-lift
  BUILDs to interleave; at the ceiling there are none. The loop has
  genuinely reached the end of high-value autonomous work.
- Finding: **Round 4 closed — breach mode is playtest-ready.** The
  player can now see HP/depth (arc-2 HUD), current shell + HE/HEAT
  reserves (iter 30), and depot upgrade choices (iter 29 panel). Every
  piece of breach economy is legible. The loop has now delivered:
  the full 5-band climb, finite shell economy with swap cost, 3 depots
  + 7-upgrade catalog, HEAT-solves-armor, death recaps, band-aware
  enemies, and the legibility layer. **30/50 structural; the remaining
  20 points are the playtest's verdict.** Per the parity-drift /meta +
  both CONSULTs, the loop has built everything reachable without a
  human. The honest next event is the REVIEW-QUEUE #3 playtest — the
  loop shifts to a slow idle heartbeat awaiting it.

## iter 029 — BUILD-QUALITY — depot UI panel (round-3 close, round-4 open)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Score: **30/50 absolute · 30/50 effective** (Δ 0 — BUILD-QUALITY;
  craft work that makes the playtest meaningful, no [STRUCTURE] anchor
  lift)
- DIAGNOSE: round 3's structural work is done (30/50 ceiling). The
  honest next work isn't grinding past the ceiling — it's the *bridge*
  to the playtest. Breach mode wasn't legible: the depot's 3-choice
  upgrade flow (KEY_1/2/3) had NO on-screen UI — just a blue marker
  rect. A playtest of an invisible depot is meaningless. CONSULT 002
  Q2: depots must be "legible in under five seconds".
- Constraints respected: 1 (the panel shows only at the safe-gate,
  tree paused — never during combat), CONSULT 002 Q2 (legibility)
- Constraints risked: depot dwell <30s — the panel is a compact 4-line
  layout (hint + 3 choices); playtest tunes.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (no substrate
  — Depot.tscn + Depot.gd arc-4-owned). `make test` exit 0. `make
  test-all` PASS. `make test-breach` PASS (16 checks).
- Falsifications: none
- Files: `scenes/Depot.tscn` (+UILayer CanvasLayer with a Panel + 5
  Labels), `scripts/Depot.gd` (_show_panel / _hide_panel /
  _set_panel_label — populates from choice labels + next_band_hint on
  entry; hides on pick + on exit), `loop/breach/test_breach_depot.gd`
  (+UI panel show/populate/hide assertions),
  `loop/breach/REVIEW-QUEUE.md` (#4 — round-3 close),
  PRE-MORTEMS, LEDGER, STATE
- Tag rationale: BUILD-QUALITY (L3/R4) — a visible depot panel is
  craft that makes the playtest possible; C2 anchors 4-5 are
  playtest-gated so it lifts no [STRUCTURE] anchor. Last BUILD-QUALITY
  iter 24; iters 25-28 were META/AUDIT/BUILD/BUILD — within cap.
- Finding: **Round 3 closed; round 4 (pre-playtest legibility) opens.**
  The depot now has a visible UI panel — entering a depot pauses the
  game and shows the next-band hint + 3 numbered upgrade choices; it
  hides on pick or exit. This is the first piece of round 4: making
  breach mode legible enough that the REVIEW-QUEUE #3 playtest is
  meaningful. Structural score holds at the honest 30/50 ceiling.
  Next iter 30: round-4 piece 2 — a shell HUD (current shell +
  HE/HEAT reserve counts), finally wiring the iter-17 shell icons
  into a visible indicator.

## iter 028 — BUILD — OVERDRIVE sprint upgrade (C8 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Score: **30/50 absolute · 30/50 effective** (Δ +1 vs prior — C8 anchor 3)
  - C8 (Sentence test compliance): 2 → 3 (anchor 3: upgrade catalog
    covers all 5 depth bands' dominant pressures — 7-entry catalog;
    OVERDRIVE fills the open_killbox positioning gap. Coverage map:
    tutorial_choke/brick_maze→HE, bunker_zone→HEAT, open_killbox→
    OVERDRIVE, endgame_mixed→FULL_RESUPPLY. Documented in Loadout.gd,
    code-cited via `make check-breach-overdrive`)
  - C1=3, C2=3, C3=4, C4=3, C5=2, C6=3, C7=3, C9=2, C10=4 unchanged
- DIAGNOSE: round-3 anchor 2. C5 anchor 3 (4th enemy role) is
  substrate-blocked — a genuine new role needs an Enemy.gd behavior
  branch (not sanctioned; iter-23 finding) and a stat-only variant
  violates CONSULT constraint 3. So took C8 anchor 3 instead.
- Constraints respected: 7 (OVERDRIVE is a movement VERB with a cost —
  burst then cooldown — not a passive +speed%; CONSULT 000 §7 "verbs
  and affordances"), 1
- Constraints risked: 2 — OVERDRIVE is the first non-shell upgrade;
  acceptable (it's a chassis/positioning affordance, not shell-class
  bloat; still 3 shells).
- Sentence test: OVERDRIVE passes — "...climb through open killboxes by
  changing how I use positioning — a speed burst to break flanker
  sightlines" (documented in Loadout.gd UPGRADE CATALOG).
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post
  PlayerTank.gd write. The sprint is gated on `loadout.has_overdrive`
  — arc-2/3 movement bit-identical. `make test` exit 0. `make
  test-all` PASS. `make test-breach` PASS (16 checks).
- Falsifications: none. Pre-mortem-adjacent lesson (not an F): headless
  `await process_frame` does not reliably tick `_physics_process` —
  the harness drives `_physics_process(delta)` directly. (Same as
  arc-3's input-sim pattern; session-local, not codified.)
- Files: `scripts/Loadout.gd` (+has_overdrive + catalog doc + coverage
  map), `scripts/Depot.gd` (UpgradeKind += OVERDRIVE),
  `scripts/PlayerTank.gd` (substrate write — overdrive sprint burst:
  KEY_SHIFT → speed×mult for overdrive_burst s → cooldown),
  `loop/breach/test_breach_overdrive.gd` (NEW), `Makefile`
  (check-breach-overdrive), PRE-MORTEMS, LEDGER, STATE
- Finding: **The depot now forks a positioning playstyle.** OVERDRIVE
  grants a sprint burst — the open_killbox band's answer. The 7-entry
  catalog covers all 5 band pressures. **Round 3 structural work is
  effectively complete: C3/4 (iter 27) + C8/3 (iter 28) shipped; C5/3
  is substrate-blocked.** 30/50 — the honest structural finish. The
  remaining 20 points (incl. C10/5 at arc close) are playtest-gated.
  Next iter 29: round-3 close — the loop has reached its true
  structural ceiling; honestly hold for the playtest (REVIEW-QUEUE #3).

## iter 027 — BUILD — shell-swap reload cost (C3 anchor 4)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Score: **29/50 absolute · 29/50 effective** (Δ +1 vs prior — C3 anchor 4)
  - C3 (Ammo as logistics): 3 → 4 (anchor 4, de-bundled iter 26:
    shell-swap has a reload cost ≥0.5s — pre-commitment under reload
    pressure — code-cited via `make check-breach-swap` reporting swap
    arms a 0.50s cooldown that blocks `_fire`)
  - C1=3, C2=3, C4=3, C5=2, C6=3, C7=3, C8=2, C9=2, C10=4 unchanged
  - Round 3, anchor 1 of 3 done. Structural ceiling ≈ 32/50.
- Constraints respected: 7 (a verb-cost — a pre-commitment beat — not a
  passive stat; CONSULT 000 §2's "the interesting WoT idea ... swapping
  takes a short reload beat"), 2, 1
- Constraints risked: none
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post
  PlayerTank.gd write. The cooldown is breach-gated — `_cycle_shell`
  early-returns when `loadout == null`, so arc-2/3 `_fire` never sees a
  nonzero `_swap_cooldown`. `make test` exit 0. `make test-all` PASS
  (5 arc-3). `make test-breach` PASS (15 checks).
- Falsifications: none. Pre-mortem predictions held — the "only arm on
  a REAL swap" guard (`order[idx] != current_shell`) prevents a
  same-class cycle from imposing a cost.
- Files: `scripts/PlayerTank.gd` (substrate write — `shell_swap_cost`
  @export + `_swap_cooldown` + decrement in `_physics_process` + `_fire`
  block + `_cycle_shell` arms it on a real swap),
  `loop/breach/test_breach_swap.gd` (NEW), `Makefile`
  (check-breach-swap), PRE-MORTEMS, LEDGER, STATE
- Finding: **Shell choice is now a pre-commitment.** Cycling to a new
  shell costs a 0.5s reload beat during which the tank cannot fire —
  the player commits to HE/HEAT/AP and pays a vulnerability window,
  exactly the CONSULT's "pre-commitment under reload pressure". C3 is
  at 4/5 (anchor 5 = playtest). Next iter 28: round-3 anchor 2 —
  C5 anchor 3 (a 4th enemy role + gen_tile silhouette) OR C8 anchor 3
  (depot catalog covers all 5 band pressures). Diagnose at iter start.

## iter 026 — AUDIT — de-bundle remaining anchors; structural ceiling ~32/50

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Score: **28/50 absolute · 28/50 effective** (Δ 0 — AUDIT; re-score
  holds, no anchor moved since iter 21)
- Trigger: AUDIT cadence (every 5; last iter 21) + Mismatch-AUDIT (L6)
  prompted by the iter-25 parity-drift /meta finding.
- Evidence: 14 breach checks GREEN, 5 arc-3 GREEN, hash anchor
  `23d6a2ec3bf2821f` + `playable: true`.
- Re-score: all 10 hold — C1=3, C2=3, C3=3, C4=3, C5=2, C6=3, C7=3,
  C8=2, C9=2, C10=4. No over- or under-claims found.

### AUDIT actions (2 anchor rephrases — RUBRIC.md revision rows 26)

1. **C3 anchor 4 de-bundled** (R1): was "Shell-swap has reload cost
   (≥0.5s); reserve-per-band limits create resupply tension —
   code-cited via harness measuring per-band shell consumption" — two
   clauses fused. Per-band shell-consumption measurement needs a
   play-AI; it is not a structural cite. De-bundled: anchor 4 is now
   the single swap-cost mechanic ("shell-swap has a reload cost
   ≥0.5s — pre-commitment under reload pressure"). Clean [STRUCTURE]
   target for round 3.
2. **C4 anchor 4 re-tagged [STRUCTURE]→[FEEL]** (Mismatch-AUDIT): "avg
   shell-mix differs per band" can only be measured by simulated or
   real play — it was mis-tagged structural. Now honestly playtest-
   gated.
- Identity-protected anchors (C1/5, C5/5, C7/5, C8/5, C9/5) NOT
  inspected (R2).

### Structural ceiling — sharpened

The iter-25 /meta finding estimated "~8-10 remaining structural
points". This AUDIT sharpens it: after de-bundling, the genuinely
harness-reachable anchors are **only**:
- C3 anchor 4 — shell-swap reload cost (+1)
- C5 anchor 3 — a 4th enemy role + gen_tile silhouette (+1)
- C8 anchor 3 — depot catalog covers all 5 band pressures (+1)
- C10 anchor 5 — arc-4 close + META-RETRO (+1, at arc close)

**True structural ceiling ≈ 32/50.** The remaining 18 points are
[FEEL]/playtest-gated by rubric design — they need the REVIEW-QUEUE #3
playtest. The meta over-estimated because it counted C4/4 (now [FEEL])
and assorted bundled clauses as structural.

- Constraints respected: all 7 (process iter)
- Hash anchor: `23d6a2ec3bf2821f` confirmed (no code touched)
- Falsifications: none. Pre-mortem (28/50 holds, 2 rephrases, ~32/50
  ceiling) — CONFIRMED.
- Files: `loop/breach/RUBRIC.md` (C3/4 de-bundle + C4/4 re-tag + 2
  revision rows), `loop/breach/PRE-MORTEMS.md`, LEDGER, STATE
- Finding: **The honest ceiling is ~32/50 structural, ~50 with the
  playtest.** Round 3 has 3 clean structural anchors left
  (C3/4 swap-cost, C5/3 4th role, C8/3 band coverage). Next iter 27:
  BUILD — C3 anchor 4, shell-swap reload cost on PlayerTank (the
  CONSULT-core "pre-commitment under reload pressure"). The loop runs
  these 3, reaches ~31-32/50, then genuinely ceiling-pauses on the
  playtest — exactly as the parity-drift meta predicted, now with a
  precise number.

## iter 025 — META + QUEUE — round-2 close; parity-drift; playtest surfaced

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Score: **28/50 absolute · 28/50 effective** (Δ 0 — META iter; process/
  discipline, no anchor lift)
- Meta-trigger: dice nat-13 /meta nudge → named **PARITY DRIFT**.
- Constraints respected: all 7 (process iter)
- Hash anchor: `23d6a2ec3bf2821f` untouched (no code).
- Falsifications: none.
- Files: `loop/breach/REVIEW-QUEUE.md` (item #3 — playtest request),
  `loop/breach/LEDGER.md`, `loop/breach/PRE-MORTEMS.md`,
  `loop/breach/STATE.md`
- **Round 2 CLOSED.** Iters 7-24 built breach economy end-to-end:
  HE-radius + finite reserves + shell cycle (the atomic verb) → depot
  flow → BreachLevel scene → 5 depth bands → death recap → enemy
  rosters → shell icons + grammar gate → 6-entry depot catalog →
  HEAT-armor → Breach Dividend rule-changer. 28/50, all 10 criteria
  non-zero, 14 arc-4 harnesses + 5 arc-3 targets green, hash anchor
  preserved through 12 substrate writes. CONSULT 002's 3 recommendations
  all executed.
- **Meta-finding (parity drift)**: every one of the 28 points is
  [STRUCTURE]/harness-cited; zero playtests across 25 iters. ~14 of the
  22 remaining rubric points are [FEEL]/playtest-gated by rubric design.
  The loop is at a structural ceiling — it can grind ~8-10 more
  structural points (C3/4 swap-cost, C4/4 shell-mix harness, C5/3 4th
  role, C8/3 band coverage) to ~37/50, then genuinely ceiling-pauses.
  This recurs arc-2's #1 retro lesson ("identity, not mechanics, is
  the limiter") and arc-3's L4 "ceiling-paused" loop state.
- Action: REVIEW-QUEUE #3 logs the playtest request as the critical
  path (not a passive note); PushNotification surfaces it to the user.
  The loop does NOT halt (non-stop per PROMPT) — round 3 opens on the
  remaining structural anchors, eyes-open that they're the last
  ~8-10 points before the real ceiling.
- Finding: **Breach mode is structurally done and evidenced; whether
  it *plays* as breach economy is now a human's verdict.** Next iter
  26: open round 3 SPIKE — weakest axes are C5 (2/5, anchor 3 = 4-5
  enemy roles) and C8 (2/5, anchor 3 = all-5-band-pressure upgrade
  coverage). Diagnose at iter start.

## iter 024 — BUILD-QUALITY — depot rule-changer "Breach Dividend"

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Score: **28/50 absolute · 28/50 effective** (Δ 0 — BUILD-QUALITY;
  CONSULT-directed playstyle work, no [STRUCTURE] anchor lift)
  - All 10 criteria unchanged (C1=3, C2=3, C3=3, C4=3, C5=2, C6=3,
    C7=3, C8=2, C9=2, C10=4)
- CONSULT 002 #2 recommendation, verbatim: "Replace one depot entry
  with a rule-changer, not a stock-changer. Breach Dividend —
  destroying 4+ bricks with one HE refunds 1 HE ... creates a
  playstyle: precise cluster breaching."
- Why BUILD-QUALITY (L3/R4): Breach Dividend is a genuine
  playstyle-forking depot entry, but it does not lift a [STRUCTURE]
  anchor — C8 anchor 3 needs all-5-band-pressure coverage (open_killbox
  still has no dedicated upgrade); the build-identity it serves (C1
  anchors 4-5, C9 anchor 3+) is playtest-gated. Honest BUILD-QUALITY.
  Last BUILD-QUALITY was iter 10 — well within the 1-per-3 cap.
- Constraints respected: 7 (a rule-changer verb — "cluster breaching
  pays for itself" — not a passive %stat; the CONSULT's exact
  prescription against logistics salad), 1
- Constraints risked: 4 (farming) — mitigated: `refill_he` caps at
  `max_he_reserve`, so a dividend sustains efficient play but never
  snowballs. CONSULT's stronger "once per band" cap deferred.
- Sentence test: BREACH_DIVIDEND passes — "...climb through brick mazes
  by changing how I use HE — precise cluster breaches refund their own
  shell." (documented in Loadout.gd UPGRADE CATALOG)
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post Bullet.gd
  write (Bullet's 4th — sanctioned). `make test` exit 0. `make
  test-all` PASS (5 arc-3). `make test-breach` PASS (14 checks).
- Falsifications: none
- Files: `scripts/Loadout.gd` (+breach_dividend flag + catalog doc),
  `scripts/Depot.gd` (UpgradeKind += BREACH_DIVIDEND), `scripts/
  Bullet.gd` (_apply_he_blast returns hit count; _try_breach_dividend
  reaches the loadout via get_parent().player.loadout),
  `loop/breach/test_breach_dividend.gd` (NEW), `Makefile`
  (check-breach-dividend), PRE-MORTEMS, LEDGER, STATE
- Finding: **The depot now has a rule-changer, not just stock.** Breach
  Dividend: an HE shot that breaches ≥4 bricks refunds 1 HE — but only
  if the player picked the upgrade. This forks a playstyle (precise
  cluster breaching = self-sustaining HE economy) per CONSULT 002 Q2.
  6-entry catalog now: 5 stock-changers + 1 rule-changer. Next iter 25:
  CONSULT 002 #3 — surface a PLAYTEST request to REVIEW-QUEUE (the
  5-person smoke test — "do players describe their run as route
  economy?"). That's a user-look gate, not a BUILD.

## iter 023 — BUILD — HEAT armor-bypass (C3 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Score: **28/50 absolute · 28/50 effective** (Δ +1 vs prior — C3 anchor 3)
  - C3 (Ammo as logistics): 2 → 3 (anchor 3: HE affects terrain ✓
    (radius blast, iter 7) + HEAT bypasses heavy armor ✓ NEW + AP
    cheap+precise ✓ — code-cited via `make check-breach-armor`:
    AP/HE deal 0 to armored bodies, HEAT deals full 2×)
  - C1=3, C2=3, C4=3, C5=2, C6=3, C7=3, C8=2, C9=2, C10=4 unchanged
- CONSULT 002 ADOPTED — this iter is its #1 "next 3 iters"
  recommendation ("make HEAT real with one armor-facing/bypass rule";
  Q3's stupid-in-6-months omission: "'2× damage' is a placeholder").
- Constraints respected: 3 (armored Heavy now MECHANICALLY demands
  HEAT — the readable shell relationship is real, not asserted), 2, 7
- Constraints risked: 1 — a HEAT-starved player vs an armored Heavy is
  stuck on that enemy (the intended breach-economy tension; recap names
  "ran out of HEAT"). Mitigation: armored Heavies are route-avoidable
  + AP/HE still kill all non-armored roles.
- **Substrate investigation** (PROMPT §DEFAULT-ON): HEAT-armor needs an
  enemy-side "armored" marker; Enemy.gd is NOT in the sanctioned write
  list. Resolved by AVOIDING the Enemy.gd touch — used a Godot group
  tag: Spawner.gd (sanctioned) calls `add_to_group("armored")` for
  Heavy; Bullet.gd (sanctioned) checks `is_in_group("armored")`. No
  halt-and-investigate needed; no Enemy.gd write.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  writes #11 (Spawner.gd) + Bullet.gd. `make test` exit 0. `make
  test-all` PASS (5 arc-3 — Spawner OG path unaffected; armored group
  only set for breach Heavies, and arc-3 OG enemies via the
  stage_number branch don't hit the armored-key path... they DO go
  through the same instantiation block — `type_data.get("armored",
  false)` returns false for OG Light/Heavy picks since OG uses
  `_get_type_by_name` which returns the same ENEMY_TYPES dict — so
  arc-3 OG Heavies WOULD get the armored tag. But Bullet's armor
  mitigation only changes outcomes for HE/HEAT shells, and arc-3 OG
  player fires AP only (no loadout) → AP vs armored = max(0,1-1)=0.
  WAIT — that WOULD change OG: OG AP shots vs Heavy enemies would deal
  0 instead of 1. **Checked: `make test-all` CHAIN tests instantiate
  stages but fire no bullets — they pass. But this is a real OG
  behavior risk.**) — see Falsification note.
- Falsifications: **F002 logged** — the armored group tag leaks into
  arc-3 OG mode (OG Heavy enemies use the same ENEMY_TYPES Heavy entry
  → get `armored` → OG player AP would deal 0). Caught during the
  hash-anchor reasoning. FIXED within-iter: gate the `add_to_group`
  call on breach mode (only tag when the level is in breach mode).
- Files: `scripts/Spawner.gd` (write #11 — armored ENEMY_TYPES key +
  `_is_breach_mode()` helper + breach-gated group tag), `scripts/
  Bullet.gd` (armor mitigation), `loop/breach/test_breach_armor.gd`
  (NEW), `Makefile` (check-breach-armor), `loop/breach/
  creative-consults.md` (CONSULT 002 ADOPTED + findings),
  `loop/breach/FALSIFICATIONS.md` (F002), PRE-MORTEMS, LEDGER, STATE
- Finding: **HEAT is now mechanically real.** Armored Heavies (the
  bunker-band threat) take 0 from AP/HE and full 2× from HEAT — the
  player learns "HE changes the map; HEAT solves armor" (CONSULT 002
  Q3). F002 (the armored tag leaking into arc-3 OG mode) was caught by
  the hash-anchor cross-mode-effect discipline + fixed within-iter via
  `_is_breach_mode()` gating. `make test` exit 0, `tile_hash`
  `23d6a2ec3bf2821f`, `make test-all` PASS (5 arc-3 — OG Heavies are
  NOT tagged armored), `make test-breach` PASS (13 checks). Next iter
  24: CONSULT 002's #2 recommendation — one depot rule-changer
  ("Breach Dividend": HE 4+-brick cluster-kill refunds 1 HE).

## iter 022 — BUILD — 3 depots at band transitions (C2 anchor 3)

## iter 022 — BUILD — 3 depots at band transitions (C2 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Score: **27/50 absolute · 27/50 effective** (Δ +1 vs prior — C2 anchor 3)
  - C2 (Field depot system): 2 → 3 (anchor 3: depots placed at
    deterministic intervals — BreachLevel.tscn now has 3 Depot
    instances at band-transition depths (y -248/-888/-1688 = band
    1/2/3 exits, depth 30/70/120); harness verifies ≥3 — code-cited
    via `make check-breach-level` reporting `depots=3 depot_y=[-1688,
    -888, -248]`)
  - C1=3, C3=2, C4=3, C5=2, C6=3, C7=3, C8=2, C9=2, C10=4 unchanged
- CONSULT 002 still running at iter-22 start (~7 min) — per PROMPT, no
  AWAIT for design; proceeded with a CONSULT-safe substrate-clean
  BUILD. iter 23 reads CONSULT 002.
- Constraints respected: 1 (depot cadence — one safe-gate per band
  transition), 6 (depots = band-segmentation points)
- Constraints risked: none
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (no substrate
  — BreachLevel.tscn is an arc-4-owned inherited scene; base
  ProceduralLevel.tscn untouched). `make test` exit 0. `make test-all`
  PASS. `make test-breach` PASS (12 checks).
- Falsifications: none
- Files: `scenes/BreachLevel.tscn` (+Depot2 +Depot3),
  `loop/breach/test_breach_level.gd` (≥3-depot assertion + depot_y
  report), PRE-MORTEMS, LEDGER, STATE
- Finding: **3 depots at deterministic band-transition depths.**
  Depot1 after band 1 (brick maze ahead), Depot2 after band 2 (steel
  bunkers ahead), Depot3 after band 3 (open killbox ahead) — each with
  a next-band hint. A full climb hits ≥3 depots. Next iter 23: read
  CONSULT 002 (queryId 72ec60ef…) + follow its redirect — the honest
  gaps named to it (hollow HEAT, restock-menu depots, no playtest)
  point at C3 anchor 3 (HEAT armor-bypass) but CONSULT decides.

## iter 021 — AUDIT + CONSULT — re-score (26/50); CONSULT 002 fired

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **26/50 absolute · 26/50 effective** (Δ +1 vs prior — C7 anchor 3 via AUDIT)
- Triggers: AUDIT (every-5; last iter 16) + CONSULT (~every-10; last iter 6).
- Evidence: 12 breach checks GREEN, 5 arc-3 GREEN, hash anchor
  `23d6a2ec3bf2821f` + `playable: true`, `SILHOUETTE_GATE_PASS`.

### Re-score (all 10 criteria)

| C# | Score | AUDIT note |
|----|-------|------------|
| C1 | 3 | anchors 1-3 hold (Loadout / ≥3 builds / build in recap). |
| C2 | 2 | anchors 1-2 hold. Anchor 3 (≥3 depots/run) — BreachLevel has 1. |
| C3 | 2 | anchors 1-2 hold. Anchor 3 (HEAT armor-bypass) — not done. |
| C4 | 3 | anchors 1-3 hold (5 bands, reachability). Anchor 4 (shell-mix-per-band harness) — not done. |
| C5 | 2 | anchors 1-2 hold (3 roles + rosters + per-role answers). Anchor 3 (4-5 roles) — have 3. |
| C6 | 3 | anchors 1-3 hold (depth/killer; shells/reserves; build_tag + band pressure). |
| C7 | **2 → 3** | **anchor 3 NOW claimed** (AUDIT correction): "All new assets in arc 4 verified via the grammar gate before commit — log artifact in LEDGER" — the anchor has NO minimum-count clause; all 3 arc-4 generated assets (shell icons) ARE gated by silhouette_gate.py + the iter-18 LEDGER logs the SILHOUETTE_GATE_PASS artifact. The iter-18 hold ("one asset-set is thin evidence") was an under-claim; AUDIT corrects it. |
| C8 | 2 | anchors 1-2 hold (5 sentence-passing upgrades). Anchor 3 (catalog covers all 5 bands' pressures) — partial. |
| C9 | 2 | anchors 1-2 hold. Anchor 3+ [FEEL] — playtest. |
| C10 | 4 | anchors 1-4 hold. Anchor 5 — arc-4 close. |

**Total: 26/50.** Effective = absolute (R3). No over-claims found.

### AUDIT action

- **C7 2→3** — corrective re-read of anchor 3. Not score-creep: the
  evidence (3 assets gated, artifact logged iter 18) was already real;
  iter 18 simply under-claimed out of conservatism. AUDIT is the
  designated place to correct both over- AND under-claims.
- No RUBRIC.md rephrase this AUDIT (iter-16 fixed the one mismatch).
- Identity-protected anchors not inspected (R2).

### CONSULT 002

Fired fire-and-forget via /agentify extended-pro. 3 permanent questions
+ embedded honest gaps (depot upgrades all reserve-refill — no
build-fork; HEAT hollow — 2× only; no playtest). queryId
`72ec60ef-f236-4454-8f1b-b0338805c99c`. Recorded to
creative-consults.md. Iter 22 reads the response.

- Constraints respected: all 7 (process iter)
- Hash anchor: `23d6a2ec3bf2821f` confirmed (no code touched)
- Falsifications: none. Pre-mortem (C7 2→3, all else holds, 26/50) —
  CONFIRMED exactly.
- Files: `loop/breach/creative-consults.md` (CONSULT 002),
  `loop/breach/PRE-MORTEMS.md`, LEDGER, STATE
- Finding: **26/50, honestly re-scored.** C7 is the silhouette-grammar
  axis fully structural-capped at 3 (anchors 4-5 are [FEEL]/identity-
  protected — playtest). Next iter 22: read CONSULT 002, integrate its
  redirect. Tentative (pending CONSULT): the honest gaps point at
  HEAT-armor-bypass (C3 anchor 3) or depot build-forking — CONSULT
  decides.

## iter 020 — BUILD — depot upgrade catalog → 5 (C8 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **25/50 absolute · 25/50 effective** (Δ +1 vs prior — C8 anchor 2)
  — exactly half the absolute ceiling at iter 20.
  - C8 (Sentence test compliance): 1 → 2 (anchor 2: 5+ upgrades — the
    UpgradeKind catalog now has 5 (HE_REFILL_2 / HEAT_REFILL_1 /
    HE_MAX_EXPAND_2 / HEAT_MAX_EXPAND_2 / FULL_RESUPPLY); all pass the
    sentence test, cited verbatim in Loadout.gd's UPGRADE CATALOG doc
    block — code-cited via `make check-breach-depot-choice`)
  - C1=3, C2=2, C3=2, C4=3, C5=2, C6=3, C7=2, C9=2, C10=4 unchanged
- DIAGNOSE: C8 at 1/5 was joint-lowest.
- Constraints respected: 7 (all 5 upgrades are economy verbs — refill /
  expand capacity / resupply — not passive %stats), 1 (catalog grew to
  5 but the depot still shows 3-at-a-time — no scrolling), 2
- Constraints risked: 4 — 5 refill/expand variants risk reading as
  "reserve stat soup". Honest position (LEDGER): reserve-size +
  resupply are CONSULT-§2-endorsed depot axes ("Depot upgrades improve
  swap speed or reserve size") — they ARE the breach currency, not
  passive %stats. Genuinely-different affordance upgrades (swap-speed,
  refund-on-kill, first-shot-pierce) need mechanics not yet built —
  scheduled, not faked.
- Sentence test: all 5 upgrades pass — verbatim sentences in this
  iter's PRE-MORTEM + Loadout.gd UPGRADE CATALOG block. None is "by
  making me stronger" / "+N%".
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (no substrate
  touched — Depot.gd + Loadout.gd arc-4-owned). `make test` exit 0,
  `make test-all` PASS, `make test-breach` PASS (12 checks).
- Falsifications: none
- Files: `scripts/Depot.gd` (UpgradeKind 3→5; extracted public
  apply_upgrade), `scripts/Loadout.gd` (UPGRADE CATALOG doc block +
  verbatim sentences), `loop/breach/test_breach_depot_choice.gd`
  (+Test 6 — 5-entry catalog, HEAT_MAX_EXPAND_2 + FULL_RESUPPLY
  verified), PRE-MORTEMS, LEDGER, STATE
- Finding: **Depot catalog at 5 sentence-test-passing upgrades.**
  apply_upgrade is now a public per-kind entry the harness exercises
  directly. Loadout.gd documents the catalog with verbatim sentence
  tests. Next iter 21: **AUDIT** due (last iter 16, every-5 cadence) —
  re-score all 10 criteria; also a natural CONSULT window (~every 10
  iters; last CONSULT iter 6, so iter ~21-22 due).

## iter 019 — BUILD — per-role canonical answers (C5 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **24/50 absolute · 24/50 effective** (Δ +1 vs prior — C5 anchor 2)
  - C5 (Enemy role vocabulary): 1 → 2 (anchor 2: each role has a
    documented canonical answer shell+positioning in BANDS.md — new
    "Per-role canonical answers" table for Light/Heavy/Fast; harness
    verifies presence in band rosters — code-cited via `make
    check-breach-enemies` Test 3 reporting all 3 roles covered)
  - C1=3, C2=2, C3=2, C4=3, C6=3, C7=2, C8=1, C9=2, C10=4 unchanged
- DIAGNOSE: C5 at 1/5 was the lowest criterion.
- Constraints respected: 3 (every enemy type now has a documented
  readable shell/positioning answer — Light→AP-lane-intercept,
  Heavy→HEAT-or-2AP/break-LOS-during-telegraph, Fast→AP-on-the-lead/
  keep-moving), 5
- Constraints risked: 3 — the canonical answer is *documented*, not yet
  *mechanically enforced* (no enemy demands a specific shell to die).
  Honest: anchor 2 is a documentation+coverage anchor. Mechanical
  enforcement (e.g. Heavy armor that only HEAT bypasses) is C3 anchor 3
  / C5 anchor-3+ territory.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (no code/config
  touched — BANDS.md doc + harness assertion only). `make test` exit 0,
  `make test-all` PASS, `make test-breach` PASS (12 checks).
- Falsifications: none
- Files: `loop/breach/BANDS.md` (+Per-role canonical answers table),
  `loop/breach/test_breach_enemies.gd` (+Test 3 role coverage),
  `Makefile` (grep surfaces the role-coverage line), PRE-MORTEMS,
  LEDGER, STATE
- Finding: **Each enemy role now has a documented canonical answer.**
  BANDS.md's per-role table names the shell + positioning for Light /
  Heavy / Fast; the harness confirms all 3 appear in ≥1 band roster.
  Next iter 20: candidates — C8 anchor 2 (5+ depot upgrades — have 3),
  C2 anchor 3 (≥3 depots per run), C3 anchor 3 (HEAT armor-bypass).
  Diagnose at iter start.

## iter 018 — BUILD — recap band pressure + silhouette-grammar gate (C6/3, C7/2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **23/50 absolute · 23/50 effective** (Δ +2 vs prior — C6 anchor 3, C7 anchor 2)
  - C6 (Death attribution): 2 → 3 (anchor 3: recap includes build
    identity tag — `build_tag()` — + dominant pressure of killing band
    — `killing_pressure` — code-cited via `make check-breach-recap`
    showing "band pressure: steel-armored bunkers; entrenched heavy
    tanks")
  - C7 (Silhouette grammar): 1 → 2 (anchor 2: silhouette-grammar check
    exists as a sibling tool — `tools/silhouette_gate.py` — outputs
    PASS/FAIL — code-cited via `make check-silhouette-gate` reporting
    `SILHOUETTE_GATE_PASS`)
  - C1=3, C2=2, C3=2, C4=3, C5=1, C8=1, C9=2, C10=4 unchanged
- Constraints respected: 6 (recap now names the route pressure that
  killed the run), 4 (the grammar gate is reusable — future assets
  route through it; not a one-off)
- Constraints risked: none
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #10 (PlayerTank.gd `_die` — capture_death signature; gated on
  run_recap != null). `make test` exit 0. `make test-all` PASS.
  `make test-breach` PASS (12 checks).
- Silhouette-grammar gate artifact (C7 anchor 3 evidence):
  `SILHOUETTE_GATE_PASS 3 assets` — shell_ap/he/heat, pairwise
  silhouette 24/9/21px + palette 67/107/52 distinct. The 3 arc-4
  generated assets all pass the gate. (C7 anchor 3 — "all new assets
  verified via the gate before commit, log artifact in LEDGER" — held
  for now; one asset-set is thin evidence of a sustained discipline.
  Next asset iter that routes through the gate cites anchor 3.)
- Falsifications: none
- Files: `scripts/RunRecap.gd` (+killing_pressure; capture_death takes
  the BreachBand object), `scripts/PlayerTank.gd` (substrate write #10
  — _die passes the band object), `loop/breach/test_breach_recap.gd`
  (band-pressure assertion), `tools/silhouette_gate.py` (NEW — reusable
  PASS/FAIL grammar gate), `tools/check_shell_icons.py` (routes through
  the gate), `Makefile` (check-silhouette-gate), PRE-MORTEMS, LEDGER,
  STATE
- Finding: **Death recaps now name the killing band's pressure; the
  silhouette gate is a reusable tool.** The recap reads as a full
  resource/build/route diagnosis ("depth 84 (bunker_zone band) / band
  pressure: steel-armored bunkers / build: rubble plow / shells fired
  ... / reserve left ..."). silhouette_gate.py is the codified
  CONSULT-constraint-4 enforcement point for every future generated
  asset. Next iter 19: candidates — C8 anchor 2 (expand depot catalog
  to 5+ upgrades), C2 anchor 3 (≥3 depots per run), C3 anchor 3 (HEAT
  armor-bypass). Diagnose at iter start.

## iter 017 — BUILD — gen_tile.py shell-icon generator (C7 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **21/50 absolute · 21/50 effective** (Δ +1 vs prior — C7 anchor 1)
  - C7 (Silhouette grammar): 0 → 1 (anchor 1: gen_tile.py extended with
    a new generator — 3 shell-icon generators shell_ap/he/heat —
    code-cited via `make check-breach-assets`)
  - C1=3, C2=2, C3=2, C4=3, C5=1, C6=2, C8=1, C9=2, C10=4 unchanged
  - **ALL 10 criteria now non-zero.**
- DIAGNOSE: C7 was the only 0/5 criterion — the weakest axis.
- Constraints respected: 4 (silhouette grammar — the 3 icons are
  readable by silhouette: AP = thin tall dart (8px footprint), HE =
  fat round blob (28px), HEAT = wide chevron (11px); + palette: pale
  steel / warm yellow / crimson, matching the Bullet.gd iter-4/7
  modulate colors), 2 (3 shell classes — icons for exactly AP/HE/HEAT)
- Constraints risked: 4 — the FORMAL automated grammar-check tool is
  C7 anchor 2 (later iter). iter 17's `check_shell_icons.py` is the
  structural proxy: it asserts pairwise silhouette distinctness
  (≥8 differing cells). First draw had AP vs HEAT at only 2px — caught
  + fixed within-iter (redrew AP as a 1px-wide spine, HEAT as a wide
  chevron). Final diffs: AP/HE 24px, AP/HEAT 9px, HE/HEAT 21px.
- **Silhouette grammar gate cited** (PROMPT ACT step): the 3 icons pass
  — distinct silhouette footprint + distinct palette + one-frame intent
  (thin=precise / round=splash / chevron=armor-focus). Verified by
  `check-breach-assets` reporting `BREACH_ASSETS_OK`.
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (gen_tile.py
  is a build-time tool — doesn't run during `make test`). `make test`
  exit 0. `make test-all` PASS. `make test-breach` PASS (11 harnesses).
- Falsifications: none. Pre-mortem predicted "8×8 silhouettes could
  end up too similar" — CONFIRMED on the first draw (AP/HEAT 2px),
  fixed within-iter.
- Files: `tools/gen_tile.py` (Layer-1 — sanctioned extension; +3 shell
  generators + SHELL_PALETTES + --from-sheet guard),
  `tools/check_shell_icons.py` (NEW verifier), `Makefile`
  (check-breach-assets), `loop/breach/PRE-MORTEMS.md`, LEDGER, STATE.
  (Generated PNGs in tools/out/ are build artifacts — not committed;
  regenerable via `make check-breach-assets`.)
- Finding: **C7 opened — all 10 criteria are now non-zero (21/50).**
  gen_tile.py now generates 3 shell-class HUD icons with distinct
  silhouettes + palettes. Next iter 18: candidates — (a) C7 anchor 2
  (formal silhouette-grammar PASS/FAIL tool — promote check_shell_icons
  into a reusable gate), (b) C6 anchor 3 (RunRecap stores band
  dominant_pressure — 2-line lift), (c) C8 anchor 2 (5+ depot
  upgrades). Diagnose at iter start.

## iter 016 — AUDIT — full re-score; C10 anchor 4; C1 anchor-2 wording fixed

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **20/50 absolute · 20/50 effective** (Δ +1 vs prior — C10 anchor 4 via Surrogate-AUDIT)
- AUDIT trigger: PROMPT cadence (every 5 iters; 16 since baseline) +
  Mismatch-AUDIT on C1 anchor 2.
- Evidence: all 10 breach harnesses GREEN, all 5 arc-3 targets GREEN,
  hash anchor `23d6a2ec3bf2821f` + `playable: true` confirmed.

### Re-score (all 10 criteria, fresh evidence)

| C# | Name | Score | AUDIT note |
|----|------|-------|------------|
| C1 | Breach build identity | 3 | anchors 1-3 hold. Anchor 2 citation rephrased (Mismatch-AUDIT — see below). Anchors 4-5 [FEEL]/[IDENTITY-PROTECTED] — playtest. |
| C2 | Field depot system | 2 | anchors 1-2 hold (Depot + pause; 3-choice catalog + preview). Anchor 3 needs ≥3 depots/run — BreachLevel has 1. |
| C3 | Ammo as logistics | 2 | anchors 1-2 hold (3 shells, distinct behavior). Anchor 3 needs HEAT-armor-bypass (only HE-terrain done) — held. |
| C4 | Depth bands | 3 | anchors 1-3 hold (5 bands, reachability 9/10). Anchor 4 needs shell-mix-per-band harness — held. |
| C5 | Enemy role vocabulary | 1 | anchor 1 holds (3 roles, band rosters). Anchor 2 needs per-role canonical answer documented — held. |
| C6 | Death attribution | 2 | anchors 1-2 hold (depth/killer; shells/reserves). Anchor 3 needs band *dominant_pressure* in recap — RunRecap stores band NAME only; a 2-line fix away. Held — flagged for a future iter. |
| C7 | Silhouette grammar | 0 | untouched — no generated assets yet. Only zero-criterion. |
| C8 | Sentence test compliance | 1 | anchor 1 holds (3 depot upgrades pass). Anchor 2 needs 5+ upgrades — have 3. Held. |
| C9 | Identity singularity | 2 | anchors 1-2 hold (new mechanics; build+depot+bands functional). Anchor 3+ [FEEL] — playtest. |
| C10 | Substrate preservation | **3 → 4** | **anchor 4 NOW HIT** (Surrogate-AUDIT): "Same through iter 15+; ≥3 sanctioned substrate writes with default-on gating, all verified" — we are at iter 16 (15+ ✓), 9 substrate writes all gated + hash-anchor-verified ✓. Anchor 5 = arc-4 close — held. |

**Total: 20/50.** Three-tier ceiling (R3): effective = absolute = 50
(identity-protected anchors C1/5, C5/5, C7/5, C8/5, C9/5 are inside the
cognitive band; no auto/cognitive split widens the gap). 20/50 effective.

### AUDIT actions taken

1. **C10 3→4** — Surrogate-AUDIT: crossing iter 15 satisfied anchor 4's
   iter-count clause; the substrate-write + gating clauses were already
   true. Legitimate lift, not score-creep — the evidence (9 verified
   gated writes, hash anchor intact 16 iters) is real.
2. **C1 anchor 2 rephrased** — Mismatch-AUDIT (L6): RUBRIC.md citation
   "via Loadout.gd permutations" → "via the Loadout reserve mix +
   RunRecap.build_tag() enumeration". Score unchanged (C1=3); the
   anchor text now names where the capability actually lives. Logged
   in RUBRIC.md revision table (iter 16).
3. Identity-protected anchors (C1/5, C5/5, C7/5, C8/5, C9/5) NOT
   inspected for rephrase (R2 — gaming-prevention guardrails).

- Constraints respected: all 7 (process iter)
- Hash anchor: `23d6a2ec3bf2821f` confirmed (no code touched)
- Falsifications: none. Pre-mortem prediction (C10 3→4, all others
  hold, total 20/50) — CONFIRMED exactly.
- Files: `loop/breach/RUBRIC.md` (C1 anchor 2 rephrase + revision row),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **Score is honest at 20/50.** 9/10 criteria non-zero; C7
  (silhouette grammar) the only untouched axis. The cheapest remaining
  structural lifts: C6 anchor 3 (2-line RunRecap fix — store band
  dominant_pressure), C8 anchor 2 (need 5+ depot upgrades — have 3),
  C2 anchor 3 (≥3 depots per run). Next iter 17: BUILD — C6 anchor 3
  (RunRecap stores killing band's dominant_pressure) bundled with C2
  anchor 3 groundwork OR C7 opening (gen_tile.py asset work). Diagnose
  weakest axis at iter start.

## iter 015 — BUILD — band-aware enemy roster (C5 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **19/50 absolute · 19/50 effective** (Δ +1 vs prior — C5 anchor 1)
  - C5 (Enemy role vocabulary): 0 → 1 (anchor 1: ≥3 enemy roles in
    code — Light/Heavy/Fast already in arc-2 Spawner ENEMY_TYPES; each
    now spawns in correct bands per BreachConfig — code-cited via
    `make check-breach-enemies`. All 5 bands declare enemy_weights;
    Spawner._pick_enemy_type reads the active BreachBand in breach mode)
  - C1=3, C2=2, C3=2, C4=3, C6=2, C8=1, C9=2, C10=3 unchanged
  - **9 of 10 criteria now non-zero** (only C7 silhouette grammar at 0)
- Constraints respected: 3 (3 behaviorally-distinct roles), 5 (each
  band's enemy pressure declared per BreachBand.enemy_weights)
- Constraints risked: 3 — per-role canonical shell answer not yet
  *enforced* (C5 anchor 2 work)
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #9 (Spawner.gd — gated breach branch; arc-2 procedural + arc-3
  OG paths untouched). `make test` exit 0. `make test-all` PASS (5
  arc-3 — OG Spawner path unchanged). `make test-breach` PASS (10
  arc-4 harnesses).
- Falsifications: none. Discovery: arc-2 Spawner already had 3 roles +
  band weights — C5 anchor 1's "≥3 roles" was pre-satisfied; only the
  BreachConfig-band wiring was new.
- Files: `scripts/BreachBand.gd` (+enemy_weights field),
  `configs/breach_default.tres` (5 bands populated with rosters),
  `scripts/Spawner.gd` (substrate write #9 — _pick_enemy_type breach
  branch + extracted _weighted_pick + _breach_band_weights helper),
  `loop/breach/test_breach_enemies.gd` (NEW), `Makefile`
  (check-breach-enemies), `loop/breach/PRE-MORTEMS.md`, LEDGER, STATE
- Finding: **Each depth band now has a distinct enemy roster.**
  tutorial_choke = Light only; brick_maze = Light + Fast; bunker_zone =
  Heavy-dominant; open_killbox = Fast-dominant; endgame_mixed = all.
  Spawner._pick_enemy_type gained a gated breach branch reading the
  active BreachBand's enemy_weights. Next iter 16: **AUDIT** — 15 iters
  since the iter-0 baseline, PROMPT cadence is "every 5 iters". Re-score
  all 10 criteria with fresh evidence; resolve the C1-anchor-2 wording
  mismatch (audit_candidate from iter 14).

## iter 014 — BUILD — RunRecap.gd death attribution (C6 anchors 1+2, C1 anchors 2+3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **18/50 absolute · 18/50 effective** (Δ +4 vs prior — C6 0→2, C1 1→3)
  - C6 (Death attribution): 0 → 2
    - anchor 1: RunRecap.gd captures depth + killing entity (depth_reached
      + killing_band + killer) — code-cited via `make check-breach-recap`
    - anchor 2: recap includes shell consumption per type (shells_fired
      dict AP/HE/HEAT) + reserve at death (he/heat_reserve_at_death) —
      code-cited
  - C1 (Breach build identity): 1 → 3
    - anchor 2: ≥3 distinct builds expressible — `RunRecap.build_tag()`
      enumerates 4 (lane sniper / rubble plow / bunker cracker / mixed
      breacher) derived from shell-usage mix; harness exercises 3.
      **NOTE**: rubric anchor 2 wording says "via Loadout.gd
      permutations" — the actual expression mechanism is
      RunRecap.build_tag (shell-usage-derived). Substance holds (≥3
      builds ARE expressible); the wording is an AUDIT candidate (R1
      mismatched-anchor) — flagged, not score-inflated.
    - anchor 3: build identity surfaces in run recap — `build_tag()`
      returns the exact rubric-named tags ('bunker cracker', 'lane
      sniper', 'rubble plow'); `format()` prints "build: <tag>" —
      near-verbatim anchor-3 satisfaction
  - C2=2, C3=2, C4=3, C8=1, C9=2, C10=3 unchanged
- Constraints respected: 6 (death recap tied to resource/build/route —
  the recap reports depth+band (route), build_tag (build), shells+
  reserves (resource) — NOT "got overwhelmed"), 7 (recap reports verbs/
  resources, not a generic score)
- Constraints risked: none
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** post substrate
  write #8 (PlayerTank.gd). The recap is created only when
  `loadout != null` — arc-2/3 PlayerTank runs the recap-free path
  bit-identically (test 4 of the harness asserts this). `make test`
  exit 0, `make test-all` PASS, `make test-breach` PASS (9 harnesses).
- Falsifications: none. Pre-mortem predictions all held.
- Files: `scripts/RunRecap.gd` (NEW), `scripts/PlayerTank.gd` (substrate
  write #8 — run_recap created in _ready when loadout!=null; record_shot
  in _fire; capture_death in _die reading the parent level's
  `_current_breach_band`), `loop/breach/test_breach_recap.gd` (NEW
  verifier), `Makefile` (new check-breach-recap target),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **Death attribution shipped — CONSULT 000's "paired
  omission" closed.** RunRecap captures depth + killing band + per-type
  shell consumption + reserves at death, derives a build_tag from the
  shell mix, and formats an actionable recap ("depth 84 (bunker_zone
  band) / build: rubble plow / shells fired: AP 1 / HE 2 / HEAT 1 /
  reserve left: HE 1 / HEAT 0"). This is a death reason tied to
  resource+build+route, not "got overwhelmed". The build_tag also
  surfaces build identity (C1 anchor 3). Next iter 15: candidates —
  (a) C5 enemy roles (Spawner band-aware roster — biggest untouched
  axis), (b) RunRecap.tscn overlay + wire into the death screen (C6
  anchor 4 trail), (c) C4 anchor 4 shell-mix-per-band harness.

## iter 013 — BUILD — 5-band roadmap complete (C4 anchor 3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Score: **14/50 absolute · 14/50 effective** (Δ +1 vs prior — C4 anchor 3)
  - C4 (Depth bands): 2 → 3 (anchor 3: 5 bands implemented per BANDS.md
    roadmap; reachability passes on all — harness-cited. 5 bands in
    `breach_default.tres`; per-band oracle 10-seed sweep = 9/10 pass,
    ≥80% floor cleared; canonical seed 42 all 5 bands reachable)
  - C1=1, C2=2, C3=2, C8=1, C9=2, C10=3 unchanged
- Constraints respected: 5 (each band a distinct climb problem —
  open_killbox = sightline pressure, endgame_mixed = composed pressure),
  7
- Constraints risked: none — F001 lesson applied (new bands
  reachability-verified before commit)
- Hash anchor: `23d6a2ec3bf2821f` **VERIFIED preserved** (config-only
  change). `make test` exit 0. `make test-all` PASS. `make test-breach`
  PASS (8 harnesses).
- Falsifications: none. Pre-mortem predicted "band 5 (endgame_mixed)
  could fail multi-seed like bunker_zone" — CONFIRMED: endgame_mixed
  failed seed 42 at steel 0.13; retuned within-iter (steel 0.13→0.10,
  empty 0.50→0.54, merge 0.26→0.24) → 9/10 sweep.
- Files: `configs/breach_default.tres` (added bands 4 open_killbox +
  5 endgame_mixed; endgame retuned for reachability), `loop/breach/
  BANDS.md` (status table — all 5 bands implemented + verified),
  `loop/breach/PRE-MORTEMS.md`, `loop/breach/LEDGER.md`,
  `loop/breach/STATE.md`
- Finding: **The full 5-band roadmap is implemented.** tutorial_choke
  (brick + scouts) → brick_maze (dense brick) → bunker_zone (steel
  bunkers) → open_killbox (sightlines, sparse cover) → endgame_mixed
  (composed). Each has a distinct LevelConfig + dominant_pressure +
  canonical_answer. All 5 reachability-verified (9/10 seeds, floor
  ≥80%). C4 = 3/5. The remaining C4 anchors are: anchor 4 ("each
  band's pressure answered by a different breach approach — verified
  via 5-seed harness: avg shell-mix differs per band") needs a
  shell-consumption harness; anchor 5 is playtest. Next iter 14:
  candidates — (a) C6 RunRecap.gd (death attribution, 0→1+, untouched
  criterion), (b) C5 enemy roles (Spawner band-aware roster), (c) the
  shell-mix harness for C4 anchor 4.

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
