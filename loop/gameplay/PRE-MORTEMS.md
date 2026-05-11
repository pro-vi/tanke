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

**Post-iter evaluation:** Predictions 1-5 all landed mechanically. Pro
consult returned post-commit; H1, H2, H5 #2 all surfaced material
critique; H5 #1 was actually false (Pro lacked PlayerTank.tscn). See
iter-4 LEDGER + creative-consults.md.

---

## H2 RULE — pre-mortems must include independently observable claims

Per GPT-Pro H2 critique (consult key tanke-iter-2-secondopinion): "'I
predicted score X and then assigned score X' is not a real prediction; it
is rubric theater." Going forward, every iter's pre-mortem **must contain
at least one independently observable falsifiable claim** — a claim whose
truth-value is set by code behavior, oracle output, automated test, or
playtest user reaction, NOT by my own scoring.

Examples (good):
- "First kill occurs within 20 seconds in a scripted sim"
- "No spawned enemy begins inside a solid tile (oracle-verifiable)"
- "Headless boot adds a parse error" (binary outcome, exit code)
- "User reaction to enemy AI includes the word 'stuck'" (playtest text)

Examples (bad — rubric theater):
- "Criterion N lands at K/5" (I'm the scorer)
- "I will integrate the consult" (I'm the executor)
- "Total score increases by ≥X" (still my scoring)

Score predictions may continue but are secondary. Falsifications come from
independently observable claims only.

---

## Iter 004 — AUDIT (Pro consult integration)

Going in, I expect this iter's biggest miss to be: rectifying H2 (rubric
theater) while still committing rubric theater inside *this* pre-mortem.
The temptation is to write "iter 4 will fix the Spawner and AUDIT will
land scores at X" — but those are still my decisions. The real
independently observable test of H2-rectification is: does my next
pre-mortem (iter 5) contain at least one claim the playtest can falsify
without my involvement?

Falsifiable predictions (independently observable):
1. **Oracle re-check returns tile_hash f873ae60ee3c420c…** exact match.
   Any deviation = silent substrate breakage from iter-3 dynamic-node
   additions. Binary, oracle-verifiable.
2. **Spawner post-patch will reject ≥1 candidate position per 10 spawn
   ticks** when player is near map center (seed 42, run for 30s). To
   verify: I'd need a counter in Spawner.gd or a Print on rejection.
   This requires a CAPABILITY mini-add. If I don't add the counter, this
   claim is unverifiable — flag it.
3. **Headless boot stays exit 0** with the Spawner reachability check
   added. Binary.
4. **Pro response H5 #1 (bullet self-collision via shared layer 1)
   was wrong** — PlayerTank.tscn shows `collision_layer=2`, not 1. Bullet
   mask = 9 = 1|8 does not include 2, so no self-hit possible. This is
   already verified by reading PlayerTank.tscn:12; flag as FALSIFICATION
   of Pro's claim.

Score-target predictions (secondary, rubric-theater-adjacent — Pro
critique acknowledged):
- AUDIT may LOWER crit 1 or crit 3 if I find I was generous (Pro's H5 #2
  spawn-in-walls issue means some "enemies present" might not actually
  reach the player; if anchor wording rules out broken AI, scores adjust)
- Most likely outcome: scores unchanged (7/50), with H1/H2/H5 #2 fixes
  shipped as substrate-discipline work without affecting rubric

**Post-iter evaluation:** 3 of 4 H2-RULE claims landed (oracle hash exact,
headless exit 0, Pro H5 #1 false); 4th (Spawner rejections > 0) properly
deferred to iter 5 playtest. Scores held at 7/50. Pro consult artifacts
shipped to creative-consults.md and FALSIFICATIONS.md.

---

## Iter 005 — PLAYTEST (mandatory user-look gate)

Going in, I expect the biggest miss to be: enemies get stuck on walls.
The iter-2 pre-mortem predicted this and Pro's H3 critique reinforced it
("don't pretend playtest is needed to discover this"). Less expected but
possible: the dynamic HurtBox doesn't fire `body_entered` for some
Godot-4 timing reason I haven't anticipated (HP never drops), or
`set_rotation` on PlayerTank rotates the muzzle in a way that makes bullets
visually wrong.

Independently observable claims for iter 5 (H2 RULE — user's playtest
report is the sole falsification authority):

1. **Bullets visibly travel forward when space pressed; visibly despawn on
   wall contact.** Falsified by: user sees stationary/invisible/persistent
   bullets, or bullets pass through walls.
2. **Some enemies get stuck on walls** — user observes at least one
   enemy piling up at a wall rather than reaching them. Falsified by:
   user reports all enemies engage cleanly OR no enemies at all.
3. **Output dock shows `[spawner] tick N: spawns=X rejections=Y` lines
   with Y > 0** within 30+ seconds of play. Falsified by: Y stays 0
   (means H5 #2 patch is overcautious, or no walls hit by 8-attempt
   sample).
4. **HP drops on enemy contact; death triggers "YOU DIED [R] RESTART"
   label.** Falsified by: HP stays 3 forever even with enemies touching
   player, OR death doesn't show the label.
5. **R-key (after release-then-press) reloads the scene to a fresh
   state.** Falsified by: R does nothing, OR restarts instantly without
   debounce, OR scene state leaks across reloads.

Score-target predictions (per H2 RULE, secondary):
- Crit 1 → 3 if user confirms full core loop (move → shoot → take damage
  → die → restart). Otherwise holds at 2.
- Crit 6 → ? (depends on user observation of enemy AI quality)
- Crit 7 (Run pacing) might land at 1 if user reports spawn-rate increases
  feel — but spawn rate is fixed at 2s, so unlikely. Probably stays at 0.

**Post-iter evaluation:** [to be filled when user responds]

---
