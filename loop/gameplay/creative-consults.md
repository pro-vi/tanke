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

## Consult 005 — Iter 29 (returned iter 30) — Validation + ascent legibility redirect

**When:** Fired iter 29 (after iter 25 tab_busy failure recovered), returned iter 30 (durationMs 282263, ~4.7 min)
**Agentify key:** `tanke-iter-29-revalidate`
**Context inlined:** 7 of 9 files (99K/100K). RUBRIC.md + STATE.md omitted by budget; LEDGER carries equivalent.

### Pro's response (key insights, full transcript at `https://chatgpt.com/g/g-p-69c9d0b3c3b88191872d6b59cb5adfb8-agentify/c/6a01b2d6-8160-83e8-88ab-20be0a2f1c0d`)

**H1 (Light split): MOSTLY HOLDS but fragile in dense terrain.** 3s × 24px/s = 72px commit = ~4.5 tiles — good "chose a lane" feel. Terrain collisions reset commit → could read as "bumbling wall AI" in dense pockets. Don't tune before iter 33; if needed later, bias should be STRICTER (3× not 2×).

**H2 (Below-spawn): BREAKS on telegraph visibility.** `spawn_y = screen_bottom + 8` places marker BELOW viewport, not inside. First behind-spawn = hidden punishment. **Fix critical before iter 33.** Either move marker INSIDE bottom edge OR add visible bottom-edge warning while enemy spawns from below. Don't increase frequency before fixing visibility.

**H3 (META resolution): NOT RESOLVED until player names strategy.** Systems improved but player must perceive the climb. Iter-33 discriminator: "What did the game seem to want you to do: clear enemies, survive in place, or keep climbing?" META resolved IF player says version of "I should keep moving up." Best supporting metrics: stall time below peak depth, ascent velocity over time, deaths-while-advancing vs deaths-while-camping. NOT kill count.

**H4 (Sprint plan): CUT kills counter HUD; reorder iter 30 to "ascent legibility polish".** **Kills counter is DANGEROUS** — teaches wrong objective (kill-completion not ascent). Iter 30 should serve climb: bottom-spawn warning visibility, "STALL WARNING" cue, depth milestone feedback. Iter 31 CAPABILITY worth it ONLY if ascender-focused metrics (NOT kill counts). DO NOT add: new enemy, power-up, death summary, economy, upgrade, terrain feature.

**H5 (Crit 2 lift): HOLDS but narrow.** Lift legitimate. Pro flags separate code issue: `_telegraph_then_spawn` post-await only re-checks GLOBAL `max_enemies`, not BAND cap → band caps can be exceeded after delayed spawns. Worth a small patch (folded into iter 30).

**Sharpest recommendation:** Replace iter 30 "kills counter HUD" with "ascent legibility polish." Build smallest cue that makes ASCENT legible. Then stop.

**META:** **Readable upward intent** is the single missing thing. Systems punish stalling but player must perceive the climb BEFORE being punished for not climbing.

### My synthesis

Adopt Pro v5 wholesale:
- **DROP kills counter HUD** (would teach wrong objective)
- **FIX below-spawn marker visibility** (critical fairness issue)
- **ADD depth milestone flash** (ascent legibility cue per META)
- **PATCH band-cap recheck post-await** (H5 minor code issue)
- **Iter 31 CAPABILITY must be ascender-focused** (stall time, ascent velocity, spawn-origin distribution) if shipped at all
- **DO NOT add content** before iter 33

### Lessons

1. **Visibility check matters for "fairness."** I called the below-spawn telegraph "visible" in my iter-28 commit message, but the math (`screen_bottom + 8`) put it 8px BELOW viewport — invisible to player. Pro caught this before iter-33 playtest would have. Anti-pattern: trusting the comment without verifying the math.
2. **Kills counter is a SCORING TRAP.** Even as "polish" it teaches kill-completion not ascent. Pro caught the cargo-cult shape of "more numbers on HUD = better feedback." HUD should reinforce the GOAL, not enumerate side effects.
3. **Pro v5 confirms the loop's parity drift is mitigated, not resolved.** iter-33 test is language-based (what does the player NAME the goal as).

---

## Consult attempt iter 25 — FAILED (tab_busy after max_tabs_reached) → SELF-CONSULT

**Trigger:** Iter 25 is per the user's 5-iter consult cadence. Fired `tanke-iter-25-validate` query.

