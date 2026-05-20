# Breach loop review queue (arc 4)

User-look pattern per L3 (carried from arc 3). Append-only by the loop;
batch-closed by the user between sessions. The loop continues running
structurally between user reviews.

Format per item:

```
#K — <topic> — <round-NNN> — <SHA> — <status: open / closed / superseded>
  Finding: <one-sentence summary>
  Affordance: <what it lets the player do>
  Risk: <seductive-but-hollow framing from CONSULT, if applicable>
```

---

#1 — Breach scaffolding (round 1) — iters 2-5 — SHA 9e0b088 — open
  Finding: Four-piece structural scaffolding for breach economy shipped:
    (a) ProceduralLevel.gd default-on `breach_mode_enabled` flag (iter 2);
    (b) BreachConfig + BreachBand schemas + 2-band sample (iter 3);
    (c) Bullet.gd shell_class with AP/HE/HEAT constants (iter 4);
    (d) Depot.gd + Depot.tscn + pause-on-entry (iter 5).
    Hash anchor `23d6a2ec3bf2821f` preserved bit-identical through all
    4 substrate writes (3 substrate-touching iters + 2 new-file iters).
    Rubric: 7/50 (C2=1, C3=1, C4=1, C9=1, C10=3).
  Affordance: lets the loop wire actual breach mechanics in round 2
    (HE-terrain-cracking, depot upgrades, depth-band-aware spawning)
    without rebuilding plumbing.
  Risk: **schema-before-mechanic**. Round 1 produced structural surfaces
    but the player can't yet *experience* breach economy. Per CONSULT §4
    iter-30 embarrassment list: "BC-like tank game with too many icons
    and not enough tactical difference between builds" — round 2 must
    avoid this trap by wiring *behavior*, not more schema. iter-6 fired
    consult 001 to ground-truth this risk read.

