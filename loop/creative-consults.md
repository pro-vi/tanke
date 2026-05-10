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

---

## Consult 2 — Iter 20 — 2026-05-10

**Mode:** External (ChatGPT Pro extended thinking via agentify, fire-and-forget). Tab pool was clear this time. Query key: `consult-iter20-procedural`. Response will be added below when the model finishes.

**Prompt summary:** Refreshed context (iter 19 state, 49/55 score, hash-anchor pattern, 5-criteria-at-5 breakdown). Walked through iter-10 hypotheses → iter-19 outcomes (H1 partially closed via vert_persistence + structure_lift; H2 partially closed via IID normalization; H3 Eller's invariant violation STILL UNTOUCHED). Asked three new H1/H2/H3 specifically about: (1) what's the loop avoiding by leaving H3 parked, (2) is any current criterion rotten, (3) what single thing should iter 21+ tackle that's not currently planned.

**Pending response.** Iter 20 STATE notes "consult fired"; iter 21 will read back and integrate.

**Iter 21 read-back: FAILED.** `agentify_status` for the key returned `tab_not_found` (tab was reaped); `agentify_read_page` returned only the empty-page footer. The query was accepted at iter 20 (queryId returned), but the response was lost — most likely the tab was garbage-collected before completion. This is the second consecutive external CONSULT failure (iter 10 was frozen-tab block).

**Decision: stop trying.** Two consecutive failures of agentify external consult is enough signal that the infra path is unreliable for this session. The loop has been measurably honest with self-consults (the iter-10 self-reflective consult surfaced exactly the H1/H2/H3 the iter-11-19 work resolved, and the iter-20 pre-mortem named the Eller's bug as the parked item). The CONSULT cadence remains valuable — but external models aren't required for it; rigorous self-pre-mortem in writing serves the same epistemic role.

**Action**: iter 21 pivots from "read consult response" to "act on the iter-20 pre-mortem #1 finding (Eller's zero-length carryover bug)". The pre-mortem named what was being avoided; the response arriving or not, that finding stands.

### Iter-19 self-assessment (pending external review)

Three things I expect the model to surface that I'm partly avoiding:

1. **The Eller's zero-length carryover bug (H3 from iter 10).** Has been on the open-issues list for 10 iterations. I haven't touched it because: (a) my oracles don't measure connectivity / solvability, so the bug is invisible to the loop's scoring; (b) the engine ostensibly doesn't need solvability (omnidirectional tank movement, destructible walls). But the bug is generating *quasi-mazes* — terrain distributions without the topological invariants Eller's was supposed to provide. The whole "Eller's algorithm" framing is partly cosmetic right now.

2. **`structure_lift` may be Goodhart-shifted, not Goodhart-eliminated.** Iter 13 normalized against IID; iter 14 verified the metric responds to a fresh prediction. But the metric is still pair-counting, not structure-recognizing. A level with perfectly random terrain placements *AT THE BLOCK LEVEL* could score similarly to a level with biome-driven row coherence, as long as overall pair statistics matched. I've shown structure_lift varies — but I haven't shown it correlates with anything a player would call "architecture."

3. **The user-look gate at iter 20.** I have not run the game and looked at it personally for ~10 iterations. Every score has been derived from automated oracles. Distribution scores 4/5 and 5/5 in the rubric should both *feel different* in 5 minutes of play. I don't actually know if they do.

### User-look gate (pending — iter 20 explicit requirement)

Per `loop/PROMPT.md` USER-LOOK GATES section:
- Run the game across 3 seeds for 5 minutes total
- Name what feels most monotonous about level generation
- Optionally reframe (any reframe → mark affected scores stale in STATE.md)

This is a request to the human pilot — automated scoring can't substitute. The loop will continue iterating in the meantime; user feedback at any time can reframe targets.

**Suggested seeds for the playtest** (chosen for distinct vert_persistence values across 4-config matrix):
- `--seed 42 --config res://configs/default.tres` (structure_lift 2.388×, balanced)
- `--seed 42 --biome res://configs/biome_balanced.tres` (structure_lift 2.522×, balanced + structured)
- `--seed 42 --config res://configs/fortress.tres` (structure_lift 1.529×, steel-dominant + low structure)

These three should *feel* clearly different if the metric is right. They should *all feel monotonous in different ways* if the metric is missing what matters.
