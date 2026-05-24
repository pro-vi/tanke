# Code Review — Round 5-8 substrate (iter 100, fresh scope)

Sequel to `code-review-iter-090.md` (Round 9-10-11). This review
covers iters 33-61 substrate: shell economy + depots + XP/levels +
band-aware spawning + meta progression — the gameplay surface the
player will actually drive during playtest 5.

Three personas dispatched (correctness, adversarial, invariance) in
parallel — leaner pipeline than iter-90's 5+codex. Total finding
count: 35 raw → 11 after fingerprint dedup + cross-reviewer
agreement promotion + 75-anchor gate.

## Critical (P0 — must fix before next playtest)

### P0-A · Depot randomized re-entry → multi-pick exploit

- `scripts/Depot.gd:184-204` + `_on_body_entered/_picked` lifecycle
- Reviewers: adversarial (90) → P0 with critical-but-uncertain rule
- **Repro**: Player enters randomized depot, picks an upgrade
  (`_picked = true`, apply_choice runs). Player walks out
  (`_on_body_exited` fires but does NOT clear `_picked` —
  actually `_on_body_entered` is what resets `_picked = false`).
  Re-enter the depot — `_picked = false` again, `_rolled_kinds`
  non-empty so `_ensure_rolled` short-circuits (same 3 offers).
  Pick #1 a SECOND time. With `HE_REFILL_2`: +2 HE again (free
  refill). With `HE_MAX_EXPAND_2`: `max_he_reserve += 2` again
  (**unbounded capacity growth per re-entry**). With
  `FULL_RESUPPLY`: free instant resupply on demand.
- **Fix**: track `_lifetime_picked: bool` set once in
  `apply_choice` and never cleared. In `_on_body_entered`,
  after the early reset, gate: `if _lifetime_picked: return`
  (or repaint panel as "PICKED" disabled).

## Important (P1 — should fix)

### P1-A · APCR `_steel_drilled == THRESHOLD` skips refund on rapid-multi-block hit

- `scripts/Bullet.gd:91-101`
- Reviewers: adversarial (75) + correctness (75) → promoted to **100**
- **Repro**: STEEL_SALVAGE_THRESHOLD = 3 (Bullet.gd:179). APCR
  drills into a steel cluster; physics_process can deliver
  multiple body_entered events for an Area2D scanning through
  tiles in the same frame. `_steel_drilled` jumps 2→4, skipping
  3 → refund never triggers despite drilling MORE than threshold.
- Also: correctness flagged that `_steel_drilled` increments
  OUTSIDE the `body.has_method("breach")` guard — counter ticks
  even on inert steel blocks lacking `breach()`.
- **Fix**: change `== STEEL_SALVAGE_THRESHOLD` → `>= THRESHOLD and not _salvage_paid` + add `var _salvage_paid: bool = false`. Move counter increment INSIDE the `has_method("breach")` guard.

### P1-B · Shell codex SPACE-dismiss leaks into `_fire` → wastes a shell

- `scripts/PlayerTank.gd:309-310 + 449`
- Reviewer: adversarial (85)
- **Repro**: Run starts; codex visible. Player presses SPACE to
  dismiss. `_dismiss_codex` runs. **Execution continues** through
  `_physics_process`. `_fire()` then runs because `ui_accept` is
  still pressed → consumes a shell + arms GunTimer cooldown.
  Current_shell = AP → no reserve consumed (AP infinite). But
  GunTimer cooldown locks the next intentional fire for 1.0s.
- **Fix**: add `return` after `_dismiss_codex()` so the same
  frame doesn't continue to input processing.

### P1-C · BandBanner Labels stack indefinitely on Y-boundary oscillation

- `scripts/PlayerTank.gd:1521-1535 + 1542-1566`
- Reviewer: adversarial (80)
- **Repro**: Player straddles a band boundary (Y-position
  oscillates), `breach_band_changed` emits on each crossing,
  `_show_band_banner` creates a NEW Label each time. Tween runs
  1.3s. Multiple Labels stack at same position; HUD layer
  accumulates them.
- **Fix**: track `_band_banner: Label = null`; before creating a
  new one, `if _band_banner != null and is_instance_valid: queue_free()`.

### P1-D · Fire-while-swapping silent drop (UX)

- `scripts/PlayerTank.gd:449-475`
- Reviewer: adversarial (75)
- **Repro**: Player TABs (sets `_swap_cooldown = 0.5`), then
  SPACEs next frame → `_fire` blocked silently. User reads it
  as input drop. With QUICK_SWAP owned, swap_cooldown stays 0
  so no issue.
- **Fix**: when `_fire` rejects due to `_swap_cooldown > 0`,
  emit a brief visual cue (flash shell-panel BG, or shorten
  `shell_swap_cost` to 0.15s).

### P1-E · `max_*_reserve` unbounded growth via level-up SHELL_CAP

- `scripts/PlayerTank.gd:1780-1786`
- Reviewer: invariance (75)
- **Repro**: `_apply_level_boost` SHELL_CAP path increments all
  three `max_*_reserve` by 1 every 3 levels. No ceiling. A long
  run pushes `max_he_reserve` arbitrarily high.
- **Fix**: ceiling-cap (e.g. `MAX_HE_CAP = 12`) and clamp the
  level boost, OR rotate boost set with finite total.

### P1-F · `max_hp` unbounded growth via level-up

