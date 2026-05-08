# tanke — Greenfield Loop Prompt (Procedural Engine)

Read this file fully before taking any action. Every section is load-bearing.

---

## CONTEXT

You are iterating on **tanke**, a Godot 4.6.2 top-down pixel tank game (GDScript only).

- **Resolution:** 320×240, pixel-snap enabled
- **Engine:** Godot 4.6.2, project at repo root
- **Core mechanic:** Infinite procedural levels via Eller's algorithm (ProceduralStep.gd — row-by-row union-find sets). 4 terrain types: Brick, Steel, Grass, Water.
- **Asset pipeline:** `tools/gen_tile.py` (PIL, 8×8 tiles), `tools/gen_sprite.py` (MLX-SD for novel sprites), `tools/compose_sheet.py` (spritesheet assembler)

**The stone:** A fully agent-mutable procedural level engine — where algorithm parameters, tile distribution weights, and level seeds are first-class objects an agent can read, mutate, and verify without opening the editor.

**Gameplay features (BrickBlock destruction, enemy tanks) are explicitly out of scope for this loop.** They live on a future `feat/gameplay` branch. Do not implement them here.

**Build priority (in order):**
1. **Headless oracle** — `loop/test_runner.gd` printing tile counts, Eller set metrics, tile map hash
2. **Screencapture oracle** — `tools/analyze_frame.py` analyzing PNG for terrain coverage by color
3. **LevelConfig resource** — weighted tile distribution replacing `_pave_set` modular arithmetic
4. **Level DNA** — seed + LevelConfig → exactly reproducible level; serializable
5. **Algorithm parameter space** — expose Eller's merge probability + vertical density on LevelConfig
6. **Pipeline completeness** — PIL tile → TileSet → `set_cell` → rendered pixel, full chain verified

---

## PRELOOP GATE

**Gate:** `preloop_complete: yes` in `loop/STATE.md`.

Do not iterate past iter 0 until the gate is literally `yes`.

```
[ ] Open project in Godot 4 editor (Godot.app → Import → select project.godot)
    Accept TileSet conversion when prompted.
[ ] After conversion, open each TileMap in Level.tscn and note source_id +
    atlas_coords for each terrain tile. Write to loop/STATE.md under "tile_source_ids".
[ ] Verify player tank moves, camera follows, no console errors.
[ ] Verify ProceduralLevel.tscn generates terrain without errors.
[ ] Flip preloop_complete: yes in loop/STATE.md.
```

**Gate is binary.** No partial fills. Loop halts if `preloop_complete: no` and iter > 0.

---

## ITER 0 — BOOTSTRAP (runs once, no scoring)

1. If `preloop_complete: no`: write `loop/test_runner.gd` stub only, then output the preloop checklist for the user and halt.

2. If `preloop_complete: yes`:
   - Write `loop/test_runner.gd` — headless GDScript: instantiate ProceduralLevel, step 60 frames, print tile counts per type + Eller set avg/max size + "PASS" or error
   - Write `tools/analyze_frame.py` — PIL script: reads a PNG, buckets pixels by terrain palette color, outputs JSON coverage %
   - Run `python3 tools/gen_tile.py --tile brick --variant 0 --out tools/out` — confirm it works
   - Run `godot --headless --path . --script res://loop/test_runner.gd 2>&1` — record output
   - Populate RUBRIC.md criterion 1 and 6 anchors with real evidence from these runs
   - Write iter 0 LEDGER entry (no scores — bootstrap only)
   - Commit: `git add -A && git commit -m "chore(loop): iter 000 — BOOTSTRAP — oracle scaffolding"`

---

## LOOP PROTOCOL

Each iteration:

### 1. DIAGNOSE (~3 sentences, required)

Read `loop/STATE.md`. Identify the single weakest rubric axis using the LEDGER.
Write: "Weakest axis: [criterion] at [N]/5. Evidence: [citation]. This iteration: [action]."

### 2. SELECT MODE

Write `MODE: <chosen>` before acting.

| Mode | When |
|------|------|
| **BUILD** | Implement a GDScript feature. Must advance ≥1 rubric axis. |
| **CAPABILITY** | Extend tools/ — oracle, PIL tile gen, MLX-SD pipeline. Justified against a rubric axis. |
| **AUDIT** | Re-score all criteria with fresh evidence. Do this every 5 iterations or after any BUILD changes the oracle. |
| **CONSULT** | Every ~10 iters: ask "what's seductive-but-hollow?" and "what omission would embarrass in a demo?" Write to `loop/creative-consults.md`. |
| **SWEEP** | Run the headless oracle across ≥5 seeds × ≥3 configs. Chart variance. Use to score Procedural Richness and Algorithm Variety. |
| **AWAIT** | Only for: paid APIs without budget cap, publish actions, secrets. NOT for creative or structural choices. |

