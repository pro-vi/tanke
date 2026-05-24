# Round 16 — Gap 4 route-diff (path-not-taken) — Summary

Round 16 ran iters 121-122 — a 2-iter round (BUILD-QUALITY +
META). Goal: close the iter-106 recap-legibility-deferred Gap 4
backlog item.

## Outcome

Shipped `RunRecap.route_diff_clause()` + PlayerTank substrate
write ×45 wiring it into the post-death breach-prompt label.
Route attribution joins BUILD/RESOURCE/CANONICAL as the **4th
constraint-6-shaped diagnosis surface** the post-death overlay
exposes.

| Iter | Mode | Output | Substrate |
|------|------|--------|-----------|
| 121 | BUILD-QUALITY | RunRecap.route_diff_clause helper + PlayerTank breach-prompt wire | PlayerTank ×45 |
| 122 | META | This summary + REVIEW-QUEUE #22 | none |

Test-breach **62 → 63**. Hash anchor `23d6a2ec3bf2821f` intact.

## Scoring

| Criterion | Pre-Round-16 | Post-Round-16 |
|-----------|--------------|---------------|
| (no rubric movement — Gap 4 is info-density addition to C6 anchor 4 which is already at effective ceiling pending playtest cite) | 50/75 effective + absolute | **50/75** unchanged |

## Loop-process findings

1. **Backlog closure rounds work without rubric movement.** The
   iter-106 Gap 4 deferral has been on the books for 15 iters.
   Round 16 closed it cleanly with 1 BUILD-QUALITY iter
   (no SPIKE; no DIAGNOSE; the iter-106 diagnosis already
   spec'd the work). Pattern: when a previously-deferred item
   has clear spec + low scope, a single BUILD-QUALITY iter
   suffices — no need to repeat DIAGNOSE.

2. **The death-overlay diagnosis surface is now 4-layer**:
   - C6 anchor 1-3 (depth/band/build) — iter 108 verdict_sentence
   - Killed-by (kill source) — iter 109 set_last_damage_source
   - Resource attribution — iter 110 resource_sentence
   - **Route attribution (path-not-taken)** — iter 121 route_diff_clause
   The breach-prompt label below the death panel is the surface
   for the route-diff (the death panel itself has line-budget
   constraints). Two distinct read-surfaces below one death:
   verdict (panel) + diagnosis-prompt (label). Natural division.

## Round 17 bootstrap

Round count and substantive ship volume across recent rounds:

| Round | Iters | Substantive ship |
|-------|-------|------------------|
| 12 (C6 recap) | 5 | verdict_sentence + kill_source + resource_sentence |
| 13 (C8 SCOUT_TELEGRAPH) | 3 | 1 upgrade |
| 14 (C8 REAR_GUARD) | 3 | 1 upgrade |
| 15 (C10 re-tag) | 3 | 0 code; 1 rubric correction |
| 16 (Gap 4) | 2 | 1 helper + 1 wire |

Round size is contracting. This is the structural-ceiling
reality at work — without user direction, the highest-value
forward work shrinks. Per the iter-89 directive the loop runs
non-stop; the iter-117 audit + iter-120 round-15-summary +
REVIEW-QUEUE #21 frame the explicit user-decision request.

Iter 123 candidates for the next round's first iter:

- **Gap 5 regret-quote** (deferred from iter-106) — auto-
  generate a CANDIDATE regret-quote from build_tag +
  killing_band + reserve_left, rendered as part of the
  verdict OR the breach-prompt. Cleanest backlog item left;
  medium scope (sentence template + helper + harness).
- **ARC-4-checkpoint.md** — cross-rounds catch-up doc for
  the user. Summarizes all 16 rounds + score history + the
  forward-decision surface in one read. Future-user-value;
  no rubric impact.
- **Audio cues DIAGNOSE** — would surface a new scope candidate
  for the user to direct.
- **HUD polish** — small QoL refinements.

Recommendation: **Gap 5 regret-quote** for iter 123 — closes
the last iter-106 backlog item, mirrors the iter-121 pattern
(deferred-spec → single BUILD-QUALITY iter), keeps rolling.
Iter 124 META Round 17 close-out.

Then iter 125+ may run out of natural BUILD-QUALITY scope and
need to pivot to either documentation (ARC-4-checkpoint.md)
or explicit user-request-via-PushNotification depending on
whether the user has surfaced direction.
