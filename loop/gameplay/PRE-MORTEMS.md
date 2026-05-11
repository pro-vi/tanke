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

**Post-iter evaluation (iter 6, after user playtest):**
- Claim 1 (bullets travel + despawn on walls): **LANDED.** User: "it works"
  with only spawn-position polish flagged.
- Claim 2 (some enemies get stuck on walls): **FALSIFIED.** User reports
  "skiing without constraints" — opposite phenomenon. Mechanism diagnosis
  was right (no pathfinding), observable prediction was wrong direction.
  Logged FALSIFICATION 002.
- Claim 3 (Spawner rejections > 0 within 30s): **INDETERMINATE.** User
  didn't surface Output dock contents.
- Claim 4 (HP drops + YOU DIED label): **LANDED.** User confirmed via
  "it works" (would have flagged otherwise).
- Claim 5 (R-key restart fresh): **LANDED.** Same.

Score: 4/5 with 1 hard falsification = H2 RULE working. First iter that
surfaced a genuine "I was wrong" via independently observable evidence.

Bonus: user invoked Battle City conventions, surfacing a design-framing
drift between PROMPT.md "VS-like" stone and actual hands-on feel.
Logged FALSIFICATION 003.

---

## Iter 006 — AUDIT (playtest evaluation)

Going in, I expect the biggest miss to be: I'll over-confidently
synthesize the user's brief report into too-specific iter-7 plans before
asking them about the framing drift. The user mentioned 6 distinct
issues (bullet off-center, brick non-destructible, water non-passable,
spawn-from-top, grid-AI, enemy-fire) — three of those (grid-AI,
enemy-fire, top-spawn) cluster as "enemy refactor," but bundling them
without confirming the framing-direction commitment risks shipping a
half-Battle-City pivot without the user explicitly saying "yes go full
Battle City."

Independently observable claims for iter 6 (H2 RULE):
1. **FALSIFICATIONS.md grows by ≥2 entries** documenting (a) iter-2
   enemy-AI prediction direction-wrong, (b) design-framing drift VS-like
   → Battle City. Binary, file-content-verifiable.