#4 — Round 3 + structural ceiling — iters 26-28 — SHA 18828be — open
  Finding: Round 3 closed the last reachable [STRUCTURE] anchors —
    C3/4 (shell-swap reload cost — pre-commitment under reload
    pressure) + C8/3 (depot catalog covers all 5 band pressures via
    the OVERDRIVE sprint upgrade). C5/3 (a 4th enemy role) is
    substrate-blocked — a genuine role needs an Enemy.gd behavior
    branch, which the arc-4 PROMPT does not sanction. The iter-26
    AUDIT de-bundled the remaining anchors and fixed the ceiling at
    **30/50** — the honest structural finish.
  Affordance: every harness-citable anchor is now closed; the loop has
    built everything reachable without a human.
  Risk: the remaining 20 points are [FEEL]/playtest-gated. Round 4
    (iter 29+) builds the *bridge* to the playtest — legibility work
    (depot UI, shell HUD) so a playtest can actually be meaningful —
    but the playtest itself (#3) remains the gate.

#3 — ★ PLAYTEST REQUEST (critical path) — round 2 — SHA 3d70133 — CLOSED — playtest delivered 2026-05-20 (see #5)
  Finding: Round 2 (iters 7-24) is STRUCTURALLY COMPLETE — breach mode
    is a full loop: 5-band climb, finite HE/HEAT reserves spent to
    breach, 3 depots with a 6-entry catalog (5 stock + 1 rule-changer
    "Breach Dividend"), band-aware enemy rosters, HEAT-solves-armor,
    death recaps. 28/50, 14 harnesses + 5 arc-3 targets green, hash
    anchor 23d6a2ec3bf2821f preserved through 12 substrate writes.
  BUT: **no human has played it.** Every score is [STRUCTURE]/harness-
    cited. The /meta lens (dice nat-13) named this PARITY DRIFT —
    harness-green has been treated as "the game works". CONSULT 001 +
    002 both flagged it. ~14 of the 22 remaining rubric points are
    [FEEL]/playtest-gated BY DESIGN — the loop cannot honestly close
    past ~37/50 without you at the controls.
  The ask (CONSULT 002 #3 — the 5-person smoke test): play
    `scenes/BreachLevel.tscn` (or `make run` → breach mode). The ONE
    question that matters: **do you describe your run as route economy
    ("I spent my HE opening the brick maze, entered the bunker band
    HEAT-starved") rather than tank combat ("I shot things")?**
    Secondary: do the depots feel like earned breath beats? does the
    death recap tell you why you fell?
  Affordance: a playtest unlocks the [FEEL] anchors (C1/4-5, C2/4-5,
    C5/4-5, C6/4-5, C7/4-5, C8/4-5, C9/3-5) — the half of the rubric
    that answers "is this actually breach economy, its own thing".
  Risk: without it, the loop grinds the last ~8-10 structural points
    (C3/4 swap-cost, C4/4 shell-mix harness, C5/3 4th role, C8/3 band
    coverage) to ~37/50 and then genuinely ceiling-pauses — exactly
    arc-2's diminishing-returns tail. To trigger: write `playtest`.

#2 — Round 2 atomic verb (iter 7+8) — iters 7-8 — open
  Finding: CONSULT 001 returned (tab-timeout but response landed —
    arc-4 documented behavior reproduced). It named the missing piece:
    "no player has yet sacrificed one resource to alter one route. That
    is the atomic verb." Iter 7 shipped HE radius brick-blast (3 stub
    bricks destroyed by one HE shot vs 0 for AP). Iter 8 shipped
    Loadout.gd + PlayerTank.gd shell cycle (KEY_TAB) + finite HE/HEAT
    reserves consumed on fire. Now the player CAN sacrifice a resource
    (HE reserve) to alter a route (open brick lane). C1=1, C9=2; total
    10/50.
  Affordance: player has a shell cycle + a finite breach budget;
    firing HE is now a commitment, not a free option.
  Risk: not yet placed in a BreachLevel scene; harness-tested only.
    The lived breach decision doesn't happen yet — no band yet places
    bricks in a choke that *requires* HE to breach. Round 2's next
    iter (iter 9+) wires the choke band + the 2-choice depot.

#5 — Playtest verdict + Round 5 launch — round 5 — iter 33 — open (informational)
  Finding: User playtested breach mode 2026-05-20 (closes #3). Verdict —
    structurally complete but ILLEGIBLE: "the game feels the same,"
    shell roles unclear ("when do I use HE vs HEAT vs AP?"), no shell UI,
    no tutorial, "it doesn't feel like a roguelite." Logged as F003
    (harness-green ≠ legible — the parity-drift /meta, confirmed). User
    overrode the 3-shell constraint: APCR is the sanctioned 4th shell.
  Affordance: re-opens the loop with real, honest work. Round 5
    (iters 34-37) = shell legibility — APCR + steel pressure, shell UI
    panel + distinct in-flight visuals, shell codex/tutorial. Round 6+ =
    the roguelite-feel program the user asked for (run-to-run variety,
    build divergence, stakes & escalation, meta-progression). Blueprint:
    `loop/breach/iter-033-round5-architect.md`.
  Risk: Round 5 fixes legibility — it does NOT by itself make the game
    feel roguelite. That is the Round 6+ program (finding 5). Watch for
    the loop declaring breach mode "fixed" after Round 5 while finding 5
    is still open. The next user playtest gate is after Round 6.

#6 — Round 5 close: shell legibility — round 5 — iter 37 — open (informational)
  Finding: Round 5 (iters 34-37) made the 4-shell breach economy
    legible — APCR (the 4th shell, breaches steel) + a colour-coded
    4-slot shell panel + a run-start shell codex. 30/50 (Δ 0 across the
    round — legibility is BUILD-QUALITY bridge work, like Round 4).
    19/19 breach harnesses + 5 arc-3 green; hash anchor preserved
    through 6 substrate writes (iters 34-36).
  Affordance: the shell economy is now visible, differentiated, and
    explained — a playtest can now meaningfully judge whether it PLAYS
    as breach economy (Round 5 removed the legibility excuse).
  Risk: CONSULT 003 (Q3) — Round 5 polished the *presentation* of the
    economy without verifying the economy is *deep*. Legibility is not
    scarcity. Round 6 must first confirm/deepen the economy's
    decision-density, then build roguelite feel. The next playtest must
    ask "did you ever agonise over a shell?" — not "is it legible?".

#7 — ★ PLAYTEST REQUEST — Rounds 5-6 complete — iter 46 — OPEN, needs you
  Finding: Rounds 5-6 (iters 34-46) are STRUCTURALLY COMPLETE — they
    built every one of the five iter-33 playtest findings + the full
    roguelite-feel package:
      • shell legibility — APCR (4th shell, breaches steel), a 4-slot
        shell panel, a run-start shell codex (Round 5);
      • run-to-run variety — band-order shuffle + depot-offer
        randomisation (Round 6a/6b);
      • build divergence — 4 depot rule-changers (Round 6c);
      • stakes & escalation — band-arrival banners + a live best-depth
        chase (Round 6d);
      • meta-progression — depth-gated depot-pool unlocks (Round 6e).
    Plus F004 fixed (the restart loop was silently broken — runs leaked
    state). 39/65, 24 breach harnesses + 5 arc-3 green, hash anchor
    23d6a2ec3bf2821f preserved through 26 substrate writes.
  BUT: no human has played any of it. Every score is [STRUCTURE] /
    harness-cited. ~26 of the 65 rubric points are the [FEEL] tier —
    playtest-locked by design (CONSULT 004).
  The ask: play `scenes/BreachLevel.tscn` (or `make run` → breach).
    The THREE questions that matter (CONSULT 004):
      1. Did you ever AGONISE over a shell — was "spend it or detour"
         ever a real dilemma? (the core economy)
      2. Did a run's band-shuffle change your plan — did runs feel
         different? (run variety)
      3. Did you climb deeper partly to unlock something? (meta)
    Secondary: do the shells read as 4 distinct tools now? do depots
    feel like real build choices? does the single life feel like it
    matters?
  Affordance: a playtest unlocks the [FEEL] tier — C1/4-5, C3/5,
    C9/3-5, C11/4-5, C12/4-5, C13/4-5 — the half of the rubric that
    answers "is this actually a breach roguelite, its own thing."
  Risk: CONSULT 004 Q3 — the loop has built 13 iters of structure
    since the last human signal; if the core economy doesn't bite, the
    roguelite scaffolding decorates a shallow loop. Only a playtest
    tells. To trigger: write `playtest`.

