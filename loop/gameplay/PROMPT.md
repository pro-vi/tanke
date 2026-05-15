# tanke — Gameplay Loop Prompt (v2 — iter 38+)

Read this file fully before taking any action. Every section is load-bearing.

**v2 supersedes v1** (archived at `loop/gameplay/PROMPT-v1.md`). The
mid-arc retrospective at `loop/gameplay/META-RETRO-iter37.md` documents
what 37 iters of running surfaced. STATE, LEDGER, scores, falsifications,
pre-mortems, and creative-consults all carry forward unchanged. The loop
continues at iter 38 with this PROMPT active.

---

## CONTEXT

You are iterating on **tanke**, a Godot 4.6.2 top-down pixel tank game
(GDScript only).

### The stone (current, iter 11 reframe via Pro Consult 003)

**A roguelike vertical tank ascender with Battle City combat feel.**

The player drives upward through an endlessly generated destructible maze,
fighting readable enemy tanks, managing terrain, surviving as long as
possible, and measuring each run by depth reached before death.

**Design law:** upward pressure is primary; Battle City is the
control/terrain reference, not the structure reference. The loop's first
job is making each ascent clearer, tenser, and more replayable.

**Load-bearing:**
- 4-direction cardinal grid tank movement (BC verb)
- BC terrain semantics: destructible brick / indestructible steel / bullets-pass-water / tank-hidden-by-forest
- Enemy tanks with distinct readable types AND distinct *battlefield roles* (iter 22 rewording, Pro Consult 004)
- Procedurally generated upward terrain (substrate identity, not curse)
- Depth ascended = run score; death ends run; restart cheap
- Forward survivability — combat happens WHILE ascending, not after

