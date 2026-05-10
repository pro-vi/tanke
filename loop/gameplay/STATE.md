# tanke — Gameplay Loop State

## Phase

```
phase: loop
iteration: 1
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
| 1. Core loop closes | 2 | Bullet system fixed iter 1; collisions register on terrain. Capped — feel criterion needs playtest for >2. |
| 2. Spawn / wave system | 0 | No enemies yet |
| 3. HP + death model | 0 | No HP system |
| 4. XP + level-up flow | 0 | No XP |
| 5. Upgrade variety | 0 | No upgrades |
| 6. Enemy variety | 0 | No enemies |
| 7. Run pacing | 0 | No run structure |
| 8. Visual feedback / juice | 0 | None |
| 9. UI / UX | 0 | No HUD |
| 10. Build distinctness | 0 | No builds |
| **Total** | **2/50** | Iter 1 lifted criterion 1 off the floor |

---

## Open seams (iter 2+ priorities)

1. ~~**Bullet system broken.**~~ ✓ Fixed iter 1. Open follow-up:
   playtest at iter 5 will validate the bullet actually visibly travels and
   despawns at runtime (only code-verified so far). Visual juice (impact
   spark, muzzle flash) deferred to a later iter when bullets actually
   collide with enemies (more rewarding signal source).

2. **No enemies.** Iter-2 work — `scenes/Enemy.tscn`, `scripts/Enemy.gd`,
   basic chaser AI. Gives bullets a visible target and creates the threat
   side of the core loop. Lifts criterion 2 (spawn) and 6 (enemy variety).

3. **No HP system.** PlayerTank.gd has no HP variable; no damage handling.
   Foundational for criterion 3 and for "death ends run" of criterion 1.

4. **No HUD.** No CanvasLayer with HP/XP/timer.

5. **No XP / level-up.** Major iter-3+ work.

6. **No upgrade pool.** Foundational for criterion 5.

---

## Last Action

```
Iter 1 BUILD complete. Bullet system fixed:
- Moved Bullet.gd repo root → scripts/Bullet.gd (typed GDScript)
- Migrated Bullet.tscn format 2 → 3 (extents → size, ext_resource syntax)
- Added body_entered handler so terrain StaticBody2Ds despawn bullets
- collision_mask=1 hits Environment; speed=120 px/s, lifetime=2s
Headless boot clean; oracle unchanged (tile_hash f873ae60…, playable: true).
Criterion 1: 0 → 2 (capped without playtest). Total 2/50.
Next: iter 2 BUILD — enemies (gives bullets a visible target, lifts crit 2+6).
```

---

## Stale Scores

None (new loop).

---

## Next Action

`Iter 2 BUILD — Enemies (basic chaser):
  - Pre-mortem to PRE-MORTEMS.md
  - DIAGNOSE: weakest axes are criteria 2, 3, 4, 5, 6, 7, 8, 9, 10 all at 0/5.
    Pick criterion 2 (Spawn) + 6 (Enemy variety) — both lift with one BUILD,
    and enemies create a visible target for iter-1's bullet collisions.
  - Write scripts/Enemy.gd: CharacterBody2D, move_toward(player), collision
    with bullet → queue_free, collision with player → no damage yet (HP iter)
  - Write scenes/Enemy.tscn: format 3, sprite frame from existing sprite sheet,
    CollisionShape2D, collision_layer = 8 (Enemy), mask = 1 + 4 (Environment + Bullet)
  - Write scripts/Spawner.gd or inline into ProceduralLevel: spawn 1 enemy per
    N seconds at off-camera positions. Start with fixed rate (anchor 1 of crit 2).
  - Make sure Bullet collision mask includes layer 8 (Enemy) so bullets stop on hit
    — update scenes/Bullet.tscn collision_mask 1 → 1+8 = 9
  - Headless smoke + oracle re-check
  - Score (target: crit 2 → 1, crit 6 → 1; crit 1 holds at 2)
  - Commit; ScheduleWakeup 240s`

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
