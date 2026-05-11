# tanke — Gameplay Loop Rubric

10 criteria, 0–5 scale. Score > 2 requires citation; score > 2 on **feel
criteria (1, 7, 8, 9, 10)** requires *playtest* citation, not oracle output.

**Reachability floor**: any criterion's score is **capped at 0** if the active
scene's config fails reachability (`playable: false`). This is the explicit
fix for the engine loop's iter-18 trophy that scored 5/5 on a config the
player couldn't traverse.

---

## 1. Core loop closes (0–5) — *feel criterion*

The fundamental cycle: move → shoot → take damage → die → restart.

| Score | Anchor |
|-------|--------|
| 0 | Tank can't move OR can't shoot OR scene won't load |
| 1 | Move works; shoot fires bullet; bullet has no effect |
| 2 | Move + shoot + bullets travel + bullet collisions register |
| 3 | All of (2) + player has HP, takes damage, can die — cited via playtest |
| 4 | All of (3) + death triggers a clear "run over" state with restart option — cited via playtest |
| 5 | All of (4) + a *first-run-without-instruction* user can complete the cycle (run, die, restart) without confusion — cited via playtest |

---

## 2. Spawn / wave system (0–5)

Enemies appear over time at increasing rate.

| Score | Anchor |
|-------|--------|
| 0 | No enemies |
| 1 | Enemies spawn but at fixed rate / single location |
| 2 | Enemies spawn at varying intervals, multiple spawn points |
| 3 | Spawn rate increases over run time (cited: enemy count at minute 1 vs minute 3) |
| 4 | Multiple wave types — different enemy compositions over time |
| 5 | Spawn system is config-driven (a `WaveConfig.tres` resource agent can mutate); wave changes produce measurably different runs |

---

## 3. HP + death model (0–5)

Player takes damage; HP visible; death ends run.

| Score | Anchor |
|-------|--------|
| 0 | No HP system |
| 1 | HP variable exists; not displayed; no damage taken |
| 2 | Player takes damage on collision; HP shown numerically |
| 3 | HP bar visible on HUD; hits flash the player; death triggers run-end |
| 4 | Damage values vary by enemy type; iframes / knockback after hit (cited: playtest "felt fair") |
| 5 | Death screen shows run summary (time, kills, build); restart returns to fresh run cleanly |

---

## 4. Depth feedback + ascent pressure (0–5) — *feel criterion*

