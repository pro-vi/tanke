# tanke — Originals Loop Prompt (arc 3, v1)

Read this file fully before taking any action. Every section is load-bearing.

This is **arc 3** of the tanke project. Arcs 1 (engine) and 2 (gameplay) are
closed retrospectives at `loop/META-RETRO.md` and
`loop/gameplay/META-RETRO-iter100.md`. **Read both retros once at iter 0**
before doing any work — they encode what arcs 1+2 learned and what's
frozen as substrate.

---

## LOOP TYPE

**This is a /frontier-loop**, not /greenfield-loop:
- Artifact exists (35 BC NES stages in `.research/repos/Tanks/resources/stages/{1..35}`)
- Evaluator is constructable (per-cell terrain diff + PNG cross-validation)
- Target is finite (35/35 stages reproduced + eagle gameplay + ice physics + mode selection)

Per-stage verification follows the /story-loop format (each stage is a
user-story with explicit AC).

This is the first arc where completion is **binary per unit** and the arc
has a **natural close** (35/35 done = ship).

---

## CONTEXT

**tanke** is a Godot 4.6.2 top-down tank game with a procedural ascender mode
shipped in arc 2 (`scenes/ProceduralLevel.tscn`, 34/50 on its rubric). Arc 3
adds an **Originals mode**: faithful reproduction of all 35 Battle City NES
(1985 Namco) stages with eagle gameplay, as a parallel scene to the
procedural mode.

### The stone

**Reproduce all 35 original Battle City NES stages as a Godot 4 game mode,
with eagle protect-or-die gameplay, layout-exact terrain (per-cell match to
`.research/repos/Tanks/resources/stages/`, automated PNG-diff cross-validated
against StrategyWiki rendered references), and per-stage enemy rosters mined
from Tanks's Java source.**

A successful arc-3 produces a mode a BC fan loads, recognizes Stage 1
instantly, plays linearly through stages 1→35, and says "yes, that's
Battle City."

### What arc-3 ALSO does (feedback to arc 2)

Once all 35 stages are imported, compute their structural metrics
(brick/steel/water/grass density distributions, room sizes, cc_max, ascent
geometry). These become **empirical targets** for arc 2's procedural
configs — resolving arc-2's F014 ("procedural variety unperceived; players
only notice spawn density") by giving the procedural generator a reference
set instead of self-comparison.

---

## SUBSTRATE FREEZE (hard rule — three layers now)

### Layer 1: Engine arc substrate (frozen since arc 1)
- `scripts/LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`
- `scripts/ProceduralStep.gd`, `ProceduralLevel.gd`
- `tools/gen_tile.py`, `tools/analyze_frame.py`
- `loop/test_runner.gd` (extend with new metrics; never refactor)

