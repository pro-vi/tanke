# tanke gameplay loop — arc-close retrospective (iter 0 → 100)

Written at iter 100 under user directive `HALT_META_REFRAME`. Closes arc 2.
Parallel to `loop/META-RETRO.md` which closed the engine arc at iter 28.

This is the *third* such reflection point in the project's life:
- Arc 1 (engine): iter 28 retro → "rubric measured wrong axis, gameplay never built"
- Arc 2 (gameplay): iter 37 mid-arc retro → PROMPT v2 rewrite, continuity preserved
- **Arc 2 close (this doc): iter 100 retro → BC mechanics replicated; identity question opens; arc 3 in `loop/originals/`**

---

## Arc shape (iter 0 → 100, three phases + a mid-arc PROMPT rewrite)

| Phase | Iters | Output | Score |
|-------|-------|--------|-------|
| **Bootstrap** | 0–4 | Bullet system fixed, enemies first version, HP/HUD/death scaffold | 0 → ~6 |
| **Build-up** | 5–10 | Enemy variety, terrain rules, BC verbs land; Consult 002 (superseded) | ~6 → ~9 |
| **Pivot** | **11** | Consult 003 → "roguelike vertical ascender + BC combat feel"; 4 of 10 criteria *renamed* | 9 → 11 |
| **Ascender shape** | 12–17 | DEPTH/TIME HUD, spawn-ahead-of-player, forest hides, steel indestructible, 2nd enemy type | 11 → ~13 |
| **First sprint** | 18–32 | User-authorized 15-iter no-playtest run (Phase A juice + Phase B roguelike depth + Phase C enemy roles); Consults 004 + 005 | ~13 → 20 |
| **F-cycle** | 33–37 | One playtest = F005-F008 (four falsifications); root-cause fixes; **PROMPT v2 rewrite** at iter 37 | 20 (unchanged across F-cycle) |
| **Build-up to iter-60 playtest** | 38–60 | Map-first directive landed; enemy types matured; ascender legibility | 20 → 32 |
| **Legibility Lock sprint** | 61–98 | 39-iter user-authorized sprint per iter-60 directive priority order; Consults 006/007/008 | 30 → 32 (mostly STRUCTURE-DEFERRED) |
| **Playtest + halt** | 99–100 | User cite Q1 + Q3 → +2; user invokes HALT_META_REFRAME | 32 → **34** |

**Final score: 34/50 across 10 criteria.** Pace: 0.34 score-points/iter, vs engine arc's 1.78. The gameplay arc traded score-velocity for substantive feature work.

---

## What the arc produced

### Engineering deliverables

| Artifact | What it does | When |
|----------|--------------|------|
| `scripts/Bullet.gd` | Manual + auto secondary firing; collision masks; lifetime | iter 1 |
| `scripts/Enemy.gd` + `EnemyLight.gd` + `EnemyHeavy.gd` | Distinct battlefield roles per Consult 004 rewording | iters 2, 16, 24 |
| `scripts/Spawner.gd` | Top-edge spawn, ascent-velocity-aware, per-band rules, stall pressure | iters 2, 7, 8, 12, 27 |
| `scripts/PlayerTank.gd` (extended) | HP/iframes/hit-flash, forest hides, ascender state (DEPTH/TIME), milestone flash, stall-time tracking, run summary | iters 0+, heavy iters 3, 11, 19, 30, 31 |
| `scripts/BrickBlock.gd` | HP-based destruction | iter 8 area |
| HUD (CanvasLayer in PlayerTank) | DEPTH, TIME, HP, death overlay | iter 11 + 30 + 31 |
| Stage-1 AI VISION (Heavy LOS-gated firing) | Pro Consult 005 H1 directive | iter 35+ |
| Ascender metrics (`_stall_time_total`, `_ascent_velocity_player`, run summary on death) | Pro Consult 005 H4 instrumentation | iter 31 |

### Loop infrastructure that emerged

