# tanke — Gameplay Loop Falsifications

Append-only. When a prediction (mine or external) is contradicted by
observable evidence, log it here with the prediction, the contradiction,
and the lesson. Per PROMPT.md §"USER-LOOK PROTOCOL": the engine loop
accumulated 4 falsifications; this loop should expect more, especially on
feel axes.

---

## Falsification 001 — iter 4 — GPT-Pro H5 #1 — bullet self-collision claim

**Prediction (Pro):** "the nastiest 30-second bug is probably bullet
self-collision with PlayerTank. Bullet.tscn masks layer 1 | 8; terrain is
layer 1, but unless PlayerTank.tscn overrides its collision layer, the
player is probably also layer 1. If the bullet spawns overlapping the
tank, _on_body_entered queues it immediately." (consult key
`tanke-iter-2-secondopinion`, end of iter 2)

**Contradiction:** `scenes/PlayerTank.tscn:12` has `collision_layer = 2`,
not 1. `Bullet.tscn:11` has `collision_mask = 9` = layer 1 (Environment) +
layer 8 (Enemy). Layer 2 (Player) is NOT in the bullet's mask. Therefore
the bullet's body_entered cannot trigger on the player even if they
overlap on spawn — the area-vs-body collision filter rules it out at the
physics-server level.

**Lesson 1:** External consultation without complete context produces
plausible-sounding-but-wrong claims. Pro hedged the claim correctly
("unless PlayerTank.tscn overrides…") — the failure was in MY context
selection. PlayerTank.tscn was not included in `contextPaths` despite
being clearly relevant to "review the bullet/enemy/player collision
graph."

**Lesson 2:** Pre-mortems-in-writing (H2 RULE) and falsification logging
work in BOTH directions — I should log when I'm wrong AND when my
external evidence sources are wrong. The latter is rarer but more
informative because it constrains my future use of consults.

**Action:** When next consultation fires, include all .tscn files
referenced anywhere in the question's domain. Specifically: any review of
collision graph / enemy AI / damage flow must include PlayerTank.tscn,
Bullet.tscn, Enemy.tscn, and any new collision-layer-using scene.

---

## Falsification 002 — iter 6 — Iter-2 enemy AI prediction wrong direction

**Prediction (mine, iter 2 pre-mortem):** "the simple chaser AI (`move_toward(player)` via `move_and_slide`) gets enemies stuck against the procedural maze walls — they path-straight into a brick/steel wall and slide along it forever instead of routing around. Iter 5 playtest will show enemies piling up at the nearest wall between them and the player, never engaging."

**Contradiction (user playtest, iter 5):** "enemies can spawn out of nowhere - they should spawn from the top and they should learn to navigate like original battle city - use directional movement like the player - not skiing without constraints."

**Mechanism analysis:** I correctly diagnosed the underlying mechanism (no
pathfinding, naive `move_and_slide`) but predicted the WRONG observable
phenomenon. `move_and_slide` doesn't stick — it slides freely along
collision normals, producing smooth diagonal motion. The user-perceived
problem is the OPPOSITE of "stuck": the enemies look like they're
"skiing without constraints" — moving in 8 directions on a continuous
plane, not Battle-City-style 4-dir grid motion that matches the player's
movement model. Hands moved from "they don't engage" (predicted) to "they
engage but the motion feels wrong."

**Lesson 1:** A prediction about *mechanism* is not the same as a
prediction about *observation*. Future pre-mortems should predict what
the user will REPORT — words like "stuck", "weird", "skiing", "fast" —
rather than what the code will technically do.

**Lesson 2:** Playtest evidence overrides automated-test evidence
unambiguously. `make test` (120 frames) shows no errors; oracle shows
playable: true; but the FEEL is wrong in a way only the user surfaces.
This is exactly why PROMPT.md mandates iter-5 user-look — and exactly
why the engine-loop's 8-iter dormant gate cost so much.

**Lesson 3:** The PROMPT.md "stone" framing ("Vampire-Survivors-like")
implies radial-spawn + chase-and-touch enemies. The user's playtest
report invokes Battle City conventions (4-dir grid, top-spawn, enemy
bullets, brick destruction). The asset library (sprites_0.png) is Battle
City. There's a latent design-direction tension between the PROMPT.md
brief and what the playable thing should feel like. Iter 7+ resolves
toward Battle City by following the user's playtest signal (the loop's
primary authority per PROMPT §USER-LOOK).

