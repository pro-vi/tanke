# tanke — Gameplay Loop State

## Phase

```
phase: loop
iteration: 0
preloop_complete: yes
```

---

## Preloop Checklist (cleared iter 0)

```
[x] F5 the scene; tank moves with WASD/arrows (user-confirmed iter 0)
[x] Scene loads without console errors (headless --quit exit 0, clean output)
[x] Reachability oracle reports playable: true (seed 42: reachable_cells=804, rows_climbed=29)
[x] project.godot run/main_scene flipped Level.tscn → ProceduralLevel.tscn (iter 0 preloop fix)
[~] Shooting KNOWN BROKEN — iter 1's job
```

---

## Substrate baseline (recorded iter 0)

Active scene config: `configs/playable.tres`
- empty 0.55 / brick 0.18 / steel 0.07 / grass 0.12 / water 0.08
- merge_probability 0.4
- Reachability at seed 42: reachable_cells **804**, rows_climbed **29**, **playable: true**
- Hash anchor (seed 42): `f873ae60ee3c420c57cdef5762acdad857b1a763ec50b76db80971ef4503e797`
- Engine-loop historical anchors for reference only: `6159ef2f5464edb1`, `1f80435080844dce` (post-iter-21), `8a4834679f9e4eb2` (biome_balanced)

Substrate freeze rule per `PROMPT.md`: do not modify `LevelConfig`,
`BiomeConfig`, `LevelDNA`, `ProceduralStep`, `ProceduralLevel` (the
procedural generation logic). Add new configs/scripts/scenes as needed.

---

## Current Scores

(Set at iter 1+ after BOOTSTRAP.)

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Core loop closes | 0 | Shooting broken (Bullet.tscn missing script) |
| 2. Spawn / wave system | 0 | No enemies yet |
| 3. HP + death model | 0 | No HP system |
| 4. XP + level-up flow | 0 | No XP |
| 5. Upgrade variety | 0 | No upgrades |
| 6. Enemy variety | 0 | No enemies |
| 7. Run pacing | 0 | No run structure |
| 8. Visual feedback / juice | 0 | None |
| 9. UI / UX | 0 | No HUD |
| 10. Build distinctness | 0 | No builds |
| **Total** | **0/50** | Floor |

---

## Open seams (iter 1+ priorities)

1. **Bullet system broken.** `Bullet.tscn` is in Godot 3 format; `res://Bullet.gd`
   doesn't exist. Tank fires the signal, level handler instantiates a
   scriptless `Area2D`, calls `b.start(pos, dir)` which errors. Iter 1 must:
   - Migrate `Bullet.tscn` to format 3
   - Fix `extents = Vector2(...)` → `size = Vector2(...)` on RectangleShape2D
   - Write `scripts/Bullet.gd` with `start(pos, dir)`, `_physics_process`,
     `_on_area_entered`, `_on_lifetime_timeout`
   - Verify via headless boot + visual playtest

2. **No enemies.** Major iter-2+ work — Enemy.tscn, Enemy.gd, basic chaser AI.

3. **No HP system.** PlayerTank.gd has no HP variable; no damage handling.

4. **No HUD.** No CanvasLayer with HP/XP/timer.

5. **No XP / level-up.** Major iter-3+ work.

6. **No upgrade pool.** Foundational for criterion 5.

---

## Last Action

```
Iter 0 BOOTSTRAP complete. Preloop cleared (user F5 confirmed WASD/arrows).
project.godot main_scene flipped to ProceduralLevel.tscn so F5 lands on the
gameplay scene. Substrate baseline recorded (hash anchor f873ae60ee3c420c).
Next: iter 1 BUILD — fix the Bullet system per open seam #1.
```

---

## Stale Scores

None (new loop).

---

## Next Action

`Iter 1 BUILD — Bullet system:
  - Pre-mortem to PRE-MORTEMS.md
  - DIAGNOSE: weakest axis is criterion 1 (core loop closes), 0/5 — shooting broken
  - Write scripts/Bullet.gd: start(pos, dir), _physics_process movement,
    area_entered → despawn, lifetime timeout
  - Migrate scenes/Bullet.tscn format=2 → format=3
  - Fix extents → size on RectangleShape2D in Bullet.tscn
  - Headless smoke: godot --quit clean; oracle still playable: true
  - Score (criterion 1 should land at 1 or 2 depending on collision visibility)
  - Commit; ScheduleWakeup 240s (BUILD cadence per PROMPT §7)`

---

## User-Look Gates

Per PROMPT user-look protocol:
- **Iter 5** (or first iter where shoot+move+enemies all work): mandatory PLAYTEST
- **Every 3 iters thereafter**: mandatory PLAYTEST
- **Halt rule**: 3 consecutive unfulfilled PLAYTEST requests → write `HALTED.md`, stop

The engine loop's biggest miss was 8 iters of open user-look gate without
enforcement. This loop halts hard at +3.

---

## Consult Log

None. First consult: iter 10. (External agentify failed twice in engine loop;
self-pre-mortem-in-writing is the proven fallback per iter-21 evidence.)

---

## Pre-mortems

`loop/gameplay/PRE-MORTEMS.md` — append-only record of each iter's "what I
expect this iter's biggest miss to be" prediction. Created at iter 1.

---

## Falsifications

`loop/gameplay/FALSIFICATIONS.md` — when user reaction contradicts a
pre-mortem, log it. The engine loop accumulated 4; expect more here on feel
axes where automated metrics can't help.
