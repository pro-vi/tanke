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

## Consult 002 — End-of-iter-9 — GPT-Pro extended thinking — LOOP REFRAME (Pro v1, SUPERSEDED by Consult 003)

**⚠️ SUPERSEDED:** This consult's synthesis was based on a static-base-defense BC clone framing. User correction iter 10 invalidated that ("the map is procedurally generated toward the up — player must keep moving towards up... thats where rogue like can happen"). See Consult 003 below for the corrected synthesis adopted iter 11. Retained for historical record.

---



**When:** Fired iter 10 (2026-05-11 ~13:14 PT); returned ~13:17 PT, durationMs 191252 (~3.2 min)
**Agentify key:** `tanke-iter-10-reframe`
**Conversation URL:** https://chatgpt.com/g/g-p-69c9d0b3c3b88191872d6b59cb5adfb8-agentify/c/6a018b7c-23a0-83e8-8014-26b078f5845a
**Context inlined:** 8 files (PROMPT.md, RUBRIC.md, STATE.md, FALSIFICATIONS.md, META-RETRO.md, PlayerTank.gd, Enemy.gd, Spawner.gd) — 62,935 of 90,000 char budget. PlayerTank.tscn included as gd code; lesson from Consult 001 (always send .tscn for collision questions) was applied to player files.

### Trigger

User instruction at iter 9 playtest response: "i want a loop where you are the ConcernedApe copying 牧場物語 — we are copying battlecity. fire /agentify then come up with your own response"

This was both:
- A framing pivot (VS-like → Battle City)
- An instruction to consult Pro AND respond independently (synthesis, not delegation)

### Five hypotheses Pro challenged

H1 — Battle City framing is right
H2 — Rewrite RUBRIC with BC features
H3 — Procedural vs hand-crafted tension
H4 — H2 RULE for feel-based goals
H5 — ConcernedApe analog implies slow pace

### Pro's response (verbatim, with my synthesis)

**H1 — HOLDS:** "The VS-like framing is now actively misleading. The assets, the user's repeated playtest language, and the fixes already shipped all point at Battle City. The danger is not 'too imitative'; the danger is pretending this is still a Vampire Survivors tank game while quietly implementing Battle City one bug report at a time. But the north star should not be 'Battle City clone' full stop. It should be 'Battle City feel, procedural campaign twist.' Copying the reference gives discipline; the procedural substrate gives identity. Pure clone is a ceiling. Procedural Battle City is a premise."

→ **Synthesis:** Adopt BC framing. Phrase carefully: "Battle City feel, procedural campaign twist" (Pro) — better than my "Battle City clone with procedural twist" because "clone" suggests imitation ceiling. Pro is right that the procedural substrate is the IDENTITY, not a curse.

**H2 — BREAKS my rubric proposal:** "The proposed rubric overcorrects. Rewriting the whole rubric into a checklist of Battle City features will produce cargo-cult scoring: 'helmet exists,' 'shovel exists,' '35 levels exist,' 'two-player exists,' while the game still feels wrong. Base defense is load-bearing eventually, but not before movement, shooting, enemy readability, terrain semantics, and spawn pressure are solid. Two-player co-op is especially dangerous: it is iconic, but it explodes scope and should not be a core rubric axis yet. The rubric should replace VS-specific axes — XP, modal level-ups, upgrade builds — with BC-specific axes, but keep 'feel' and '30-second playtest dignity' as first-class."

→ **Synthesis:** Adopt the BC framing for the 3 VS-specific criteria (4, 5, 10) but as ABSTRACT feel axes, NOT feature checklists. Specifically:
- Crit 4 (was XP/level-up flow): "Wave/threat progression feel" — does enemy pressure escalate believably?
- Crit 5 (was Upgrade variety): "Power-up presence and feel" — when implemented, do power-ups make a visible feel difference, not just "exist"?
- Crit 10 (was Build distinctness): "Base/identity stakes" — does the player understand what they're defending and feel its loss?

Co-op explicitly DROPPED from rubric per Pro's scope-grenade warning.

