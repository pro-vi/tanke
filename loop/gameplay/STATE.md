# tanke — Gameplay Loop State

## Phase

```
phase: loop
iteration: 19
preloop_complete: yes
last_completed_playtest_iter: 17
design_direction: roguelike_vertical_ascender_with_battle_city_combat_feel
next_playtest_due_iter: 33
consult_cadence: every 5 iters (iter 20, 25, 30)
sprint_phase: A (visual juice, iters 19-23)
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
| 1. Core loop closes | 4 | Iter 6 playtest-cited anchor 4 |
| 2. Spawn / wave system | 1 | Iter 7 top-edge spawn; pattern still single-direction (interval fixed) |
| 3. HP + death model | 2 | Iter 3 HurtBox + HP shown; anchor 3 needs HP bar |
| 4. Depth feedback + ascent pressure (was XP) | **2** | Iter 15 playtest cite "feels like a run" satisfies anchor 2 (DEPTH+TIME live update) |
| 5. Forward survivability (was Upgrade variety) | **1** | Iter 12 anchor 1 met: fire-while-moving + spawn-ahead-of-velocity = enemies don't reliably block ascent |
| 6. Enemy variety | **2** | Iter 16: Light + Heavy types (70/30 weighted) — distinct sprite, speed, HP, fire cooldown. Anchor 2 BC-aligned. |
| 7. Compulsion loop (was Run pacing) | 0 | Needs playtest |
| 8. Visual feedback / juice | **1** | Iter 19: player hit-flash red + iframe blink Tween |
| 9. UI / UX | 1 | Iter 3 text HUD; iter 11 added DEPTH/TIME labels |
| 10. Run summary + replayability (was Build distinctness) | **1** | Anchor 1 met retroactively iter 3 (YOU DIED + R) |
| **Total** | **15/50** | Iter 19 +1 (crit 8 anchor 1 — hit flash) |

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
Iter 19 BUILD complete. Player hit-flash + iframe blink:
- PlayerTank.gd: take_damage (non-lethal) → _start_hit_flash() Tween:
  red pulse (0.08s) → 3× dim/normal blink cycles (0.48s) → restore.
  Total ~0.56s matches damage_iframes window.
- _update_forest_hide gated on _is_flashing to prevent alpha-write
  collision with the tween.
- Verified: make test exit 0, oracle tile_hash f873ae60ee3c420c… unchanged.
- Crit 8 (Visual feedback) 0 → 1 (anchor 1 hit-flash). Total 14 → 15/50.

Next: iter 20 CONSULT (PROMPT §10/20/30, user's 5-iter cadence).
```

---

## Stale Scores

None (new loop).

---

## Next Action

`Iter 20 CONSULT (PROMPT §"CONSULT SCHEDULE" iter 10/20/30 + user's 5-iter cadence):
  - Pre-mortem (H2 RULE — claims about Pro's response language)
  - Fire /agentify with current state, ask for creative direction.
  - Questions:
    1. What's seductive-but-hollow about the current 15/50 playable thing?
       (Pro v1 question from PROMPT §CONSULT SCHEDULE — reframed for
       roguelike-ascender stone)
    2. Is the iter-16 enemy variety (Light/Heavy) doing real work, or is
       it cosmetic distinction? What would make the two types FEEL
       different beyond stats?
    3. Crit 6 anchor 2 wording "chaser + ranged-shooter" is VS-style.
       BC-aligned reading was used. Should rubric be reworded to
       fast/light + slow/heavy?
    4. What's the highest-leverage feature for iters 21-32 (before next
       playtest)? Options on my plan: enemy death particles, brick
       destruction visuals, death-screen run summary, run-best persist,
       kill counter on HUD, third enemy type, power-up prototype.
  - Inline all relevant files (PROMPT.md, RUBRIC.md, STATE.md, LEDGER iter
    16-19, FALSIFICATIONS.md, ALL .gd scripts, ALL .tscn scenes per
    F001 lesson). Lesson F001: include .tscn for collision-related q's.
  - fireAndForget: true. Read response in iter 21.

Iter 21+ adjusts per Pro's response.`

---

## Previous Next Action (iter 19 — shipped)