**Not in scope:**
- Static base defense (no eagle to defend; player IS what's preserved)
- Hand-crafted levels (procedural with encounter beats — see `RUBRIC.md` crit 4)
- VS-style XP modals / upgrade pools (replaced iter 11 with ascender axes)
- Two-player co-op
- MLX-SD work unless user requests

**A successful loop produces a run a friend wants to retry after dying
once,** because the climb felt close and they want to push further next
time.

---

## SUBSTRATE FREEZE (hard rule)

### Hard substrate (DO NOT modify)
- `scripts/LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`
- `scripts/ProceduralStep.gd`, `ProceduralLevel.gd`
- `tools/gen_tile.py`, `tools/analyze_frame.py`
- `loop/test_runner.gd` (extend with new metrics; don't refactor)
- Engine-loop hash anchors (`6159ef2f`, `1f80435080844dce`, `8a48346…`) — historical reference only

### Active scene substrate (NEW iter 37 codification — H1 tripwire)
`scenes/ProceduralLevel.tscn` is itself substrate. The literal-reading
defense ("only the `.gd` is frozen") is too convenient — adding gameplay
siblings to that scene blurs engine substrate vs gameplay layer (the
iter-28 engine-loop failure mode in disguise).

**Rule:** count gameplay siblings added to `ProceduralLevel.tscn`. STATE.md
tracks this as the `H1 tripwire` count. Allowed without ceremony: dynamic
instantiation (HurtBox, HUD CanvasLayer added at runtime), `Spawner`
already present. New static siblings (e.g. a third permanent node) require
a one-line justification in the LEDGER entry.

### Soft substrate (modify with care — score citations may be at risk)
- `scripts/Bullet.gd`, `Enemy.gd`, `EnemyLight.gd`, `EnemyHeavy.gd`, `Spawner.gd`
- `scripts/PlayerTank.gd` (heavy — HUD + run state + ascender metrics + hit flash all inline)
- `configs/playable.tres` (active scene config; hash anchor `f873ae60…`)

You may freely add new scripts/scenes/configs. If a soft-substrate change
breaks a score-cited behavior, log a falsification.

---

## REACHABILITY FLOOR

The reachability oracle (`loop/test_runner.gd`) is the gameplay rubric's
**hard floor**:

```
playable: bool          # rows_climbed >= MIN_ROWS_CLIMBED (default 10)
reachable_cells: int    # BFS flood-fill from spawn (20, 29)
rows_climbed: int       # rows above spawn the player can reach
```

**No criterion scores above 0 if `playable: false`.** Caps the whole rubric.

Verify before any BUILD that touches level config or scene structure:
```bash
godot --headless --path . --script res://loop/test_runner.gd \
  -- --seed 42 --json | grep '^{' | python3 -c "
import sys, json; d = json.loads(sys.stdin.read())
print(d['playable'], d['reachable_cells'], d['rows_climbed'])
"
```

---

## ITER 0 BOOTSTRAP (DONE — iter 0 completed; do not re-run)

Iter 0 verified preloop + recorded substrate baseline (hash `f873ae60…`).
The PRELOOP GATE is closed. Continue from current iter in `STATE.md`.

---

## LOOP PROTOCOL

Each iteration:

### Step 1 — PRE-MORTEM (required, append-only to `PRE-MORTEMS.md`)

Before reading STATE or picking a mode, write:
> "Going in, I expect this iter's biggest miss to be: ___."

Then add ≥1 **independently observable falsifiable claim** per H2 RULE.
For score-lift iters, also tag each claim with one of:

| Tag | Meaning | Evidence |
|-----|---------|----------|
| `[STRUCTURE]` | System exists in code; feel-impact unverified | code citation sufficient |
| `[FEEL]` | User-observable behavior verified via playtest | playtest cite required |
| `[MIXED]` | System exists AND has been playtest-cited | both required |
| `[STRUCTURE-DEFERRED]` | Built; feel verification deferred to specific later iter | code cite + named verification iter |

**Self-deception detector** (iter 22 /meta lesson): before commit, ask
*"if I showed this citation to Pro, would they reword the anchor?"* If
yes → defer or rewrite first.

### Step 2 — DIAGNOSE

Read `STATE.md`. Identify the single weakest rubric axis using LEDGER.
Write:
> "Weakest axis: [criterion] at [N]/5. Evidence: [citation]. This iter: [action]."

### Step 3 — SELECT MODE

Write `MODE: <chosen>` before acting.

| Mode | When |
|------|------|
| **BUILD** | Implement a gameplay feature. Must advance ≥1 rubric axis. |
| **PLAYTEST** | Produce a running build; ask user to play 1 round; capture reaction. See USER-LOOK PROTOCOL. |
| **CAPABILITY** | Extend `loop/test_runner.gd` or instrumentation. Justified against a rubric axis. |
| **AUDIT** | Re-score all criteria with fresh evidence. Every 5 iters or after substrate change or after `/meta` is invoked. |
| **CONSULT** | Adaptive cadence — see CONSULT SCHEDULE. |
| **SWEEP** | Run a parameter grid; cite mean/stddev for any metric with CV >15%. |
| **META** | **NEW (iter 23/28 self-developed).** Process / structural-discipline iter — not feature build or rubric audit. Examples: install discipline rule, refactor PROMPT, address `/meta` diagnosis, mitigate accumulating risk pattern. Cite the meta-trigger in the LEDGER entry (e.g. "Trigger: /meta nat-13 diagnosis" or "Trigger: 3 falsifications from one playtest"). No score lifts in META iters. |
| **AWAIT** | Only for: paid APIs without budget cap, publish actions, secrets. NEVER for design / content / mode decisions. Saturation: 2 consecutive AWAITs on same question → default on 3rd. |

### Step 4 — ACT

After any BUILD touching level config or scene structure: **re-run
reachability oracle**. If `playable: false`, fix or revert before scoring.

After any BUILD adding gameplay logic: `make test` exit 0 + `godot
--headless --quit` clean output. Real test is the user playtest.

### Step 5 — SCORE

Score all 10 criteria per `RUBRIC.md`. Rules:

- **Reachability floor**: any criterion's score is capped at 0 if `playable: false`.
- **Score > 2 on feel criteria** (1, 4, 5, 7, 8, 9, 10) requires `[FEEL]` or `[MIXED]` tagged citation. `[STRUCTURE]` doesn't count for >2 on feel.
- **Score > 2 on non-feel criteria** (2, 3, 6) can be `[STRUCTURE]` but must specify what playtest evidence would falsify the lift.
- **Cheap dignity test**: would this embarrass in a 30-second playtest?

Append to `LEDGER.md`. Cite which `[TAG]` each lift carries.

### Step 6 — COMMIT

```bash
git add -A && git commit -m "chore(gameplay): iter NNN — <MODE> — <focus>"
```

No iteration ends without a commit if any file changed.

### Step 7 — SCHEDULE

Update `STATE.md`. ScheduleWakeup:
- BUILD / CAPABILITY: 240s
- AUDIT / SWEEP / META: 120s
- PLAYTEST: AWAIT user response (no scheduled retry)

---

## USER-LOOK PROTOCOL

The engine loop's biggest miss was 8 iterations of "user-look gate open"
with no enforcement. This loop fixes that — *and* accepts user-directed
sprints (iter 18 pattern).

### Default cadence
- **First mandatory PLAYTEST at iter 5** (or first iter shoot+move+enemies all work, whichever earlier)
- **Every 3 iters thereafter**

### Sprint authorization (NEW — iter 18 pattern)
User may override the default with phrasing like *"do N iters before next playtest"* or *"do at least N iters before asking me"*. When authorized:
- The next mandatory PLAYTEST is at iter `current + N` (not current + 3)
- Halt rule shifts proportionally
- Sprint authorization must be cited in LEDGER (`User directive iter X: ...`)
- A sprint may overlap with CONSULTs (user may also authorize `/agentify` cadence — typical: every 5 iters)
- After sprint completes, default cadence resumes

### Halt rule
A PLAYTEST request unfulfilled for **3 subsequent iters** (counted from
request) → loop halts. Write `loop/gameplay/HALTED.md` with the open
question and stop. Honest halt; engine loop's 8-dormant pattern can't
recur.

### Playtest deliverable per iter
1. Verify build runs (`make test` clean, `godot --quit` returns 0)
2. Capture run config: seed, level config, current enemy roster, ascent state
3. Use `loop/gameplay/playtest-template.md` 2-question format (≤30s of user time)

### Falsification protocol (NEW — iter 33+ pattern)
- Falsifications get F-numbers in order encountered (F001, F002, …, F008+).
- Track open falsifications in STATE.md `falsifications_pending_playtest`.
- One playtest may produce multiple Fs. **If ≥3 Fs from one playtest, the prior BUILD scope was too broad** — next BUILD iter should target one F at a time. Log this as a META observation.
- Closed falsifications stay in `FALSIFICATIONS.md` with lessons.

---

## CONSULT SCHEDULE (adaptive — v2 update)

V1 said iter 10/20/30 fixed. Actual pattern is **adaptive**: typical
cadence ~every 10 iters but advances/retreats on triggers.

### Trigger conditions
- Default: roughly every 10 iters (10, 20, 30, 40, …)
- A failed external CONSULT → retry within 5 iters OR fall back to self-pre-mortem-in-writing (proven mechanism, engine iter-21)
- A reframe-worthy finding (rubric criterion seems mis-aligned, framing seems wrong) → ahead-of-schedule CONSULT request
- Sprint authorization: user may set consult sub-cadence (typical: every 5 iters within sprint)

### Permanent question set (modify if loop framing shifts)
1. "What's seductive-but-hollow about the gameplay so far?"
2. "Are enemies / ascent / death-feel cohering, or just stacking systems?"
3. "What would a Battle City + roguelike-ascender player find embarrassing in a 60-second run?"

### Write target
`loop/gameplay/creative-consults.md`. Each consult numbered (001, 002, …).
If a consult supersedes a prior one (Consult 002 → 003), mark the earlier
SUPERSEDED.

### Reframe protocol (NEW — iter 11 pattern)
A consult may trigger a **rubric rename** (not just anchor lift). When
this happens:
1. The renamed criterion gets a new title + new anchors
2. Existing scores carry over only if the new anchor's score-N still
   describes the cited evidence; otherwise reset to 0 with a stale-score
   note in STATE.md
3. RUBRIC.md Revision Log gets an entry naming the consult source
4. The PROMPT's "stone" section gets updated to the new framing

This is the iter-11 mechanism. Iter 18+ confirmed it as the right move.
Codifying so future reframes don't require process improvisation.

---

## CEILING RULE (extended)

If total hits **35/50 before iter 15**, the rubric was too easy:
- Add 2 criteria, OR
- Raise score-4/5 anchor definitions, OR
- **Rename criteria** via reframe protocol if the consult triggered this

Note any change in `RUBRIC.md` Revision Log.

V1 only contemplated anchor lifts. Iter 11's wholesale rename of 4 criteria
is the missing case. V2 codifies.

---

## ANTI-PATTERNS (v2 — vocabulary refreshed)

| Bad | Why | Good |
|-----|-----|------|
| Edit `LevelConfig.gd` to "tune the maze" | Substrate freeze | Create new `configs/*.tres`; switch the scene |
| Skip reachability check before BUILD | iter-22 engine disaster | Re-run oracle every BUILD that touches level config |
| Score feel criteria from oracle alone | Goodhart on automated metrics | `[FEEL]` or `[MIXED]` tag required for >2 on feel |
| AWAIT for design / mode decisions | iter-12 anti-pattern | Decide; commit; let falsification correct |
| Defer playtest "one more iter" | Engine loop's 8-dormant pattern | Halt rule fires at +3 iters past request |
| Add gameplay sibling to `ProceduralLevel.tscn` without ceremony | H1 tripwire substrate-blur | Dynamic instantiate from script, OR cite justification in LEDGER |
| Score >2 on `[STRUCTURE]` for a feel criterion | Parity drift (iter 22 /meta) | Tag honestly; rescore after playtest |
| Touch `_pave_set` / `ProceduralStep` | Hard substrate | Adjust via config weights or new config; never the algorithm |
| Score-lift on 3+ feel anchors in one BUILD iter | Likely conflating structure with feel | Land one anchor at a time; tag honestly |
| Treat "many BUILDs without score change" as stall in a sprint | V1 misfire | Inside a sprint window, BUILDs accumulate until playtest unlocks anchors |

---

## HALT CONDITIONS

- `preloop_complete: no` and iter > 0 attempted *(historical; already cleared iter 0)*
- A PLAYTEST request unfulfilled for 3 iters → write `HALTED.md` and stop
- Reachability fails after a BUILD and isn't fixed within the same iter
- User writes "stop" or "halt"
- Hard substrate violated — auto-revert and halt
- Active scene config's `playable` regresses to false — auto-revert and halt
- **(refined v2)** Outside a sprint window, 3 consecutive BUILD iters with no rubric score change AND no F-numbered falsification surfaced → switch to AUDIT or PLAYTEST. Inside a sprint window, this rule is suspended.

---

## DO NOT

- Modify `LevelConfig`, `BiomeConfig`, `LevelDNA`, `ProceduralStep`, `ProceduralLevel` (hard substrate)
- Re-tune existing `configs/*.tres` (create new ones if needed)
- Score above 2 on feel criteria without `[FEEL]` or `[MIXED]` tagged playtest citation
- AWAIT on design / mode / content decisions
- Let LEDGER go 2+ iterations without a commit
- Use C# (GDScript only)
- Add MLX-SD work without explicit user request
- Add static gameplay siblings to `ProceduralLevel.tscn` without an H1-tripwire LEDGER justification

---

## REFERENCE FILES

| File | Purpose |
|------|---------|
| `loop/gameplay/PROMPT.md` | This file. Read every iter. |
| `loop/gameplay/PROMPT-v1.md` | Archived v1 (iters 0–37). For provenance. |
| `loop/gameplay/META-RETRO-iter37.md` | Why v2 changed. Read once at iter 38. |
| `loop/gameplay/RUBRIC.md` | 10 criteria with anchors. Reframed iter 11. Reworded iter 22 (crit 6). |
| `loop/gameplay/STATE.md` | Current phase / iter / open seams. Updated every iter. |
| `loop/gameplay/LEDGER.md` | Append-only score history. 37 entries so far. |
| `loop/gameplay/PRE-MORTEMS.md` | Append-only per-iter predictions. H2 RULE v2 active. |
| `loop/gameplay/FALSIFICATIONS.md` | F-numbered falsifications + lessons. |
| `loop/gameplay/creative-consults.md` | 5 consults so far (002 superseded by 003). |
| `loop/gameplay/playtest-template.md` | 2-question format for ≤30s user playtests. |
| `loop/META-RETRO.md` | Engine loop retro (iters 0–28; 50/55; substrate map). |
| `loop/AGENTS.md` | Substrate parameter map. Don't mutate. |

---

## FIRE COMMAND

```
/loop Read ./loop/gameplay/PROMPT.md and follow its instructions exactly.
```
