# Code Review — Round 9-10-11 substrate (iter 090)

User feedback iter 89: "in the loop u gotta start asking delegating
agents for /code-review because there are bugs. it means the loop
is not exhaistive. u havent done enough to deserve a pause"

Iter-87 self-audit was too shallow. This review dispatched the full
/code-review skill — 5 personas (correctness, adversarial,
composition, invariance, reliability) + codex cross-model — in
parallel against the Round 9-10-11 diff (`721ff8d^..HEAD`, ~800
LoC across 8 GDScript files).

After fingerprint-dedup + cross-reviewer agreement promotion at the
75-anchor gate: **18 findings** (2 P0, 6 P1, 10 P2).

---

## Critical (P0 — must fix before next playtest)

### P0-1 · `_archetype_selecting` doesn't pause the world

- `scripts/PlayerTank.gd:271-273`
- Reviewers: adversarial (100), codex (80) → promoted to **100**
- Repro: At run start, breach mode + force_archetype_select=true.
  PlayerTank `_ready` calls `_show_archetype_select()`, which sets
  `_archetype_selecting = true`. PlayerTank `_physics_process`
  early-returns. **But no `get_tree().paused = true`** (unlike Depot
  which pauses). Spawner, Enemy, MortarShell, AmmoPickup all keep
  ticking. Enemies spawn, chase the stationary player, fire. The
  player CAN take damage (no `take_damage` gate on
  `_archetype_selecting`) — a Heavy can kill the player while they
  read the pick screen.
- Also: `_archetype_selecting` is checked BEFORE `_dead` in
  `_physics_process` — if the player dies during the pick screen,
  the selector polling blocks the death code path.
- Fix:
  ```gdscript
  func _show_archetype_select() -> void:
      _archetype_selecting = true
      _archetype_panel.visible = true
      _archetype_panel.process_mode = Node.PROCESS_MODE_ALWAYS
      get_tree().paused = true

  func _pick_archetype(value: int) -> void:
      ...  # existing logic
      get_tree().paused = false
  ```
  And reorder `_physics_process` so `_dead` is checked first.

### P0-2 · `_revert_archetype` / `_init_archetype` hard-resets `GunTimer.wait_time` — wipes FASTER_RELOAD XP bonus

- `scripts/PlayerTank.gd:578-582, 600`
- Reviewers: correctness (75), adversarial (100), codex (80) →
  promoted to **100**
- Repro: Pick MORTAR start. Level-up at L2 fires the FASTER_RELOAD
  branch (`_apply_level_boost`), `gt.wait_time = max(0.35, 1.5 -
  0.1) = 1.4`. Buy SWITCH_TO_RAM at depot. `_revert_archetype` runs
  MORTAR branch → hard-codes `gt.wait_time = 1.0`. All XP-earned
  reload reductions are wiped. Same hazard: DEFAULT level-up reduces
  wait_time below 1.0; switch to MORTAR then back resets to 1.0.
- Fix: cache `_base_gun_wait_time` in `_ready` (or as
  `level_boost_reduction: float`), apply XP boosts to the cache,
  derive per-archetype wait_time as `cache * archetype_multiplier`
  in `_init_archetype` and on revert.

---

## Important (P1 — should fix before next playtest)

### P1-1 · `Enemy.take_damage` re-emits `killed` if hp already ≤ 0 (double-kill)

- `scripts/Enemy.gd:462-468`
- Reviewers: correctness (75), invariance (75) → promoted to **100**
- Repro: MORTAR AoE catches an enemy already at hp=0 in the same
  frame (deferred queue_free). `take_damage(amount)` re-runs:
  `hp -= amount` (more negative), `killed.emit()` fires AGAIN,
  `_spawn_death_effect` paints a second burst, drop logic re-rolls.
  Spawner's `enemies_killed += 1` fires twice for one corpse,
  ammo/HP drops can spawn twice, XP doubles.
- Fix: 1-line guard at top of `take_damage`:
  ```gdscript
  func take_damage(amount: int) -> void:
      if hp <= 0:
          return
      hp -= amount
      ...
  ```
- **Fixing this in iter 090 directly** (one-line, surgical).

### P1-2 · `_pick_archetype` bypasses `_revert_archetype` (latent)

- `scripts/PlayerTank.gd:688-696`
- Reviewers: correctness (75), invariance (80) → promoted to **100**
- Repro: Latent today (start-pick is always from DEFAULT). But if
  any future caller invokes `_pick_archetype(MORTAR)` when current
  archetype is RAM, RAM_SPEED_BONUS stays added permanently, MORTAR
  GunTimer wait_time layers on top.
- Fix: route `_pick_archetype` through `switch_archetype` (single
  transition function), OR call `_revert_archetype()` inside
  `_pick_archetype` before reassigning.

