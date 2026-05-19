# Session learnings — 2026-05-15 → 2026-05-18 (arc 3, iters 0-27)

Cross-arc lessons surfaced during the arc-3 session that aren't yet in the
loop machinery (PROMPT v2, RUBRIC v2). Most actionable for PROMPT v3.

Format per item: **NAME** — *when it fired* — what it is — how to codify.

---

## Loop-engineering learnings (6)

### L1 — Spike-before-build via parallel subagents

**Fired:** iter 23.5 (between iters 23 and 24) — user asked which of 3 harness
extensions to "seriously implement"; I dispatched 3 parallel general-purpose
subagents to investigate each via real POC code + report back.

**What it is:** When deciding among >1 BUILD options of uncertain feasibility,
run parallel spike investigations *before* committing to architect/build.
Each spike does a real POC, returns a SHIP / REFINE / SKIP verdict + effort
estimate.

**Why it worked:** All 3 spike verdicts (SHIP) were confirmed on real
implementation. Without the spikes, iter 24 might have wasted a cycle
discovering Godot's input-synthesis works in headless mode. Spikes
de-risked the 3-iter trio.

**Codification (PROMPT v3):** Add a SPIKE mode to the protocol's MODE table,
between BUILD and CAPABILITY. SPIKE iters cost ~1 wall-clock iter slot but
investigate N≥2 options in parallel; gate the next iter's BUILD on a spike
verdict. Especially useful when:
- Harness extension feasibility unknown (headless input? real-game APIs?)
- Multiple AUDIT-rephrase candidates exist; want to know which yield real cite
- User asks "which of these should I prioritize"

---

### L2 — Compaction-safe blueprint artifacts

**Fired:** User goal directive for iter 24-26 included "you will run into
compaction so allocate smartly and store artifacts if needed." I wrote
`loop/originals/iter024-026-architect.md` (~140 lines) BEFORE executing
iter 24; the file survived through 3 iter cycles without needing reload.

**What it is:** When a multi-iter task is queued, persist the architecture
blueprint to a markdown file in the loop directory. Each iter reads the
blueprint instead of relying on context memory.

**Why it worked:** Compaction never triggered (session was ~700k tokens),
but if it had, the blueprint file would have been the recovery anchor.
Cheaper insurance than expensive recovery.

**Codification (PROMPT v3):** When `/architect` produces a blueprint for
N>1 iters, save it to `loop/<arc>/iter-NNN-MMM-architect.md` automatically.
META-RETRO docs already follow this pattern — extend to multi-iter
blueprints.

---

### L3 — Quality-only iter is a real category

**Fired:** Iters 19, 20, 21, 23 — each shipped substantial code (F002+F003
cures, TitleScreen aesthetic, BC HUD, lives system) but didn't lift the
rubric score. I called them "quality work; no rubric anchor lift."

**What it is:** Code that improves game-craft / user experience / fidelity
without satisfying a specific rubric anchor. The rubric's anchor-set is
finite; not every improvement maps. Score-only loops would pressure-cook
toward score-creep / Goodhart.

**Why it matters:** Without this category, the loop reads quality iters as
"failure to score" or "drifting from rubric." The honest read is that
some valuable work is non-rubric. Calling it "quality" up-front prevents
the false-failure read.

**Codification (RUBRIC):** Either (a) add a C13 "Game polish / craft —
non-anchor improvements that move the build closer to ship-quality" with
anchors like "0/1/2/3+ documented quality iters since last anchor lift,"
OR (b) explicit MODE in PROMPT for `BUILD-QUALITY` distinct from `BUILD`
(which implies anchor target).

I lean (b): MODE distinction is cleaner than gaming a meta-criterion.

---

### L4 — Structural ceiling as a loop state

**Fired:** Iter 27 — recognized that after iter 24-26 trio, all
auto-citable anchors were maxed. Further BUILD iters could only chase
non-rubric quality (drift risk) or re-rephrase rubric (over-AUDIT risk).
Needed a name for this state.

**What it is:** A loop state distinct from "actively iterating" or
"halted" — the loop is *capable of* iteration but no rubric-rewarding
work remains. Pausing for user re-direction is the correct response.

**Why it matters:** Without naming this state, the loop would keep
pulling toward score lifts that don't exist, or do META-RETRO every iter
(both wasteful). Recognizing the state explicitly = correct pause.

