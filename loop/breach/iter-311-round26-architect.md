# iter 311 — Round 26 (Visual Identity Sprint) — Blueprint

**Date:** 2026-05-27
**Mode:** META → opens Round 26 as the visual-identity variant per `STATE.post_halt_direction_iter_305` Option A sanctioned candidate + REVIEW-QUEUE #27 queued + `asset_gen_standing_capability` authorized.
**Trigger lineage:** iter-270 "modern delta from raw BC" + iter-271 "assets from chat gpt... we can produce all sorts of assets now" + iter-305 post_halt_direction.

---

## Stance: conservative-first

The visual-identity sprint is the largest available next surface. STATE estimates 30-50 iters at full scope. **This blueprint scopes Phase A as a single proof-of-concept asset shipped via procedural PIL (gen_sprite.py extension), not /agentify image_gen.** Reasons:

1. **Substrate budget discipline.** substrate_writes = 92 of 120 cliff. Round 26 needs to fit ~10-15 writes max to avoid calcification. Phase A's 1-asset proof-of-concept fits in 2-3 writes.
2. **External resource cost.** /agentify image_gen is real ChatGPT API + minutes per call. The user has been auto-firing /loop on wake-up cadence — they may or may not be at the terminal. Burning external resources without explicit re-engagement is reckless.
3. **Pipeline already exists locally.** `tools/gen_sprite.py`, `tools/gen_archetype_sprites.py`, `tools/silhouette_gate.py`, `tools/compose_sheet.py` shipped at iters 142-149. Procedural PIL extension is the same-iter fallback the standing-capability note names.
4. **Phase B+ reserved for /agentify** once user re-engages OR Phase A passes silhouette grammar gate + ships clean.

---

## Round 26 — Phase A scope

**Goal:** ship ONE enemy-tier visual variant via procedural PIL extension. Prove the swap-in plumbing works at the loadout-gated layer (arc-2/3 procedural baseline stays bit-identical).

**Target:** **Light enemy "tier-2" sprite** — same silhouette family as standard Light enemy, slightly armored visual (1 extra band/highlight stroke) signaling "depth-tiered" enemy variant.

### Pipeline

1. **Generate** — extend `tools/gen_sprite.py` (or new `tools/gen_enemy_tier_sprite.py`) to produce a 4-direction sprite at the next available frame index in `sprites_*.png`. Output: `img/enemy_light_t2.png` (or appended into existing atlas).
2. **Silhouette gate** — run `tools/silhouette_gate.py` to confirm the variant reads at silhouette+palette+facing+intent (CONSULT constraint 4 — sanctioned). Fail → fix → re-gate.
3. **Wire** — extend Spawner.gd `ENEMY_TYPES` table with a new entry (or new `enemy_subtype` field) carrying `base_frame` for the t2 variant. ALL writes loadout-gated; default procedural mode untouched.
4. **Spawn-side trigger** — add an existing-band depth-tier check OR a Loadout flag toggling whether spawned Light enemies use t1 (default) vs t2 (breach mode tier-up). Default off → bit-identical hash.
5. **Harness** — `loop/breach/test_breach_enemy_tier_variant.gd` verifies (a) sprite asset exists, (b) silhouette grammar passes, (c) Spawner uses t1 base_frame when Loadout flag off (bit-identical), (d) Spawner uses t2 base_frame when flag on.

### Substrate writes (Phase A budget): ≤ 3

- 1× write to Spawner.gd (`ENEMY_TYPES` table extension OR enemy_subtype field; loadout-gated)
- 0× to Enemy.gd (uses existing `sprite_base_frame` mechanism — no schema change)
- 1× to Loadout.gd (NEW flag for tier-up — defaults to off)
- 1× possibly to `configs/breach_default.tres` (toggle flag on for breach mode)
- Hash anchor preservation: verified post-edit with default loadout flag off.

### Deliverables

- `tools/gen_sprite.py` extension (or new tool) — produces the variant sprite
- `img/enemy_light_t2.png` (or appended atlas frame)
- Spawner.gd substrate write (loadout-gated)
- Loadout.gd new flag
- `loop/breach/test_breach_enemy_tier_variant.gd` harness
- `loop/breach/probes/probe-004-round26-phaseA-visual-identity.md` ship report (NOTE: probe naming continues from Round 25 since this is documentation-of-shipped-work)

---

## Iter sequencing

| Iter | Mode | Focus |
|---|---|---|
| 311 | META | This blueprint (current iter) |
| 312 | CAPABILITY | Extend gen_sprite.py for enemy_light_t2 variant; generate + silhouette gate |
| 313 | BUILD | Wire Spawner.gd + Loadout.gd substrate writes (loadout-gated; ≤3 writes) |
| 314 | BUILD | Ship harness + ship report; hash anchor verify; close Phase A |

Total Phase A budget: 4 iters max.

**Phase A done criteria:**
- Sprite asset present at `img/enemy_light_t2.png` AND silhouette grammar PASSES
- Spawner table extension shipped + loadout-gated harness PASSES
- Default procedural mode (loadout=null) renders bit-identical hash `23d6a2ec3bf2821f` on seed 42
- test-breach 89 → 90 (+1 OK marker for new harness)
- ≤3 substrate writes total (substrate_writes_this_arc ≤ 95)

---

## Phase B+ (deferred — user re-engagement OR Phase A success gate)

If Phase A ships clean AND user re-engages with explicit direction, Round 26 may extend to:
- **Phase B**: /agentify image_gen for 1 enemy variant + comparison vs procedural baseline (calibration: how much does art quality matter?)
- **Phase C**: 4 upgrade card icons (highest-leverage cards by usage)
- **Phase D**: 1 depot art variant (per-band differentiation)

Phase B+ scope decisions are deferred. Phase A is the only committed slice.

---

## What this round does NOT do

1. Does NOT use /agentify image_gen in Phase A (deferred to Phase B pending user re-engagement).
2. Does NOT touch Layer 1/2/3 substrate beyond ≤3 sanctioned writes (Spawner is Layer 2; default-on gating template applies).
3. Does NOT consult-fire (hard constraint per post_halt_direction).
4. Does NOT add REVIEW-QUEUE direction-asks (per WATCH-FOR signal #2 anti-accretion).

---

## Risks

- **gen_sprite.py extension may produce a sprite that fails silhouette gate.** Mitigation: silhouette_gate.py is a hard quality gate; failure → iterate the procedural generation algorithm (parameters: stroke count, palette band, body cell offset). Worst case: Phase A pivots to a smaller asset (e.g., a tier-marker overlay instead of a full sprite swap).
- **Hash anchor break.** Mitigation: every substrate write loadout-gated; default flag off; hash verified post-edit.
- **Phase A "ships clean" but is visually underwhelming.** Honest read: procedural PIL produces lower quality than /agentify. Phase A is proof-of-pipeline + permission-to-extend; if visually underwhelming, that's WHY Phase B (/agentify) is reserved.

---

## Anti-cargo-cult check (iter 273 / iter 282)

The iter-282 /meta finding warned against "becoming extremely good at managing the absence of evidence — labels, counters, tags, consults — while still avoiding 'did the game become more compelling to an actual player'."

Visual identity work directly produces in-game visual changes the user can SEE. This is the opposite of the failure mode the /meta finding named. Even procedural PIL variants are SHIPPED VISUAL DIFFERENCES vs current state — anchor-tied to compelling-for-player, not absence-of-evidence.

If Phase A ships and looks crude, that's still evidence the player can react to. Crude > invisible.
