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

## Consult 002 — iter 21 — extended-pro via /agentify — fire-and-forget (PENDING)

- Date: 2026-05-19
- Tab status: fire-and-forget — async dispatch confirmed, response pending
- Trigger: ~every-10-iter cadence (last CONSULT iter 6). Round 2 deep
  (25/50; breach economy is a full loop — climb / spend / breach /
  depot / recap).
- Three permanent questions asked? YES (Q1 distinctness, Q2 depots
  earned-beats-vs-restock-menus, Q3 seductive-but-hollow). Prompt
  embedded the honest gaps: depot upgrades all reserve-refill (no
  build-fork), HEAT hollow (2× only, no armor), no playtest.
- Adopted into: TBD — iter 22 reads the response.
- Conversation URL / queryId: `72ec60ef-f236-4454-8f1b-b0338805c99c`
  (tabId: `eda5ebde-138f-4841-876c-943f4f2436e3`, key:
  `tanke-arc4-iter21-consult2`)

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
