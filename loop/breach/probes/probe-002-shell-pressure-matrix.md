# Probe 002 — Shell × target pressure matrix

**Iter shipped:** 308
**Round:** 25 (probe sprint)
**Driver:** `tools/shell_pressure_matrix.gd` (run via `make shell-pressure-matrix`)
**Harness:** `loop/breach/test_breach_shell_pressure_matrix.gd` (run via `make check-breach-shell-pressure-matrix`)
**Raw output:** `tools/out/shell_pressure_matrix.json`

---

## Question

For each (shell, target) pair, how many hits to destroy? How much damage per hit? Does the route ledger fire? This matrix gives the canonical per-cell mechanics that the "shells as route currency" identity rests on — and surfaces where the ledger DRIFTS from the mechanics.

---

## Method

For each of 4 shells × 4 targets = 16 cells, instantiate a fresh target with `is_route_gate=true` meta inside a MockLevel/MockPlayer harness (so `Bullet._try_record_shot_hit` reaches a record_shot_hit method). Fire bullets one at a time up to `MAX_HITS_PER_CELL=10` or until the target is destroyed. Capture hits_fired, damage_per_hit (where observable), outcome, and route/combat counters.

This is per-cell mechanic measurement in ISOLATION — Probe 1 measured per-policy outcomes in the populated Q1 scene; Probe 2 measures the underlying mechanics that drove Probe 1's policy differentials.

---

## The matrix

| | brick (hp=1) | steel (no take_damage) | light_enemy (hp=1, unarmored) | heavy_enemy (hp=3, armored) |
|---|---|---|---|---|
| **AP** | 1 hit destroyed (1 dmg, 1 route) | **bounces** (10 hits / steel intact / 0 routes) | 1 hit killed (1 dmg, 1 route) | **NEVER** (10 hits / 0 dmg/hit / **10 routes recorded**) |
| **HE** | 1 hit destroyed (1 dmg, 1 route) | **bounces** (10 hits / steel intact / 0 routes) | 1 hit killed (1 dmg, 1 route) | **NEVER** (10 hits / 0 dmg/hit / **10 routes recorded**) |
| **HEAT** | 1 hit destroyed (1 dmg, 1 route) | **bounces** (10 hits / steel intact / 0 routes) | 1 hit killed (1 dmg, 1 route) | **2 hits killed** (2 dmg/hit, 2 routes) |
| **APCR** | 1 hit destroyed (1 dmg, 1 route) | **1 hit drills** (steel destroyed, 1 route) | 1 hit killed (1 dmg, 1 route) | 3 hits killed (1 dmg/hit, 3 routes) |

---

## Findings

### F1 — AP and HE are IDENTICAL on every per-cell test (no radius effect in isolation)

The HE radius blast that gave dominant_per_lane its 5× brick-destruction efficiency in Probe 1 is a SCENE-LEVEL effect — it triggers `_apply_he_blast` which iterates over physics neighbors. In isolation (no adjacent bricks), HE behaves identically to AP: 1 hit kills hp=1 targets, 0 dmg per hit on armored, bounces off steel.

**Design implication:** HE's identity ("the lane opener") is positional, not statistical. A first-time player firing HE at a single isolated brick will see no difference from AP. The "I see why this shell is different" moment is gated on the player encountering a BRICK CLUSTER — a content-layout concern, not a damage-stat concern.

**Cross-shell distinctness (per-cell):**
- AP vs HE: indistinguishable in isolation
- AP/HE vs HEAT: distinct ONLY when target is armored (HEAT 2 dmg vs AP/HE 0 dmg on heavy)
- AP/HE/HEAT vs APCR: distinct ONLY when target is steel (APCR drills; others bounce)

Three of the four shells need SPECIFIC TARGET TYPES to express their identity. Only HEAT and APCR have non-isolated differentiation; AP and HE share per-cell mechanics entirely.

### F2 — Route ledger fires 10 times on AP × armored Heavy despite ZERO damage dealt (F3-from-Probe-1 systematized)

