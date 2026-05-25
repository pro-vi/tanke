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

### Concrete recommendations from consult (response received iter 280)

Bottom line (verbatim): "Phase A was real progress, not fake shipping — but it is now one step away from becoming self-validating HUD work. It solved 'the systems are invisible.' It did not yet solve 'the systems create a modern breach identity.'"

| Hypothesis | Verdict | Confidence | Action |
|---|---|---|---|
| H1: HUD legibility is right Phase A scope | mostly yes | 0.86 | Strengthen acceptance gate: state → decision (not just naming) |
| H2: Procedural V1 acceptable scaffolding | depends | 0.83 | Strong for shell/reload/speed; weak for active cards (labels are debug, not semiotics) |
| H3: 5-BUILD streak was productive same-family | technically yes, strategically suspect | 0.89 | **Stop adding HUD widgets before Phase B. Add HUD pressure test instead.** |
| H4: 16×16 kill-flash sufficient | probably no for attribution | 0.74 | Bump to 24×24 outer ring + 16×16 core, same 0.3s lifetime |
| H5: 2-letter ribbon labels honest | **NO** | 0.95 | **Replace with 3-5 char semantic tokens: RLD/CAP/MOVE/BEAM/RNG/PIER/AOE/RAD/CD/SWNG/COL/SPRT/HP/H+.** Add pickup toast with full name. |
| H6: 3-strip bottom-left stacking acceptable | depends | 0.81 | Visibility classes: always-on combat (HP/reload/shell) / conditional (speed only when buffed) / breath-beat (route + cards fade except low-pressure) |
| Q1: Breach economy distinct from BC? | NOT YET — UI reveals identity, cannot manufacture it | 0.90 | Pre-Phase-B "breach-economy proof room": HE opens loot lane but costs AoE safety; HEAT punches bunker shortcut at armor cost; APCR saves time at escape-ammo cost. Make shells route currency. |
| Q2: Earned breath beats or HUD bloat? | leaning bloat until modal behavior added | 0.80 | Stardew's deeper rhythm is day/energy loop, NOT just legible HUD |
| Q3: Seductive-but-hollow? | "phase can pass screen-reading test while failing play test" | 0.92 | Build diagnostic room + recap metric: kills-by-shell, terrain-opened-by-shell, shells-spent-opening-lanes, cards-affecting-run |
| Reload bar placement | top-left coherent but not optimal alone | 0.84 | Add tank-adjacent 6-10px reload pip; do NOT move whole HUD yet — duplicate critical timing signal near tank |
| Kill-flash drama | slightly louder, not full spectacle | 0.77 | A/B: legacy 16×16 core + 24×24 faint outer shell-color ring, 0.3s fade |
| 2-letter abbreviations parseable? | NO — "BD not parseable after 5s" | 0.95 | Progressive disclosure: short chip + full pickup toast/legend |
| Stardew delta — HUD or pacing? | **PACING/RHYTHM/ECONOMY, not HUD legibility** | 0.87 | Define tanke equivalent of Stardew's day/energy loop BEFORE Phase B: breach budget = limited specials + reload tempo + terrain + route + post-room cards |

### Player predictions (falsifiable)

**Prediction 1** — Shell/reload legibility will PASS; active build legibility will FAIL.
- expected_observation: Fresh player names current shell + reload state within 3s on static screen; CANNOT explain BD/BR/BP/AD/AR/LB/SW/CL/SP during combat without prior teaching.
- falsified_if: ≥80% of fresh testers correctly identify current shell + reload state + meaning of ≥5 active card chips DURING combat without legend.

**Prediction 2** — Top-left reload bar will be read AFTER combat, not USED during combat.
- expected_observation: Players notice reload bar when asked OR when screen is calm; in fights they fire by rhythm / failed input / projectile observation rather than top-left glance.
- falsified_if: Testers visibly delay shots based on the bar during enemy pressure AND can later cite using it to time ≥2 shots per run.

**Prediction 3** — Bottom-left 3-strip stacking will be IGNORED under pressure.
- expected_observation: During combat, players attend to tank position / enemies / bullets / HP / current shell ONLY; route strip + active-card ribbon become post-hoc info.
- falsified_if: Fresh testers make ≥1 route/build/shell decision during combat AND explicitly cite the ribbon or route strip as the reason without prompting.

### What CANNOT be known from this consult
- Tactile feel of the reload bar / shell chips / kill-flash IN MOTION at 60fps
- Whether the player notices the cards ribbon DURING combat (attention budget under pressure)
- Whether 2-letter ribbon labels parse in <5s for a fresh player (cognitive load under stress) — though the consult predicts NO with 0.95 confidence
- Whether the bottom-left 3-strip stacking obscures bricks / enemies in tight chokes
- Whether Phase A actually shifts feel toward "Stardew Valley delta" or just makes BC's HUD denser — though the consult predicts the latter at 0.87 confidence
- Death recap experience post-kill-flash (does shell-tinted burst land emotionally?)

### Affected anchors
- C8 (HUD legibility): could lift to 4 [FEEL-CONSULT] after Phase A widget set complete IF Predictions 1+2+3 are SCORED hits. Per cap=3 uncalibrated → NO lift yet; require real playtest scoring first.
- Other RUBRIC anchors: the consult explicitly says HUD work does NOT lift Q1 (breach economy distinctness) — that lift requires the "breach-economy proof room" work, not Phase A.

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
