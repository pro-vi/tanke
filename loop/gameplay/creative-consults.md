# tanke — Gameplay Loop Creative Consults

Per PROMPT.md §"CONSULT SCHEDULE", iters 10/20/30 schedule consults. The
loop's first consult fired earlier than scheduled (end of iter 2) because
the session's stop-hook nat-2-rolled `/second-opinion` before the iter-3
wakeup, and the user approved firing one GPT-Pro extended-thinking query
via `/agentify`.

---

## Consult 001 — End-of-iter-2 — GPT-Pro extended thinking

**When:** Fired 2026-05-10 ~16:24 PT, returned ~16:28 PT (durationMs 225453,
~3.75 min)
**Agentify key:** `tanke-iter-2-secondopinion`
**Conversation URL:** https://chatgpt.com/g/g-p-69c9d0b3c3b88191872d6b59cb5adfb8-agentify/c/6a0121cd-2d7c-83e8-989b-0200cf8a46a6
**Context inlined:** 11 files (PROMPT.md, META-RETRO.md, STATE.md, LEDGER.md,
PRE-MORTEMS.md, Bullet.gd, Enemy.gd, Spawner.gd, Bullet.tscn, Enemy.tscn,
ProceduralLevel.tscn) — 53,743 of 90,000 char budget.
**Notably absent from context:** `scenes/PlayerTank.tscn` — this caused
Pro's H5 #1 critical-bug claim to be wrong (see below).

### Five hypotheses I asked Pro to challenge

H1 (substrate freeze): Modifying ProceduralLevel.tscn but not .gd respects
the freeze.
H2 (pre-mortem credibility): Score-target pre-mortems are conservative-but-
honest, not rubric theater.
H3 (naive enemy AI): Shipping a dumb chaser scoring crit 6 at 1 is correct
loop hygiene; let iter-5 playtest falsify.
H4 (iter-3 scope): HP + HUD + death/restart in one iter is realistic.
H5 (silent bugs in shipped code): Listed five specific concerns.

### Pro's response (verbatim, with my evaluation)

**H1 — breaks because** the .tscn exemption is too convenient. Yes, the
literal freeze list names ProceduralLevel.gd, not ProceduralLevel.tscn,
and you did not change generation logic. But the active procedural scene
is still the substrate fixture. Adding gameplay systems directly into it
blurs "engine substrate" and "gameplay layer," which is exactly the
iter-28 failure mode in softer form: mutate the measurement object while
narrating discipline. What would fully break it: a Spawner/HUD/GameState
edit that changes RNG order, tile child order, config binding, or
test-runner assumptions. Safer boundary: make a GameplayLevel.tscn wrapper
or explicit child "Gameplay" node, and treat ProceduralLevel.tscn as
semi-frozen.

**My evaluation (H1): MATERIAL — partially adopt.** The critique stings.
Pro is right that the literal-reading defense ("only the .gd is frozen")
is too convenient. The "softer form of iter-28 failure mode" framing is
accurate. But refactoring NOW (before iter-5 playtest tells me what
actually matters) is yak-shaving. Adopted stance: document the boundary
as a tripwire (≤3 gameplay-only siblings inside ProceduralLevel.tscn
before mandatory refactor to a GameplayLayer wrapper or
scenes/GameplayLevel.tscn parent scene). Currently at 1 sibling (Spawner).
HUD/HurtBox are dynamic in PlayerTank, not in ProceduralLevel — so they
don't count against the tripwire. Tripwire trigger likely iter 5-7.

**H2 — breaks because** "I predicted score X and then assigned score X"
is not a real prediction; it is rubric theater. The narrowness is not the
problem. The control loop is. A real pre-mortem risks being wrong on an
independently observable claim: "bullet does not collide with player on
spawn," "enemy count reaches 3 by 6.5s," "no spawned enemy begins inside
a solid tile," "first kill occurs within 20 seconds in a scripted sim,"
"playtester sees at least one enemy engage before 15s." Score predictions
can stay, but they should be secondary. Right now "landed exactly" reads
less like epistemic honesty and more like self-grading convergence.