**Action:** Iter 7 BUILD targets the user-reported gaps: (1) grid-aligned
4-dir enemy AI matching the player's movement model, (2) enemy bullets
fired in facing direction, (3) top-edge enemy spawn replacing radial.
Iter 8 BUILD targets the bullet/terrain gaps: brick destructibility,
bullets-over-water collision filter, muzzle-position centering.

---

## Falsification 003 — iter 6 — Loop-scoped design framing drift

**Prediction (implicit, PROMPT.md "the stone"):** The gameplay loop builds toward "a complete Vampire-Survivors-like tank survival run: manual movement + manual primary gun + auto-firing secondary weapons; HP bar, single life, 5–10 minute runs; procedural maze as terrain substrate; wave-based enemy escalation; kills drop XP, threshold triggers level-up modal with 1-of-3 upgrade choice."

**Contradiction (user playtest, iter 5):** User invokes Battle City conventions consistent with the asset library — 4-dir grid movement, top-edge spawn, enemy bullets, brick destruction by bullets, bullets passing over water — none of which are in the PROMPT.md "stone" framing.

**Analysis:** Two coherent design directions are now both partially
implemented:
- **VS-like (PROMPT.md "stone"):** radial-spawn enemies, chase-and-touch
  damage, XP-driven upgrade trees, multi-minute survival arc
- **Battle City (asset-library + user playtest):** 4-dir grid motion,
  top-spawn directional waves, enemy bullets, brick destruction, base
  defense (?)

Neither is "wrong"; they're different feel targets. The procedural maze
substrate + tank survival framing works for both. Decision needs to be
made: pick one direction, hybridize, or let the loop discover via
iterative playtest.

**Lesson:** Greenfield loops should accept that the actual playable
feel may shift framing from the brief. PROMPT.md's brief was written
before any playable thing existed. Now that there's a playable thing,
the user's hands-on signal is more authoritative than the brief.

**Action:** Don't unilaterally rewrite PROMPT.md. Note the framing
question explicitly in STATE.md "Design direction" section. Let the
user steer at iter-7+ playtests, or explicitly during planning. Default
direction for iters 7-8: follow the user's playtest report (Battle City
direction), since they're the loop's user-look authority.

---

## Falsification 005 — iter 34 — Heavy AI omniscient (too smart per user)

**Prediction (mine, iter 24 [STRUCTURE-DEFERRED]):** Heavy state machine CHASE/AIM_FIRE = legitimate behavioral split that lifts crit 6 anchor 2.

**Contradiction (user playtest iter 33):** "heavy tanks are too smart of my location - i think we should gradually build into the best ver. of intelligence the AI system can have - vision first, transimission second. for example a heavy tank shouldnt be hunting me down and as soon as i go into its range it just starts firing non stop. too smart/cheaty."

**Root cause:** `Enemy.gd:_player_in_line_of_sight` uses raw `player.global_position` — omniscient through walls. Heavy "sees" player even when there's a brick wall between them. Original Battle City had NO vision system at all; my Heavy is several orders of magnitude smarter than the source material.

**Lesson:** Pro Consult 004 H2 said "make Heavy a corridor-denier that turns slower, pauses, and fires bursts." I implemented pauses+bursts correctly but the LOS check is omniscient. Pause+burst with raycast-aware LOS would have been the right move; I over-shot on "easy to detect alignment" and missed "fair detection."

**Action:** Iter 35 BUILD reworks Heavy to Stage 1 vision per `.research/battle-city-ai.md`: cardinal forward cone + raycast through env layer 1 to block on walls. Heavy only enters AIM_FIRE when player is in forward cone AND no wall between. Authentic BC tactical play (hide behind brick, peek out, hide again).

---

## Falsification 006 — iter 34 — Tanks (and player) drift off map border

**Prediction (implicit, never tested):** Map boundaries are respected; tanks stay within x ∈ [0, 320].

**Contradiction (user iter 33):** "they sometimes drive out of map boarder? seems i can do that too..."

**Root cause:** `scenes/ProceduralLevel.tscn:62-65` Camera2D has `limit_left=0, limit_right=320` — that clamps the CAMERA view, but there are no collision walls at x=0 or x=320. PlayerTank (mask=513 Env+Water) and Enemy (mask=513 same) collide with terrain INSIDE the maze but find no walls at the map edges. They can drift outside.

**Action:** Iter 35 BUILD adds invisible StaticBody2D walls at x=-4 and x=324 (4px outside visible range) on layer 1 (Environment) so both tank types collide normally. Single small scene-edit in ProceduralLevel.tscn.

