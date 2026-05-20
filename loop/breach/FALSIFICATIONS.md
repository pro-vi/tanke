# Breach loop falsifications (arc 4)

F-numbered. One block per falsified prediction. Codifies the lesson so the
loop doesn't repeat the failure mode. **≥3 F's in one playtest = scope too
broad** (arc-2 carry).

Format:

```
## F0NN — <one-line title> — iter NNN
- Predicted: <claim from PRE-MORTEMS>
- Observed: <what actually happened>
- Root cause: <structural / feel / mixed / instrumentation>
- Lesson: <PROMPT-level invariant if codifiable, else session-local cite>
- Codified where: <PROMPT.md anti-pattern row | RUBRIC anchor reword | this file only>
```

---

## F001 — Breach band terrain density eyeballed, not reachability-verified — iter 11

- Predicted: iter-11 PRE-MORTEM claimed "keep band configs gentle
  (empty_weight ≥ 0.12)" would keep the breach bands passable without
  forcing the player to breach.
- Observed: `test_breach_harness.gd` reachability oracle reported
  `playable: false` (rows_climbed 5, MIN 10) for tutorial_choke at its
  iter-3 values (empty 0.20 / brick 0.55 / merge 0.45). First retune
  (empty 0.34 / brick 0.40 / merge 0.34) still failed 2 of 7 seeds
  (rows_climbed 7). Only empty 0.46 / brick 0.32 / merge 0.30 passed
  7 of 7 seeds.
- Root cause: STRUCTURE. High `brick_weight` × high `merge_probability`
  compound — bigger Eller sets land brick more often, producing large
  contiguous impassable walls. The reachability oracle (correctly, per
  PROMPT §REACHABILITY FLOOR) treats brick as a wall: the player must
  have a clear route without being *forced* to spend HE. "Gentle
  empty_weight" alone is not a sufficient heuristic — `merge_probability`
  is a co-factor and was ignored in the pre-mortem.
- Lesson: every breach band LevelConfig must be **multi-seed
  reachability-verified** before C4 is scored. Single-seed pass is not
  enough (F001 itself: seed 42 passed at a config where seeds 1+777
  failed). The harness must run ≥5 seeds.
- Codified where: this file + iter-12 requirement — the deep-climb
  harness must reachability-verify bands 2 (brick_maze) and 3
  (bunker_zone), which iter-11's 30-frame harness cannot reach. Their
  configs were proactively softened in iter 11 (applying the band-1
  lesson) but remain UNVERIFIED until iter 12.
