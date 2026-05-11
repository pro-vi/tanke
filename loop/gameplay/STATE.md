# tanke — Gameplay Loop State

## Phase

```
phase: loop
iteration: 8
preloop_complete: yes
playtest_requested_iter: 5
playtest_completed_iter: 6
design_direction: battle_city (user playtest signal — see FALSIFICATION 003)
next_playtest_due_iter: 9
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

**H1 tripwire (added iter 4 per GPT-Pro consult — see creative-consults.md):**
the literal-reading defense for `scenes/ProceduralLevel.tscn` ("only the
.gd is frozen") is *too convenient*. Per Pro: "the active procedural scene
is still the substrate fixture. Adding gameplay systems directly into it
blurs engine substrate and gameplay layer — the iter-28 failure mode in
softer form." Adopted stance: **≤3 gameplay-only sibling nodes** may live
inside ProceduralLevel.tscn before a mandatory refactor to either (a) a
`GameplayLayer` Node2D child that contains them all, or (b) a parent
scene `scenes/GameplayLevel.tscn` that instances ProceduralLevel.tscn.
Current count: 1 (Spawner). HurtBox + HUD are dynamic-in-PlayerTank and
don't count against this tripwire. Tripwire trigger likely iter 5-7.

---

## Current Scores

(Set at iter 1+ after BOOTSTRAP.)

| Criterion | Score | Notes |
|-----------|-------|-------|
| 1. Core loop closes | **4** | Iter 6: playtest-cited anchor 4 ("death triggers clear run over with restart"). Capped at 4 — anchor 5 needs first-run-without-instruction. |
| 2. Spawn / wave system | 1 | Iter 2: fixed-rate. User playtest: pattern wrong (radial, should be top-edge). Iter 7 work. |
| 3. HP + death model | 2 | Iter 3: HurtBox + HP numerically shown; playtest-confirmed iter 6. Anchor 3 needs HP bar. |
| 4. XP + level-up flow | 0 | No XP |
| 5. Upgrade variety | 0 | No upgrades |
| 6. Enemy variety | 1 | Iter 2: one chaser, naive AI. User: "skiing without constraints" — wants 4-dir grid like player. Iter 7. |
| 7. Run pacing | 0 | No run structure |
| 8. Visual feedback / juice | 0 | None; iter-6 playtest flagged "bullet off-center" polish gap |
| 9. UI / UX | 1 | Iter 3: text HP HUD via CanvasLayer Label; playtest-confirmed iter 6 |
| 10. Build distinctness | 0 | No builds |
| **Total** | **9/50** | Iter 6 +2 via playtest cite on crit 1 |

---

## Open seams (iter 7+ priorities)

Closed in prior iters: 1-bullet, 2-enemies-exist, 3-HP, 4-HUD-text,
7-death/restart, 8-pro-consult. See LEDGER history.

### From iter-5 user playtest (NEW, highest priority for iters 7-8)

**A. Enemy AI: "skiing without constraints"** — user wants 4-dir grid
movement like the player (snap to grid on turn, U/D/L/R only). Currently
naive `move_and_slide` produces continuous diagonal motion. *Iter 7
BUILD.* Lifts crit 6.

**B. Enemy fire** — user wants enemies to fire bullets in their facing
direction (Battle City convention). Currently enemies only deal contact
damage. *Iter 7 BUILD.* Lifts crit 6 toward anchor 2 (ranged-shooter
type).

**C. Top-edge enemy spawn** — user wants Battle City-style spawn pattern
(enemies enter from top of map and push down) instead of radial-around-
player. *Iter 7 BUILD.* Lifts crit 2 toward anchor 2/3.

**D. Brick destructibility** — user: "doesnt break brick wall." Battle
City convention: bullets break bricks (1-2 hits), can't break steel.
Currently bullets queue_free on hit without affecting brick. *Iter 8
BUILD.* Lifts crit 8 (visual feedback) and crit 1 (core loop satisfaction).

**E. Bullets pass over water** — user: "doesnt travel over water." Water
should block tanks but not bullets. Currently WaterBlock collision_layer=513
includes layer 1, Bullet mask=9 includes layer 1, so bullet collides.
Fix: WaterBlock layer or Bullet mask. *Iter 8 BUILD.* Lifts crit 1.

**F. Muzzle/bullet centering** — user: "bullet can spawn off center."
PlayerTank's `$Muzzle` position is Vector2(7, 0); after `set_rotation`
on direction change, muzzle may not align visually with sprite center.
*Iter 8 BUILD.* Polish/crit 8.

### Pre-existing seams (still open)

5. **No XP / level-up.** Foundational for crit 4 + 5. Iter 9+.
6. **No upgrade pool.** Foundational for crit 5 + 10. Iter 9+.
9. **No visual juice.** Crit 8. Hit-flash on damage / impact spark.
   Tied to D (brick break).
10. **No iframes visual indication.** Player can't see invincibility
    window. Tied to 9.
11. **Design direction explicit lock?** Currently `design_direction:
    battle_city` per user playtest signal. Document explicitly if user
    confirms; pivot if user prefers VS-like.

---

## Last Action

```
Iter 8 BUILD complete. Bullet/terrain (Battle City direction part 2):
- BrickBlock.gd: max_hp=1, take_damage queue_frees brick. Bullet's
  body_entered already calls take_damage (iter-2 work); destruction is
  automatic once method exists.
