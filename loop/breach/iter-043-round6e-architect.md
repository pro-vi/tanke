# Round 6e blueprint — Meta-progression (+ a loadout-lifecycle finding)

Written iter 043 (SPIKE). Compaction-safe per L2 — each follow-up iter
reads this instead of relying on context memory.

## Origin

Round 6e is the last Round-6 sub-round (roguelite feel). The user
picked meta-progression; CONSULT 003 said it must come LAST and unlock
OPTIONS, not raw power (power-creep dilutes "what will you spend").

## Finding 1 — the loadout-lifecycle bug (correctness; fix first)

The breach loadout is a SHARED Resource: BreachLevel.tscn sets
PlayerTank.loadout = ExtResource(breach_starter_loadout.tres); the
.tres has no `resource_local_to_scene`; nothing calls `.duplicate()`.
During a run, PlayerTank `_fire` -> `loadout.consume()` decrements the
reserves, and depot upgrades set `loadout.breach_dividend` etc. — all
MUTATING the shared resource. On death the player presses [R] ->
`reload_current_scene()`, which reuses the cached (mutated) resource.

**Consequence (strongly suspected): run 2+ of a session starts with
run 1's depleted reserves AND run 1's purchased upgrades.** A
correctness bug — and the entanglement that makes any loadout-touching
meta-progression design risky.

Fix: PlayerTank `_ready`, when `loadout != null`, do
`loadout = loadout.duplicate()` — a private per-run copy from the .tres
template. This also un-blocks loadout-based meta later.
Cost: ~3 harnesses (test_breach_loadout, test_breach_hud, possibly
test_breach_swap) assume `pt.loadout` IS the object they passed and
mutate it post-_ready — they must be updated to read `pt.loadout`.

## SPIKE — meta-progression options

| Opt | What | Risk | Verdict |
|-----|------|------|---------|
| A | Depot-pool widening — best_depth unlocks upgrade KINDS into the depot `_ensure_rolled` pool (fresh save: 7 core upgrades; depth 40 -> +Quick Swap; depth 80 -> +Steel Salvage) | Low — no loadout touch, no new UI, a small read in `_ensure_rolled` | **SHIP (iter 45)** |
| B | Alt starting loadouts — best_depth unlocks alternate starting shell-mixes, picked at the codex | High — entangled with Finding 1; needs a pick mechanism; breaks harnesses | Deferred (revisit after the Finding-1 fix) |
| C | Meta-perk — best_depth unlocks a depot reroll / a 4th depot choice | Med — depot-UI work; a 4th choice is mildly power-ish | Not chosen |

**Verdict: Option A.** Standard roguelite meta (unlock content by
playing — the Slay-the-Spire card-unlock pattern); genuine
options-not-power (an unlocked rule-changer adds a build path, not a
stat); no loadout entanglement; no new UI. The "subtractive" feel (a
fresh save sees fewer depot upgrades) IS the meta-progression curve —
it gives the climb a between-run purpose: get deep -> unlock the
advanced rule-changers.

## iter 44+ sequence

- **iter 44 — BUILD — loadout-lifecycle fix** (Finding 1). Confirm with
  a probe harness; PlayerTank `_ready` duplicates the loadout; update
  the ~3 affected harnesses to read `pt.loadout`.
- **iter 45 — BUILD — meta-progression Option A** (Round 6e). New
  `scripts/MetaProgress.gd` — reads best_depth from stats.cfg, exposes
  the unlocked upgrade-kind set. Depot `_ensure_rolled` consults it.
  Surface the unlock state (depot panel locked-count, or the codex).
  Adds RUBRIC C13 (meta-progression).
- **iter 46 — CONSULT + QUEUE — Round 6 close.** Fire the Round-6
  CONSULT; append REVIEW-QUEUE #7 — the loop's next user-look gate.

## RUBRIC C13 proposal (apply at iter 45)

- C13 — Meta-progression. Structural anchors: a persistent
  best-depth-driven unlock system grants OPTIONS (more build paths) —
  code-cited; a sentence-test analogue holds ("the unlock gives a new
  way to climb, not a bigger number"). Feel anchors: playtest — the
  player climbs deep partly to unlock. -> 13 criteria / 65-pt ceiling.

## Guardrails

- Meta-progression unlocks OPTIONS, never raw power (CONSULT 003 — the
  identity guardrail).
- Hash anchor `23d6a2ec3bf2821f` preserved (MetaProgress + Depot are
  off the procedural hash path; the loadout-duplicate is breach-only —
  flag-off PlayerTank has no loadout).
- test-all + test-breach green; the loadout-fix's harness updates are
  bounded + listed above.
