# Breach loop consult ledger (arc 4) — iter 273 per /second-opinion

Every `[FEEL-CONSULT]` cite requires an entry here. The ledger turns adversarial-consult-over-artifact from "model critique" into a falsifiable forecast. Later real playtests SCORE the predictions; repeated misses lower the consult cap, repeated hits may raise it.

**The point:** without prediction + later scoring, `[FEEL-CONSULT]` becomes a fig leaf that lets the loop claim progress on cognitive criteria it can't validate. With the ledger, every consult is accountable.

---

## Entry format

```
## consult-NNN — <one-line topic> — iter <opened> — <archived | open | scored>

- consult_id: NNN
- opened_iter: <n>
- media_hash: <sha256 of artifact sent to /agentify>
- prompt_hash: <sha256 of prompt content>
- agentify_query_key: <key>
- agentify_run_id: <runId>

### Blind read (stage 1 — artifact + anchor wording ONLY, no design intent)
- artifact: <link/path/description>
- 4 blind questions asked: [as written]
- response summary: <2-4 sentences>

### Informed critique (stage 2 — artifact + stated design intent)
- design intent sent: <excerpt>
- response summary: <2-4 sentences>

### Delta (blind vs informed) — the most-valuable signal
- what the blind read SAW that the informed read justified: ...
- what the blind read MISSED that the informed read explained: ...
- where the model's reading DRIFTED on receiving intent: ...

### Concrete recommendations from consult
- [list]

### Player predictions (falsifiable)
- prediction: <claim about what a real player will do/notice/feel>
  expected_observation: <what we'd see in playtest>
  falsified_if: <what would prove this wrong>
- (more predictions...)

### What CANNOT be known from this consult
- [list of non-consultable surfaces — tactile feel, pacing under pressure, etc.]

### Affected anchors
- RUBRIC criterion: <C#>, anchor: <N>, lifted to [FEEL-CONSULT] at score <X>
- (more anchors...)

### Expiration
- max_iters_without_real_playtest: 30 (default; tunable per consult)
- expires_at_iter: <opened_iter + 30>
- expires_on_next_real_playtest: yes (predictions get scored)

### Scoring (filled in by user after playtest)
- iter_scored: <n>
- predictions:
  - prediction 1: hit | partial | miss | untested
  - (more...)
- overall verdict: <how well did consult match reality>
- cap_impact: <raises | lowers | holds>
```

---

## Rules

1. **Two consults ≠ one playtest.** The Nth consult does not stack with the (N−1)th. Each is its own evidence with its own expiration.
2. **A consult cannot lift the same anchor twice without new media OR new evidence.** Re-firing the same consult on the same artifact does not stack lift.
3. **Predictions must be falsifiable.** "The HUD looks clean" is not a prediction. "A first-time player will not notice the breach meter until after their first death" is.
4. **What_cannot_be_known is mandatory.** Every consult must list which surfaces it CAN'T evaluate (tactile feel, retention, pacing under stress, etc.).
5. **Expiry is hard.** Expired consult lifts revert anchors to structural floor until a fresh consult fires OR real playtest scores the prediction.
6. **Calibration is automatic.** When user plays and scores predictions in this ledger, `STATE.consult_calibration` updates: hits/partial/misses tallied; cap eligibility recalculated.

---

## Calibration thresholds

| Tally | Effect on `feel_consult_cap` |
|---|---|
| 0 entries scored | Cap stays at 3 (uncalibrated default) |
| ≥2 hits + hit rate ≥50% | Cap may rise to 4 (calibrated) |
| ≥3 misses in last 5 scored | Cap lowers to 2 OR `[FEEL-CONSULT]` temporarily disabled for affected anchor types |
| Hit rate <30% across ≥5 entries | `[FEEL-CONSULT]` disabled until next user direction |

---

## Open entries (active, awaiting scoring)

## consult-001 — Round 24 Phase A close (5 HUD widgets) — iter 279 — open

- consult_id: 001
- opened_iter: 279
- trigger: stop-hook dice (Nat 2 — "Run /second-opinion before shipping"); also: Phase A close is the first natural punctuation since iter-79 last logged consult (200+ iters overdue per ~every-10 cadence).
- media_hash: n/a (text-only consult; no screenshot — Godot session not running during cron iter; future consults should capture instrumented frame per iter-273 § "Where to source media")
- prompt_hash: n/a (recorded in agentify run page)
- agentify_query_key: tanke-arc4-phase-a-second-opinion
- agentify_run_id: 28d4afe9-3038-4cf7-af0a-96708ec88acb
- agentify_tab_id: c22332a9-4621-4970-a43f-da6f68a2b4b2
- modeIntent: extended-pro (ChatGPT Pro extended thinking)
- fired_at: 2026-05-25 (session iter 279, post-Phase-A-close)

### Blind read (stage 1)

DEVIATION from PROMPT § two-stage protocol: this consult was fired as a SINGLE compound prompt containing 6 hypotheses + 3 permanent questions + 4 specific sharp asks + the 5-widget design surface description. NOT split into blind-read first / informed-critique second. Reason: stop-hook fired post-commit; the loop wanted one consult to cover the Phase A close inflection point rather than two sequential rounds. The delta-blind-vs-informed signal is lost for this entry; future entries should restore the two-stage discipline.

Pending response read (~10-30 min from fire time per Pro extended thinking).

### Informed critique (stage 2)
- Folded into stage 1 above (deviation noted).

### Delta (blind vs informed)
- N/A — single-stage. Mitigation: hypotheses H1-H6 were framed NEUTRALLY (per /second-opinion skill rule — no preloaded conclusions), so the model is invited to challenge each without anchoring.

### Concrete recommendations from consult
- *Pending response.*

### Player predictions (falsifiable)
- *Pending response — explicitly requested as 3 falsifiable predictions in prompt response-format block.*

### What CANNOT be known from this consult
- Tactile feel of the reload bar / shell chips / kill-flash IN MOTION at 60fps
- Whether the player notices the cards ribbon DURING combat (attention budget under pressure)
- Whether 2-letter ribbon labels parse in <5s for a fresh player (cognitive load under stress)
- Whether the bottom-left 3-strip stacking obscures bricks / enemies in tight chokes
- Whether Phase A actually shifts feel toward "Stardew Valley delta" or just makes BC's HUD denser
- Death recap experience post-kill-flash (does shell-tinted burst land emotionally?)

### Affected anchors
- *Pending response — will list which RUBRIC anchors the consult lifts to [FEEL-CONSULT] (cap 3 uncalibrated) OR explicitly cannot lift.*

### Expiration
- max_iters_without_real_playtest: 30 (default)
- expires_at_iter: 309
- expires_on_next_real_playtest: yes

### Scoring (filled in by user after playtest)
- iter_scored: TBD
- predictions:
  - TBD (response not yet read)
- overall verdict: TBD
- cap_impact: TBD

---

## Scored entries (archive)

*None yet.*
