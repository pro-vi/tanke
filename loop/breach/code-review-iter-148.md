# Code Review — iter 148 (Pro Consult 011 round close)

**Date:** 2026-05-24
**Scope:** iter-142..147 substrate writes — `scripts/PlayerTank.gd` (+1
to #70) and `scripts/TankSprite.gd` (+1; additive frame_base).
**Trigger:** F006 discipline ("/code-review at every round close, not
self-audit") — Pro Consult 011's 5-iter plan closed iter 147; this
iter delegates a focused independent review of the substrate-touching
diff before bootstrap-next.

## Result

**NO ANCHORED FINDINGS at the 75-confidence gate.**

The independent reviewer audited:

- `_apply_archetype_sprite` body (both gate branches: loadout-null and
  DEFAULT-archetype) + its call sites at `_init_archetype` and
  `_revert_archetype`.
- TankSprite.gd `frame_base` field default and the `_process` selector
  expression `set_frame(frame_base + dir_set[animation_frame])` —
  confirmed bit-identical at frame_base=0 (integer addition with 0 is
  identity).
- All 7 harness cases — confirmed that Case 1 (loadout=null + PRISM)
  exercises the null-loadout gate with a non-DEFAULT archetype value
  set; Case 7 routes through `_revert_archetype` end-to-end;
  `switch_archetype` revert→assign→re-init sequence covered.

Cross-arc invariant verdict: **hash anchor 23d6a2ec3bf2821f… holds
on the procedural baseline.** The null-loadout gate writes texture/
vframes/frame_base every spawn, but these are no-ops semantically when
the scene-default is already sprites_0.png + vframes=18; `frame_base=0`
adds a dynamic property that Godot's Sprite2D doesn't serialize and
doesn't render-affect (TankSprite reads it; identity at 0). No
render-pipeline divergence.

## Sub-75 nits (not anchored — recorded for future cleanup)

These are below the 75 confidence gate so do NOT enter REVIEW-QUEUE,
but capturing them keeps the audit honest:

**N1 — `sprite.has_method("set")` tautology.**
- Location: `PlayerTank.gd` inside `_apply_archetype_sprite`, 3 sites
  (loadout-null branch + DEFAULT-archetype branch + final swap branch).
- Issue: `set()` is on `Object` so always true. The apparent intent was
  to guard the dynamic `frame_base` field's existence, but the guard is
  inert.
- Risk: cosmetic; the call works regardless because Godot allows
  `set("frame_base", ...)` on any Object (creates a dynamic entry if
  absent, sets the value if present, and TankSprite reads it via the
  same dynamic mechanism). Confidence anchor: 25 (speculative — no
  failure mode under current scene-graph).
- Action: leave as-is OR remove guards in a future cleanup iter
  (would shave 3 lines). Not worth a dedicated fix iter.

**N2 — Harness chain coverage gap.**
- Location: `test_breach_archetype_sprite.gd` Case 7.
- Issue: Case 7 tests MORTAR→RAM chain (non-DEFAULT→non-DEFAULT) but
  doesn't test MORTAR→DEFAULT (revert-from-chain) in the same flow.
  Case 6 tests PRISM→DEFAULT but that's a single-hop, not a chain.
- Risk: a hypothetical future regression where revert from a
  non-DEFAULT chain leaves stale vframes wouldn't be caught by the
  current harness. Currently safe because `_revert_archetype` calls
  `_apply_archetype_sprite(DEFAULT)` unconditionally. Confidence
  anchor: 50 (logical extrapolation; no failure today, would catch
  a future bug if revert logic is refactored).
- Action: add a Case 8 in a future iter — PRISM→MORTAR→DEFAULT chain,
  asserts texture/vframes/frame_base all revert. ~10 lines.

## Lessons

L1: F006 discipline pays off — even when the round looks clean, a
focused independent pass surfaces sub-anchored observations that
self-audit consistently misses. The two nits above WOULD have been
caught by a `/code-review` 6 iters earlier had the discipline been
applied iter-by-iter.

L2: pixel-level falsifiable claims (iter 145 cleat-no-op catch) and
machine-checkable readability gates (iter 144 RAM-density catch) are
the in-iter equivalents of /code-review for ASSET work — they catch
the same class of defect (cosmetic-looking-correct, actually wrong)
that /code-review catches for CODE work.

L3: at honest saturation (iter 128 posture), the marginal value per
iter shifts from "ship more substrate" to "harden what's shipped."
This iter's review IS the hardening — auditing the structural
ceiling rather than chasing more anchors.
