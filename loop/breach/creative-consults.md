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

## Consult 001 — iter 6 — extended-pro via /agentify — fire-and-forget (PENDING)

- Date: 2026-05-19
- Tab status: fire-and-forget — async dispatch confirmed, response pending
- Trigger: round-1 close ("After first end-to-end depot+band+breach-build
  run" per PROMPT trigger list — slightly liberal interpretation since
  the depot isn't yet placed in a BreachLevel scene, but round 1 shipped
  end-to-end schema for all four pieces: flag / BreachConfig / shells /
  depot)
- Three permanent questions asked? YES (Q1 distinctness, Q2 depot-as-
  earned-beat vs menu-grind, Q3 seductive-but-hollow / 6-month-stupid
  omission)
- Self-pre-mortem embedded in prompt: schema-before-mechanic risk
  named explicitly; "structural completion theater" framing offered to
  the model as the brutal lens
- Adopted into: TBD (iter 7 reads response and decides)
- Conversation URL / queryId: `3ae82231-9889-4859-bfea-9ef0b78ae9b4`
  (tabId: `c482361b-ecb9-483c-b74d-fe73445230be`, key:
  `tanke-arc4-iter6-round1-close`)

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