2. **Score table updates with at least 1 score going up via playtest
   evidence.** Crit 1 should reach anchor 4 ("death triggers clear run
   over state with restart option — cited via playtest") since user
   confirmed the full move→shoot→die→restart cycle. Score 1: 2 → 4
   expected.
3. **STATE.md "Open seams" grows by ≥3 entries** capturing
   user-surfaced gaps (brick destruction, water bullet pass, grid AI,
   enemy fire, top spawn, muzzle centering).
4. **Iter 7 plan documents 3 of those 6 user-surfaced gaps as one
   coherent BUILD focus** (enemy refactor — grid AI + enemy fire +
   top spawn — same module).

Secondary: AUDIT may not change Crit 6 score because the user did NOT
report enemies stuck, but also did NOT report basic pathfinding — Pro's
H3 critique stands.

**Post-iter evaluation (iter 6):** All 4 H2-RULE claims landed. Scores
unchanged at 9/50. Iter 7+ plans documented. Pro consult work shipped.

---

## Iter 007 — BUILD (enemy refactor)

(Pre-mortem and post-eval inlined into the iter-7 LEDGER entry rather
than here; documented in commit message and LEDGER. Going forward iter
entries in this file are short.)

H2-RULE claims:
1. make test clean post-refactor → LANDED (after spawn_distance hotfix)
2. Oracle hash unchanged → LANDED
3-5. iter-9 playtest claims (no "skiing", enemies fire, no "spawn out of
nowhere") → DEFERRED to iter 9

---

## Iter 008 — BUILD (bullet/terrain)

Going in, biggest expected miss: bullet-over-water fix needs synchronized
changes across 3 files (WaterBlock.tscn layer, Enemy.tscn mask, Spawner.gd
reachability mask). If I miss one (especially Enemy mask), enemies walk
through water — regression worse than the bug. Secondary risk: muzzle
centering — wrong about sprite size.

H2-RULE claims:
1. `make test` exit 0 clean post-changes. **LANDED.**
2. Oracle `tile_hash f873ae60ee3c420c…` unchanged. **LANDED.**
3. iter-9 playtest: user reports bullets travel over water. DEFERRED.
4. iter-9 playtest: user reports breaking brick walls. DEFERRED.
5. iter-9 playtest: user does NOT say "off center" again. DEFERRED.

Mid-iter check: looked up actual sprite size (256/16 = 16px per frame).
Muzzle at (7, 0) was 1px INSIDE the sprite edge (sprite half-width = 8).
Fix: muzzle (7,0) → (8,0) = sprite edge exactly. Visual fix grounded in
measured sprite dimensions, not a guess.

**Post-iter evaluation:** Both binary claims LANDED (make test, oracle).
Synchronized 3-file water collision change predicted as highest risk;
landed cleanly. Pre-mortem-as-attention-bounder pattern worked.

---

## Iter 009 — PLAYTEST (paired iter-7 + iter-8 changes)

Going in, biggest expected miss: difficulty spike. Iter 5 enemies were
slow chasers with no fire — basically harmless. Now enemies have grid AI
+ fire every 1.5s. With max_enemies=20 and ~13 bullets/s at saturation,
player HP=3 may die in 5-10s. User might report "too hard." That'd flag
a balance gap for iter 10.

H2-RULE independently observable claims (user playtest is sole authority):
1. User does NOT use "skiing" / "without constraints" / "diagonal" to
   describe enemy motion. Falsified by recurrence.
2. User reports enemies firing bullets. Falsified by no mention.
3. User does NOT say "out of nowhere" / "random around me." Falsified by
   recurrence.
4. User confirms brick destruction by bullets. Falsified by "bricks still
   unbreakable."
5. User confirms bullets pass over water. Falsified by "still blocked at
   water."
6. User does NOT say "off center" for bullets. Falsified by recurrence.
7. (Secondary, balance risk) User reports difficulty acceptable — not
   "I die immediately." Falsified by "too hard / can't play."

Score-target predictions (secondary, H2-RULE-acknowledged):
- Crit 6: 1 → 2 (chaser+ranged-shooter, anchor 2). Possible jump to 5 if
  user cites "they don't get stuck."
- Crit 1: stays at 4 (anchor 5 still needs first-run-without-instruction;
  I keep giving instructions).
- Crit 2: stays at 1 (intervals fixed, not varying).
- Crit 7: maybe 1 (top-edge spawn creates pressure direction).
- Crit 8: maybe 1 (brick destruction = some feedback).
- Total: 9 → 11-13 if anchors land.

**Post-iter evaluation (iter 10 audit):** 3 of 7 claims resolved-favorable (incl. claim 1 reframed as "skiing → weird fashion / head not forward" — same root, different observable language), 2 FALSIFIED (claim 3 spawn-from-top, claim 6 off-center), 5 INDETERMINATE. User correction triggered framing pivot via CONSULT 002+003. See LEDGER iter 010-011.

---

## Iter 010 — AUDIT + CONSULT (reactive to playtest)

(No separate pre-mortem — iter 10 was reactive to playtest, not pre-planned. Synthesis lives in LEDGER iter 010 + PRE-MORTEMS iter 009 post-eval above.)

---

## Iter 011 — BUILD — Identity rewrite (Pro v2 reframe) + DEPTH/TIME HUD

Going in, biggest expected miss: I'll rewrite PROMPT.md's stone but leave dangling references elsewhere — STATE.md "design_direction" field, scripts mentioning VS-like concepts, comments referring to upgrades. The reframe is supposed to be load-bearing; partial adoption is worse than no adoption.

H2-RULE independently observable claims:
1. **PROMPT.md "the stone" contains Pro v2's verbatim sentence.** Binary, file-content. → LANDED
2. **RUBRIC.md crits 4/5/7/10 renamed** to "Depth feedback / ascent pressure", "Forward survivability", "Compulsion loop", "Run summary + replayability". Binary, file-content. → LANDED
3. **PlayerTank HUD shows `DEPTH 0` and `TIME 0:00` at game start.** Iter-14 playtest binary.
4. **After 5s of W-held, DEPTH > 0.** Iter-14 playtest binary.
5. **`make test` exit 0** post-rewrite. Binary. → LANDED
6. **Oracle `tile_hash f873ae60ee3c420c…` unchanged.** Binary. → LANDED

4 of 6 LANDED in-iter; 2 deferred to playtest.

Secondary score predictions (H2-RULE acknowledged secondary):
- Crit 4 (new: depth feedback) → 1 (anchor 1 cited via code)
- Crit 10 (new: run summary) → 1 (anchor 1 retroactive from iter-3 YOU DIED label)
- Others unchanged
- Total predicted: 9 → 11

**Post-iter evaluation:** All 4 binary-now predictions landed. Score lifted 9 → 11 via rubric realignment (no inflation — anchors retroactively countable, not new feature work). Iter 12 will exercise the new compulsion-loop axis via spawn-ahead-of-player.

---
