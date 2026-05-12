# tanke — Gameplay Loop State

> **iter 38 advisory (PROMPT v2 active):** `loop/gameplay/PROMPT.md` was
> rewritten between iters 37 and 38. Continuity preserved (iter counter,
> LEDGER, scores, falsifications, pre-mortems, consults all carry). Read
> `loop/gameplay/META-RETRO-iter37.md` once at iter 38 start; then proceed
> per v2 PROMPT. v1 archived at `PROMPT-v1.md` for provenance.
>
> **What changed in v2:**
> - Stone rewritten (no VS-like vocabulary; ascender + BC feel only)
> - New **META** mode (alongside BUILD/CAPABILITY/AUDIT/CONSULT/SWEEP/PLAYTEST/AWAIT)
> - H1 tripwire codified in SUBSTRATE FREEZE (ProceduralLevel.tscn additions need LEDGER justification)
> - STRUCTURE/FEEL/MIXED/STRUCTURE-DEFERRED tags from H2 RULE v2 are now PROMPT-mandated for score citations
> - CONSULT SCHEDULE is adaptive (not fixed iter 10/20/30)
> - CEILING RULE extended to cover **rubric rename** (not just anchor lift)
> - Sprint authorization (user override of PLAYTEST cadence) codified
> - F-numbered falsifications + "≥3 Fs from one playtest → BUILD scope was too broad" rule
> - HALT 3-stall rule scoped to "outside sprint window"
> - ANTI-PATTERNS vocabulary refreshed
>
> No state reset. Continue iter 38 with current `falsifications_pending_playtest` and `phase: AWAITING_USER_PLAYTEST`.

## Phase

```
phase: SPRINT (iter 63 → 99) — MAP-FOCUSED per user iter-60 directive
iteration: 63
banded_biome: WIRED (warmup=playable.tres mix preserves baseline hash; first_push/heavy_gate/rush varied for gameplay depths beyond oracle window)
sprint_authorization: "User directive iter 60: 'next playtest at ITER 99' + priority: local map > enemy types > feedback/polish > roguelite mechanics"
sprint_complete_prior: yes (iter 39-60 sprint, score 20 → 32/50 incl iter-60 cite)
last_completed_playtest_iter: 60 (user cited: Q4 routing decisions; Q5 map-first directive)
mandatory_playtest_iter: 99
halt_iter_if_no_response: 102
consult_006: ADOPTED. consult_007: ADOPTED.
falsifications_pending_iter99: F009 enemy distinction, F010 visual noise artifact, F011 death-screen font, F012 map samey-ness (Pro H4 confirmed)
prompt_version: v2 (active iter 38+)
preloop_complete: yes
sprint_authorization: "User directive iter 38: 'lets schedule the next playtest in loop 60' — 21-iter sprint authorized"
last_completed_playtest_iter: 38 (Heavy wind-up: user cite "yeah ok that works for now")
design_direction: roguelike_vertical_ascender_with_battle_city_combat_feel
consult_cadence: adaptive — last 29, planned 45 (mid-sprint), 55 (pre-playtest)
ai_intelligence_stage: Stage 1 VISION + wind-up + LKP (iter 47): Heavy chases last-known position, searches 2.5s on reach, wanders upward-bias when no LKP. 3rd type Fast — harassment rusher (movement still omniscient by design).
falsifications_closed: F007, F005-v2, F006, F008
falsifications_pending_playtest: crit 6 anchor 3 [STRUCTURE] lift falsification clause (iter 60); crit 8 anchor 4 [STRUCTURE-DEFERRED → iter 60] for impact spark + hit-flash feel cite
rubric_debt: crit 8 anchor 3 (XP gems language stale post-iter-11 reframe), anchor 4 "UI counter increments" (kill count dropped iter 30) — flag for AUDIT iter ~50
mandatory_playtest_iter: 60
halt_iter_if_no_response: 63
score: 30/50 (iter 50 AUDIT +4: crit 2 +3, crit 3 +1, crit 9 +1; crit 7 stale row corrected)
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
| 2. Spawn / wave system | **4** | Iter 50 AUDIT [STRUCTURE] anchors 2/3/4: varying intervals (band interval_mult 1.25→0.7) + multiple spawn points (top + below-spawn iter 28) + spawn rate escalation (band progression) + multiple wave types (DEPTH_BANDS type_weights — Light warmup, Heavy heavy_gate, Fast rush). Anchor 5 (config-driven WaveConfig.tres) not met. Falsification clause iter 60: if user cites "spawn felt same throughout," revert to 2. |
| 3. HP + death model | **3** | Iter 50 AUDIT [STRUCTURE] anchor 3: "HP bar visible (iter 49) + hits flash player (iter 19) + death triggers run-end (iter 3)" — all verbatim met. Anchor 4 partial: iframes (damage_iframes=0.6) but damage uniform across enemies, no knockback. |
| 4. Depth feedback + ascent pressure (was XP) | **2** | Iter 15 playtest cite "feels like a run" satisfies anchor 2 (DEPTH+TIME live update) |
| 5. Forward survivability (was Upgrade variety) | **3** | Iter 60 PLAYTEST [FEEL] anchor 3: "Combat micro-decisions while ascending — which enemy to engage, which to dodge — playtest cited." User cite verbatim: "decision is in whether i can dig tunnel to ignore some enemies, how do i safely reduce the angle i engage." Routing + angle decisions = anchor 3 met. Anchor 1 (iter 12) + anchor 2 (climb rate) carry. |
| 6. Enemy variety | **3** | Iter 40 [STRUCTURE] anchor 3: 3 types with distinct movement AND firing patterns — Light (lane-invader, 3.5s rare fire, 3s lane-commit) / Heavy (paused-aim corridor-denier, 0.45s wind-up + telegraph + burst, vision-gated) / Fast (continuous-fire harasser, 1.0s fire while moving, no aim, no LOS check). Falsification clause iter 60: if user does NOT distinguish Fast → revert 3→2. |
| 7. Compulsion loop (was Run pacing) | **3** | Iter 34 [FEEL] anchor 3: "user spontaneously presses R within 5s of death" — playtest cited "5 lives this time" implied. Anchor 4 (3+ runs unprompted) implied by 5-runs cite but iter-34 conservatively held at 3. Iter 50 AUDIT: table row was stale at 0 — correction to 3. |
| 8. Impact / feedback / readability (iter 46 rename) | **3** | Iter 46 [STRUCTURE] anchor 3: multi-event impact layer — bullet impact spark on every collision (iter 41) + enemy hit-flash on non-kill (iter 41) + depth milestone visual cue (iter 30). Carries forward iter-19 hit-flash + iter-21 enemy death (anchors 1-2). Anchor 4 (camera shake on damage + above layer "feel-verified") gates on iter-60 playtest cite for shake's punch. |
| 9. HUD / state communication (iter 46 rename) | **4** | Iter 50 AUDIT [STRUCTURE] anchor 4: "Best-depth visible during run OR low-HP warning state cue (color shift / blink)" — second clause met verbatim by iter-49 red shift at hp/max<0.34. Anchor 3 met (iter 49 HP bar). Anchor 5 ("first-time user navigates death→restart without instruction — playtest cited") requires [FEEL] cite. |
| 10. Run loop closure (iter 46 rename; anchors tightened) | **3** | Iter 46 [STRUCTURE] anchor 3 (post-rename): "Death screen shows best-depth + NEW BEST highlight when run > prior — code-citable" — iter 44 ship matches verbatim. Carries: anchor 2 (depth+time+kills+stall) iter 43. Anchors 4-5 require iter-60 playtest cite ("I want one more" / "I want to beat my best"). |
| **Total** | **32/50** | Iter 60 PLAYTEST +2: crit 5 1→3 [FEEL] (Q4 cite "dig tunnel / reduce angle"). Other cites partial/negative — see F009-F012 falsifications. |

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
Iter 36 PLAYTEST request issued. AWAITING USER.
Build verified (make test + headless exit 0).
2-question prompt covering 4 F005-F008 verifications.
Halt rule iter 39.
Score unchanged 20/50.
```

