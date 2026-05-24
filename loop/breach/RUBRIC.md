# tanke — Breach Loop Rubric (arc 4, v1)

**15 criteria**, 0–5 scale. **75-point absolute ceiling.** Score above 2 on any
upgrade-related anchor requires the upgrade to pass the sentence test:
*"This upgrade helps me climb through ___ by changing how I use ___."*

**Reachability floor**: criterion 4 (depth bands) caps at 0 if any included
band fails reachability (`playable: false`). Arc-1 carry.

**Hash anchor floor**: any criterion caps at 0 if the cross-arc invariant
`23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` is
broken on the flag-off codepath. Arc-3 carry.

**Tag legend** (carried from arc 2 + arc 3, extended in arc 4):
- `[STRUCTURE]` — code-cited, harness-verifiable
- `[FEEL]` — playtest-cited, irreducibly cognitive
- `[MIXED]` — both required
- `[STRUCTURE-DEFERRED]` — structural cite pending, FEEL not yet attempted
- `[IDENTITY-PROTECTED]` (NEW per R2) — anchor exists as gaming-prevention; **never AUDIT-rephrased**

**Three-tier ceiling reporting** (per R3): every score report includes
"X/Y effective" alongside "X/50 absolute" where effective excludes
identity-protected anchors locked behind playtest until user invokes one.

---

## 1. Breach build identity (0–5) — *feel criterion*

Runs produce nameable build identities, not stat lists. Stone test: after a
5-min run, the player describes the run by zones breached and resources
spent, not by waves survived or buffs collected.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No build state exists (single fixed loadout) | — |
| 1 | Loadout struct exists; player has ≥1 build-axis differentiator (shell-reserve mix, module slot, chassis tag) — code-cited | [STRUCTURE] |
| 2 | ≥3 distinct builds expressible via current systems (AP-heavy / HE-heavy / HEAT-heavy / mixed) — code-cited via the Loadout reserve mix + `RunRecap.build_tag()` enumeration (iter-16 AUDIT: rephrased from "via Loadout.gd permutations" — the build-expression mechanism is shell-usage-derived, not Loadout-permutation-derived) | [STRUCTURE] |
| 3 | Build identity surfaces in run recap (`RunRecap.gd` tags the run with a build name: "bunker cracker," "lane sniper," "rubble plow") — code-cited | [STRUCTURE] |
| 4 | Playtest: user names their build unprompted at end of run ("I was a [X]") | [FEEL] |
| 5 | Playtest: user names ≥2 distinct build identities across consecutive runs, cites the shift unprompted | [FEEL] [IDENTITY-PROTECTED] |

---

## 2. Field depot system (0–5) — *structural+feel*

Depots exist as non-combat safe gates between depth bands; gate all RPG
choice; preview next band; allow resupply.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No depot system; all upgrades mid-combat OR no upgrades | — |
| 1 | Depot entity exists in code (`Depot.gd` / `Depot.tscn`); combat pauses on entry — code-cited | [STRUCTURE] |
| 2 | Depot offers ≥3 meaningful upgrade choices on entry + previews next band's dominant pressure — code-cited | [STRUCTURE] |
| 3 | Depots placed at deterministic intervals (e.g. every band); harness verifies a full run hits ≥3 depots — code-cited | [STRUCTURE] |
| 4 | Playtest: depot dwell <30s; user describes depot choice as preparatory not reactive | [FEEL] |
| 5 | Playtest: user anticipates next depot ("if I survive to depot 3, I can switch to HEAT") — cited unprompted | [FEEL] |

**Anti-pattern explicit**: depot dwell >30s OR depot UI requires reading during pursuit by enemies = automatic 0 on this criterion.

---

## 3. Ammo as logistics (0–5) — *structural*

Three shell classes (AP/HE/HEAT). Each affects both combat AND map traversal.
Swap cost creates pre-commitment under reload pressure. Reserves are
finite per band (until depot resupply).

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | Single bullet type (arc-2 baseline) | — |
| 1 | ≥2 shell types in code; player can fire either — code-cited | [STRUCTURE] |
| 2 | All shell classes (AP/HE/HEAT, + APCR per the iter-33 user override) implemented; each has distinct combat behavior — code-cited | [STRUCTURE] |
| 3 | Each shell has a distinct terrain affordance: AP single-tile, HE brick-zone blast, APCR breaches steel (the only shell that can), HEAT pure combat; HEAT + APCR bypass armor — code-cited via terrain-change verification | [STRUCTURE] |
| 4 | Shell-swap has a reload cost (≥0.5s) — pre-commitment under reload pressure (CONSULT §2 "the interesting WoT idea") — code-cited (iter-26 AUDIT: de-bundled — the original "+ harness measuring per-band shell consumption" clause was R1 bundled debt; per-band consumption needs play-sim and now lives in the [FEEL] tier / C4 anchor 4) | [STRUCTURE] |
| 5 | Playtest: user describes a tradeoff explicitly ("I held HEAT for the bunker band but ran out in mid-floor") | [FEEL] |

