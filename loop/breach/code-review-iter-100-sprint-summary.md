# Code-Review-Iter-100 Sprint Summary

Closing doc for the 5-iter fix sprint (iters 100-104) that resolved
the code-review-iter-100 findings.

- **Window**: iters 100-104 (2026-05-24)
- **Source review**: `code-review-iter-100.md` — 11 anchored findings
  on Round 5-8 substrate (1 P0 + 6 P1 + 4 P2), surfaced via the F006
  pattern (delegate /code-review at round close) applied retroactively
  per F007 (the discipline should cover prior-round substrate too).
- **Outcome**: **10 of 11 actionable findings fixed** with regression
  harness coverage. The 11th (P2-D) is a design-call no-op per the
  iter-100 review note ("accept as intended — the retiering reflects
  an honest re-tuning, not a bug to migrate around").

## Resolution table

| Iter | Finding | File(s) touched | Harness | Substrate write # |
|------|---------|-----------------|---------|-------------------|
| 100 | **P0-A** Depot re-entry exploit | Depot.gd (arc-4-owned) | test_breach_depot_lifetime_pick | n/a (arc-4) |
| 101 | P1-A APCR steel_drilled `==`→`>=` + latch | Bullet.gd | test_breach_steel_salvage_threshold | Bullet.gd ×8 |
| 101 | P1-B Codex dismiss → `return` | PlayerTank.gd | (codex shares existing test surface) | PlayerTank.gd ×36 |
| 102 | P1-C BandBanner stacking cleanup | PlayerTank.gd | test_breach_band_banner_stacking | PlayerTank.gd ×37 |
| 102 | P1-D Fire-while-swap UX flash | PlayerTank.gd | test_breach_fire_while_swap | PlayerTank.gd ×38 |
| 103 | P1-E + P1-F Level-up max ceilings | PlayerTank.gd | test_breach_level_up_ceilings | PlayerTank.gd ×39 |
| 103 | P2-A AmmoPickup re-roll on cap | AmmoPickup.gd (arc-4-owned) | test_breach_ammo_pickup_no_waste | n/a (arc-4) |
| 104 | P2-B Toast Y stagger | PlayerTank.gd | test_breach_toast_stagger | PlayerTank.gd ×40 |
| 104 | P2-C Route-strip max-cleared tracking | PlayerTank.gd | test_breach_route_strip_max_cleared | PlayerTank.gd ×41 |
| n/a | **P2-D** MetaProgress option revocation | MetaProgress.gd | (no-op by design call) | n/a |

**Totals**: 10 findings × ≥1 regression harness each = 10 new harnesses;
test-breach aggregate **47 → 57** (+10). PlayerTank.gd substrate write
count **×35 → ×41** (+6 — three P1 + three P2 fixes against the
arc-2/3 substrate file; all default-on gated; hash anchor preserved).

## Hash anchor integrity

`23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291`
verified bit-identical at the close of every iter in the sprint
(100, 101, 102, 103, 104). The 6 PlayerTank.gd substrate writes
all live on arc-4-only codepaths: loadout-gated (shell panel,
level-up, toast, route strip), breach-level-only (band banner),
or codex-modal-only (P1-B return). Default procedural baseline
codepath is unchanged across the entire sprint.

## Loop-process findings (meta)

1. **Paired-fix batching scales.** 5 iters resolved 10 findings —
   2 findings per iter on average. Same pattern as iter-90 sprint
   (iters 90-98 resolved 17 findings in 9 iters = 1.9/iter). The
   "two fixes + one harness file" cadence keeps each iter's blast
   radius small while still moving the queue meaningfully.

2. **F006 + F007 are now load-bearing.** Without /code-review
   delegation at round close (F006), the 11 latent findings on
   Round 5-8 substrate would have stayed undetected — including a
   60-iter-latent P0 (Depot re-entry exploit, present since iter
   41). The retroactive application (F007) closed that exposure.
   Future rounds: invoke /code-review at every round close, even
   if the round looks "clean."

3. **Regression-harness-per-fix is the right discipline.** All 10
   fixes have anchored assertions. The harnesses themselves become
   the proof-of-fix and the long-term tripwire if any future iter
   regresses the cleanup.

4. **Godot HUD gotcha (discovered iter 102)**: `queue_free()` does
   not release a node's `name` reservation until the next frame.
   `add_child` of a same-named node while the prior is queued for
   deletion auto-renames the new node (`BandBanner` → `@Label@37`).
   For test code that needs to identify short-lived HUD Labels,
   count by **text signature** or **meta key**, not name. This
   gotcha drove the `is_pickup_toast` meta-tag pattern used in P2-B
   (test_breach_toast_stagger) and the text-signature counter in
   test_breach_band_banner_stacking.

5. **CONSULT constraint mapping was useful.** Every PRE-MORTEM in
   the sprint cited which of the 7 CONSULT §9 constraints the fix
   served. This produced a clean rationale chain: P1-A → constraint 3
   (APCR's drill verb honest); P1-D → constraint 1 (cost surfaces
   readable); P1-E/F → constraint 7 (verbs over passive stats);
   P2-B → constraint 6 (run-recap legibility); P2-C → constraint 5
   (band-as-specific-problem). Bug fixes earned their place in
   the loop's design vocabulary, not just the bug tracker.

## Next round bootstrap (open question for iter 106+)

With code-review-iter-100 sprint closed, the loop bootstraps the
next exploration round. The weakest rubric axes are:

- **C9 = 2/5** (death attribution / run recap legibility) — the
  lowest score on the rubric; an under-invested surface despite
  CONSULT constraint 6 making this load-bearing. Likely a 2-3-iter
  BUILD round around what the recap actually tells the player.
- **C5 = 3/5** (depth-band pressure naming) — three bands have
  named pressures (PRESSURES.md, iter 76) but the in-game surfacing
  is just the band-arrival banner. A round on per-band telegraphing
  + interim pressure cues would lift this.
- Several C-axes at 3 (C1, C2, C4, C6, C7, C8, C11, C12, C13, C14)
  could move with targeted BUILDs but none is structurally weak
  enough to demand attention.
- C15 = 4 (build-identity surfacing) — already strong; sprint-grade
  improvements would need specific playtest evidence to lift to 5.

**Recommendation**: iter 106 DIAGNOSE → iter 107 SPIKE on C9
(death-recap surface), with the option to widen to C5 if the
spike surfaces shared infrastructure (run-narration framework).
The C9 surface is also the cleanest connection to the open
playtest gate (REVIEW-QUEUE #14) — better recap = better
playtest debrief = better next-round direction.