---

## Falsification 007 — iter 34 — Water doesn't block player

**Prediction (iter 8):** WaterBlock.collision_layer 513→512 + Player mask 513 → Player still blocked by water (mask 513 includes 512).

**Contradiction (user iter 33):** "water does not block me?"

**Root cause:** Needs investigation. iter-8 collision math is correct on paper: 513 mask AND 512 layer = 512 (non-zero) → collision. Possibilities: (a) WaterBlock isn't actually placed at runtime in some path; (b) Level.gd `_replace_blocks()` replaces brick but NOT water in some procedural setup; (c) iter-N regressed the collision_layer back. Iter 35 must verify the current state and fix.

**Action:** Iter 35 BUILD: re-grep WaterBlock.tscn for collision_layer; trace Level.gd `_replace_blocks` for water replacement path; verify with a runtime test. Likely a small fix once root-cause identified.

**Root cause CONFIRMED iter 37 (user playtest iter 36):** Water is painted via `waterTileMap.set_cell()` (TileMapLayer in ProceduralLevel.tscn), NOT via WaterBlock.tscn instances. Iter 35's WaterBlock.tscn rewrite was dead code — never instantiated. The actual `WaterSet` TileSet had NO `physics_layer_0` defined, so water tiles had zero collision. Compounding: PlayerTank instance in ProceduralLevel.tscn overrode `collision_mask = 1`, stripping water layer (512) from the player's mask even if water had collision.

**Iter 37 fix:** Added `physics_layer_0/collision_layer = 512` to WaterSet + polygon points `PackedVector2Array(-4,-4,4,-4,4,4,-4,4)` to WaterSrc. Changed PlayerTank instance `collision_mask = 1` → `513`. Enemy already had mask 513 from before. Headless boot clean.

**Lesson:** When a fix targets a `.tscn` file, verify the file is actually used at runtime — `grep` for instantiation sites first. The base PlayerTank.tscn correctly had mask=513 but the level-scene override silently stripped it; instance overrides on scenes mask base values without warning.

**RESOLVED (user iter 37 playtest):** "water fixed." Closed.

---

## Falsification 005-v2 — iter 37 — Heavy still rapid-fires on LOS acquisition

**Prediction (iter 35):** Vision-cone gate solves "Heavy too smart" — Heavy needs to FACE player + clear LOS to fire.

**Contradiction (user iter 37):** "heavy feels easier but it still points me directly and fire rapidly as soon as i came into its line of sight. really hard to play around."

**Root cause:** Vision-cone correctly gated ENTRY into AIM_FIRE, but on entry: (a) `_enter_aim_fire()` set `_burst_timer = 0.0` → fires on next tick with zero reaction time, (b) `burst_interval = 0.25s` produced rapid 2-shot volley, (c) `aim_fire_cooldown_between_bursts = 0.8s` was short enough that sustained LOS = sustained pressure. No telegraph — player had no signal "Heavy has locked on, dodge now."

**Iter 38 fix:**
- New export `aim_fire_reaction_time = 0.45s` — Heavy enters AIM_FIRE, stops, faces player, but does NOT fire for 0.45s.
- Red modulate telegraph during reaction window (color `(1.6, 0.5, 0.5)`, alpha preserved for forest hide).
- `burst_interval` 0.25 → 0.4 (less rapid).
- `aim_fire_cooldown_between_bursts` 0.8 → 1.2 (longer recovery).
- Telegraph cleared on first shot of each burst.

This gives the player a ~0.45s readable window to either break LOS (slip behind a wall) or commit to a perpendicular dodge. Per `.research/battle-city-ai.md` Stage 1 design intent: vision-based AI must be REACTABLE; instant-fire on acquisition reproduces the iter-24 "too smart" feel even with vision gating.

**RESOLVED (user iter 38 playtest cite):** "yeah ok that works for now." Heavy AI reactability passes. F005 lineage closes. Promoted crit 6 STRUCTURE-DEFERRED → [FEEL]-confirmed at anchor 2 (no numeric lift; anchor 3 requires 3+ enemy types, we have 2).

---

## Falsification 006 — RESOLVED iter 39 (soft-closed, no complaint after 2 playtests)

**Original prediction (iter 12+):** Map borders contain player/enemies without drift.

**Original contradiction (user iter 33):** Tanks driving off map edges.

**Iter 35 fix:** Invisible StaticBody2D walls at x=-4, x=324, RectangleShape2D size 8×8000, layer 1.

