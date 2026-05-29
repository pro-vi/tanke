# Probe 005 — Q1 replay capture (event-indexed timeseries)

**Iters shipped:** 317 (blueprint), 318 (driver + harness + this report)
**Round:** 27 (single-probe replay capture sprint)
**Driver:** `tools/q1_replay_capture.gd` (run via `make q1-replay-capture`)
**Harness:** `loop/breach/test_breach_q1_replay_capture.gd` (run via `make check-breach-q1-replay-capture`)
**Raw output:** `tools/out/q1_replay_dominant_per_lane.json`

---

## Question

Probes 1-4 produced STATIC evidence — aggregate stats, per-cell matrices, coverage math, pipeline plumbing. None captured TEMPORAL dynamics: which shot fired when, what state changed in response, in what order did events propagate? Probe 5 produces an event-indexed timeseries of a deterministic Q1 playthrough.

---

## Method

Synthetic-fire approach (mirrors iter-307 q1_bot_run.gd + iter-289 test_breach_q1_proof_playthrough.gd precedent). For each gate target in `dominant_per_lane` policy order (HE-brick / APCR-steel / HEAT-Heavy / AP-Light), record:
- **PRE-state**: target_hp, terrain_alive count, enemies_alive count, routes snapshot.
- Fire.
- **POST-state**: same fields + target_destroyed bool.

Plus an initial-state snapshot at frame 0 and a final-summary snapshot at the end.

**Honest framing note:** the synthetic-fire approach bypasses real-time physics. The "timeseries" is event-indexed, NOT frame-indexed. Frame-indexed would require driving PlayerTank._input_dir + GunTimer awaits + 60Hz tick loop — substantially more complex. Event-indexed produces the structurally-meaningful data (what each shot DID, in order) without the runtime physics overhead. The driver's `capture_mode` field in the output JSON is set to `event_indexed_synthetic_fire` to make this explicit.

---

## Results — 10-event sequence

| Event | Phase | Lane | Shell | Target hp pre→post | Terrain | Enemies | Routes (AP/HE/HEAT/APCR) |
|---|---|---|---|---|---|---|---|
| -1 | initial | — | — | — | 10 | 6 | 0/0/0/0 |
| 0 | pre | HE | HE | 1 → ? | 10 | 6 | 0/0/0/0 |
| 0 | post | HE | HE | destroyed | **5** | 6 | 0/**1**/0/0 |
| 1 | pre | APCR | APCR | — | 5 | 6 | 0/1/0/0 |
| 1 | post | APCR | APCR | destroyed | **4** | 6 | 0/1/0/**1** |
| 2 | pre | HEAT | HEAT | 3 → ? | 4 | 6 | 0/1/0/1 |
| 2 | post | HEAT | HEAT | alive, hp=1 | 4 | 6 | 0/1/**1**/1 |
| 3 | pre | AP | AP | 1 → ? | 4 | 6 | 0/1/1/1 |
| 3 | post | AP | AP | destroyed | 4 | **5** | **1**/1/1/1 |
| 4 | final | — | — | — | 4 | 5 | 1/1/1/1 |

---

## Findings

### F1 — HE radius blast destroys **5 bricks in a single event** (Probe 2 F4 in temporal form)

Event 0 transitions terrain count 10 → 5 across a single HE shot. The HE-lane has 5 bricks at the gate row (cols 0-4). One HE shot detonates with radius blast → all 5 bricks queued for deletion in the same physics frame.

**This is Probe 2 F4 dramatized.** Probe 2's per-cell matrix showed HE = AP on isolated bricks. The "radius is a SCENE-LEVEL effect" finding becomes visible HERE in the timeseries: a single HE event drops terrain by 5, while APCR (event 1) drops it by 1 and AP (event 3) drops it by 0 (target was an enemy, not terrain).

**Cost/effect asymmetry visible in time:**
- HE: 1 shell → 5 bricks
- APCR: 1 shell → 1 steel
- HEAT: 1 shell → ½ Heavy (2 dmg of 3 hp; not destroyed)
- AP: 1 shell → 1 Light kill

The HE radius blast is the highest-leverage event in the playthrough. **For "shells as route currency" identity, HE is structurally the cheapest lane-opener IF the bricks cluster** — which they do at the HE gate by design.

### F2 — Routes ledger fills 0/0/0/0 → 1/1/1/1 across 4 events (Probe 1 F1 in temporal form)

The dominant_per_lane policy's routes-symmetry pattern (Probe 1 F1) is visible in the event-by-event ledger growth: each shot increments exactly one shell-class's route counter. Final state 1/1/1/1 matches Probe 1's aggregate output.

**Temporal advantage:** if a future shot mis-routed (e.g., HE on steel), the ledger growth would be observably uneven — you'd see "1/1/0/1" or similar after the wasted shot. Probe 1's aggregate would just say "3 routes recorded for 4 shots fired" without indicating WHICH shot was wasted.

### F3 — HEAT × Heavy spans 2 events without resolution (the per-cell finding made temporal)