**Sentence test gate**: any score above 2 requires citing how shell change affects climb, not just combat damage.

---

## 4. Depth bands (0–5) — *structural*

Map structured into N named bands (target: 5); each has a dominant
terrain/enemy pressure. NOT generic-harder; each band is a specific climb
problem.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No band structure (continuous procedural mush, arc-2 baseline) | — |
| 1 | `BreachConfig.gd` or equivalent encodes ≥2 distinct bands with different terrain weights — code-cited | [STRUCTURE] |
| 2 | ≥3 bands; each has a stated "dominant pressure" in config (e.g. band-1=brick-choke, band-2=heavy-patrol) — code-cited | [STRUCTURE] |
| 3 | 5 bands implemented per `BANDS.md` roadmap; reachability passes on all — harness-cited | [STRUCTURE] |
| 4 | Each band's pressure is *answered* by a different breach approach — avg shell-mix differs per band (iter-26 AUDIT: re-tagged [STRUCTURE]→[FEEL] — "avg shell-mix per band" can only be measured by simulated or real play; it is not harness-citable without a play-AI, so it is honestly playtest-gated) | [FEEL] |
| 5 | Playtest: user names ≥3 bands by their pressure ("the bunker band killed me") unprompted | [FEEL] |

---

## 5. Enemy role vocabulary (0–5) — *structural+feel*

Small readable enemy set (target: 4-5 roles). Each role has a specific
tactical answer. No "harder version of role X" without a distinct silhouette.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | Arc-2 baseline (EnemyLight + EnemyHeavy, 2 roles) | — |
| 1 | ≥3 enemy roles in code; each spawns in correct bands per BreachConfig — code-cited | [STRUCTURE] |
| 2 | Each role has a documented "canonical answer" shell+positioning in `BANDS.md`; harness verifies presence in band rosters — code-cited | [STRUCTURE] |
| 3 | 4-5 roles implemented; silhouette + palette + facing differ — code-cited via gen_tile.py outputs | [STRUCTURE] |
| 4 | Playtest: user differentiates roles by silhouette without reading labels | [FEEL] |
| 5 | Playtest: user cites the canonical answer for ≥3 roles unprompted | [FEEL] [IDENTITY-PROTECTED] |

---

## 6. Death attribution (0–5) — *structural*

Every death produces a recap that names: depth reached, build identity,
resource state at death, killing factor, longest vertical push. NOT "got
overwhelmed."

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No death recap (game-over screen with no info) | — |
| 1 | `RunRecap.gd` captures depth + killing entity — code-cited | [STRUCTURE] |
| 2 | Recap includes shell consumption per type + reserve at death — code-cited | [STRUCTURE] |
| 3 | Recap includes build identity tag (from C1) + dominant pressure of killing band — code-cited | [STRUCTURE] |
| 4 | Recap text reads as actionable diagnosis ("Entered band 3 bunker zone with 0 HE; killed by Heavy") — playtest sample cited | [FEEL] |
| 5 | Playtest: user uses recap to inform next run's loadout choice unprompted | [FEEL] |

---

## 7. Silhouette grammar (0–5) — *structural*

Generated asset pipeline (algorithmic `gen_tile.py` extension) is gated by
a silhouette-readability rule. No asset ships without a silhouette + palette +
facing + one-frame-intent check.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No new assets generated OR assets ship without any check | — |
| 1 | `tools/gen_tile.py` extended with ≥1 new generator (depot tile / shell icon / chassis variant) — code-cited | [STRUCTURE] |
| 2 | Silhouette-grammar check exists in `tools/analyze_frame.py` or sibling tool; outputs PASS/FAIL — code-cited | [STRUCTURE] |
| 3 | All new assets in arc 4 verified via the grammar gate before commit — log artifact in LEDGER | [STRUCTURE] |
| 4 | Playtest: user reads ≥4 of 5 new assets' roles within 2 seconds of viewing | [FEEL] |
| 5 | Playtest: user differentiates new vs existing assets without confusion across a full run | [FEEL] [IDENTITY-PROTECTED] |