| Mechanism | Where | Trigger |
|-----------|-------|---------|
| **STRUCTURE / FEEL / MIXED / STRUCTURE-DEFERRED tags** | `PRE-MORTEMS.md` H2 RULE v2 | iter 23 `/meta` nat-13 diagnosis ("parity drift") |
| **H1 tripwire** (`ProceduralLevel.tscn` substrate-blur counter) | STATE.md substrate baseline | iter 4 |
| **F-numbered falsifications** + "≥3 from one playtest = scope too broad" | `FALSIFICATIONS.md` | iter 33 (F005-F008 in one playtest) |
| **Sprint authorization** | LEDGER iter 18 | user directive *"do 15 iters before next playtest"* |
| **META mode** (process / discipline iters) | LEDGER iters 23, 28, 95-98 | self-developed for non-feature work |
| **Adaptive CONSULT cadence** | iters 10/20/25-failed/29/40/45/55/87 | reframe-worthy findings + mid-sprint reviews |
| **Wholesale rubric RENAME via consult** | iter 11 (criteria 4/5/7/10 renamed) and iter 22 (criterion 6 reworded) and iter 46 (criteria 8/9 reworded) | Consults 003, 004, 006 |
| **Mid-arc PROMPT v2 rewrite with continuity** | iter 37 | accumulated vocabulary + process debt |
| **Final-prep META freeze window** | iters 95-98 before iter 99 playtest | self-disciplined no-change buffer |

### Hash anchors (logic vs cosmetic invariants)

| Anchor | Provenance | Survived |
|--------|------------|----------|
| `f873ae60ee3c420c…` | seed 42 / `configs/playable.tres` / iter 0 baseline | iters 0–65 (cosmetic mutations + soft-substrate edits) |
| `8224ebda…` | seed 42 / first_push variant / iter 66 onward | iter 66+ deliberate config evolution |
| `23d6a2ec3bf2821f…` | iter-98 pre-playtest verification | iter 99 playtest baseline |

Three anchors across arc 2 (vs two across arc 1). Each retirement was intentional (logic shifts), not accidental drift. The cosmetic-vs-logic separation that arc 1 established held.

---

## Consults: 8 fired, 7 ADOPTED

| # | Iter | Mode | Outcome |
|---|------|------|---------|
| 001 | end-of-iter-2 | extended-pro | adopted; early framing input |
| 002 | end-of-iter-9 | extended-pro | **SUPERSEDED by 003** (Pro v1 static-base framing the user corrected) |
| 003 | mid-iter-10 | extended-pro | **ADOPTED — the reframe**: vertical ascender + BC combat feel |
| 004 | iter 20 | extended-pro | adopted; criterion-6 enemy-role rewording (H3) |
| 005 | iter 29→30 | extended-pro | adopted; ascent legibility + H4 metric instrumentation |
| 006 | iter 45 | extended-pro | adopted; mid-sprint review + criteria 8/9 reword |
| 007 | iter 55 | extended-pro | adopted; pre-playtest pulse check |
| 008 | iter 87 | extended-pro | adopted; late-sprint check |

Engine arc: 2 attempted, 0 succeeded (frozen + reaped tabs). Gameplay arc: 8 attempted, 7 adopted, 1 superseded by next. **Consult infra reliability flipped completely between arcs** — the iter-21 self-pre-mortem fallback that arc 1 relied on was rarely needed in arc 2.

---

## Falsifications: ~14 numbered, lessons cycled

Highlights:

- **F003 — Loop-scoped design framing drift** (iter 6): the "Vampire-Survivors-like" PROMPT framing was already wrong; user corrected to roguelike-ascender at iter 10 → Consult 003 reframe → iter 11 rubric rename. *The PROMPT's stone became debt within 6 iters.*
- **F004 — Spawn-from-top-edge partial failure** (iter 15): mechanism implemented but middle-of-screen spawns still occurred. *Mechanism ≠ predicate; verify the predicate.*
- **F005-F008** (iter 34, one playtest): omniscient Heavy AI, drift off map border, water not blocking, below-spawn fires when not stalling. *Single playtest → 4 Fs = BUILD scope too broad. Codified in PROMPT v2.*
- **F009-F012** (iter 60, one playtest): enemy visual distinction insufficient, juice reads as noise, death-screen typography blocks, map samey-ness (Pro H4 confirmed). *Pattern repeated. User-cite map-first as directive.*
- **F013** (iter 99): shield duration too brief to perceive value. *Signal-to-noise problem — system stacking outpacing communication.*
- **F014** (iter 99): terrain band variance unperceived; only spawn density was. *Pro Consult 003's "encounter beats" landed; iter-18 quadrant trophy from arc 1 redux — the procedural variety machinery is invisible to players.*

