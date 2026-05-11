# tanke — Gameplay Loop LEDGER

Append-only. One block per iteration. Iter 0 is bootstrap (no scoring).

---

## Iter 000 — BOOTSTRAP

**Mode:** BOOTSTRAP (no scoring)
**Date:** 2026-05-10
**Branch:** `exp/godot4-loop`

### Preloop resolution

User F5 confirmed tank renders + moves with WASD/arrows on the gameplay scene.

One blocker surfaced + fixed during preloop:
- `project.godot:14 run/main_scene` was `res://scenes/Level.tscn` (the legacy
  hand-built scene). Its `Level.gd` references nonexistent child nodes
  `$Tiles/Brick` / `$Tiles/Steel` / `$Tiles/Grass` / `$Tiles/Water` (actual
  nodes are `BrickTileMap` etc.), so F5 launched a broken scene with red
  spam in Output. Switched to `res://scenes/ProceduralLevel.tscn` so F5
  lands on the gameplay-target scene (the one with the iter-29 shoot-signal
  fix and `playable.tres` default). `project.godot` is not in the substrate
  freeze list — this is a config flip, not a generation-logic change.

### Substrate baseline

| Field | Value |
|-------|-------|
| Active scene | `scenes/ProceduralLevel.tscn` |
| Active config | `configs/playable.tres` |
| Seed | 42 (oracle reference) |
| `playable` | **true** |
| `reachable_cells` | 804 |
| `rows_climbed` | 29 |
| `min_reachable_row` | 0 |
| `cc_count` / `cc_avg` / `cc_max` | 49 / 12.08 / 60 |
| `eller_sets` / `eller_avg_size` / `eller_max_size` | 15 / 1.33 / 3 |
| `vert_structure_lift` | 2.63 |
| `tile_hash` (seed 42) | `f873ae60ee3c420c57cdef5762acdad857b1a763ec50b76db80971ef4503e797` |
| Headless boot | `godot --quit` exit 0, no errors |

### Substrate internalized (from META-RETRO "What survives past the loop")

Engine-loop deliverables I will not modify and may reuse:
1. `LevelDNA` + `BiomeConfig` + named presets (serializable level-recipe system)
2. Hash-anchor pattern (16-char fingerprint, one-shot regression check)
3. `structure_lift` metric (IID-normalized vertical-pair correlation)
4. `gen_tile.py --from-sheet` (palette-aware tile generation)
5. Eller's invariant fix (≥1 carry per set)
6. Cited mutation cycles (edit → rerun → cite Δ)
7. `AGENTS.md` parameter map

### Scores

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Core loop closes | 0 | Shooting broken (Bullet.tscn missing script) |
| 2. Spawn / wave system | 0 | No enemies |
| 3. HP + death model | 0 | No HP |
| 4. XP + level-up flow | 0 | No XP |
| 5. Upgrade variety | 0 | No upgrades |
| 6. Enemy variety | 0 | No enemies |
| 7. Run pacing | 0 | No run structure |
| 8. Visual feedback / juice | 0 | None |
| 9. UI / UX | 0 | No HUD |
| 10. Build distinctness | 0 | No builds |
| **Total** | **0/50** | Floor; gameplay loop starts here |

### Files touched

- `project.godot` (`run/main_scene` Level.tscn → ProceduralLevel.tscn)
- `loop/gameplay/STATE.md` (preloop_complete → yes, baseline recorded, next action set)
- `loop/gameplay/LEDGER.md` (this file, created)

### Schedule

