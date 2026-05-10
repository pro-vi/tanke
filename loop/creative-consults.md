# tanke — Creative Consult Log

Per CONSULT SCHEDULE (PROMPT.md), iters 10 / 20 / 30. Captures sharp outside-perspective questions and answers. Disagreement with the consultant is allowed and sometimes correct.

---

## Consult 1 — Iter 10 — 2026-05-10

**Mode:** Self-reflective (internal). External agentify consult attempted; blocked by a frozen 12-hour-old query in another session locking the tab pool (`tab_busy` after `max_tabs_reached` resolution). Five stale tabs closed, retry still failed. Logged as infrastructure outage; will retry external consult at iter 20 with the same prompt.

**Pre-staged hypotheses (from iters 6/9 audit observations):**

### H1 — Spatial decorrelation

> The engine has spatial coherence ONLY on the depth axis (via biome interpolation). Within a row, `_pave_set` sees a set as a list of cells and ignores the *shape* they form. The maze topology and the terrain texture don't speak to each other.

**Self-critique:** This is real and worse than I framed. Eller's algorithm produces *connected components* — those components have geometric character (long horizontal runs, single-cell isolates, connected clusters), but `_pave_set` reads only `set.size()` as a feature when picking a terrain. In the original modular-arithmetic version (iter 0), size was at least a gate (steel needed size 2-3, water size ≤6). The weighted refactor (iter 2) *removed* that signal entirely — every set is treated identically regardless of shape. **The refactor was a regression on this axis** and I never noticed because the oracle doesn't measure spatial coherence.

What would architecture look like? At minimum: terrain weights conditioned on set size (small isolates → grass; medium → brick; large → water/open). Better: terrain weights conditioned on the cell pattern (long horizontal run → wall-like brick; cluster → water pool; isolated → grass).

### H2 — Oracle Goodhart

> The "distribution score" is normalized Shannon entropy. Uniform 25/25/25/25 maxes the score while being maximally boring.

**Self-critique:** Confirmed and concrete. The current score peaks at uniform mass distribution. If the loop optimizes against this score (and the rubric encourages it via criterion 8), it'll converge on flat noise. The fix is to add a SECOND oracle that measures *non-uniformity in a structured way* — e.g., spatial autocorrelation (Moran's I), connected-component statistics, or "biome contrast" (avg pairwise terrain distance between top-of-screen and bottom-of-screen). The diff oracle (iter 8) already measures *change* between configs, which is closer to "interestingness" than entropy is. I should retire entropy as a primary scoring axis or rename it "diversity" so its role is honest.

### H3 — Algorithmic depth

> Eller's contribution is cosmetic grouping; the engine is a row-by-row weighted random tile distributor.

**Self-critique:** Half-right. Eller's *does* contribute one real thing: vertical connectivity through carry-overs (the `verts` dict in ProceduralLevel). Without it, every row would be independent, and large brick walls couldn't span multiple rows even at high merge_probability. So Eller's is doing structural work, just narrowly. But H3 stands in spirit: there is no `vertical_merge_probability` parameter; vertical relationships are an emergent side-effect of `cells.shuffle().slice(0, randi() % cells.size())` in `ProceduralStep.generate_step()` — which is essentially "between 0 and N-1 verticals carry forward, uniformly". This is a hidden algorithm choice, not an exposed parameter.

The honest fix: expose `vertical_merge_count_max` (or a probability), and add a "set lifetime" parameter — how many rows can a single set persist via vertical carryovers? Long-lived sets become walls; short-lived sets become rooms. Right now this is an unintended emergent property of slice() randomness.

### Q1 — What's seductive-but-hollow about this engine?

The dual oracle is seductive. Two independent measurements that "agree on direction" feel like robust validation, but they share a critical failure mode: both measure *aggregate distribution*, not *spatial structure*. A level that's 90% concentric rings of brick and a level that's 90% scattered brick noise would score identically on every current oracle. The loop has no way to distinguish architecture from texture, and so its scoring rewards texture changes (which are easy) while staying blind to architecture absences (which are hard).

