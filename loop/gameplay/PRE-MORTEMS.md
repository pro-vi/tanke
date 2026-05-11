# tanke — Gameplay Loop Pre-Mortems

Append-only. Written before DIAGNOSE/MODE/ACT each iter (PROMPT §1).
Iter-21 evidence: pre-mortems-in-writing work as a falsification mechanism
even when external CONSULT fails.

---

## Iter 001 — BUILD (Bullet system)

Going in, I expect this iter's biggest miss to be: bullet travels and
despawns cleanly on terrain collision, but with no enemies to shoot and no
visible impact spark, the "core loop closes" criterion lands at 1
(move + shoot + bullet has no effect) rather than 2 (move + shoot +
collisions register). The collision will technically register on terrain
StaticBody2D, but without a visible target it'll feel like firing into the
void. Secondary risk: format-2 → format-3 .tscn migration introduces a
UID/resource regression that breaks scene loading entirely — would surface
in headless boot, so recoverable in-iter.

Falsifiable predictions:
1. Criterion 1 lands at 2/5 (not 1, not 3). Anchor: collision registers
   even without enemies — bullet visibly despawns hitting brick.
2. Headless `godot --quit` returns 0 with no parse errors.
3. Reachability oracle at seed 42 unchanged: `playable: true`, `tile_hash
   f873ae60ee3c420c…` (Bullet changes don't touch tile placement).

**Post-iter evaluation:** All three predictions landed exactly. Crit 1 = 2.
Boot clean (one harmless UID cache warning). Oracle byte-identical. No
falsifications. Real runtime risk (bullet visibly moves, despawns) deferred
to iter 5 playtest.

---

## Iter 002 — BUILD (Enemies + Spawner)

Going in, I expect this iter's biggest miss to be: the simple chaser AI
(`move_toward(player)` via `move_and_slide`) gets enemies stuck against
the procedural maze walls — they path-straight into a brick/steel wall and
slide along it forever instead of routing around. Iter 5 playtest will
show enemies piling up at the nearest wall between them and the player,
never engaging. Secondary risk: spawn positions land in unreachable cells
(the maze has ~33% non-terrain but with disconnected pockets the BFS
reaches 804 cells of 1200 total — meaning ~33% of spawn points are walled
off from the player). Either way, criterion 6 (enemy variety + behavior)
caps at 1 — the anchor-5 "they don't get stuck" is exactly the predicted
miss.

Falsifiable predictions:
1. Criterion 2 (spawn) lands at 1 — fixed-rate, random-angle spawn is
   between anchor 1 (single location) and anchor 2 (varying intervals).
   Conservative: 1.
2. Criterion 6 (enemy variety) lands at 1 — single chaser type, no
   pathfinding. Anchor 1 exactly.
3. Criterion 1 (core loop) stays at 2 — bullets can now hit enemies but
   no HP/death system yet, so anchor 3 ("player has HP, takes damage, can
   die") is unreachable.
4. Headless boot clean; oracle unchanged.

**Post-iter evaluation:** All four predictions landed. Crit 2 = 1, crit 6 = 1,
crit 1 held at 2, boot/oracle clean. The predicted runtime miss (enemies
stuck on walls / spawn in unreachable pockets) is unverified — needs
iter-5 playtest to confirm or falsify.

---

## Iter 003 — BUILD (HP + HUD + death/restart)

Going in, I expect this iter's biggest miss to be: combining HP + HUD +
death/restart in one iter creates a wiring bug that headless boot won't
catch — specifically the damage-detection mechanism. Two `CharacterBody2D`s
(player + enemy) don't emit collision signals through `move_and_slide`, so
I need an `Area2D` HurtBox somewhere. If layer/mask is wrong (HurtBox needs
`collision_mask = 8` (Enemy), `collision_layer = 0` so it doesn't push
anything), enemies will pass through the player silently and HP never
drops. Secondary risk: restart via `get_tree().reload_current_scene()`
recreates the Spawner cleanly but if I set `process_mode` wrong on a "dead"
player, the death-state UI won't render. Tertiary: `Input.is_physical_key_pressed(KEY_R)`
vs `Input.is_action_just_pressed` — polled `is_pressed` will instantly
restart the moment a player dies if R was already held; debounce needed.

Falsifiable predictions:
1. Crit 1 (Core loop closes) → 3. Anchor 3 = "player has HP, takes damage,
   can die — cited via playtest". Capped at 3 even with HP because feel
   criterion needs playtest for >2. So actually capped at 2 from playtest
   rule; but anchor 3 *exists* in code, so I'll cite scripts/PlayerTank.gd
   and stay at 2 honestly — pre-mortem says crit 1 holds at 2.
2. Crit 3 (HP/death model) → 2. Anchor 2 = "Player takes damage on
   collision; HP shown numerically". HurtBox + Label HUD = exact anchor 2.
3. Crit 9 (UI/UX) → 1. Anchor 1 = "HP/XP shown numerically (text only)".
4. Crit 1 might stay at 2 (feel criterion playtest rule). I'm tempted to
   bump it to 3 because anchor 3 is structurally satisfied, but the rule
   says >2 needs playtest. So 2 it is.
5. Headless boot clean; oracle unchanged.

**Pre-commit override risk:** If the agentify GPT-Pro consultation
(started end-of-iter-2) returns mid-iter with material critique (e.g.
"this scope is too wide" or "silent bug in code"), I will integrate before
commit. This iter therefore has a built-in falsification surface that's
not my own work product — first iter where falsification can come from
external evidence, not just my own scoring.

---
