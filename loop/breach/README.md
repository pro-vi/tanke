# Breach Loop (arc 4)

Fourth arc of the tanke autonomous-loop research project. Builds on arcs 1
(engine), 2 (gameplay), 3 (originals). Identity anchor: **breach economy**.

## Fire command

```
/loop Read ./loop/breach/PROMPT.md and follow its instructions exactly.
```

## What it does

Explores roguelite game mechanics on the BC base. Non-stop. Each
exploration round investigates one mechanic surface (ammo / depot /
chassis / enemy role / terrain affordance / death recap / asset gen /
procedural-OG handshake / …) and ships its finding into
`REVIEW-QUEUE.md` for you to look at between sessions.

Macro cadence:
**SPIKE → DECISION → BUILD × N → CONSULT → QUEUE → bootstrap-next**

The loop self-diagnoses each iter — no pre-allocated trajectory. When a
round closes, it immediately starts the next round against the
weakest-axis surface remaining (the rubric measures depth on the 10
surfaces it names, but the design space is open-ended; the loop extends
the rubric or carries open questions to QUEUE).

## How to pause for playtest

- Write `playtest` in the conversation — loop pauses, surfaces
  `REVIEW-QUEUE.md`, awaits your direction
- `halt` or `stop` also work (treated identically)

## When the loop self-halts (correctness only)

- Cross-arc hash anchor `23d6a2ec…` broken on procedural baseline
- `make test-all` regression (arc-3 work broken)
- Reachability fails on a band and isn't fixed same-iter
- Hard substrate (layers 1/2/3) violated without sanctioned default-on gating

The loop does **NOT** self-halt on: score milestones, empty rubric-lift,
F-numbered falsifications, or "ran out of work" (the design space is
open-ended).

## Where to look for results

- `loop/breach/STATE.md` — current phase, iter, next action
- `loop/breach/LEDGER.md` — append-only iter history with scores
- `loop/breach/REVIEW-QUEUE.md` — your queue of items to review
- `loop/breach/PRE-MORTEMS.md` — what the loop expected to fail at each iter
- `loop/breach/FALSIFICATIONS.md` — what actually failed + lessons
- `loop/breach/creative-consults.md` — frontier-model design CONSULT outputs

## Identity anchor (the spine)

> Battle City as a vertical breach roguelite: a single-life tank climbs
> through fortified depth bands by managing shells, terrain destruction,
> and depot-based upgrades.

> What are you willing to spend to open the next vertical lane?

## Sentence test (the gate)

Every upgrade must pass:
> "This upgrade helps me climb through ___ by changing how I use ___."

Bad upgrade fails: "by making me stronger" / "by doing more damage."

## What this arc deliberately does NOT do

- MLX-SD asset generation (P1 NO-GO — phantom dependency; algorithmic gen only)
- Combat upgrade modals (CONSULT constraint 1)
- Passive stat soup as primary RPG layer (CONSULT §4 anti-pattern)
- Modify arc-1/2/3 substrate without default-on gating + hash verification
- Add new gameplay siblings without iter-1 DECISION blueprint
- More than 3 shell classes initially (CONSULT constraint 2)
- AWAIT on design / pacing / content decisions

## Morning checkin

```
cat loop/breach/STATE.md
tail -200 loop/breach/LEDGER.md
cat loop/breach/REVIEW-QUEUE.md
```

Look at the QUEUE — each entry is a round-closure note describing what
the loop shipped and what's seductive-but-hollow about it. When you find
one (or several) worth playing, write `playtest`.

## Loop type

Hybrid: /greenfield-loop (rubric is constructed + revisable; identity is
discovered) within the /frontier three-arc chain (rich substrate from arcs
1-3; harness exists; cross-arc invariants honored).
