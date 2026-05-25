# tanke — Breach Loop Prompt (arc 4, v1)

Read this file fully before taking any action. Every section is load-bearing.

This is **arc 4** of the tanke project. Arcs 1, 2, and 3 are closed
retrospectives. **Read these four files in iter-0 preloop, in order**:

1. `loop/META-RETRO.md` — arc 1 (engine, iters 0-28, 50/55)
2. `loop/gameplay/META-RETRO-iter100.md` — arc 2 (gameplay, iters 0-100, 34/50)
3. `loop/originals/iter027-meta-arc3-ceiling.md` — arc 3 (originals, iters 0-27, 51/60)
4. `loop/session-learnings-2026-05-18.md` — cross-arc lessons (L1-L6 + R1-R4)

The arc-4 substrate document is:

5. `.research/synthesis-arc4-creative-consult-2026-05-19.md` — frontier-model
   creative consult that named the "breach economy" identity anchor and the
   seven design constraints. **Treat this as the design substrate. Cite it
   from arc-4 PRE-MORTEMS when invoking any constraint.**

---

## LOOP TYPE

**Hybrid: /greenfield-loop within the three-arc /frontier chain.**

Distinct from arcs 1+2+3 because:
- The artifact exists (procedural mode + OG mode + harness from arcs 1-3)
- The evaluator does not (no pre-built rubric for "breach economy"; rubric is
  constructed in this PROMPT and will be revised per arc-2's iter-37 pattern)
- The target is exploratory (identity-as-discovered, not stage-count-as-binary)

Per /greenfield-loop invariants 1-11, rubric is replaceable; the **stone**
is not. The CONSULT defines the stone; the rubric encodes it operationally
and may be reframed via CONSULT (arc-2 pattern carry).

---

## CONTEXT

**The arc-4 stone (verbatim from CONSULT §9):**

> **Battle City as a vertical breach roguelite: a single-life tank climbs
> through fortified depth bands by managing shells, terrain destruction,
> and depot-based upgrades.**

**The identity anchor (CONSULT §6):**

> **Breach economy.** *What are you willing to spend to open the next vertical lane?*

**The anchor sentence (CONSULT §9):**

> **The tank is not becoming numerically stronger; it is becoming better
> at buying passage through specific kinds of obstruction.**

**The sentence test (CONSULT §8) — every upgrade must pass:**

> **"This upgrade helps me climb through ___ by changing how I use ___."**

Bad upgrades fail with: "by making me stronger" or "by doing more damage."

---

## SEVEN DESIGN CONSTRAINTS (from CONSULT §9, codified as PROMPT rules)

These are not aspirational. They are PROMPT-level invariants. Every iter
PRE-MORTEM cites which constraints the iter respects or risks.

1. **No upgrade choices during active combat.** All RPG choice happens at
   field depots / safe gates. Combat modals = automatic F-number.
2. **No more than three primary shell classes at first.** (AP / HE / HEAT).
3. **Every enemy type must have a readable shell/positioning relationship.**
   An enemy that has no canonical answer = decorative complexity = cut it.
4. **Every generated asset must map to an existing silhouette role.** Asset
   pipeline does not invent mechanics. Silhouette grammar gate before any
   new enemy ships.
5. **Every depth band must have a dominant terrain/enemy pressure.** No
   "generic harder enemies" bands. Each band is a specific climb problem.
6. **Every run produces a death reason tied to resource/build/route** —
   not "got overwhelmed." Death recap is harness-required.
7. **RPG progression is mostly verbs and affordances, not passive stats.**
   "+18% damage" cards fail the sentence test.

---

## SUBSTRATE FREEZE (four layers now)

### Layer 1 — Engine (frozen since arc 1)
- `scripts/LevelConfig.gd`, `BiomeConfig.gd`, `LevelDNA.gd`
- `scripts/ProceduralStep.gd`, `ProceduralLevel.gd`
- `tools/gen_tile.py` (extendable for new procedural generators; see
  CAPABILITY rules below), `tools/analyze_frame.py`
- `loop/test_runner.gd` (extend, never refactor)

### Layer 2 — Gameplay (frozen since arc 2 close at iter 100)
- `scripts/Bullet.gd`, `Enemy.gd`, `EnemyLight.gd`, `EnemyHeavy.gd`
- `scripts/Spawner.gd` (extended in arc 3 for OG rosters; still substrate)
- `scripts/PlayerTank.gd` (extended in arc 2 + arc 3; still substrate)
- `scripts/BrickBlock.gd`
- `configs/playable.tres`

### Layer 3 — Originals (frozen since arc 3 close at iter 27)
- `scripts/LevelLoader.gd`, `Eagle.gd`, `StageDirector.gd`, `Roster.gd`
- `scenes/OriginalLevel.tscn`, `Eagle.tscn`, `TitleScreen.tscn`
- `configs/stages/stage_{01..35}.tres`, `configs/og_calibrated.tres`
- `tools/png_diff.py`, `og_metrics.py`, `band_check.py`

### Layer 4 — BC source data (read-only canonical)
- `.research/repos/Tanks/` — read-only (H2 tripwire)
- `.research/synthesis-bc-level-sources-2026-05-13.md`
- `.research/synthesis-arc4-creative-consult-2026-05-19.md` (the CONSULT)

### What arc-4 ADDS (its own work)

Tentative — to be confirmed in iter 1 DECISION. Likely set:
- `scripts/Shell.gd` (or extend Bullet) — 3 shell classes with combat+terrain affordances
- `scripts/Depot.gd` + `scenes/Depot.tscn` — field depot entity + UI
- `scripts/BreachConfig.gd` — depth-band config (which terrain, which enemies, which depots)
- `scripts/Loadout.gd` — player build state (shell reserves, modules, identity tag)
- `scripts/RunRecap.gd` — death attribution capture + display
- `scenes/RunRecap.tscn` — recap overlay
- Extended `tools/gen_tile.py` — new procedural generators (depot tiles, shell-type icons, chassis variants — algorithmic, NOT MLX-SD)
- `loop/breach/BANDS.md` — depth-band roadmap (this directory)
- `loop/breach/test_breach_harness.gd` — harness extension for breach-economy verification

### Mode integration (iter 1 DECISION, gated)

Two valid paths:
- **A: Extend `ProceduralLevel.tscn` via default-on `breach_mode_enabled` flag.**
  Preserves H1 (arc 2 substrate). Loop default = arc-2 ascender; flag-on = arc-4 breach mode.
  Hash anchor `23d6a2ec…` MUST be preserved when flag-off.
- **B: New `scenes/BreachLevel.tscn` sibling.** Cleaner separation, but adds a new H1 surface and duplicates ProceduralStep wiring.

**Default recommendation: Path A** (default-on gating template; PATTERN 2 from arc 3 + L5). Loop may pick B if iter-1 SPIKE shows A is structurally infeasible.

---

## REACHABILITY FLOOR (carried)

For every depth band tested, the reachability oracle must report
`playable: true` at the band's spawn-to-exit geometry. Breach economy doesn't
override this — "I should HE my way out" is a tactical option, not a
substitute for a playable layout.

Each BUILD iter touching map generation:
```bash
godot --headless --path . --script res://loop/breach/test_breach_harness.gd \
  -- --seed 42 --band K --json
```
(harness extension is iter-1 CAPABILITY work)

---

## HASH ANCHOR (cross-arc invariant)

Arc-3 closed with `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291`
as the cross-arc regression detector (seed 42 / canonical procedural baseline).

**Every arc-4 iter that touches Layer 1/2/3 substrate MUST verify the anchor
post-commit when flag-off.** If breach mode is enabled, the anchor verification
applies to the flag-off codepath only.

PATTERN 1 from arc-3 retro: the anchor is the project-wide regression detector.

---

## PRELOOP GATE

**Gate:** `preloop_complete: yes` in `loop/breach/STATE.md`.

```
[ ] Read loop/META-RETRO.md (arc 1)
[ ] Read loop/gameplay/META-RETRO-iter100.md (arc 2)
[ ] Read loop/originals/iter027-meta-arc3-ceiling.md (arc 3)
[ ] Read loop/session-learnings-2026-05-18.md (cross-arc lessons)
[ ] Read .research/synthesis-arc4-creative-consult-2026-05-19.md (the CONSULT, the design substrate)
[ ] Verify make test exits 0 and procedural mode + OG mode both still work
[ ] Verify hash anchor 23d6a2ec… on procedural baseline (seed 42)
[ ] Flip preloop_complete: yes in STATE.md
```

Gate is binary. Loop halts if `preloop_complete: no` and iter > 0.

---

## EXPLORATION ROUND CADENCE (macro)

**The loop is non-stop.** There is no "arc close." There is no score-based exit. The loop diagnoses each iter what to do and runs until you write `playtest`, `halt`, or `stop`.

Work is organized into **exploration rounds**. Each round investigates one mechanic surface (ammo economy, depot UI, terrain affordances, enemy roles, chassis identity, etc.) and ships its findings into `REVIEW-QUEUE.md` for you to look at between sessions. When a round closes, the loop bootstraps the next one against the weakest-axis surface remaining.

```
                      EXPLORATION ROUND
   ┌──────────────────────────────────────────────────────┐
   │                                                       │
   │  SPIKE      → 2-4 parallel POCs (1 iter)             │
   │  DECISION   → pick winner, write blueprint (1 iter)  │
   │  BUILD × N  → implement; N self-determined           │
   │  CONSULT    → frontier-model creative check          │
   │  QUEUE      → append finding to REVIEW-QUEUE.md      │
   │                                                       │
   └─────────────────┬────────────────────────────────────┘
                     │
                     ▼
              BOOTSTRAP NEXT
              (diagnose next surface → next round's SPIKE)
```

**Self-diagnosis each iter.** The loop reads `STATE.md` + last 30 `LEDGER.md` entries + `REVIEW-QUEUE.md` and decides:
- Which round phase am I in? (SPIKE / DECISION / BUILD / CONSULT / between rounds)
- What's the weakest axis right now?
- Is the current mechanic shippable (passes sentence test + substrate intact + advances rubric)?
- If yes → ship to QUEUE, bootstrap next round.
- If no → continue BUILD or pivot via SPIKE.

**Round close criteria** (loop's own judgment):
- Current mechanic implements its winning SPIKE blueprint end-to-end
- Passes sentence test
- `make check` + `make test` + `make test-all` green
- Hash anchor `23d6a2ec…` preserved on procedural baseline
- LEDGER entry summarizes the finding for QUEUE

When a round closes, **immediately start the next SPIKE**. Do not pause. Do not await user signal between rounds.

**N (BUILD iters per round)** is loop-determined. Simple mechanics may need 1-3 BUILD iters; layered ones may need 8-15. Use F-numbered falsifications to detect "scope too broad" (≥3 F's in one playtest = scope-too-broad signal carried from arc 2).

**CONSULT cadence**: fire once per round (after BUILD closes, before bootstrap-next). Frontier-model creative check via /agentify with the three permanent questions (see CONSULT SCHEDULE below).

**QUEUE cadence**: every round closes with ONE `REVIEW-QUEUE.md` append. Format:
```
#K — <mechanic> — <round-NNN> — <SHA> — <status: ready-for-playtest | needs-tuning>
  Finding: <one-sentence summary>
  Affordance: <what it lets the player do>
  Risk: <what's seductive-but-hollow about this — from CONSULT>
```

---

## FIRST-ITER NOTE

The first iter of the loop is whatever the loop diagnoses. **Don't pre-script it.** Likely it'll be:
- Read the preloop checklist + flip `preloop_complete: yes`
- Inventory substrate + record hash anchor baseline
- Open the first exploration round with a SPIKE on the highest-leverage gap (likely mode-integration path A vs B, since that gates everything downstream)

If the loop wants to do something else first based on its diagnosis, let it.

---

## LOOP PROTOCOL (per iter)

Each iteration after iter 1 follows the same 7-step ritual as arc-3 PROMPT v1,
with three new modes added per session-learnings.

### Step 1 — PRE-MORTEM (required, append-only to `PRE-MORTEMS.md`)

H2 RULE v2 tags mandatory: `[STRUCTURE]`, `[FEEL]`, `[MIXED]`, or
`[STRUCTURE-DEFERRED]`. NEW for arc 4: tag `[IDENTITY-PROTECTED]` for
anchors that exist by design as a check against the loop gaming itself
(R2 from session-learnings).

Cite which of the seven CONSULT constraints this iter respects or risks.

Falsifiable claim required. Example:
> "I expect this iter to fail at: HE shell terrain-cracking might destroy
> bricks too cheaply, collapsing the 'breach economy' tradeoff into 'always
> use HE.' Falsifiable claim: at default HE cost, average run uses ≤40%
> HE for terrain (rest for combat). Tag: [STRUCTURE]. Respects CONSULT
> constraints 3, 7; risks constraint 1 if depot UI bleeds into combat."

### Step 2 — DIAGNOSE

For arc 4, "weakest axis" is phrased relative to breach economy:
> "Weakest axis: criterion 3 (Ammo as logistics) at 1/5 — shells exist but
> swap cost is zero and HE doesn't alter terrain. This iter: add swap-cost
> reload beat + HE-creates-rubble-tile."

### Step 3 — SELECT MODE

| Mode | When | Notes |
|------|------|-------|
| **BUILD** | Default. Implements a feature; must advance ≥1 rubric axis. |  |
| **BUILD-QUALITY** | NEW per L3+R4. Quality/craft work without a rubric anchor lift. Capped at 1 per 3 BUILDs. Tag iter `[QUALITY]`. | Prevents score-creep + drift |
| **SPIKE** | NEW per L1. ≥2 parallel investigations of uncertain options before a BUILD commits. Costs ~1 wall-clock slot; outputs verdict + blueprint. | Especially for: harness extensions, design forks, AUDIT-rephrase candidates |
| **CAPABILITY** | Extend `loop/breach/test_breach_harness.gd`, `tools/gen_tile.py`, or write new tools. Must justify against a rubric axis. |  |
| **AUDIT** | Re-score all criteria with fresh evidence. Every 5 iters or after substrate change. Mismatch OR Surrogate trigger per L6. | Identity-protected anchors not AUDIT-eligible (R2) |
| **CONSULT** | Adaptive cadence (~every 10 iters). | Three permanent questions below |
| **SWEEP** | Verification grid (all bands × reachability, all shells × swap-cost, all depots × UI legibility). |  |
| **META** | Process / discipline iter. Cite the meta-trigger. |  |
| **PLAYTEST** | User plays. REVIEW-QUEUE pattern (L3 carry from arc 3). | NOT 3-iter halt by default; see USER-LOOK PROTOCOL |
| **AWAIT** | Only for paid APIs / publish actions / secrets. NEVER for design / mode / content / pacing decisions. | Saturation rule: 2 consecutive AWAITs on the same question force a default on the third |

### Step 4 — ACT

After any BUILD touching mode integration (default-on flag):
- Verify hash anchor on flag-off codepath: must equal `23d6a2ec…`
- `make test` exit 0

After any BUILD adding/modifying shells:
- Run breach harness oracle (when it exists post-iter-1)
- Verify reachability on tested bands

After any BUILD adding a generated asset (algorithmic via `gen_tile.py`):
- **Silhouette grammar gate** (CONSULT constraint 4): the asset's role
  must be readable from silhouette + palette + facing + one-frame intent.
  Cite the grammar check explicitly.

### Step 5 — SCORE

Score all 10 criteria per `RUBRIC.md`. Rules:
- **Reachability floor** — band score caps at 0 if reachability fails
- **STRUCTURE / FEEL / MIXED / IDENTITY-PROTECTED tags** apply (arc-2/3 carry + R2)
- **Sentence test gate** (NEW) — any upgrade-related score above 2 requires the upgrade to pass the sentence test ("helps me climb through ___ by changing how I use ___"). Cite the sentence verbatim.
- **Three-tier ceiling reporting** (R3): score reports include "X/Y effective" alongside "X/Z absolute" where effective = auto-citable max + cognitive max, and Z = absolute max.

Append to `LEDGER.md`.

### Step 6 — COMMIT

```bash
git add -A && COMMIT_APPROVED=1 git commit -m "chore(breach): iter NNN — <MODE> — <focus>"
```

### Step 7 — SCHEDULE

ScheduleWakeup:
- BUILD / BUILD-QUALITY / IMPORT / CAPABILITY: 240s
- SPIKE: 360s (parallel work)
- AUDIT / SWEEP / META: 120s
- CONSULT: 120s if /agentify fire-and-forget; else AWAIT until consult resolves
- PLAYTEST: append to REVIEW-QUEUE; do not block (L3 from arc 3)

---

## USER-LOOK PROTOCOL (REVIEW-QUEUE pattern per L3)

Arc 4 uses REVIEW-QUEUE from day 1. NOT the 3-iter PLAYTEST halt rule.

- Append observations / playtest requests / direction-picks to `loop/breach/REVIEW-QUEUE.md`
- User batch-closes items between sessions; loop reads queue at iter start
- Items have shape: `#K — <topic> — <status: open / closed / superseded>`
- Loop continues running structurally between user reviews

PLAYTEST is invoked when a user-look gate fires (~every 15-20 iters or after
a major milestone like "first depot working end-to-end").

Sprint authorization (arc-2 carry): user may override cadence with explicit
"do N iters before next playtest."

---

## RUBRIC IS MEASUREMENT, NOT EXIT

The rubric exists to measure where the loop has invested. **High scores do not stop the loop.** If all 10 criteria hit 5/5, that means we've ground deep on the 10 surfaces named in the rubric — and now the loop bootstraps a new round on a surface the rubric DOESN'T name yet (extend RUBRIC.md to cover it, or carry the un-rubric-able exploration to the QUEUE as an open question for you).

If the loop ever feels like it's "out of work," it isn't — the BC roguelite design space is open-ended. Surfaces the loop can keep exploring (non-exhaustive):
- Ammo economy variants (AP/HE/HEAT timing, swap cost, reserve curves)
- Depot UI shapes (preview-next-band, reroll cost, slot caps)
- Chassis identities (movement profile, hitbox, special tile interaction)
- Enemy role expansions (mortar telegraph, sniper sightlines, supply-cache guard)
- Terrain affordances (rubble-ramp, ice-slide, water-bridge-on-HE)
- Death attribution / run recap (what tells you "why")
- Run scaling (band pressure curves, depot spacing)
- Build-identity surfacing (run-tag emission, recap framing)
- Algorithmic asset gen extension (chassis variants, depot tiles, HUD icons)
- Procedural-OG handshake (band-tuning informed by OG metric bands)

Each surface is a candidate for a new SPIKE → BUILD round.

---

## DEFAULT-ON SUBSTRATE GATING TEMPLATE (PATTERN 2 + L5)

When a cross-arc substrate file MUST be extended:

```gdscript
@export var <flag_name>: <T> = <OLD_BEHAVIOR_DEFAULT>
# Behavior gated on <flag_name>; when at default, code path is bit-identical
# to the prior-arc version. New behavior fires only when the flag is
# explicitly overridden (typically in the new-arc scene's instance config).
```

Plus: hash anchor verification post-edit before commit (flag-off codepath
must produce `23d6a2ec…` on seed 42).

Sanctioned arc-4 substrate writes (with default-on gating):
- `scripts/PlayerTank.gd` — add Loadout + RunRecap hooks (default off in OG + procedural modes)
- `scripts/ProceduralLevel.gd` — `breach_mode_enabled = false` flag (path A)
- `scripts/Spawner.gd` — band-aware spawning if iter-1 chooses path A
- `scripts/Bullet.gd` — multi-shell support if iter chooses extend-vs-new-Shell.gd

Any other substrate write = halt + investigate.

---

## CONSULT SCHEDULE (adaptive)

Default: ~every 10 iters. Three permanent question candidates for arc 4
(adapted from /greenfield-loop invariant 8):

1. "Is breach economy actually distinct from BC, or just BC with shell-type colors?"
2. "Are the depots earned breath beats, or menu-grind interruptions?"
3. "What's seductive-but-hollow about the recent 3 iters? What omission would look stupid in 6 months?"

Trigger conditions:
- ~every 10 iters
- A failed external CONSULT → retry within 5 iters OR fall back to written
  self-pre-mortem (arc 1 + arc 3 fallback pattern; the CONSULT result may
  arrive even when tab reports timeout — check conversation URL before
  declaring failure)
- A reframe-worthy finding → ahead-of-schedule
- After first end-to-end depot+band+breach-build run

**Capture all consults to `loop/breach/creative-consults.md`** even on
"failed" tab status (the arc-4 design CONSULT itself completed despite
timeout; this is now documented arc-4 behavior).

### Simulated-playtest CONSULT (NEW — iter 272 amendment per /greenfield-loop invariant 8 blind-adversarial protocol)

When a `[FEEL]` anchor is structurally ready to lift but real PLAYTEST is unavailable, the loop fires a **simulated-playtest CONSULT** via /agentify to produce a fresh-eye reading. This is NOT a substitute for real playtest — it's a partial signal that lets the loop lift the anchor to `[FEEL-CONSULT]` (cap 4 effective; cap 5 still requires real playtest).

**Protocol:**
1. Capture artifact: a screenshot, 30-second gameplay clip, or focused design excerpt (rubric anchor wording + the relevant scene file or HUD widget).
2. Frame the consult prompt blind-adversarially:
   - "Here is [artifact]. Without the rubric or scores, what does this make you understand? What does the player NOT understand?"
   - "What's seductive-but-hollow about this? What would look embarrassing in 6 months?"
   - "What assumption is being over-optimized?"
3. Capture response to `loop/breach/creative-consults.md` with `[SIMULATED-PLAYTEST]` header.
4. Cite the anchor as `[FEEL-CONSULT]` (effective cap 4); upgrade to `[FEEL]` (effective cap 5) only on real playtest cite.

**When to fire:**
- A `[FEEL]` anchor's structural prereqs are complete but next anchor-lift requires player perception
- Quiet-signal counter ≥ 3 (per § QUIET-SIGNAL COUNTER below)
- Round closes and the playtest gate (REVIEW-QUEUE #14 or sibling) is still open

**Honesty discipline:** the `[FEEL-CONSULT]` cite tag is mandatory — the loop never promotes a consult cite to a playtest cite. The user reviewing REVIEW-QUEUE sees clearly which anchors were lifted via simulated vs real playtest.

---

## QUIET-SIGNAL COUNTER (NEW — iter 272 per /frontier-loop quiet-signal-checkpoint)

The loop tracks how many consecutive iters have passed without **strong signal**. STATE.md carries `quiet_signal_counter`.

**Strong signal (resets counter to 0):**
- A PLAYTEST cite (`[FEEL]` anchor lift)
- A CONSULT fired AND response captured (`[FEEL-CONSULT]` or `creative-consults.md` append)
- A `[STRUCTURE]` rubric anchor lift (numerical, not re-narration)
- A harness regression caught + fixed (a real failure detected by the harness)
- A user direction (conversation, REVIEW-QUEUE, STATE amendment, LEDGER directive)
- A correctness signal (hash anchor verification on a substrate write, `make test-all` regression detected)

**NOT strong signal (does NOT reset):**
- A LEDGER STATUS-CHECK entry ("no change · hash ok · tests green")
- A BUILD-QUALITY iter without anchor lift (polish only)
- Self-authored re-narration of prior work
- A scoping/planning iter that doesn't ship anything
- Idle hash anchor verification when nothing was touched

**Counter-driven actions:**
- counter ≥ 3 → fire simulated-playtest CONSULT (per § CONSULT SCHEDULE) OR bootstrap next round OR escalate via PushNotification. Pick the option that produces strong signal; do not let counter ≥ 4 happen without escalation.
- counter ≥ 5 → emit `signal-starvation` halt-cause label (per § HALT CONDITIONS) + hard escalate via PushNotification with REVIEW-QUEUE tail summary + queued-round status

**Why:** the iter-200-268 70-iter STATUS-CHECK idle anti-pattern was unlabeled signal-starvation. Counter discipline prevents the loop from drifting into idle without registering it as a structured event.

---

## COMPACTION DISCIPLINE (per L2)

When `/architect` produces a blueprint for N>1 iters, save to
`loop/breach/iter-NNN-MMM-architect.md` automatically. Each iter reads
the blueprint instead of relying on context memory.

Multi-iter trios/sprints write blueprint at iter K BEFORE executing
iter K+1.

---

## ANTI-PATTERNS (arc-4-specific additions)

| Bad | Why | Good |
|-----|-----|------|
| `+18% damage` / `+15% reload` upgrade cards | Fails sentence test; CONSULT §4 anti-pattern | Affordance-changing upgrades only ("HE leaves rubble ramps") |
| RPG choice modal during combat | CONSULT constraint 1 violation; arc-2 F013 redux | All choices at depots |
| Generated enemy without silhouette grammar gate | CONSULT constraint 4 violation | Gate every new asset |
| Adding a fourth shell type before AP/HE/HEAT cohere | CONSULT constraint 2 violation | Three first; expand after iter-20 audit |
| Generic-harder-enemy band ("level 2 of band X") | CONSULT constraint 5 violation; depth-as-band-mush | Each band has a *specific* climb problem |
| Skipping death recap because "got overwhelmed" | CONSULT constraint 6 violation | Attribute to resource/build/route |
| Passive stat soup as primary RPG layer | CONSULT §4 + §7 violation | Verbs and affordances first; stats as garnish only if at all |
| Calling breach economy distinct without playtest evidence | Self-pre-mortem critique #1 ("BC with extra steps") | Cite a 5-min run where build description differs materially from arc-2 |
| Depots that exceed 30s dwell time | Self-pre-mortem critique #2 (Mech-Havoc garage anti-pattern) | Compact UI; meaningful but fast |
| Building terrain capability for 10+ iters before any breach iter ships | Self-pre-mortem critique #4 (capability-eats-budget) | Cap terrain CAPABILITY at 3 iters; ship breach with whatever palette exists |
| Adding a sibling scene to procedural / OG without iter-1 DECISION blueprint | H1 surface multiplication; arc-2 carry | Path A (default-on flag) is default; path B requires SPIKE justification |
| MLX-SD asset gen work | P1 NO-GO; arc-1 phantom-dependency anti-pattern | Algorithmic via extended `gen_tile.py` only |
| Rubric anchors with "and" / " + " bundling two testable clauses | R1 (bundled-anchor debt) | Split into 5a / 5b or separate criteria |
| Score-creep via meta-criterion gaming | L3 (BUILD-QUALITY mode is the correct release valve) | Tag quality iters explicitly; don't game C8/C10 |
| AUDIT-rephrasing an identity-protected anchor | R2 (these exist as gaming-prevention) | Cognitive anchors stay playtest-only by design |

---

## HALT CONDITIONS (only these — the loop otherwise runs forever)

The loop is **explicitly non-stop**. It only halts on:

- **User signal**: user writes `playtest`, `halt`, or `stop`
- **Correctness violations** (auto-halt + investigate):
  - Hash anchor `23d6a2ec…` broken on procedural baseline (cross-arc invariant)
  - `make test-all` fails on any arc-3 target (regression of merged work)
  - Reachability fails on a band and isn't fixed within the same iter
  - Hard substrate (layers 1/2/3) violated without sanctioned default-on gating

The loop does **NOT** halt on:
- Score milestones (no ceiling rule, no "arc close")
- Empty rubric-lift (instead → bootstrap next exploration round)
- F-numbered falsifications (instead → log, fix, continue)
- Compaction or session boundary (instead → resume from STATE.md + LEDGER tail)
- "Ran out of work" (instead → diagnose next surface from the open-ended list)

### Halt-cause classifier (NEW — iter 272 per /frontier-loop)

When the loop encounters a stall (quiet iter, empty DIAGNOSE, no shippable advancement, no signal lift), it does NOT silently emit a STATUS-CHECK. It LABELS the stall:

| Label | Meaning | Action |
|---|---|---|
| `signal-starvation` | Quiet-signal counter ≥ 5 (no strong signal: no playtest, no consult, no anchor lift, no metric movement). | Fire simulated-playtest CONSULT OR bootstrap next round OR escalate via PushNotification (max 1 per 10 iters). DO NOT auto-pivot to idle cadence. |
| `derivation-gap` | Loop blocked on something that could have been resolved at scope time (missing capability, ambiguous direction, undefined acceptance). | Log gap to `loop/breach/derivation-gaps.md`; escalate via PushNotification; do best-effort default per /greenfield-loop invariant 7 (judgment default + bounded escalate). |
| `stone-converged` | Current round closed AND no next round queued AND no user direction. | Bootstrap from § RUBRIC IS MEASUREMENT open-ended surface list. If no surface fits → ASK USER via PushNotification, DO NOT idle. |
| `wrong-loop` | The work has stopped fitting this loop shape (target became fixed → /frontier-loop terminal; or finite checklist → /goal-loop). | Emit label; propose loop-shape change to user. |

**Saturation rule (anti-iter-200-268-pattern):** the loop must NOT emit 2 consecutive iters with the same halt-cause label without escalating via PushNotification on the 3rd. The iter-200-268 70-iter idle pattern was unlabeled signal-starvation; this classifier prevents recurrence.

**Halt-cause is metadata, not halt.** Labeling a stall doesn't stop the loop — it tells the loop what to DO next (and tells the user what happened when they re-engage). The loop still only halts on user signal + correctness violations.

---

## DO NOT

- Modify Layer 1, 2, 3, or 4 substrate without default-on gating + hash
  anchor verification
- Modify `.research/repos/Tanks/` files (H2)
- Add MLX-SD work (P1 NO-GO verdict)
- Add an upgrade that fails the sentence test
- Add a generated enemy without silhouette grammar gate
- Add a depot UI element that requires reading during combat
- AWAIT on design / mode / content / pacing decisions
- Let LEDGER go 2+ iterations without a commit
- Use C# (GDScript only)
- Add gameplay siblings to ProceduralLevel.tscn, OriginalLevel.tscn, or TitleScreen.tscn without iter-1 DECISION blueprint
- Cite "feels breach-like" instead of a sentence-test citation or playtest cite
- Score a stat-based upgrade above 2 on any breach-economy criterion
- Pad iters with cosmetic asset work to escape the "no rubric lift" pressure (use BUILD-QUALITY mode instead)
- AUDIT-rephrase an IDENTITY-PROTECTED anchor

---

## REFERENCE FILES

| File | Purpose |
|------|---------|
| `loop/breach/PROMPT.md` | This file. Read every iter. |
| `loop/breach/RUBRIC.md` | 10 arc-4 criteria. |
| `loop/breach/STATE.md` | Current phase / iter / next action. |
| `loop/breach/BANDS.md` | 5 depth-band roadmap. |
| `loop/breach/REVIEW-QUEUE.md` | Append-only user-look queue (L3 pattern). |
| `loop/breach/LEDGER.md` | Append-only score history. |
| `loop/breach/PRE-MORTEMS.md` | Per-iter predictions. H2 RULE v2 applies. |
| `loop/breach/FALSIFICATIONS.md` | F-numbered falsifications + lessons. |
| `loop/breach/creative-consults.md` | Consult records (capture even on tab-timeout). |
| `loop/breach/iter-NNN-MMM-architect.md` | Compaction-safe blueprints (L2). |
| `loop/META-RETRO.md` | Arc 1 retro. Read once at preloop. |
| `loop/gameplay/META-RETRO-iter100.md` | Arc 2 retro. Read once at preloop. |
| `loop/originals/iter027-meta-arc3-ceiling.md` | Arc 3 retro. Read once at preloop. |
| `loop/session-learnings-2026-05-18.md` | Cross-arc lessons L1-L6 + R1-R4. Read once at preloop. |
| `.research/synthesis-arc4-creative-consult-2026-05-19.md` | THE CONSULT — design substrate. Cite from PRE-MORTEMS. |
| `loop/originals/PROMPT.md` | Arc 3 PROMPT v1. Reference for protocol details. |
| `loop/gameplay/PROMPT.md` | Arc 2 PROMPT v2. Reference for tag/sprint/H2 details. |

---

## FIRE COMMAND

```
/loop Read ./loop/breach/PROMPT.md and follow its instructions exactly.
```

The loop runs until you write `playtest`, `halt`, or `stop`. There is no other exit. Each round closes a mechanic and appends to `REVIEW-QUEUE.md`; the loop bootstraps the next round immediately without pausing.

When you want to playtest: write `playtest` in the conversation. The loop pauses, surfaces the current `REVIEW-QUEUE.md`, and awaits your direction.
