# Probe 001 — Q1 headless bot run baseline

**Iter shipped:** 307
**Round:** 25 (probe sprint)
**Driver:** `tools/q1_bot_run.gd` (run via `make q1-bot-run`)
**Harness:** `loop/breach/test_breach_q1_bot_run.gd` (run via `make check-breach-q1-bot-run`)
**Raw output:** `tools/out/q1_bot_run_{always_ap,round_robin,dominant_per_lane,all}.json`

---

## Question

When a stub bot drives the Q1 proof room under 3 fixed shell-selection policies, does the data plumbing produce DIFFERENTIATED outcomes per policy? If yes, the proof room structurally enacts the "shells as route currency" identity claim from consult-001 Q1 (0.90). If no, the design is flat and the consult's recommendation didn't materialize.

---

## Method

Each policy fires at the same 4 gate targets (row 14):

| Lane | Col | Target |
|---|---|---|
| HE | 2 | brick (gate-row, `is_route_gate=true`) |
| APCR | 7 | steel (gate-row, `is_route_gate=true`) |
| HEAT | 12 | Heavy enemy (gate-row, hp=3, armored, `is_route_gate=true`) |
| AP | 16 | Light enemy (gate-row, hp=1, `is_route_gate=true`) |

Policies:
1. **always_ap** — every shot is AP
2. **round_robin** — AP → HE → HEAT → APCR by shot index
3. **dominant_per_lane** — HE for HE-lane brick, APCR for APCR-lane steel, HEAT for HEAT-lane Heavy, AP for AP-lane Light

Synthetic-fire approach (mirrors `test_breach_q1_proof_playthrough.gd`): instantiate `Bullet`, set `shell_class`, call `_on_body_entered(target)` directly. The iter-296 e2e fire harness already validates the full `PlayerTank._fire → emit shoot → bullet.start → physics → record_shot_hit` path; this probe focuses on calibration data shape, not wiring re-verification.

---

## Results

| Policy | Shells fired (AP/HE/HEAT/APCR) | Routes recorded | Gate-row blocks destroyed | Enemies killed | Total damage |
|---|---|---|---|---|---|
| always_ap | 4 / 0 / 0 / 0 | **3 / 0 / 0 / 0** (3 total) | **1 / 10** | 1 | 1 |
| round_robin | 1 / 1 / 1 / 1 | **1 / 0 / 1 / 1** (3 total) | **1 / 10** | 1 | 3 |
| dominant_per_lane | 1 / 1 / 1 / 1 | **1 / 1 / 1 / 1** (4 total) | **6 / 10** | 1 | 3 |

(Route counts are per-class shells_spent_on_routes, in AP/HE/HEAT/APCR order.)

---

## Findings

### F1 — Dominant_per_lane produces the only symmetric routes pattern

Only `dominant_per_lane` records routes 1/1/1/1 across the 4 shell classes. The other two policies record 3-and-zeros (always_ap) or 1-0-1-1 (round_robin). This means: the proof room's gate row STRUCTURALLY enacts the "shells as route currency" identity ONLY when the player picks the canonical answer per lane. Any other policy leaves at least one lane's currency slot empty.

**Calibration weight:** consult-001 Q1 (0.90) said "UI can reveal identity, cannot manufacture it. Shells become route currency only when specific gates are shell-gated." This probe gives structural floor evidence — Q1 lanes ARE shell-gated; the routes ledger differentiates by ~3-4x in symmetry between dumb and tank-savvy policies.

### F2 — HE-on-steel records no route hit (silent waste)

`round_robin` fired HE at the APCR-lane steel and recorded `shells_spent_on_routes[HE] = 0`. Reason: SteelBlock has no `take_damage` method → Bullet's `_try_record_shot_hit` only fires inside the `body.has_method("take_damage")` branch → HE-on-steel just bounces silently. The HE shell is consumed, the player can see the impact spark, but no route currency is logged.

**Design implication:** the route-currency ledger is a TRUTHFUL accounting — "you spent an HE shell on steel" is implicitly counted as zero progress, because the shell did zero damage. A future card or recap line could surface this ("you wasted N shells on wrong-shell-vs-terrain") to teach the routing economy.

**Risk surfaced:** the player who fires HE at steel sees no feedback distinguishing this from a successful breach. The reload bar refills, the chip count drops, the impact spark renders — but the gate STAYS. A first-time player may not connect "no progress" to "wrong shell." This is exactly the consult Q3 (0.92) "passes screen-reading test, fails play test" failure mode at the per-shot resolution.

### F3 — AP cannot breach steel, AND it's mitigated to 0 damage on armored Heavies — yet it still RECORDS a route hit on the Heavy