The most striking finding from Probe 1 (AP at armored Heavy records as route despite 0 damage) is now SYSTEMATIZED in the matrix. AP at heavy: 10 shells fired, 0 hp lost, **10 route hits recorded**. The route ledger conflates "shell consumed at gate-row body that has take_damage" with "shell DAMAGED the gate-row body." The size of the conflation is dramatic — at MAX_HITS_PER_CELL=10 (representing a stubborn player), the recap would tell them they spent 10 AP on route work and the Heavy still has full HP.

**Truth-vs-progress gap:** the player firing AP at a Heavy is making zero progress — but their reload bar refills, their reserve depletes, their impact spark renders, and now we know the ledger says "10 routes spent." The structural mismatch between in-fiction feedback and ledger truth is at MAXIMUM here.

**Backlog candidate (carried from Probe 1):** consider gating `_try_record_shot_hit` on `deal > 0`. Side-effect: would make "shell consumed but mitigated" invisible to the ledger, which has its own downsides (player might think they "got away with" a wasted shot). Both ledger semantics are defensible; the design needs the user's call.

### F3 — Steel-vs-AP-HE-HEAT silent-bounce: NO route hit (probe-1 F2 systematized)

Three of the four shells (AP, HE, HEAT) bounce off steel with ZERO ledger entries. The ledger silence here is HONEST: the steel didn't take damage, no route was breached. But the player gets the same impact-spark feedback they'd see on a successful damage hit. They learn the distinction only by repeated failure OR by reading the codex.

**Compared to F2:** the AP-on-Heavy case writes 10 routes for 0 progress; the AP-on-steel case writes 0 routes for 0 progress. The ledger is silent when the shell has no contact point (steel) but loud when the shell touches an armored body. This asymmetry in feedback is a real design surface — the recap can show "you wasted 3 shells trying AP on steel" only if the ledger TRACKS those wastes. It currently doesn't.

**If the ledger were extended:** a `shells_bounced` dict could capture per-class bounce counts (Bullet._on_body_entered would set this on the no-take_damage early return). Then the recap could synthesize "wasted shots" honestly. Filed as Round 25 follow-up candidate.

### F4 — HEAT is the universal Heavy-killer; APCR is the universal-anything-killer

- HEAT × Heavy: 2 hits (2 dmg/hit, AOE-armor-piercing) = 4 dmg dealt total. Fastest kill on armored.
- APCR × Heavy: 3 hits (1 dmg/hit, armor-piercing at 1×) = 3 dmg dealt total. Slower but universal.

HEAT pays for its anti-armor advantage by being CAPPED at small reserves (per UpgradeCatalog from prior rounds). APCR is even more capped. Together they form a tight specialization layer on top of the AP+HE generalist layer.

**Critical observation for round-design:** if a band has NO armored enemies AND NO steel terrain, HEAT and APCR have NEAR-ZERO marginal utility over AP+HE. The "shells as route currency" identity REQUIRES the band roster to include armor or steel pressure. A "brick-only + Light-only" band would collapse the four-shell economy to a one-shell-with-flavor pattern.

**This is a CONTENT constraint surfaced by the matrix.** Round 25 has not modified content; this is a finding the matrix reveals about the existing 5-band design. Likely a future round's REVIEW-QUEUE candidate.

### F5 — APCR is the only shell that works on every target in the matrix

APCR is the ONLY shell with a positive outcome on all 4 targets (1 hit brick, 1 hit drill steel, 1 hit kill Light, 3 hits kill Heavy). AP/HE both fail on steel AND on heavy. HEAT fails on steel.

**Balance implication:** APCR's "works on everything" property is the same property that makes HEAT's hard cap necessary. APCR breadth is the design's pressure-release valve when the player picks the wrong specialized shell. If APCR were ALSO cheap to refill, the four-shell economy collapses (always use APCR). The current design caps APCR reserves tightly — the matrix validates that's the right call.

### F6 — The 6-assertion harness locks the canonical mechanics

The harness (`test_breach_shell_pressure_matrix.gd`) encodes 6 fingerprint assertions that future iters MUST preserve:

