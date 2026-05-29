# Round 5 blueprint — Shell legibility + APCR (playtest-driven)

Written iter 033. Compaction-safe per L2 — each Round-5 BUILD iter reads
this file instead of relying on context memory.

## Origin

User playtested breach mode 2026-05-20 (the REVIEW-QUEUE #3 gate). Verdict:
breach mode does not **read** as breach economy. Five findings:

1. **No shell UI** — shell types are invisible; the user expected an
   on-screen panel showing them.
2. **No tutorial** — nothing explains what the shells do differently.
3. **Illegible shell roles** — "I don't understand when to use HE vs HEAT
   vs AP."
4. **Under-differentiated mechanics** — shells need sharp, distinct
   terrain jobs (HE→walls, something→steel).
5. **"Doesn't feel like a roguelite"** — the deepest note (→ Round 6+).

The /meta's "parity drift" diagnosis is CONFIRMED. 32 iters built the
structure and verified it with harnesses; none of it was made legible.
Round 5 closes findings 1-4. Finding 5 is the Round 6+ program (see tail).

## User design decisions (override the PROMPT — recorded in STATE.md)

- **Q1 → "4 shells, add APCR."** The user explicitly overrides PROMPT
  CONSULT constraint 2 ("no more than three primary shell classes at
  first"). APCR is sanctioned as the 4th shell class. Constraint 3 still
  stands — each shell must keep one crisp, distinct job.
- **Q2 → all four roguelite ingredients** (run-to-run variety, build
  divergence, stakes & escalation, meta-progression). That is the
  Round 6+ mandate.

## The shell grammar (Round 5 target — each shell ONE crisp job)

| Shell | Combat job          | Terrain job            | "Use when…"                      |
|-------|---------------------|------------------------|----------------------------------|
| AP    | cheap, precise      | brick: 1 tile          | default; conserve the others     |
| HE    | blast, multi-hit    | brick: ZONE (wall)     | a brick wall blocks the lane     |
| HEAT  | 2× vs armor (burst) | none                   | an armored Heavy blocks the lane |
| APCR  | pierces armor (1×)  | STEEL: breaches it     | a steel wall blocks the lane     |

APCR vs HEAT must NOT collapse into one shell. The split:
- **HEAT** = the hard-ENEMY answer — 2× damage, single-target burst.
- **APCR** = the hard-TERRAIN answer — the *only* shell that opens steel;
  it also pierces armor but at *normal* (1×) damage.
- Economy framing: HEAT *buys a fast armored kill*; APCR *buys a steel lane*.

Note: HE-zone-blast and HEAT-2×-armor already exist in code (iters 7, 22).
Round 5's mechanical NEW work is APCR + steel. The rest of Round 5 makes
the existing grammar **legible** — that is the whole point of the round.

## Pieces (BUILD iters 34-37)

### iter 34 — BUILD — APCR shell + steel as a band pressure
Investigate first (~15 min): does `ProceduralLevel.gd` place SteelBlock
tiles? Is there a `SteelBlock.gd`? How does HE's brick-zone destruction
work today (`_apply_he_blast`)? Then:
- `Bullet.gd`: `SHELL_CLASS_APCR = 3`; APCR breaches steel; pierces armor
  at 1× damage. Sanctioned substrate write (PROMPT §DEFAULT-ON lists
  Bullet.gd multi-shell support). Default-on gating; hash-anchor verify.
- `Loadout.gd`: `apcr_reserve` / `max_apcr_reserve`; extend
  `can_fire` / `consume` / `refill_*`.
- `PlayerTank.gd`: KEY_TAB cycle extends to 4 shells.
- breach config: the **bunker_zone** band gets a steel wall that gates a
  lane — makes APCR the canonical answer for that band (lifts C5/C4 toward
  the "specific climb problem" bar). Reachability oracle must still pass.
- Harness: `check-breach-apcr` (steel breached by APCR, NOT by AP/HE/HEAT).
- If the procedural generator does NOT place steel today, that becomes
  iter 34's scope — flag it; do not silently skip.

### iter 35 — BUILD — shell UI panel + distinct shell visuals
- `tools/gen_tile.py`: `gen_shell_apcr` icon; all 4 shell icons must pass
  the silhouette-grammar gate (CONSULT constraint 4) before commit.
- `Bullet.gd`: a distinct in-flight visual per shell (shape, not only
  modulate) — the player must SEE which shell they fired.
- `PlayerTank.gd` HUD: replace the text-only `ShellLabel` with a 4-slot
  shell panel — generated icons, current selection highlighted, per-shell
  reserve count. This directly answers playtest finding 1.

### iter 36 — BUILD — shell codex / tutorial layer
Constraint 1 (no combat-time reading): the explanation lives at a safe
gate. Ship a **shell codex** — a one-time intro overlay before band 1
plus a codex section in the depot UI. Each shell: icon + one-line
"use when…" from the grammar table above. Answers findings 2-3.

### iter 37 — CONSULT + QUEUE — close Round 5
- CONSULT: "Do the four shells now read as four distinct *economy*
  choices, or four damage colors?" + the 3 permanent questions.
- QUEUE: append REVIEW-QUEUE #6 — the Round 5 finding.
- Bootstrap Round 6 (roguelite feel).

N is loop-determined; 34-37 is the plan, not a contract. A within-round
falsification or scope signal (≥3 F's) can re-shape it.

## Round 6+ — roguelite feel (finding 5; bootstrapped after Round 5)

The user wants all four ingredients. Likely round sequence:
- **Round 6 — run-to-run variety:** band-order shuffle, depot-offer
  randomization, enemy-mix variation per run. Today every run is the same
  5 bands in the same order — the core "not roguelite" cause.
- **Round 7 — build divergence:** make shell + depot-upgrade combos
  produce sharply different runs; surface the build to the player.
- **Round 8 — stakes & escalation:** depth/score-chase HUD, an escalating
  band-pressure curve, a death→restart loop that frames the run.
- **Round 9 — meta-progression:** between-run unlocks (new shells, alt
  starting loadouts) earned by climbing deep on prior runs.

RUBRIC.md does not yet have criteria for the roguelite axes (run variety,
meta-progression, escalation). Extend the rubric when Round 6 opens —
rubric-is-revisable per PROMPT §RUBRIC IS MEASUREMENT.

## Guardrails carried into every Round-5 iter

- Hash anchor `23d6a2ec3bf2821f` verified on the flag-off codepath after
  any substrate write.
- `make test-breach` + `make test-all` green every BUILD iter.
- Each new asset passes the silhouette-grammar gate before commit.
- A mechanic is not "done" at harness-green — it is done when it is
  **visible, explained, and differentiated** (the F003 lesson).
