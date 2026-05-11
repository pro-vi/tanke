# tanke — Lightweight Playtest Template

Designed iter 23 per /meta nat-13 diagnosis: the loop needs more frequent playtest evidence to prevent parity drift. The iter-14 10-question prompt produced 4 answers; the iter-17 5-question prompt produced ~3 short answers. This 2-question format targets <30 seconds of user time so playtest cadence can rise.

## The format

```
🎮 Quick playtest — F5, play ~30-60 seconds, two questions:

1. THE LOAD-BEARING PREDICTION: <one specific reference-language
   prediction per Pro v2 H4>. Did this happen?
2. ANYTHING OFF? Anything weird, surprising, or broken — one line.
```

## Why two questions

Single question is too narrow — user can dodge ("it's fine") without committing. Three+ questions is the iter-14 trap (user picks favorites, leaves gaps).

Two questions force:
- A FALSIFIABLE commitment on the iter's planned-feature claim
- A free-form bug-discovery slot (catches surprises)

## Example slot 1 prompts (load-bearing predictions)

Per Pro Consult 004 H5: "user will stop to clear enemies more often than they push upward through danger." Variants:

- "Did you find yourself stopping to clear enemies, or were you mostly pushing upward through danger?"
- "When the enemy-type-X spawned, did you change behavior? How?"
- "Did the depth band transitions feel different from each other, or like 'more enemies higher up'?"

## When to use

- Default playtest format starting iter 33+
- Replaces the 5-10 question format used iter 14/17
- Increases playtest cadence target from 1-per-15 to 1-per-5 once user signals comfort

## Anti-format

What NOT to ask:
- Checklists ("1. bullets work? 2. brick destroys? 3. ...") — user picks favorites
- Generic ("how does it feel?") — invites approval without falsifiability
- Multi-part single questions ("did the run feel like an ascent and were enemies fair?") — gets answered as one

## Origin

Iter 23 process refactor after `/meta` analysis at iter 22 named loop's parity drift. /meta recommendation: "design a 2-question playtest the user can complete in 30 seconds, so playtest cadence can rise from 1-per-15-iters to 1-per-5-iters without imposing burden."

This template is the productization.