(Previous)

```
Iter 35 BUILD complete. F005-F008 fixes + Heavy vision-cone Stage 1.

F005 Heavy vision-cone:
  Enemy.gd _player_in_line_of_sight rewritten. Vision = cardinal forward
  cone (forward_dist > 0, lateral < 12px, range < 80px) + raycast through
  env layer 1 (no x-ray through walls). Heavy must FACE player AND have
  clear LOS. Per .research/battle-city-ai.md Stage 1.

F006 Map walls:
  scenes/ProceduralLevel.tscn: new Walls Node2D + LeftWall/RightWall
  StaticBody2D at x=-4, x=324, layer=1, shape RectangleShape2D(8, 8000).
  H1 tripwire: 2 siblings (Spawner + Walls), under cap of 3.

F007 Water collision:
  scenes/WaterBlock.tscn format=2 → format=3 with explicit
  RectangleShape2D size=(8,8). Hypothesis: format-2 auto-migration
  silently failed; explicit format-3 is robust.

F008 Below-spawn threshold raise:
  Spawner.gd stall_below_spawn_after 8→12s, below_spawn_cooldown 6→10s.
  Conservative tweak; real rows-per-N-sec fix deferred if user still
  complains.

Verified: make test exit 0, oracle f873ae60ee3c420c… unchanged.
Substrate intact iters 1-35.

Score unchanged at 20/50. Iter-36 PLAYTEST verifies feel.

Next: iter 36 mandatory PLAYTEST.
```

(Previous)

