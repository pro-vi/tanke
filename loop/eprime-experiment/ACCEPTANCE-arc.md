# ACCEPTANCE — arc-harness-v0.2 (competent bot on the REAL procedural arc)

Additive arc lane beside the frozen Q1 `bot-harness`. The arc harness is an
**autonomous-playtest instrument**: it drives a deterministic composite bot up the
real `BreachLevel` procedural climb and emits per-band telemetry. The Q1 harness
(`BotRegistry`, the 7 single-verb bots, `bot_runner.gd`, `TelemetryRecorder/Schema`,
`make bot-harness`, AC-001..007) is left **bit-identical**; `CompetentBot` is
resolved by the arc runner directly and is **never** in `BotRegistry`.

## Acceptance criteria

| AC | Claim | Verifier (sentinel) |
|----|-------|---------------------|
| **AC-A1** | The composite `CompetentBot` loads as a `BotPolicy`, returns a VALID `BotAction` for every observation (teeth: null/garbage caught), and exhibits each verb — climb / engage (HEAT vs Heavy) / breach brick (AP/HE) / breach steel (APCR when boxed) / don't-fire-at-water / dodge / depot-steer. | `make check-competent-bot` → `COMPETENT_OK` |
| **AC-A2** | The arc telemetry contract (v0.2-arc, strict v0.1 superset): a good fixture validates, a bad one is rejected (teeth); the `ArcTelemetryRecorder` produces a conforming record from breach signals (band segments, depot picks, victory). | `make check-arc-telemetry-schema` → `ARC_TELEMETRY_OK 2/2`; `make check-arc-telemetry-recorder` → `ARC_RECORDER_OK` |
| **AC-A3** | `competent` decisively out-climbs the single-verb baseline. Calibrated to DEMONSTRATED capability; the honest depth distribution is recorded. Teeth: `objective-rush` through the same oracle FAILS the competent floor. | `make check-arc-climb` → `ARC_CLIMB_OK depth=13 endgame=0/12 baseline=0` |
| **AC-A4** | The arc batch integration proof: the arc roster × 12-seed bank, each run emitting a schema-conforming v0.2-arc JSON, no crash; loud on unknown/empty bot. | `make check-arc-runs` → `ARC_RUNS_OK N/N` |

**Composite final-verify:** `make arc-harness` → `ARC_HARNESS_OK`, in one repo
state alongside the Q1 regression guards: `make bot-harness` → `BOT_HARNESS_OK
84/84`, `make test-all`, `make check-hash-anchor` → `HASH_OK`.

**Verified (single clean one-state run, all green):** `ARC_HARNESS_OK` (with
`COMPETENT_OK`, `ARC_TELEMETRY_OK 2/2`, `ARC_RECORDER_OK`, `ARC_CLIMB_OK depth=13
endgame=0/12 baseline=0`, `ARC_RUNS_OK 96/96` victory 0 / death 81 / timeout 15) +
`BOT_HARNESS_OK 84/84` + test-all (loader, CHAIN_25/35, titlescreen) + `HASH_OK`.
No `No rule` / `SCRIPT ERROR`. NOTE: `check-arc-climb` measures its own seed set
(median 13); the arc batch measures the canonical seed-bank seeds (median 6, max
15) — both deterministic, both far above the single-verb baseline (0).

## The acceptance bar — honest capability (the product fork)

The plan framed U8 as (a) endgame-victory or (b) honest capability-acceptance. The
direction was "push hard for endgame." After substantial iteration the bot does
**NOT** reach the endgame band — it does not even clear band 0 (`tutorial_choke`,
depth 0–30): it reaches **mid-band-0, median depth 13** (range 0–15), consistently,
where every single-verb bot stalls at 0. Per "truthfulness above all," the bar is
**(b): honest capability-acceptance** — the deliverable is a faithful, deterministic
playtest instrument whose composite bot decisively out-climbs the single-verb
baselines and localises where the climb stalls. Victory is asserted only when
achieved (`REQUIRE_ENDGAME = 0`; raise the floor — never lower it — when a
controller climbs deeper).

## Demonstrated capability (FileAccess-measured, deterministic)

12 seed-bank seeds, committed baseline bot + the arc_run_helper determinism
re-seed; two batches agree:

- **competent median max_depth = 13**, distribution
  `{0,1,4,5,5,12,14,14,15,15,15,15}`, **all in `tutorial_choke` (band 0)**.
  Single-verb `objective-rush` = 0 (an enemy blocks its lane; it never breaches).
- Death causes are `melee`/`projectile`/`suicide` from the enemy swarm (plus a
  couple of `timeout` survivors) — i.e. the bot is KILLED, it does not get lost.
- Per-band telemetry (`band_segments`, `depot_picks`, `bands_reached`,
  `max_depth`, `reached_endgame`) is emitted and schema-conforming.

## What this build contains — and a measured negative result

- **Determinism fix (`arc_run_helper.gd`) — KEPT.** Re-seed the global RNG AFTER
  the setup frames settle so leftover-node RNG consumption no longer offsets a
  run's enemy-fire stagger by batch order. Same seed run 3× in one process: was
  15/10/10 (a leak), now stable. This makes each seed's result order-independent —
  a real correctness improvement to the instrument; it also tightened the
  distribution (median 12 → 13).
- **The U10 motion-primitive rewrite was TRIED and REVERTED.** The plan's premise
  was that a footprint-aligned motion controller would lift the depth ceiling. Two
  variants were built and FileAccess-measured: a footprint-lane BFS (median 8.5)
  and a brick-cost-weighted Dijkstra (median 2) — **both worse than the committed
  baseline (median 13)**. The ceiling is not motion control; `tutorial_choke` has
  no long clear vertical channels, so cost-weighting away from brick made the tank
  wander sideways and get swarmed. Reverted to the committed baseline (no
  regression). Recorded so the next session doesn't re-try motion tuning.

## Path to endgame (for a follow-up session)

The depth ceiling is **enemy survival**, confirmed by the death-cause mix: the
player has only 3 HP, and the Spawner ramps spawn rate up to 2.5× when ascent
< 0.3 rows/s. Navigation is not the blocker — the bot climbs fine until the swarm
kills it ~depth 13. Highest-leverage next steps:
1. **Survival** (THE lever) — pre-emptive evasion of Heavy aim-fire lines,
   kite-while-reload, clear lane-blocking enemies before advancing, don't linger in
   open sightlines. Verify against the death-cause mix, not just max_depth.
2. **Band-aware depot picks** — buy FASTER_RELOAD (runner auto-picks
   `apply_choice(1)`) to cut breach time once survival lets the bot reach depots.
