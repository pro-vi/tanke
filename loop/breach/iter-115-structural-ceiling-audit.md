# Iter 115 — DIAGNOSE — Structural-ceiling audit + Round 14 bootstrap

Per round-13-summary §Round-14-bootstrap, this iter audits C2 +
C7 with C11 as fallback. Finding: **8 axes are at structural
ceiling** (anchor 3 fully met; anchors 4-5 [FEEL] playtest-only
with no structural surrogate). Forward movement requires either
cognitive-max claims (a few axes), playtest cites, or NEW
mechanical scope.

---

## Part 1 — Per-axis structural ceiling check

| Axis | Anchor 3 evidence | Anchors 4-5 | Structural ceiling? |
|------|-------------------|-------------|---------------------|
| **C2 Field depot** = 3 | `test_breach_level`: ≥4 depots placed deterministically | 4 = depot dwell <30s playtest; 5 = "if I survive to depot 3" cite | ✓ YES |
| **C4 Depth bands** = 3 | 5 bands in `configs/breach_default.tres` with per-band pressures + canonical answers (iter 33+) | 4-5 playtest | ✓ YES |
| **C5 Enemy role vocab** = 3 | `loop/breach/PRESSURES.md` per-archetype × per-pressure matrix (iter 76) | 4-5 playtest | ✓ YES |
| **C7 Silhouette grammar** = 3 | gate gate exists in `analyze_frame.py`; SCOUT_TELEGRAPH (iter 113) is **NOT a new asset** — it's a `self_modulate` tint on existing Light enemy sprite; grammar-gate-on-new-assets doesn't trigger | 4-5 playtest | ✓ YES (no new asset → no audit fail) |
| **C11 Run-to-run variety** = 3 | iter 39 band-order shuffle + iter 40 depot next-band preview tracks varied run; deterministic from seed | 4-5 playtest | ✓ YES |
| **C12 Stakes & escalation** = 3 | iter 73 BEST + BEST_TIME persistence; iter 108-110 verdict recap with depth-vs-BEST visible side-by-side ("DEPTH 95 · TIME 4:32 · KILLS 18\nBEST 110") | 4 = "single life feels like it matters" playtest; 5 = "chases best-depth across runs" playtest | ✓ YES |
| **C13 Meta-progression** = 3 | iter 51 `_build_unlock_ladder` renders the unlock ladder on the run-start shell_codex with "best depth N — climb to earn depot options" header + per-tier green/dark cells | 4-5 playtest | ✓ YES |
| **C14 In-run progression** = 3 | iter 58 XP + level-ups + pick-1-of-3-at-every-phase + AmmoPickup mid-combat resupply (test_breach_xp + test_breach_ammo) | 4-5 playtest | ✓ YES |

**Summary**: 8 of 15 axes are at structural ceiling 3/5. Combined
with C6 effective 4 (cognitive-max iter 110) and C8 effective 4
(cognitive-max iter 113), the **structural ceiling is 49/75
effective**. Movement beyond this requires:

1. **Playtest cite** for any of the 8 FEEL-blocked axes (mostly
   anchor 4: "user describes X unprompted")
2. **Cognitive-max claim** for a FEEL anchor with unusually
   strong structural evidence (already exercised at C6 + C8)
3. **New mechanical scope** that extends a rubric anchor's
   surface (e.g. open_killbox C8-anchor-3 completion via a new
   chassis mechanic)
4. **RUBRIC extension** with new criteria (per /greenfield-loop
   invariant 1 — rubric is replaceable)

---

## Part 2 — open_killbox completion as Round 14 BUILD-able surface

The cleanest path forward without a playtest signal is closing
the **open_killbox C8-anchor-3 gap** that Round 13 deferred. The
band's canonical answer is "AP precision + facing-aware
positioning; HE wasted here" — a chassis-mechanic upgrade that
changes facing/positioning behavior would lift C8 absolute from
3 → 4 (anchor 3 fully met: all 5 bands covered).

### 3 candidate mechanics

#### REAR_GUARD (passive auto-defense in rear cone)

When owned, an AP shot automatically fires at the closest enemy
in the rear 90° cone when one enters it. Costs no shell. Cooldown
~2.5s. Sentence: *"helps me climb open_killbox by changing how
I commit to facing — rear scouts no longer demand a turn."*

- **Pros**: Sentence-test compliant (commitment-change affordance).
  Direct answer to "rear-flank patrols". Small implementation:
  flag + per-frame scan + fire-backward call.
- **Cons**: Passive (auto-fires). Marginal verb-style. Could
  feel like a free pass — does it teach the player to STOP
  thinking about rear flanks? (Mitigation: cooldown forces
  manual rear-aware moments anyway.)

#### TWIN_TURRET (passive — fire forward AND backward each cooldown)

Each gun cooldown fires TWO bullets (forward + backward) at the
cost of 1 shell. Sentence: *"helps me climb open_killbox by
changing how I cover both directions."*

