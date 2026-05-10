# tanke — Loop Meta-Retrospective (Iters 0–27)

Written iter 28. The loop reached a natural pause point at 50/55 (90.9%) on
the expanded 11-criterion rubric. This retrospective documents what was
built, what was learned, and what each remaining gap honestly needs.

---

## The arc in three phases

### Phase 1 — Build & lift (iters 0–19)
40 → 49 / 55. Each iter typically targeted one rubric criterion. The loop
extended its own rubric at iter 11 (added Spatial Coherence as criterion 11
when CONSULT surfaced that no axis measured spatial structure — proportional
score *dropped* at the time, the right outcome for a measurement instrument
gain).

### Phase 2 — Stress-test (iters 20–26)
49 → 49. Score-flat but epistemically rich. Four directional predictions
were *falsified* (iters 12, 23, 24, 25). External CONSULT failed twice
(iters 10, 20). The loop surfaced and acted on the iter-20 self-pre-mortem
in iter 21 (Eller's zero-length carryover bug, dormant 10 iters). Iter 22
added a CC metric, iter 26 found CC was high-variance at single seed.

### Phase 3 — Cap (iter 27)
49 → 50. Typed GDScript pass; closed C10. The remaining 4-anchors all
require *new mechanisms*, not tuning.

---

## What the loop produced

### Engineering deliverables

| Artifact | What it does | Where to look |
|----------|--------------|---------------|
| `LevelConfig` | 5 weights + merge_probability per terrain | `scripts/LevelConfig.gd` |
| `BiomeConfig` | depth-modulated config interpolation | `scripts/BiomeConfig.gd` |
| `LevelDNA` | seed + config bundle, JSON round-trip | `scripts/LevelDNA.gd` |
| Headless oracle | counts + Eller metrics + tile_hash + vert_persistence + structure_lift + cc_count/max/avg, JSON output | `loop/test_runner.gd` |
| Screencapture oracle | PIL pixel classifier + entropy + diff mode | `tools/analyze_frame.py` |
| `gen_tile.py --from-sheet` | palette extracted from sprite sheet | `tools/gen_tile.py` |
| Eller's bug fix | zero-length carryover → ≥1 carry per set (classical invariant) | `scripts/ProceduralStep.gd:30-36` |
| Make targets | `check`, `test`, `screenshot`, `analyze`, `diff CONFIG=`, `run` | `Makefile` |
| Env var overrides | `TANKE_SEED`, `TANKE_CONFIG`, `TANKE_BIOME` for renderer | `scripts/ProceduralLevel.gd:_ready` |

### Configs (8 named presets)

`default`, `watery`, `fortress`, `balanced_steel`, `balanced_brick`,
`balanced_water`, `balanced_grass`, plus `biome_default_to_watery`,
`biome_balanced`, `biome_interleave`, `biome_gentle`, `biome_test_depth`,
`dna_default_s42`. Each serves as a measurement anchor or comparison point.

### Hash anchors (the loop's invariants)

| Hash | Provenance | Survival count |
|------|------------|----------------|
| `6159ef2f5464edb1` | seed 42 / default / pre-Eller-fix | 4 cosmetic mutations (texture × 3, scene flatten) |
| `1f80435080844dce` | seed 42 / default / post-Eller-fix | 2 cosmetic mutations (CC metric add, typing pass) |
| `8a4834679f9e4eb2` | seed 42 / biome_balanced / post-Eller-fix | tracked from iter 21 |

The hash anchor pattern was the loop's most durable proof that **logic and
presentation are cleanly separated**. Cosmetic changes (texture, scene
structure, type annotations) preserved the hash; logic changes (Eller's bug
fix) intentionally retired it.

---

## What the loop learned about itself

### Discipline that worked

1. **Pre-commit predictions in writing.** Forced epistemic honesty.
   Falsifications became findings instead of embarrassments.
2. **The hash-anchor invariant.** Made it possible to confidently swap
   textures, refactor scenes, and add metrics without breaking measurements
   that span dozens of iters.
3. **Dual-oracle (headless + screencapture).** Two independent signals
   constrain failure modes that one alone misses.
4. **Cited mutation cycles.** Edit one parameter → rerun → cite Δ. Made
   "the agent changed something" verifiable.
5. **Loop edits its own measurement instrument.** Iter 11 (added criterion
   11), iter 13 (added structure_lift), iter 22 (added CC metric), iter 26
   (added metric-reliability table). Each lifted the rubric's honesty.

### Discipline that didn't work

1. **External agentify CONSULT** — failed twice consecutively (iters 10, 20).
   Frozen-tab and reaped-tab. The decision to stop relying on it (iter 21)
   was correct; written self-pre-mortem fills the role.
2. **Predictions about CC behavior** — accuracy 0/4 directional. The metric
   has compound randomness across rows that doesn't yield to intuitive
   parameter modeling. Single-seed CC measurements are unreliable (CV 35%);
   structure_lift is reliable (CV 5%).
3. **Adding parameters before measuring stability.** Iter 22 cited
   single-seed CC values as anchors; iter 26 multi-seed sweep showed those
   were at the *minimum* of the range. Should always do a variance check
   before citing a metric value as a stable anchor.

### Falsifications (4 total)

| Iter | Prediction | Outcome | Lesson |
|------|------------|---------|--------|
| 12 | ↑ merge_probability ⇒ ↑ vert_persistence | slight ↓ | metric was capturing block-floor; iter 13 refined |
| 23 | ↑ contrast ⇒ ↑ s_lift, ↓ cc_max | both worse | strong contrast → stratification, not interleave |
| 24 | ↓ contrast ⇒ ↓ cc_max | got ↑ | CC dominated by p_merge, not contrast (new theory) |
| 25 | ↑ p_merge ⇒ ↑ cc_max monotonically | non-monotone | even isolated p_merge → chaotic CC; theory falsified |

Pattern: directional prediction works on **integrative** metrics
(structure_lift averages over many cells) and fails on **extremal** metrics
(cc_max picks one extreme value sensitive to compound randomness).

### Meta-findings

1. **Iter 21**: written pre-mortems work even when external consults fail.
   The iter-20 self-assessment named "the parked Eller's bug" as item #1;
   iter 21 acted on it and produced a real engine improvement (4% structure_lift
   gain on biome configs).
2. **Iter 26**: metric reliability is not uniform. `structure_lift` is
   single-seed-diagnostic; `cc_max` requires ≥3 seeds. AGENTS.md now has a
   reliability table.

---

## What each remaining 4-criterion actually needs

Score landscape post iter 27:
- 5/5: criteria 1, 3, 4, 7, 10, 11 (six)
- 4/5: criteria 2, 5, 6, 8, 9 (five)

| C# | Name | Anchor 5 | What's needed |
|----|------|----------|---------------|
| 2 | Algorithm variety | non-obvious parameter-interaction analysis | search-style experimentation across param grid; ~5+ iters; would benefit from external math/stats discipline |
| 5 | Tile visual coherence | zero tile bleed across multiple seeds | a *seam-check oracle* — new tooling that flags rendering artifacts at tile boundaries (PIL on screencaptures) |
| 6 | Screencapture oracle | oracle drives loop scoring decisions | automation layer — the loop reads JSON oracle, decides next mutation based on Δ, writes result back into LEDGER. Doable but ~1 substantial iter |
| 8 | Procedural richness | 9 distinct level feelings × 3 seeds × 3 configs documented with playtest | **explicitly user-look required** — automated metrics can score variance, but "feeling distinct" is a human judgment by anchor design |
| 9 | Pipeline completeness | tile generated → imported → live in single iter | a `make new-tile TILE=brick VARIANT=N` target that does gen_tile + import + scene patch + screencap + diff. Mostly bash glue. ~1 iter |

### What user-look would unlock (criteria 8 directly, others indirectly)

The user-look gate has been **open for 8 iterations without movement**.
Anchor 5 of C8 explicitly demands a 5-minute playtest across 3 configs.
Without it, the loop can't honestly claim 5/5 on procedural richness — and
the loop has been measurably honest about this (8 iters of "user-look gate
still open" in STATE.md). 4/5 on C8 is the rubric-correct ceiling
without playtest.

User-look would also implicitly inform C5 (does it *look* coherent?) and
C2 (do the parameter changes *feel* meaningfully different?). These are
soft connections; the hard requirement is C8.

---

## The pivot-vs-halt decision

### The case for halting

1. The rubric has been honestly capped at 50/55 for the no-user-look path.
2. Each remaining anchor needs new mechanisms (4-iter chunks of new tooling)
   or human input. The "easy lifts" are exhausted.
3. The loop has surfaced its own value: **the engine is now agent-mutable
   along contrast × p_merge × biome dimensions, with two independent
   architectural metrics.** Whoever continues the project (iter 28+ or a
   different person) inherits a working measurement framework.
4. Ten falsifications-and-pre-mortems-recorded honestly. The discipline is
   the artifact, not just the score.

### The case for pivoting

1. C9 is one Make target away from 5/5. ~30 minutes of bash. Trivial cap.
2. C5 seam-check oracle is genuinely useful (would catch tile-rendering
   bugs the current oracles miss).
3. C6 automation (loop reads its own JSON, decides) is a substantial
   capability gain — would make the loop *closed-loop*, not just iterating.
4. The user-look gate may close at any time; if it does, C8 → 5 is one
   playtest away.

### Recommendation

**Honest halt. Loop produced what it could without human input.** If the
user runs the playtest at any time, fire `/loop` again and feed back what
they noticed — that's the natural resumption point. Iter 28's deliverable
is *this retrospective itself*, not a 28th metric or config.

If continuation is preferred: iter 29 = C9 → 5 via `make new-tile` (~30 min,
trivial), then iter 30 = C5 seam-check oracle (substantive new tooling).
Both are honest progress without user-look.

---

## What survives past the loop

If the project continues outside this loop's framing, these are the
things worth keeping:

1. **`LevelDNA` + `BiomeConfig` + named presets.** A serializable, mutable,
   reproducible level-recipe system.
2. **The hash-anchor pattern.** A 16-char fingerprint that spans iterations
   and survives cosmetic changes — one-shot regression check.
3. **`structure_lift` metric.** IID-normalized vertical-pair correlation.
   Reliable across seeds; correctly identifies architectural modes
   (interleave vs blob).
4. **`gen_tile.py --from-sheet`.** Palette extraction makes generated tiles
   stay within the analyze classifier's tolerance window.
5. **Eller's invariant fix (≥1 carry per set).** Real algorithmic correctness
   improvement.
6. **The discipline of cited mutation cycles.** Edit one parameter → rerun
   → cite Δ. Generalizes to any procedural-engine tuning.
7. **`AGENTS.md` parameter map.** A future agent or human can read it and
   know which knobs exist, what they do, and how to verify changes.

Things that should not survive without rework:
- `cc_max`/`cc_count`/`cc_avg` as single-seed anchors — multi-seed only.
- The PROMPT.md `_pave_set` modular-arithmetic ghost (iter 0's original
  algorithm) — it was replaced iter 2, but the PROMPT still references it.

---

## Numbers for the record

```
Iters:                      27 (build) + 1 (retro) = 28
Total score:                50/55 (90.9%)
Criteria at 5/5:            6 of 11
Criteria at 4/5:            5 of 11
Falsifications recorded:    4 directional predictions (CC-related)
Re-predictions verified:    1 (iter 14, after iter 12 falsification)
Hash anchors retired:       1 (iter 21, intentional logic fix)
Hash anchors active:        2 (default + biome_balanced post-iter-21)
Configs created:            13 (8 LevelConfig + 5 BiomeConfig)
External CONSULTs:          2 attempted, 2 failed, 0 received
User-look gates fulfilled:  0 of 1 mandatory
Commits:                    28+
LEDGER entries:             27
```
