# Round 24 architect (REFRAMED) — Q1 breach-economy proof room

**Opened:** iter 283 (2026-05-25)
**Trigger:** User chose Option B at AskUserQuestion in iter 283, picking consult-001 Q1 (verdict confidence 0.90) over the original blueprint's Phase B (scaling-curve audit) and Phase C (enemy-HP recurve).
**Supersedes:** Phase B + Phase C of iter-270-round24-architect.md (parked, may be revisited after the proof room ships).

---

## Why this exists

Consult-001 (Pro extended-thinking 5m29s, iter 279-280) verdict on Q1:
> Phase A alone is not distinct enough. It makes distinction legible; it does not create it. UI can reveal identity, but cannot manufacture it. Shell colors, reserves, and reload bars help the player see a possible economy, but the economy only becomes distinct if finite shells, terrain destruction, lane opening, and route pressure force tradeoffs. If AP/HE/HEAT/APCR are mostly "damage flavors," then Phase A sharpens the resemblance to classic tank combat instead of escaping it.
>
> Concrete next step: Add one pre-Phase-B breach-economy proof room: a tile/route/cache/enemy formation that is materially changed by spending a scarce shell. Example: HE opens a loot lane but costs future AoE safety; HEAT punches a bunker shortcut but leaves you low for armored enemies; APCR saves time but depletes escape ammo. The player must feel "shells are route currency," not just ammo.

The /meta verdict at iter 282 reinforced: the structural finding is that shells must be **route currency**, not just damage flavor. Phase A made shells/reload/cards LEGIBLE; this round makes shells STRUCTURALLY CONSEQUENTIAL.

---

## North star

**Shells open routes, not just damage.** Every shell class has a UNIQUE route the player can take that no other shell can open. The player's choice of which shells to STOCKPILE and which to SPEND becomes a choice of which routes their run favors.

This restores the arc-4 identity anchor (CONSULT §6 verbatim): *"Breach economy. What are you willing to spend to open the next vertical lane?"*

Sentence test (preserved from arc-4 CONSULT, every design element passes):
> "This shell helps me climb through ___ by changing how I use ___."

---

## Design — the proof room (1 band, fully gated)

A single BreachBand `q1_proof` instantiated as a self-contained playable room. ~30 tile rows × 21 cols (one BC band footprint). 4 distinct routes, each gated by a different shell class:

### Route layout

```
                         GOAL (top of band)
                            ▲
        ╔════════╤════════════════╤═══════════════╤════════╗
        ║        │                │               │        ║
        ║  HE    │   APCR          │   HEAT       │  AP    ║
        ║  lane  │   lane          │   lane       │  lane  ║
        ║        │                │               │        ║
        ║  ████  │  ████████████  │  [Heavy(3)]  │ patrol ║  ← gate row
        ║  brick │  steel barrier │  bunker      │ open   ║
        ║  cluster│  (3 cells)    │  armored     │ but    ║
        ║        │                │  guarding    │ heavy  ║
        ║        │                │  shortcut    │ patrol ║
        ║        │                │              │ (3-4   ║
        ║        │                │              │ Lights)║
        ║        │                │              │        ║
        ║        │                │              │        ║
        ║        START (bottom of band)         │        ║
        ╚════════╧════════════════╧═══════════════╧════════╝
```

### Per-route gate semantics

| Lane | Gate | Cost to open | Without that shell | Time-to-clear |
|---|---|---|---|---|
| HE lane | brick cluster (4-cell rosette) | 1 HE shell (HE blast clears 4+ bricks in radius) | Cannot pass without ~10-20s of AP shots OR rerouting | ~3s with HE / ~25s with AP |
| APCR lane | steel barrier (3 cells) | 1-3 APCR shells (drills through, 1 cell per hit) | **Impossible without APCR** — AP/HE/HEAT bounce off steel | ~6s with APCR / never with others |
| HEAT lane | 1 entrenched Heavy (hp=3, armored) blocking the shortcut | 2 HEAT shells (2× damage to armored = 1 shot per HEAT) | Needs 6 AP or 3 HE to chip through; high exposure | ~4s with 2 HEAT / ~15s with 6 AP under fire |
| AP lane | 3-4 Light patrol (no armor, hp=1) + open lane | Pure AP rotation / movement | Slower; the AP lane is the "free" baseline | ~12s with AP |