### P1-3 · `switch_archetype` no value validation

- `scripts/PlayerTank.gd:592-598`
- Reviewers: correctness (75), adversarial (75), composition (65) →
  promoted to **100**
- Repro: `_player.switch_archetype(99)`. `archetype = 99`,
  `_init_archetype` falls through, tank is in undefined state.
  Future `_revert_archetype` won't restore anything.
- Fix:
  ```gdscript
  func switch_archetype(value: int) -> void:
      if value < TankArchetype.DEFAULT or value > TankArchetype.RAM:
          push_warning("switch_archetype invalid value: %d" % value)
          return
      if value == archetype:
          return
      ...
  ```

### P1-4 · `RunRecap.archetype` reassigned on every band change → contradicts "at run start" contract

- `scripts/PlayerTank.gd:1441` + `scripts/RunRecap.gd:30`
- Reviewers: adversarial (75), composition (80), codex (75) →
  promoted to **100**
- Two related bugs:
  - (a) `_on_breach_band_changed` does `run_recap.archetype = archetype`
    on every band crossing. Field is documented as "PlayerTank.
    TankArchetype value at run start." After a SWITCH_TO_*
    mid-run, the next band crossing overwrites it with the new
    archetype. Cross-archetype distinctness analysis (the whole
    point of iter-82/83) is corrupted by in-run switches.
  - (b) First band entry fires DURING archetype-select pause (if
    no tree pause — see P0-1) — `run_recap.archetype = 0`
    (DEFAULT) before the player picks. The first band is
    mis-attributed.
  - (c) The starting band is initialized silently by
    `ProceduralLevel._init_breach_mode()` BEFORE
    `breach_band_changed` would fire. Runs that die before first
    band transition get empty signatures; all signatures miss the
    initial band segment.
- Fix: set `run_recap.archetype` once in `_ready` after run_recap
  creation AND in `_pick_archetype()`. Seed the first band via
  deferred read of `level._current_breach_band` after parent
  `_ready` completes.

### P1-5 · Depot `_player` reference not validated with `is_instance_valid`

- `scripts/Depot.gd:80-94` + apply_upgrade SWITCH_TO_* branches
- Reviewers: adversarial (75), reliability (75) → promoted to **100**
- Repro: Player enters depot, `_player = body`. PlayerTank gets
  freed (scene reload, death + restart). Depot's `_player` is
  now a freed Node reference. Next call to
  `_player.has_method("switch_archetype")` on a freed Object —
  Godot 4 may crash or warn.
- Fix: wrap with `is_instance_valid(_player)` check in
  `apply_upgrade` for the SWITCH_TO_* branches, AND in any other
  `_player.` access.

### P1-6 · `MortarShell._explode` / `_spawn_burst` no `is_instance_valid` on parent

- `scripts/MortarShell.gd:41-53, 81-90`
- Reviewers: adversarial (75), reliability (75) → promoted to **100**
- Repro: Shell in flight (TRAVEL_TIME 0.6s). Player dies, presses R,
  scene reloads. Pending shell `_physics_process` fires one more
  time during reload window. `parent_node.add_child(burst)` on
  freed parent → error.
- Fix: guard before any `parent_node.add_child` / `get_children`:
  ```gdscript
  if parent_node == null or not is_instance_valid(parent_node) \
          or parent_node.is_queued_for_deletion():
      return
  ```

---

## Minor (P2 — fix soon)

### P2-1 · `RunRecapAnalyzer.compare_signatures` returns "similar" for single sig — should be "insufficient_data"

- `scripts/RunRecapAnalyzer.gd:32-63`
- Reviewers: correctness (75), reliability (75) → promoted to **100**
- Fix: distinct verdict for `sigs.size() < 2`.

### P2-2 · Hardcoded `switch_archetype(1/2/3)` int literals — brittle to TankArchetype reorder

- `scripts/Depot.gd:345-353` + `scripts/PlayerTank.gd:19`
- Reviewers: composition (75), invariance (70) → promoted to **100**
- Fix: pin via MetaProgress `_ARCHETYPE_*` constants OR add a
  test_breach_meta assertion that `TankArchetype.PRISM == 1` etc.

### P2-3 · `_init_archetype` MORTAR branch doesn't stop GunTimer first (DEFAULT→MORTAR carries old cooldown)

- `scripts/PlayerTank.gd:600` (and conceptually mirrors iter-88)
- Reviewers: reliability (75), codex (75) → promoted to **100**
- Fix: in `_init_archetype` MORTAR branch, `gt.stop()` then set
  wait_time, then `can_shoot = true`. Same pattern as iter-88's
  revert.

### P2-4 · `_die` doesn't call `_stop_beam` — PRISM beam stays drawn on death screen

