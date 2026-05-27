# iter 317 — Round 27 (Replay Capture Probe) — Blueprint

**Date:** 2026-05-27
**Mode:** META → opens Round 27 as a single-probe replay-capture round per PROMPT § work-valid-without-playtest surface list.
**Lineage:** post_halt_direction Options A+B both served; this is the loop-selected next frontier per `stone-converged` halt-cause-label resolution path ("archive current stone, start next frontier from work-valid-without-playtest surface list"). User has not provided fresh direction in 11 iters this session; the standing-direction "loop runs non-stop" PROMPT clause + the surface list ARE sufficient justification.

---

## Why replay capture next

Rounds 25+26 produced 4 probe reports + visible visual identity work but ALL of it was STATIC evidence:
- Probe 1 (Q1 bot baseline): aggregate stats per fixed bot policy.
- Probe 2 (shell × target matrix): cell-by-cell mechanic numbers.
- Probe 3 (HUD coverage): static coverage math.
- Probe 4 (brick variant): pipeline + activation.

None of these captured **temporal dynamics** — what does a playthrough LOOK LIKE over time? Replay capture answers: at each frame N, where was the player, what was their reload state, what bullets were in flight, what enemies were alive, which shell was fired and at what target?

**The value:** the user's iter-270 "Stardew Valley delta" trigger named pacing/rhythm/economy concerns that STATIC probes can't address. A replay JSON of a bot-driven Q1 playthrough is the loop's nearest approach to providing TEMPORAL evidence without a real playtest.

**The honest limit:** a bot's playthrough is structurally calibrated, NOT feel-calibrated. Real human pacing is non-consultable. Replay data is one more rung up the structural ladder, not a substitute for human play.

---

## Round 27 — design

**Purpose:** ship a per-frame state recorder over the existing Q1 bot run + output JSON timeseries the user can scrub through (or feed to a future visualization tool).

**Scope:** ONE probe (Probe 5 in cumulative numbering — Probes 1-3 in Round 25, Probe 4 in Round 26).
**Substrate writes budget:** 0 (tooling + harness only).
**Cadence:** 240s active-build.
**Close criterion:** probe report ships at `loop/breach/probes/probe-005-q1-replay-capture.md` with per-frame JSON sample + interpretation.

---

## Probe 5 — Q1 replay capture

**Question:** what does a deterministic Q1 playthrough look like at frame resolution? Where does the bot spend its time, which lanes does it engage, when does it fire each shell class?

**Implementation:**
1. Extend `tools/q1_bot_run.gd` (or new `tools/q1_replay_capture.gd` driver) to record per-frame state during a single bot-policy run:
   - frame_number
   - player_position (x, y)
   - shell_class_selected
   - shell_fired_this_frame (bool)
   - enemies_alive (list of {id, position, hp})
   - terrain_remaining (count + positions)
   - run_recap.shells_spent_on_routes (incremental)
2. Pick ONE bot policy (likely `dominant_per_lane` since Probe 1 showed it produced the clearest routes-1/1/1/1 pattern).
3. Run for N frames OR until target list exhausted.
4. Write `tools/out/q1_replay_dominant_per_lane.json` — array of per-frame state dicts.

**Deliverable:**
- `tools/q1_replay_capture.gd` driver (NEW; reuses Q1ProofRoom + same bot policy from Probe 1 + adds per-frame recorder)
- `loop/breach/test_breach_q1_replay_capture.gd` 3-case smoke harness: (a) driver runs to completion, (b) JSON contains ≥10 frame entries, (c) frame N has expected schema keys.
- `loop/breach/probes/probe-005-q1-replay-capture.md` report — JSON schema + sample 3-frame excerpt + interpretation (where did the bot go, which shells fired when).

**Substrate writes:** 0.
**Test-breach:** +1 OK marker (87 → 92).

---

## Iter sequencing

| Iter | Mode | Focus |
|---|---|---|
| 317 | META | This blueprint (current iter) |
| 318 | CAPABILITY | Build tools/q1_replay_capture.gd + harness |
| 319 | BUILD | Ship probe-005 report + close Round 27 |

Total Round 27 budget: 3 iters max. After iter 319 close, loop is at next between-rounds inflection.

---

## What this round does NOT do

1. **Does NOT fire any consult.** Hard constraint per STATE.post_halt_direction (no 2nd adversarial consult before consult-001 scored).
2. **Does NOT add substrate writes.** Pure tooling + harness; substrate budget remains 26 writes from 120 cliff.
3. **Does NOT extend REVIEW-QUEUE with new direction asks.** Same posture as Rounds 25+26.
4. **Does NOT introduce visualization** — JSON output is the deliverable; future iter can build a visualization atop the data if user wants.

---

## Anchors potentially lifted

- **C6 (Death recap)** — replay data is the most-detailed possible recap evidence; could inform a future C6 anchor 5 lift if real playtest scores it. Round 27 itself doesn't lift; provides material.
- **C8 (HUD legibility)** — replay shows when HUD widgets are referenced during play (if instrumented). Round 27 doesn't add HUD instrumentation; deferred.

No `[FEEL-CONSULT]` lifts (hard constraint).

---

## Risks

- **Replay JSON could be too verbose** if all per-frame keys included. Mitigation: target ≤200 frames at the bot's 60fps + filter to "interesting frames" (fire events, kill events, band transitions) for the report excerpt; full JSON stays as supplementary file.
- **Synthesized playthrough is uninteresting** if the bot's policy is too rigid. Mitigation: report frames the data as "structural floor evidence of what a deterministic playthrough produces" — does NOT claim it represents real player behavior.
- **Same-family with Round 25 probes** — but separated by Round 26; productive same-family per iter-273 rule (each probe ships concrete numerical artifact).

---

## After Round 27 close

Iter 320+ candidates:
- Round 28 — gameplay axis (new enemy variant, depot upgrade, terrain affordance — REVIEW-QUEUE #27 candidate surfaces not yet served)
- Round 28 — instrumentation extension Phase B (HUD reference tracking during replay; band-transition counter; per-shell fire latency)
- Voluntary halt + PushNotification — if user still hasn't re-engaged after 14 iters of session.
- Stardew-pacing pivot — explicit user reversal would unblock this.

Default if user hasn't engaged by iter 320: PushNotification + voluntary halt under `stone-converged` halt-cause-label "if no surface fits → ASK USER." After ~14 iters of session without re-engagement, the loop has done what it can structurally; the next direction needs human input.