```
Iter 34 AUDIT complete. User played 5 lives unprompted → "good" +
4 falsifications (F005-F008) + design directive ("vision first,
transmission second") + /research request.

H2-RULE iter-33 eval:
- Slot 1 META (keep climbing?): PARTIAL — user didn't verbatim-pick
  but 5-runs-in-session = behavioral META resolution
- Slot 2: 4 specific complaints (Heavy too smart, map border, water
  doesn't block, below-spawn fires too freely)

Score: crit 7 (Compulsion loop) 0 → 3 [FEEL]. Total 17 → 20/50.
First [FEEL] playtest-cite since iter 15.

Research dispatched via /research skill. Saved to
.research/battle-city-ai.md. Key finding: original BC AI is
fundamentally DUMB (no vision, no aiming, no pathfinding). My iter-24
Heavy is omniscient = "too smart" per user. Vision-cone + raycast =
Stage 1 of user ladder, iter 35 target.

Next: iter 35 BUILD — F006 map walls + F007 water fix + F005 Heavy
vision-cone rework.
```

(Previous)

```
Iter 33 PLAYTEST request issued. AWAITING USER.
Halt rule iter 36 if no response.

2-question playtest prompt:
1. LOAD-BEARING (Pro v5 H3 META test): "What did the game seem to want
   you to do — clear enemies, survive in place, or keep climbing?"
2. WILDCARD: "Anything off/surprising/broken?"
3. BONUS: paste [run] line from Output dock if seen

Sprint (iters 18-32) complete:
- Visual juice: hit-flash + enemy death particle
- Identity: PROMPT/RUBRIC reframed to roguelike-ascender + DEPTH/TIME HUD
- Spawn: ascent director (DEPTH_BANDS) + graduated stall + below-spawn
  threats-from-behind + visible telegraphs (red below, yellow top)
- Enemy variety: Heavy CHASE/AIM_FIRE state machine + Light commit-to-lane
- Polish: depth milestone flash (green pulse every 10 rows)
- Instrumentation: [run] summary + spawn origin distribution

Score 17/50 (+3 over iter 17 baseline; iter-22 rubric tightening -1
makes current 17 honest 17, not pre-tightening 18).
```

(Previous)

```
Iter 32 prep complete. Final pre-playtest verification:
- make test exit 0
- godot --headless --quit exit 0 (no warnings)
- Oracle tile_hash f873ae60ee3c420c… unchanged
- Iter-33 playtest prompt drafted per 2-question template + Pro v5 H3
  language-based META test:
  * Slot 1 LOAD-BEARING: "What did the game seem to want you to do?"
    (clear / survive / climb) — META resolution test
  * Slot 2 WILDCARD: "Anything off/surprising/broken?"
  * Bonus: [run] line from Output dock (iter-31 instrumentation)
- No code changes. No new features (per Pro v5 H4).
- Score unchanged at 17/50.

Sprint complete (iters 18-32, 15 iters of solo work between playtests).
Score trajectory 14 → 17 (+3 net; iter-22 rubric tightening was -1).

Next: iter 33 issues the playtest prompt. AWAIT user. Halt rule iter 36.
```

(Previous)

```
Iter 31 CAPABILITY complete. Ascender metric instrumentation:
- PlayerTank: _stall_time_total cumulative; _die() prints
  [run] depth=N time=M:SS ascent_rate=R rows/s stall_total=S (P%)
- Spawner: spawn_origin_top + spawn_origin_below counters
- Debug print enriched: spawns=N (top=A below=B)
- Substrate freeze respected — test_runner.gd untouched; instrumentation
  in existing PlayerTank/Spawner scripts
- 15s headless verified: spawn origin distribution captured correctly
  (top=3 below=1 when stall > 8s threshold + cooldown)
- Run-summary line fires on death (won't show in stationary headless;
  appears in iter-33 actual playtest)

Score unchanged at 17/50.
Next: iter 32 playtest prep (compose 2-question prompt per iter-23 template).
```

(Previous)

```
Iter 30 BUILD complete. Pro Consult 005 ascent legibility redirect:
- DROPPED kills counter HUD (Pro v5 H4: teaches wrong objective)
- FIXED below-spawn telegraph visibility bug: marker now placed INSIDE
  viewport bottom edge (12px inside); enemy still spawns at off-screen
  position. Red color for "behind" distinction. Pro v5 H2 fix.
- ADDED depth milestone flash: DEPTH label scales 1.8× + recolors green
  for 0.12s when crossing every 10th depth row. "Readable upward intent"
  per Pro v5 META.
- PATCHED band-cap recheck post-telegraph-await (Pro v5 H5 minor code
  issue): _telegraph_then_spawn now uses _current_band().max_alive
  instead of global max_enemies.
- Verified: make test exit 0, oracle f873ae60ee3c420c… unchanged
- Scores unchanged at 17/50 (polish-only iter)

Pro Consult 005 caught critical iter-28 fairness bug (below-spawn marker
was off-screen, would have felt like hidden punishment at iter-33 playtest)
and a kills-counter cargo-cult trap (drops from plan).

Next: iter 31 CAPABILITY — extend test_runner with ASCENDER metrics only
per Pro v5 H4.
```

(Previous)

