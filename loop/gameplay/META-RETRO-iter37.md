# tanke gameplay loop — mid-arc retrospective (iter 0 → 37)

Written at iter 37 before PROMPT v2 lands. Loop continues at iter 38 with the
v2 PROMPT (preserves STATE, LEDGER, scores). This retro documents what the loop
self-developed beyond what v1 PROMPT specified, and frames the v2 changes.

---

## The arc so far

| Phase | Iters | Output |
|-------|-------|--------|
| **Bootstrap** | 0–4 | Bullet system fixed, enemies, HP/HUD/death, first playtest at iter 5 |
| **Build-up** | 5–10 | Enemy variety, terrain rules, Bullet/Spawner shape; Pro Consult 002 (superseded) |
| **Framing pivot** | **11** | Pro Consult 003 → "roguelike vertical ascender with Battle City combat feel"; 4 of 10 criteria *renamed* (not just anchor-lifted) |
| **Ascender shape** | 12–17 | DEPTH/TIME HUD, spawn-ahead-of-player, forest hides, steel indestructible, 2nd enemy type |
| **Sprint** | **18–32** | User authorized 15-iter no-playtest sprint. Phases A (visual juice) + B (roguelike depth) + C (enemy roles). Consults 004 + 005 drove enemy-role rewording (iter 22) and ascent legibility (iter 30) |
| **F-cycle** | 33–37 | Iter 33 playtest produced F005–F008 (4 falsifications, 1 playtest). Iter 35 fixed all four; iter 36 playtest falsified F007; iter 37 root-cause water-physics fix |

**Score**: 20/50 at iter 37. Half the engine loop's pace; work is significantly
heavier (real gameplay vs measurement scaffolding).

---

## What v1 PROMPT got right (use as-is)

- **Reachability floor**: hash anchor `f873ae60ee3c420c…` for `configs/playable.tres` held across 37 iters. No accidental regression on traversability. The iter-29 finding paid off.
- **Substrate freeze**: only one "tripwire" event (iter 4 H1 — ProceduralLevel.tscn additions) and it was caught + codified. Engine substrate untouched.
- **PLAYTEST cadence + halt rule**: iter 5 mandatory; halt-iter +3 from request; both honored. Engine loop's 8-dormant-iter pattern did not recur.
- **Pre-mortem-in-writing as step 1**: every iter has a PRE-MORTEMS entry. 100% rate. Falsifications became findings.
- **Reachability + substrate as hard floors**: no Goodhart on impassable configs recurred.
- **Per-iteration commits**: held throughout. 37 commits, fully recoverable.

---

## What v1 PROMPT got wrong / didn't anticipate

### 1. Stone framing pivoted at iter 11; v1 text became misleading

V1 said "VS-like with manual + auto secondary, level-up modal, upgrade pool."
Iter 11 rewrote this to "roguelike vertical ascender" via Pro Consult 003.
The v1 anti-patterns section still references "enemies_killed, time_to_death,
upgrades_chosen" — vocabulary the loop has not used since iter 10.

### 2. CONSULT cadence is adaptive, not fixed iter 10/20/30

Actual cadence: **10 / 20 / 25 (failed → self-consult) / 29 / 40 (planned)**.
V1 PROMPT mandates iter 10/20/30; the loop diverged because (a) consults
sometimes failed and (b) reframes triggered earlier-than-scheduled follow-ups
(iter 22's rubric reword was triggered by Pro Consult 004, mid-Phase-A sprint).

### 3. No META mode

Iter 23 was self-labeled "AUDIT — /meta structural fixes (STRUCTURE/FEEL tags
+ playtest template)". Iter 28 was "BUILD — META mitigation: threats-from-
behind." Both are process / structural-discipline iters, not feature builds
or audits in the rubric sense. The loop invented a META concept; v1 PROMPT
has no slot for it.

### 4. CEILING RULE doesn't cover rename, only anchor lift

Iter 11 renamed criteria 4, 5, 7, 10 wholesale (XP/upgrades/pacing/builds →
depth/ascent/compulsion/replay). The CEILING RULE only anticipated anchor
revisions when score hits a threshold. The actual mechanism — *a Pro Consult
triggers a wholesale rename* — has no protocol in v1.

### 5. STRUCTURE/FEEL/MIXED tag rule (iter 23) is undocumented in PROMPT

`/meta` diagnosis at iter 22 named "parity drift" — anchors meeting code but
not feel. Iter 23 installed STRUCTURE/FEEL/MIXED/STRUCTURE-DEFERRED tags in
the H2 RULE v2 (see `PRE-MORTEMS.md`). These tags are now load-bearing for
every score citation; v1 PROMPT mentions only generic "playtest required for
feel criteria."

### 6. Sprint authorization (user override of PLAYTEST cadence) not codified

Iter 18: user said *"do at least 15 iters before asking me for any playtest;
every 5 iter, may /agentify for creative input."* Loop adopted. V1's
"mandatory iter 5 + every 3 after" still stood as the *default*; the user
override was first-class behavior the PROMPT didn't codify.

### 7. H1 tripwire (ProceduralLevel.tscn as substrate boundary) lives in STATE, not PROMPT

Iter 4 added the rule: "the active procedural scene is still substrate
fixture. Adding gameplay siblings to it blurs engine substrate vs gameplay
layer (the iter-28 retro failure mode in disguise)." Lives in STATE.md
substrate baseline. Should graduate to PROMPT.

### 8. Falsification pace + F-numbering self-developed

