# Round 8 blueprint — the roguelite-progression overhaul

Written iter 055. Compaction-safe per L2 — each Round-8 iter reads this.

## Origin

The user playtested after Round 7 (the iter-53 close / REVIEW-QUEUE #9
gate) and delivered a direction-changing verdict:

- **"still dont understand what each phases do"** — the 5 depth bands
  still do not read, even with the iter-50 route strip. Finding 2/3 has
  now recurred a THIRD time — exactly what CONSULT 005 Q3 predicted.
- **"does enemy drop ammo?"** — no; the user wants enemies to drop ammo.
- **"where is the roguelite element like level ups?"** — the user does
  not perceive the breach economy as roguelite progression. They want
  level-ups.

Via AskUserQuestion the user chose, with override authority (PROMPT
§USER-LOOK PROTOCOL; STATE §Arc-4 amendments):

- **Progression: BOTH** — XP level-ups (stat growth) during play AND a
  pick-1-of-3 upgrade card after every phase.
- **Enemy ammo drops: YES** — and "make shields longer or something."

## The override — what it changes

This is a sanctioned override of the arc-4 ANCHOR SENTENCE ("the tank
is not becoming numerically stronger; it is becoming better at buying
passage"). Round 8 adds a conventional roguelite power curve ON TOP of
the breach economy. The breach economy is NOT removed — shells stay
finite and are still spent to breach — but it is no longer the SOLE
progression.

- CONSULT constraint 7 ("RPG progression is mostly verbs, not passive
  stats") is RELAXED for Round 8 by the user's explicit "XP + stats"
  pick.
- CONSULT constraint 1 ("no upgrade choices during active combat")
  STILL HOLDS: XP level-ups grant their boost AUTOMATICALLY (no
  mid-combat modal); the CHOICE happens only at the between-phase card
  screen (a paused safe gate).

The honest meta-read (carry into the 8-close CONSULT): after 7 rounds
the user does not perceive the core concept. The "breach economy" bet
has not landed for this player. Round 8 bends the design to the player
— it gives them the roguelite they are asking for.

## Sub-round sequence

- **8a — XP + level-up core.** PlayerTank earns XP (enemy kills +
  depth climbed); at thresholds it levels up; each level-up grants an
  AUTOMATIC stat boost, rotated across a small legible set (max HP /
  reload speed / shell capacity). A HUD XP bar + LEVEL readout — the
  visible progression beat the user is missing. Breach-mode-only (gated
  on loadout != null); an arc-2/3 PlayerTank builds none. Substrate:
  PlayerTank.gd (sanctioned).
- **8b — Per-phase upgrade-card pick.** A pick-1-of-3 upgrade screen at
  every band boundary (5 bands → ~4-5 picks, up from 3 depots) — the
  loud Hades / Slay-the-Spire reward beat. Builds on the existing Depot
  pick-1-of-3 + UI. 8b DECISION: extend depot placement to one per
  boundary, vs a band-clear reward screen hung off breach_band_changed.
  Either way it PAUSES (constraint 1). A "BAND CLEARED: <name>" header
  makes each phase a named milestone — this is also the real fix for
  the phases-don't-read finding (a phase you are rewarded for clearing
  is a phase you remember). Substrate: Depot.gd (arc-4-owned),
  ProceduralLevel.gd depot placement (sanctioned) if needed.
- **8c — Enemy ammo drops.** On enemy death, spawn an ammo pickup
  (HE/HEAT/APCR shell); the player collects it mid-combat → loadout
  reserve += . Resupply is no longer depot-only. MUST hook via
  Spawner.gd's existing enemy-death path (sanctioned) — NOT Enemy.gd
  (unsanctioned substrate; halt-and-investigate if 8c needs it). New
  arc-4 AmmoPickup script/scene; reuse the arc-2 pickup pattern
  (PlayerTank.heal / apply_shield / _show_pickup_toast).
- **8d — Defensive pickups / longer shields.** Bump apply_shield
  duration; optionally make shields a drop (depot and/or enemy). Small
  sub-round. Substrate: PlayerTank.gd (apply_shield — sanctioned).
- **8-close — CONSULT + QUEUE.** CONSULT 006: did the roguelite
  overhaul make it FEEL like a roguelite? Is it ONE game or two
  bolted-together progression systems? + the rubric question.

## Rubric

Round 8 builds an in-run progression surface (XP / levels) the 13-crit
rubric does not name. Per PROMPT §RUBRIC IS MEASUREMENT, extend
RUBRIC.md when the surface lands — likely +C14 "in-run progression"
when 8a/8b close (the iter-39 incremental pattern: a criterion is added
when its sub-round opens). The deeper question — whether the rubric's
"breach economy" framing still fits after the override — is an 8-close
CONSULT item, not a mid-round scramble.

## Guardrails

- Hash anchor 23d6a2ec3bf2821f preserved on every substrate write —
  all Round-8 systems gate on breach mode; the AP procedural baseline
  never triggers XP / drops / picks.
- Constraint 1 holds: no upgrade choice during combat. Level-ups are
  automatic; picks happen at paused safe gates.
- 8c hooks enemy death via Spawner.gd, not Enemy.gd.
- The breach economy is KEPT, not replaced — shells stay finite and
  spent. Round 8 adds a power curve; it does not delete the old one.
- Each sub-round: hash verify + `make test-all` + `make test-breach`
  green; a harness per BUILD.
- The next playtest re-checks the plain question: does it feel like a
  roguelite now?