```
Iter 29 CONSULT retry SUCCEEDED. Fired tanke-iter-29-revalidate agentify
query. fireAndForget. 7/9 files inlined, 99K context. Asked:
- H1 Light split adequacy
- H2 below-spawn risk
- H3 META resolution status
- H4 sprint plan remaining
- H5 anti-cargo-cult on crit 2 lift
- META: single missing thing for iter-33 ascent-feel test

Score unchanged at 17/50.
Iter 30 reads Pro response.
```

(Previous)

```
Iter 28 BUILD complete. META mitigation — threats-from-behind:
- Spawner.gd: new exports stall_below_spawn_after=8s,
  below_spawn_cooldown=6s, spawn_bottom_edge_offset=8px
- New _should_spawn_below() gates on stall + cooldown
- _find_valid_spawn branches: if eligible, spawn at camera_bottom +
  offset (below viewport); else top-edge default
- _last_below_spawn_time tracks for cooldown
- Combined with iter-27 graduated stall: stalling now costs
  (faster spawns + occasional spawn-from-behind) → Pro v4 META
  "rewards for maintaining upward motion" + "threats from behind"
- Verified: make test exit 0, oracle f873ae60ee3c420c… unchanged
- Score unchanged at 17/50 (reinforces crit 4 anchor 4 [STRUCTURE-
  DEFERRED → iter 33])
Next: iter 29 CONSULT retry.
```

(Previous)

```
Iter 27 BUILD complete. Per-band encounter rules + graduated stall:
- DEPTH_BANDS: each band has max_alive cap (warmup 4, first_push 10,
  heavy_gate 8, rush 16) + guarantee_first_type (heavy_gate=Heavy,
  rush=Light; sets band tone on entry)
- Graduated stall multiplier (replaces binary): linear ramp 1.0 → 0.4
  between 4s and 12s stall. At full stall, spawn rate 2.5× faster.
- _try_spawn: per-band cap blocks spawn but tick print still fires
  (with CAP marker)
- _pick_enemy_type: honors band-entry guarantee_first_type
- Verified 25s headless: stall=9.9s→stallMult=0.56, stall=15.1s→0.40
  (floored). Band cap correctly blocks at 4/4.
- Crit 2 1 → 2 [STRUCTURE] (anchor 2 wording unambiguous, no playtest
  qualifier). Total 16 → 17/50.

Next: iter 28 META mitigation (forward enemies / threats-from-behind /
open lane).
```

(Previous)

```
Iter 26 BUILD complete. Light commit-to-lane behavioral split:
- Spawner ENEMY_TYPES["Light"]: fire_cooldown 1.5 → 3.5, NEW
  direction_commit_time = 3.0 (commits to lane per Pro v4 H2 recipe)
- Spawner ENEMY_TYPES["Heavy"]: NEW direction_commit_time = 0.8
- Spawner _telegraph_then_spawn also sets direction_commit_time per type
- Enemy.gd _light_tick: uses new _choose_direction_light_lane with
  vertical bias (prefer U/D unless |dx| > 2× |dy|). Light invades
  vertical lanes toward player rather than tracking precisely.
- Heavy unchanged from iter 24
- Verified: make test exit 0, oracle f873ae60ee3c420c… unchanged
- Score: unchanged at 16/50 (reinforces crit 6 anchor 2 already met
  iter 24; no new anchor satisfied).
Next: iter 27 BUILD per-band encounter rules + stall pressure tuning.
```

(Previous)

```
Iter 25 CONSULT attempt FAILED (agentify tab_busy after closing 3 stale
tabs) → SELF-CONSULT fallback per FALSIFICATION 001 lesson.

Self-consult H1-H5 + META in LEDGER iter 025. Key conclusions:
- Heavy state machine adequacy: HOLDS conditional; flag heavy_gate 60%
  Heavy as potential bullet-wall risk
- Light split iter 26: Option C (commit-to-lane, dir_commit 3s,
  fire 3.5s, vertical bias)
- iter-33 prediction still load-bearing
- Sprint plan revised: drop iter-31 death-summary as separate iter
  (fold kills counter into polish); ADD iter-31 CAPABILITY (extend
  test_runner with ascender metrics); CONSULT retry pushed to iter 29.

Scores unchanged at 16/50 (process iter).

Next: iter 26 BUILD Light commit-to-lane.
```

(Previous content)

```
Iter 24 BUILD complete. Heavy CHASE/AIM_FIRE state machine:
- Enemy.gd refactored: enum State {CHASE, AIM_FIRE}, enemy_type
  export, _heavy_tick + _light_tick dispatch in _physics_process
- Heavy CHASE: locomotes like Light + LOS check → AIM_FIRE
- Heavy AIM_FIRE: stop, face_player, fire 2-shot burst at 0.25s
  interval, 0.8s cooldown, exit on lost-LOS after 0.4s min dwell
- _player_in_line_of_sight: cardinal alignment <12px off-axis, <80px range
- Spawner passes enemy.set("enemy_type", type_data.name) on spawn
- Light unchanged (naive chase + 1.5s fire_cooldown)
- Verified: make test exit 0, oracle f873ae60ee3c420c… unchanged
- Crit 6 1 → 2 [STRUCTURE-DEFERRED → iter 33]. Total 15 → 16/50.

Pro Consult 004 H2 recipe ("corridor-denier that pauses and fires
bursts") implemented verbatim.

Next: iter 25 CONSULT — validate Heavy state machine + plan iter 26.
```