**Cumulative directional-prediction accuracy on feel-criteria: ~50%** (vs arc 1's 0/4 on CC). The H2 RULE v2 tags surfaced this earlier than arc 1 had any tool for.

---

## What worked across 100 iters

1. **The four engine-arc structural fixes graduated to permanent protocol.** Reachability floor, substrate freeze, PLAYTEST halt rule, pre-mortem step 1 — all held through 100 iters of arc 2 without amendment. Engine arc treated them as experimental; arc 2 confirmed them.

2. **Mid-arc PROMPT rewrite with continuity (iter 37)** absorbed vocabulary + process debt without losing state. Score, LEDGER, falsifications all carried. The mechanism is reusable; it's now codified as "expected over time" in PROMPT v2.

3. **STRUCTURE/FEEL/MIXED tags surfaced parity drift before it accumulated.** Iter 22's `/meta` nat-13 diagnosis named "anchors meeting code but not feel" — iter 23 installed the tag rule — by iter 50 retroactive `[STRUCTURE]` tagging had identified ~5 score-lifts that needed playtest verification. Arc 1 had no tool for this.

4. **Sprint authorization** turned out to be load-bearing. Two sprints (iter 18 + iter 60-99). Without it, the rigid "every 3 iters PLAYTEST" would have made the deep-build phases impossible.

5. **Adaptive consult cadence** — eight consults, seven adopted. Pro Consults *drove* the framing pivots (003, 004, 006). The skill says consults are creative direction; arc 2 confirmed they're also rubric-redirection.

---

## What didn't work / what the rubric couldn't catch

1. **Identity, not mechanics, is the limiter.** Score 34/50 is honest. The 10-criterion rubric measures mechanic-presence and feel-cohesion; it does not measure *singularity*. By iter 100 we had a polished BC-with-ascent. The user reframed because the rubric's ceiling is "polished clone," not "tanke."

2. **Procedural variety is invisible to players** (F014). The engine arc's 50/55 trophy criterion 11 (Spatial Coherence) achieved 2.628× structure_lift on `biome_balanced`. Players don't perceive it. They perceive *spawn density* differences. The engine arc's metric architecture was perceptually disconnected from gameplay. Arc 1 said this abstractly; arc 2 demonstrated it concretely.

3. **System-stacking outpaced communication** (F013). Shield, HP, ascent pressure, enemy types, terrain bands all stack. Each new system fights the prior ones for the player's attention bandwidth. The PROMPT didn't have a "system count ceiling" or "communication budget" concept. Without it, adding features made the game *less* legible.

4. **The PLAYTEST cadence works but its sample size is tiny.** Six playtests across 100 iters (iters 5, 9, 14, 33, 60, 99). Each playtest is a snapshot. The rubric requires `[FEEL]` cites for >2 on feel criteria, but a single playtest cite is weak evidence for level-4+ anchors. *Two consecutive playtests landing the same observation would be much stronger.*

5. **The compulsion-loop criterion 7 is structurally hard to score honestly.** Anchor 4 requires *"user completes 3+ runs in one session WITHOUT being asked."* Anchor 5: *"user says 'one more run' out loud."* Single playtest cycles can't reach these — they require *sustained* user engagement which the PLAYTEST format doesn't capture. C7 is at 2/5 at iter 100 and probably can't climb without a different evaluation format.

---

## Substrate state at iter 100

### Hard substrate (still frozen since arc 1)
- `scripts/LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`
- `scripts/ProceduralStep.gd`, `ProceduralLevel.gd`
- `tools/gen_tile.py`, `tools/analyze_frame.py`
- `loop/test_runner.gd` (extended; never refactored)

### Gameplay layer (arc 2 output; substrate for arc 3)
- `scripts/Bullet.gd`, `Enemy.gd`, `EnemyLight.gd`, `EnemyHeavy.gd`, `Spawner.gd`
- `scripts/PlayerTank.gd` (heavy — HUD + run state + ascender metrics + hit flash + forest hide + restart all inline)
- `scripts/BrickBlock.gd` (HP-based destruction)
- Configs: `playable.tres` (active for arc 2)
- Hash anchors: `f873ae60…` (historical), `8224ebda…` (iter 66+), `23d6a2ec…` (iter 98+)

### Loop machinery (procedural + verification)
- 8 consults filed
- ~14 falsifications with lessons
- ~100 LEDGER entries
- PROMPT v1 + v2 (v1 archived; v2 active iter 38+)
- Two retros (iter-37 + this one)

---

## What survives into arc 3

Arc 3 (`loop/originals/` — original BC stages mode) inherits:
- **All of arc 2's gameplay layer as substrate.** Bullet, Enemy, Spawner, PlayerTank, terrain — all reusable.
- **The hash-anchor pattern** but in a new role: each OG stage gets its own reference anchor.
- **The four structural fixes from arc 1** continue. Reachability floor applies to every OG level (impassable layouts get caught).
- **STRUCTURE/FEEL/MIXED tags** continue but mostly inverted — OG levels are *structure-verifiable* (layout-diff against reference), so most citations will be `[STRUCTURE]`.
- **The H2 RULE v2 pre-mortem discipline.**
- **The composition principle**: arc 1's engine became substrate for arc 2; arc 2's gameplay layer becomes substrate for arc 3.

Arc 3 introduces (preview, full PROMPT after /research phase):
- A **different loop shape**: /frontier-loop, not /greenfield-loop. Pre-existing artifact (BC's 35 stages) + constructable evaluator (per-cell terrain diff) + finite target.
- **Per-level user-story verification** in the /story-loop format.
- A **closable arc** — 35 levels = 35 done = ship.
- A **feedback channel into procedural mode**: empirical structural distributions of OG stages → tuning targets for procedural configs. Resolves F014 (procedural variety invisible) by giving procedural mode a reference set to compare against.

---

## What shouldn't survive without rework

1. **The 50/55 rubric criteria** (engine arc) referenced for substrate-tuning. Player perception data (F014) shows multiple of those criteria were measuring axes players don't see.
2. **PROMPT v2's CONSULT SCHEDULE wording** ("adaptive") needs to be more concrete for arc 3 — the OG-level loop has a different cadence shape (per-level work, not per-feature).
3. **The "feel criterion" tags** are arc-2-specific (criteria 1, 7, 8, 9, 10). Arc 3's rubric will tag differently — most OG-level criteria are structurally verifiable.

---

## What loops taught us (cumulative across arc 1 + arc 2 = 128 iters)

Three things that aren't in any current loop skill:

1. **The two-arc (now three-arc) chain pattern.** Each arc's output becomes the next arc's frozen substrate via a deliberate META-RETRO bridge. /greenfield-loop describes one loop; /frontier-loop describes one loop; no skill describes the chain.

2. **The PROMPT itself is the load-bearing artifact, and it accumulates debt.** The PROMPT mutated twice in arc 2 (v1 → v2 at iter 37; v2 due for v3 review now). Every PROMPT mutation was driven by failures the prior version missed an invariant for. *Loop skills currently treat the PROMPT as one-shot emission; in practice it's a living document.*

3. **Identity isn't a rubric criterion.** Both arcs hit 34/50 or 50/55 on rubrics that, by anchor design, couldn't distinguish "polished implementation of a known thing" from "a singular thing only this project is." This is arguably the most important lesson — and it's what motivates arc 3's framing (the OG stages give arc 2's output an external reference point that *makes* the procedural mode's singularity meaningful by contrast).

---

## The arc-2 closing line

Arc 2 built BC. Arc 3 imports BC's reference layouts so that the *next* version of arc 2's procedural mode can be measured against ground truth, not against itself. **The identity question doesn't get answered by the rubric; it gets answered by the comparison.**

Arc 2 closes at 34/50, score-feasibly capped at ~38/50 without arc 3's feedback. Continuing arc 2 in isolation would have hit diminishing returns within ~15 iters. Arc 3 unlocks the next score-ceiling lift retroactively.

Halt. Read this retro once at arc-3 iter 0. Proceed to `loop/originals/PROMPT.md` after /research phase finds clean BC level sources.