- `scripts/PlayerTank.gd:866`
- Reviewer: codex (75) → anchor 75
- Fix: call `_stop_beam()` in `_die()` before showing death UI
  (when archetype == PRISM and beam_line.visible).

### P2-5 · `Spawner.BREACH_HP_BONUS` makes Heavy HP=3 but HEAT damage=2 — codex/canonical "HEAT kills heavies" claim is false in breach mode

- `scripts/Spawner.gd:462` + `configs/breach_default.tres:65`
- Reviewer: codex (75) → anchor 75
- Repro: PRESSURES.md says "HEAT one-shots Heavy"; breach config
  says canonical_answer = "APCR breaches steel bunker walls; HEAT
  kills entrenched heavies." But Heavy.max_hp = 2 + 1 = 3 in breach
  mode, and Bullet HEAT damage is `damage * 2 = 2`. **HEAT takes 2
  shells to kill a breach Heavy.** Codex affordance text is wrong.
- Fix: exclude Heavy from breach HP bonus, OR raise HEAT damage vs
  armored, OR update the canonical text + PRESSURES.md.

### P2-6 · `Depot._upgrade_pool` can offer SWITCH_TO_* matching current archetype (no-op pick)

- `scripts/Depot.gd:229`
- Reviewer: codex (75) → anchor 75
- Fix: filter SWITCH_TO_X from the pool when `_player.archetype == X`.

### P2-7 · Beam burns non-enemy `take_damage`-bearing bodies at FRAME-RATE

- `scripts/PlayerTank.gd:529-538`
- Reviewer: adversarial (75) → anchor 75
- Repro: Bricks burn fast (intended). But any future multi-HP
  non-enemy damageable (eagle base, destructible cover) would melt
  in 1 second at 60fps. The `is_in_group("enemy")` gate is the only
  cooldown applier.
- Fix: apply `BEAM_DAMAGE_COOLDOWN` to all damageable bodies, OR
  add an explicit "burn" group for brick-fast targets.

### P2-8 · `MortarShell._physics_process` no `t` clamp before lerp — frame-spike overshoot

- `scripts/MortarShell.gd:41-53`
- Reviewer: reliability (75) → anchor 75
- Fix: `var t: float = min(1.0, _elapsed / TRAVEL_TIME)` before
  `start_pos.lerp(target_pos, t)`.

### P2-9 · `MetaProgress.unlock_ladder()` returns 4 rungs but pool widens 7 tiers — codex/HUD under-reports

- `scripts/MetaProgress.gd:55-61` + `scripts/Depot.gd:208-235`
- Reviewer: composition (75) → anchor 75
- Fix: extend `unlock_ladder()` to include the 3 archetype rungs,
  OR split into `upgrade_ladder()` / `archetype_ladder()`.

### P2-10 · MORTAR AoE can friendly-fire the firing player

- `scripts/MortarShell.gd:67-76`
- Reviewer: composition (70) → **below 75 gate** — NOT promoted
- Marked here for awareness; doesn't enter the action queue.

---

## Fix queue (recommended order)

| Order | Finding | File | Effort | Iter |
|-------|---------|------|--------|------|
| 1 | P1-1 Enemy double-kill | Enemy.gd | 1 line | **iter 090 (this iter)** |
| 2 | P0-1 selector pause | PlayerTank.gd | small | iter 091 |
| 3 | P0-2 FASTER_RELOAD cache | PlayerTank.gd | medium | iter 092 |
| 4 | P1-3 switch_archetype validation | PlayerTank.gd | 3 lines | iter 093 |
| 5 | P1-5 Depot._player is_instance_valid | Depot.gd | small | iter 093 |
| 6 | P1-2 _pick_archetype bypass | PlayerTank.gd | small | iter 094 |
| 7 | P1-6 MortarShell parent guard | MortarShell.gd | small | iter 094 |
| 8 | P1-4 RunRecap archetype contract | PlayerTank.gd / RunRecap.gd | medium | iter 095 |
| 9 | P2-1 to P2-9 (8 items) | various | small each | iter 096+ |

After all fixes: re-run test-all + test-breach + hash. Add a
regression harness per fix that catches the failure mode.

---

## Why iter-87 missed these

- Read-only audit of state-machine code only; didn't construct
  failure scenarios across modules
- Didn't trace XP / leveling interaction with archetype switching
- Didn't check the pause / tree-state contract for the selector
- Didn't validate cross-module assumptions (Depot `_player`
  lifecycle, hardcoded enum ints, run_recap.archetype contract)
- Didn't notice the codex/canonical contradiction (HEAT vs breach
  Heavy HP)

The right discipline going forward: **delegate /code-review at
every round close**, not just self-audit. The 9-persona +
cross-model pipeline catches what a single-pass read cannot.
