# tanke — Originals Loop FALSIFICATIONS (arc 3)

Append-only. F-numbered findings where a prediction or assumption was
empirically refuted. Tag with [STRUCTURE] / [FEEL] / [MIXED] /
[STRUCTURE-DEFERRED] per arc-2 H2 RULE v2.

Parallel to `loop/FALSIFICATIONS.md` (arc 1, engine — F001-F004) and
`loop/gameplay/FALSIFICATIONS.md` (arc 2, gameplay — F001-F014).

---

## F001 — Tanks roster formula approximates mean but loses per-stage variance

**Iter:** 015
**Tag:** [STRUCTURE]
**Predicted:** Iter-4 cited the Tanks formula (`p_armored(stage) = 0.00735 × stage + 0.09265`) as the canonical BC enemy-roster representation. iter-7's `scripts/Roster.gd` and iter-11's Spawner integration both treat the formula as faithful.

**Observed:** Iter-15 cross-validation against StrategyWiki's per-stage walkthrough revealed:
- **Mean armor fraction matches**: 24.1% empirical vs 22.5% predicted (Δ 1.6%).
- **Trend direction matches**: empirical and predicted both rise monotonically with stage number.
- **Per-stage variance diverges**: empirical range [0%, 50%] vs formula [10%, 35%]. Specific stages mismatch by >20%:
  - Stage 17: 50% empirical vs 21.8% predicted (Δ 28.2%)
  - Stage 25: 50% empirical vs 27.6% predicted (Δ 22.4%)
  - Stage 28: 5% empirical vs 29.8% predicted (Δ 24.8%) — opposite direction
- BC's roster has specific "spike" stages (17, 25, 35) and "breather" stages (1, 7, 28); the formula smooths through these.

**Implication:**
- The formula is a faithful AGGREGATE approximation; **not** a per-stage table replica.
- For arc-3 v1, the formula is sufficient for the "increasing difficulty curve" feel.
- For full BC fidelity (arc-3 v2 or future), the per-stage roster from `loop/originals/roster-validation.md` could be promoted to a `configs/og_rosters.tres` artifact and `Roster.gd` extended to read per-stage data.

**Lesson:** stochastic formulas sourced from a derivative repo (Tanks's C++) capture *trend* but discarding *variance* matters for "this stage felt like BC Stage K" cite (C5 anchor 5, currently held at 4). The Tanks codebase's design choice — formula over table — was a simplification; arc-3's faithfulness ambition surfaces the gap.

**Action:**
- Logged here as F001 (the first arc-3 falsification).
- Documented in `loop/originals/roster-validation.md` with full per-stage table.
- REVIEW-QUEUE item NOT added — this isn't blocked on user input; it's an explicit known-approximation that the v1 formula is good enough for.
- If arc-3 v2 happens, the per-stage table is ready to promote to a config artifact.
