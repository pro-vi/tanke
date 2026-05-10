# tanke — Gameplay Loop Prompt

Read this file fully before taking any action. Every section is load-bearing.

---

## CONTEXT

You are iterating on **tanke**, a Godot 4.6.2 top-down pixel tank game (GDScript only).

**Why this loop exists:** the prior loop (28 iters, archived in `loop/`) built a
procedural-engine measurement framework that scored 50/55 on its rubric. The
iter-28 retrospective (`loop/META-RETRO.md`) named the framing pivot honestly:
the loop optimized engine measurement and **never built gameplay**. A user-look
at iter 29 surfaced two latent bugs (broken shooting, unplayable density) and
one big finding: 4 of 5 measured configs scored well on structural metrics but
fail reachability. **The rubric was measuring the wrong thing.**

**This loop fixes the framing.** Engine work is now substrate. Gameplay is the
target.

### The stone

A complete Vampire-Survivors-like tank survival run:
- Manual movement + manual primary gun + auto-firing secondary weapons
- HP bar, single life, 5–10 minute runs
- Procedural maze as terrain substrate (existing `LevelConfig` / `BiomeConfig` system)
- Wave-based enemy escalation
- Kills drop XP, threshold triggers level-up modal with 1-of-3 upgrade choice
- Compounding builds; different upgrade paths *feel* different
- Death ends run; restart easily

**A successful loop produces a level a friend would want to retry after dying once.**

---

## SUBSTRATE FREEZE (hard rule)

The following are **frozen substrate**. Do not modify unless gameplay forces it:
- `scripts/LevelConfig.gd`, `scripts/BiomeConfig.gd`, `scripts/LevelDNA.gd`
- `scripts/ProceduralStep.gd`, `scripts/ProceduralLevel.gd` (procedural generation logic)
- `tools/gen_tile.py`, `tools/analyze_frame.py`
- `loop/test_runner.gd` (extend with new metrics if needed; don't refactor)
- The hash anchor pattern (`6159ef2f5464edb1` historical, `1f80435080844dce` post-iter-21, `8a4834679f9e4eb2` biome_balanced)
- All existing `configs/*.tres`

**You may**: add new scripts (Bullet.gd, Enemy.gd, Spawner.gd, etc), new scenes (Enemy.tscn, UpgradeModal.tscn, etc), new configs/, extend `test_runner.gd` with gameplay metrics.

**You may not**: re-tune `LevelConfig` weights to chase rubric scores. If a
config doesn't suit gameplay, *create a new one* (e.g. `configs/playable.tres`
already exists — use it as a model). The engine loop's hash anchors are
historical reference points, not optimization targets.

If you find yourself opening `ProceduralStep.gd` to "fix" set sizes, **stop**
— that's the iter-28 retro's named pivot pattern. Re-read this section.

---

## REACHABILITY FLOOR

The reachability oracle (added iter 29 of the engine loop) is the **gameplay
rubric's hard floor**. From `loop/test_runner.gd`:

```
playable: bool          # rows_climbed >= MIN_ROWS_CLIMBED (default 10)
reachable_cells: int    # BFS flood-fill from spawn (20, 29)
rows_climbed: int       # how many rows above spawn the player can reach
```

**No criterion in this rubric scores above 0 if the active scene's config
fails reachability.** Score caps at 0 across ALL criteria.

This is the explicit fix for the engine loop's Goodhart hole — where the
"high diversity AND high structure_lift" iter-18 trophy turned out to be on
a config the player can't traverse.

Verify before any gameplay BUILD:
```bash
godot --headless --path . --script res://loop/test_runner.gd -- --seed 42 --json | grep '^{' | python3 -c "
import sys, json; d = json.loads(sys.stdin.read())
print(d['playable'], d['reachable_cells'], d['rows_climbed'])
"
```

---

## KNOWN BROKEN (iter-1 work)

The user surfaced these via F5 playtest at the engine-loop's iter 29:

1. **Shooting is broken.** `scenes/Bullet.tscn` is in Godot 3 format (`format=2`)
   and references `res://Bullet.gd` which does not exist. The signal connection
   was fixed in engine-iter 29 (`ProceduralLevel.gd._ready()` now wires
   `player.shoot.connect(_on_PlayerTank_shoot)`), but instantiated bullets are
   scriptless `Area2D`s with no `start(pos, dir)` method. **Iter 1 must fix this.**
   Suggested approach: write `scripts/Bullet.gd` with `start(pos, dir)`, movement
   via `_physics_process`, area-entered handler that despawns on collision.
   Migrate `Bullet.tscn` to format 3, fix `extents` → `size` on RectangleShape2D.

