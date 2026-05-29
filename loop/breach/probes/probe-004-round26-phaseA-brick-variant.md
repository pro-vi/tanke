# Probe 004 — Round 26 Phase A close: BrickBlock variant_texture wiring

**Iters shipped:** 311 (blueprint), 312 (pivot + asset + DG-001), 313 (wiring + harness), 314 (this report)
**Round:** 26 Phase A (visual identity sprint — first phase)
**Status:** Phase A done criteria MET. Round 26 enters Phase B+ deferred posture.

---

## What Phase A shipped

| Iter | Mode | Deliverable |
|---|---|---|
| 311 | META | Round 26 blueprint at `loop/breach/iter-311-round26-architect.md` — 4-iter Phase A scope; procedural-PIL-first; conservative substrate budget (≤3 writes) |
| 312 | CAPABILITY | `tools/gen_tile.py --variant 12` produced `img/brick_012.png` (8×8 brick variant; palette extracted from canonical sprites_1.png). Derivation-gap DG-001 logged at `loop/breach/derivation-gaps.md` — `gen_sprite.py` is MLX-SD (P1 NO-GO); pivoted from enemy-sprite to terrain-variant scope |
| 313 | BUILD | `scripts/BrickBlock.gd` substrate write #3 — `variant_texture: Texture2D = null` @export + _ready branch swapping sprite + atlas indexing when set. 4-case harness `loop/breach/test_breach_brick_variant.gd` verifies both default-null (arc-2/3 baseline preserved) and override (standalone tile) codepaths |
| 314 | BUILD | This report |

---

## Done criteria check

| Criterion | Target | Actual | Status |
|---|---|---|---|
| Sprite asset shipped | 1 algorithmic variant | brick_012.png at img/ | **PASS** |
| Silhouette grammar gate | Cited (CONSULT constraint 4) | Within-role variant; gate FAIL is intentional (same role, different pattern) — documented in DG-001 | **PASS** (with finding) |
| Loadout/data-gated wire | Default codepath bit-identical | `variant_texture: Texture2D = null` default → _ready branch never enters; arc-2/3 baseline preserved | **PASS** |
| Hash anchor preservation | 23d6a2ec3bf2821f on seed 42 | Verified bit-identical at iter 312, 313, 314 | **PASS** |
| Harness coverage | +1 test-breach target | 89 → 90 OK markers (+1 for brick-variant) | **PASS** |
| Substrate writes budget | ≤3 | 1 (BrickBlock.gd ×3 this arc) | **PASS** (1 of 3 budget used) |

All 6 done criteria met. Phase A ships clean.

---

## Findings

### F1 — Pivot uncovered a real dependency gap (DG-001)

The iter-311 blueprint assumed `tools/gen_sprite.py` was a usable extension point for procedural enemy sprites. Dependency check at iter 312 surfaced that `gen_sprite.py` is **MLX-Stable-Diffusion-based** — P1 NO-GO per PROMPT § ANTI-PATTERNS ("MLX-SD asset gen work | P1 NO-GO; arc-1 phantom-dependency anti-pattern"). The blueprint was UNDER-INSPECTED at iter 311 — should have grep'd the tool before claiming extensibility.

**Lesson encoded:** added `loop/breach/derivation-gaps.md` as the structural log for these kinds of dependency mismatches. Per PROMPT halt-cause classifier `derivation-gap`, the resolution requires producing ONE of {decision record, minimal experiment, uncertainty-reduction patch} — iter 312 produced BOTH the decision record (DG-001 with sanctioned alternatives) AND a concrete patch (pivot to gen_tile.py + brick_012.png). Rule-compliant.

**Going forward:** every blueprint that names a tool extension should grep the tool's source for forbidden dependencies (MLX, phantom imports) BEFORE iter-1 of the round commits work.

### F2 — Within-role variants invert the silhouette gate's purpose

Running `silhouette_gate.py img/brick_007.png img/brick_012.png` returns FAIL with "silhouette diff 0 < 8" — both bricks are 64/64 opaque cells, identical silhouettes. The gate is designed to ensure NEW-ROLE assets are visually distinct (player vs enemy vs powerup). For SAME-ROLE variants (brick_v1 vs brick_v2), the desired test is INVERTED: silhouettes SHOULD match (same role), pattern + palette SHOULD differ.

**Backlog candidate:** add `silhouette_gate.py --variant-mode` flag that asserts (1) silhouette matches between assets (same role preserved) AND (2) palette/interior pattern differs (variant signal present). Filed at DG-001 backlog.

### F3 — The `variant_texture` field is shipped but NOT YET ACTIVATED

iter 313 ships the OVERRIDE CAPABILITY: BrickBlock can swap its sprite when given a `variant_texture` ref. But no Level.gd or ProceduralLevel.gd code SETS this field on any instantiated brick — arc-2/3 baseline never passes the override, so the default null path is the only live path.

This is intentional Phase A scope (the blueprint explicitly defers activation to Phase B+). The shipped state of the codebase is:

- brick_012.png exists (a real asset)
- BrickBlock.variant_texture exists (a wireable hook)
- The hook has not been wired (no caller yet)

