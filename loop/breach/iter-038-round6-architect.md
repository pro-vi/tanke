# Round 6 blueprint — Roguelite feel

Written iter 038 (SPIKE). Compaction-safe per L2 — each Round-6 iter
reads this instead of relying on context memory.

## Origin

Round 5 (iters 34-37) made the breach economy LEGIBLE — APCR + steel,
the shell panel, the codex. CONSULT 003 (iter 37) then named the open
risk: **Round 5 made the economy legible but never verified it is
DEEP.** And the iter-33 user playtest's deepest note — "it just doesn't
feel like a roguelite" (playtest finding 5) — is still open. The user
picked all four roguelite ingredients: run-to-run variety, build
divergence, stakes & escalation, meta-progression.

Round 6 builds the roguelite feel. Per CONSULT 003: variety FIRST (it
is also the cheapest scarcity lever — a run you cannot pre-plan forces
real shell-economy decisions); meta-progression LAST and
options-not-power.

## SPIKE — run-to-run variety (the iter-38 investigation)

The user's literal complaint: "every run is the same 5 bands in the
same order." Note the procedural TILE layout already varies per run
(ProceduralLevel rolls a random level_seed). What does NOT vary: band
order, which pressures appear, depot offers, enemy mixes.

Three options investigated:

| Opt | What | Cost | Verdict |
|-----|------|------|---------|
| A | Band-order shuffle — permute the 3 middle bands (maze / bunker / killbox) per run; tutorial_choke stays first, endgame_mixed stays last | Low. One coupling cost: depot next-band previews are static @exports → must become dynamic | **SHIP FIRST (6a)** |
| B | Band-pool draw — define >5 band archetypes, draw + order 5 per run | Med. Each new band needs a reachability-verified config | Sub-round 6b |
| C | Per-run band-parameter variation — roll each band's terrain weights within a tuned range | Med. Every roll must stay reachability-valid → needs a verified per-band range | Later tuning lever |

**Reachability is safe for A**: the oracle (test_breach_harness) is
per-band-LOCAL — "for each band, generate that band's config + flood-
fill". Band ORDER is irrelevant to it; each band stays reachability-
valid wherever it sits in the climb (oracle header lines 9-12).

**Why A first**: it directly fixes the user's literal complaint, is
cheap, and reordering genuinely forces shell-economy re-planning
(bunker-before-maze vs maze-before-bunker changes what you hold HEAT /
APCR for) — variety AS a scarcity lever, exactly CONSULT 003's ask.

## Round 6 sub-round sequence

- **6a — run-to-run variety (band-order shuffle).** iter 39+.
  - ProceduralLevel: at run start, permute the 3 middle BreachBands'
    depth ranges (deterministic from level_seed so a run is
    reproducible). tutorial_choke + endgame_mixed pinned.
  - Depot: next-band preview becomes dynamic — the depot reads the
    level's (shuffled) breach_config to show the real next band.
  - Harness: verify the shuffle produces >=2 distinct orders across
    seeds, all 5 bands still present, reachability holds.
- **6b — deeper variety.** Band-pool draw (option B) + depot-offer
  randomization (each depot draws its 3 choices from the catalog).
- **6c — build divergence.** More depot RULE-CHANGERS (CONSULT 003 Q2:
  the catalog is mostly stock-refills). Shells + upgrades should
  compose into distinct doctrines.
- **6d — stakes & escalation.** Surface the single-life depth chase —
  a depth/score HUD beat, an escalation curve, death->restart framing.
- **6e — meta-progression.** LAST, and options-not-power: between-run
  unlocks of new shells / alt starting loadouts earned by climbing
  deep — never raw +power (power-creep dilutes "what will you spend").

N per sub-round is loop-determined. A within-round falsification or a
>=3-F playtest reshapes the sequence.

## RUBRIC extension proposal (apply at iter 39 DECISION)

The current 10-criterion / 50-pt rubric is breach-economy-focused and
has no criteria for the roguelite axes. Proposed: +3 criteria -> 13
criteria / 65-pt absolute ceiling.

- **C11 — Run-to-run variety.** Structural: band order/pool varies per
  run (code-cited); reachability holds across the variation. Feel:
  playtest — "no two runs felt the same."
- **C12 — Stakes & escalation.** Structural: a surfaced depth/score
  chase + an escalation curve. Feel: playtest — the single life felt
  like it mattered.
- **C13 — Meta-progression.** Structural: between-run unlocks that
  grant OPTIONS not power (a sentence-test analogue — "this unlock
  gives me a new way to climb, not a bigger number"). Feel: playtest.

Build divergence folds into C1 (build identity). Each new criterion
keeps the [STRUCTURE]/[FEEL]/[IDENTITY-PROTECTED] tag discipline.
Reason logged in the RUBRIC revision log.

## Guardrails (every Round-6 iter)

- Hash anchor `23d6a2ec3bf2821f` verified on the flag-off codepath
  after any substrate write.
- Reachability holds across whatever per-run variation is introduced —
  run a multi-seed sweep, not a single seed.
- `make test-breach` + `make test-all` green.
- Meta-progression unlocks OPTIONS, never raw power (the identity
  guardrail — CONSULT 003).
- A mechanic is not done at harness-green — it is done when it changes
  a decision (the F003 + CONSULT-003 lesson; the next playtest asks
  "did you ever agonise over a shell?", not "is it legible?").