Event 2 ships the HEAT shot at the gate-row Heavy. Pre-state: target_hp=3. Post-state: target_destroyed=false, target_hp=1. The Heavy is now at 1 HP — a second HEAT shot would kill, an AP shot might bounce off armor at 0 dmg.

**The temporal data SHOWS the unresolved state.** A player reading the timeseries can see exactly when the Heavy becomes "almost dead" but not yet — a tactical decision point that aggregate stats hide.

### F4 — Enemy count drops by 1 only at event 3 (AP × Light)

Initial enemies = 6. Final enemies = 5. The single enemy killed across all 4 events is the AP-lane Light at gate row 16. The Heavy survived (HP 3 → 1, queued for a future shot). 4 clearance-row Lights (rows 3, 4, 5) never engaged (they're enemies the bot policy doesn't shoot at; the policy only targets gate-row obstacles).

**Implication:** dominant_per_lane is a GATE-CLEARING bot, not a combat-clearing bot. Aggregate stats hide that distinction; timeseries makes it explicit.

### F5 — Final state shows 4 unfinished obstacles

Final terrain alive = 4 (APCR-lane: cols 6, 8, 9 — 3 steels; HEAT-lane: col 10 brick if present — let me recount: APCR cols 5-9 = 5 steels initially; APCR breached col 7 = 1 destroyed; remaining = 4. Yes, 4 steel remain at APCR lane). Final enemies alive = 5 (Heavy at HP 1 + 4 clearance Lights).

**dominant_per_lane closes the route currency loop (1/1/1/1) but does NOT finish the room.** A full playthrough would need to (a) continue APCR shots to drill more steel, (b) finish the Heavy with a 2nd HEAT (or AP at 0 dmg → 10 routes recorded for nothing per Probe 2 F2), (c) ignore or engage clearance Lights as needed.

**Temporal narrative:** the proof room is designed for SAMPLE the route-currency mechanic, not exhaustive completion. The bot's 4 shots demonstrate the principle; a real player would need ~10-15 shots to exit. This matches what Probe 1 already showed in aggregate; Probe 5 makes it temporally explicit.

---

## What this probe CAN'T tell us (non-consultable)

- Whether a real player would attend to the timeseries (do they think in event-by-event terms, or in screen-state-at-the-moment terms?)
- Whether the HE radius blast FEELS as dramatic as the data suggests (5 bricks in 1 shot = potentially satisfying OR potentially "what just happened?")
- Whether the HEAT-Heavy unresolved state at HP=1 creates tactical tension or feels like an unfinished interruption
- Whether dominant_per_lane is even close to how a real player would play (probably not — humans don't pre-commit to shell-per-lane mapping)
- Whether the bot's per-event pacing (1 shot per event, no movement between) matches any real human's flow

These remain real-playtest-gated. Probe 5 is the structural floor of TEMPORAL evidence the loop can produce; FEEL is non-consultable.

---

## Substrate impact

- Files added: `tools/q1_replay_capture.gd` (NEW driver), `loop/breach/test_breach_q1_replay_capture.gd` (NEW harness), `loop/breach/probes/probe-005-q1-replay-capture.md` (THIS report)
- Files modified: `Makefile` (added `check-breach-q1-replay-capture` + `q1-replay-capture` standalone targets; harness added to test-breach aggregate at 92 OK markers)
- Layer 1/2/3 substrate writes: **0**
- substrate_writes_this_arc unchanged at 94 (Round 27 budget 0 of 0 used; pure tooling round per blueprint)
- Hash anchor `23d6a2ec3bf2821f` preserved.
- test-breach: 91 → 92 OK markers (+1 for q1-replay-capture).
- test-all: 5/5 unchanged.

---

## Round 27 close + saturation watch

Round 27 (single-probe) ships at iter 318 in 2 iters total (blueprint + ship). Iter 319 would be the formal META close. Per blueprint:

> Saturation watch: if user hasn't re-engaged by iter 320 (Round 27 close + 1), default to PushNotification + voluntary halt under stone-converged ASK USER path.

This iter 318 closes the substantive work of Round 27. Iter 319 should be the META close + decision point: continue indefinitely OR escalate via PushNotification.

**Honest assessment at iter 318:** the loop has produced 5 probe reports + 1 visual identity pipeline across iters 306-318 of this resume session (13 iters, ~65 min). All substantive structural work has been done on standing direction; the user has not provided fresh direction in 13 iters. Per PROMPT § halt-cause classifier, `stone-converged → ASK USER via PushNotification` is the correct response to "no surface fits" — but surfaces still exist (Round 28 gameplay axis, Round 28 visual Phase C, Round 28 more probes). The choice between "loop self-selects" and "ask user" comes down to whether 13 iters of standing-direction-only work constitutes the iter-282 /meta "managing absence of evidence" failure mode.

**My recommendation at iter 319:** PushNotification + voluntary halt. Surface 5 probe reports + Round 26 visual identity + 13-iter session summary. User can re-engage if they want; loop pauses to honor the "no idle, but no cargo-cult either" rule.

If user re-engages with fresh direction before iter 319 fires, the loop honors that.