**Codification (PROMPT v3):** Add to PROMPT phase list: `loop`, `paused`,
`halted`, `arc-closed`, **`ceiling-paused`** (new). Define: "all
auto-citable anchors satisfied; remaining anchors require user input
(playtest / direction-pick); BUILD iters would drift or over-AUDIT."
Trigger: AUDIT iter finds nothing to lift + no playtest data + no queue
direction-picks in N iters.

---

### L5 — Default-on substrate gating template

**Fired:** Iters 11, 19, 23 — three sanctioned arc-2 substrate writes
(Spawner.gd, PlayerTank.gd, PlayerTank.gd). All used the same template,
all preserved the hash anchor.

**What it is:** Template for cross-arc substrate writes:

```gdscript
@export var <flag_name>: <T> = <OLD_BEHAVIOR_DEFAULT>
# Behavior gated on <flag_name>; when default, code path is bit-identical
# to the prior-arc version. New behavior fires only when the flag is
# explicitly overridden (typically in the new-arc scene's instance config).
```

Plus: hash anchor verification post-edit before commit.

**Why it matters:** PROMPT v1 said "Spawner.gd / PlayerTank.gd will be
EXTENDED for X" but didn't specify the gating discipline. The 3 successful
writes proved the discipline; the discipline (not the file list) is the
actual rule.

**Codification (PROMPT v3):** Replace "only [list] files writable" with
"any cross-arc substrate file writable via default-on gating template +
hash-anchor regression check." Template documented inline.

---

### L6 — AUDIT trigger taxonomy

**Fired:** Iter 8 AUDIT triggered by C5 data-shape mismatch (rubric
anchor wording assumed table-driven roster; actual data is formula-
driven). Iter 24-26 AUDIT triggered by "we now have a structural
surrogate for what was previously playtest-only." Two different
triggers for the same mechanism.

**What it is:**
- **Mismatch AUDIT** — rubric anchor wording doesn't fit actual data
  shape. Iter-8 example: anchor wanted `.tres` per-stage; data is formula.
- **Surrogate AUDIT** — harness gained capability that lets rubric's
  structural-bundled-with-playtest anchor split cleanly. Iter-24-26
  example: 35-chain test + ARC COMPLETE assertion is a structural
  surrogate for C10/5's "full 1-35 + playtest verified" wording.

**Codification (PROMPT v3):** Document both AUDIT triggers explicitly.
Mismatch AUDIT is rare (data-shape understanding usually clears mid-arc);
Surrogate AUDIT happens when harness extension lands. Both rephrase
anchors honestly; neither is score-creep IF the underlying evidence is
real.

---

## Rubric-design learnings (4)

### R1 — Bundled-anchor wording is the rubric's biggest debt

**Pattern:** Anchors like "Stages 1-25 reachable; eagle gameplay
survives the full progression — code-cited" bundle two sub-clauses.
Some anchors bundle structural + playtest: "Full 1-35 reachable +
'win' state when stage 35 cleared; full playthrough verified via
playtest." When the harness can cite one half but not the other, the
anchor becomes un-citable without AUDIT rephrasing.

**Rule for arc-4+ rubric design:** Each anchor should be a single
testable claim. If two conditions need to hold for a score level, make
them separate anchors (5a and 5b) or a separate criterion.

**Concrete proposal:** When writing arc-4 rubric, scan every anchor for
the word "and" or " + " — if both clauses are non-trivially testable,
split them.

---

### R2 — Cognitive anchors need explicit identity-preservation tagging

**Pattern:** C11 anchors 3-5 ("recognizes BC", "names 3+ features",
"says yes that's BC") are cognitive/linguistic acts that resist
structural surrogates. AUDIT-rephrasing them would dilute the rubric's
purpose. They are the "is this actually BC?" identity gate.

**Rule:** Mark certain anchors as **NON-NEGOTIABLE-PLAYTEST** explicitly
in their wording. These exist by design as a check against the loop
gaming itself. Even if the harness gets cleverer, these stay playtest-
only.

**Concrete proposal:** Add a `[IDENTITY-PROTECTED]` tag to anchor rows,
alongside `[STRUCTURE]/[FEEL]/[MIXED]`. Anchors with this tag are
documented as un-AUDIT-able. Iter-8 AUDIT discipline would respect the
tag.