2. **Default config was unplayable.** Fixed by setting scene's `config` to
   `configs/playable.tres` (engine-iter 29). Don't revert.

---

## PRELOOP GATE

**Gate:** `preloop_complete: yes` in `loop/gameplay/STATE.md`.

```
[ ] F5 the scene; confirm tank moves with WASD/arrows
[ ] Confirm scene loads without console errors
[ ] Confirm reachability oracle reports playable: true
[ ] (Note: shooting is known broken — that's iter 1's job)
[ ] Flip preloop_complete: yes in loop/gameplay/STATE.md
```

**Gate is binary.** No partial fills. Loop halts if `preloop_complete: no` and iter > 0.

---

## ITER 0 — BOOTSTRAP (runs once, no scoring)

1. If `preloop_complete: no`: output the preloop checklist and halt.
2. If `preloop_complete: yes`:
   - Run reachability oracle on the active scene config; record baseline reachable_cells / rows_climbed.
   - Read `loop/META-RETRO.md` "What survives past the loop" section to internalize substrate.
   - Write iter 0 LEDGER entry (no scores).
   - Commit: `git add -A && git commit -m "chore(gameplay): iter 000 — BOOTSTRAP — substrate confirmed"`

---

## LOOP PROTOCOL

Each iteration after iter 0:

### 1. PRE-MORTEM (~3 sentences, **required**)

Before reading STATE or picking a mode, write:
> "Going in, I expect this iter's biggest miss to be: ___."

This is the iter-20 → iter-21 mechanism made first-class. Pre-mortems-in-writing
worked when external CONSULT failed. Force commit to a prediction *before*
measuring; falsifications become findings instead of embarrassments.

Save to `loop/gameplay/PRE-MORTEMS.md` (append-only).

### 2. DIAGNOSE

Read `loop/gameplay/STATE.md`. Identify the single weakest rubric axis using LEDGER.
Write: "Weakest axis: [criterion] at [N]/5. Evidence: [citation]. This iteration: [action]."

### 3. SELECT MODE

Write `MODE: <chosen>` before acting.

| Mode | When |
|------|------|
| **BUILD** | Implement a gameplay feature (enemy AI, upgrade system, HP, etc). Must advance ≥1 rubric axis. |
| **PLAYTEST** | Produce a running build; ask user to play 1 round; capture reaction. **Mandatory at iter 5 and every 3 iters thereafter.** Loop halts at iter +3 if a requested PLAYTEST is unfulfilled. |
| **CAPABILITY** | Extend `loop/test_runner.gd` with a new gameplay metric (e.g. enemy counts at minute 1/3/5). Justified against a rubric axis. |
| **AUDIT** | Re-score all criteria with fresh evidence. Every 5 iters or after substrate change. |
| **CONSULT** | Iters 10/20/30: "what's seductive-but-hollow?" Write to `creative-consults.md`. **If external fails, pre-mortem-in-writing serves the role.** |
| **SWEEP** | Run a parameter grid; cite mean/stddev for any metric with CV >15%. |
| **AWAIT** | Only for: paid APIs without budget cap, publish actions, secrets. **NEVER for design or content decisions.** Saturation: 2 consecutive AWAITs on same question → default on 3rd. |

### 4. ACT

After any BUILD that touches level config or scene structure, **re-run the reachability oracle**. If `playable: false`, fix or revert before scoring.

After any BUILD that adds gameplay logic (HP, enemies, upgrades, etc), **F5 the scene yourself headfully** is not possible — but you can run `godot --headless --quit` to catch parse/load errors. The real test is the user playtest.

### 5. SCORE

Score all 10 criteria per `RUBRIC.md`. Rules:
- **Reachability floor**: any criterion's score is **capped at 0** if active scene config fails reachability.
- Score > 2 on any "feel" criterion (1, 7, 8, 9, 10) requires **playtest evidence** (cited user reaction, not just oracle output)
- Score > 2 on any other criterion requires file:line citation or oracle output excerpt
- "Cheap dignity test": would this embarrass in a 30-second playtest?

Append to `loop/gameplay/LEDGER.md`.

### 6. COMMIT

```bash
git add -A && git commit -m "chore(gameplay): iter NNN — <MODE> — <focus>"
```

No iteration ends without a commit if any file changed.

### 7. SCHEDULE

