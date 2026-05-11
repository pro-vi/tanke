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