`Iter 19 BUILD — Player hit-flash + iframe blink (visual juice):
  - Pre-mortem (H2 RULE — claims about iter-33 playtest, not immediate)
  - DIAGNOSE: crit 8 (Visual feedback / juice) at 0/5. Anchor 1 "Hit
    flashes one color." Player has iframes (0.6s) after take_damage but
    no visual signal — feels like nothing happens on hit.
  - PlayerTank.gd take_damage flow:
    * On take_damage (non-lethal): start a brief tween that modulates
      sprite red→white→red→white→normal over the iframe period
    * Visual: red flash on hit, blinking during iframes for visibility
  - Headless smoke + oracle re-check
  - Score predictions: crit 8 0 → 1 (anchor 1 "Hit flashes one color")
    code-citable
  - Commit; ScheduleWakeup 240s

Iter 20 = CONSULT (PROMPT §10/20/30 + user's 5-iter cadence):
  - Fire /agentify with current state, ask for creative direction.
  - Question themes:
    * Anything seductive-but-hollow about the playable thing?
    * Should iter 21+ continue Phase A (visual juice) or shift focus?
    * Rubric anchor 2 wording for crit 6 ("chaser + ranged-shooter")
      is VS-style; should it be BC-aligned-renamed?
    * What's the single most likely thing missing for the
      first-60-seconds-unmistakably-roguelike-ascender test at iter 33?

Iter 21 onwards: follow Pro v2 path; re-plan after each consult.`

---

## Previous Next Action (iter 17 — playtest implicit landed)

`AWAITING user playtest response.

On response (iter 18):
  - Evaluate 5 H2-RULE claims (LANDED / FALSIFIED / INDETERMINATE)
  - Log F005+ for any falsification (especially sprite_base_frame=32
    if it lands on non-tank graphic)
  - Update scores per claim outcomes — potential lifts:
    * Crit 6 anchor 2 confirmed via playtest cite (if claim 1)
    * Crit 4 anchor 4 unlocked (if claim 3)
    * Crit 7 anchor 3 unlocked (if claim 4)
  - Iter 19 BUILD targeting whatever surfaces (likely visual juice
    or power-up prototype if no major bug; iter-16 sprite fix if
    claim 5 falsifies)
  - Iter 20 = CONSULT (PROMPT §"CONSULT SCHEDULE" 10/20/30). Suggested
    questions:
    * The rubric anchor 2 wording for crit 6 is "chaser + ranged-
      shooter" (VS-style). BC-aligned reading was used for iter 16
      score. Should the rubric be updated to BC-aligned wording for
      crit 6, similar to iter 11's rename of crits 4/5/7/10?
    * Where's next on the roguelike-ascender axis after enemy
      variety and depth feedback?
    * Anything seductive-but-hollow about the current playable thing?

If no user response by end-of-iter-20: write HALTED.md per PROMPT
§"USER-LOOK PROTOCOL" halt rule; stop.`

---

## Previous Next Action (iter 17 — shipped as this playtest prompt)

`Iter 17 PLAYTEST — verify F004 fix + enemy variety:
  - Pre-mortem (H2 RULE — reference-language predictions, NARROWER list
    than iter 14: ask 5-6 things max so user can answer all)
  - Verify build: make test + godot --quit exit 0
  - Capture run config deltas since iter 14:
    * F004 fix: spawn position now relative to effective camera (no
      more middle-screen spawns)
    * Enemy variety: 2 types (Light fast/fragile, Heavy slow/tough)
  - Output playtest prompt to user. AWAIT. Halt rule iter 20.

NARROWER iter-17 questions (lessons from iter-14's 10-question report
where user answered 4):
  1. Do enemies now appear from the TOP EDGE (driving in), not the
     middle? (F004 verification)
  2. Do you see TWO different enemy types? Describe what's different
     about them (color, speed, toughness, fire rate)?
  3. Does stalling (standing still) increase spawn rate noticeably?
     (iter-12 unverified)
  4. After dying, do you press R quickly? (iter-11 compulsion signal,
     unverified)
  5. Any new bugs or surprises from the recent changes?

Score-target predictions:
  - Crit 6 anchor 2 confirmed → 2 stays. If user notices behavior
    distinction, doesn't lift further.
  - Crit 7 anchor 3 ("user presses R within 5s of death") if claim 4
    lands → 3.
  - Crit 4 anchor 4 (stalling pressure) if claim 3 lands → 4.

Previous Next Action (iter 15 — shipped iter 16 BUILD):
  Original plan was "pick highest-leverage." Picked enemy variety.`

---

## Previous Next Action (iter 15 — implemented as iter 16)

