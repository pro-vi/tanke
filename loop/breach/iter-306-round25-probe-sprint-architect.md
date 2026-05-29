# iter 306 — Round 25 (Probe Sprint variant) — Blueprint

**Date:** 2026-05-27
**Mode:** META → opens Round 25 as a **work-valid-without-playtest probe sprint**, NOT the visual-identity variant originally queued at REVIEW-QUEUE #27.
**Authority:** STATE.post_halt_direction_iter_305 — "Option B nudge accepted" → sanctioned candidate #2 (work-valid-without-playtest probes per PROMPT § iter-273 list).

---

## Why probe sprint over visual identity

Three structural facts force the choice:

1. **consult-001 has 3 falsifiable predictions, all `untested`**, expiring at iter 309 (3 iters from now). `STATE.consult_calibration = {hits:0, partial:0, misses:0, untested:0}`. Without scoring, the consult lift expires → anchors revert → 200+ iters of consult discipline produced zero calibration evidence.
2. **substrate_writes_this_arc = 92 / 120 cliff.** Visual identity sprint adds substrate writes (sprite swap-in points, atlas plumbing) — wrong direction at this watermark. Probes are mostly harness + tooling: 0-2 substrate writes per probe.
3. **The user said "kick the loop running again without feedback."** Translated: don't ask for more playtest direction; produce evidence the loop CAN produce without playtest. Visual assets generate beauty; probes generate calibration data. The hard constraint ("max 1 NEW adversarial consult before consult-001 scored") points the same way — accumulating uncalibrated artifacts is the failure mode; producing measurable structural signal is the response.

