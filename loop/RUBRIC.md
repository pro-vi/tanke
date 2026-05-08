# tanke — Loop Rubric

10 criteria, 0–5 scale. Any score above 2 requires citation (file:line or tool output).
Rubric is a discovered artifact — revise anchors when a criterion's ceiling is hit.

---

## 1. Gameplay Loop Completeness (0–5)

Does the game have a complete loop: move → fight → die → restart?

| Score | Anchor |
|-------|--------|
| 0 | No game loop; player spawns but nothing happens |
| 1 | Player can move; no enemies or destruction |
| 2 | Player can shoot; bullets exist but nothing reacts |
| 3 | Bullets destroy BrickBlocks; player can reach a dead end |
| 4 | Enemies exist, shoot back; player can die; game restarts |
| 5 | Win condition + score + restart feel intentional; difficulty escalates |

**Current state:** 1 — player moves and shoots, bullets exist, nothing reacts (Bullet.gd impact() calls queue_free but no BrickBlock collision response).

---

## 2. BrickBlock Destruction (0–5)

| Score | Anchor |
|-------|--------|
| 0 | BrickBlock.gd is a stub with two TODOs |
| 1 | Collision shape exists; no damage logic |
| 2 | Impact registered (print statement); no visual change |
| 3 | `scripts/BrickBlock.gd`: hp decrements on bullet hit; node freed at 0 — cite line |
| 4 | 2-frame crumble animation plays before free; frame PNGs in img/ |
| 5 | Partial destruction (e.g. 2hp → cracked sprite → crumble); satisfying pixel feedback |

**Current state:** 0 — `scripts/BrickBlock.gd:5` has `#TODO: destruction on bullet impact`.

---

## 3. Enemy AI Quality (0–5)

| Score | Anchor |
|-------|--------|
| 0 | No enemy scene or script |
| 1 | Enemy scene exists; no behavior |
| 2 | Enemy moves (patrol direction); no targeting |
| 3 | Enemy shoots toward player when LoS is clear; cite detection logic file:line |
| 4 | Enemy navigates around obstacles; doesn't get stuck on walls |
| 5 | Enemy difficulty scales with level depth; multiple enemy types or behaviors |

**Current state:** 0 — no enemy scene.

---

## 4. Procedural Variety (0–5)

| Score | Anchor |
|-------|--------|
| 0 | Level generation crashes or is empty |
| 1 | Level generates one terrain type only |
| 2 | All 4 terrain types appear; distribution feels random but not interesting |
| 3 | LevelConfig weights produce noticeably different level characters (dense/open/watery) — cite config values used |
| 4 | Biome-like zones: level feel shifts as player scrolls deeper |
| 5 | Agent can mutate LevelConfig in a single resource file and immediately see different feel without editor |

**Current state:** 2 — all 4 types generate; distribution is naive modular arithmetic (`_pave_set` in ProceduralLevel.gd:69).

---

## 5. LevelConfig Mutability (0–5)

| Score | Anchor |
|-------|--------|
| 0 | No LevelConfig; weights are hardcoded modular arithmetic |
| 1 | LevelConfig class exists; not wired to generation |
| 2 | LevelConfig loaded and passed to _pave_set; default values unchanged from old behavior |
| 3 | Changing a weight value in LevelConfig.gd produces measurably different terrain distribution — cite the weight field and test output |
| 4 | LevelConfig is a Godot Resource (.tres file); editable without touching .gd |
| 5 | LevelConfig has named presets (e.g. "urban", "swamp", "fortress"); agent can swap presets |

**Current state:** 0 — hardcoded in ProceduralLevel.gd:69–94.

---

## 6. Level DNA Reproducibility (0–5)

| Score | Anchor |
|-------|--------|
| 0 | No seed/config struct; levels are not reproducible |
| 1 | LevelDNA struct exists with seed field; not used in generation |
| 2 | Seed passed to ProceduralStep; same seed = same layout on one run |
| 3 | `level_dna.seed + level_dna.config` fully determines a level — proven by running two instances with same DNA and comparing tile maps — cite test |
| 4 | LevelDNA serializable to JSON; loadable from file |
| 5 | Loop can propose a LevelDNA mutation, apply it, and score the result — full agent-iteration cycle demonstrated |

**Current state:** 0 — `randi()` is used without stored seed.

---

## 7. Visual Coherence (0–5)

| Score | Anchor |
|-------|--------|
| 0 | Missing sprites; obvious placeholder tiles |
| 1 | All assets present; no visual consistency |
| 2 | Pixel-snap works; no floating-point jitter |
| 3 | New assets (enemy sprites, crumble frames) match existing palette — cite palette extraction from sprites_0.png |
| 4 | UI elements (score, lives) use VT323 font and fit the 320×240 aesthetic |
| 5 | Screenshot at any moment looks like a coherent game from one era |

**Current state:** 2 — existing assets work, no new assets generated yet.

---

## 8. Agent Editability (0–5)

Does an agent (me) have clear, low-friction paths to mutate game behavior?

| Score | Anchor |
|-------|--------|
| 0 | All logic interleaved; no clear edit points |
| 1 | Scripts exist but behavior is fully implicit (magic numbers) |
| 2 | Key parameters are named constants in Constants.gd |
| 3 | LevelConfig is a separate resource; BrickBlock hp is exported var — cite file:line |
| 4 | AGENTS.md documents the grammar: every mutable parameter with file, line, type, valid range |
| 5 | Loop can propose a mutation, apply it, run test_runner.gd, and score result in one iteration with no human help |

**Current state:** 1 — `PlayerTank.gd:5` has `@export var speed: int = 32` and `@export var gun_cooldown: int = 100` but game behavior is mostly hardcoded.

---

## 9. GDScript Correctness (0–5)

| Score | Anchor |
|-------|--------|
| 0 | Script parse errors; project won't load |
| 1 | Loads but throws runtime errors on play |
| 2 | Runs; deprecation warnings present; no crashes in normal play |
| 3 | No errors in test_runner.gd output — cite test run output |
| 4 | No deprecation warnings (`TileMap` → `TileMapLayer` migration complete) |
| 5 | Typed GDScript throughout; static analysis clean |

**Current state:** 2 — converted from GD3 to GD4; TileMap deprecated nodes remain; test_runner.gd not yet written.

---

## 10. Asset Pipeline Usability (0–5)

| Score | Anchor |
|-------|--------|
| 0 | tools/ doesn't exist |
| 1 | tools/ exists; scripts error on run |
| 2 | gen_tile.py produces PNGs; gen_sprite.py not yet tested |
| 3 | Full pipeline: gen_tile → compose_sheet → import to Godot TileSet — cite output file and size |
| 4 | gen_sprite.py (MLX-SD) produces an enemy sprite variant in <60s — cite output |
| 5 | Any tile or sprite in the game can be regenerated from tools/ + ASSET-MANIFEST.md with no editor intervention |

**Current state:** 2 — gen_tile.py works (`tools/out/brick_000.png` through `water_003.png` generated at 8×8); gen_sprite.py untested; MLX-SD not installed.

---

## Revision Log

| Iter | Change | Reason |
|------|--------|--------|
| 0 | Initial rubric written | Bootstrap |