**H3 — BREAKS the binary:** "'Procedural vs. Battle City' is a false binary. Hand-authored Battle City maps are not sacred because they are hand-authored; they are sacred because they create recognizable combat problems: lanes, base vulnerability, brick fortresses, water denial, forest concealment, steel choke points, spawn pressure from top. A procedural generator can target those motifs. The middle path is the right one: procedural-with-templates. Keep Eller's maze as substrate, then stamp BC motifs into it: bottom-center base fort, three top spawn gates, destructible brick pockets, steel anchors, water/forest patches, and guaranteed lanes. Do not add a hand-crafted mode as primary; that abandons the one novel thing the project already has."

→ **Synthesis:** This is the major design insight. **Procedural-with-templates** — keep Eller's algorithm (substrate freeze respected) but POST-PROCESS the generated map by stamping BC motifs at canonical positions. Concrete:
- Base fort: insert a 3×3 brick ring around bottom-center (where player spawns); base sprite at center
- Three top spawn gates: clear 1-cell-wide vertical lanes at x=80, 160, 240 in the topmost generated row
- Steel anchors: reserve corner cells in alternating rows for steel (chokepoint markers)
- Water/forest patches: at biome interpolation seam-points, force water and grass (those layers exist already)
- Guaranteed lanes: post-process to ensure 1+ vertical path from each top gate to base

This is iter-12+ work. Iter 11 = base + template-stamping start.

**H4 — HOLDS:** "Clone-feel loops need different discipline than metric loops, but that does not mean abandoning observables. The pre-mortem should stop predicting abstract 'fun' and start predicting reference-specific user language: 'enemy looked like player,' 'spawn felt unfair,' 'movement felt slippery,' 'brick didn't behave like Battle City,' 'I didn't know what I was defending.' Between user tests, use proxies: sprite direction correctness, spawn offscreen verification, terrain collision matrix, bullet/brick/steel/water truth table, base damage simulation, enemy readability screenshots, and a 'Battle City mechanic parity checklist.' The rule remains: every iter must predict something a player or oracle can contradict."

→ **Synthesis:** Upgrade the H2 RULE. Pre-mortems for feel iters must predict **reference-specific user language** (verbatim phrases the user is likely to use or not use) rather than abstract scoring. Between playtests, automate proxies: a BC truth-table oracle (does bullet pass water? brick destroyed by 1 hit? steel survives bullet? forest hides tank? top spawn off-screen?). This becomes a CAPABILITY-mode iter at some point (iter 14 or 15).

**H5 — BREAKS my speed analog:** "The ConcernedApe analogy is emotionally useful but operationally dangerous. ConcernedApe did not mean 'slow commits'; he meant obsessive reference study, taste, polish, and willingness to rebuild until the feel is right. The autonomous loop should not slow down for romance. It should stay fast, but change what speed is optimizing for: not 'more systems per hour,' but 'one reference-feel defect removed per commit.' Fast iteration with human steering is exactly right. What must slow down is scoring ambition, not implementation cadence. No more claiming progress because a system exists; progress is when the player's Battle City complaint disappears."

→ **Synthesis:** Keep 240s BUILD cadence. Change the SCORING rule: "progress = a specific BC complaint disappears." This is a stronger H2 RULE — pre-mortems track *which BC complaint will go away this iter* and the playtest verifies. Reframes iter success: not "feature shipped" but "defect removed."

### Pro's sharpest recommendation

"Rewrite the prompt around Battle City feel parity before feature breadth. The next 20 iters should not chase XP, upgrades, co-op, or long-run survival. They should make the first 60 seconds unmistakably Battle City: readable player/enemy sprites, correct cardinal tank movement, clean bullet origin, destructible brick, indestructible steel, bullets over water, forest concealment, enemies spawning from top gates, enemy bullets, player/base loss condition, and restart."

### The new "stone" (Pro's verbatim, adopted)

> "A Battle City-inspired procedural tank defense game. The player controls a readable 4-direction tank, defends a vulnerable base, shoots destructible terrain, survives top-spawn enemy tanks, and clears procedurally generated Battle City-like arenas. Success is not feature count; success is that a first-time player says, *'Oh, this is Battle City, but new.'*"

### iter-11+ roadmap (synthesis of mine + Pro's)

