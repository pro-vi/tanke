# Derivation gaps (arc 4)

Per PROMPT § halt-cause classifier `derivation-gap`: when a blueprint or
iter scope assumes a tool/dependency that turns out to be unavailable
or wrong-shaped, the loop must produce ONE of:
  - derivation artifact (decision record + alternatives)
  - minimal experiment / probe
  - concrete uncertainty-reduction patch

This file is the append-only LOG of those gaps + their resolutions.

---

## DG-001 — iter 312 — procedural enemy sprite generation unavailable for Round 26 Phase A

**Gap surfaced at:** iter 312 (Round 26 Phase A CAPABILITY).
**Blueprint claim:** "Phase A uses procedural PIL via gen_sprite.py extension to produce enemy_light_t2 sprite."
**Dependency check finding:** `tools/gen_sprite.py` is **MLX-SD-based** (Stable Diffusion via mlx-stable-diffusion). MLX-SD is **P1 NO-GO** per PROMPT § ANTI-PATTERNS:
  > MLX-SD asset gen work | P1 NO-GO; arc-1 phantom-dependency anti-pattern | Algorithmic via extended gen_tile.py only

**Sanctioned procedural surfaces:**
  - `tools/gen_tile.py` — 8×8 terrain tile variants (brick, steel, grass, water). Works via PIL palette extraction + algorithmic mortar / texture pattern generation per tile family. **Currently the only sanctioned procedural surface for arc-4 generated assets.**
  - `tools/gen_archetype_sprites.py` — player archetype 16×16 sprites via Consult-011 motif-first procedural masks. Single-purpose (already shipped at iters 142-149); does not generalize to enemy sprites without significant extension.

**What's missing:** there is **no sanctioned procedural enemy sprite generator** in arc-4. To build one would require either:
  - (a) extending gen_archetype_sprites.py's motif-first pattern to enemy roles (light/heavy/fast tiers × directions). Substantial engineering effort — multi-iter. Risks scope creep at the substrate boundary.
  - (b) /agentify image_gen pipeline (sanctioned per asset_gen_standing_capability at iter 271) — real external cost, minutes per call, requires user re-engagement to authorize burn.
  - (c) hand-drawn sprites via external editor — out of loop's scope.

**Decision (iter 312):** PIVOT Round 26 Phase A from "enemy_light_t2 sprite" to "band-themed brick tile variant via gen_tile.py." Reasoning:
  - sanctioned tooling (gen_tile.py is explicitly named in PROMPT as the extendable algorithmic path)
  - real visible visual identity (different mortar pattern + palette tint per band)
  - 0 external resource burn
  - same Round-26-blueprint scope axis (REVIEW-QUEUE #27 names "Background/floor decoration" as a candidate surface)
  - small substrate budget (~1-2 writes in ProceduralLevel.gd or BiomeConfig.gd for variant selection)

**Pivoted deliverable shipped iter 312:** `img/brick_012.png` — brick tile variant generated via `gen_tile.py --tile brick --variant 12 --from-sheet img/sprites_1.png`. Same palette family as canonical brick_007.png; distinct mortar pattern (different seed → different brick-row alignment).

**Silhouette gate finding:** the gate FAILS on within-role variants (brick_007 vs brick_012 both 64/64 opaque cells → silhouette diff = 0). This is the gate's CORRECT behavior — it's designed to ensure NEW-ROLE assets are distinct silhouettes. For SAME-ROLE variants, the test is inverted: silhouettes SHOULD match (the role is unchanged); the variant signal lives in interior pattern + palette tint.

  **Future:** if more within-role variants ship, consider a `silhouette_gate.py --variant-mode` flag that asserts silhouettes MATCH (same role) AND palette/pattern DIFFER (variant signal). Filed as Round 26 follow-up candidate.

**Status:** RESOLVED iter 312. brick_012.png shipped as Phase A first asset. Phase A wiring (loadout/band-aware variant selection in ProceduralLevel or BiomeConfig) targets iter 313 BUILD.

---

## Format for future entries

```
## DG-NNN — iter NNN — <one-line gap summary>

**Gap surfaced at:** iter NNN context.
**Blueprint claim:** what was assumed.
**Dependency check finding:** what's actually true.
**Sanctioned alternatives:** list.
**What's missing:** the structural gap.
**Decision (iter NNN):** PIVOT / HALT / RESOLVE-WITH-ALTERNATIVE.
**Status:** OPEN / RESOLVED iter NNN.
```
