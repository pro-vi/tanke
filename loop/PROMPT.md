# tanke — Greenfield Loop Prompt

Read this file fully before taking any action. Every section is load-bearing.

---

## CONTEXT

You are iterating on **tanke**, a Godot 4.6.2 top-down pixel tank game (GDScript only, no C#).

- **Resolution:** 320×240, pixel-snap enabled
- **Engine:** Godot 4.6.2, project at repo root
- **Core mechanic:** Infinite procedural levels via Eller's algorithm (ProceduralStep.gd — row-by-row union-find sets). 4 terrain types: Brick, Steel, Grass, Water.
- **Asset pipeline:** `tools/gen_tile.py` (PIL, 8×8 tiles), `tools/gen_sprite.py` (MLX-SD for novel sprites), `tools/compose_sheet.py` (spritesheet assembler)
- **Headless test signal:** `godot --headless --path . --script res://loop/test_runner.gd` — write and maintain this as your primary feedback mechanism

**The stone:** A complete, playable, agent-evolvable tank game where procedural level generation and game rules are fully parameter-mutable by an agent with no editor intervention.

**Build priority (in order):**
1. BrickBlock destruction — bullet impact → crumble animation → node free
2. Enemy tanks — patrol, line-of-sight, shoot; spawn from procedural sets
3. LevelConfig resource — weighted tile distribution replacing naive modular arithmetic
4. Level DNA — seed + LevelConfig → exactly reproducible level

---

## PRELOOP GATE

**Gate:** `preloop_complete: yes` in `loop/STATE.md`.

The human must complete this checklist before the loop begins iterating. Do not iterate past iter 0 until the gate is flipped.

```
[ ] Open project in Godot 4 editor (Godot.app → Import project)
    The editor will offer to convert TileSets — accept. This migrates
    TileMap tile data from Godot 3 packed format to Godot 4 sources.
[ ] After conversion, open each TileMap in Level.tscn and note the
    source_id and atlas_coords for each terrain tile. Write them to
    loop/STATE.md under "tile_source_ids".
[ ] Verify basic movement works (player tank moves, camera follows)
[ ] Confirm ProceduralLevel.tscn generates terrain without console errors
[ ] Flip preloop_complete: yes in loop/STATE.md
```

**Gate is binary.** "Almost done" does not count. The loop halts at any iter > 0 attempt if the flag is not literally `yes`.

---

## ITER 0 — BOOTSTRAP (runs once, no scoring)

On iter 0:

1. Check the gate. If `preloop_complete: no`, do exactly one thing: write a `loop/test_runner.gd` headless script that can be invoked to verify the project loads without errors. Then halt and tell the user the preloop checklist.

2. If `preloop_complete: yes`, do all of the following:
   - Create/update `loop/test_runner.gd` — headless GDScript that instantiates ProceduralLevel, steps 10 frames, and prints "PASS" or the error to stdout
   - Verify `tools/gen_tile.py` runs and produces output: `python3 tools/gen_tile.py --tile brick --variant 0 --out tools/out`
   - Read `loop/RUBRIC.md` fully. Populate concrete pixel/artifact-level anchors for every criterion using the current codebase state.
   - Write initial LEDGER entry: iter 0, mode BOOTSTRAP, state of each rubric criterion with citation evidence.
   - Commit: `git add loop/ && git commit -m "chore(loop): iter 000 — BOOTSTRAP — scaffolding"`

---

## LOOP PROTOCOL

Each iteration:

### 1. DIAGNOSE (required, ~3 sentences)
Read `loop/STATE.md`. Identify the single most under-developed dimension of the stone using the RUBRIC. Name it explicitly: "The weakest axis is [criterion] at score [N] because [evidence]."

### 2. SELECT MODE
Choose exactly one mode per iteration. Write `MODE: <chosen>` before acting.

| Mode | When to use |
|------|-------------|
| **BUILD** | Implement a game feature in GDScript. Must advance a rubric axis. |
| **CAPABILITY** | Add/extend tools — test runner, asset gen, PIL tile variants, MLX-SD integration. Justified against a stone-axis. Not yak-shaving. |
| **AUDIT** | Read existing code and rubric; adjust scores with evidence; identify contradictions. |
| **CONSULT** | Every ~10 iterations: ask "what's seductive-but-hollow about recent progress?" Use a frontier model if available, else reason adversarially yourself. |
| **AWAIT** | Only for: paid APIs without budget cap, public-publish actions, secrets the loop cannot supply. NOT for: creative choices, test results, code structure. |

**AWAIT saturation rule:** 2 consecutive AWAITs on the same logical question → default on the third iteration and document the choice.

### 3. ACT
Execute the mode. For BUILD and CAPABILITY, write code. For AUDIT, write updated scores with citations. For CONSULT, write the consult log to `loop/creative-consults.md`.

**Headless feedback:** After any BUILD change, run:
```
godot --headless --path . --script res://loop/test_runner.gd 2>&1 | tail -20
```
If it prints ERROR, fix before marking the build done. "Untested" caps the relevant rubric score at 2.

**Asset generation:** When a BUILD needs a new tile or sprite variant:
```bash
python3 tools/gen_tile.py --tile <TYPE> --variant <SEED> --out tools/out --scale 1
```
For novel sprites (enemies, explosions): `tools/gen_sprite.py`. Add provenance to `loop/ASSET-MANIFEST.md`:
```
slotId | semanticRole | source | prompt | seed | replaceability | comprehensionClaim
```

### 4. SCORE
After acting, score ALL 10 rubric criteria. Rules:
- Any score above 2 requires citation: file path + line number or tool output excerpt
- If you cannot cite it, the score is ≤ 2
- Run the "cheap dignity test": would a player who just opened the game for the first time find this output embarrassing? If yes, no criterion scores > 3 this iteration.
- Write scores to `loop/LEDGER.md` in the append-only format below

### 5. COMMIT
```bash
git add -A
git commit -m "chore(loop): iter NNN — <MODE> — <focus>"
```
No iteration ends without a commit if any file changed.

### 6. SCHEDULE NEXT
Update `loop/STATE.md`. Schedule next wake-up via ScheduleWakeup. Typical cadence: BUILD/CAPABILITY iterations take real work, so 120–270s. AUDIT/CONSULT can be shorter.

---

## LEDGER FORMAT

Append to `loop/LEDGER.md` each iteration:

```
## Iter NNN — MODE — YYYY-MM-DD
**Focus:** <one-line description>
**Changed files:** <list>

| Criterion | Score | Evidence |
|-----------|-------|----------|
| Gameplay loop | N | <citation or "untested"> |
| BrickBlock destruction | N | ... |
| Enemy AI | N | ... |
| Procedural variety | N | ... |
| LevelConfig mutability | N | ... |
| Level DNA reproducibility | N | ... |
| Visual coherence | N | ... |
| Agent editability | N | ... |
| GDScript correctness | N | ... |
| Asset pipeline | N | ... |

**Total:** NN/50
**Weakest axis next:** <criterion>
```

---

## SCORING RULES

Scores are 0–5 per criterion (max total: 50).

| Score | Meaning |
|-------|---------|
| 0 | Not started, doesn't exist |
| 1 | Scaffolded/stubbed, doesn't run |
| 2 | Runs without crash, no meaningful behavior |
| 3 | **Citation required.** Feature demonstrably works in isolation |
| 4 | **Citation required.** Feature works in context of full game |
| 5 | **Citation required.** Feature is polished, agent-mutable, and would not embarrass in a demo |

**Ceiling demolition rule:** When total score hits 35/50 faster than iter 15, the rubric was too easy. Add 2 new criteria and/or raise anchor definitions for scores 4 and 5.

---

## CONSULT SCHEDULE

Every ~10 iterations (iters 10, 20, 30, …), run a CONSULT iteration. Ask:
1. "What's seductive-but-hollow about the progress so far?"
2. "What omission would look embarrassing in a playtest in 6 months?"
3. "Is the agent-editability (LevelConfig/Level DNA) actually agent-friendly, or is it just a renamed config file?"

Write answers to `loop/creative-consults.md` with iteration number.

---

## USER-LOOK GATES

At iter 20 and iter 40 (and every 20 after), AWAIT the user to:
- Play the current build for 5 minutes
- Name the single thing that feels most wrong
- Optionally reframe the target (any reframe invalidates scores for affected criteria — mark them stale in STATE.md)

This is the only permitted AWAIT trigger besides paid APIs and secrets.

---

## HALT CONDITIONS

Stop and emit `Next action: HALT` in STATE.md if:
- `preloop_complete: no` and iter > 0 has been attempted
- 3 consecutive BUILD iterations that don't advance any rubric score (diagnose why)
- The user writes "stop" or "halt" in the session
- A destructive file operation is about to run (delete scenes, overwrite img/ without backup)

---

## ANTI-PATTERNS — DO NOT

- Score your own BUILD above 3 without running `test_runner.gd` or citing a file/line
- Use `@tool` scripts or editor plugins (we are headless-first)
- Add C# files (GDScript only per constraints)
- Modify `img/sprites_0.png` or `img/PlayerTank.png` directly (use tools/ pipeline, add to manifest)
- `await` on user-facing questions about code structure, feature order, or creative direction — decide yourself
- Let `loop/LEDGER.md` go more than 1 iteration without a commit

---

## FIRE COMMAND

```
/loop Read ./loop/PROMPT.md and follow its instructions exactly.
```
