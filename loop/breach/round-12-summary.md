# Round 12 — Death Recap Legibility — Summary

Round 12 ran iters 106-111. Goal: lift the weakest rubric axis
(intended C9 per iter-106 diagnosis; **actually C6** per
RUBRIC.md — see §Scoring correction below).

## Outcome

10 substrate changes shipped across 4 BUILDs; 3 new regression
harnesses (test_breach_run_recap_verdict_sentence,
test_breach_run_recap_killer, test_breach_run_recap_resource_sentence);
test-breach 57 → 60. Hash anchor 23d6a2ec3bf2821f preserved across
the entire round.

| Iter | Mode | Output | Substrate |
|------|------|--------|-----------|
| 106 | DIAGNOSE | iter-106-c9-diagnose.md — 5 named gaps in recap surface | none |
| 107 | SPIKE | iter-107-c9-spike-report.md — 3 rendering POCs (α/β/γ); γ wins on canonical_answer surfacing | none |
| 108 | DECISION+BUILD | γ verdict sentence: `RunRecap.verdict_sentence()` + 3 helpers + PlayerTank wire | PlayerTank ×42 |
| 109 | BUILD | Gap 2 kill-source: `Bullet.source_label` + Enemy `_fire` tag + PlayerTank `set_last_damage_source` | Bullet ×9, Enemy ×3, PlayerTank ×43 |
| 110 | BUILD | Gap 3 resource attribution sentence: `resource_sentence` + word-boundary regex (no AP↔APCR or HE↔HEAT false matches); parenthetical-suppression | none (arc-4-owned RunRecap.gd) |
| 111 | META | This summary doc + REVIEW-QUEUE #18 + scoring correction | none |

## Scoring correction (load-bearing)

**I was lifting the wrong criterion label in STATE since iter 106.**

The iter-106 DIAGNOSE described "C9 (death attribution / run recap
legibility) at 2/5" — but RUBRIC.md is unambiguous:

- **C6 = Death attribution** *(structural)* — captures depth + killing
  entity + build identity + dominant pressure + actionable diagnosis.
  This is exactly the criterion the verdict_sentence + kill_source +
  resource_sentence chain lifts.
- **C9 = Identity / breach-roguelite singularity** *(feel)* — captures
  whether the game has its own identity vs "BC with cards" / "VS with
  tank skins". Anchors 3-5 are all [FEEL] playtest-cited; absolute
  structural max is 2/5.

The pre-iter-106 score string had `C6=3` (death attribution, accurate
at the time) and `C9=2` (identity, accurate). My LEDGER/STATE entries
for iters 106-110 attributed lifts to **C9** when the work was
demonstrably C6 anchor 3→4.

Corrected scoring (per RUBRIC.md):

| Criterion | Pre-Round-12 | Post-Round-12 effective | Post-Round-12 absolute |
|-----------|--------------|-------------------------|------------------------|
| C6 (Death attribution) | 3 | **4** (anchor 4 effective via cognitive-max — verdict reads as actionable diagnosis structurally) | 3 (anchor 4 [FEEL]; playtest cite gates absolute) |
| C9 (Identity singularity) | 2 | 2 (unchanged — no Identity-axis work this round) | 2 |
| **Total** | **47/75 effective** | **48/75 effective** | **47/75 absolute** |

The corrected delta is **+1 effective** on C6, not the +3 across C9
that intermediate STATE strings claimed. The work shipped is exactly
what it was — high-quality, regression-covered, constraint-6-shaped
recap legibility — but it earns +1 effective, not +3.

This correction follows R2 (identity-protected anchors not AUDIT-
eligible) and R3 (effective ≠ absolute) discipline carried from
arc-3 close. Anchors 4-5 on C6 are [FEEL]-tagged; effective lift to
4 is defensible via cognitive-max (the verdict text structurally
demonstrates "actionable diagnosis" form), but absolute 4 requires
a playtest cite per the anchor's "playtest sample cited" tag.

## Per-rubric-anchor citation table

C6 (Death attribution) — what's citable post-Round-12:

