# Breach loop creative consults (arc 4)

Capture every consult, even on tab-timeout status (per arc-4 PROMPT —
arc-4's design CONSULT itself completed despite timeout). The loop reads
the conversation URL before declaring failure.

Default cadence: ~every 10 iters. Trigger conditions also in PROMPT.

Format:

```
## Consult NNN — iter NNN — <mode> — <status: adopted / superseded / failed>
- Date: YYYY-MM-DD
- Tab status: <ok / error-but-completed / reaped / frozen>
- Three permanent questions answered? <yes / partial / no>
- Key reframe (if any): <one-sentence>
- Adopted into: <PROMPT.md | RUBRIC.md | iter-NNN-MMM-architect.md | none>
- Conversation URL / queryId: <stash for recovery>
```

---

## Consult 006 — iter 60 — written self-pre-mortem — Round 8 close

- Date: 2026-05-21
- Tab status: n/a — written self-pre-mortem (the established arc-4 mode;
  cf. CONSULT 003/004/005). Round 8 was a user-directed overhaul; the
  user's hands-on verdict is the creative check and the next gate.
- Three permanent questions answered? YES (+ the Round-8 coherence
  question + the rubric question).
- Key reframe: Round 8 gave the user the conventional roguelite they
  asked for (XP/levels + per-phase picks + ammo drops + longer
  shields). The open risk — flagged at iter 55 — is whether it is ONE
  game or two bolted-on progression systems. Harness-verified to
  EXIST; the playtest decides if it COHERES + FEELS right.
- Adopted into: RUBRIC.md +C14 "in-run progression"; REVIEW-QUEUE #11;
  the iter-60 Round-8 close.

### Round 8 review — did the overhaul land structurally?

Round 8 shipped all four pieces of the iter-55 override: 8a XP +
level-ups (rotated stat boosts, a HUD XP bar); 8b a pick-1-of-3 at
every one of the 4 completable phases (Depot4 added; the panel names
the cleared band); 8c enemy ammo drops (40%, collected mid-combat);
8d longer shields (6s in breach mode + a HUD indicator). All
harness-cited (28 breach harnesses). C14 added to the rubric at 3 —
the structural ceiling.

### Q1 — distinct from BC, or BC with shell colours?

Round 8 changes this answer's SHAPE. Through Round 7 the game was
distinct via the breach economy (shells spent to breach). Round 8
adds a conventional roguelite layer — and conventional is, by
definition, less distinctive. The game is now "a breach roguelite
WITH a standard power curve." Its distinctiveness now rests on the
breach economy staying legible UNDER the new XP/level/loot layer. If
the XP curve dominates the player's attention, the breach economy —
the thing that made it its own game — could recede.

### Q2 — depots earned beats, or menu-grind?

Round 8b made depots MORE frequent (4, one per phase) and reframed
them as "PHASE CLEARED" reward beats. More frequent = more reward
cadence — but also closer to menu-grind if each pick is rote. 4 depot
stops + per-level stat boosts + ammo pickups is a LOT of progression
interaction; it could read as generous, or as busy. Playtest-gated.

### Q3 — what's seductive-but-hollow about Round 8?

The sharp finding. Round 8 was the loop doing what the user asked —
correctly. But the user asked because the breach economy "didn't feel
like a roguelite." The seductive-but-hollow risk: Round 8 bolts the
FAMILIAR roguelite vocabulary (XP, levels, loot) onto the game, and
that will probably "feel like a roguelite" because it literally is the
genre's furniture — but it may not have made the BREACH ECONOMY any
better. Two outcomes the next playtest must separate: (a) "a
satisfying roguelite AND the breach economy still bites" — the win;
(b) "a generic roguelite, the breach economy is wallpaper" — hollow.
The omission that would look stupid in 6 months: shipping a competent
generic roguelite and quietly losing the one idea — breach economy —
that was ever distinctive.

### Q4 — one game, or two bolted-on progression systems?

Structurally there are now TWO progression axes: the breach economy
(spend finite shells to open lanes) and the power curve (XP/levels +
picks). They COEXIST but are not INTEGRATED — a level-up grants +HP
regardless of how you breach; a depot pick is mostly the old catalog.
Nothing yet makes the power curve EXPRESS the breach economy (e.g.
level-ups that change how you SPEND shells). If the playtest wants the
loop to continue, a Round 9 should look at fusing the two — or the
user may be content with two parallel systems.

### Verdict

Round 8 delivered the user's brief in full, harness-verified — 42/70
(RUBRIC +C14). The loop is at the autonomous ceiling again: whether
the overhaul makes the game FEEL like a coherent roguelite is entirely
playtest-gated. REVIEW-QUEUE #11 carries the ask. Per the PROMPT the
loop does not halt for a playtest — but Round 8 is a natural, large
user-look gate, and CONSULT 005's "legibility theater" caution applies
doubly here: do not pile a Round 9 of systems before the user
confirms Round 8 cohered.

## Consult 005 — iter 53 — written self-pre-mortem — Round 7 close

- Date: 2026-05-20
- Tab status: n/a — written self-pre-mortem, in place of an external
  /agentify call. Rationale: same as CONSULT 004 — iter 53 closes
  Round 7 and surfaces the next USER PLAYTEST (REVIEW-QUEUE #9).
  Round 7 was itself a user-directed fix-round; the user's hands-on
  verdict is THE creative check and it is the very next thing.
- Three permanent questions answered? YES (+ a finding-by-finding
  Round-7 review).
- Key reframe: Round 7 shipped a fix for all 5 of playtest-2's
  findings, but 4 of the 5 are [FEEL]/visual/legibility-gated —
  verified to EXIST, not to LAND. F003 is the live risk. The loop is
  back at the autonomous ceiling; the playtest is the gate.
- Adopted into: REVIEW-QUEUE #9; the iter-53 Round-7 close.

### Round 7 finding-by-finding review

- **Finding 1 "shells too few" → 7a (iter 48).** Starter reserves
  5 → 15, caps doubled. The most solidly fixed — a pure quantity
  change; 15 finite shells across a 5-band climb is defensibly "a
  managed handful." Residual: the depot's small refills (+2 HE) now
  read modest against the bigger caps. Confidence: HIGH.
- **Finding 4 "APCR should penetrate steel" → 7b (iter 49).** A
  user-SPECIFIED redesign — the user described the exact verb. 7b
  implements precisely that. Confidence the build matches intent:
  HIGH; the FEEL of drilling a steel tunnel is playtest-gated.
- **Finding 2 "band shuffle illegible" → 7c (iter 50).** A persistent
  route strip + a codex line. F003 RISK — a legibility surface,
  verified to exist not to land. Mitigant: unlike the iter-42 banner,
  the strip is PERSISTENT and across runs the order visibly differs.
  Confidence: MEDIUM.
- **Finding 3 "what can be unlocked?" → 7d (iter 51).** The unlock
  ladder went 2 → 4 rungs + a 4-cell codex display. F003 RISK is
  SHARPEST here — the iter-45 meta line failed in exactly this way
  once already (it IS finding 3). "Clearer than the thing that failed"
  is not "confirmed to land." Confidence: MEDIUM-LOW; the finding most
  likely to recur.
- **Finding 5 "HE needs an explosion" → 7e (iter 52).** A two-layer
  blast bloom. The harness confirms the NODES spawn; the LOOK is
  unverifiable headlessly. Confidence it exists: HIGH; that it looks
  right: playtest-only.

### Q1 — distinct from BC, or BC with shell colours?

No change from CONSULT 004: structurally distinct; felt-distinctness
is the playtest's call. Round 7 retuned the economy's QUANTITY (7a)
and one shell's verb (7b) — it did not touch the core economy's
DEPTH. CONSULT 003/004's question — "does a player ever AGONISE over
a shell?" — is still unanswered.

### Q2 — depots earned beats, or menu-grind?

7d re-tiered the pool (5 core + 4 depth-gated). With 7a's bigger caps
the small refills are now modest top-ups and FULL_RESUPPLY is the
heavy lever. Structurally richer than ever; "earned beat vs menu" is
still playtest-gated.

### Q3 — what's seductive-but-hollow about Round 7?

The sharp finding. Round 7 added four new HUD/legibility surfaces —
the route strip, the unlock-ladder cells, two codex lines, the HE
blast. The risk: **legibility theater.** The loop has now answered
"the player doesn't understand X" with "draw X on screen" three times
(iters 42, 45, then 50/51). If findings 2-3 recur a third time, the
real problem is not communication — it is that band-shuffle and
meta-unlocks may not MATTER enough for the player to care to read
them. A mechanic the player ignores is not illegible; it is
inconsequential. That is the omission that would look stupid in 6
months: HUD-painting around features that don't pull their weight.

### Q4 — did Round 7 fix the 5 findings?

Structurally yes — all 5 have shipped builds, harness-verified. Felt,
unknown for 4 of 5. Round 7 was a user-directed fix-round; the same
user must now confirm the fixes.

### Verdict

The loop is at the autonomous ceiling — the same place as CONSULT
004, with Round 7's fixes layered on. 39/65; the remaining ~26 points
are the [FEEL] tier, playtest-locked by design. The highest-value
next action is unambiguous: a playtest of Round 7 (REVIEW-QUEUE #9).
Per the PROMPT the loop is non-stop and does not halt for playtests;
iter 53 schedules the next wakeup. But there is no structural work
left that is not either playtest-gated or speculative new scope — and
the anti-patterns explicitly forbid piling speculative structure
ahead of a playtest. The honest recommendation: playtest Round 7
before the loop builds further.

## Consult 004 — iter 46 — written self-pre-mortem — Round 6 close

- Date: 2026-05-20
- Tab status: n/a — written self-pre-mortem, in place of an external
  /agentify call. Rationale: iter 46 is the playtest-handoff iter — the
  loop closes Round 6 and surfaces the next USER PLAYTEST (REVIEW-QUEUE
  #7). The user's hands-on verdict is THE creative check and it is the
  very next thing; a frontier CONSULT minutes before it is redundant,
  and its sharp questions are playtest-gated. (CONSULT 003 set this
  written mode; 001/002 were external.)
- Three permanent questions answered? YES (+ a Round-6 question).
- Key reframe: Rounds 5-6 built everything the iter-33 playtest
  mandated + the full roguelite-feel package — but every bit of it is
  [FEEL]-gated for its VALUE. The loop is at the honest autonomous
  ceiling; the playtest is the gate.
- Adopted into: REVIEW-QUEUE #7; the iter-46 honest pause.

### Q1 — distinct from BC, or BC with shell colours?

Structurally: now firmly distinct. 4 shells with sharp terrain+combat
grammar (AP/HE/HEAT/APCR), finite reserves, depots with 4 rule-changers
+ randomised offers, depth bands that shuffle per run, a surfaced
single-life depth chase, depth-gated meta-unlocks. BC has none of it.
The iter-33 "feels the same" verdict predated Rounds 5-6. Whether it
now FEELS distinct is the playtest's call.

### Q2 — depots earned beats, or menu-grind?

Far richer than CONSULT 003's "logistics salad" — randomised 3-of-9
offers, 4 rule-changers (HE / APCR / positioning / swap doctrines), a
dynamic next-band preview, a meta-gated pool. A depot pick can now be
doctrine-defining. Whether it FEELS like an earned beat — playtest.

### Q3 — what's seductive-but-hollow about Rounds 5-6?

The sharp finding, and it is CONSULT 003's Q3 RECURSED. Round 5 made
the economy legible; Round 6 made the run varied, divergent, staked,
and meta-hooked. All of it is genuine, well-built roguelite scaffolding
— and ALL of it decorates a core shell economy whose felt DEPTH the
loop has still never verified. 13 iters of autonomous building since
the iter-33 playtest; none of it could answer CONSULT 003's question —
"does a player ever AGONISE over a shell? is detour-vs-spend a real
dilemma?" The seductive-but-hollow: a beautifully-systemed breach
roguelite whose central loop might still be shallow — and the loop
cannot know without a human. The omission that would look stupid in 6
months: shipping all this structure without one playtest confirming
the economy bites.

### Q4 — does Round 6 make it a roguelite, or roguelite-DECORATED?

Structurally a roguelite (variety / divergence / stakes / meta — the
four ingredients the user named). Felt — playtest-gated. Same answer.

### Implication — the loop is at the honest autonomous ceiling

Rounds 5-6 (iters 34-46) delivered every iter-33 playtest finding plus
the roguelite package. The remaining ~26 rubric points are the [FEEL]
tier — playtest-locked by design. The remaining structural surfaces
are either substrate-blocked (C5's 4th enemy role, iter 28) or
genuinely new scope the user has not asked for — and piling new
structure on 13 iters of playtest-unverified work IS the parity-drift
trap (F003).

So the loop PAUSES here — the iter-32 judgement, now at a far more
complete state (39/65, the full breach roguelite built). The next
playtest must NOT ask "is it legible" (Round 5 settled that) — it must
ask: **did you agonise over a shell? did a run's band-shuffle change
your plan? did you climb deeper to unlock something?** Those three
questions are the whole [FEEL] tier.

## Consult 003 — iter 37 — written self-pre-mortem — Round 5 close

- Date: 2026-05-20
- Tab status: n/a — written self-pre-mortem (arc-1/arc-3 fallback mode),
  fired in place of an external /agentify call. Rationale: the iter-33
  user playtest is Round 5's real creative check (a human played the
  game); it fulfilled CONSULT 002's closing "5-person smoke test"
  recommendation. An external frontier CONSULT now would be redundant,
  and its key question is playtest-gated. An external CONSULT will be
  fired during Round 6 if the loop, running autonomously again, needs
  outside perspective.
- Three permanent questions answered? YES (+ the Round-5 question).
- Key reframe: Round 5 made the breach economy LEGIBLE; it did not
  verify the economy is DEEP. The next playtest must check scarcity,
  not just clarity.
- Adopted into: REVIEW-QUEUE #6; the Round-6 framing in STATE + LEDGER.

### Q1 — Is breach economy distinct from BC, or BC with shell colours?

Structurally distinct — finite reserves, depots, depth bands,
steel-as-APCR-gated terrain, death recaps; a BC clone has none of it.
But the iter-33 playtest verdict was "the game feels the same" — the
structure is distinct, the *felt* experience (as of iter 33) was not.
Round 5 is the bet that legibility closes that gap. The bet is unverified.

### Q2 — Are depots earned breath beats, or menu-grind?

Structurally a breath beat (combat pauses, 3 choices, next-band
preview). But the iter-33 playtest never mentioned depots — positive or
negative. That silence is data: depots did not register. The catalog is
still mostly stock-refills (refill / expand) with only 2 rule-changers.
The user's Round-6 ask for "build divergence" lands here: depots need
more rule-changers — upgrades that change HOW you climb, not how MUCH.

### Q3 — What's seductive-but-hollow about Round 5?

The sharpest finding. Round 5 built a clean dashboard — panel, icons,
codex — for an economy whose actual DECISIONS may be thin. Legibility is
not depth. The omission that would look stupid in 6 months: **the loop
has never verified the economy creates real scarcity.** Do players run
out of shells at tense moments? Is "detour vs spend" ever an agonising
choice? Does a run ever hit steel where breach-vs-detour genuinely
bites? Round 5 polished the *presentation* of the economy without
confirming the economy underneath demands choices. This is F003
recursing one level up: we made the thing legible without confirming
the thing is worth making legible.

### Q4 — Do the 4 shells read as 4 economy choices or 4 damage colours?

Structurally 4 distinct tools (cheap-precise / brick-zone / armor-burst
/ steel). They are 4 economy CHOICES only if (a) the finite three are
genuinely scarce and (b) bands present brick-walls AND armored-heavies
AND steel often enough to want all three. If a run rarely hits steel,
APCR is dead weight the codex still advertises. The icons + codex make
them LOOK like 4 choices; whether they ARE is playtest-gated.

### Round 6 implication

The user picked all four roguelite ingredients. But CONSULT 003 Q3 says:
do NOT open Round 6 with cosmetic roguelite-feel. Round 6 must FIRST
verify + deepen the economy's scarcity and decision-density — otherwise
run-variety / meta-progression just decorate a shallow core. Priority:
  1. Run-to-run variety — band-order shuffle / depot-offer variation.
     The user named this ("every run is the same") — the #1
     not-roguelite cause, and the cheapest scarcity lever (variety
     forces adaptation).
  2. Build divergence — more depot rule-changers (per Q2), so shells +
     upgrades compose into distinct doctrines.
  3. Stakes / escalation — surface the single-life depth chase.
  4. Meta-progression LAST, and carefully — it must unlock OPTIONS
     (new shells, alt loadouts) NOT raw power; power-creep meta dilutes
     the "what will you spend" core that is the whole identity.
The next playtest gate (after Round 6) must ask not "is it legible"
(Round 5 settled that) but "did you ever agonise over a shell?".

## Consult 002 — iter 21 — extended-pro via /agentify — ADOPTED (iter 23)

- Date: 2026-05-19 (fired) / read 2026-05-20 iter 23
- Tab status: response landed on the conversation page (read via
  agentify_read_page). "Thought for 5m 23s".
- Trigger: ~every-10-iter cadence (last CONSULT iter 6).
- Three permanent questions answered? YES — full response captured.
- Conversation / queryId: `72ec60ef-f236-4454-8f1b-b0338805c99c`
  (tabId `eda5ebde-138f-4841-876c-943f4f2436e3`, key
  `tanke-arc4-iter21-consult2`)
- Adopted into: iter 23+ BUILD sequence — the CONSULT's explicit
  "next 3 iters" recommendation.

### Key findings (paraphrased)

**Q1 — distinct?**: "Distinct in kind, but only at the floor. Iter 8
gives the real atomic verb. But if HE is usually replenished / the
right breach is obvious / depots only restore spent resource, it
collapses back to 'BC plus consumable wall bombs.'"
→ **implication**: build one band where the same obstacle has ≥2 valid
solves (spend HE shortcut into danger / conserve HE + longer enemy
route / HEAT through a Heavy-held lane); the recap names the decision.

**Q2 — depots earned or restock menus?**: "Right now, depots are
restock menus. Not stat salad — but logistics salad: refill, cap,
refill, cap, full refill. The player chooses quantity, not doctrine."
→ **implication**: replace one depot entry with a *rule-changer*, not
a stock-changer. Example given: **"Breach Dividend — destroying 4+
bricks with one HE refunds 1 HE, capped once per room/band"** —
preserves the reserve axis but creates a playstyle.

**Q3 — seductive-but-hollow / 6-month-stupid omission?**: "The
stupid-in-6-months omission would be not making HEAT mechanically
real. '2× damage' is a placeholder that survives too long because it
passes harnesses. If HE alters terrain and HEAT merely hurts more,
AP/HE/HEAT is not a triangle — it's AP, bombs, and bigger AP."
→ **implication**: give HEAT one unmistakable anti-armor rule —
"Heavy tanks have frontal mitigation against AP/HE, but HEAT ignores
it." Brutally simple. Player learns: "HE changes the map; HEAT solves
armor."

**Closing — "next 3 iters"**:
> make HEAT real with one armor-facing/bypass rule, then add one depot
> rule-changer that alters shell economics, then run a 5-person smoke
> test asking only whether players describe their run as route
> economy rather than tank combat.

Loop mapping: iter 23 = HEAT armor rule (C3 anchor 3); iter 24 = depot
rule-changer "Breach Dividend"; iter ~25 = surface a PLAYTEST request
to REVIEW-QUEUE (the 5-person smoke test — needs the user).

## Consult 001 — iter 6 — extended-pro via /agentify — ADOPTED (iter 8)

- Date: 2026-05-19
- Tab status: tab reported `error / Response timed out` at ~10:02
  elapsed BUT the response landed on the conversation page anyway —
  the arc-4-documented "tab-status=error ≠ consult-failed" pattern
  reproduced exactly. Read at iter 8 via agentify_read_page.
- Trigger: round-1 close
- Three permanent questions answered? YES — full response captured;
  see conversation `c/6a0cc4a6-f0b0-83e8-bfb1-0ce34be13f5f`
- Self-pre-mortem in prompt: confirmed-and-sharpened by the response
  ("Currently not yet [distinct] — it's BC-plus-typed-shells-in-waiting")
- Adopted into: iter 8 BUILD (Loadout + finite HE/HEAT reserves +
  shell-cycle input). Adopts CONSULT recommendation: "iter 6 would be:
  make HE visibly destroy/open brick lanes in a single depth-band
  choke, then place a two-option depot immediately after that asks the
  player to recover or double down on breach ammo." Iter 7 shipped the
  HE-radius half; iter 8 ships the *commitment cost* (finite reserves)
  half. Iter 9+ ships the 2-choice depot.
- Conversation URL / queryId: `3ae82231-9889-4859-bfea-9ef0b78ae9b4`
  (tabId: `c482361b-ecb9-483c-b74d-fe73445230be`, key:
  `tanke-arc4-iter6-round1-close`)

### Key findings (paraphrased from response)

**Q1 — distinctness**:
> Not yet. Right now it is BC-plus-typed-shells-in-waiting. The
> distinctiveness does not come from "AP/HE/HEAT exist"; it comes when
> the player looks at terrain pressure and thinks, "What am I willing
> to spend to open this lane?" Until shell choice changes route
> topology, time pressure, or enemy exposure, breach economy is still
> conceptual.
**Next-iter implication**: "Wire one lived breach decision, not the
whole shell system."

**Q2 — depot earned vs menu-grind**:
> They become earned only if they appear after the player has paid a
> visible breach cost. A depot after generic movement is a menu. A
> depot after "I spent my last HE to escape a brick killbox" is relief.
**Next-iter implication**: "Two-choice depot whose options are legible
in under five seconds and both answer the last/next breach problem.
Example: 'Restock 2 HE' vs 'Cheaper AP pierce for next band.' No
scrolling, no build tree, no stat salad."

**Q3 — seductive-but-hollow / 6-month stupid omission**:
> The omission that would look stupid in six months is: no player has
> yet sacrificed one resource to alter one route. That is the atomic
> verb. Without it, the rubric can climb while the game remains "tank
> shooter with future systems."
**Next-iter implication**: "Stop expanding schemas for one iter. Force
the first undeniable breach moment into the player's hands."

**Closing line**:
> If I were you, iter 6 would be: make HE visibly destroy/open brick
> lanes in a single depth-band choke, then place a two-option depot
> immediately after that asks the player to recover or double down on
> breach ammo.

## Consult 000 — pre-iter-1 — extended-pro via /agentify — adopted

## Consult 000 — pre-iter-1 — extended-pro via /agentify — adopted

- Date: 2026-05-19
- Tab status: error-but-completed (Agentify reliability gotcha — the
  arc-4 CONSULT is the inaugural documentation of this behavior; full
  response landed despite reported timeout)
- Three permanent questions answered? n/a (this was the *design substrate*
  consult, not the rolling 10-iter cadence consult)
- Key reframe: "breach economy" as the singular identity anchor; the seven
  design constraints (§9); the sentence test (§8); the anchor sentence —
  "The tank is not becoming numerically stronger; it is becoming better at
  buying passage through specific kinds of obstruction."
- Adopted into: `loop/breach/PROMPT.md` (substrate freeze + constraints +
  sentence test + anti-patterns), `loop/breach/RUBRIC.md` (10 criteria
  built around breach economy), `loop/breach/BANDS.md` (5 depth bands).
- Conversation URL / queryId: `e381507c-1928-4baf-ad54-81277c29eadf`
- Source file: `.research/synthesis-arc4-creative-consult-2026-05-19.md`