(Renamed iter 11 — replaces former "XP + level-up flow." Reframed per
Pro Consult 003: the ascender's diegetic feedback is depth-as-score, not
XP; uniform Eller's rows are "too texture-like" — need encounter beats.)

Does the player feel/see upward progress? Is there pressure to keep
moving up?

| Score | Anchor |
|-------|--------|
| 0 | No depth indicator; uniform Eller's maze; no upward pressure mechanic |
| 1 | HUD shows `DEPTH: N` (rows ascended) numerically — cited via code |
| 2 | DEPTH + run TIME both shown; updates live as player ascends — cited via playtest |
| 3 | Every N rows = declared encounter beat (safe / pressure / choke / ambush); playtest cites varied rhythm |
| 4 | Stalling at one depth produces visible pressure (e.g. faster spawn rate, descending fog, telegraphed "keep moving"); playtest cited "I felt pushed up" |
| 5 | The compulsion to ascend is unmistakable in a 60-second playtest — user describes the game as a "climb" or "ascent" unprompted |

---

## 5. Forward survivability (0–5) — *feel criterion*

(Renamed iter 11 — replaces former "Upgrade variety + compounding."
Reframed per Pro Consult 003: optimize for "fight while advancing," not
"clear the screen.")

Can the player sustain ascending while combat happens? Or does combat
force stop-and-clear, breaking compulsion?

| Score | Anchor |
|-------|--------|
| 0 | Combat forces full stop; ascending and fighting are exclusive |
| 1 | Player can fire while moving; enemies don't reliably block ascent |
| 2 | Climb rate observable — most enemies engageable on-the-go; cited via playtest "I kept moving" |
| 3 | Combat micro-decisions while ascending (which enemy to engage, which to dodge); playtest cited |
| 4 | Forward-friendly mechanics (e.g. forward-cone bullet pickups, dash, ramming charge) reward advancing over clearing |
| 5 | The game rewards "fight while climbing" so unmistakably that stopping feels wrong — playtest cited "stalling got me killed" |

---

## 6. Enemy variety + behavior (0–5)

Multiple enemy types with distinct AI.

| Score | Anchor |
|-------|--------|
| 0 | No enemies, or one type with no AI |
| 1 | One enemy type that moves toward player |
| 2 | Two types: chaser + ranged-shooter |
| 3 | Three+ types with distinct movement (chaser / circler / line-of-sight shooter) |
| 4 | Boss-like enemy or wave-marker enemy (special spawn at minute 2/4/etc) |
| 5 | Enemies route around walls (basic pathfinding); cited via playtest "they don't get stuck" |

---

## 7. Compulsion loop (0–5) — *feel criterion*

(Renamed iter 11 — was "Run pacing"; reframed per Pro Consult 003:
roguelike compulsion is the primary success metric.)

Does the player want one more run after dying?

| Score | Anchor |
|-------|--------|
| 0 | After death, user does NOT want to play again |
| 1 | Spawn rate increases with depth — difficulty escalates linearly |
| 2 | Player reaches new personal-best depth at least once in 3 runs — playtest cited |
| 3 | After dying, user spontaneously presses R within 5 seconds — playtest cited |
| 4 | User completes 3+ runs in one session WITHOUT being asked — playtest cited |
| 5 | User says "one more run" out loud (or equivalent) — playtest cited |

---

## 8. Visual feedback / juice (0–5) — *feel criterion*

Hit-flash, death anim, XP magnet, level-up modal.

| Score | Anchor |
|-------|--------|
| 0 | No feedback on any event |
| 1 | Hit flashes one color |
| 2 | Hit flash + enemy death (sprite swap or particle) |
| 3 | XP gems animate (drift toward player); level-up has visual flourish (cited) |
| 4 | Camera shake on damage; bullet impact spark; UI counter increments |
| 5 | Screen-clear visual impact — playtest cited "satisfying to mow through a wave" |

---

## 9. UI / UX (0–5) — *feel criterion*

HUD legible at 320×240; restart obvious.

| Score | Anchor |
|-------|--------|
| 0 | No HUD |
| 1 | HP / XP shown numerically (text only) |
| 2 | HP bar + XP bar visible; readable at 320×240 |
| 3 | Run timer + kill count + level number on HUD |
| 4 | Level-up modal pauses cleanly; choices show name + brief description |
| 5 | First-time user can navigate from death → restart without instruction — playtest cited |

---

## 10. Run summary + replayability (0–5) — *feel criterion*

(Renamed iter 11 — replaces former "Build distinctness." Reframed per
Pro Consult 003: the death screen is the roguelike's pitch for the next
run, not the build's epitaph.)

Does the death screen close one run and pitch the next?

| Score | Anchor |
|-------|--------|
| 0 | No death screen — instant restart or hard stop |
| 1 | "YOU DIED" + restart hint shown — cited via code (iter 3) |
| 2 | Death screen shows depth reached, run time, enemies killed — cited via playtest |
| 3 | Death screen highlights personal best vs. this run — cited via playtest |
| 4 | Death screen shows "death cause" (which enemy, depth) — playtest cited "I want to beat my last run" |
| 5 | Death screen is fast, restart is immediate, user-flow is silent (no menu friction) — playtest cited "I didn't think, I just pressed R" |

---

## Revision Log

| Iter | Change | Reason |
|------|--------|--------|
| 0 | Initial gameplay rubric, 10 criteria, reachability floor | New loop scope: VS-like gameplay; engine is substrate |
| 11 | Renamed crits 4, 5, 7, 10 to roguelike-ascender axes (Depth feedback, Forward survivability, Compulsion loop, Run summary) | Framing pivot per user correction iter 10 + Pro Consult 003: roguelike vertical ascender with BC combat feel, not VS-like survival. Co-op explicitly NOT a rubric axis (scope grenade). |
