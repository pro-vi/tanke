# Round 7 blueprint — the iter-46 playtest round

Written iter 047. Compaction-safe per L2 — each Round-7 iter reads this.

## Origin

The user playtested after Round 6 (the iter-46 playtest gate) and gave
5 findings. Round 7 fixes them. Two were clarified via AskUserQuestion.

## The 5 findings -> build pieces

1. **"Shells are too little" -> too few to manage.** The starter
   reserves (HE 2 / HEAT 1 / APCR 2) run dry before the economy becomes
   something to manage. -> 7a: retune reserves + caps UP — a working
   economy to spend, not "two shots and done."

2. **"No idea what band shuffle means."** The per-run band-order
   shuffle (iter 39) is invisible within a run — the band banner (iter
   42) names each band on crossing, but nothing shows the run is a
   *shuffled sequence*. -> 7c: surface the run's full route up front
   ("this run: maze -> bunker -> killbox").

3. **"What can be unlocked?"** The meta-progression (iter 45) gates
   Quick Swap @40 / Steel Salvage @80; a codex line states it but does
   not land. -> 7d: make the unlock ladder legible; add more unlock
   tiers (2 is thin).

4. **APCR redesign (user-confirmed).** APCR should PENETRATE steel —
   drill through it, breaking ONE steel block per block it passes (like
   AP breaks one brick), NO radius cluster; the bullet continues until
   its lifetime ends. -> 7b: replace `_apply_apcr_breach` (the iter-34
   radius breach) with a penetrate-drill; retune STEEL_SALVAGE.

5. **"HE should have an explosion effect."** HE has a radius blast
   *mechanically* (`_apply_he_blast`) but no *visual*. -> 7e: a visible
   explosion effect on HE detonation.

F003 recurs (noted, not re-numbered): findings 2-3 show iters 42/45
built legibility surfaces that are harness-verified to EXIST but do not
COMMUNICATE. A legibility feature is done when a playtest confirms it
lands — Round 7's legibility pieces must be re-checked by the next
playtest.

## Sub-round sequence

- **7a — shell economy retune.** Bump HE/HEAT/APCR starter reserves +
  caps (configs/breach_starter_loadout.tres + Loadout defaults); the
  economy should be MANAGED, not starved. Combines with 7b — more APCR
  + 1-block drilling = a steel lane is a real APCR investment.
- **7b — APCR penetrate-steel.** Bullet: APCR hits steel -> break that
  one SteelBlock, do NOT queue_free (penetrate), continue. Drills a
  1-wide tunnel bounded by the bullet lifetime. Replaces the radius
  `_apply_apcr_breach`. STEEL_SALVAGE retunes to count drilled blocks.
  Hash-anchor verify (Bullet substrate).
- **7c — run-route legibility.** Surface the shuffled band sequence for
  the run (a codex route line and/or a HUD route strip) so the player
  SEES the run is a unique order.
- **7d — meta-progression legibility.** Make the unlock ladder legible
  (what is unlocked / what is next / at what depth); add 1-2 more
  unlock tiers so meta-progression is not just 2 entries.
- **7e — HE explosion visual.** A visible blast on HE detonation —
  algorithmic (ColorRect / tween burst, the proven `_spawn_impact_spark`
  pattern scaled up; no MLX-SD). Harness the node spawn; the look is a
  noted visual-verification caveat.
- **7-close — CONSULT + QUEUE.**

## Guardrails

- Hash anchor 23d6a2ec3bf2821f preserved on every substrate write.
- 7b changes APCR (Bullet substrate) — the flag-off codepath stays
  bit-identical (APCR never fires on the procedural baseline).
- Round 7 is a fix-round — most iters lift no [STRUCTURE] integer (the
  structural tiers are maxed); the value is [FEEL]-gated for the NEXT
  playtest. Honest Δ 0 is expected; that is not drift.
- The next playtest must re-check that findings 1-5 actually landed.