---

## Stale Scores

None (new loop).

---

## Next Action

`AWAITING user playtest response.

On response (iter 37):
  - Evaluate 4 F-verification claims + new Heavy-movement-still-omniscient risk
  - Update scores per playtest evidence
  - If Heavy still feels too smart: iter 37 reworks _choose_direction_toward_player
    for Heavy to be vision-aware (random wander until sees player, then chase)
  - If F005-F008 all confirmed closed: F005-F008 close in FALSIFICATIONS.md,
    score crit 6 anchor 2 cited via [FEEL]
  - If new bugs: iter 37 fixes
  
Halt rule iter 39.`

---

## Previous Next Action (iter 35 → iter 36 shipped)

`Iter 36 PLAYTEST (mandatory; verifies F005-F008):
  - Pre-mortem H2 RULE v2 tag declaration
  - Verify build (make test + headless boot)
  - Compose 2-question prompt per template, focused on:
    * Slot 1: Heavy AI behavior — does it now feel like Heavy needs to
      SEE you to shoot (vision cone + walls block)? Or still cheaty?
    * Slot 2: Water blocks now? Tanks stay in map?
  - Bonus: [run] line for quant correlation
  - AWAIT user response. Halt rule iter 39.

If user reports Heavy still cheaty → F005 fix didn't land properly,
debug raycast / cone math
If user confirms F005-F008 closed → F005 anchor reinforces crit 6
under [FEEL] cite ("Heavy needs to see me"). Crit 6 might go 2 → 3
(third+ types — except we don't have third type yet... wait, anchor
sequence requires 3+ types, so crit 6 caps at 2 until iter 37+ adds
third type).
If user surfaces new bugs → iter 37 fixes.`

---

## Previous Next Action (iter 34 → iter 35 shipped)

`Iter 35 BUILD — Critical fixes + Heavy vision-cone Stage 1:
  - Pre-mortem H2 RULE v2 tag declaration
  - Sub-task 1 (F006 map border walls):
    * scenes/ProceduralLevel.tscn: add 2 StaticBody2D children with
      CollisionShape2D RectangleShape2D, layer=1 (env), at x=-4 (left
      wall) and x=324 (right wall), full vertical span (or tall enough
      to cover all generated rows; e.g., size=Vector2(8, 8000)).
    * Verify oracle (substrate-extension, should pass)
  - Sub-task 2 (F007 water collision verification):
    * grep WaterBlock.tscn for current collision_layer
    * trace Level.gd _replace_blocks to confirm WaterBlock is
      instantiated from water tilemap cells
    * test player drives onto water tile — expected block; observed?
    * fix root cause (collision_layer regression OR _replace_blocks
      water path missing OR mask issue)
  - Sub-task 3 (F005 Heavy vision-cone Stage 1):
    * scripts/Enemy.gd: replace _player_in_line_of_sight() with
      vision-cone-in-facing-direction + raycast through env layer 1
    * Implementation per .research/battle-city-ai.md Stage 1:
      - forward_dist = to_player.dot(dir_vec); reject if ≤0 or > vision_range
      - lateral_dist = absf(to_player.dot(perpendicular(dir_vec))); reject if > vision_lateral_tolerance
      - raycast from self to player on env layer 1; reject if hit
    * Add @export vars: vision_range=80, vision_lateral_tolerance=16
    * Heavy now only spots player when facing them AND no wall between
    * Expected effect: Heavy nerf, more BC-like
    * Tag: [STRUCTURE-DEFERRED → iter 36] for crit 6 anchor 2 reinforcement
  - Verify make test + oracle
  - Commit; ScheduleWakeup 240s
  - Iter 36 = mandatory PLAYTEST (per "every 3 iters" cadence)`

---

## Previous Next Action (iter 33 → iter 34)

`AWAITING user playtest response.

On response (iter 34):
  - Evaluate 5 H2-RULE claims (especially load-bearing slot-1 META test)
  - Log FALSIFICATIONS for any miss (iter-22-style scoring honesty)
  - Update scores per RUBRIC.md anchors using playtest evidence
    * Multiple anchors poised under [STRUCTURE-DEFERRED] — feel-criterion
      lifts unlocked: crit 4 anchor 4 (stalling pressure), crit 6
      anchor 5 (no stuck), crit 7 (compulsion), crit 8 ≥1 (visual feel)
  - Parse [run] line if user pastes it — ascent_rate + stall_total
    correlate with feel reports
  - Plan iter 35 BUILD per outcome
  - PROMPT §"CONSULT SCHEDULE" iter 10/20/30 — iter 33 is 33; next
    scheduled CONSULT at iter 40 (post-playtest)

If no response by iter 36: write HALTED.md per PROMPT §"USER-LOOK PROTOCOL"
halt rule; stop.`