1. AP × brick: 1 hit destroys + 1 route (control)
2. AP × steel: bounces 5 hits / 0 routes (cross-pollination preserved)
3. AP × heavy: 0 damage per hit + 3 routes recorded (F2 conflation LOCKED)
4. HEAT × heavy: 2 hits kill (HEAT 2x + armor-piercing)
5. APCR × steel: 1 hit drills (canonical APCR verb)
6. HE × brick (isolated) == AP × brick (HE radius is scene-level)

Any future change to Bullet armor mitigation, HEAT 2× damage multiplier, APCR drill semantics, or HE per-cell behavior will fail one of these assertions BEFORE the change ships.

---

## What this probe CAN'T tell us (non-consultable)

- Whether HE's brick-cluster radius "feels" like the lane-opener the design names it as (tactile/audio/visual feedback in motion)
- Whether the AP-on-Heavy ledger conflation FRUSTRATES a real player when they read the recap, or whether they ignore the route count
- Whether the "AP+HE are identical per-cell" finding will surface as design boredom or as design-irrelevant (depends on whether players ever fire HE at single bricks)
- Whether APCR's universal viability creates a "default to APCR" attractor in actual play

These remain in consult-001's `What CANNOT be known` section. Probe 2 produces matrix-floor evidence; it does not score consult-001 predictions.

---

## Substrate impact

- Files added: `tools/shell_pressure_matrix.gd`, `loop/breach/test_breach_shell_pressure_matrix.gd`, `loop/breach/probes/probe-002-shell-pressure-matrix.md`
- Files modified: `Makefile` (3 new targets: `check-breach-shell-pressure-matrix`, `shell-pressure-matrix`; harness added to test-breach aggregate)
- Layer 1/2/3 substrate writes: **0**
- substrate_writes_this_arc unchanged at 92.
- Hash anchor `23d6a2ec3bf2821f` preserved.
- test-breach: 87 → 88 OK markers (+1 for shell-pressure-matrix harness).
- test-all: 5/5 unchanged.

---

## Findings carried to follow-up

| Finding | Surface | Backlog candidate |
|---|---|---|
| Ledger conflation (F2) | `Bullet._try_record_shot_hit` | Gate on `deal > 0` (design call required) |
| Silent bounce on steel (F3) | `Bullet._on_body_entered` early return | Track `shells_bounced` for recap (design call required) |
| HE per-cell == AP (F1) | Bullet.gd HE branch | Probe-3 candidate: measure HE radius blast efficacy at varying cluster densities |
| Bands need armor/steel for shell economy (F4) | Content layer (BANDS.md) | Future-round candidate: audit each band's shell-pressure mix |
| APCR breadth + balance (F5) | UpgradeCatalog reserve caps | Already controlled; reaffirmed |

None of these need Round 25 action — they're filed for the user or future-round consideration.

---

## Probe 1 + Probe 2 together: cumulative Round 25 picture

- Probe 1: at the SCENE level, dominant_per_lane is the only policy with routes 1/1/1/1; HE radius is what amplifies dominant's brick-destruction to 5×.
- Probe 2: at the PER-CELL level, AP=HE in isolation; only HEAT and APCR have unique per-cell verbs (anti-armor vs anti-steel). The ledger conflates 10 wasted AP shots on Heavy as 10 routes recorded.
- Together: the proof room's "shells as route currency" identity is structurally enacted, BUT the ledger has truth-vs-progress drift on armored targets, AND three of four shells overlap on unarmored hp=1 targets.

The user's iter-270 "Stardew delta" trigger remains gated on FEEL playtest evidence. Probes 1+2 give STRUCTURAL FLOOR data; the cognitive-level "does this feel like a roguelite economy?" is still real-playtest only.

---

## Round 25 next-iter posture

Iter 309 candidates:
- (a) Probe 3 — UI readability pass (HUD coverage math + label-size audit) per blueprint. Round 25 caps at 3 probes — would close the round at iter 309/310.
- (b) Round 25 close — F1-F6 in Probe 1 + F1-F6 in Probe 2 may already saturate the calibration value. Bootstrap next surface from PROMPT § work-valid-without-playtest list.
- (c) META iter consolidating findings into REVIEW-QUEUE *if* a queue closure can also fire (per WATCH-FOR anti-accretion signal).

iter 309 diagnoses based on STATE + LEDGER tail.
