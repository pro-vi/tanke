# Q1 Proof-Room — Playtest Brief

**Shipped:** iters 283-290 (Round 24 reframe per user direction Option B at iter 283).
**Built to test:** consult-001 Q1 (verdict confidence 0.90) — "shells are route currency, not just damage flavor."

---

## Launch

```bash
godot --path /Users/provi/Development/_projs/tanke scenes/Q1ProofRoom.tscn
```

The proof room is a standalone scene — does NOT load via TitleScreen or
the procedural baseline. Player starts in the HE lane (auto-pick V1).

---

## What you'll see

```
        ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲       ← GOAL (top of band)
        ┌─────┬─────┬─────┬──────┐
        │     │     │     │      │
        │  HE │ APCR│HEAT │  AP  │
        │lane │ lane│lane │ lane │
        │     │     │     │      │
        │BBBBB SSSSS  H    L.L   │   ← GATE ROW (row 14)
        │     │     │     │      │
        │     │     │     │      │
        │  P  │  P  │  P  │  P   │   ← player starts (4 lanes)
        └─────┴─────┴─────┴──────┘
        col 0    5    10    15  20
```

- **HE lane** (cols 0-4): 5-cell brick cluster. **HE clears it in 1 shot** (blast radius).
  AP would need ~20-25s of individual hits.
- **APCR lane** (cols 5-9): 5-cell steel barrier. **Only APCR drills it.**
  AP/HE/HEAT BOUNCE off steel. This lane is IMPASSABLE without APCR.
- **HEAT lane** (cols 10-14): 1 entrenched Heavy (hp=3, armored).
  **HEAT 2-shots** (2× damage to armored). AP takes 6 shots while exposed.
- **AP lane** (cols 15-20): 2 Light patrol (hp=1 each).
  **AP rotation handles it** — this is the baseline "free" lane.

The proof room's design claim: **shells aren't just damage flavors; each
shell is a different route's currency.**

---

## The 3 falsifiable predictions to score

Consult-001 (Pro extended-thinking, iter 279) made these predictions. Each
expects a specific observation in playtest. Mark each as **hit / partial / miss**
after playing.

### Prediction 1 — Shell/reload legibility passes; active-build legibility fails

- **expected_observation:** Within 3 seconds of static screen, you can name
  current shell + reload state. During combat, you CANNOT explain the
  active-cards ribbon's 2-letter codes (HP/BEAM/MOVE/RLD/etc) without prior
  teaching.
- **falsified_if:** ≥80% of fresh testers correctly identify current shell,
  reload state, AND the meaning of ≥5 active card chips during live combat
  without a legend or explanation.

### Prediction 2 — Top-left reload read AFTER combat, not USED during combat

- **expected_observation:** You notice the reload bar when asked or when the
  screen is calm; in fights, you fire by rhythm / failed input / projectile
  observation rather than glancing top-left.
- **falsified_if:** You visibly delay shots based on the bar during enemy
  pressure AND can later say you used the top-left bar to time firing at
  least twice in one run.

### Prediction 3 — Bottom-left route/card/shell stacking IGNORED under pressure

- **expected_observation:** During active combat, you attend to tank position
  / enemies / bullets / HP / current shell ONLY. Route strip and active-cards
  ribbon become post-hoc information rather than decision-driving.
- **falsified_if:** You make ≥1 route/build/shell decision during combat AND
  explicitly cite the bottom-left ribbon or route strip as the reason without
  being prompted.

---

## STATE → DECISION GATE (consult-001 H1 fix, iter 293)

The original Phase A acceptance was a STATIC-SCREEN test: "stranger names
current shell + reload state + active build within 3 seconds." That's
necessary but not sufficient — consult-001 verdict Q3 (0.92) named the
trap: *"phase can pass the screen-reading test while failing the play
test."* You can label every system, satisfy every naming test, and
still ship HUD-as-decoration if the player never USES it.

H1 (consult-001 conf 0.86) adds a second gate. After playing:

> **Did visibility CHANGE your behavior?**

For each shipped HUD widget, ask whether you actually USED it during
the run:

- **Reload bar (top-left + tank-adjacent pip):**
  - Did you DELAY a shot because you saw the bar still filling?
  - Did you use the tank-adjacent pip in combat, the top-left bar
    in calm moments, or both?
  - Or did you fire by rhythm / failed input / projectile observation,
    ignoring both readouts?
- **Shell chips row:**
  - Did you SEE your reserves dwindling and switch shells preemptively?
  - Or did you discover empty reserves only when you tried to fire?
- **Speed meter (SPD N.N×):**
  - Did you NOTICE the speed boost actually matter — did you take a
    riskier path / try to outrun something / extend a sprint window
    because the meter showed > 1.0×?
  - Or was it numerical decoration?
- **Active-cards ribbon (bottom-left, 3-5 char tokens):**
  - Did you remember what cards you picked WITHOUT consulting the ribbon?
  - Did you make a synergy decision based on the visible stack?
- **Kill-flash (shell-tinted death burst):**
  - Did you notice "ah, that was my HEAT shot" vs "that was my AP"?
  - Did the color change your sense of which shell did what work?