- Bullets-over-water via synchronized 3-file collision-layer changes:
  * WaterBlock.tscn collision_layer 513 → 512 (Water-only; removed
    Environment bit 1)
  * Enemy.tscn collision_mask 1 → 513 (Environment + Water, must still
    block enemies from water)
  * Spawner.gd _is_blocked mask 1 → 513 (won't spawn on water either)
- Final collision graph: bullet mask 9 (Env+Enemy) excludes water layer
  512 → bullets pass water; tank mask 513 (Env+Water) still blocked.
- Muzzle: sprites_0.png is 16px per frame (verified via PIL: 256/16=16);
  muzzle (7,0) was 1px INSIDE sprite edge — read as off-center. Fixed
  to (8,0) = sprite-edge exactly.
- Verified: make test exit 0, oracle tile_hash f873ae60ee3c420c…
  unchanged. Substrate intact iters 1-8.
- Scores unchanged at 9/50. Multiple anchors poised to lift on iter-9.
Next: iter 9 PLAYTEST — mandatory user-look gate.
```

---

## Stale Scores

None (new loop).

---

## Next Action (current, replacing iter-7 plan that was just shipped)

`Iter 9 PLAYTEST (mandatory user-look gate, paired iter-7 + iter-8 changes):
  - Pre-mortem to PRE-MORTEMS.md — must include H2-RULE
    independently observable claims about user playtest report
  - Verify build runs: make test clean, godot --quit exit 0
  - Capture run config (deltas since iter-5 playtest):
    * Enemy grid AI: 4-dir cardinal, direction_commit_time=0.8s
    * Enemy fire: bullets every 1.5s in facing direction, mask=3 (hits player + env)
    * Spawn: top-edge (y = player.y - 144), random x ∈ [4, 316]
    * Brick walls: destructible (1 hit per 8×8 cell)
    * Water: bullets pass over, tanks blocked
    * Muzzle: aligned with sprite edge (8, 0)
  - Output to user: "Please play one F5 run (~1-2 min). Specifically
    observe these SEVEN things, focused on whether iter-7/8 fixes work:
    1. ENEMIES — grid-aligned 4-dir motion like the player? Or still
       skiing diagonally?
    2. ENEMIES SHOOT — do enemies fire bullets at you?
    3. SPAWN POSITION — enemies appear from above (top of screen),
       not random around you?
    4. BRICK WALLS — can you destroy brick walls by shooting them?
    5. WATER — do bullets pass over water now (not blocked at water
       edge)?
    6. MUZZLE — do bullets now start visually aligned with the tank
       (not off-center)?
    7. ANY OTHER — what felt off / surprising / broken?"
  - AWAIT user response. No scheduled retry per PROMPT §7.
  - Halt rule: if 3 subsequent iters pass without user playtest
    response (iter 12), write HALTED.md and stop.
  - On response: iter 10 evaluates the claims, logs falsifications,
    scores update (multiple anchors poised to lift — crit 6, crit 8,
    crit 2, crit 1 → 5). Iter 10 is also CONSULT iter per PROMPT
    §"CONSULT SCHEDULE" (iter 10/20/30) — combine with playtest eval.`

---

## Previous Next Action (iter 8 — shipped iter 8)

`Iter 8 BUILD — Bullet/terrain (Battle City direction part 2):
  - Pre-mortem (H2 RULE: ≥1 independently observable claim about
    iter-9 playtest result)

  D. Brick destructibility:
     - BrickBlock.gd: add @export max_hp: int = 1 (Battle City: 1 hit)
     - take_damage(amount) decrements hp, queue_free on 0
     - Bullet.gd already calls body.take_damage if has_method, so brick
       death is automatic once take_damage exists
     - Optional: hit-flash via modulate tween (crit 8 anchor 1)
  E. Bullets over water:
     - Either: WaterBlock.collision_layer 513 → 512 (remove layer 1)
       — but then tanks can drive through water too. Bad.
     - Better: use a dedicated layer for "bullet-blockable" vs
       "tank-blockable". Layer 10 (Water) is already named for water in
       project.godot. Set WaterBlock layer to 1024 only (no layer 1).
       Bullet mask=9 doesn't include 1024 → passes over water. Tank
       mask=513 includes 1+512=513 — wait 1024 not 512.
     - Let me re-read project.godot layer_names:
       2d_physics/layer_1="Environment"
       2d_physics/layer_2="Player"
       2d_physics/layer_10="Water"
       So layer 10 = value 1<<9 = 512. WaterBlock layer 513 = 1+512.
       Tank mask 513 = layer 1 + layer 10. Tank blocked by water (via
       layer 10) AND environment (via layer 1).
     - Plan: WaterBlock layer 513 → 512 (remove layer 1). Tank mask 513
       still includes layer 10 (water=512) → tank still blocked. Bullet
       mask 9 doesn't include 512 → bullet passes water. ✓
  F. Muzzle centering:
     - PlayerTank.tscn: Muzzle position Vector2(7, 0) → Vector2(8, 0)
       or align with sprite center. Test visually (deferred to playtest)
     - Or: compute muzzle offset in PlayerTank.gd _fire() relative to
       sprite center, ignoring scene-set Marker2D position.

  - Headless smoke + oracle re-check (substrate)
  - Score predictions: crit 1 → 5 maybe (Battle City full feel),
    crit 8 → 1 (brick hit-flash visible), crit 1 anchor 5 still capped
    without playtest. Honest: crit 8 → 1, others unchanged till iter 9.
  - Commit; ScheduleWakeup 240s
  - Iter 9 = PLAYTEST (user-look gate, requesting playtest of iters
    7+8 changes)

H1 tripwire: 0 new gameplay siblings in ProceduralLevel.tscn. Count: 1.`

---

## Previous Next Action (iter 7 — shipped iter 7)

`Iter 7 BUILD — Enemy refactor (Battle City direction):
  - Pre-mortem (H2 RULE: ≥1 independently observable claim about user
    report at iter 9 or wherever next playtest lands)
  - DIAGNOSE: weakest user-experience axis is "skiing without constraints"
    (FALSIFICATION 002). Refactor Enemy.gd from continuous chaser to
    4-dir grid mover matching PlayerTank's movement model.

  A. Enemy.gd grid AI:
     - Add direction var (Constants.Dir enum: U/D/L/R)
     - Pick nearest cardinal direction toward player; reconsider on
       wall collision or every ~1s
     - move via move_and_collide with cardinal velocity (no normalize +
       slide); snap to grid on turn like player
     - Rotate sprite via set_rotation(Constants.dir_to_rotation(dir))

  B. Enemy fire:
     - Reuse Bullet.tscn (don't fork yet — generalize via collision_layer
       on bullet to distinguish friend/foe)
     - Add @export var fire_cooldown: float = 1.5
     - On _physics_process: if cooldown expired and facing direction has
       a line-of-sight to player (raycast or just fire on cadence), emit
       a bullet at muzzle position with current direction
     - Enemy bullets need collision_mask that includes player layer (2)
       and excludes enemy layer (8). Either: separate EnemyBullet.tscn
       (cleaner), or: Bullet.gd grows a "shooter_layer" param. Pick
       cleaner: new scenes/EnemyBullet.tscn that reuses scripts/Bullet.gd
       with different masks; OR refactor Bullet.tscn collision to be
       set on instantiate.
     - Decision: cleanest is to NOT fork — pass mask in start(). Bullet.gd
       gains `start(pos, dir, mask)` with mask param; collision_mask set
       at instantiation time.

  C. Spawner refactor — top-edge spawn:
     - Replace random-angle-around-player with top-edge sampling
     - Spawn position: x ∈ [4, 316] random, y = camera_top - 24 (just
       off-screen above viewport)
     - Keep H5 #2 reachability check (don't spawn inside walls)
     - Increase spawn_distance not needed; top-edge spawn is by-design
       further from player than radial-120

  - Headless smoke + oracle re-check (should still match f873ae60…)
  - Score predictions: crit 6 1 → 2 (chaser + ranged-shooter anchor 2),
    crit 2 1 → 2 (varying intervals + multiple spawn points... actually
    fixed interval, top-edge only is single direction so maybe stays 1
    or hits anchor-2 "multiple spawn points" if x varies — yes x varies
    along the top edge, so anchor 2 OK). Crit 7 might hit 1.
  - Commit; ScheduleWakeup 240s
  - Iter 8 = BUILD (bullet/terrain): brick destruction, water pass,
    muzzle centering
  - Iter 9 likely = PLAYTEST (iter 5 + 3 = 8 was when next would be due,
    but iter 7+8 are BUILD; iter 9 PLAYTEST is the next mandatory
    user-look gate per "every 3 iters after iter 5")

H1 tripwire: adding 0 new gameplay siblings to ProceduralLevel.tscn
(Spawner already exists, refactoring its behavior is fine). HurtBox/
HUD/Bullet additions are dynamic or contained. Count stays at 1.`

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
