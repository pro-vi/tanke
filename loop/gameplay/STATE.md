# tanke — Gameplay Loop State

## Phase

```
phase: loop
iteration: 2
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
| 1. Core loop closes | 2 | Bullet system fixed iter 1; bullets hit enemies iter 2. Anchor 3 (death) needs HP. Capped — feel criterion needs playtest for >2. |
| 2. Spawn / wave system | 1 | Iter 2: fixed-rate spawner, random angle around player |
| 3. HP + death model | 0 | No HP system |
| 4. XP + level-up flow | 0 | No XP |
| 5. Upgrade variety | 0 | No upgrades |
| 6. Enemy variety | 1 | Iter 2: one chaser type, naive move-and-slide |
| 7. Run pacing | 0 | No run structure |
| 8. Visual feedback / juice | 0 | None |
| 9. UI / UX | 0 | No HUD |
| 10. Build distinctness | 0 | No builds |
| **Total** | **4/50** | Iter 2 +2 (enemies online) |

---

## Open seams (iter 3+ priorities)

1. ~~**Bullet system broken.**~~ ✓ Fixed iter 1. Real visual validation
   still pending iter-5 playtest.

2. ~~**No enemies.**~~ ✓ Iter 2: chaser + spawner online. Open runtime
   risks (predicted iter-2 pre-mortem): (a) enemies stuck on walls via
   naive move-and-slide, no pathfinding; (b) spawn positions occasionally
   land in BFS-unreachable pockets (~33% of map). Both deferred to iter 5
   playtest for falsification.

3. **No HP system.** PlayerTank.gd has no HP variable; no damage handling.
   Iter-3 work. Unblocks crit 1 anchor 3 (HP/death) and crit 3.

4. **No HUD.** No CanvasLayer. Likely seeds in iter 3 alongside HP
   (text-only HP display = crit 9 anchor 1).

5. **No XP / level-up.** Major iter-4+ work. Foundational for crit 4 + 5.

6. **No upgrade pool.** Foundational for criterion 5 and 10.

7. **No death/restart flow.** Once HP exists, need "you died" state with
   restart. Crit 1 anchor 4 + crit 3 anchor 3.

---

## Last Action

```
Iter 2 BUILD complete. Enemies + Spawner online:
- scripts/Enemy.gd: CharacterBody2D chaser, move_and_slide toward player
- scripts/Spawner.gd: scene-resident, 2s fixed interval, random angle 120px
  from player, max 20 alive
- scenes/Enemy.tscn: collision_layer=8, mask=1; sprite from sprites_0.png frame=16
- scenes/ProceduralLevel.tscn: added Spawner node (only the .gd is frozen)
- scripts/Bullet.gd: _on_body_entered calls take_damage on hit
- scenes/Bullet.tscn: mask 1 → 9 (Environment + Enemy)
Headless boot clean; oracle byte-identical to baseline.
Criteria 2 → 1, 6 → 1; crit 1 holds at 2. Total 4/50.
Next: iter 3 BUILD — HP/death system (unlocks crit 1 anchor 3, lifts crit 3).
```

---

## Stale Scores

None (new loop).

---

## Next Action

`Iter 3 BUILD — HP + minimal HUD:
  - Pre-mortem to PRE-MORTEMS.md
  - DIAGNOSE: weakest axes are criteria 3, 4, 5, 7, 8, 9, 10 at 0/5.
    Pick crit 3 (HP/death) + crit 9 (UI) — pair because HP needs display
    to register as "feedback". Also unblocks crit 1 anchor 3 (player has
    HP, can die).
  - PlayerTank.gd: add max_hp/hp vars, take_damage(amount), death state.
    On death: emit died signal, queue_free or set a "dead" flag.
  - Add HitBox area (or use body_entered on PlayerTank's CharacterBody)
    so enemies passing over the player deal damage. Cooldown timer to
    prevent every-frame damage.
  - Enemy.gd: on touching player (overlap or body_entered) → call player.take_damage(1)
  - Minimal HUD: CanvasLayer with HP label. Text-only (crit 9 anchor 1).
  - Death: show "YOU DIED" + "[R] restart" label. R reloads scene.
  - Headless smoke + oracle re-check (oracle is tile-only; should still
    match f873ae60…).
  - Score: crit 3 → 2 (numeric HP, takes damage), crit 1 → 3 (HP+death,
    capped at 3 without playtest — feel criterion), crit 9 → 1
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