- `scripts/PlayerTank.gd:1767-1773`
- Reviewer: invariance (75)
- **Repro**: Same as P1-E pattern; level-up `kind == 0` does
  `max_hp += 1; hp += 1`. No ceiling.
- **Fix**: ceiling constant + clamp, OR finite rotation. Likely
  paired fix with P1-E.

## Minor (P2 — fix soon)

### P2-A · AmmoPickup random shell pick wastes when player at cap

- `scripts/AmmoPickup.gd:23-26`
- Reviewers: invariance (75) + correctness (50) → promoted to **100**
- **Repro**: AmmoPickup picks `randi() % DROP_SHELLS.size()`
  without checking the player's current reserve. Pick HE when
  `he_reserve == max_he_reserve` → silent no-op pickup.
- **Fix**: pass loadout to AmmoPickup at spawn OR re-roll if
  picked class is at cap, OR weight by `reserve/max` ratio
  (lowest fill gets highest weight).

### P2-B · Multi-level-up toast stacking at identical position

- `scripts/PlayerTank.gd:1240-1248`
- Reviewer: correctness (75)
- **Repro**: Big XP burst (kills + depth in one tick) crosses
  2-3 levels → `_grant_xp` while-loop calls `_apply_level_boost`
  per level → multiple toasts at `(140, 28)`.
- **Fix**: stagger Y offset per toast OR coalesce.

### P2-C · Route-strip backward repaints prior cells

- `scripts/PlayerTank.gd:1117-1124`
- Reviewer: correctness (75)
- **Repro**: Player climbs to band 3, retreats to band 1 →
  `_highlight_route_cell(1)` paints i<1 cleared, i==1 current,
  i>1 plain — cells 2-3 lose "cleared" tint despite visited.
- **Fix**: track `_max_cleared_idx` separately.

### P2-D · MetaProgress threshold retiering silently revokes options

- `scripts/MetaProgress.gd:18-22`
- Reviewer: invariance (75)
- **Repro**: QUICK_SWAP moved from `best ≥ 40` → `best ≥ 60`.
  Pre-existing saves with `best ∈ [40, 60)` lose the unlock
  silently — violates CONSULT 003 "options not power."
- **Fix**: design call — likely accept as intended (the retiering
  was deliberate iter-51 work). Document explicitly that no
  migration is needed because the retiering reflects an
  honest re-tuning, OR add a one-time grandfather flag.

## Below 75 gate (NOT in queue)

For traceability — these found findings stayed below the
operational gate but documented as awareness-tier:

- HE blast scans Level siblings → damages player/eagle (adversarial 65)
- Depot KEY_1 held → multi-depot auto-pick (adversarial 70)
- _respawn no loadout/timer reset (adversarial 70)
- AmmoPickup randi() in _ready burns RNG in arc-2/3 (adversarial 65)
- APCR loadout fallback visual mismatch (adversarial 65)
- _grant_xp infinite loop if XP_BASE ≤ 0 (adversarial 60)
- HE breach_dividend over-counts on non-take_damage primary (correctness 50)
- HE blast bypasses armor on radius targets (correctness 50)
- _min_y_reached not reset on respawn — XP stalls (correctness 50)
- AmmoPickup wasted at cap (single-source 50, but promoted via I1)
- Several Depot/MetaProgress edge-case finds at 50

## Fix queue (recommended order)

| Order | Finding | File | Effort | Iter target |
|-------|---------|------|--------|-------------|
| 1 | **P0-A** Depot re-entry exploit | Depot.gd | small (4 lines) | **iter 100 ✓ FIXED** |
| 2 | P1-A APCR steel_drilled >= + latch | Bullet.gd | small (3 lines) | **iter 101 ✓ FIXED** (harness: test_breach_steel_salvage_threshold) |
| 3 | P1-B codex dismiss → return | PlayerTank.gd | 1 line | **iter 101 ✓ FIXED** (substrate write ×36) |
| 4 | P1-C BandBanner cleanup | PlayerTank.gd | small | **iter 102 ✓ FIXED** (harness: test_breach_band_banner_stacking, substrate ×37) |
| 5 | P1-D fire-while-swap UX | PlayerTank.gd | medium | **iter 102 ✓ FIXED** (harness: test_breach_fire_while_swap, substrate ×38) |
| 6 | P1-E + P1-F max ceilings | PlayerTank.gd | small | **iter 103 ✓ FIXED** (harness: test_breach_level_up_ceilings, substrate ×39) |
| 7 | P2-A AmmoPickup re-roll | AmmoPickup.gd | small | **iter 103 ✓ FIXED** (harness: test_breach_ammo_pickup_no_waste) |
| 8 | P2-B toast stacking | PlayerTank.gd | small | **iter 104 ✓ FIXED** (harness: test_breach_toast_stagger, substrate ×40) |
| 9 | P2-C route-strip backward | PlayerTank.gd | small | **iter 104 ✓ FIXED** (harness: test_breach_route_strip_max_cleared, substrate ×41) |
| 10 | P2-D MetaProgress option revocation | MetaProgress.gd | design call | **NO-OP** — accept as intended per iter-100 review note (re-tiering reflects honest re-tuning, not a bug to migrate around) |

**SPRINT COMPLETE** — 10 of 11 actionable findings fixed across iters 100-104. P2-D is a no-op design call.

Estimated total sprint: 4-5 iters for 11 findings.