---

### R3 — Rubric ceiling should be at structural+cognitive combined max

**Pattern:** Arc-3 rubric maxes at 60. We hit 51 via structural.
9/60 ungained: 4 cognitive (C11/4-5 + C2/4-5), 2 rubric-capped (C3/4-5),
0 ice anchors recoverable without re-decision. The ceiling is
effectively 56 (51 + 5 cognitive reachable via one playtest), with the
rest gated on design decisions (ice slide-physics).

**Rule:** When designing a rubric, explicitly partition criteria into:
- **Auto-citable** (structural; targetable by harness extension)
- **Cognitive** (irreducibly playtest; one playtest covers them)
- **Capped-by-design-decision** (rubric anchors reflect a design choice
  the arc-3 team locked in; only recoverable via arc-N rebuild)

Then the *effective* ceiling = auto-citable max + cognitive max. The
capped-by-design max is a documented choice, not a missed score.

**Concrete proposal:** Arc-4 rubric should explicitly tag each
criterion's ceiling category. Score reports include "X/Y effective"
not just "X/Z absolute." This is more honest scoring discipline.

---

### R4 — Quality-iter signal needs a place in the rubric

**Pattern:** Iters 19/20/21/23 shipped real work that improves the
build but doesn't satisfy any rubric anchor. The loop's discipline
("score is the signal") incorrectly reads these as drift.

**Rule:** Rubric should have a metric that rewards quality work, even
when no specific anchor lifts. Could be:
- A "Quality streak counter" (number of quality iters since last anchor
  lift) — encourages alternating with anchor-lift iters.
- A meta-criterion like "Game polish: 0 = rough, 5 = ship-ready" with
  anchors based on subjective playtest impression.
- Or just MODE distinction (per L3 above) so quality iters are typed
  separately and don't compete with BUILD-anchor iters on score.

**Concrete proposal:** Add to arc-4 rubric a *Pace criterion*: anchors
based on rhythm rather than feature presence. E.g., "Quality + anchor
work balanced (≥1 quality iter per 3 BUILD iters; ≥1 AUDIT per 5
iters)" — captures process health alongside output.

---

## Next-session actionable list

If user picks "arc 4: <anything>" in next session, these are the
machinery-level improvements that'd help that arc go smoother:

- [ ] **PROMPT v3 draft** — incorporates L1-L6 + R1-R4 above. New
  modes: SPIKE, BUILD-QUALITY. New phase: ceiling-paused. New tag:
  IDENTITY-PROTECTED. Default-on gating template documented.
- [ ] **Per-arc rubric scaffold** — template for arc-4 rubric that
  partitions criteria into auto-citable / cognitive / capped categories
  upfront, with effective-ceiling reporting.
- [ ] **Spike-pattern automation** — when next BUILD iter has uncertain
  feasibility, /architect could auto-recommend SPIKE mode + suggest
  parallel investigation candidates.
- [ ] **Compaction artifact discipline** — `/architect` outputs always
  go to a blueprint file by default; agents reading the loop directory
  always check for recent blueprint files before fresh planning.

None of these are urgent — the existing PROMPT v2 + RUBRIC v2 worked
across 27 iters and produced a 85%-of-rubric ship. These are
incremental improvements for arc-4+ to feel sharper.

---

## Stuff I learned not worth codifying (just session-context)

- Godot 4.6 headless mode fully processes synthesized `InputEventKey`
  events — surprising and useful capability.
- StrategyWiki BC walkthrough has full per-stage roster tables in a
  `Stage K ★★ N Tank-type ...` format — regex-extractable.
- Godot `--write-movie` captures frames per stage cleanly + headless.
- Default-on `@export` flag is the right pattern for arc-extending
  shared substrate files (versus subclass / inheritance / scene
  override). The 3 successful arc-2 writes (Spawner ×1, PlayerTank ×2)
  all used this.
- Pre-tool hooks in this repo catch parse-order errors immediately;
  saved 2 iters from broken commits (iter 11, iter 23).
- The user's iter-10 directive ("loop runs structurally; review at end")
  is the most consequential single loop-shape change in arc-3 — 17
  subsequent iters operated under it.

---

End of session learnings.