---

## Previous Next Action (iter 32 — iter 33 shipped)

`Iter 33 — Issue playtest request:
  - Pre-mortem (H2 RULE v2 tag declaration for the load-bearing iter-33
    prediction: per Pro v5 H3, "user picks 'keep climbing' or names
    ascent-language unprompted = META resolved")
  - Update STATE.md phase → AWAITING_USER_PLAYTEST, iteration 33
  - Output the iter-32-drafted 2-question playtest prompt to user
  - NO ScheduleWakeup (AWAIT per PROMPT §7)
  - Halt rule: iter 36 if no user response within 3 iters

If user responds: iter 34 = AUDIT (eval 2 H2-RULE claims), iter 35 =
BUILD per outcome. If user says "keep climbing" → META resolved, focus
shifts to remaining anchors. If user says "clear enemies" → META still
broken, iter 35-37 deepen meta-mit (third behavioral split? skippable
band?).`

---

## Previous Next Action (iter 31 — iter 32 shipped)

`Iter 32 — Final playtest prep:
  - Pre-mortem (H2 RULE v2): tag declaration
  - Verify build: make test + godot --headless --quit both exit 0
  - Capture run config delta since iter-17 playtest (~14 iters of work)
  - Compose iter-33 playtest prompt per 2-question template
    (loop/gameplay/playtest-template.md):
    * Slot 1 LOAD-BEARING: per Pro Consult 005 H3 — language-based test:
      "What did the game seem to want you to do — clear enemies, survive
      in place, or keep climbing? Answer in your own words."
    * Slot 2 WILDCARD: "Anything off, surprising, or broken?"
  - Don't add more features per Pro v5: "Do not add a new enemy, power-up,
    death summary, economy, upgrade system, or terrain feature before
    iter 33."
  - Commit; ScheduleWakeup 240s
  - Iter 33: PLAYTEST request issued to user, AWAIT response

H2-RULE prediction for iter 32: I'll be tempted to ship "one more
polish" instead of just preparing the playtest. Resist. Iter 32 = pure
prep + no new features.`

---

## Previous Next Action (iter 30 — iter 31 shipped)

`Iter 31 CAPABILITY — Extend test_runner.gd with ASCENDER metrics:
  - Pre-mortem H2 RULE v2: [STRUCTURE] tagged (oracle-test instrumentation).
  - Per Pro v5 H4: instrument ascent-quality metrics, NOT kill counts.
    Specifically:
    * ascent_rate_avg (rows/sec averaged over run frames)
    * stall_time_total (cumulative seconds with ascent_velocity below threshold)
    * spawn_origin_top_count vs spawn_origin_below_count
    * time_since_last_depth_gain (final value at quit)
    * Per-band: time_in_band, kills_in_band (KILLS PER BAND is OK because
      contextualizes density, not a goal metric)
  - Spawner.gd already has spawns_total/rejections_total/ticks_total —
    extend with origin distribution counters.
  - test_runner.gd already collects post-generation tile counts; add
    runtime aggregates by instrumenting the live scene for N frames.
  - Output: JSON with the new fields appended.
  - Verify make test + oracle (tile_hash should still match — this is
    additive instrumentation, no gameplay change).
  - Score: no new anchor.
  - Commit; ScheduleWakeup 240s.

Iter 32 = final playtest prep using 2-question template per iter 23.
Iter 33 = PLAYTEST (paired iters 18-30 work).`

---

## Previous Next Action (iter 29 — iter 30 shipped)

`Iter 30 BUILD — Read Pro consult response, integrate, then polish:
  - agentify_status / read_page for key tanke-iter-29-revalidate
  - Append Consult 005 to creative-consults.md
  - If Pro adopts existing plan: BUILD kills counter HUD (10 lines, fold
    into polish iter) + any small Pro-recommended polish
  - If Pro redirects: plan accordingly
  - Score iter 30 honestly per H2 RULE v2 tags
  - Commit; ScheduleWakeup 240s

Iter 31 CAPABILITY: extend test_runner.gd with ascender metrics if Pro
endorses; else swap to additional gameplay polish.`

---

## Previous Next Action (iter 28 — iter 29 shipped)

`Iter 29 CONSULT (retry after iter-25 failure, per 5-iter cadence):
  - Tab cleanup if max_tabs_reached recurs (close tanke-iter-2-secondopinion
    etc. as stale)
  - Fire /agentify with:
    1. iter 27-28 work review (graduated stall + below-spawn)
    2. Light commit-to-lane validation (iter 26)
    3. Plan iter 30-32 polish + CAPABILITY + playtest prep
    4. Re-check iter-33 prediction
  - If agentify fails again → self-consult
  - fireAndForget, read iter 30

Iter 30 = polish + kills counter HUD + read consult response`

---

## Previous Next Action (iter 27 — iter 28 shipped)