### Q2 — Is `LevelConfig` agent-friendly, or just a renamed config file?

Currently: it's a renamed config file with a *very* friendly schema. Agent-friendliness has three meaningful tests, and LevelConfig passes one of them:

1. ✓ **Single-edit causes measurable Δ** (iter 7 cited cycle): yes
2. ✗ **Agent can name what it just did**: edit `water_weight` and the agent knows "I made it wetter" only because of the field name. There's no derived label like "swampiness" that captures emergent properties (e.g. fortress.tres has merge_probability=0.7 + steel-dominance, which together produce "rooms" — but no LevelConfig field captures that)
3. ✗ **Agent can search the parameter space**: with 6 fields and continuous ranges, the loop has no "next mutation" heuristic. Iter 7 chose `water_weight` because I (the model) picked it. A real agent loop would need a Bayesian-search-like signal — "which parameter, when nudged, produces the most interesting Δ?"

Honest answer: LevelConfig is *an excellent renamed config file*, with high mutability hygiene. It is not yet a search space.

### Q3 — What would a generative systems researcher find embarrassing about this Eller's implementation?

The shuffle-and-slice random vertical carryover. Eller's classical formulation specifies that *for each set in the row*, you pick *at least one* cell to carry vertically (otherwise the set becomes disconnected from below). This implementation does:

```gdscript
cells.shuffle()
cells = cells.slice(0, randi() % cells.size())
```

Which can produce a slice of length **zero** — meaning a set has *no* vertical connections, leaving it stranded in its row. This is technically a bug: every Eller's-generated maze is supposed to be a single connected component (or have its disconnections rectified in the final row pass). The current impl produces *islands* — pockets of terrain unreachable from the rest of the maze — without ever surfacing that to the player or the oracle.

The researcher would also note: there's no "final row" pass to ensure the bottom of the visible level connects all sets. Real Eller's needs that for solvability.

These together mean the engine is generating *quasi-mazes* — maze-like distributions without the topological invariants. For a tank game where movement is omnidirectional and walls are destructible, this might be fine (or even desirable). But it's worth knowing.

---

## Action items surfaced (priority order)

1. **(High)** Add a *spatial-coherence* oracle to break Goodhart on entropy. Candidates: Moran's I, average connected-component size, "vertical persistence" (how often the same terrain occupies adjacent rows in the same column).
2. **(High)** Condition `_pave_set` on set size or shape. The simplest fix: `LevelConfig.weights_by_size: Dictionary[int, Dictionary]` — weights keyed by set-size bucket. Restores the "small = grass, medium = brick, large = water" intuition that iter 2 dropped.
3. **(Medium)** Expose `vertical_merge_count_max` (or `vertical_carry_probability`) on `LevelConfig` so vertical structure becomes a directly tunable knob.
4. **(Medium)** Audit: is the `randi() % cells.size()` slice producing zero-length carryovers? If so, that's an Eller's invariant violation worth either fixing (always carry ≥1) or making explicit (`allow_islands: bool` on LevelConfig).
5. **(Low)** Rename "distribution" oracle score to "diversity" so its scope is honest, and add a separate "interestingness" axis that's *not* maximized by uniform.

## Loop direction implications

Iters 11+ should target the spatial-structure gap. The temptation is to keep climbing existing 3-criteria (5, 9, 10) toward 4. The deeper issue is that the **rubric itself doesn't measure architecture**, so even maxing every criterion would leave H1/H3 unaddressed. **Iter 11 candidate: add a new criterion to RUBRIC — "Spatial coherence / architecture", initial score 0/5.** The CEILING RULE allows adding criteria when the rubric is too easy; this is *the* moment.

Adding criterion 11 is a meta-move: the loop edits its own measurement instrument. If anchors are honest, this might *drop* the total in the short run (spatial coherence is ~1/5 right now), trading raw score for direction.