---

## 8. Sentence test compliance (0–5) — *structural*

Every upgrade card / module / shell variant must pass:
*"This upgrade helps me climb through ___ by changing how I use ___."*

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No upgrades exist OR all upgrades are passive stat boosts | — |
| 1 | ≥1 upgrade exists and passes sentence test; cited in iter LEDGER | [STRUCTURE] |
| 2 | 5+ upgrades; all pass; sentence cited verbatim per upgrade — `Loadout.gd` documents | [STRUCTURE] |
| 3 | Upgrade catalog covers all 5 depth bands' dominant pressures (≥1 upgrade per band's pressure type) — code-cited | [STRUCTURE] |
| 4 | Playtest: user describes ≥2 upgrade picks via "this lets me X" framing, not "this is +N%" | [FEEL] |
| 5 | Playtest: user rejects an offered upgrade because "it doesn't help me with [pressure]" — cited unprompted | [FEEL] [IDENTITY-PROTECTED] |

---

## 9. Identity / breach-roguelite singularity (0–5) — *feel criterion*

The arc-4 stone heart: "Battle City as a vertical breach roguelite." Captures
whether the game has its own identity distinct from BC-with-extra-steps
(self-pre-mortem critique #1) or roguelite-with-tank-skins.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | Plays as BC clone OR plays as VS / Brotato with tank sprites | — |
| 1 | ≥1 mechanic exists that has no analog in arc 2 (e.g. shell-swap, depot, band structure) — code-cited | [STRUCTURE] |
| 2 | Build identity (C1) + depots (C2) + bands (C4) all functional — code-cited | [STRUCTURE] |
| 3 | A first-time tester opening arc-4 mode describes it differently from "arc-2 ascender" within 60s — playtest cited | [FEEL] |
| 4 | Tester names ≥2 distinct mechanics that distinguish arc 4 from arc 2 — playtest cited | [FEEL] |
| 5 | Tester says some variant of "this is its own thing" unprompted, NOT "BC with cards" or "VS with tanks" — playtest cited | [FEEL] [IDENTITY-PROTECTED] |

---

## 10. Substrate preservation (0–5) — *structural*

The cross-arc invariant. Hash anchor + arc-2 procedural + arc-3 OG mode
all functional through arc-4 work.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | Hash anchor `23d6a2ec…` broken on flag-off codepath OR arc-3 OG mode regressed | — |
| 1 | Hash anchor verified at iter 0 + preserved through ≥3 iters of arc-4 work | [STRUCTURE] |
| 2 | Same + `make test-all` (arc-3 targets) passes through all iters | [STRUCTURE] |
| 3 | Same + arc-2 procedural mode plays identically when `breach_mode_enabled = false` (manual or harness check) | [STRUCTURE] |
| 4 | Same through iter 15+; ≥3 sanctioned substrate writes with default-on gating, all verified | [STRUCTURE] |
| 5 | Cross-arc invariant intact across iter-N+ checkpoint (N ≥ 100); ≥3 sanctioned substrate writes verified across ≥3 distinct files; documented in a `round-NN-summary.md` or checkpoint file. *(iter-119 re-tag — original "arc-4 close" condition became structurally unreachable when PROMPT was amended to make the loop non-stop; substantive cross-arc claim is verified at iter 117 by 67 substrate writes + hash anchor preserved + arc-3 test-all green throughout.)* | [STRUCTURE] |

---

## 11. Run-to-run variety (0–5) — *structural+feel*

No two runs are the same climb. Band order (and later — sub-rounds 6b+
— band pool + depot offers) varies per run, so the player cannot
pre-plan a fixed shell economy: variety forces adaptation (CONSULT 003
— variety is the scarcity lever). Procedural tile layout already varies
per seed; this criterion is about the *band structure*.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | Fixed band order every run (arc-4 iters 0-38 baseline) | — |
| 1 | Band order or pool varies per run — code-cited | [STRUCTURE] |
| 2 | The variation is deterministic from the run seed (a run is reproducible) AND reachability holds across it — multi-seed harness-cited | [STRUCTURE] |
| 3 | ≥3 distinct run-shapes reachable; the depot next-band preview tracks the actual (varied) run — code-cited | [STRUCTURE] |
| 4 | Playtest: the player notices consecutive runs differ, unprompted | [FEEL] |
| 5 | Playtest: the player adapts strategy to the run-shape ("this run front-loaded the bunker, so I held HEAT") — cited unprompted | [FEEL] [IDENTITY-PROTECTED] |

---

## 12. Stakes & escalation (0–5) — *structural+feel*

The single-life run reads as a high-stakes climb. The depth chase is
surfaced; each band transition is an escalation beat; death is
run-framed and invites a retry.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No surfaced run stakes (no depth chase, no run framing) | — |
| 1 | A live depth readout on the HUD — the depth chase is visible — code-cited | [STRUCTURE] |
| 2 | Each band transition surfaces an arrival beat naming the new band + its pressure — code-cited | [STRUCTURE] |
| 3 | The persistent best-depth is surfaced (live + on death) AND death produces a run-framed recap (depth vs best, killing band) inviting a retry — code-cited | [STRUCTURE] |
| 4 | Playtest: the single life feels like it matters — the player pushes for depth, plays carefully near a record | [FEEL] |
| 5 | Playtest: the player chases their best-depth across consecutive runs unprompted | [FEEL] [IDENTITY-PROTECTED] |

---

## 13. Meta-progression (0–5) — *structural+feel*

Climbing deep across runs unlocks OPTIONS — more build paths — not raw
power (CONSULT 003: power-creep dilutes "what will you spend"). The
between-run hook of a roguelite.

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No between-run progression | — |
| 1 | A persistent best-depth-driven unlock system exists (MetaProgress) — code-cited | [STRUCTURE] |
| 2 | Unlocks grant OPTIONS not power — depth thresholds widen the depot upgrade pool, never add a raw stat — code-cited | [STRUCTURE] |
| 3 | The unlock state is surfaced — the player sees what is unlocked + what climbing deeper grants — code-cited | [STRUCTURE] |
| 4 | Playtest: the player climbs partly to unlock — cites it unprompted | [FEEL] |
| 5 | Playtest: the player describes a build enabled by a meta-unlock across runs | [FEEL] [IDENTITY-PROTECTED] |

---

## 14. In-run progression (0–5) — *structural+feel*

The conventional roguelite power curve, added Round 8 by the iter-55
playtest-3 override: the tank grows stronger DURING a run — XP/levels,
a per-phase upgrade pick, mid-combat resupply. This layers ON TOP of
the breach economy; it does not replace it. (Constraint 7 — "verbs not
passive stats" — is relaxed for this criterion per the user override,
STATE §Arc-4 amendments.)

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | No in-run progression — the tank's power is fixed across a run | — |
| 1 | An in-run progression mechanic exists (XP, or a per-phase pick) — code-cited | [STRUCTURE] |
| 2 | XP + level-ups implemented — kills/depth earn XP, level-ups apply automatic stat growth; harness-cited | [STRUCTURE] |
| 3 | The full in-run suite — XP/levels + a pick-1-of-3 at every phase + mid-combat resupply (enemy ammo drops) — all harness-cited | [STRUCTURE] |
| 4 | Playtest: the player feels they grow stronger across a run — cites a level-up or a pick unprompted | [FEEL] |
| 5 | Playtest: the in-run power curve and the breach economy read as ONE game — the player describes a run as both spending shells AND building power, not two bolted-on systems | [FEEL] [IDENTITY-PROTECTED] |

---

## 15. Tank archetypes (0–5) — *structural+feel*

The Round-9 surface added per the iter-62 playtest-4 override: the
"tank that shoots discrete bullets" primitive is one of N archetypes.
Each archetype is a DIFFERENT way to play — not a stat-skinned
default. The Into-the-Breach standard: if a new archetype reduces to
a stat tweak, it shouldn't ship. (CONSULT constraint 7 — "verbs and
affordances, not passive stats" — applies maximally here.)

| Score | Anchor | Tag |
|-------|--------|-----|
| 0 | Single archetype (the original "default tank") | — |
| 1 | ≥2 archetypes in code; each with a verb-differentiated weapon (not just a stat) — code-cited | [STRUCTURE] |
| 2 | ≥3 mechanically distinct archetypes shipped (e.g. discrete bullets + continuous beam + lobbed AoE); each gates on a TankArchetype enum — code-cited | [STRUCTURE] |
| 3 | 4-archetype slate + start-of-run selection screen (MetaProgress-gated unlocks) + mid-run event-unlock switching via a depot upgrade kind — all code-cited via the test_breach_{archetype,prism,mortar,ram,archetype_select,archetype_switch} harnesses | [STRUCTURE] |
| 4 | Visual concept sprites with mechanically-readable silhouettes per archetype (cyan beam-aperture / olive angled-barrel / red plow / default), passing the silhouette grammar gate at the concept tier; integration path queued for user decision — code/asset-cited | [STRUCTURE] |
| 5 | Playtest: the user describes ≥2 runs by ARCHETYPE + VERB ("I had to play this run as a Mortar — picking my impacts"), not by archetype-as-skin ("I picked Prism, then I shot stuff") — cited unprompted | [FEEL] [IDENTITY-PROTECTED] |

**Into-the-Breach gate (anchor 2+)**: a new archetype is rubric-eligible only if a different player INPUT produces a meaningfully different combat loop. Stop-and-fire (PRISM), lobbed parabola (MORTAR), and collision-as-weapon + sprint (RAM) each pass; a "Default + 20% damage" archetype would fail at anchor 2.

---

## Effective ceiling math (per R3)

| Bucket | Criteria | Max | Notes |
|--------|----------|-----|-------|
| Auto-citable (structural) | C2-anchor-3, C3-anchor-4, C4-anchor-4, C6-anchor-3, C7-anchor-3, C8-anchor-3, C10 (all), C11-anchor-3, C12-anchor-3, C13-anchor-3, C14-anchor-3, C15-anchor-4 | ~46 | Reachable without playtest |
| Cognitive (feel-only) | C1-anchor-4-5, C2-anchor-4-5, C3-anchor-5, C4-anchor-5, C5-anchor-4-5, C6-anchor-4-5, C7-anchor-4-5, C8-anchor-4-5, C9-anchor-3-5, C11-anchor-4-5, C12-anchor-4-5, C13-anchor-4-5, C14-anchor-4-5, C15-anchor-5 | ~29 | Requires 1-2 playtests |
| Identity-protected (NEVER AUDIT-rephrased) | C1-anchor-5, C5-anchor-5, C7-anchor-5, C8-anchor-5, C9-anchor-5, C11-anchor-5, C12-anchor-5, C13-anchor-5, C14-anchor-5, C15-anchor-5 | ~9 | Gaming-prevention; playtest-only by design |

**Effective ceiling (auto + cognitive): ~75/75.** Same as absolute since
identity-protected anchors are inside cognitive. Reports use "X/75" with
breakdown. (Round 9 adds C15 "Tank archetypes" — the iter-62
playtest-4 archetype-program surface.)

---

## Acceptance template (per band — referenced by /story-loop verification)

Each band is a user-story:

```
**Band K — user story**

As a player, I can climb through band K of arc-4 breach mode.

Acceptance:
- [ ] Band loads via BreachConfig at depth range [Kmin, Kmax]
- [ ] Reachability oracle reports playable=true on ≥4 of 5 test seeds
- [ ] Dominant pressure (terrain / enemy / pacing) cited in BANDS.md
- [ ] Canonical breach answer (shell + positioning) documented
- [ ] ≥1 upgrade in depot inventory addresses this band's pressure
- [ ] Death recap on death-in-band reports band name + killing factor
- [ ] Hash anchor flag-off check passes

Evidence: LEDGER iter NNN cites results; BANDS.md checkbox flipped.
```

---

## Revision log

| Iter | Change | Reason |
|------|--------|--------|
| 0 | Initial arc-4 rubric, 10 criteria, breach-economy framing | CONSULT §9 seven constraints + self-pre-mortem #1-7 anti-patterns. Three-tier ceiling reporting per R3. IDENTITY-PROTECTED tag per R2. |
| 16 | C1 anchor 2 citation rephrased — "via Loadout.gd permutations" → "via the Loadout reserve mix + RunRecap.build_tag() enumeration" | Mismatch-AUDIT (L6): the build-identity expression mechanism is shell-usage-derived (RunRecap.build_tag enumerates lane sniper / rubble plow / bunker cracker / mixed breacher), not Loadout-permutation-derived. Score unchanged (C1=3); citation made honest. |
| 26 | C3 anchor 4 de-bundled — dropped the "+ harness measuring per-band shell consumption" clause; anchor 4 is now the single swap-cost mechanic | R1 bundled-anchor debt: the anchor fused a structural mechanic (swap reload cost) with a measurement that needs play-sim. De-bundled per R1/L6 — swap-cost stays [STRUCTURE], per-band consumption lives in the [FEEL] tier. |
| 26 | C4 anchor 4 re-tagged [STRUCTURE]→[FEEL] | Mismatch-AUDIT (L6): "avg shell-mix differs per band" is not harness-citable without a play-AI — it is honestly playtest-gated. Re-tag corrects the over-optimistic [STRUCTURE] tag. |
| 34 | C3 anchors 2-3 updated for the 4-shell grammar — anchor 2 names APCR; anchor 3 restated as a per-shell terrain-affordance bar (AP tile / HE zone / APCR steel / HEAT none) | User override (iter-33 playtest) sanctioned APCR as the 4th shell (STATE.md §Arc-4 amendments). Factual correction — the rubric said "3 shells"; no score change (C3's structural tier was already maxed at iter 27). |
| 39 | +C11 "Run-to-run variety" — 11 criteria, 55-pt absolute ceiling | Round 6 (roguelite feel) adds surface the breach-economy rubric never covered (PROMPT §RUBRIC IS MEASUREMENT — "extend RUBRIC.md to cover it"). The iter-38 blueprint proposed +3 (C11/C12/C13); revised to incremental — each roguelite criterion is added when its sub-round opens, so the rubric tracks built work, not speculative surface. C12 (stakes & escalation) lands with sub-round 6d; C13 (meta-progression) with 6e. |
| 42 | +C12 "Stakes & escalation" — 12 criteria, 60-pt absolute ceiling | Round 6d (stakes & escalation) — surfaces the single-life depth chase (band-arrival banner + live best-depth). Per the iter-39 incremental plan, each roguelite criterion lands when its sub-round opens; C13 (meta-progression) lands with sub-round 6e. |
| 45 | +C13 "Meta-progression" — 13 criteria, 65-pt absolute ceiling | Round 6e (meta-progression) — depth-gated depot-pool widening. Completes the iter-39 incremental plan: Round 6's three roguelite axes (C11 variety, C12 stakes, C13 meta) are now all rubric-covered. |
| 60 | +C14 "In-run progression" — 14 criteria, 70-pt absolute ceiling | Round 8 (the iter-55 playtest-3 override) adds a conventional roguelite power curve — XP/levels, per-phase upgrade picks, enemy ammo drops, longer shields — a surface the breach-economy rubric never covered. Per the iter-39 incremental pattern, the criterion is added when its round closes. C14=3 (anchor 3 — the full in-run suite, harness-cited via test_breach_xp / level / depot / ammo); anchors 4-5 playtest-gated. Constraint 7 ("verbs not stats") is relaxed for C14 per the user override (STATE §Arc-4 amendments). |
| 71 | +C15 "Tank archetypes" — 15 criteria, 75-pt absolute ceiling | Round 9 (the iter-62 playtest-4 override) adds the tank-archetype program — 4 mechanically-distinct tanks (Default / Prism / Mortar / Ram) + start-of-run selection + mid-run event-unlock switching via depot upgrade + visual concept sprites. C15=4 (anchor 4 — the structural ceiling: 4-archetype slate + both selection paths + concept sprites passing the silhouette gate, all harness-cited via test_breach_{archetype,prism,mortar,ram,archetype_select,archetype_switch} + iter-70 image-gen output); anchor 5 playtest-gated. Constraint 7 ("verbs not stats") is re-established maximally here — archetypes are pure verb-differentiation. The Into-the-Breach gate (different input → different combat loop) is encoded in the C15 prose. |
| 119 | C10 anchor 5 re-tag — "at arc-4 close" → "iter-N+ checkpoint (N ≥ 100)" | Round 15 Phase 2 BUILD-QUALITY. The original anchor 5 condition ("at arc-4 close") was authored before PROMPT was amended to make the loop EXPLICITLY non-stop (PROMPT §EXPLORATION ROUND CADENCE: "There is no 'arc close.' There is no score-based exit"). The substantive cross-arc-invariant claim is overwhelmingly verified at iter-117 audit (117 iters of arc-4 work; 67 substrate writes across 6 files: PlayerTank.gd ×44, Bullet.gd ×9, Spawner.gd ×5, Enemy.gd ×4, ProceduralLevel.gd ×5, Level.gd ×1; hash anchor 23d6a2ec3bf2821f preserved; all arc-3 test-all targets green throughout; arc-2 procedural bit-identical on flag-off codepath). Re-tag corrects the stale anchor text to match PROMPT's non-stop semantics — NOT rubric-gaming (the substance is overwhelmingly satisfied; the "arc-4 close" gate was structural-blockage caused by an unintended PROMPT-amendment interaction). C10 = 5 absolute. Score: 49 → 50/75 absolute · 49 → 50/75 effective. Full justification: loop/breach/iter-118-round-15-bootstrap.md §Option D. |