`Iter 28 BUILD — META mitigation (combat vs ascender tension):
  - Pre-mortem H2 RULE v2 tag declaration
  - Pro Consult 004 META options:
    (a) Forward-only enemy that doesn't lateral-track — dodgeable by side step
    (b) Threats-from-behind: enemies spawning BELOW player force upward push
    (c) "Open lane" band variant that's skippable without clearing
  - Choose ONE. Likely (b) — most direct addressing of "user stops to
    clear instead of pushing upward." Threats-from-behind = scary
    enough that player wants to escape upward.
  - Implementation if (b): periodic spawn from BOTTOM edge of camera
    view (below player). These enemies converge on player from below.
    Player who keeps moving up = always at safe distance; player who
    stalls = caught.
    * Spawner adds optional bottom_spawn flag per band? Or constant low
      rate of bottom-spawns regardless of band?
    * Simplest: at certain depths or stall conditions, spawn 1 enemy
      below player. Heavy or Light same as top.
  - Smaller scope alternative: tune existing graduated stall to spawn
    1 enemy at BOTTOM after sustained stall (e.g., stall_time > 8s →
    spawn from below). Limited frequency.
  - Score: probably no new anchor lift. Crit 4 anchor 4 "stalling
    produces visible pressure" already qualified [STRUCTURE] but has
    [FEEL] requirement for >2.
  - Tag: [STRUCTURE-DEFERRED → iter 33]

Iter 29 = CONSULT retry (per cadence + addressing iter-25 failure).`

---

## Previous Next Action (iter 26 — iter 27 shipped)

`Iter 27 BUILD — Per-band encounter rules + stall pressure tuning:
  - Pre-mortem (H2 RULE v2 tag declaration)
  - DIAGNOSE: ascent director bands currently differ only in type_weights
    and interval_mult. Encounter "rules" could include:
    * Min/max enemies alive per band (heavy_gate caps at 5? rush caps at 12?)
    * Spawn-specific rules per band (e.g., heavy_gate guarantees first
      spawn = Heavy)
    * Stall pressure graduated: currently binary 4s threshold; ramp
      progressively (e.g., 4s → 1.5× interval, 8s → 2× interval cap)
  - Implementation:
    * Add max_enemies_alive_band override per band (default = global
      max_enemies)
    * Add guarantee_first_type optional per band (e.g., heavy_gate first
      spawn is Heavy regardless of weights — sets initial threat tone)
    * Replace binary stall multiplier with graduated function:
      stall_multiplier(stall_time) = clampf(1.0 - 0.1*(stall_time-4)/2, 0.4, 1.0)
      So 4s stall = 1.0, 8s = 0.6, 12s = 0.4 (cap)
  - Score predictions: no new anchor lifts (crit 4 anchor 4 "stalling
    pressure" already at 2; anchor 4 needs playtest cite for >2)
  - Tag: [STRUCTURE] / [STRUCTURE-DEFERRED] — no FEEL cite without playtest

Iter 28: META mitigation (forward-only enemies or threats-from-behind).`

---

## Previous Next Action (iter 25 — iter 26 shipped)

`Iter 26 BUILD — Light commit-to-lane behavioral split:
  - Pre-mortem with H2 RULE v2 tag declaration
  - Tag: [STRUCTURE-DEFERRED → iter 33] for crit 6 anchor 2 reinforcement
    (anchor 2 already met iter 24 via Heavy state machine; Light split
    is reinforcement, not new anchor)
  - Enemy.gd Light branch (in _light_tick) changes:
    * direction_commit_time effectively extended for Light (override per-
      type via Spawner enemy.set?). Or add Light-specific @export
      light_direction_commit_time = 3.0
    * fire_cooldown for Light → 3.5s (currently 1.5s default; Spawner sets
      from ENEMY_TYPES so update Light entry)
    * _choose_direction_toward_player for Light: add vertical bias —
      if absf(dx) and absf(dy) within 20% of each other, prefer vertical
      direction. Otherwise unchanged.
  - Update Spawner.gd ENEMY_TYPES["Light"] fire_cooldown 1.5 → 3.5
  - Verify make test + oracle
  - Score: no new anchor lift (crit 6 stays at 2 — Light split reinforces
    existing role distinction). But the split DOES make the role
    distinction more LEGIBLE which strengthens [STRUCTURE-DEFERRED] tag.
  - Commit; ScheduleWakeup 240s

Iter 27 BUILD = per-band encounter rules + stalling pressure tuning.`

---

## Previous Next Action (iter 24 — iter 25 attempted, fell back to self-consult)