**Resolution iter 39:** Two subsequent playtests (iter 37 water-focused, iter 38 Heavy-focused) — user did not re-mention border drift. Per cite-prediction discipline: if user were still hitting borders, that would be a top-of-mind complaint. SOFT-CLOSED. Re-open if iter 60 playtest surfaces edge-drift again.

---

## Falsification 008 — RESOLVED iter 39 (soft-closed, no complaint after 2 playtests)

**Original prediction (iter 28):** Below-spawn fires only after sustained intentional stall.

**Original contradiction (user iter 33):** "enemies still can spawn behind me."

**Iter 35 fix:** Raised stall_below_spawn_after 8→12s, below_spawn_cooldown 6→10s.

**Resolution iter 39:** Two subsequent playtests — no below-spawn complaint. SOFT-CLOSED. Re-open if iter 60 playtest surfaces "spawned behind me" again, or if `[run]` summary shows below-spawn count rising during normal play (instrumentation from iter 31 still active).

---

## Falsification 008 — iter 34 — Below-spawn fires when not intentionally stalling

**Prediction (iter 28):** Below-spawn fires only after sustained intentional stall (stall_time > 8s with stall_threshold=0.3 rows/s).

**Contradiction (user iter 33):** "enemies still can spawn behind me."

**Possible root cause:** Player moving slowly through dense maze (collisions, navigating around walls) keeps `ascent_velocity` near 0 even though player IS trying to move forward. EMA-smoothed ascent_velocity might accumulate stall_time without the player feeling like they "stopped." 8s threshold + 6s cooldown means ~14s elapsed between below-spawns — that's plausibly mid-navigation, not a clear "I'm stalling" trigger.

**Action:** Iter 35+ BUILD tighter threshold: raise stall_below_spawn_after to 12s (give player more grace). Or use ROWS-ASCENDED-IN-LAST-N-SECONDS instead of velocity (a player who climbed 0 rows in 10s is genuinely stalled; a player at 0.2 rows/s but moving is not). Use `_max_depth_reached` delta vs N seconds ago.

---

## Falsification 004 — iter 15 — Spawn-from-top-edge partial failure

**Prediction (mine, iter 12 + iter 14 H2-RULE claim):** Enemies spawn off-screen above the viewport and walk down into view ("driving in from above" per user iter-9 request).

**Contradiction (user playtest iter 14):** "no some of them spawn in the middle but there is an animation indicator, i want them to spawn almost out of screen and drivin into view"

**Root cause:** `scripts/Spawner.gd` was using `_camera.global_position.y` as the camera reference for computing spawn_y. But `Camera2D.global_position` reports the *requested* camera position, NOT the *effective* (limit-clamped) screen center. When player is near the floor (y=232) and Camera2D has `limit_bottom=240`, the effective viewport is clamped: bottom = 240, top = 0, center = 120. But `_camera.global_position.y` returns 232 (the unclamped requested position). My spawn formula `spawn_y = 232 - 120 - 24 = 88` placed spawns at y=88, which is well INSIDE the visible viewport (0..240) instead of above it.

**Why this slipped past iter-10 fix:** Iter 10 commit `a7f8bf0` switched from `_player.global_position.y` to `_camera.global_position.y` as the reference. That was a correct direction but used the wrong camera API — should have used `_camera.get_screen_center_position()` which accounts for limit clamping.

**Why this slipped past iter-12 H2-RULE claims:** My pre-mortem claims #1 (spawn from top edge) and headless verification at fixed-fps confirmed timer-tick behavior but did NOT verify spawn-position correctness because the headless run used a stationary player at y=232 where the bug is most visible — yet I checked spawn_y values numerically rather than visually. Lesson: code-level verification doesn't catch positional bugs that need rendering to see; iter-12 should have included a camera-clamping check.

**Action (iter 15):** Spawner.gd switched to `_camera.get_screen_center_position().y`. Renamed `top_off_screen_margin` to `spawn_top_edge_offset` and changed semantics: spawn AT screen top + 8px INSIDE the visible edge (rather than 24px ABOVE). User explicitly requested "spawn almost out of screen and driving into view" — enemy appears at top edge visibly, walks down into play area. Telegraph also visible at top edge.

**Lesson:** When using camera position for game logic, prefer Camera2D APIs that account for clamping (`get_screen_center_position`) over raw node position (`global_position`). This is a Godot-API gotcha worth remembering.

---