**AWAIT saturation:** 2 consecutive AWAITs on the same question → default on the 3rd, document it.

### 3. ACT

**After any BUILD, run both oracles:**

```bash
# Headless oracle
godot --headless --path . --script res://loop/test_runner.gd 2>&1 | tail -30

# Screencapture oracle (requires game window open)
screencapture -x /tmp/tanke_frame.png && python3 tools/analyze_frame.py /tmp/tanke_frame.png
```

If headless oracle prints ERROR: fix before scoring. "Untested" caps the relevant score at 2.

Screencapture oracle requires the game to be running. If it's not open, skip it and note "screencapture: skipped (game not running)" in the LEDGER. Do not AWAIT the user to open it — just note and continue.

**Asset provenance:** Any new tile or sprite → add to `loop/ASSET-MANIFEST.md`:
```
slotId | semanticRole | source | prompt_or_params | seed | replaceability | comprehensionClaim
```

### 4. SCORE

Score all 10 criteria. Rules:
- Score > 2 → citation required (file:line or oracle output excerpt)
- No citation → score ≤ 2
- "Cheap dignity test": would this embarrass in a 5-minute playtest? If yes → no score > 3

Append to `loop/LEDGER.md`.

### 5. COMMIT

```bash
git add -A && git commit -m "chore(loop): iter NNN — <MODE> — <focus>"
```

No iteration ends without a commit if any file changed.

### 6. SCHEDULE

Update `loop/STATE.md`. ScheduleWakeup: BUILD/CAPABILITY = 120–270s, AUDIT/SWEEP = 60–120s.

---

## LEDGER FORMAT

```markdown
## Iter NNN — MODE — YYYY-MM-DD
**Focus:** <one line>
**Changed files:** <list>
**Oracle output:** <excerpt or "skipped">

| Criterion | Score | Evidence |
|-----------|-------|----------|
| Headless oracle | N | <cite or "not yet"> |
| Algorithm variety | N | ... |
| LevelConfig mutability | N | ... |
| Level DNA | N | ... |
| Tile visual coherence | N | ... |
| Screencapture oracle | N | ... |
| Agent edit friction | N | ... |
| Procedural richness | N | ... |
| Pipeline completeness | N | ... |
| GDScript correctness | N | ... |

**Total:** NN/50
**Weakest axis next:** <criterion>
```

---

## CEILING RULE

If total hits 35/50 before iter 15, the rubric was too easy. Add 2 criteria or raise score-4/5 anchor definitions. Note the change in RUBRIC.md Revision Log.

---

## CONSULT SCHEDULE

Iters 10, 20, 30: CONSULT mode. Questions:
1. "What's seductive-but-hollow about the procedural engine so far?"
2. "Is LevelConfig actually agent-friendly, or just a renamed config file?"
3. "What would a generative systems researcher find embarrassing about this Eller's implementation?"

Write to `loop/creative-consults.md`.

---

## USER-LOOK GATES

Iter 20 and iter 40: AWAIT the user to:
- Run the game for 5 minutes across 3 seeds
- Name what feels most monotonous about level generation
- Optionally reframe (any reframe → mark affected scores stale in STATE.md)

---

## AGENTS.md CONTRACT

Once LevelConfig exists, maintain `loop/AGENTS.md` — every agent-mutable parameter:
```
param | file | line | type | valid_range | effect
```
This is the agent's map of the parameter space.

---

## HALT CONDITIONS

- `preloop_complete: no` and iter > 0 attempted
- 3 consecutive BUILD iters with no rubric score change (diagnose and switch mode)
- User writes "stop" or "halt"
- About to delete or overwrite `img/sprites_0.png` or `img/PlayerTank.png` without backup

---

## DO NOT

- Implement BrickBlock destruction or enemy tanks (future branch)
- Use C# (GDScript only)
- Score BUILD above 3 without oracle output citation
- AWAIT on code structure or creative direction — decide yourself
- Let LEDGER go 2+ iterations without a commit

---

## FIRE COMMAND

```
/loop Read ./loop/PROMPT.md and follow its instructions exactly.
```
