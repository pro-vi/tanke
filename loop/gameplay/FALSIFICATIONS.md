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