**Failure mode:** First call returned `max_tabs_reached` (agentify cap, 12 tabs). Closed 3 stale non-tanke tabs (`consult-19`, `blog-cn-curation`, `blog-cn-curation-2`). Retried; got `tab_busy` even though target tab key didn't exist. Tried fresh key; still `tab_busy`. agentify_tabs showed 9 tabs alive — under the 12 cap — but the default tab's `lastUsedAt` was very recent suggesting some background operation. Couldn't determine root cause.

**Precedent:** FALSIFICATION 001 lesson + engine-loop iter-10/20 history: when external CONSULT fails, **self-pre-mortem-in-writing** fills the role. This is the third external-consult failure across the project (engine-loop x2 + iter 25). Pattern: agentify is reliable when it works, but failure mode requires fallback to self-consult.

**Self-consult output:** See LEDGER iter 025 entry for full H1-H5 self-answers and revised sprint plan.

**Lesson:** When agentify fails mid-cadence, default to self-consult and document the failure here. Don't retry endlessly. The H2 RULE v2 discipline (STRUCTURE/FEEL tags) substitutes for Pro's "would they reword the anchor?" check — I can apply the self-deception detector without Pro present.

---

## Consult 004 — Iter 20 — GPT-Pro extended thinking — CREATIVE STEERING

**When:** Fired iter 20 (2026-05-11), returned in iter 22 (durationMs 358561 ~6 min)
**Agentify key:** `tanke-iter-20-creative`
**Conversation URL:** https://chatgpt.com/g/g-p-69c9d0b3c3b88191872d6b59cb5adfb8-agentify/c/6a01a364-cfd4-83e8-8f9a-768d9c7a08c8
**Context inlined:** 14 of 15 files (94K/100K). STATE.md omitted; LEDGER carried equivalent.

### Trigger

User iter-17 directive: "do at least 15 iters before asking me for any playtest. every 5 iter, may /agentify for creative input." Iter 20 is the first scheduled CONSULT under this cadence. Asked 5 hypotheses + META.

### Pro's response (verbatim, key insights)

**H1 (seductive-but-hollow): BREAKS** — "The seductive hollow thing is not merely 'depth 10 feels like depth 100.' It is worse: the game may be Battle City-shaped but not Battle City-legible. You have bullets, bricks, steel, forest alpha, water pass-through, top spawns, and tanks, but those are nouns. Battle City feel comes from combat grammar: lanes, brick sacrifice, bunker angles, spawn anticipation, pressure from known gates, and 'I chose to break this wall / preserve this wall.' Right now the procedural maze may be functioning as decorative obstruction rather than tactical authorship. Avoid polishing surface events until terrain creates recognizable decisions."

→ **My synthesis (H1):** ADOPT. The pre-mortem prediction "depth 10 vs depth 30 feels same" was the surface complaint; the deeper truth is the terrain has no grammar. Procedural maze is RANDOM, not ARGUMENTATIVE — it doesn't pose decisions. **Stop polishing.** Iter 19 (hit flash) and iter 21 (enemy death particle) were rubric-driven but Pro is correct that they're surface polish over a missing skeleton.

**H2 (enemy variety depth): BREAKS** — "Light vs Heavy as stats-only types is not enough unless the player can predict them by silhouette and change behavior. 'Fast/fragile' and 'slow/tough/fires more' is a good seed, but both currently chase and shoot, so the player mostly experiences 'enemy tank but sometimes annoying.' Make Light a lane-invader that advances aggressively and fires rarely; make Heavy a corridor-denier that turns slower, pauses, and fires bursts or aimed shots. One behavior split is worth more than adding a third type."

→ **My synthesis (H2):** ADOPT. Iter 16's Light/Heavy currently differ only in stats. Make them BEHAVIORALLY distinct: Light=aggressive forward, low fire; Heavy=defensive position-and-shoot, high fire. Skip "Fast" as third type per Pro. Behavioral split takes ~2 iters; lifts crit 6 properly (under new rubric anchor 2 wording per H3).

**H3 (rubric rewording): BREAKS** — "The rubric wording is now giving you permission to rationalize. 'Chaser + ranged-shooter' was not just a VS artifact; it was trying to demand role distinction, not stat distinction. Reword crit 6 now, but make it stricter, not easier: 'enemy types have distinct battlefield roles visible within 10 seconds: mobile pressure, lane denial, flanker, ambusher, etc.' Do not retroactively award yourself for Light/Heavy unless the code creates different decisions. Rubric edits are healthy only if they make future self-deception harder."