The visual identity round stays queued (still at REVIEW-QUEUE #27); it opens later when the loop has CALIBRATED structural signal to anchor visual choices against.

---

## Round 25 (Probe Sprint) — design

**Purpose:** ship work that produces evidence even when no human can play. Each probe outputs **numbers** (counts, ratios, distributions) — not narration, not labels, not "consult agrees."

**Cadence:** 240s active-build (per L16).
**Substrate budget:** strict ≤ 5 writes for entire round (currently 92 → cap at 97 before reassessment).
**Halt trigger:** if a probe surfaces a CORRECTNESS issue (hash break, test regression, reachability fail, latent bug) → halt + investigate before queuing the next.
**Close criterion:** ONE probe report committed to `loop/breach/probes/probe-NNN-<name>.md` per probe, with raw numbers + 1-paragraph interpretation. Round closes when 3 probes ship OR 12 iters elapsed (whichever first).

---

## Candidate probes (ordered by calibration-leverage against consult-001)

### Probe 1 — Q1 headless bot run: per-lane shell-consumption + outcome distribution (iter 307 candidate)

**Question:** when a stub bot drives the Q1 proof room with a fixed policy (e.g. "fire AP at every wall, switch class on cooldown"), what shell-consumption + lane-completion stats fall out?

**Why first:** it directly probes consult-001 prediction 3 ("3-strip bottom-left will be IGNORED under pressure") at the STRUCTURAL layer the bot can reach. The bot can't experience "ignored under pressure," but it CAN produce the route+shell-class hit log that PlayerTank's `record_shot_hit` already records (iter 286 instrumentation). If the recorded data shows 0% route hits under bot policy → loop knows the recap currency summary will display nothing during real play → that's a structural blocker the user playtest would hit. If it shows real route data → bot run becomes a baseline against which user playtest scoring is the FEEL-layer delta.

**Deliverable:** `loop/breach/probes/probe-001-q1-bot-baseline.md` — table of (policy, total_shells_fired, route_hits_by_class, combat_hits_by_class, lane_completion_time, deaths) for ≥3 fixed bot policies.

**Implementation:**
- Reuse `tools/q1_screenshot.gd` driver pattern; new `tools/q1_bot_run.gd` extends SceneTree, instantiates Q1ProofRoom, drives player input via `_input_dir` and `_fire()` stubbing.
- 3 bot policies: (a) "always AP," (b) "round-robin shell," (c) "HE first, AP fallback."
- Runs ≤ 1000 frames each at headless `--fixed-fps 60`; logs to JSON.
- New harness `loop/breach/test_breach_q1_bot_run.gd` verifies bot finishes without crash + produces non-empty hit log.

**Substrate writes:** 0 (driver + harness + report; PlayerTank already has `record_shot_hit` from iter 286).

**Falsifiable:** post-iter, the report exists + JSON parseable + at least one policy completes the room.

---

### Probe 2 — Shell vs obstacle deterministic combat probe matrix (later iter candidate)

**Question:** for each of (AP, HE, HEAT, APCR) × (brick, steel, water, dirt, EnemyLight, EnemyHeavy), how many hits to destroy/clear?

**Why valuable:** PRESSURES.md from iter 76 documented this matrix for archetypes. No equivalent exists for shells × terrain/enemies. Without it, the "shells as route currency" identity claim has no numerical backbone — only the Q1 proof room's hand-tuned lane layout vouches for it.

**Deliverable:** `loop/breach/probes/probe-002-shell-pressure-matrix.md` — 4×6 table of hit-counts + 1 paragraph noting where the matrix surfaces hidden dominance (e.g. if APCR ties HEAT on steel but costs less reserve, APCR is dominant strategy → economy collapses).

**Implementation:** harness only — instantiate Bullet + target, call body collision in test, count hits to break. Pure deterministic.

**Substrate writes:** 0 (pure harness).

---

### Probe 3 — UI readability pass: HUD coverage math + label-size audit (later iter candidate)

**Question:** what fraction of the 320×240 viewport is HUD-occupied at default Q1 state? What's the smallest font_size on any HUD label?

**Why valuable:** PROMPT names "HUD area ≤ 25% of viewport per blueprint" as a constraint and iter 299 surfaced "all labels were at default 16pt in pixel-art viewport." A static probe that asserts the constraint catches regression cheaply. Also surfaces whether iter-300's WoT tray + iter-298's z-stack hierarchy stay within the original ≤25% budget.

**Deliverable:** `loop/breach/probes/probe-003-hud-coverage.md` — computed coverage % + min/max label sizes + list of any constraint violations.

**Implementation:** Godot harness instantiates PlayerTank.HUD, walks children, sums ColorRect + Label areas, computes fraction. Asserts ≤ 0.25.

**Substrate writes:** 0 (pure harness).

---

### Probe 4 — Economy simulator (Python, pure-data, optional) — deferred

Same shape as iter-75 path but for shell economy: how often does the random card pool produce a "build that wins" vs "build that strands"? Defer until Probe 1 calibrates the data shape.

---

### Probe 5 — Archetype isolation room (Q1 sibling) — deferred

A second proof room targeting archetype × pressure (mirror Q1's lane structure but for the 4 archetypes). Defer until the existing Q1 room produces calibration data via Probe 1.

---

## Iter sequencing (target — loop may diverge based on probe outcomes)

| Iter | Mode | Focus |
|---|---|---|
| 306 | META | This blueprint (current iter) |
| 307 | CAPABILITY | Probe 1 — build tools/q1_bot_run.gd + harness |
| 308 | BUILD | Probe 1 — run + JSON output + report write-up |
| 309 | (BUFFER) | consult-001 expiration date — emit reminder via STATE if user still hasn't scored |
| 310 | CAPABILITY | Probe 2 — shell pressure matrix harness |
| 311 | BUILD | Probe 2 — matrix table + interpretation |
| 312 | CAPABILITY | Probe 3 — HUD coverage harness |
| 313 | BUILD | Probe 3 — coverage report |
| 314 | META | Round 25 close — consolidate findings into REVIEW-QUEUE entry; bootstrap next round |

Loop self-pacing applies — if Probe 1 surfaces a STRUCTURAL gap (e.g. record_shot_hit doesn't actually fire on bot-driven player) the next iter pivots to fixing the gap instead of advancing to Probe 2.

---

## What this round explicitly does NOT do

1. **Does not fire a 2nd adversarial consult.** Hard constraint per STATE.post_halt_direction; consult-001 must score first.
2. **Does not write substrate beyond 5 writes total** (currently 92; budget caps at 97 mid-round; if a probe needs more, that's a SPIKE-then-decide moment).
3. **Does not score consult-001 predictions itself.** Scoring is a USER act (the predictions are about player behavior). Bot probes produce ADJACENT structural evidence — they do not substitute for the human scoring.
4. **Does not extend REVIEW-QUEUE with new directional asks.** Per WATCH-FOR signal #2 (3+ new entries without closures = anti-pattern), Round 25 ships findings as PROBE REPORTS in `loop/breach/probes/` rather than new REVIEW-QUEUE direction-questions. Reports are READS for the user, not DECIDES.

---

## Anchors potentially lifted

- **C3 (Ammo as logistics)** — Probe 2's matrix would surface anchor 3+ structural evidence ("shells have asymmetric cost AND effect") via numbers. Lift candidate 3 → 4 (structural) on Probe 2 close.
- **C9 (Death attribution / recap)** — Probe 1's recap-currency output gives anchor 3 evidence ("a real run produces a death recap with cited shell-route attribution"). Lift candidate at Probe 1 close.
- **C8 (HUD legibility)** — Probe 3's coverage math gives anchor 4 evidence ("HUD area ≤ 25% verified by automated measurement"). Lift candidate at Probe 3 close.

No `[FEEL-CONSULT]` lifts in this round — that path is BLOCKED by the hard constraint until consult-001 scores.

---

## Risks

- **Bot policies may be unrealistic** — "always AP" bot doesn't reproduce a human's shell-class selection rhythm. Mitigation: report 3 distinct policies; don't claim any one of them IS player behavior. Frame as "structural floor data."
- **Probe data may be uninteresting** — if all 3 bot policies look identical, the proof room may not differentiate shell strategy as designed. Mitigation: that's a USEFUL finding — surfaces a real design gap to the user as a probe-report.
- **Time pressure from consult-001 expiry at iter 309** — only 3 iters between this blueprint and expiry. Mitigation: even if Probe 1 isn't done by iter 309, that's fine — consult expiry doesn't BREAK anything (anchors revert to floor; loop continues). The expiry is metadata, not a halt condition.

---

## Compaction safety

This blueprint is the L2 compaction-safe pointer. If a future session resumes mid-round-25, it reads this file + STATE for which probe is next + LEDGER tail for last iter's findings + the existing `loop/breach/probes/*.md` reports.