- **Q3 recap (death overlay "ROUTE: ... / COMBAT: ..."):**
  - After your run, did the breakdown surprise you? Did it match what
    you THOUGHT you spent shells on, or did it surface a gap?

**The state→decision gate passes when** you can name at least one
moment where the HUD changed what you did. The screen-reading gate
catches LEGIBILITY; the state→decision gate catches USABILITY UNDER
PRESSURE. Both gates are required for Phase A acceptance.

If you can't name a state→decision moment for a widget, that widget
either (a) needs a stronger affordance (the consult's H6 visibility-
classes recommendation addresses this) or (b) has the wrong placement
(the iter-292 tank-adjacent pip is the experiment for the reload bar
specifically — does combat-focus placement change usage vs the top-
left bar alone?).

---

## What to look for (Q1 verdict-specific)

Beyond the predictions, the central Q1 claim is:

> **"Shells are route currency, not just damage flavor."**

After 1-2 playthroughs, ask yourself:
1. Did your choice of which shell to STOCKPILE feel like a choice of which
   LANE you'd take? Or did all lanes feel interchangeable?
2. When you spent an HE on the brick cluster, did it feel like SPENDING
   CURRENCY (something you'd be without later) or just FIRING A WEAPON?
3. Was the APCR-only-drills-steel rule something you discovered through
   play, or did you have to read the brief?
4. Does the proof room change your felt sense of what shells ARE in this
   game — or does it just demonstrate the same primitives more clearly?

The structural verification harnesses (`make check-breach-q1-proof-*`)
prove the design INTENT is enforced at code level. This brief asks
whether the design intent LANDS at human-feel level. They can diverge.

---

## What's not yet in (honest scope)

- **No pick UI:** V1 auto-spawns player in HE lane. To play other lanes,
  edit `scripts/Q1ProofRoomScene.gd:V1_PLAYER_LANE` to "APCR" / "HEAT" / "AP".
- **No goal trigger:** crossing the GOAL row doesn't fire any
  run-complete event yet. You'll know you "won" by reaching the top.
- **No timer / no per-lane recap:** `RunRecap.shells_spent_on_routes` is
  populated but not surfaced on screen yet. Use `print(player.run_recap.shells_spent_on_routes)`
  in a debug build if you want to see counts.
- **No camera follow:** Camera2D is static; you can pan with arrow keys
  if you bind them, or just walk and let the player drift off-screen.

These are deliberate V1 gaps. iter 290 closes the Q1 SPRINT; further
refinements happen when you score the predictions.

---

## Debrief template

Copy + fill after 1-2 playthroughs. Append to `loop/breach/REVIEW-QUEUE.md`
under #30, OR send back to the loop on next /loop fire.

```
## Q1 proof-room playtest — DATE

Lanes attempted: [HE / APCR / HEAT / AP / multiple]
Run time per lane: HE: ?s  APCR: ?s  HEAT: ?s  AP: ?s

Did you reach the goal? [yes / no / partial]

Did shells feel like route currency? [yes / sort of / no]
  Why:

Q1 claim verdict — "shells are route currency, not damage flavor":
  - believable [strong / weak / no]
  - surprising verb you noticed:

Consult-001 predictions:
  1. shell/reload legible, build chips opaque:
     [hit / partial / miss]   notes:
  2. reload bar read AFTER combat (top-left vs tank-adjacent pip):
     [hit / partial / miss]   notes:
  3. bottom-left stack ignored under pressure:
     [hit / partial / miss]   notes:

STATE → DECISION GATE (consult-001 H1 fix):
  Did visibility CHANGE your behavior? (per widget)
  - Reload bar (top-left):  [used / ignored / sometimes]   notes:
  - Reload pip (tank-adj):  [used / ignored / sometimes]   notes:
  - Shell chips:            [used / ignored / sometimes]   notes:
  - Speed meter:            [used / ignored / sometimes]   notes:
  - Active-cards ribbon:    [used / ignored / sometimes]   notes:
  - Kill-flash:             [used / ignored / sometimes]   notes:
  - Q3 recap (death):       [used / ignored / sometimes]   notes:

What surprised you (positive):

What felt wrong (the seductive-but-hollow finder):

Next direction:
```

---

## Where this slots into the loop

After you score predictions:
- CONSULT-LEDGER.md consult-001 § Scoring fills in
- STATE.consult_calibration tallies update (hits / partials / misses)
- Per CONSULT-LEDGER rules: ≥2 hits + hit_rate ≥50% over time can RAISE
  `feel_consult_cap` from 3 (uncalibrated) → 4 (calibrated)
- The loop also uses the scoring to decide next sprint scope: which of
  the 5 remaining consult-001 backlog items (H6 visibility classes, H1
  acceptance-gate strengthen, reload bar tank-adjacent dup, Stardew-delta
  pacing reframe, Q3 diagnostic recap surfacing) addresses the live gap

The brief is a forcing function. Without it, the loop would either keep
building or stall on framing-ambiguity. With it, you collapse the
predictions into evidence and the loop continues from there.