Critical design property: **each lane has a DOMINANT shell class.** A pure AP build can complete only the AP lane (and chip the HE lane slowly). A pure HEAT/APCR/HE build cannot pass without spending the right shell at the right gate. This forces the player to ASK at run-start: "Which routes does my build open?"

### Goal at top

A single visible REWARD at the goal (a depot cache containing 2-3 cards + a shell refill). This makes the run feel COMPLETE — the player chose a route, paid the cost, and got the reward.

---

## Deliverables (per-iter) — REVISED iter 287 (sprint extends 4 → 6-7 iters)

**Original 4-iter plan was over-optimistic.** Iter 284 shipped the design artifact + design-verification harness but punted "spawn the gate elements" forward. Iters 285-286 took storage + wiring (per plan). At iter 287 mid-correction, the playable scene integration still needs ≥2 iters of work. Revised plan below; total 6-7 iters, well within user's iter-283 estimate of 8-15.

| Iter | Phase | Shipped |
|---|---|---|
| 284 | BUILD | BreachBand resource + ASCII narrative layout + design-verification harness |
| 285 | BUILD | RunRecap route-currency dicts + record_shot_hit API |
| 286 | BUILD | Bullet→PlayerTank→RunRecap wiring (is_route_gate meta routing) |
| 287 | BUILD | Q1ProofRoom parser module (TILE_GRID + lane helpers; foundation for scene) |
| 288 | BUILD | scenes/Q1ProofRoom.tscn + spawn logic (terrain + enemies + player + goal) |
| 289 | BUILD | per-lane playthrough harness (sim drives a virtual player through each lane) |
| 290 | REVIEW | playtest brief + REVIEW-QUEUE close |

Original per-iter sections preserved below for traceability:

### iter 284 — BUILD — proof room as a new BreachBand

- Create `configs/bands/q1_proof.tres` (BreachBand resource)
- Define the 4-lane layout via existing LevelDNA / BiomeConfig terrain weights
- New ProceduralStep mode "Q1_PROOF" OR hand-laid `q1_proof_layout.txt` tile array consumed by a small loader
- Spawn the gate elements: brick cluster (HE lane), steel barrier (APCR lane), entrenched Heavy (HEAT lane), Light patrol (AP lane)
- Sim harness asserts: each lane has its gate; each gate is solvable ONLY with its sanctioned shell; the goal at the top is reachable from all 4 lanes
- Hash anchor preserved (proof room is a NEW BreachBand resource, not a substrate write; arc-2/3 procedural mode unaffected)

### iter 285 — BUILD — RunRecap extension: route-currency metrics

Per consult Q3 (0.92): "Build one diagnostic room + recap metric: kills by shell, terrain opened by shell, shells spent opening lanes, cards affecting the run."

- Extend `RunRecap.gd` (arc-4-owned, not substrate) with fields:
  - `shells_spent_on_routes: Dictionary` — by shell class, count of shells spent destroying ROUTE-GATE terrain
  - `shells_spent_on_combat: Dictionary` — by shell class, count of shells spent on enemies
  - `route_taken: String` — which of the 4 lanes the player completed first
  - `time_per_lane: Dictionary` — actual playthrough time per lane
- Modify Bullet.gd to TAG body hits with `was_route_gate: bool` so RunRecap can distinguish route from combat
- Modify Enemy.gd `take_damage` setter chain to mark the entrenched-Heavy hits as route (placement-tag-driven)
- Harness asserts: shooting brick cluster with HE marks shells_spent_on_routes[HE] += 1; shooting Light with AP marks shells_spent_on_combat[AP] += 1

### iter 286 — BUILD — proof-room sim harness

- Headless playthrough script that drives a virtual player through each of the 4 lanes
- For each lane: spawn proof room, instantiate player with the lane's required shell reserve, execute scripted movement + fire, assert goal reached + time-to-goal within target window
- Verifies the design property: each lane is solvable ONLY with its dominant shell + the gate is impassable without
- Test target: `check-breach-q1-proof-room`

### iter 287 — REVIEW — playtest brief + REVIEW-QUEUE entry

- Write `loop/breach/Q1-PROOF-ROOM-PLAYTEST-BRIEF.md` — 1-page playtest spec for the user
- The brief tests the predictions from consult-001:
  - Prediction 1 (shell legibility passes / build legibility fails): does the user feel shells as ROUTE-CURRENCY after one playthrough?
  - Prediction 2 (reload bar): does the player consult reload during combat under pressure?
  - Prediction 3 (3-strip stacking): does the player notice the active-cards ribbon during the room?