A future iter that wants to activate this would:
1. Add `brick_variant_path: String = ""` (or `brick_variant: Texture2D = null`) field to BreachBand.gd or BiomeConfig.gd
2. Hook Level.gd._replace_blocks() to read the active band's variant + pass to each instantiated BrickBlock via `b.variant_texture = active_band.brick_variant`
3. Update breach_default.tres to set brick_012 for one of the bands (e.g. brick_maze band gets brick_012; tutorial_choke stays at default)
4. Hash anchor verification: the activation must be loadout-gated AND default-disabled OR config-defaulted-empty so arc-2/3 baseline never enters the override path

Estimated effort: 1-2 iters, 1-2 substrate writes (BreachBand + Level OR ProceduralLevel).

**Why deferred:** Round 26 substrate budget is conservative (~3-5 writes for whole round); iter 313 used 1; Phase B activation would use another 1-2; that leaves headroom for Phase C+ (card icons, depot variants, etc.) IF user explicitly re-engages with Round 26 scope.

### F4 — Round 26 trajectory: continuing vs closing

Phase A demonstrates the pipeline works:
- Procedural asset generation (sanctioned via gen_tile.py)
- Per-instance override CAPABILITY (sanctioned per substrate budget)
- Harness defends both codepaths
- Hash anchor preserved through 4 iters

Phase A does NOT demonstrate visible in-game change — the override is never set. A player running the game won't see brick_012; they'll see brick_007 (the canonical) like before.

Two trajectories from here:

**(a) Continue Round 26 into Phase B** — wire activation (1-2 iters, 1-2 writes); ship the first BAND-themed brick variant; player can now see different bricks in different bands. This is the smallest "real visible change" extension.

**(b) Close Round 26 at Phase A** — log the override CAPABILITY as a future-extension surface; bootstrap a different round. Honest because: (i) the user has been auto-firing /loop without re-engagement, (ii) Phase A is a self-contained capability addition, (iii) substrate writes spent so far (1) are recoverable budget.

The loop's default behavior per PROMPT § HALT CONDITIONS would be (a) — keep running, advance to Phase B. But the user's silence about Round 26 scope (no explicit "yes go visual identity" since the post_halt_direction Option B nudge for probes) means the loop is operating on STANDING DIRECTION ONLY.

**My recommendation at iter 314 close:** (a) — proceed to Phase B at iter 315. Rationale: Phase A is structurally complete BUT visually invisible. A single Phase B iter that activates band-variant selection produces actual visible difference. The substrate cost is ~1 write (sanctioned). After Phase B activation, Round 26 can naturally close OR extend further if user re-engages.

---

## What this probe CAN'T tell us

- Whether brick_012's visual differentiation from brick_007 is MEANINGFUL to a player (subtle mortar variation; would a real player notice?)
- Whether band-themed brick variants meaningfully advance the "modern Stardew delta" identity (texture variation is one of many surfaces; not necessarily the load-bearing one)
- Whether the procedural PIL output quality is acceptable as the long-term answer OR whether Phase B+ should pivot to /agentify image_gen for quality (defer until user re-engages)

These remain real-playtest-gated.

---

## Substrate impact (cumulative through Round 26 Phase A)

- Files added: `tools/q1_bot_run.gd`, `tools/shell_pressure_matrix.gd` (Round 25 leftovers), `img/brick_012.png` + `.import`, `scripts/BrickBlock.gd` substrate write #3, `loop/breach/test_breach_brick_variant.gd`, `loop/breach/derivation-gaps.md`, `loop/breach/probes/probe-004-round26-phaseA-brick-variant.md`, blueprint amendment
- Layer 1/2/3 substrate writes through Phase A: **1** (BrickBlock.gd ×1 — 92 → 93)
- Round 26 substrate budget remaining: 2-4 (of original 3-5)
- Hash anchor `23d6a2ec3bf2821f` preserved through all 4 iters
- test-breach: 89 → 90 (+1 OK marker for brick-variant harness)
- test-all: 5/5 unchanged

---

## Iter 315+ posture

Per F4 recommendation: iter 315 advances to Phase B activation. Specifically:
1. Add `brick_variant: Texture2D = null` field to BreachBand.gd (Resource — not Layer 1/2/3 substrate; arc-4-owned)
2. Hook Level.gd._replace_blocks() to read the active band config and pass variant_texture to each instantiated BrickBlock — gated on the breach mode active band having a non-null variant
3. Update `configs/breach_default.tres` to assign brick_012 to the brick_maze band (depth 30-70 range — the second band)
4. Harness verifies (a) brick_maze band → bricks render brick_012; (b) tutorial_choke band → bricks render canonical brick_007; (c) arc-2/3 procedural baseline (loadout=null) → all bricks render canonical brick_007; (d) hash bit-identical

Estimated: 2-3 substrate writes (BreachBand.gd ×N OR Level.gd ×N + configs); 1-2 iters of work.

If the user surfaces fresh direction before iter 315 fires (halt / new round / Stardew pacing pivot / playtest score), the loop honors that over the default Phase B advance.