Update `loop/gameplay/STATE.md`. ScheduleWakeup: BUILD/CAPABILITY = 240s, AUDIT/SWEEP = 120s, PLAYTEST = AWAIT until user response (no scheduled retry).

---

## USER-LOOK PROTOCOL

The engine loop's biggest miss: 8 iterations of "user-look gate open" with no
enforcement. This loop fixes that.

**Mandatory PLAYTESTs:**
- **Iter 5** (or first iter where shoot+move+enemies all work — whichever earlier)
- **Every 3 iters thereafter** (8, 11, 14, ...)

**Halt rule:** if a PLAYTEST is requested in STATE.md and the user has not
provided feedback within **3 subsequent iters** (counted from when the request
was logged), the loop **halts**. Schedule no further wakeups; write a
`loop/gameplay/HALTED.md` with the open question.

This is the "honest halt" pattern from iter-28 retro, applied earlier.

**Playtest deliverable per iter:**
1. Verify build runs (`make test` clean; `godot --quit` returns 0)
2. Capture the run config: seed, level config, current upgrade pool, enemy spawn schedule
3. Output to user: "Please play one run. Specifically observe: [3 specific things]. Report what felt off."

**Falsification log:** when user reaction contradicts a pre-mortem prediction,
append to `loop/gameplay/FALSIFICATIONS.md` with the prediction, the contradiction,
and the lesson. The engine loop accumulated 4 falsifications; the new loop should
expect more, especially on "feel" axes where automated metrics can't help.

---

## CEILING RULE

If total hits 35/50 before iter 15, the rubric was too easy. Add 2 criteria
or raise score-4/5 anchor definitions. Note in `RUBRIC.md` Revision Log.

This is a direct port from the engine loop. Worked there (iter 7); should work
here too.

---

## CONSULT SCHEDULE

Iters 10, 20, 30: **CONSULT mode**.

Three permanent questions:
1. "What's seductive-but-hollow about the gameplay so far?"
2. "Is the upgrade system actually creating distinct builds, or just stacking numbers?"
3. "What would a Vampire Survivors player find embarrassing about this in a 5-min run?"

Write to `loop/gameplay/creative-consults.md`. **External agentify CONSULT
failed twice in the engine loop (iters 10, 20). If it fails again, write a
self-pre-mortem instead — that mechanism is proven.**

---

## ANTI-PATTERNS

| Bad | Why | Good |
|-----|-----|------|
| Edit `LevelConfig.gd` to "tune the maze" | Substrate freeze | Create a new `configs/*.tres` and switch the scene |
| Skip reachability check before BUILD | Iter-22 disaster (rubric 5/5 on impassable level) | Re-run oracle every BUILD that touches config |
| Score "feel" criteria from oracle alone | Goodhart on automated metrics | Require user playtest for >2 on feel axes |
| AWAIT for design choices | Iter-12 anti-pattern | Decide; commit; let falsification correct |
| Defer playtest "one more iter" | 8-iter dormant gate (engine loop) | Halt rule fires at +3 iters past request |
| Optimize structure_lift / cc_max | These are engine metrics; gameplay metrics will be different | Add new metrics to `test_runner.gd` for gameplay (enemies_killed, time_to_death, upgrades_chosen, etc) |
| Touch `_pave_set` | Engine-loop's Eller's path; substrate | If terrain selection needs tweaking for gameplay, do it via config weights |

---

## HALT CONDITIONS

- `preloop_complete: no` and iter > 0 attempted
- 3 consecutive BUILD iters with no rubric score change (diagnose, switch mode)
- A PLAYTEST request unfulfilled for 3 iters → write `HALTED.md` and stop
- Reachability fails after a BUILD and isn't fixed within the same iter
- User writes "stop" or "halt"
- About to delete `img/sprites_*.png` or `img/PlayerTank.png` without backup
- The substrate freeze rule is violated — auto-revert and halt

---

## DO NOT

- Modify `LevelConfig`, `BiomeConfig`, `LevelDNA`, `ProceduralStep`, `ProceduralLevel` (substrate)
- Re-tune existing configs/*.tres (create new ones if needed)
- Score above 2 on feel criteria without playtest citation
- AWAIT on design or content decisions
- Let LEDGER go 2+ iterations without a commit
- Use C# (GDScript only)
- Add MLX-SD work without explicit user request

---

## FIRE COMMAND

```
/loop Read ./loop/gameplay/PROMPT.md and follow its instructions exactly.
```