- REVIEW-QUEUE entry summarizing the proof room as shipped, awaiting playtest scoring
- Updates CONSULT-LEDGER consult-001 § Affected anchors with the prediction-scoring trigger

### iter 288 (optional) — META — proof room close OR pivot

- If acceptance harness passes AND consult predictions hold structurally → close Q1; revisit blueprint Phase B/C OR open Round 25 visual identity
- If something doesn't fit → pivot

---

## Acceptance criteria

1. **Each lane has its gate.** Sim harness verifies the proof room layout: 4 lanes, each with the right gate type at row K.
2. **Each gate is shell-gated.** Sim harness verifies: HE lane requires HE; APCR lane requires APCR; HEAT lane requires HEAT; AP lane is open but defended.
3. **Route-currency metrics work.** RunRecap fills `shells_spent_on_routes` and `shells_spent_on_combat` distinctly; harness verifies both update under scripted play.
4. **Goal is reachable from all 4 lanes.** Reachability oracle (existing) confirms playable: true for each lane variant.
5. **Hash anchor preserved.** `23d6a2ec3bf2821f` bit-identical on procedural baseline (the proof room is a NEW BreachBand, not a substrate write to ProceduralLevel).
6. **make test-all + make test-breach green.**
7. **REVIEW-QUEUE entry + playtest brief shipped.** User can do one playthrough and answer "did shells feel like route currency?"

---

## Anti-patterns to avoid

- **Stat-boost gates.** A gate that says "this shell does +1 damage to this enemy" is the wrong frame (CONSULT §7 violation). Each gate must be a ROUTE-OPENING affordance, not a damage modifier.
- **Multiple-shell-solves-everything.** If any lane is solvable by 2+ shell classes equally well, the route-currency claim collapses. Each lane MUST have ONE dominant shell.
- **Phase A regression.** The proof room must work WITHOUT touching the existing 5 Phase A HUD widgets. Loadout-gated additions only; hash anchor mandatory.
- **Scope creep into Phase B.** The proof room does NOT introduce tier-breakthroughs (that was original blueprint Phase B). Pure route-currency demonstration.
- **Fake difficulty.** AP lane must be COMPLETABLE (with effort). The point is to make the player FEEL their build choice changes WHICH route they take, not to gate the goal behind a specific shell.

---

## Why this addresses the consult findings

| Finding | Confidence | How proof room addresses it |
|---|---|---|
| Q1: UI reveals identity but cannot manufacture it | 0.90 | Proof room MANUFACTURES the identity via route-currency mechanic; HUD reveals it. |
| Q3: phase can pass screen-reading test while failing play test | 0.92 | The acceptance gate IS a play test (per-lane completion); proof room cannot fake-pass. |
| Stardew delta = pacing/rhythm/economy | 0.87 | Proof room introduces a per-room economic CHOICE (which lane to spend on), the rhythm primitive Stardew's day/energy provides. Not the full pacing answer, but the first piece. |
| H3: 5-BUILD streak strategically suspect | 0.89 | This round breaks the HUD-fix streak with mechanical work. |

---

## Sentence test per shell at the proof room

- **HE**: "This shell helps me climb through brick-cluster lanes by changing how I use my AoE budget." ✓
- **APCR**: "This shell helps me climb through steel-barrier lanes by changing how I use my drill budget." ✓
- **HEAT**: "This shell helps me climb through armored-bunker shortcuts by changing how I use my 2× anti-armor burst." ✓
- **AP**: "This shell helps me climb through patrol-defended open lanes by changing how I use my time + movement budget." ✓ (the baseline shell still passes because the lane is solvable, just slower)

All four pass — they are AFFORDANCE-changing, not stat-changing.

---

## Out of scope (for this round)

- Tier-breakthrough card conversion (original blueprint Phase B) — parked
- Enemy-HP recurve (original blueprint Phase C) — parked
- /agentify icon swap for HUD widgets (Round 25 candidate) — parked
- H6 visibility classes / reload bar dup / pickup-toast from consult-001 backlog — applied OPPORTUNISTICALLY if they help the proof room, otherwise stay queued
- The Stardew delta as a FULL pacing/rhythm reframe (Option C) — user explicitly chose Option B, the smaller proof-room scope; Option C may still happen as a future round
