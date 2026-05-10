# tanke gameplay loop

Greenfield loop for the **gameplay phase** of tanke (Godot 4 top-down tank,
VS-like survival). Engine work is substrate; this loop builds the actual game.

## How to fire

```
/loop Read ./loop/gameplay/PROMPT.md and follow its instructions exactly.
```

Paste that into a Claude Code session at the repo root. Works cold — the
PROMPT references everything else explicitly and the new Claude doesn't need
prior session context.

## The four key differences from the prior (engine) loop

1. **Reachability is the rubric floor.** Any criterion's score caps at 0 if
   the active scene config fails the reachability oracle (`playable: false`).
   This is the explicit fix for the engine loop's iter-18 trophy that scored
   5/5 on a config the player couldn't traverse.

2. **PLAYTEST is a first-class mode.** Mandatory at iter 5 and every 3 after.
   Halts the loop at +3 iters past an unfulfilled request. The engine loop's
   user-look gate stayed open 8 iters without enforcement; this one doesn't.

3. **Substrate freeze.** Don't touch `LevelConfig` / `BiomeConfig` /
   `LevelDNA` / `ProceduralStep` / `ProceduralLevel` / `gen_tile.py` /
   `analyze_frame.py`. They're frozen. Add new scripts/scenes/configs.
   The `loop/test_runner.gd` may be extended with new gameplay metrics.

4. **Pre-mortems-in-writing are required every iter.** Iter 20 of the engine
   loop showed that pre-mortems work even when external CONSULT fails. Iter 1
   here turns it from optional discipline into a structural step — written
   *before* DIAGNOSE/MODE/ACT.

## Files in this directory

| File | Purpose |
|------|---------|
| `PROMPT.md` | The self-contained loop instruction. The loop reads this every iteration. |
| `RUBRIC.md` | 10 gameplay criteria with anchors. Reachability floor at top. |
| `STATE.md` | Phase, iteration, open seams, next action. |
| `LEDGER.md` | Append-only score history. Created iter 0. |
| `PRE-MORTEMS.md` | Append-only "what I expect to fail at" log. Created iter 1. |
| `FALSIFICATIONS.md` | When user reaction contradicts pre-mortem prediction, log here. |
| `creative-consults.md` | Iter 10/20/30 consult records. Created iter 10. |
| `HALTED.md` | Created if PLAYTEST halt rule fires. |

## Reference docs

- `loop/META-RETRO.md` — engine loop's full 28-iter retrospective; "What
  survives past the loop" section is the substrate map.
- `loop/AGENTS.md` — the engine loop's parameter map. Useful for what
  knobs exist in the substrate; do not mutate without explicit gameplay reason.
- `loop/RUBRIC.md` — the engine loop's rubric (50/55, paused). Read for
  context on what's already measured and why.

## How to halt

- Write "stop" or "halt" in the session
- Set `Next action: HALT` in `STATE.md`
- Triggered automatically if a PLAYTEST is unfulfilled for 3 iters

## Substrate knobs available (don't change; use as-is)

```
configs/playable.tres        ← active scene default; verified playable
configs/default.tres         ← engine-loop baseline; UNPLAYABLE per reachability
configs/biome_balanced.tres  ← engine-loop trophy; UNPLAYABLE per reachability
configs/{watery,fortress,balanced_steel,balanced_grass,...}.tres
configs/biome_{default_to_watery,balanced,interleave,gentle,test_depth}.tres
```

The loop should add new configs as gameplay needs require — DO NOT mutate
existing ones.

## Milestones

| Milestone | Meaning |
|-----------|---------|
| iter 1 ships fixed Bullet | criterion 1 anchor 2 (move + shoot + bullet travels) |
| iter 5 PLAYTEST passes  | core loop closes per user, criterion 1 → 3+ |
| Total ≥ 25/50 | ~half-rubric: enemies + HP + XP all working |
| Total ≥ 35/50 | If hit before iter 15, raise anchors per CEILING RULE |
| Total ≥ 45/50 | Ship candidate — extended user-look gate before claiming done |