- Iter 1 = BUILD (fix Bullet system per open seam #1, advance criterion 1)
- ScheduleWakeup cadence: 240s for BUILD per PROMPT §7
- First mandatory PLAYTEST: iter 5 (or earlier if shoot+move+enemies all work)

---

## Iter 001 — BUILD — Bullet system

**Mode:** BUILD
**Focus:** criterion 1 (core loop closes) — fix the broken Bullet so shoot+travel+collision actually works
**Date:** 2026-05-10
**Pre-mortem:** PRE-MORTEMS.md iter 001 (predicted criterion 1 → 2/5; predicted headless clean; predicted oracle unchanged)

### Diagnose

Weakest axis: **criterion 1 (Core loop closes) at 0/5**. Evidence: STATE.md
iter-0 scores all at floor; user F5 confirms move works (iter 0), but
shooting known broken per open seam #1. PROMPT §"KNOWN BROKEN" iter-1 work:
fix the Bullet system.

### Findings during inspection

PROMPT was slightly off: `Bullet.gd` *did* exist (at repo root, not in
`scripts/`). The actual blockers were:
1. `scenes/Bullet.tscn` was `format=2` (Godot 3) — broken ext_resource
   syntax + `extents` on RectangleShape2D (Godot 4 wants `size`)
2. Only `area_entered` was wired — but terrain (BrickBlock, WaterBlock,
   TileMapLayer) is `StaticBody2D`, so collisions never fired
3. `speed = 5` in the .tscn (Godot-3 frame-tied speed) is unplayable at
   `_process(delta)` semantics — 5 px/sec × 1s lifetime = 5px total travel
4. `Bullet.gd` at repo root violates the `scripts/` convention used by
   every other game script

### Actions

1. Moved `Bullet.gd` repo-root → `scripts/Bullet.gd` (preserved
   `uid://cbdxbbvo1fdgj` in `scripts/Bullet.gd.uid`; deleted root files)
2. Rewrote `scripts/Bullet.gd` typed (consistent with iter-27 substrate):
   - `start(pos: Vector2, dir: int)` sets position/rotation/velocity, sets
     timer `wait_time = lifetime` and starts it
   - `_physics_process(delta)` moves the bullet (physics frame so collision
     callbacks sync)
   - `_on_area_entered(_area)` + `_on_body_entered(_body)` both
     `queue_free()` — covers future enemies (Areas) and current terrain
     (StaticBodies)
   - `_on_lifetime_timeout()` `queue_free()`
   - Defaults: `speed = 120` px/s, `damage = 1`, `lifetime = 2.0s`
3. Migrated `scenes/Bullet.tscn`:
   - `format=2` → `format=3` with proper Godot 4 ext_resource syntax
   - `extents = Vector2(2.00204, 1.50773)` → `size = Vector2(4, 3)` (Godot
     4 RectangleShape2D uses full size, not half-extents — `2.00204*2 ≈ 4`)
   - Removed the `speed = 5` override (let Bullet.gd default of 120 stand)
   - `collision_layer = 4` (Bullet), `collision_mask = 1` (Environment)
   - `LifeTimeTimer wait_time = 2.0, one_shot = true`
   - Signal connections updated to `_on_area_entered`, `_on_body_entered`,
     `_on_lifetime_timeout`

### Verification

- `godot --headless --path . --quit` → exit 0, clean (one cosmetic UID-cache
  warning about `uid://cbdxbbvo1fdgj` falling back to text path — Godot
  will refresh the UID cache on next editor open; harmless)
- Reachability oracle (seed 42): `playable: true, reachable_cells: 804,
  rows_climbed: 29, tile_hash: f873ae60ee3c420c…` — identical to iter-0
  baseline. Bullet changes don't touch tile placement, as predicted.

### Scores

| Criterion | Iter 0 | Iter 1 | Δ | Citation |
|-----------|--------|--------|---|----------|
| 1. Core loop closes | 0 | **2** | +2 | `scripts/Bullet.gd:13-30`, `scenes/Bullet.tscn:9-26`, headless boot exit 0. Capped at 2 — feel criterion, needs playtest for >2. |
| 2. Spawn / wave system | 0 | 0 | – | No enemies still |
| 3. HP + death model | 0 | 0 | – | No HP still |
| 4. XP + level-up flow | 0 | 0 | – | – |
| 5. Upgrade variety | 0 | 0 | – | – |
| 6. Enemy variety | 0 | 0 | – | – |
| 7. Run pacing | 0 | 0 | – | – |
| 8. Visual feedback / juice | 0 | 0 | – | No spark/impact yet |
| 9. UI / UX | 0 | 0 | – | – |
| 10. Build distinctness | 0 | 0 | – | – |
| **Total** | **0** | **2** | **+2** | |

### Pre-mortem evaluation

Prediction 1 (criterion 1 → 2): **landed** as called.
Prediction 2 (headless clean): **landed** (one cosmetic UID warning aside).
Prediction 3 (oracle unchanged): **landed** exactly.

No falsifications this iter — pre-mortem was conservative and correct.
Real falsification risk shifts to iter 5 playtest: does the bullet actually
visibly move and visibly despawn? Code says yes; user eyes will tell.

### Files touched

- Created: `scripts/Bullet.gd`, `scripts/Bullet.gd.uid`,
  `loop/gameplay/PRE-MORTEMS.md`
- Rewrote: `scenes/Bullet.tscn` (format 2 → 3 migration)
- Deleted: `Bullet.gd`, `Bullet.gd.uid` (from repo root)

### Schedule

- Iter 2 candidate = BUILD: enemies (Enemy.tscn + Enemy.gd + basic chaser
  AI + spawner stub). Advances criteria 2 + 6 simultaneously. Also creates
  a real bullet target so iter-1's collision register gets visual proof.
- ScheduleWakeup 240s (BUILD cadence per PROMPT §7)
- PLAYTEST gate remains iter 5

---

## Iter 002 — BUILD — Enemies + Spawner

**Mode:** BUILD
**Focus:** criteria 2 (spawn) + 6 (enemy variety) — first enemies in the world; also gives bullets a real target
**Date:** 2026-05-10
**Pre-mortem:** PRE-MORTEMS.md iter 002 (predicted crit 2 → 1, crit 6 → 1, crit 1 holds at 2, boot/oracle clean; runtime miss = enemies stuck on walls)

### Diagnose

Weakest axes: 9 criteria still at 0/5. Picked crit 2 (Spawn) + crit 6
(Enemy variety) — both lift with one BUILD because enemies need spawning
to exist, and a spawned chaser gives bullets a visible target validating
iter-1's collision-register claim. HP/death/XP can't move until enemies
exist (you need something to kill). So crit-2+6 is the right unblock.

### Actions

1. Wrote `scripts/Enemy.gd` (typed, CharacterBody2D):
   - `@export var speed: float = 24.0` (under PlayerTank's 32 so player
     can outrun)
   - `@export var max_hp: int = 1`
   - `_player` resolved via `get_tree().get_root().find_child("PlayerTank")`
   - `_physics_process` does `velocity = to_player.normalized() * speed;
     move_and_slide()` — naive chaser, no pathfinding
   - `take_damage(amount)` decrements hp, `queue_free` on death
2. Wrote `scenes/Enemy.tscn` (format 3, 14×14 collision box):
   - CharacterBody2D with `collision_layer=8` (Enemy), `collision_mask=1`
     (Environment) so they push against walls
   - Sprite2D using `img/sprites_0.png`, vframes=18 hframes=16, `frame=16`
     (row 2 col 0 — enemy tank from Battle City sprite sheet)
3. Wrote `scripts/Spawner.gd` (Node2D, scene-resident):
   - `@export enemy_scene: PackedScene`, `spawn_interval=2.0s`,
     `max_enemies=20`, `spawn_distance=120` px
   - `_ready` creates a child Timer (autostart) — self-contained, no scene
     wiring needed beyond the export
   - On timeout: pick random angle around player, instantiate enemy at
     `player.global_position + Vector2(spawn_distance, 0).rotated(angle)`,
     `add_child` under the level (sibling of player)
   - Tracks `_enemies_alive` via `tree_exited` signal so cap respects deaths
4. Added Spawner to `scenes/ProceduralLevel.tscn` (substrate freeze
   compliant — only the .gd is frozen; .tscn nodes can be added):
   - `[node name="Spawner" type="Node2D" parent="."]` with
     `enemy_scene = ExtResource(Enemy.tscn)`, all four export defaults
5. Bullet collision upgrade:
   - `scripts/Bullet.gd:25-28`: `_on_body_entered` now calls
     `body.take_damage(damage)` if the body has that method
   - `scenes/Bullet.tscn:11`: `collision_mask = 1 → 9` (Environment +
     Enemy layer 8 = 1+8 = 9)

### Substrate freeze check

- `LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`, `ProceduralStep.gd`,
  `ProceduralLevel.gd`, all `tools/*.py`, `loop/test_runner.gd`,
  `configs/*.tres` — **untouched**.
- `ProceduralLevel.tscn` modified (added Spawner node + 2 ext_resources);
  not in the freeze list (only the .gd is).

### Verification

- `godot --headless --path . --quit` → exit 0, clean. One carryover
  cosmetic UID warning for Bullet.gd (Godot's UID cache stale from iter 1's
  move; resolves on next editor open).
- Reachability oracle (seed 42): byte-identical to iter 0/1 baseline —
  `playable: true, reachable_cells: 804, rows_climbed: 29, tile_hash:
  f873ae60ee3c420c57cdef5762acdad857b1a763ec50b76db80971ef4503e797`.
  Spawner/Enemy are runtime entities; oracle measures generated tiles.

### Scores

| Criterion | Iter 1 | Iter 2 | Δ | Citation |
|-----------|--------|--------|---|----------|
| 1. Core loop closes | 2 | 2 | – | No HP/death yet; anchor 3 unreachable |
| 2. Spawn / wave system | 0 | **1** | +1 | Fixed-rate spawner, random angle around player. `scripts/Spawner.gd:11-30`, `scenes/ProceduralLevel.tscn:91-96` |
| 3. HP + death model | 0 | 0 | – | Player has no HP |
| 4. XP + level-up flow | 0 | 0 | – | – |
| 5. Upgrade variety | 0 | 0 | – | – |
| 6. Enemy variety + behavior | 0 | **1** | +1 | One chaser type, naive move-and-slide AI. `scripts/Enemy.gd:14-19`, `scenes/Enemy.tscn:9-13`. Anchor 1. |
| 7. Run pacing | 0 | 0 | – | – |
| 8. Visual feedback / juice | 0 | 0 | – | – |
| 9. UI / UX | 0 | 0 | – | – |
| 10. Build distinctness | 0 | 0 | – | – |
| **Total** | **2** | **4** | **+2** | |

### Pre-mortem evaluation

All four falsifiable predictions landed exactly. No falsifications. The
real-runtime miss (enemies stuck on walls / spawn in unreachable pockets)
is unverified by automated tests — iter-5 playtest is the falsification
mechanism.

### Files touched

- Created: `scripts/Enemy.gd`, `scripts/Spawner.gd`, `scenes/Enemy.tscn`
- Modified: `scripts/Bullet.gd` (take_damage on body hit),
  `scenes/Bullet.tscn` (mask 1→9), `scenes/ProceduralLevel.tscn`
  (Spawner node + 2 ext_resources, load_steps 15→17),
  `loop/gameplay/PRE-MORTEMS.md`, `loop/gameplay/STATE.md`,
  `loop/gameplay/LEDGER.md`

### Schedule

- Iter 3 candidate = BUILD: HP/death system. PlayerTank + HP, enemy-on-touch
  damage, death triggers run-over state with restart. Lifts crit 3 from 0
  to ~2 (numeric HP, takes damage on collision) and crit 1 from 2 to 3
  (anchor 3 unlocks: player has HP, takes damage, can die). Also probably
  needs a minimal HUD (text-only HP) which seeds crit 9 at 1.
- ScheduleWakeup 240s (BUILD cadence per PROMPT §7)
- PLAYTEST mandatory at iter 5 (3 iters away)

---

## Iter 003 — BUILD — HP + HUD + death/restart

**Mode:** BUILD
**Focus:** crit 3 (HP/death) + crit 9 (text HUD); structural anchor 3 of crit 1 (HP/death in code; playtest rule keeps crit 1 capped at 2)
**Date:** 2026-05-11
**Pre-mortem:** PRE-MORTEMS.md iter 003 (predicted crit 3 → 2, crit 9 → 1, crit 1 holds at 2 per feel-criterion playtest rule; identified HurtBox layer/mask + restart debounce as likely silent bugs)

**Built-in falsification surface:** Mid-iter, an external GPT-Pro
consultation (key `tanke-iter-2-secondopinion`, fired end-of-iter-2 via
agentify) was still pending (~2.5 min into its run) when this commit
landed. Pre-mortem predicts: if Pro's response surfaces material critique
of H1-H5 (substrate-freeze interpretation, pre-mortem credibility, naive
enemy AI, iter-3 scope, silent bugs), iter 4 will integrate. This is the
first iter with an external evidence channel that can falsify the loop's
own scoring.

### Diagnose

Crit 3 (HP) at 0/5; crit 9 (UI) at 0/5. Picked both because HP needs HUD
to register as "feedback" — they're foundational pair. Also unblocks crit
1 anchor 3 structurally (even though playtest rule caps crit 1 at 2).
Decision: dynamic HurtBox + dynamic HUD created from PlayerTank.gd `_ready`
— avoids editing PlayerTank.tscn (still format=2; could risk Bullet-style
migration churn if touched).

### Actions

1. `scripts/PlayerTank.gd` extended:
   - `@export max_hp: int = 3, damage_iframes: float = 0.6`
   - `signal hp_changed(new_hp, max_hp)`, `signal died`
   - `take_damage(amount)` with iframe gate, emits `hp_changed`, calls
     `_die()` on hp ≤ 0
   - `_die()` sets `_dead`, stops sprite, zeros velocity, shows death
     label, emits `died`
   - `_physics_process` returns early if `_dead`, only processes restart
     input
   - `_handle_restart_input()` uses `Input.is_physical_key_pressed(KEY_R)`
     with `_restart_armed` debounce (must release R then press to trigger
     reload; prevents instant-restart if R was already held at death)
   - `_setup_hurtbox()` creates child Area2D with collision_layer=0
     (doesn't push), collision_mask=8 (Enemy), 12×12 RectangleShape2D;
     wired to `_on_hurtbox_body_entered` checking `body.is_in_group("enemy")`
   - `_setup_hud()` creates child CanvasLayer with "HP %d/%d" label and a
     hidden death label; connects `hp_changed` to update the label
2. `scripts/Enemy.gd`: added `add_to_group("enemy")` in `_ready` so the
   HurtBox detection works.

### Substrate freeze check

- All five frozen scripts and the test_runner untouched.
- No .tscn edits this iter (HurtBox + HUD are dynamic in _ready) —
  PlayerTank.tscn (still format=2) avoided to dodge migration risk.

### Verification

- `godot --headless --path . --quit` → exit 0, clean (same cosmetic UID
  carryover warning for Bullet.gd, harmless).
- No oracle re-check needed (no tile-affecting changes; oracle measures
  generated tile grid, not runtime entities). Last green: tile_hash
  f873ae60ee3c420c…, playable: true, reachable_cells: 804.

### Scores

| Criterion | Iter 2 | Iter 3 | Δ | Citation |
|-----------|--------|--------|---|----------|
| 1. Core loop closes | 2 | 2 | – | Anchor 3 in code (`PlayerTank.gd:107-117` take_damage + die); feel criterion playtest rule caps at 2 |
| 2. Spawn / wave system | 1 | 1 | – | unchanged |
| 3. HP + death model | 0 | **2** | +2 | Anchor 2 exact: damage on collision via dynamic HurtBox `PlayerTank.gd:128-140`; HP numerically shown `PlayerTank.gd:148-149`. Not a feel criterion. |
| 4. XP + level-up flow | 0 | 0 | – | – |
| 5. Upgrade variety | 0 | 0 | – | – |
| 6. Enemy variety + behavior | 1 | 1 | – | unchanged |
| 7. Run pacing | 0 | 0 | – | – |
| 8. Visual feedback / juice | 0 | 0 | – | – |
| 9. UI / UX | 0 | **1** | +1 | Anchor 1: text HP visible. `PlayerTank.gd:148`. Feel ≤2 OK with code citation. |
| 10. Build distinctness | 0 | 0 | – | – |
| **Total** | **4** | **7** | **+3** | |

### Pre-mortem evaluation

Pre-mortem-internal: all five predictions landed. Crit 3 → 2, crit 9 → 1,
crit 1 held at 2, boot clean, oracle unchanged (not re-run since no
tile-affecting changes — note this as a small process drift; PROMPT
suggests oracle re-check after any BUILD that "touches level config or
scene structure" — HurtBox is dynamic in code, not scene structure, so
oracle re-check arguably not required, but worth doing in iter 4 for
discipline).

Real falsification risks (deferred):
- iter-5 PLAYTEST: does HP actually drop when enemy touches player? Does R
  actually restart cleanly? Does iframes feel right at 0.6s?
- Pending GPT Pro consult: may surface H5 silent bugs (Timer creation
  order, find_child timing, dynamic-node-in-_ready gotchas).

### Files touched

- Modified: `scripts/PlayerTank.gd` (HP+HUD+death system),
  `scripts/Enemy.gd` (group registration),
  `loop/gameplay/PRE-MORTEMS.md`, `loop/gameplay/STATE.md`,
  `loop/gameplay/LEDGER.md`

### Schedule

- Iter 4 candidate = AUDIT mode (PROMPT §3 calls for AUDIT every 5 iters
  or after substrate change). Iter 4 has two motivations: (a) integrate
  GPT Pro consult response (should be done by then), (b) re-score all
  criteria with fresh evidence including running the oracle again for
  discipline. If Pro flags material H1-H5 issues, iter 4 morphs into a
  targeted BUILD fix.
- ScheduleWakeup 240s (AUDIT cadence is 120s per PROMPT §7 but the
  primary uncertainty is the Pro response — 240s gives Pro time to finish)
- PLAYTEST mandatory at iter 5 (2 iters away — that's when the user F5s)

---