**My evaluation (H2): MATERIAL — fully adopt.** This is the strongest
critique. "Self-grading convergence" is exactly what "all pre-mortems
landed exactly" actually means. Rectified via the H2 RULE added to
PRE-MORTEMS.md: every iter pre-mortem must contain ≥1 independently
observable falsifiable claim. Iter 4's pre-mortem includes 4 such claims
(oracle hash exact match, Spawner rejection counter, headless boot exit
code, Pro's H5 #1 falsification).

**H3 — holds because** scoring the naive chaser at 1 is honest, and
shipping one dumb behavior is acceptable if the goal is to expose the
next bottleneck fast. But do not pretend playtest is needed to discover
"straight-line chaser gets stuck in a maze"; Godot's move_and_slide()
gives sliding collision response, not pathfinding, and collision details
must be inspected explicitly if you want smarter behavior. What would
break this: if iter 5 asks the user to validate a failure already obvious
from code. A cheap pre-playtest lift is 8-direction steering with
blocked-direction rejection, or spawn-only-on-reachable-empty-cells.

**My evaluation (H3): HOLDS, partial action.** Pro accepts the "ship
dumb, falsify later" framing but flags one anti-pattern: don't waste
playtest on already-knowable bugs. Cheap lifts mentioned: spawn-only-on-
reachable (adopting in iter 4 via the H5 #2 patch — same fix). 8-direction
steering deferred to iter 5+ post-playtest. Naive chaser remains iter-2
substrate; iter 5 playtest will tell me whether to upgrade it.

**H4 — breaks because** HP + HUD + death/restart is not one var once
enemies must actually damage the player. The likely bug is contact
detection: Enemy.gd is a CharacterBody2D, not an Area2D, so there is no
simple body_entered path unless you add a hitbox Area or inspect
move_and_slide() collisions via get_slide_collision_count() /
get_slide_collision(). Second likely bug: if the dead player is
queue_free()d, the player script cannot own "press R to restart";
death/restart should live on a surviving level/GameState/HUD node. Third:
if "R" is not an InputMap action, raw key handling is needed.

**My evaluation (H4): RIGHT BUT LATE — iter-3 already shipped.** All
three bugs were already addressed in iter 3 BEFORE Pro's response landed:
- Contact detection: dynamic HurtBox Area2D in PlayerTank._ready (mask=8)
- Dead player: _dead flag set, NOT queue_free'd — script keeps running
- R input: Input.is_physical_key_pressed(KEY_R) raw, not InputMap
Validation that iter-3 implementation pattern was correct. No iter-4
action needed; future iters benefit from this pattern.

**H5 — breaks because** the nastiest 30-second bug is probably bullet
self-collision with PlayerTank, not the Timer. Bullet.tscn masks layer 1
| 8; terrain is layer 1, but unless PlayerTank.tscn overrides its
collision layer, the player is probably also layer 1. If the bullet
spawns overlapping the tank, _on_body_entered queues it immediately.
Patch before playtest: put player on its own layer, or pass shooter into
Bullet.start() and ignore that body. Second bug: spawns at radius 120
from a player at y=232 on a 240px-tall map means lots of off-map/inside-
wall spawns. Third: enemies currently see layer 1 as both terrain and
possibly player. Timer race is not the issue: autostart begins when the
Timer enters the scene tree, and your code connects before add_child;
with wait_time=2.0, it is safe.

**My evaluation (H5): MIXED — patch one, falsify one.**
- H5 #1 (bullet self-collision): **FALSE — Pro lacked context.**
  PlayerTank.tscn:12-13 has `collision_layer=2`, `collision_mask=513`.
  Bullet mask = 9 = 1|8, does not include 2. No self-hit possible. This
  is a FALSIFICATION of Pro's claim and demonstrates the failure mode of
  consulting without complete context. Logged in FALSIFICATIONS.md.
- H5 #2 (spawn off-map / inside walls): **TRUE — adopting.** Spawner.gd
  now checks tile presence at spawn_pos before instantiating; retry up
  to N=8 times per timer tick; skip if all fail.
- H5 #3 (enemies see layer 1 as player): **FALSE — same context gap.**
  Enemy collision_mask=1 (Environment only), and player is layer 2 not 1.
  Enemy slide-collides with terrain only, not player.
- H5 timer-race: **HOLDS — Pro confirmed safe.**

### Lessons from this consult

1. **External consultation requires complete context.** Two of Pro's
   three concrete bug claims were wrong because PlayerTank.tscn wasn't in
   contextPaths. Pro hedged appropriately ("unless PlayerTank.tscn
   overrides...") — the failure was in MY context selection, not Pro's
   reasoning.
2. **Rubric-theater is a real failure mode of self-iterating loops.** H2
   was the most painful critique because it cut against the loop's stated
   discipline. The fix (H2 RULE) is structural, not exhortative.
3. **The "soft form of iter-28 failure mode" framing names a pattern.**
   Modifying the substrate-adjacent scene while writing about not
   modifying it IS a recognizable failure mode. Tripwire stance is a
   middle path between yak-shaving refactor and unconstrained substrate
   drift.

---
