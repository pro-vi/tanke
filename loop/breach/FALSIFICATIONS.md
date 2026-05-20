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

## F004 — breach loadout leaked across runs (shared Resource) — iter 43-44

- Predicted: the arc-4 loadout work (iter 8+) treated PlayerTank.loadout
  as per-run state — every run starts from breach_starter_loadout.tres.
  No iter verified that assumption.
- Observed: the iter-43 SPIKE found breach_starter_loadout.tres is a
  SHARED Resource (baked into BreachLevel.tscn as an ExtResource; no
  `resource_local_to_scene`; never `.duplicate()`d). consume() + depot
  apply_upgrade mutate it in place. Godot's resource cache reuses the
  instance — so after [R]-restart (reload_current_scene) run 2+ starts
  with run 1's depleted reserves AND run 1's purchased upgrades. The
  iter-44 harness confirmed load() returns the cached instance.
- Root cause: STRUCTURE — a Resource set as a scene @export is shared
  across instantiations + survives scene reload via the resource cache;
  mutating it at runtime makes it de-facto global state. The same class
  of bug as F002 (a shared data table mutated without scoping the
  effect).
- Why no harness caught it: every breach harness instantiates ONE
  PlayerTank and never simulates a second run / scene reload. The bug
  only manifests across runs — a dimension no harness exercised.
- Fixed (iter 44): PlayerTank `_ready` does `loadout = loadout.duplicate()`
  when loadout != null — each run gets a private copy; the .tres
  template is never mutated. test_breach_loadout Test 6 verifies it.
- Lesson: a Resource baked into a scene as an @export and mutated at
  runtime is shared + reload-persistent — duplicate() it at the
  consuming node's _ready to get per-run state. Codified: this file.
  (breach_config has the same shape but is already duplicated by the
  iter-39 band shuffle; other configs are read-only.)

## F003 — harness-green breach mode did not READ as breach economy — iter 33

- Predicted: 32 iters of [STRUCTURE]-cited anchors (4-wait-3 shells with
  distinct behavior, swap cost, depots, bands, recaps) were treated as
  evidence that breach mode WORKS as breach economy. The /meta (dice
  nat-13) named the risk — "parity drift" — but the loop still scored
  30/50, paused at iter 32, and implicitly bet the structure would read.
- Observed: user playtest 2026-05-20 (the REVIEW-QUEUE #3 gate). Verdict:
  "the game feels the same"; "I don't understand when I should use HE vs
  HEAT vs AP"; "it just doesn't feel like a roguelite." No shell UI, no
  tutorial, shell roles illegible. The structure is all there in code —
  and none of it reaches the player.
- Root cause: FEEL — specifically a LEGIBILITY failure. Every mechanic
  was built and harness-verified; none was made visible, explained, or
  differentiated sharply enough to be felt. A harness can verify "HE
  destroys 4 bricks"; it cannot verify "the player knows HE is the wall
  shell."
- Why no harness caught it: by construction. Harnesses test code paths;
  legibility is a property of the screen plus the player's mental model.
  This is the parity-drift /meta made concrete — the loop's test model
  (harness-green) did not match the real condition (a human reading the
  screen).
- Lesson: a mechanic is not done when its harness is green — it is done
  when it is VISIBLE, EXPLAINED, and DIFFERENTIATED enough to change a
  decision. Round 5 (iters 34-37) is the legibility round: shell UI,
  distinct visuals, shell codex/tutorial. Every future round carries a
  legibility check alongside the harness check.
- Codified where: this file + STATE.md (Round 5 mandate + §Arc-4
  amendments) + `iter-033-round5-architect.md`. Candidate PROMPT
  anti-pattern row — "harness-green cited as playtest-equivalent" — to be
  added if the pattern recurs after Round 5.
- Single F (not ≥3) — no "scope too broad" trigger. It is one root cause:
  legibility was never built.

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