`Iter 16 BUILD — pick highest-leverage user-facing gap:

Option A: Enemy variety (second enemy type)
  - Add a second tank type: e.g., "armored" (faster bullets, 2 HP) or
    "scout" (fast, fragile, 1HP, faster movement)
  - Lifts crit 6 anchor 2 ("Two types: chaser + ranged-shooter")
  - Once anchor 2 met, anchors 3-5 reachable (anchor 5 "they don't get
    stuck" already arguably met per user "they do better now")

Option B: Visual juice (hit flash on player damage)
  - Tween modulate red on take_damage; brief shake on hit
  - Lifts crit 8 anchor 1 ("Hit flashes one color")

Option C: Power-up prototype
  - BC helmet pickup: drops from random enemy kill; 10s invincibility
  - Lifts toward crit 5 anchor 4 ("forward-friendly mechanics") and
    crit 1 anchor satisfaction (more BC-genuine)

Recommendation: A (enemy variety) — unblocks the crit-6 ladder which
has 3 anchors stuck behind "two types" gate. One BUILD unlocks 4
potential anchors over future playtests.

Pre-mortem H2 RULE: reference-language predictions for iter-17 playtest:
1. User reports two distinct enemy types (color or behavior visible)
2. User does NOT report spawn-in-middle (F004 fixed)
3. User notes enemy with different attack (if ranged-shooter type added)

Iter 17 = PLAYTEST (per PROMPT §"USER-LOOK PROTOCOL" every 3 iters).`

---

## Previous Next Action (iter 14 — playtest evaluated iter 15)

`AWAITING user playtest response.

On response (iter 15):
  - Read user report
  - Evaluate 10 H2-RULE reference-language claims (LANDED / FALSIFIED / INDETERMINATE)
  - Log falsifications to FALSIFICATIONS.md
  - Update scores per RUBRIC.md anchors using playtest evidence:
    * Crit 4 anchor 4 ("stalling produces visible pressure") if user
      mentions more spawns when stopped
    * Crit 5 anchor 2 ("climb rate observable") if user mentions
      ascending / climbing
    * Crit 6 anchor 5 ("they don't get stuck") if no AI complaint
    * Crit 8 anchor 1 (some hit-flash/feedback) if user mentions any
      visual feedback effect
  - Per PROMPT §3, iter 15 is also AUDIT cycle (every 5 iters).
    Combine playtest eval with full rescore.
  - Plan iter 16 BUILD targeting whatever surfaces:
    * If "boring/not pushed" → iter 16 = better stalling pressure
      (e.g., descending fog, telegraphed warning) OR scrolling-screen
      mechanic
    * If "too hard" → iter 16 = balance tuning
    * If "I want a [BC mechanic missing]" → iter 16 = add that
      mechanic (likely power-ups or enemy types)
  - Update PRE-MORTEMS.md iter-14 post-eval

If no user response by end-of-iter-17: write HALTED.md per PROMPT
§"USER-LOOK PROTOCOL" halt rule; stop.`

---

## Previous Next Action (iter 14 — shipped as this iter's playtest prompt)

`Iter 14 PLAYTEST (first user-look on the roguelike-ascender stone):
  - Pre-mortem (H2 RULE: reference-language predictions per Pro v2 H4)
  - Verify build: make test, godot --quit, both exit 0
  - Capture run config deltas since iter-5 (FULL DELTA — first playtest
    on the new stone):
    * Movement: 4-dir grid (player + enemies)
    * Enemy types: 1 chaser+shooter type, white sprite (distinct from player yellow)
    * Spawn: top-edge, velocity-scaled lookahead, telegraph 0.5s before
    * Stalling pressure: 4s stall → spawn rate doubles
    * Bullets: 120 px/s, mask 9 (player) / mask 3 (enemy)
    * Terrain: brick destructible (1 hit), steel indestructible,
      water passable by bullets, forest hides tanks
    * HP: 3, iframes 0.6s, YOU DIED + R restart
    * HUD: HP 3/3 (top-left), DEPTH N (top-right), TIME M:SS (top-right)
    * Muzzle: aligned with sprite edge (8, 0)
  - Output playtest prompt to user. AWAIT. Halt rule iter 17.

Expected user observations (H2-RULE predictions):
  - "DEPTH counter goes up as I ascend" — verifies iter 11 HUD
  - "Enemies appear above me as I climb" — verifies iter 7 + iter 12
  - "Spawning is faster when I sit still" — verifies iter 12 stall pressure
  - "I see a yellow flash before each enemy" — verifies iter 12 telegraph
  - "Tank disappears in grass" — verifies iter 13 forest hide
  - "Brick breaks, steel doesn't" — verifies iter 8 + iter 13
  - "Bullets fly over water" — verifies iter 8
  - "Muzzle no longer off-center" — verifies iter 10
  - "Enemy faces forward properly" — verifies iter 10
  - DEFECT/SURPRISE — any new bug from compounding iter-12/13 changes`

---

## Previous Next Action (iter 13 — shipped)