| Iter | Mode | Focus | Why |
|------|------|-------|-----|
| 11 | BUILD | Player base node + game-over-on-base-destruction + PROMPT.md rewrite to new stone | First "you can lose what you're defending" iter; encodes stone |
| 12 | BUILD | Procedural-template stamping — bottom-center base fort + 3 top spawn gates | Pro's H3 middle path |
| 13 | BUILD | Steel as indestructible (BC truth: steel doesn't break to player bullets, breaks to star-upgraded bullets) + forest hides tanks (TileMapLayer Grass already exists; just set sprite alpha when on grass) | BC parity for terrain semantics |
| 14 | PLAYTEST | All BC fundamentals shipped; the "first 60 seconds unmistakably BC" test | Pro's "60s test" |
| 15 | AUDIT + CAPABILITY | Build BC-truth-table oracle (passes water, brick break, steel survive, etc.) — Pro's H4 proxies | Automate feel-truth for between-playtest iters |
| 16+ | BUILD | Enemy tank types (4 from BC) → power-ups → wave progression | After BC fundamentals are locked in |

### Lessons

1. **Pro is good at killing my checklists.** I tend toward feature-counting; Pro pushes toward feel-parity-via-defect-removal. Useful corrective.
2. **"Procedural-with-templates" is the load-bearing insight.** I was leaning binary; Pro named the middle path cleanly. This is the kind of synthesis that's hard to reach alone.
3. **ConcernedApe analog implies TASTE not PACE.** I had this slightly wrong. The user almost certainly meant "obsess on the reference until it feels right," not "go slower."

---

## Consult 003 — Mid-iter-10 — GPT-Pro extended thinking — LOOP REFRAME v2 (vertical ascender)

**When:** Fired iter 10 (2026-05-11) after user correction; returned ~2.5 min later (durationMs 151971). Same agentify tab as Consult 002 (continuation conversation).

**Agentify key:** `tanke-iter-10-reframe` (continuation)
**Conversation URL:** https://chatgpt.com/g/g-p-69c9d0b3c3b88191872d6b59cb5adfb8-agentify/c/6a018b7c-23a0-83e8-8014-26b078f5845a

### Trigger

User correction (verbatim): "but it is not fully right - the move is that the map is procedurally generated toward the up - player must keep moving towards up ... thats where rogue like can happen... so pls fire the query again with this correction"

This invalidated Consult 002's static-base-defense BC clone framing. Map is procedurally generated UPWARD as player ascends (engine substrate already does this via `next_row -= 1`); player MUST move up; roguelike progression via depth.

### Pro v2's responses (verbatim, with synthesis)

**H1 v2 — HOLDS:** "The correction cleanly separates combat grammar from run grammar. Battle City supplies the verbs: cardinal tank movement, directional shots, brick/steel/water/forest rules, enemy tanks. The roguelike vertical ascender supplies the reason to keep playing: climb farther, survive longer, die, restart, improve. This is coherent. What breaks it is naming it 'Battle City clone' again. That will keep dragging the loop toward base defense, fixed stages, and spawn gates. Recommendation: make 'upward pressure' the primary design law; Battle City is the control/terrain reference, not the structure reference."

**My synthesis (H1 v2):** Adopt verbatim. "Upward pressure as primary design law" is the load-bearing framing line. PROMPT.md "stone" rewritten to Pro v2's verbatim sentence.

**H2 v2 — HOLDS:** "The rubric should now score whether the player is being pulled upward under pressure, not whether iconic Battle City checklist items exist. 'Compulsion loop' is measurable enough: depth reached, rows per minute, time alive, time spent stalled, enemies killed per depth band, death cause, and whether the user says they wanted to try one more climb. Meta-progression is not load-bearing yet; it is scope creep until one run is compelling. Recommendation: add criteria for depth feedback, ascent pressure, run summary, and forward-survivability; delete XP modal/build-distinctness/base-defense-style axes for now."

**My synthesis (H2 v2):** Adopt. RUBRIC.md crits 4, 5, 7, 10 renamed iter 11:
- Crit 4: "Depth feedback + ascent pressure"
- Crit 5: "Forward survivability"
- Crit 7: "Compulsion loop"
- Crit 10: "Run summary + replayability"

**H3 v2 — HOLDS:** "The procedural substrate finally has a job. It is not a compromise with Battle City; it is the game's identity. But uniform Eller's maze rows alone are probably too texture-like. A roguelike ascender needs beats: safe-ish openings, pressure corridors, destructible choke pockets, ambush rows, resource/recovery rows, miniboss rows, and occasional terrain-rule teaching moments. Not handcrafted levels, but not undifferentiated maze extrusion either. Recommendation: evolve from 'generate rows' to 'generate vertical encounter bands,' where every N rows has a declared purpose."

**My synthesis (H3 v2):** Adopt. Encoded into crit-4 anchor 3: "Every N rows = declared encounter beat." Future iter (12-13) will explore band-stamping over Eller's substrate. Substrate freeze respected — bands are POST-process, not generation-logic edits.

**H4 v2 — HOLDS:** "Roguelike framing makes the loop more measurable, not less. The loop can now predict concrete outcomes: 'player reaches depth 25,' 'dies mostly to enemy bullets,' 'stalls more than 30 seconds below depth 10,' 'doesn't notice depth counter,' 'keeps climbing instead of clearing every enemy.' The real tension is optimization conflict: Battle City rewards careful positional combat; vertical roguelike pressure punishes over-clearing and hesitation. Recommendation: optimize for 'fight while advancing,' not 'perfectly clear the screen.' Track climb rate and stall time alongside combat deaths."

**My synthesis (H4 v2):** Adopt. Pre-mortem H2-RULE now favors observable depth/time/stall claims over generic "feel" claims. Forward-survivability crit 5 encodes the "fight while advancing" optimization target.

**H5 v2 — MOSTLY HOLDS:** "A depth/time HUD before terrain semantics is correct because it names the game to the player: this is a run, not a stage. But iter 11 cannot merely add HUD and rewrite text while enemy/player readability, sprite rotation, muzzle alignment, and spawn fairness remain visibly wrong. Those defects poison every future playtest. Recommendation: iter 11 should be 'identity + readability': rewrite PROMPT stone, add DEPTH/TIME, fix tank orientation/readability defects."

**My synthesis (H5 v2):** Adopt — and note that the readability defects (muzzle initial rotation, enemy sprite rotation, enemy distinct sprite, spawn-off-screen) WERE FIXED in iter 10 commit `a7f8bf0` BEFORE the consult returned. Iter 11 is therefore exactly: stone rewrite + DEPTH/TIME HUD. Validation deferred to iter 14 playtest.

### The new stone (Pro v2 verbatim, adopted)

> "A roguelike vertical tank ascender with Battle City combat feel: the player drives upward through an endlessly generated destructible maze, fighting readable enemy tanks, managing terrain, surviving as long as possible, and measuring each run by depth reached before death."

### iter-11+ roadmap (final, post Pro v2)

| Iter | Mode | Focus |
|------|------|-------|
| 11 | BUILD | Identity: rewrite PROMPT.md/RUBRIC.md to roguelike-ascender framing + DEPTH/TIME HUD added to PlayerTank |
| 12 | BUILD | Spawning ahead-of-player (currently spawns at camera top; refine to scale with player ascent velocity) + telegraphing |
| 13 | BUILD | Terrain semantics completion: forest hides tanks; steel indestructible by base bullet |
| 14 | PLAYTEST | "Did the ascent feel compelling? Did the BC combat feel good while ascending?" + verify iter-10 readability fixes |
| 15+ | CAPABILITY | Vertical encounter bands (post-process Eller's with declared-purpose row beats per Pro H3 v2) |
| 16+ | BUILD | Roguelike meta: death-screen with depth/time/cause, score persistence |

### Lessons

1. **Same-tab continuation works:** Pro maintained the full prior context — no need to re-inline files for v2. Cost-effective.
2. **User correction overrode Pro's first synthesis.** Pro v1's "static base defense" framing was internally coherent but missed a fundamental user-side mechanic (procedural-up). Lesson: my synthesis prompt should have surfaced the procedural-upward fact more prominently; I assumed Pro would infer it from context.
3. **The roguelike framing is MORE constraining than the BC framing, in a good way.** Pro v2: "roguelike makes the loop more measurable, not less." Concrete observables: depth, climb rate, stall time, death cause. H2 RULE becomes easier to apply, not harder.
4. **"Upward pressure as primary design law" is the new north star.** Every iter 11+ decision is evaluated by: "does this make the upward run clearer, tenser, or more replayable?"

---
