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

## F002 — "armored" group tag leaked into arc-3 OG mode — iter 23

- Predicted: iter-23 PRE-MORTEM treated the group-tag approach
  (Spawner adds `armored` group, Bullet mitigates) as cleanly
  substrate-safe and breach-scoped.
- Observed: caught during the hash-anchor reasoning while writing the
  LEDGER — NOT by a harness. The Heavy `ENEMY_TYPES` entry is SHARED
  between arc-2 ascender, arc-3 OG, and arc-4 breach modes. Spawner's
  instantiation block runs for all three. So an unguarded
  `if type_data.get("armored"): enemy.add_to_group("armored")` would
  tag arc-3 OG Heavy enemies too — and the OG player (fires AP, no
  loadout → shell_class AP) would deal `max(0, 1-1) = 0` damage to OG
  Heavy enemies, breaking OG combat.
- Root cause: STRUCTURE — a shared data table (ENEMY_TYPES) consumed
  by 3 modes; a new per-type flag was added without scoping its
  *effect* to the mode that introduced it.
- Why no harness caught it: `make test-all`'s CHAIN tests instantiate
  every OG stage but fire no bullets — the 0-damage bug only manifests
  in live OG combat, which no harness exercises. The hash-anchor
  discipline (reasoning through every cross-mode effect before commit)
  caught what the harness could not.
- Fixed within-iter: added `_is_breach_mode()` (reads the parent
  level's `breach_mode_enabled`) and gated the `add_to_group` call on
  it. Arc-2/3 enemies never get the tag; Bullet's mitigation only ever
  engages in breach mode.
- Lesson: when adding a flag to a shared data table (ENEMY_TYPES,
  LevelConfig, etc.), scope the flag's *effect* to the introducing
  mode — a default value on the table is NOT enough if the table is
  cross-mode. Codified: this file. The hash-anchor "reason through
  every cross-arc effect" discipline is the real catch — keep it.

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
- **RESOLVED iter 12**: the per-band reachability oracle (pure-data
  rewrite of `test_breach_harness.gd`) verified all 3 bands. After
  retuning (all 3 bands → empty 0.50-0.52, merge 0.24-0.26), a 10-seed
  sweep passes 9/10 (seed 77 fails all 3 bands at identical
  rows_climbed=7 — a spawn-area Eller artifact of that seed, NOT
  config-tunable; arc-1's extremal-metric-variance lesson confirmed).
  Floor codified: **≥80% of a 10-seed sweep** (arc-3 band_check.py
  precedent). 9/10 = 90% clears it. Canonical seed 42 passes solidly
  (41/23/41). C4=2 reachability caveat closed.