`always_ap` records 3 routes (brick + Heavy + Light) and 0 combat. The 3rd route — AP at Heavy — is structurally suspicious: AP's damage is mitigated to 0 by ARMOR_MITIGATION on armored bodies, so `body.take_damage(0)` fires and `_try_record_shot_hit` records, but the Heavy's HP doesn't change. The route ledger shows "1 AP spent on route" but the Heavy is unscathed.

**Design implication:** the route ledger conflates "shell consumed at gate-row body" with "shell DAMAGED the gate-row body." A more honest ledger would gate the record on `deal > 0`. Without this, always_ap looks 3-routes-effective when it's actually 2-routes-effective (brick + Light, both took real damage).

**Backlog candidate:** consider adding `deal > 0` guard to `_try_record_shot_hit` — but defer the design call. The current ledger is a "shells thrown at routes" count, not a "successful breach" count. Both are legitimate metrics. Round 25 Probe 2 (shell × terrain matrix) will surface the same conflation more sharply.

### F4 — HE radius blast amplifies HE-lane breach 5×

`dominant_per_lane` destroys 6 gate-row blocks total while firing only 1 HE shot at the brick wall. Reason: HE's radius blast at impact propagates to adjacent bricks (5 in the HE lane: cols 0-4). The other 3 shots each destroy at most 1 block (APCR drills 1 steel, HEAT enemy damage, AP enemy kill).

**Calibration weight:** HE's "open the lane" verb is the load-bearing distinct verb. APCR drills 1 block per shot; HE blasts 5 in optimal lane. This is roughly the cost/effect asymmetry the consult-001 verdict predicted ("HE opens loot lane but costs AoE safety").

### F5 — Round 25 Probe 1's contract is met: bot finishes cleanly + non-empty hit log per policy + data shape differentiates

All 3 policies show `bot_finished_cleanly: true`. All 3 produce non-empty `shells_spent_on_routes`. The aggregate file (`tools/out/q1_bot_run_all.json`) contains 3 records ready for tabular consumption by future probes or consult media.

---

## What the probe CAN'T tell us (non-consultable, real-playtest gated)

- Whether a real player FEELS the asymmetry across the 4 lanes mid-combat
- Whether the recap currency summary makes the routing economy "click" post-run
- Whether picking lanes by visible obstacle (brick vs steel vs Heavy vs Light) reads instantly to a fresh player or requires legend training
- Whether HE's radius blast is satisfying or anti-climactic in motion (tactile feel, screen shake, audio response — none captured here)
- Whether the wrong-shell-no-feedback case (F2) creates frustration, curiosity, or pure confusion in real play

These remain in consult-001's `What CANNOT be known` section and the 3 falsifiable predictions awaiting user scoring. Probe 1 produces ADJACENT structural floor evidence; it does not score the predictions.

---

## Substrate impact

- Files added: `tools/q1_bot_run.gd`, `loop/breach/test_breach_q1_bot_run.gd`, `loop/breach/probes/probe-001-q1-bot-baseline.md`, `tools/out/q1_bot_run_*.json` (4 files)
- Files modified: `Makefile` (added `check-breach-q1-bot-run` + `q1-bot-run` targets; added new harness to `test-breach` aggregate)
- Layer 1/2/3 substrate writes: **0**
- substrate_writes_this_arc unchanged at 92.
- Hash anchor `23d6a2ec3bf2821f` preserved (no substrate touch).
- test-breach: 86 → 87 OK markers (+1 for q1-bot-run harness).
- test-all: 5/5 unchanged.

---

## What this probe DOES NOT do

1. Score consult-001's 3 falsifiable predictions (those are player-behavior claims; only real playtest scores them).
2. Lift any RUBRIC anchor via `[FEEL-CONSULT]` — Probe 1 provides STRUCTURAL evidence. The hard constraint per STATE.post_halt_direction explicitly bans more `[FEEL-CONSULT]` lifts until consult-001 scores.
3. Validate the iter-296 fire path (already covered by `test_breach_q1_proof_fire_e2e`).
4. Run real-time game simulation under physics (synthetic-fire approach; the existing fire-e2e harness covers wiring).

---

## Next probe candidates

- **Probe 2** — Shell × obstacle deterministic combat matrix (4 shells × ~6 terrain/enemy types → hit-count to clear). Surfaces hidden dominance and validates F2/F3 findings at finer resolution.
- **Probe 3** — UI readability pass: HUD coverage math + label-size audit. Validates iter-300 WoT-tray layout stays ≤ 25% viewport.

Per blueprint sequencing, Probe 2 targeted at iter 310 (CAPABILITY) / iter 311 (BUILD).
