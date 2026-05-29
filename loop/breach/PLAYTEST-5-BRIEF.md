# PLAYTEST 5 — Round 9 verdict, layered with the Phase-3 questions

Round 10 Phase 3 artifact (iter 78). One-page playtest brief for
the user, complementing the on-death prompt overlay
(`_breach_prompt_label` on the death screen).

The point of this brief: improve the QUALITY of the playtest
verdict by structuring what to watch for, without changing the
game itself. Per Consult 008's H5 ("deferral ≠ passivity"), this
is the highest-leverage pre-playtest work the loop can do.

## What we built since playtest 4 (Round 9)

Four mechanically-distinct tank archetypes, each with its own combat
loop:

- **DEFAULT** — discrete bullets (AP/HE/HEAT/APCR), move + shoot,
  the breach economy as-built since arc-4 start
- **PRISM** — stop-and-fire continuous beam (4 Hz damage, 160px
  range, line damage); movement BLOCKED while firing
- **MORTAR** — lobbed parabolic shells, AoE on impact (~96px range,
  1.5s cadence); fires over walls, no LoS needed
- **RAM** — collision damage + 18px swing cone + sprint speed; no
  projectile weapon

Plus enemy HP > 1 + HP bars; start-of-run archetype selection
(MetaProgress-gated unlocks at depth 20/40/60); mid-run event-unlock
switching via depot upgrade.

## What the loop is uncertain about (the user is the gate)

Consult 008 named the dominant risk: the archetypes are
**mechanically distinct on paper but might be experientially
homogeneous in play**. Different verbs ≠ different games — if every
archetype produces the same loop ("kill enemies, breach wall, move
up, take depot"), the playtest will report "four control schemes for
the same climb."

Phase 1 distinctness audit shows the 4 archetypes differ in 9-10 of
10 structural+derived signals (CALIBRATION WARNING: audit too easy
to pass; only a playtest can validate the experiential dimension).

## What to watch for — the four characteristic-mistake temptations

Each archetype was designed around a different temptation. Pay
attention to whether you EXPERIENCE these in play:

| Archetype | Designed temptation                                       | Diagnostic line                                                      |
|-----------|-----------------------------------------------------------|----------------------------------------------------------------------|
| **PRISM** | Overcommit — beam locks you in place; greedy DPS = death  | "I overcommitted the beam and got shot from behind"                  |
| **MORTAR**| Lazy safety / bad prediction — lob over wall but mistime  | "I misjudged the impact zone" / "the swarm moved out before it landed" |
| **RAM**   | Reckless pathing — speed makes you forget enemy fire arcs | "I rammed into a bad lane and ate two bullets closing"               |
| **DEFAULT**| Shell waste — wrong shell for the band's pressure       | "I wasted my HE before the bunker band; ran out at the wrong moment" |

If you find yourself emitting any of these regret-quotes, the
archetype's identity is landing — characteristic mistakes ARE
identities (per Consult 008's first principles).

## What to play (5 runs total, ~25-40 min)

The minimum spec — run each archetype once, plus one switching run:

1. **Run 1 — DEFAULT.** The baseline. The arc-4 breach economy as
   shipped through Round 8. Pay attention to your shell-economy
   discipline.

2. **Run 2 — PRISM.** Unlocked at MetaProgress best-depth ≥20
   (depth in the start-pick screen). Focus on: does stop-and-fire
   create real decision moments? Does the 4Hz beam feel like a
   different game or just "PRISM mode for the same game"?

3. **Run 3 — MORTAR.** Unlocked at ≥40. Focus on: do you USE the
   over-walls capability, or does it sit unused? Does the slower
   cadence (1.5s) reshape how you approach enemy clusters?

4. **Run 4 — RAM.** Unlocked at ≥60. Focus on: does collision
   damage + sprint feel viable, or do you find yourself wishing
   for a gun? When you swing, does the 18px cone reward
   positioning?

5. **Run 5 — switching.** Start as whichever archetype you most
   liked; switch to a different one at the first depot that offers
   "Switch to X." Note your reaction: did the switch feel
   meaningful, or were you indifferent?

## The three questions you'll see on death

The death screen (breach mode only) shows a one-line prompt:
> *which moment did you regret? right archetype? would switching help?*

These are the three diagnostic axes:
1. **Regret moment** — a regret-able moment IS a characteristic
   mistake. If you can't name one, the archetype is too forgiving
   (or the encounters were).
2. **Right archetype** — were you the wrong tool for the run? If
   yes, the start-pick screen needs more decision support OR the
   archetype is too narrow.
3. **Switching help** — would mid-run switching have changed the
   outcome? If yes, the SWITCH_TO_* depot picks are working as
   intended (per the iter-69 "almost like switching a weapon"
   direction).

The cleanest evidence is the SHAPE of your regret-quote:
- **"I overcommitted as Prism"** = archetypes as RUN IDENTITIES
  (start-pick is the load-bearing design).
- **"I should have switched to Ram before the swarm band"** =
  archetypes as WEAPONS (mid-run switch is the load-bearing
  design).

REVIEW-QUEUE #15 is the open design question. Your quotes settle
it.

## What we'd like to learn

In rough order:

1. **Did the archetypes feel distinct?** (Yes/No/Mixed + which
   pair felt most-similar.) — C15 anchor 5, identity-protected.
2. **Are archetypes identities or weapons?** Your regret-quote
   shape answers this — see above.
3. **Roster gaps from PRESSURES.md:** swarm enemies, snipers,
   heavier armor, suppression-pressure. Did you notice any of
   these MISSING during the runs? — Round 11 candidates.
4. **Armor-bypass asymmetry** (PRESSURES.md surfaced this): DEFAULT
   must pick HEAT/APCR for armored Heavies; PRISM/MORTAR/RAM
   bypass armor by mechanism. Did this feel right, or did it feel
   like the other three archetypes "skip the puzzle"?
5. **Distinctness audit CALIBRATION WARNING:** the structural
   audit flagged that it's too easy to pass — i.e. structurally
   the archetypes ARE distinct. Your experiential read either
   confirms the audit's blindness (structurally fine, feels same)
   or validates it (structurally distinct → experientially
   distinct).
6. **The visual concept sprites** (REVIEW-QUEUE #13) are reference
   concept art — they're not in the game yet. Which integration
   path do you want — (a) downsample + composite, (b) algorithmic
   tint+overlay via gen_tile.py, (c) defer for human pass?

## How to invoke

Write `playtest` in the conversation when ready. The loop pauses,
surfaces REVIEW-QUEUE #14 + this brief, and awaits your direction.
