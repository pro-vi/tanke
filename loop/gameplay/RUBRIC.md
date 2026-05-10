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

## 4. XP + level-up flow (0–5)

Kills drop XP; threshold triggers upgrade modal.

| Score | Anchor |
|-------|--------|
| 0 | No XP system |
| 1 | Enemies drop XP gems (visible) |
| 2 | XP magnetizes to player; XP bar fills on HUD |
| 3 | XP threshold triggers level-up; pause / modal appears |
| 4 | Level-up offers 3 choices; selection applies upgrade and resumes |
| 5 | Level-up is satisfying — clear feedback (visual flourish, sound, "Level X!"); cited via playtest |

---

## 5. Upgrade variety + compounding (0–5)

Distinct upgrades that combine.

| Score | Anchor |
|-------|--------|
| 0 | No upgrades |
| 1 | 1–2 upgrades; only one stacks |
| 2 | 3–5 upgrades available; choices presented as 1-of-3 |
| 3 | 5+ upgrades; passives (HP, speed) and weapons (secondary, mines) both present |
| 4 | 8+ upgrades; some have prerequisites or evolve at max level |
| 5 | Upgrade synergies visible — picking A then B has different effect than B then A; cited via playtest "build matters" |

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

## 7. Run pacing (0–5) — *feel criterion*

Difficulty curve actually escalates.

| Score | Anchor |
|-------|--------|
| 0 | No difficulty change over run time |
| 1 | Spawn rate increases linearly |
| 2 | Spawn rate AND enemy variety increase together |
| 3 | Player power (via upgrades) and threat (via spawns) scale together — playtest cited "felt tense at minute 3" |
| 4 | Distinct phases (early / mid / late) with different challenge characters — playtest cited |
| 5 | A 5-minute run produces a "third-act crescendo" — playtest cited "I died but wanted to try again" |

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

## 10. Build distinctness (0–5) — *feel criterion*

Different upgrade paths produce visibly different play.

| Score | Anchor |
|-------|--------|
| 0 | No upgrades to distinguish |
| 1 | All upgrades are stat bumps (+10% damage, +10% speed, etc) |
| 2 | Some weapon upgrades visibly change projectile (extra bullet, fire rate up) |
| 3 | Three distinct play styles emerge from upgrade choices — playtest cited |
| 4 | A "shotgun build" plays meaningfully different from a "speed build" — playtest cited |
| 5 | Player can describe their build in 3 words ("burst-damage glass cannon", "tanky-defensive turret"); each is recognizable in playtest |

---

## Revision Log

| Iter | Change | Reason |
|------|--------|--------|
| 0 | Initial gameplay rubric, 10 criteria, reachability floor | New loop scope: VS-like gameplay; engine is substrate |