| Anchor | Status pre-R12 | Status post-R12 |
|--------|----------------|-----------------|
| 1 — captures depth + killing entity | ✓ (RunRecap.gd since iter 31) | ✓ |
| 2 — shell consumption + reserve at death | ✓ (since iter 33 in format()) | ✓ |
| 3 — build identity tag + dominant pressure | ✓ (build_tag() + killing_pressure in format()) | ✓ |
| 4 — recap reads as actionable diagnosis | ✗ (text not on screen, was ASCENDER stats) | **✓ effective** (verdict_sentence wired to _death_label, names build + band + dry-on-X + canonical answer); **✗ absolute** (needs playtest sample cite) |
| 5 — user uses recap unprompted in next loadout | ✗ ([FEEL] playtest-only) | ✗ ([FEEL] playtest-only) |

## Loop-process findings

1. **The mislabeling itself is the round's most valuable finding.**
   Five iters of work consistently attributed to the wrong criterion
   number. Caught only via RUBRIC.md re-grounding at META time.
   Adds a discipline: every BUILD iter that claims a rubric lift
   must cite the criterion's NAME from RUBRIC.md, not just the
   number. Score-string discipline alone wasn't enough — RUBRIC.md
   is canonical, STATE.score is just the cache.

2. **γ rendering shape validation.** The iter-107 SPIKE recommended
   γ over α/β. Post-implementation, γ delivered on its predicted
   strengths — the canonical_answer surfacing turned the recap from
   "what happened" into a learning-moment diagnosis. The
   line-budget concern (γ might overflow on edge cases) was real
   — Gap 3's resource_sentence required suppressing the parenthetical
   canonical aside to stay within 10 lines.

3. **Method-existence-gated propagation pattern is reusable.**
   `body.set_last_damage_source` (iter 109) is method-existence-
   gated — arc-2/3 bodies don't define it, so the call is a no-op
   on the baseline. Same pattern works for: PRISM beam damage,
   HE blast splash, MORTAR splash, RAM impact (all currently fall
   back to "shell impact" placeholder; cheap follow-on work).

4. **Word-boundary regex matters in domain-string detection.**
   Iter 110's resource_sentence has to detect "HE" in canonical
   strings without false-matching "HEAT", and "AP" without false-
   matching "APCR". `\bHE\b` / `\bAP\b` correctly handles both.
   Test_breach_run_recap_resource_sentence assertions 5 + 6
   are anchored on this — would have shipped wrong without them.

5. **Parenthetical-suppression-when-resource-sentence-fires** is
   a UX-grade decision that's hard to reverse later. The resource
   sentence already names the canonical answer (either as "the
   band's canonical answer" or "band wanted Y"); the parenthetical
   would repeat. Suppression cleans up redundancy AND preserves
   the panel's line budget. Documented in the verdict_sentence
   docstring + harness assertions.

## Round 13 bootstrap

Multiple criteria are tied at 3/5 (the lowest non-promoted scores):
C1, C2, C4, C5, C7, C8, C11, C12, C13, C14. With C6 now at 4
effective, the weakest *structural* axes that can move without
playtest are:

- **C8 (Sentence test compliance) = 3** — anchor 4 is [FEEL] but
  anchor 3 is "upgrade catalog covers all 5 depth bands' dominant
  pressures". Structural surface; potentially auditable.
- **C7 (Silhouette grammar) = 3** — anchor 4+ are [FEEL] playtest;
  absolute structural max is 3.
- **C1 (Breach build identity) = 3** — anchor 4 is [FEEL] but
  anchor 3 is "run-tag emitted on death + visible in recap". The
  iter 108-110 verdict already names build_tag in the recap...
  arguably C1 was lifted to 3 already; potentially 4 effective
  via the same cognitive-max as C6.

C9 (Identity singularity) is also worth revisiting once the
Round-12 recap improvements have a playtest cite — anchor 3 (tester
describes arc-4 differently within 60s) is achievable once any
post-Round-12 playtest happens.

**Recommendation**: iter 112 DIAGNOSE on **C8 (sentence test
compliance)** — the upgrade catalog has grown across rounds 5-11
without a formal sentence-test audit pass. A quick DIAGNOSE iter
can survey Loadout.gd's upgrade kinds against the sentence template
to identify which fail. Alternative: C1 anchor 4 effective
re-score if the verdict_sentence already implies build-identity
visibility.

Defer C9 and the playtest-only axes (C3 anchor 5, C8 anchor 4,
C9 anchor 3+, etc.) until a user playtest signal arrives —
REVIEW-QUEUE #14 remains open.
