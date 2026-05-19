# Breach Loop (arc 4)

Fourth arc of the tanke autonomous-loop research project. Builds on arcs 1
(engine), 2 (gameplay), 3 (originals). Identity anchor: **breach economy**.

## Fire command

```
/loop Read ./loop/breach/PROMPT.md and follow its instructions exactly.
```

## What it does

1. Reads 4 prior-arc retros + the design CONSULT (preloop, ~5 min)
2. Verifies cross-arc substrate intact (procedural + OG modes + hash anchor)
3. Iter 0 bootstrap (substrate baseline, no scoring)
4. Iter 1 forced DECISION + SPIKE (mode integration path; blueprint)
5. Iters 2+ BUILD / CAPABILITY / AUDIT cycle per RUBRIC's weakest axis
6. Adaptive CONSULT (~every 10 iters) on identity questions
7. REVIEW-QUEUE pattern for user-look (NOT 3-iter halt rule)

## How to halt

- Write "halt" or "stop" in conversation
- Update `STATE.md` with `next_action: HALT`
- Loop self-halts on hard substrate violation or hash anchor break
- Loop pauses (ceiling-paused, NOT halt) when all auto-citable anchors maxed

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

## Overnight expectation

Kicked off at midnight, ~8h of self-paced loop:
- Iter 0: bootstrap (~3 min)
- Iter 1: DECISION + SPIKE (~10 min)
- Iters 2-15: BUILD / CAPABILITY mix (~6 min each)
- Iter 10: CONSULT (adaptive)
- Iters 15-20: first PLAYTEST request appended to REVIEW-QUEUE
- Halt OR ceiling-paused OR user signal in morning

Morning checkin: read `STATE.md` + `LEDGER.md` tail + `REVIEW-QUEUE.md`.

## Loop type

Hybrid: /greenfield-loop (rubric is constructed + revisable; identity is
discovered) within the /frontier three-arc chain (rich substrate from arcs
1-3; harness exists; cross-arc invariants honored).