`Iter 13 BUILD — BC terrain truth (forest hides + steel indestructibility):
  - Pre-mortem (H2 RULE: ≥1 reference-language playtest prediction)
  - DIAGNOSE: weakest axes still crit 4 (depth pressure anchor 4 needs
    playtest), crit 6 (one enemy type), crit 7 (compulsion), crit 8
    (visual juice), crit 10 (run summary playtest).
    Pick crit 6 lift via BC terrain truth — terrain semantics is BC's
    identity-feel axis. Forest hides + steel indestructible = 2 BC
    parity items.

  A. Steel indestructibility:
     - BrickBlock.gd take_damage assumes hp=1 destroys. But ALL terrain
       in the current setup uses BrickBlock-like StaticBody2D with hp.
       Actually, only BrickBlock has take_damage; the Steel TileMapLayer
       cells have no take_damage method. Bullet body_entered → if has
       method → call. So bullets DON'T destroy Steel cells; they just
       despawn against them. That's already correct BC behavior.
     - BUT: brick currently destroys in 1 hit. BC convention: standard
       bullet 1-hit destroys; star-upgraded bullet 1-hit destroys steel.
       For now, just confirm steel survives (no change needed). Iter
       13 might be lighter than expected.
  B. Forest hides tanks:
     - The Grass TileMapLayer exists (configs/playable.tres uses 12%
       grass). When player or enemy is OVER a grass cell, sprite alpha
       should reduce (e.g., to 0.3) — they're hidden in foliage.
     - Implement: PlayerTank + Enemy poll their world position vs.
       Grass TileMap. If above grass cell, sprite.modulate.a = 0.3.
       Else 1.0.
     - Need to find Grass TileMapLayer from script context. Use
       get_tree().get_root().find_child("Grass", true, false) or
       similar.
  C. (Optional) Camera limit_top removal so player can ascend
     unbounded. Currently project ProceduralLevel.tscn camera has
     limit_bottom=240 only; no limit_top. So unbounded ascent already
     works.

  - Headless smoke + oracle re-check
  - Score predictions: crit 6 anchor 2 ("Two types: chaser + ranged-
    shooter") might unlock if I add a second enemy type. But forest
    hides isn't really a new ENEMY axis — it's a terrain axis. So
    forest hides doesn't directly lift crit 6 by anchor wording.
    Could lift crit 8 anchor 1 (some hit-flash-equivalent) if forest
    transition is visible. Honestly: scores might not change in iter
    13; this is BC parity work.
  - Commit; ScheduleWakeup 240s
  - Iter 14 PLAYTEST: paired iter-10/11/12/13 user-look gate.

H1 tripwire: no new gameplay siblings. Count: 1.`

---

## Previous Next Action (iter 12 — shipped)

`Iter 12 BUILD — Spawn-ahead-of-player + ascending pressure:
  - Pre-mortem (H2 RULE: independently observable claims about iter-14
    playtest; specifically reference-language predictions like "I feel
    pushed up" / "I keep climbing")
  - DIAGNOSE: weakest axes are 4 (depth feedback, 1), 5 (forward survivability, 0),
    7 (compulsion loop, 0). Pick crit 5 + 7 — spawn-ahead is the
    primary lever for "fight while advancing."
  - Spawner.gd modifications:
    * Track player ascent velocity (avg upward rows/sec over last 2s)
    * spawn_y formula: current top-of-camera-view minus ascent-velocity-scaled
      margin (faster ascent = spawn further ahead, gives player time to
      see enemies before reaching them)
    * Add spawn TELEGRAPH: when an enemy will appear, briefly flash a
      marker at the spawn x-coord at top edge (1s warning before spawn)
    * If player stalls (ascent velocity < threshold), trigger
      "stalling pressure": increase spawn rate by 50% as gentle "keep
      moving" prompt
  - Headless smoke + oracle re-check
  - Score predictions (per H2 RULE secondary):
    * Crit 5 → 1 (player fires while moving — true in code already; could
      count this as anchor 1 if I cite Bullet's independence from player input)
    * Crit 7 anchor 1 "Spawn rate increases with depth — difficulty
      escalates linearly" — not exactly there since rate is fixed; could
      reach by tying spawn_interval to depth.
    * Stalling pressure mechanic = crit 4 anchor 4 ("Stalling at one
      depth produces visible pressure") — only countable after playtest cite
  - Commit; ScheduleWakeup 240s
  - Iter 13 BUILD = terrain semantics (forest hides, steel indestructible)
  - Iter 14 PLAYTEST — paired iter-10/11/12/13 user-look gate, the
    "first 60 seconds unmistakably roguelike-ascender-with-BC-feel" test`

---

## Previous Next Action (iter 9 — shipped as this iter's playtest prompt)

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