Iter 33's playtest produced 4 falsifications (F005, F006, F007, F008) in
one cycle. The loop developed numbered F-tracking with `falsifications_
pending_playtest` in STATE. V1 PROMPT mentions falsifications but doesn't
codify the numbering, the "one playtest → multiple falsifications" pattern,
or the rule "if one playtest yields ≥3 falsifications, BUILD scope was too
broad."

### 9. Stall-rule misfires on "many BUILD iters between playtests"

V1 has *"3 consecutive BUILD iters with no rubric score change → halt /
switch mode."* Reality: many BUILDs accumulate value that only scores after
a PLAYTEST confirms feel anchors. The halt rule misreads this as stall.
Iter 18's sprint was a 15-iter explicit user override of this; the rule was
never appropriate during a sprint.

### 10. Ascender metrics (ascent_rate, stall_pct) self-developed in PlayerTank.gd

Iter 31 instrumented `_stall_time_total`, `_ascent_velocity_player`, run
summary on death. These are gameplay metrics the loop added inline in
PlayerTank.gd. Not in `loop/test_runner.gd`. Not documented as metrics in
PROMPT. The loop has a richer instrumentation layer than the PROMPT
acknowledges.

---

## Mechanisms the loop self-developed (v2 should codify)

| Mechanism | Origin | What it does |
|-----------|--------|--------------|
| STRUCTURE / FEEL / MIXED / STRUCTURE-DEFERRED tags | iter 23 H2 RULE v2 | Forces honest evidence type on every score citation |
| H1 tripwire (scene-additions count) | iter 4 substrate baseline | Catches substrate-blur via gameplay siblings in ProceduralLevel.tscn |
| F-numbered falsifications | iter 33 playtest | Trackable falsifications across iters; `falsifications_pending_playtest` in STATE |
| Sprint authorization (user override) | iter 18 | User says "N iters before next playtest" — PROMPT defaults yield |
| META mode | iter 23 / 28 self-label | Process / structural-discipline iter, not feature build |
| Adaptive consult cadence | iters 10/20/25/29/40 | Consults trigger follow-ups; failed consult → self-consult; reframes can trigger ahead-of-schedule |
| Rubric rename protocol | iter 11 | Pro Consult triggers wholesale criterion rename (not anchor lift) |
| Playtest template (2-question) | iter 23 | `loop/gameplay/playtest-template.md`; <30s user time; enables lighter cadence |
| Cite-prediction discipline (Pro/Self) | every iter | "If I showed this citation to Pro, would they reword the anchor?" — self-deception detector |

---

## Substrate state at iter 37

Frozen substrate (unchanged from iter 0):
- `scripts/LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`, `ProceduralStep.gd`, `ProceduralLevel.gd`
- `tools/gen_tile.py`, `tools/analyze_frame.py`
- `loop/test_runner.gd` (extended; not refactored)
- Existing `configs/*.tres` (only `configs/playable.tres` is the active scene config)

New gameplay layer (built iters 1–37, considered "soft substrate" — modify with care):
- `scripts/Bullet.gd` (iter 1)
- `scripts/Enemy.gd`, `scripts/EnemyLight.gd`, `scripts/EnemyHeavy.gd` (iters 2, 16, 24)
- `scripts/Spawner.gd` (iter 2; refactored iters 7, 8, 15)
- `scripts/PlayerTank.gd` (iter 0 baseline + heavily extended iters 3, 11, 19, 30, 31)
- `scripts/BrickBlock.gd` (HP system iter 8 area)
- Scenes for above; HUD code inline in PlayerTank.gd
- Hash anchor `f873ae60ee3c420c57cdef5762acdad857b1a763ec50b76db80971ef4503e797`

PlayerTank.gd is getting heavy (~250 lines) — does **HUD, run state, ascender
metrics, hurtbox setup, hit flash, depth tracking, restart input** all in one
script. A future iter might split out HUD + ascender-state, but not yet a
priority for the loop's progress; flagged for awareness.

---

## What survives into v2 PROMPT

1. All four structural fixes from v1 hold and stay: reachability floor, substrate freeze, PLAYTEST cadence + halt, pre-mortem step 1.
2. Stone rewrite: vertical ascender + Battle City combat feel (iter 11 wording, no VS-like text).
3. New mode: **META** — alongside BUILD/CAPABILITY/AUDIT/CONSULT/SWEEP/PLAYTEST/AWAIT.
4. H2 RULE v2 tags (STRUCTURE/FEEL/MIXED/STRUCTURE-DEFERRED) move to PROMPT step 5 SCORE rules.
5. H1 tripwire codified in SUBSTRATE FREEZE section.
6. CONSULT SCHEDULE: adaptive, not fixed.
7. CEILING RULE extended: rename protocol added.
8. New rules: falsification-pace ceiling (≥3 from one playtest → too broad), sprint authorization (user override).
9. ANTI-PATTERNS vocabulary updated (no XP/upgrade modal references).
10. HALT CONDITIONS: 3-stall rule scoped to "outside sprint window" only.

---

## Bottom line

V1 PROMPT held its shape across 37 iters but accumulated **vocabulary debt
(stone framing)** and **process debt (META mode, rubric rename, sprint
authorization, tag rules)** that the loop itself developed in response to
real friction. V2 absorbs these.

The four structural fixes from the engine-loop META-RETRO continue to be
load-bearing. Nothing in 37 iters has invalidated them. They graduate from
"experimental fixes for the engine loop's failures" to "permanent loop
protocol."