### Layer 2: Gameplay arc substrate (frozen as of arc-2 close at iter 100)
- `scripts/Bullet.gd` — manual + auto secondary firing
- `scripts/Enemy.gd`, `EnemyLight.gd`, `EnemyHeavy.gd` — distinct battlefield roles
- `scripts/Spawner.gd` — wave / spawn logic (will be EXTENDED for OG per-stage rosters; arc-3's only soft-substrate write into arc-2 layer)
- `scripts/PlayerTank.gd` — HP, iframes, hit-flash, forest hide, restart (will be EXTENDED for eagle-protect mechanic; arc-3's only soft-substrate write)
- `scripts/BrickBlock.gd` — HP-based destructible
- `configs/playable.tres` (active for procedural mode; do not touch)

### Layer 3: BC source data (read-only canonical)
- `.research/repos/Tanks/resources/stages/{1..35}` — canonical layouts
- `.research/repos/Tanks/src/` — read-only for per-stage enemy roster mining (iter 1-2)
- `.research/synthesis-bc-level-sources-2026-05-13.md` — the research record; cite this from arc-3 docs

### What arc-3 ADDS (new — its own work)
- `scripts/LevelLoader.gd` — parses Tanks ASCII grids → emits set_cell calls
- `scripts/Eagle.gd` + `scenes/Eagle.tscn` — base entity with HP=1, destroy = game over
- `scripts/StageDirector.gd` — manages stage progression (1→2→…→35)
- `scenes/OriginalLevel.tscn` — new mode scene, parallel to ProceduralLevel.tscn
- `scenes/TitleScreen.tscn` (or similar) — mode picker (Originals / Procedural)
- `configs/stages/stage_{01..35}.tres` — per-stage data (terrain ref + enemy roster + ice flag)
- `tools/png_diff.py` — PIL pipeline: render-our-stage → classify-tiles → diff against StrategyWiki Stage_K.png
- `loop/originals/STAGES.md` — checklist of 35 stages, ✓ as each completes

### H1 tripwire (carried from arc 2)
`scenes/ProceduralLevel.tscn` is substrate. **Do not add gameplay siblings.**
Arc 3 builds a NEW scene (`OriginalLevel.tscn`); the procedural scene is
untouched.

**H2 tripwire (new for arc 3)**: any modification to `.research/repos/Tanks/`
is a substrate violation. Read-only. If parsing requires preprocessing,
copy data into `configs/stages/` and parse-from-copy.

---

## REACHABILITY FLOOR (carried from arcs 1+2)

For every imported stage, the reachability oracle must report
`playable: true`. If it doesn't, the import is broken (either the loader,
or the source data interpretation, or the eagle position blocks all paths).

Each stage iter must:
```bash
godot --headless --path . --script res://loop/test_runner.gd \
  -- --seed 42 --scene res://scenes/OriginalLevel.tscn \
     --og-stage K --json | grep '^{' | python3 -c "
import sys, json; d = json.loads(sys.stdin.read())
print(d['playable'], d['reachable_cells'], d['rows_climbed'])
"
```

(test_runner extension needed for `--scene` and `--og-stage K` flags — that's
arc-3's iter 0 capability work.)

---

## KNOWN GAPS (iter 0-2 work)

These were surfaced by `.research/synthesis-bc-level-sources-2026-05-13.md`:

1. **Eagle entity doesn't exist.** Tanks's layout has a brick fortress at
   bottom-center but no eagle entity. Arc 3 must create `Eagle.gd` /
   `Eagle.tscn` with: 16×16 sprite, HP=1, destroy on bullet hit, signal
   `eagle_destroyed` → game over. Position: per-stage, derived from
   layout (typically tile (12, 24) or similar in 26×26 coords; verify
   against Tanks's source).
2. **Ice physics undefined.** `-` symbol appears in some Tanks stages.
   Decision (defer to phase-1 explicit decision iter): slide-physics
   (BC-faithful) or pass-through (simpler v1)?
3. **Per-stage enemy rosters not in level files.** Tanks's stage files are
   terrain-only. Per-stage enemy spawn counts + types live in Tanks's
   Java source. **Iter 1-2 includes a sub-research step** to grep/read
   Tanks's `src/` for canonical roster data; if not found, fall back to
   Wikipedia or brian_sulpher GameFAQs walkthrough.
4. **Mode selection scene doesn't exist.** Default scene is
   `ProceduralLevel.tscn`. Arc 3 adds a title-screen / mode-picker.
5. **PNG-diff oracle needs building.** No tool yet compares rendered-stage
   to reference PNG. `tools/png_diff.py` is iter-1-2 capability work.

---

## PRELOOP GATE

**Gate:** `preloop_complete: yes` in `loop/originals/STATE.md`.

```
[ ] Read loop/META-RETRO.md (arc 1, engine retro)
[ ] Read loop/gameplay/META-RETRO-iter100.md (arc 2, gameplay retro)
[ ] Read .research/synthesis-bc-level-sources-2026-05-13.md (this arc's research substrate)
[ ] Verify .research/repos/Tanks/resources/stages/1 exists and matches synthesis stage-1 sample
[ ] Verify make test exits 0 and procedural mode (loop/gameplay) still works
[ ] Flip preloop_complete: yes
```

Gate is binary. Loop halts if `preloop_complete: no` and iter > 0.

---

## ITER 0 — BOOTSTRAP (runs once, no scoring)

1. If `preloop_complete: no`: output checklist, halt.
2. If `preloop_complete: yes`:
   - Verify reachability oracle still passes on procedural scene (sanity)
   - Record hash anchor of current procedural baseline for cross-arc invariant
   - Inventory: which stage files exist in `.research/repos/Tanks/resources/stages/`?
   - Write iter 0 LEDGER entry (no scores)
   - Commit: `chore(originals): iter 000 — BOOTSTRAP — substrate verified, sources inventoried`

---

## LOOP PROTOCOL

Each iteration after iter 0 follows the same 7-step ritual as arc 2's
PROMPT v2, with adaptations for frontier-loop shape:

### Step 1 — PRE-MORTEM (required, append-only to `PRE-MORTEMS.md`)

Carried from arc 2: H2 RULE v2 tags mandatory.

For frontier-loop iters, pre-mortems often look like:
> "I expect this iter to fail at: parsing Tanks stage K's row 14 — the
> @@ steel pattern might span column 22-25 incorrectly because my offset
> math is wrong. Falsifiable claim: stage K loads without parse error
> AND reachability passes AND PNG diff < 5%. Tag: [STRUCTURE]."

### Step 2 — DIAGNOSE

For arc 3, "weakest axis" is often phrased as "which stage / capability is
the next deliverable?" Use:
> "Weakest axis: criterion 7 (Stages 1-12 complete) at 3/5 — stages 1-6
> imported and cross-validated; stages 7-9 imported but PNG-diff pending;
> stages 10-12 not yet started. This iter: import stages 7-9 + run PNG
> diff oracle on all stages 7-9."

### Step 3 — SELECT MODE

| Mode | When |
|------|------|
| **BUILD** | Default. Implement a feature, import N stages, write a script. Must advance ≥1 rubric axis. |
| **IMPORT** | Sub-mode of BUILD specifically for stage-import iters. Iter targets 2-5 stages, runs PNG-diff oracle, updates STAGES.md checklist. |
| **CAPABILITY** | Extend `loop/test_runner.gd` or `tools/png_diff.py`. Justify against a rubric axis. |
| **AUDIT** | Re-score all criteria with fresh evidence. Every 5 iters or after substrate change. |
| **CONSULT** | Adaptive cadence (~every 10 iters). Especially valuable around design decisions: eagle gameplay shape, ice physics, end-of-arc-3 → arc-4 framing. |
| **SWEEP** | Run a verification grid (e.g. all 35 stages × reachability oracle). |
| **META** | Process / discipline iter. Cite the meta-trigger. |
| **PLAYTEST** | User plays. Different cadence than arc 2 — see USER-LOOK PROTOCOL below. |
| **AWAIT** | Only for paid APIs / publish actions / secrets. Never for design decisions. |

### Step 4 — ACT

After any BUILD that imports or modifies stages: **re-run reachability oracle
on the affected stage(s)**. If `playable: false`, fix or revert before scoring.

After any BUILD that changes Bullet/Enemy/Spawner/PlayerTank (the soft-substrate
arc-2 carry): `make test` exit 0 + verify procedural mode still works (the
arc-2 baseline must not regress; this is arc-3's hash-anchor analog).

### Step 5 — SCORE

Score all 10 criteria per `RUBRIC.md`. Rules:
- **Reachability floor**: criteria 7/8/9 (per-bucket stage counts) cap at 0
  if any included stage fails reachability.
- **PNG-diff floor** (NEW): criteria 7/8/9 cap at the count of stages that
  pass automated PNG diff < 5% mismatch. Cite the diff result.
- **STRUCTURE / FEEL / MIXED tags** apply (arc-2 carry).
- Arc 3 is mostly STRUCTURE-cited (terrain match is verifiable code-side); FEEL cites apply to eagle gameplay, mode-selection UX, and end-to-end playthrough.

Append to `LEDGER.md`. Update `STAGES.md` per-stage checkbox state.

### Step 6 — COMMIT

```bash
git add -A && git commit -m "chore(originals): iter NNN — <MODE> — <focus>"
```

### Step 7 — SCHEDULE

ScheduleWakeup:
- BUILD / IMPORT / CAPABILITY: 240s
- AUDIT / SWEEP / META: 120s
- PLAYTEST: AWAIT user response (no scheduled retry)

---

## USER-LOOK PROTOCOL (arc-3-specific)

Arc 3's playtest cadence is different. Stages import in batches; each
batch is cheap to playtest (load + walk through). Schedule:

- **Iter 1 (or first iter where mode-select + stage-1 load works)**: PLAYTEST — "load stage 1, walk through, eagle visible, exit cleanly"
- **After every 5 stages imported**: PLAYTEST checkpoint (stages 5, 10, 15, 20, 25, 30, 35)
- **Iter that ships end-to-end mode (stage 1 → 35 progression)**: full PLAYTEST
- **Halt rule** (arc-2 carry): PLAYTEST unfulfilled for 3 iters → halt + write `HALTED.md`

Sprint authorization (arc-2 carry): user may override cadence with explicit
phrasing.

Playtest deliverable per iter: 2-question format from
`loop/gameplay/playtest-template.md`, with stage-specific questions like
*"Does Stage K look recognizable as Battle City Stage K? Does the eagle
survive a basic enemy attack?"*

---

## CEILING RULE

If total hits 35/50 before iter 15, the rubric was too easy. Add 2
criteria or raise score-4/5 anchor definitions, or RENAME criteria via
reframe protocol if a consult triggered this. (Arc 2's reframe pattern
carries.)

Less likely to fire in arc-3 because the score is closely tied to
binary completion (X/35 stages done) — but possible if eagle/ice/PNG-diff
all land cleanly in early iters.

---

## CONSULT SCHEDULE (adaptive)

Default: ~every 10 iters. Three permanent question candidates:

1. "Is the imported stage K (or batch) faithfully BC, or just structurally similar?" (perception cross-check)
2. "Does the eagle mechanic make stages feel like BC, or like arc-2's depth-as-score with extra steps?"
3. "What would a BC fan find embarrassing about a specific imported stage in a 60-second playtest?"

Trigger conditions (arc-2 carry):
- ~every 10 iters
- A failed external CONSULT → retry within 5 iters OR fall back to self-pre-mortem
- A reframe-worthy finding → ahead-of-schedule
- After all 35 stages are imported but before end-of-arc evaluation

---

## ANTI-PATTERNS (arc-3-specific additions)

| Bad | Why | Good |
|-----|-----|------|
| Modify `.research/repos/Tanks/` files | H2 tripwire (read-only canonical) | Parse-from-copy; never edit upstream |
| Skip PNG-diff because "stage looks right" | Automated cross-validation is the arc-3 quality floor | Run `tools/png_diff.py` every stage; cite result |
| Add gameplay siblings to `ProceduralLevel.tscn` | H1 tripwire (arc-2 carry) | Build new scenes; never edit arc-2 scenes |
| Modify `LevelConfig`/`BiomeConfig`/`ProceduralStep` to "tune for OG mode" | Hard substrate (arc-1 carry) | OG mode reads from Tanks; doesn't need procedural config |
| Score stages 1-12 = 5/5 without verifying ALL 12 pass PNG diff | Goodhart on stage-count without quality gate | Cite per-stage diff result; stale until all 12 pass |
| Conflate Tank 1990 (50 stages) with canonical BC (35) | Disqualifying source confusion | If any source claims >35 stages, reject |
| Defer eagle gameplay to "after all stages" | Eagle is integral to BC identity, not a polish layer | Eagle goes in iter 1-3, before mass stage import |
| Treat ice (`-`) as plain floor without phase-1 decision | Hidden physics shortcut | Explicit decision iter; ship one approach; F-number if wrong |
| Add MLX-SD work / new image generation | Out of arc-3 scope | If new sprites needed, hand-craft or extract from arc-2's gen_tile pipeline |

---

## HALT CONDITIONS

- `preloop_complete: no` and iter > 0 attempted
- 3 consecutive BUILD iters with no rubric score change AND no F-number AND no stage-imported-and-verified (outside any sprint window)
- A PLAYTEST request unfulfilled for 3 iters → `HALTED.md` and stop
- Reachability fails on a stage after import and isn't fixed within the same iter
- PNG-diff regression on a previously-passing stage and isn't fixed within the same iter
- Procedural mode (arc-2) regresses — hash anchor changes unexpectedly → halt, investigate
- User writes "stop" or "halt"
- Hard substrate (layer 1 or 2) violated → auto-revert and halt
- All 35 stages complete + eagle + ice + end-to-end playable + PNG diff all-passing → **arc 3 closes successfully**

---

## DO NOT

- Modify hard substrate (`LevelConfig`, `BiomeConfig`, `LevelDNA`, `ProceduralStep`, `ProceduralLevel`)
- Modify arc-2 substrate (`Bullet.gd`, `Enemy*.gd`) without justification + procedural-mode regression check
- Modify `.research/repos/Tanks/` files
- Re-tune `configs/playable.tres` or any other arc-2 config
- Score above 0 on any stage-count criterion (7/8/9) for stages that haven't passed PNG diff
- AWAIT on design / mode / content decisions
- Let LEDGER go 2+ iterations without a commit
- Use C# (GDScript only)
- Add MLX-SD work without explicit user request
- Add gameplay siblings to `ProceduralLevel.tscn`
- Cite "looks right" instead of automated diff result

---

## REFERENCE FILES

| File | Purpose |
|------|---------|
| `loop/originals/PROMPT.md` | This file. Read every iter. |
| `loop/originals/RUBRIC.md` | 10 arc-3 criteria. |
| `loop/originals/STATE.md` | Current phase / iter / next action. |
| `loop/originals/STAGES.md` | 35-stage checklist (✓ as each completes). |
| `loop/originals/LEDGER.md` | Append-only score history. |
| `loop/originals/PRE-MORTEMS.md` | Per-iter predictions. H2 RULE v2 applies. |
| `loop/originals/FALSIFICATIONS.md` | F-numbered falsifications + lessons. |
| `loop/originals/creative-consults.md` | Consult records. |
| `loop/META-RETRO.md` | Arc 1 retro (engine, iters 0-28). Read once at iter 0. |
| `loop/gameplay/META-RETRO-iter100.md` | Arc 2 retro (gameplay, iters 0-100). Read once at iter 0. |
| `loop/gameplay/PROMPT.md` | Arc 2 PROMPT v2. Reference for protocol details (much of arc-3's protocol is carried). |
| `.research/synthesis-bc-level-sources-2026-05-13.md` | The research that anchors arc 3. |
| `.research/repos/Tanks/` | Cloned source (gitignored; read-only). |

---

## FIRE COMMAND

```
/loop Read ./loop/originals/PROMPT.md and follow its instructions exactly.
```