`Iter 25 CONSULT (per cadence — every 5 iters):
  - Pre-mortem H2 RULE v2 tagged
  - Fire /agentify with current state (post-iter-24 Heavy state machine).
    Questions:
    1. Heavy CHASE/AIM_FIRE state machine — does the BEHAVIORAL split
       map to anchor 2's role-distinction intent? Are there obvious
       gaps (e.g., LOS proxy is naive)?
    2. iter-26 Light behavioral split ("lane-invader, advances
       aggressively, fires rarely"). Best impl approach?
    3. Per Pro v4 META (combat verbs vs ascender verbs): does Heavy
       AIM_FIRE partially address this (player can dodge if they
       keep moving — Heavy must align then commit to a 0.8s pause)?
       Or does it INTENSIFY the contradiction (player must stop to
       not get hit by burst, breaking ascender flow)?
    4. Status check: load-bearing iter-33 prediction still right?
  - fireAndForget, read iter 26.

Iter 26 BUILD = Light behavioral split + Pro Consult 005 integration.`

---

## Previous Next Action (iter 23 — shipped iter 24)

`Iter 24 BUILD — Heavy behavioral split (corridor-denier state machine):
  - Pre-mortem (H2 RULE v2): tag declaration upfront. Expected tag for
    crit 6 lift: [STRUCTURE-DEFERRED → iter 33] — code-citable role
    distinction (state machine), feel verification deferred to playtest.
  - DIAGNOSE: crit 6 at 1 (post-revert). Anchor 2 wording (per iter 22
    rewrite) requires "distinct battlefield roles visible within 10 seconds."
    Heavy as corridor-denier = role distinction.
  - Enemy.gd state machine:
    * enum State { CHASE, AIM_FIRE }
    * Only Heavy type uses state-machine; Light stays naive
    * AIM_FIRE: stop moving, face player direction, fire 2-3 burst
    * Transition CHASE → AIM_FIRE: when player in roughly same row/col
      AND within ~80 px (line-of-sight proxy)
    * Transition AIM_FIRE → CHASE: when player out of LOS for N frames
      OR burst complete
  - Score predictions:
    * Crit 6: 1 → 2 [STRUCTURE-DEFERRED → iter 33]
    * Tagged self-deception check: if Pro saw this code, would they
      reword anchor 2 again? — Stricter wording from iter 22 demands
      visible role distinction. Heavy CHASE/AIM_FIRE alternation IS a
      role distinction. Should hold.
  - Commit; ScheduleWakeup 240s.

Iter 25 CONSULT (per cadence): fire /agentify to validate iter-24
implementation feel-delivery vs structure-only.`

---

## Previous Next Action (iter 22 — shipped as iter 23)

`Iter 23 AUDIT (every-5-iters cycle):
  - Pre-mortem (H2 RULE: reference-language for iter-33 — sharper version)
  - Re-score with fresh eyes per current scores 15/50
  - Run longer headless (60-90s, simulated movement or just measure
    bands at depth 0). Verify band-transitions are detectable.
  - Open question: how do I drive headless player UP to test band
    transitions at depth 8/20/40? Maybe a hidden test mode that auto-moves
    PlayerTank up. Or use --remote-debug to inject Input events. Or just
    rely on iter-33 user playtest for band verification.
  - Decide whether iter 23 builds a test driver OR proceeds straight to
    iter 24 Heavy behavioral split.
  - Most likely: brief AUDIT, plan iter 24 BUILD detailed.

Iter 24 BUILD plan: Heavy behavioral split — corridor-denier:
  - Heavy doesn't always chase. Instead: if line-of-sight to player,
    pause + face + fire 2-3 shot burst. Otherwise advance slowly toward
    last known player position.
  - State machine in Enemy.gd: states = CHASE, PAUSE_FIRE.
  - Transition: see player + at firing range → PAUSE_FIRE. Player out
    of LOS or moved → CHASE.
  - Only "Heavy" type uses this state machine; "Light" stays naive chaser.
  - Light's behavioral split (rare fire + aggressive forward) lands iter 26.`

---

## Previous Next Action (iter 21 — shipped iter 22)

`Iter 22 — read Pro response (should be done by now), plan BUILD:
  - agentify_status / agentify_read_page for key tanke-iter-20-creative
  - If Pro responded: synthesize, append Consult 004 to creative-consults.md, integrate
  - If still pending (unlikely after 8+ min): proceed with default roadmap
  - Default iter 22 BUILD: brick destruction visual feedback (small puff
    on brick break, similar pattern to enemy death burst but smaller/whiter)
  - Score + commit + ScheduleWakeup 240s

Iter 23 = AUDIT (every-5-iters cycle).`

---

## Previous Next Action (iter 21 — shipped iter 21 BUILD)

`Iter 21 — read Pro response, plan BUILD:
  - agentify_status / agentify_read_page for key tanke-iter-20-creative
  - Evaluate H1-H5 responses + META
  - Append Consult 004 entry to creative-consults.md
  - If Pro says continue Phase A: BUILD enemy death particle (per
    original roadmap; lifts crit 8 anchor 2 "Hit flash + enemy death")
  - If Pro redirects: plan accordingly; document the pivot
  - Score iter 21 per the build that lands
  - Commit; ScheduleWakeup 240s

Iter 22: Phase A continuation (brick destruction visual) or whatever
Pro recommended. Iter 23: AUDIT.`

---

## Previous Next Action (iter 20 — shipped as the consult fire)

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