- **Pros**: Affordance change. The player thinks differently
  about positioning (any forward fire covers a rear threat too).
- **Cons**: Visual clutter (double bullets every shot). Risks
  becoming the default firing pattern (overshadows single-shot
  positioning rather than enriching it).

#### FACING_BURST (active — press X for instant 360 sweep)

Pressing X fires 4 AP shells (N/S/E/W) simultaneously at the
cost of 2 shells. Cooldown 4s. Sentence: *"helps me climb
open_killbox by changing how I respond to surrounded moments —
one button, all directions."*

- **Pros**: Active verb (player input → mechanic). Strong
  affordance (single-button-360-fire is memorable).
- **Cons**: New input binding (X). Higher implementation cost
  (input wiring, 4-shell consumption, fire-from-each-direction
  loop, cooldown). Probably the highest-quality but biggest scope.

### Comparison

| Axis | REAR_GUARD | TWIN_TURRET | FACING_BURST |
|------|------------|-------------|--------------|
| Sentence-test verb-style | ✓ (commitment) | ✓ (coverage) | ✓ (response) |
| Active vs passive | passive | passive | **active** |
| Input surface | none | none | new key |
| Implementation scope | small | small | medium |
| Visual clutter risk | low | high | low (burst once + cooldown) |
| Teaches good positioning | indirect | weak | strong |
| Default-on gating risk | low | low | low |

---

## Recommendation: **REAR_GUARD** for Round 14 BUILD

REAR_GUARD has the cleanest cost/benefit:
- Smallest implementation (one Loadout flag + one per-frame
  check + one fire-backward call)
- Directly addresses the band's named pressure ("rear-flank
  patrols")
- Cooldown prevents it from becoming a free-pass spammable
- Sentence-test compliant (commitment-change verb)

FACING_BURST is the highest-quality but introduces new input
binding scope. Defer it unless playtest cites surface a
specific demand for a "panic button" verb.

TWIN_TURRET fails the legibility check (constant double-bullets
is too noisy for a positioning-aware band).

---

## Round 14 plan

- **iter 116 — DECISION + BUILD**: implement REAR_GUARD per
  the SPIKE-effective recommendation above (no separate SPIKE
  needed — DIAGNOSE already enumerated alternatives).
  - Loadout flag `has_rear_guard: bool`
  - Depot UpgradeKind value (catalog 13 → 14; pool entry; label)
  - PlayerTank.gd substrate write ×44: per-frame scan of "enemy"
    group for any body in the rear 90° cone within 96px range;
    fire AP backward (180° from current direction); arm cooldown
  - Test_breach_overdrive: catalog 13 → 14 + pool sizes +1
  - Test_breach_meta: pool sizes +1
  - NEW test_breach_rear_guard.gd: 5+ assertions (flag default,
    apply, rear-cone detection, fire fires, cooldown arms,
    front-cone no-fire regression)
- **iter 117 — META**: Round 14 close-out doc; C8 lifts 4 → 4
  absolute (anchor 3 fully met — all 5 bands covered); pivot
  to next axis (likely re-audit of cognitive-max effective
  claims across the 8 ceilinged axes — could some claim 4
  effective?)

### Side-path findings

- **C12 anchor 4 cognitive-max** *(possibly defensible)*: the
  iter 108-110 verdict_sentence shows "DEPTH 95 · TIME 4:32 ·
  KILLS 18\nBEST 110" — depth-vs-BEST contrast is structurally
  on-screen. This is structural evidence that "the single life
  feels like it matters" because the player SEES the depth-
  vs-record contrast every death. Anchor 4 says "the player
  PUSHES for depth, plays carefully near a record" — that's a
  behavior claim, but the structural prerequisite (the contrast
  IS visible to motivate the behavior) is there. **Marginal
  call** — defensible cognitive-max if we're consistent with
  C6 + C8 standard. Hold off unless Round 14 produces no other
  axis movement.

- **C13 anchor 3 alternate citation**: the iter-51
  `_build_unlock_ladder` is on the **run-start codex**, not
  the title screen. Anchor 3 says "the player sees what is
  unlocked + what climbing deeper grants — code-cited". Codex
  shown at run-start covers it. **No further structural lift
  available.**

---

## Honest forward path summary

**Without a user playtest signal**, the loop can earn:
- +1 effective (C8 → 4 absolute) via REAR_GUARD (Round 14)
- Possibly +1 effective (C12 → 4 cognitive-max) via re-score
- Total ceiling reachable: ~51/75 effective

**With a user playtest signal**, every axis 3 → 4 absolute is
potentially unlockable (8 axes × 1 = up to 8 absolute lifts).

This is the natural "playtest gate" moment — REVIEW-QUEUE #14
remains open and is the cleanest user-action surface.

The loop CONTINUES (no halt). Iter 116 = REAR_GUARD BUILD.
