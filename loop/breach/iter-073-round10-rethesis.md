# Round 10 rethesis — written iter 073 (META, post-Consult-008)

Compaction-safe per L2. Supersedes the recommendation in
`loop/breach/iter-072-round10-diagnose.md` (which named enemy roster
expansion as the default Round-10 axis). Consult 008 (GPT Pro
extended thinking, iter 73) reframed the question.

## The reframe

> **"Round 9 solved INPUT POVERTY, not yet DECISION POVERTY."**

Different verbs are not automatically different games. If every
archetype produces the same practical loop (kill / breach / move /
depot), a hostile playtester experiences four control schemes for
the same climb — not four games.

The follow-on:

> Round 10's best thesis is: **every archetype must buy passage
> differently.** Mechanics become identities through characteristic
> mistakes, not through feature lists.

## What this changes vs the iter-072 diagnose

The iter-072 diagnose recommended (a) enemy roster expansion as the
default Round-10 axis. Pro's verdict: directionally plausible but
risks **rubric-chasing** (C5 is lowest score ≠ C5 is highest
leverage). The stronger thesis is **archetype pressure design** —
new enemies are one possible instrument, not the goal.

The "this enemy DEMANDS one archetype" framing is also rejected: it
makes start-pick a pre-run coin flip. The right requirement is:
**"this enemy creates a best answer, costly backup answer, and bad
answer across multiple archetypes."** A threat without options is
matchup tax; a threat with hierarchy of answers is design.

## Round 10 — three-phase build plan

### Phase 1 (iters 74-75) — DISTINCTNESS AUDIT instrumentation

Goal: structurally detect "experientially homogeneous" BEFORE the
playtest. The harness compares per-archetype metrics across the same
seeds:

| Metric                          | Why                                       |
|---------------------------------|-------------------------------------------|
| Median kill distance            | Beam ≠ collide ≠ lob ≠ direct             |
| % time stationary in combat     | PRISM should be much higher than RAM      |
| Wall interaction mode histogram | HE-blast vs beam-burn vs collide vs over  |
| Death reason distribution       | Different archetypes should die different |
| Preferred depot pick histogram  | The "this archetype wants X" signal       |
| Average exposure during fire    | PRISM should be much higher; MORTAR low   |

Build target: `loop/breach/test_breach_distinctness_audit.gd` — a
play-sim harness that runs N seeded auto-play sessions per archetype
and emits the per-archetype metric vector. If two archetypes' vectors
converge within a tolerance, the harness FAILS with a warning that
the playtest will likely report "feels the same."

This is **non-speculative pre-playtest work**: it adds no design
surface; it ADDS A STRUCTURAL EARLY-WARNING for the H4 risk Pro
flagged.

Implementation note: a tiny scripted auto-play is fine — it doesn't
need to be smart; it just needs to be the SAME for all 4 archetypes
on the same seeds so the variance is the signal.

### Phase 2 (iters 76-77) — ARCHETYPE PRESSURE MATRIX (doc + audit)

Goal: catalog which pressure dimensions the EXISTING roster already
exposes per archetype, and which it doesn't. Write
`loop/breach/PRESSURES.md` — a matrix:

```
                  | DEFAULT | PRISM  | MORTAR | RAM
long-LoS threat   |   ?     |   ?    |   ?    |  ?
dense swarm       |   ?     |   ?    |   ?    |  ?
armor (HEAT/APCR) |   ✓     |   ?    |   ?    |  ?
narrow corridors  |   ?     |   ?    |   ?    |  ?
moving targets    |   ?     |   ?    |   ?    |  ?
brick obstruction |   ✓     |   ✓    |   ✓    |  ✓
depot timing      |   ?     |   ?    |   ?    |  ?
```

Fill cells by reading current Spawner.gd + BreachConfig.gd + the
archetype harnesses. Each cell records: best answer / costly backup /
bad answer. Empty cells = pressures the current game doesn't express
→ candidates for Round 11 (NOT Round 10 — Round 10 is detection +
documentation, not content).

This is the **right gate before adding enemies**: it ensures the next
enemy added expresses a pressure the current roster CANNOT, rather
than just "another monster with stats."

### Phase 3 (iter 78) — CURATED PLAYTEST INSTRUMENTATION

Goal: improve playtest verdict quality WITHOUT adding design surface.

- A short structured prompt the user sees on death:
  - "Which moment do you regret most?"
  - "Was your starting archetype the right pick?"
  - "Would switching archetypes have helped?"
- A one-page playtest brief (e.g. `loop/breach/PLAYTEST-5-BRIEF.md`)
  asking the user to do: 1 normal run per archetype + 1 mid-run
  switch run, recording reactions to the four characteristic-mistake
  temptations (PRISM overcommit / MORTAR lazy safety / RAM reckless
  pathing / Default shell waste).

This is the "deferral ≠ passivity" principle in action: the loop
prepares the BEST POSSIBLE PLAYTEST without piling speculative
content ahead of it.

## Round 10 close (iter 79 if all phases land)

- CONSULT 009 — written self-pre-mortem reviewing the distinctness-
  audit results (did metrics converge? if yes, the playtest will
  say "feels same" and Round 11 has to address it; if no, the
  archetypes are structurally distinct and the playtest is more
  likely to validate)
- REVIEW-QUEUE #16 — ★ updated playtest request layered with the
  PLAYTEST-5-BRIEF + the distinctness-audit metric report. The
  playtest gate from REVIEW-QUEUE #14 supersedes/upgrades.
- RUBRIC consideration: C15 anchor 5 may need rephrasing per Consult
  008's first-principles point ("switched archetypes in response to
  pressure" might be equally valid evidence of distinctness). Hold
  the rephrase pending playtest verdict — premature edits to
  identity-protected anchors violate R2.

## What this round does NOT do

- It does **not add new enemies**. Adding enemies before the pressure
  matrix names what's missing = rubric-chasing per Pro.
- It does **not change the archetypes**. They're at the structural
  ceiling; further tuning needs playtest data.
- It does **not import OG enemies**. That's still on the table for
  Round 11 as a SPIKE probe ONLY IF the pressure matrix says we
  need a specific pressure they could express.

## Why this is the right call

Three reasons:

1. **It addresses the actual seductive-but-hollow risk.** The H4
   risk Pro flagged is the dominant uncertainty. The distinctness
   audit lets us DETECT it before the user does — and the right
   response if it triggers is "build wrong-archetype encounters,"
   NOT "add more enemies."

2. **It preserves user direction-setting.** Every prior round was
   user-redirected. Round 10 as INSTRUMENTATION + DOCUMENTATION
   leaves the design surface unchanged — the user playtests, then
   directs Round 11 as either roster expansion, identity/weapon
   clarification, or a third direction we haven't seen.

3. **It exits idle-heartbeat without piling speculative structure.**
   Pro explicitly named the trap: "speculative production after a
   major untested mechanic is exactly how a project accumulates
   systems that look impressive but do not cohere." The
   instrumentation work is non-speculative — it improves our
   verification posture regardless of which Round 11 direction the
   playtest indicates.

## Next-iter handoff

Iter 74 BUILD: write `test_breach_distinctness_audit.gd` (Phase 1
scaffolding). Auto-play sim driving each archetype through a fixed
seed; emit metric vector to JSON; harness asserts pairwise vector
distance > tolerance.
