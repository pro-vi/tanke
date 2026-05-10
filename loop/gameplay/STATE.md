# tanke — Gameplay Loop State

## Phase

```
phase: preloop
iteration: 0
preloop_complete: no
```

---

## Preloop Checklist

```
[ ] F5 the scene; confirm tank moves with WASD/arrows
[ ] Confirm scene loads without console errors (godot --quit returns 0)
[ ] Confirm reachability oracle reports playable: true:
    godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --json | grep '^{' | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d['playable'])"
[ ] Note: shooting is KNOWN BROKEN (Bullet.tscn format=2, no Bullet.gd) — that's iter 1's job, not preloop's.
[ ] Flip preloop_complete: yes above
```

---

## Substrate baseline (iter 0 will record)

Active scene config: `configs/playable.tres`
- empty 0.55 / brick 0.18 / steel 0.07 / grass 0.12 / water 0.08
- merge_probability 0.4
- Reachability at seed 42: reachable_cells 804, rows_climbed 29, **playable: true**
- Hash anchor for this config + scene at seed 42: (iter 0 records)

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
Loop initialized iter 0. Engine loop archived at loop/* (50/55, paused).
Substrate freeze in effect. User-look is mandatory iter 5 / every 3 after.
First task post-bootstrap: fix Bullet system (criterion 1 baseline).
```

---

## Stale Scores

None (new loop).

---

## Next Action

`Iter 0 BOOTSTRAP:
  - Verify reachability oracle reports playable: true on active scene
  - Record baseline tile_hash + reachable_cells in LEDGER iter 000
  - Read META-RETRO "What survives past the loop" section (substrate map)
  - Commit "chore(gameplay): iter 000 — BOOTSTRAP — substrate confirmed"
  - Schedule iter 1 (BUILD: fix Bullet system)`

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