→ **My synthesis (H3):** ADOPT. Update crit 6 anchor 2 wording to require ROLE distinction. RETROACTIVELY un-award iter-16 lift (crit 6 was 1, was lifted to 2 via Light/Heavy stats; revert to 1 since stats-only doesn't meet new anchor wording). Total drops 16 → 15. This is the kind of honesty Pro v2's H2 critique demanded.

**H4 (sprint plan reprioritization): BREAKS** — "The sprint plan overinvests in after-the-fact roguelike framing: death summaries, best tracking, kill counter, particles. Those help a good run feel remembered; they do not make the run good. Sacrifice the power-up prototype first, then most of the persistent run-best work. Keep only the cheapest death summary: depth, time, kills. Spend the freed 2–3 iters on encounter bands or a depth director. Yes: encounter bands are more important than power-ups for iter-33. A helmet pickup inside a samey climb is just another noun."

→ **My synthesis (H4):** ADOPT. Sprint plan revised below. Drop power-up (iter 31). Drop run-best tracker (iter 26). Keep minimal death summary (iter 24, cheap). Replace freed iters with encounter-band work.

**H5 (iter-33 prediction): HOLDS** — "Your proposed falsification is probably right, but the sharper H2-RULE prediction should be more player-language-specific: 'In the iter-33 playtest, the user will not describe the game as a climb/ascent unless prompted; they will describe it as Battle City-ish tanks in a maze, and at least one comment will imply sameness or unclear forward pressure.' Even sharper: 'The user will stop to clear enemies more often than they push upward through danger.' That is the prediction most likely to expose whether the ascender premise exists in hands, not just HUD."

→ **My synthesis (H5):** ADOPT. Replace my iter-33 H2-RULE prediction "depth 10 ≠ depth 30" with Pro's sharper version: "The user will stop to clear enemies more often than they push upward through danger." This is the falsification-pure test of whether the ascender premise EXISTS IN HANDS.

### Pro's sharpest recommendation (adopted)

"Before particles, power-ups, or persistence, build a tiny ascent director. Every N depth rows, change the run's situation in an obvious way: 'open lane,' 'brick choke,' 'heavy gate,' 'light rush,' 'forest pocket,' 'stall punishment.' This can be crude. It does not need full procedural artistry. It needs the player to feel, within one minute, 'I reached a different kind of problem.' If you only do one thing before iter-33, make depth alter encounter texture, not just spawn count."

### Pro's META (the blind spot)

"The core verbs may be fighting each other. Battle City shooting is body-aimed: to shoot left, right, or down, you stop ascending and turn. A vertical ascender asks the player to keep moving up. That means your 'authentic BC control feel' may directly sabotage 'forward survivability.' If the optimal play is stop, face, clear, then ascend, the roguelike ascender collapses into room-by-room tank clearing. Avoid building ten systems around a contradiction. You need mechanics or encounter design that make fighting while climbing natural: forward lanes, threats from behind, enemies that can be dodged rather than cleared, or rewards for maintaining upward motion."

→ **My synthesis (META):** This is the load-bearing critique. The combat verbs (stop-face-fire) compete with the ascender verbs (keep moving). Mitigations Pro lists: forward lanes, threats from behind, dodge-not-clear enemies, ascending rewards. Translates to design rules for the ascent director:
- Top-spawn enemies = naturally "behind" you as you ascend (already partially in place)
- Stalling pressure (iter-12) = reward for moving = ALREADY in place but maybe too weak
- Future bands could be "skippable" — no requirement to clear, just pass through
- Future enemies could have stable patterns the player learns to weave around without stopping

### Revised iter-22-32 roadmap

| Iter | Mode | Focus |
|------|------|-------|
| 22 | BUILD | Rubric rewrite (crit 6 anchor 2) + score revert + ASCENT DIRECTOR scaffolding (depth bands → per-band spawn config) |
| 23 | AUDIT | First encounter band tuning |
| 24 | BUILD | First behaviorally distinct enemy type (Heavy = pause-and-fire) |
| 25 | CONSULT (per cadence) |
| 26 | BUILD | Light behavioral split (lane-invader, low fire) |
| 27 | BUILD | Second encounter band (e.g., "heavy gate" = brick choke + Heavy spawn) |
| 28 | AUDIT |
| 29 | BUILD | Third band + "stall punishment" band (escalates stalling pressure visibly) |
| 30 | CONSULT (per cadence + PROMPT §10/20/30) |
| 31 | BUILD | Cheap death summary (depth/time/kills text on YOU DIED screen) |
| 32 | Polish + prep iter-33 playtest |

DROPPED: power-up prototype, run-best tracker (FileAccess persistence), kill counter HUD. May reintroduce post-playtest if user reports them missing.

### Lessons

1. **Rubric is permission-to-rationalize when wording is loose.** Crit 6 anchor 2 "chaser + ranged-shooter" let me claim stats-only Light/Heavy as anchor-met. Pro flagged this as exactly the rubric theater H2 critique warned about. Tighter wording → harder to self-deceive.
2. **Surface polish before structure is a false-progress trap.** Iter 19/21 (hit flash, death particle) are crit-8 anchor citations but Pro says particles inside a samey climb are "another noun." They're not WRONG, just LOW-PRIORITY vs. building grammar.
3. **The combat-vs-climb tension is the load-bearing META blind spot.** Need to design encounters that resolve it rather than fight it. Pro names 4 mitigations — pick 1-2 to encode in the ascent director.

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

## Consult 006 — Iter 45 — GPT-Pro extended thinking — MID-SPRINT REVIEW

**Date:** 2026-05-11
**Trigger:** Planned mid-sprint review per iter-39 roadmap (iter 39-59 sprint window). 5 BUILD iters shipped (40-44); 14 iters remain before iter-60 PLAYTEST.
**Tab key:** `tanke-iter-45-consult-mid-sprint`
**Mode:** `extended-pro` fire-and-forget
**Tab capacity:** closed 3 stale tabs before firing (consult-20-vrc-direction, tanke-iter-2-secondopinion, cold-comprehension-probe-768).

### Prompt focus

5 labeled hypotheses presented neutrally (per /agentify "don't preload your conclusions" rule):
- **H1**: Sprint trajectory (sparks/shake/summary/best tracker) is the right priority. 3 STRUCTURE-DEFERRED cites stacking is acceptable.
- **H2**: Heavy AI movement omniscience is *fine* now that wind-up + telegraph make Heavy reactable.
- **H3**: Crit 8/9 rubric debt should be addressed iter 46 via reframe protocol, not deferred to AUDIT 50.
- **H4**: Recent ships are seductive-but-hollow; the combat verb (decision-making) is thin.
- **H5**: iter-60 playtest needs to expand beyond 2-question template for the 6 visible iters of change.

Asked Pro to lead with "breaks because" / "holds because" per H, then recommend top 1-2 things to ship iter 46-59 that I'm NOT currently planning.

### Status

ADOPTED (read iter 46; 80s gen, Pro Extended Thinking).

### Pro response synthesis

| H | Verdict | Pro's lead-in (paraphrased) |
|---|---------|------------------------------|
| H1 | **BREAKS** | "Yes, you are over-juicing the wrong layer. Sparks, shake, summary, best-depth are good presentation scaffolding but not independently strong enough to carry three deferred [FEEL] citations unless iter-60 player spontaneously notices them as part of a coherent loop." Brittle: one lukewarm playtest collapses crits 8/10 to "visible polish exists." |
| H2 | **BREAKS** | "Heavy omniscient movement is not fine; it is just not the loudest problem anymore. Pursuit behavior is part of the stealth/peek/cover verb. If Heavy always chooses toward raw player position, the player cannot meaningfully lose it, bait it, route around it, or exploit walls except at the firing moment." |
| H3 | **HOLDS** | "Rubric debt is now actively distorting build choices. Do the rename now, not at iter 50, because 46-59 planning depends on what the anchors actually mean." Proposed: Crit 8 → "impact/feedback/readability"; Crit 9 → "HUD communicates survival/ascent state"; Crit 10 → "run loop closure". |
| H4 | **HOLDS** | "Ascent loop is still thinner than the shipped polish suggests. Enemy differentiation on paper but player verbs sound mostly like 'drive upward, shoot, dodge,' not 'scout, choose route, bait Heavy, break LOS, decide push or clear.' Missing layer: pressure/choice mechanic." |
| H5 | **HOLDS** | "Standard 2-question playtest will under-sample. Use 4-5 diagnostic questions tied to specific rubric axes + one forced choice." |

### Pro's sharp recommendations

1. **PRIMARY: Heavy de-omniscience (LKP + search behavior).** Heavy chases last known player position, pauses/searches when LOS lost, reacquires on LOS/proximity. Directly attacks hollow-loop risk. Adopted iter 47-48 BUILD.
2. **SECONDARY: Depth pressure landmarks.** Every N vertical chunks, recognizable "gate room" or "danger pocket" with milestone callout. Authored ascent beats. Adopted iter 49-50 BUILD.

### Adoption decisions

**Iter 46 (this iter):**
- ADOPT H3 hold: rubric rename via v2 §Reframe protocol. RUBRIC.md crits 8/9/10 reworded. Revision Log entry filed. Score lifts: crit 8 2→3, crit 10 2→3 [STRUCTURE].
- ADOPT H5 hold: iter-60 playtest will use 4-5 question diagnostic tour.

**Iter 47-48:** ADOPT primary — Heavy LKP de-omniscience.

**Iter 49-50:** ADOPT secondary — depth pressure landmarks.

**Iter 51-54:** BUILD as surfaces (HP bar, Light/Fast sharpening, audio stubs, Heavy tuning).

**Iter 55:** CONSULT 007 pre-playtest.

**Iter 56-59:** tune/polish per Consult 007.

**Iter 60:** PLAYTEST 4-5 question diagnostic tour (per Pro H5 template).

### Lessons

1. **Pro's "breaks because"/"holds because" surfaces hard truths quickly.** H1 break ("over-juicing the wrong layer") was the most useful single sentence — broke a 5-iter trajectory and redirected iter 46-59.
2. **Rubric debt actively distorts citations.** Pro's call to rename mid-sprint (not at AUDIT 50) was right because all 46-59 planning was hostage to what crit 8/9/10 actually meant.
3. **"Seductive but hollow" was answered: yes.** The visual juice tier is decoration over thin combat verb. Pro's fix is decision-quality (LKP, landmarks), not more polish.
4. **CONSULT mid-sprint pays off when budget is right.** 5 BUILDs in, 14 to go, was the right moment — early enough to redirect, late enough to have concrete progress.

---

## Consult 007 — Iter 55 — GPT-Pro extended thinking — PRE-PLAYTEST PULSE CHECK

**Date:** 2026-05-11
**Trigger:** Planned pre-playtest review per iter-39 sprint roadmap. 4 BUILD iters remain (56-59) before iter-60 mandatory PLAYTEST. Score 30/50 with 5 [STRUCTURE-DEFERRED → iter 60] gates pending user cite.
**Tab key:** `tanke-iter-55-consult-preplaytest`
**Mode:** `extended-pro` fire-and-forget
**Tab capacity:** 8/12 — no clean-up needed

### Prompt focus

4 labeled hypotheses presented neutrally:
- **H1**: Ship NO new features iter 56-59 — tune existing parameters only
- **H2**: Drop playtest from 5Q to 3Q (Q1+Q4+Q5 core)
- **H3**: Heavy over-correction risk — dominates player attention budget
- **H4**: Map/Eller-substrate samey-ness is biggest playtest risk (untouchable)

Asked for breaks/holds per H + one recommendation for iter 56-59:
(a) ship feature, (b) tune params, (c) AUDIT/META, (d) other.

### Status

ADOPTED (read iter 56; 275s gen, Pro Extended Thinking).

### Pro response synthesis

| H | Verdict | Pro's lead-in (paraphrased) |
|---|---------|------------------------------|
| H1 | **MOSTLY HOLDS** with caveat | "Shipped layer is sufficient for iter-60 diagnosis." Caveat: "no more features" shouldn't mean "no more risk reduction." Tiny affordance/instrumentation changes OK if they directly improve test interpretability. Sharp critique: "stability work should ACTIVELY make playtest cleaner — fewer ambiguous deaths, clearer Heavy states, cleaner feedback reads." |
| H2 | **BREAKS** | "Dropping to 3 questions is too aggressive — pending lifts are citation-gated. Q2 supports crit 8 impact/feedback; Q3 supports crit 10 run-loop closure. You DO NOT 'already know' those work — you know you implemented structures intending to support them." Holds Q1/Q4/Q5 as most load-bearing. Sharp critique: "Optimizing for shorter form instead of rubric coverage. Keep 5 questions but make them punchier." |
| H3 | **HOLDS as risk, not problem** | "Heavy may dominate attention budget — unique pathing/damage/tint/aim-cancel/counterplay. Light/Fast may feel like ambient noise." But: "Heavy being the main decision enemy is fine if Light/Fast change positioning, timing, panic pressure. They need FUNCTIONAL PRESSURE, not equal attention." Sharp critique: "Do not ask 'are Light/Fast as interesting as Heavy.' Ask 'do Light/Fast make Heavy decisions HARDER, EARLIER, or MORE COSTLY.'" |
| H4 | **HOLDS** | "Map/level structure is the biggest systemic risk. Landmarks improve orientation not topology. If maze feels samey, iter-48 only helps name depth, not feel authored progression." But: "not the highest-risk thing to fix before iter 60. Playtest can expose whether sameness damages decision quality or is just aesthetic." Sharp critique: "'Procedural generation is frozen' is becoming a hiding place. You may not change Eller's, but you can still tune encounter pacing, landmark cadence, and readability around it." |

### Recommendation: (b) TUNE EXISTING PARAMETERS

No new gameplay features iter 56-59. Narrow tuning pass:

1. **Heavy `lkp_search_duration`**: test 2.0s / 2.5s / 3.0s. Pick "fallible but not stupid."
2. **Heavy `aim_cancel_cooldown`**: keep 1.5s unless Heavy becomes trivial in self-play; raise slightly only if spam-cancel viable.
3. **Heavy `bullet_damage=2`**: keep — gives enemy identity. Watch iter-60 whether deaths feel "my fault" vs "cheap."
4. **Light/Fast**: don't buff blindly. Make sure existing speeds/damage create positioning pressure around Heavy.
5. **Playtest prompt**: keep 5 questions, trim wording.

**Posture for iter 56-59**: "freeze feature surface, tune feel, protect diagnostic value of iter 60."

### Adoption decisions

**Iter 56 (this iter):**
- ADOPT recommendation (b): no new features.
- ADOPT Pro H2 break: keep 5Q template, trim wording (iter-60-playtest-prompt-draft.md edits).
- ADOPT Pro H1 caveat: ship a small INSTRUMENTATION improvement — aim-cancel success counter in [run] log. Diagnostic value for iter 60.
- Heavy params: keep current values (lkp_search_duration=2.5, aim_cancel_cooldown=1.5, bullet_damage=2). Pro's "fallible but not stupid" is informational; 2.5 is middle of 2.0-3.0 range.

**Iter 57-59**: tune-only iters. Reserve for actual signal from self-play or surface issues.

### Lessons

1. **"Stability is not passivity"** — Pro's H1 sharp critique. Tuning iters can ACTIVELY improve diagnostic value. Aim-cancel counter is the iter-56 application.
2. **Playtest coverage > prompt brevity** — Pro broke H2 cleanly. The 5 questions exist for rubric coverage. Trim wording, not count.
3. **"Functional pressure ≠ equal attention"** — Pro's H3 reframe. Don't measure Light/Fast against Heavy's depth; measure whether they make Heavy harder to deal with. The current design (Light lane-commit, Fast continuous fire) DOES create positioning pressure; iter-60 will tell.
4. **"Procedural generation is becoming a hiding place"** — Pro's H4 sharp critique. Substrate freeze is real, but I can tune around it (landmark cadence, encounter pacing). Future iter aspiration.

---

## Consult 008 — Iter 87 — GPT-Pro extended thinking — LATE-SPRINT CHECK

**Date:** 2026-05-11
**Trigger:** Pre-emptive late-sprint pulse (planned iter 96 per iter-74 META, fired iter 87 to leave time to act on findings).
**Tab key:** `tanke-iter-87-consult-late-sprint`
**Mode:** `extended-pro` fire-and-forget

### Hypotheses

H1: 3 pickup mechanics overcomplicate combat decision space
H2: Sprint pattern of small ships → combinatorial complexity overwhelms iter-99 user
H3: Map priority addressed via wrapper-around-Eller's, not algorithm. Risk: "still samey" cite at iter 99.
H4: 12 iters remain. Best use: (a) playtest prompt META, (b) one more substantive ship, (c) no-op, (d) other.

Asked for breaks/holds per H + recommendation for iter 87-94 (8 iters before iter 95 final-prep window).

### Status

PENDING (fired iter 87, response expected iter 88).

---
