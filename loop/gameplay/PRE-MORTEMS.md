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
