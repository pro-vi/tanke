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

*None yet — first entry will be created when the loop fires its first iter-273+ adversarial-consult-over-artifact.*

---

## Scored entries (archive)

*None yet.*
