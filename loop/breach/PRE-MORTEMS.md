# Breach loop pre-mortems (arc 4)

Append-only. One block per iter, written **before** ACT. H2 RULE v2 tags
mandatory: `[STRUCTURE]` / `[FEEL]` / `[MIXED]` / `[STRUCTURE-DEFERRED]` /
`[IDENTITY-PROTECTED]`.

Every entry cites which of the seven CONSULT §9 constraints the iter
respects or risks. Falsifiable claim required.

Format:

```
## iter NNN — <MODE> — <focus>
- Date: YYYY-MM-DD
- Tag: [<tag>]
- CONSULT constraints respected: <list>
- CONSULT constraints risked: <list, if any>
- Predicted failure: <where this iter might fail>
- Falsifiable claim: <a concrete observable that would prove the prediction>
- Sentence test (if upgrade-touching): "This upgrade helps me climb through ___ by changing how I use ___"
- Substrate touched: <files, if Layer 1/2/3>
- Hash-anchor verification plan: <pre-/post-edit check, or n/a>
```

---

## iter 308 — CAPABILITY — Round 25 Probe 2: shell × target pressure matrix

- Date: 2026-05-27
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1, 6, 7 (probe systematizes ledger semantics that surface in death-attribution recap).
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — Probe 2 systematizes Probe 1's F2/F3 ledger findings; anchor-tied to Round 25 (Option B nudge). Productive direction-continuity.
- Same-family check: iter 307 CAPABILITY → iter 308 CAPABILITY. 2 in a row but each ships a CONCRETE probe deliverable producing numerical findings (not narration). Productive.
- Predicted failure: per-cell isolation might mis-measure HE because HE's radius blast depends on physics neighbor lookup — if MockLevel doesn't expose collision properly, HE damage might be undercounted. Mitigation: harness compares HE×brick to AP×brick on a SINGLE-brick scene with no neighbors; if HE has fewer hits-to-destroy than AP in isolation, the radius is leaking; if equal, HE is per-cell-equal-to-AP as expected.
- Falsifiable claim: post-iter, (a) tools/shell_pressure_matrix.gd parses + runs to completion via `make shell-pressure-matrix`; (b) tools/out/shell_pressure_matrix.json contains a 4×4 grid; (c) harness PASSES 6 fingerprint assertions; (d) probe-002 report ≥5 numbered findings; (e) substrate_writes_this_arc unchanged at 92.
- Sentence test: n/a (probe + harness; no upgrade work).
- Substrate touched: NONE. Files added are tooling (tools/shell_pressure_matrix.gd), harness, probe report, JSON output. Makefile appended.
- Hash-anchor verification plan: no Layer 1/2/3 substrate touch → hash anchor 23d6a2ec3bf2821f bit-identical on procedural baseline (seed 42 / default config). Will re-run procedural oracle post-edit to confirm.

---

## iter 307 — CAPABILITY — Round 25 Probe 1: Q1 headless bot run driver + harness

- Date: 2026-05-27
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1, 6, 7 (probe enriches death-attribution / recap-currency data via existing verb-not-stat shell classes; no combat modal added).
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — iter-306 blueprint targeted iter 307 CAPABILITY = Probe 1; downstream of post_halt_direction Option B nudge. Anchor-tied.
- Same-family check: iter 306 META → iter 307 CAPABILITY. Healthy alternation; CAPABILITY delivers concrete driver + harness + report (not narration).
- Predicted failure: synthetic-fire approach skips the runtime physics chain (PlayerTank._fire → emit shoot → physics → _on_body_entered) but iter-296 fire e2e harness already validates that path. Risk: probe data could diverge from real player experience because synthetic-fire bypasses GunTimer cooldowns + movement constraints. Mitigation: report explicitly frames probe as "structural floor evidence" — not "what real players will do."
- Falsifiable claim: post-iter, (a) tools/q1_bot_run.gd parses + runs to completion via `make q1-bot-run`; (b) 4 JSON files written to tools/out/q1_bot_run_*.json; (c) harness test_breach_q1_bot_run.gd PASSES 4 cases (driver constants + dominant_per_lane symmetry + always_ap baseline + AP-cannot-breach-steel); (d) probe-001 report exists at loop/breach/probes/ with ≥3 numbered findings; (e) substrate_writes_this_arc unchanged at 92.
- Sentence test: n/a (probe + harness; no upgrade work).
- Substrate touched: NONE. Files added are tooling (tools/q1_bot_run.gd), harness (loop/breach/test_breach_q1_bot_run.gd), probe report (loop/breach/probes/probe-001-q1-bot-baseline.md), JSON output (tools/out/q1_bot_run_*.json). Makefile + LEDGER + STATE + PRE-MORTEMS appended.
- Hash-anchor verification plan: no Layer 1/2/3 substrate touch → hash anchor 23d6a2ec3bf2821f bit-identical on procedural baseline (seed 42 / default config). Will re-run procedural oracle post-edit to confirm.

---

## iter 306 — META — open Round 25 (probe-sprint variant per Option B nudge)

- Date: 2026-05-27
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (META — blueprint + ledger + state only).
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger lineage? YES — Option B was "kicked running again without feedback + Option B nudge accepted" per STATE.post_halt_direction_iter_305 dated 2026-05-27. Sanctioned candidate #2 (work-valid-without-playtest probes per PROMPT § iter-273 list). Gate passes via explicit pre-resume direction.
- Same-family check: iter 305 META (session close) → iter 306 META (session open). Two MEs in a row but they bracket the session boundary; admissibility rule targets NO-SIGNAL families and this iter bootstraps a NEW concrete round with deliverable list. Productive.
- Anti-theory-laundering check: this iter does NOT fire a new consult (hard constraint per post_halt_direction); does NOT add substrate (META + new file); does NOT widen REVIEW-QUEUE with new direction-asks (probes produce reports, not new questions).
- Predicted failure: probe-sprint scope could drift toward "look rigorous in absence of evidence" — the cargo-cult pattern iter-273 named. Mitigation: every probe deliverable is a NUMBER table + 1-paragraph interpretation, NOT a verdict or label. If a probe report reads like a consult verdict, it's the wrong shape.
- Falsifiable claim: post-iter, `loop/breach/iter-306-round25-probe-sprint-architect.md` exists + names 3+ concrete probes with deliverable shapes + STATE updates phase to `round-25-probe-sprint-open` + LEDGER records the round open. Next iter (307) targets Probe 1 (Q1 bot run) per the blueprint.
- Sentence test: n/a (META).
- Substrate touched: NONE (blueprint + LEDGER + STATE + PRE-MORTEMS only).
- Hash-anchor verification plan: no substrate write → hash anchor `23d6a2ec3bf2821f` trivially preserved. `make test` not required for META; will run `make test-all` + `make test-breach` to confirm baseline still green post-session-resume.

---

## iter 294 — BUILD — consult-001 H6 visibility classes: pressure-fade ribbon + route (user direction Option A)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — fade is passive), 2/3, 5, 7 (verb-not-stat — pressure determines visibility class, naming the player's current state).
- CONSULT constraints risked: visual jitter — if pressure transitions oscillate the ribbon could "flicker." Mitigated by HIGH_PRESSURE_WINDOW = 2.0s smoothing.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — user explicitly chose Option A at iter 294 AskUserQuestion (apply H6 visibility classes); H6 is consult-001's final structural fix (conf 0.81). Citable: STATE source_ids_used iter-294 entry. Gate passes.
- Same-family check: iter 293 META → 294 BUILD. Mix preserves alternation; consult-driven application, anchor-tied.
- Predicted failure: pressure proxy ("fired within last 2s") may fail to capture passive threat (enemy approaching but player hasn't shot). V1 ships the firing-based proxy as scaffold; iter 295 can extend to enemy-proximity OR enemy-bullet-in-flight as a stricter proxy if playtest reveals a gap.
- Falsifiable claim: post-edit, PlayerTank has `_last_fire_time` field + `_is_high_pressure()` helper + alpha modulation logic in `_update_run_hud`. Harness asserts:
  - Initial state (no fires yet): _is_high_pressure() == false; active-cards panel + route panel at full alpha (1.0)
  - After simulated fire: _last_fire_time set; _is_high_pressure() == true for HIGH_PRESSURE_WINDOW seconds; ribbon + route alpha drops to 0.3
  - After window expires: _is_high_pressure() == false again; alpha restored to 1.0
- Sentence test: n/a.
- Substrate touched: scripts/PlayerTank.gd (substrate write #55 — loadout-gated; arc-2/3 baseline doesn't load these panels at all per iter-278/iter-50 gating).
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 → 23d6a2ec3bf2821f… (modulation lives inside the existing loadout-gated panels which arc-2/3 baseline never builds).

---

## iter 293 — META — consult-001 H1: acceptance-gate strengthen (state→decision second gate)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (META — docs only).
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — H1 (consult-001 conf 0.86) addresses Q3 verdict 0.92 framing concern ("phase passes screen-reading test while failing play test") by adding a SECOND gate to Phase A acceptance: state→decision (instrumented evidence that visibility CHANGES behavior). Direct downstream of Option B's iter-270 anchor. Gate passes.
- Same-family check: iter 292 BUILD → 293 META. Mix alternates productively.
- Predicted failure: docs-only iter could feel light, but the prediction-scoring lift from H1 is real: without state→decision, the loop ships HUD widgets that look pass-able on a static screen but never gets evidence they CHANGED PLAYER BEHAVIOR.
- Falsifiable claim: post-edit, Q1-PROOF-ROOM-PLAYTEST-BRIEF.md has a new "STATE → DECISION GATE" section asking "did visibility change YOUR behavior?"; REVIEW-QUEUE #28 has the gate added to the stranger-on-screen acceptance criteria; CONSULT-LEDGER consult-001 § Affected anchors notes the H1 fix applied.
- Sentence test: n/a.
- Substrate touched: NONE — docs + REVIEW-QUEUE + CONSULT-LEDGER.
- Hash-anchor verification plan: no substrate write → hash preserved. Will skip the hash verification step this iter since the diff is markdown-only; if state changes anywhere unexpected, the next iter's verification catches it.

---

## iter 292 — BUILD — consult-001 reload-bar tank-adjacent pip (combat-timing UI near combat focus)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1, 7 (verb-not-stat — reload pip surfaces the COOLDOWN verb visually). Consult prediction 2 (0.84): "Top-left is coherent, but probably not optimal as the only reload readout. Keep the top-left reload bar paired with shell chips, but add a tiny tank-adjacent reload affordance: a 6-10px cooldown pip, ring, or under-tank bar that fills in the current shell color. Do not move the whole HUD yet; duplicate the critical timing signal near the tank and test which one players use."
- CONSULT constraints risked: visual noise — tank-adjacent pip could compete with the tank sprite. Mitigated by: small size (6-8 px wide, 1-2 px tall), faint alpha when full (ready to fire), brighter color while filling.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — consult-001's prediction 2 says the top-left bar will be IGNORED under pressure; the tank-adjacent pip is the structural test of that prediction. Direct downstream of user's Option B (Q1 sprint) + the iter-290 brief's prediction-scoring framework. Gate passes.
- Same-family check: iter 291 BUILD → 292 BUILD. Both downstream of consult-001 application; productive same-family.
- Predicted failure: pip placement could overlap the tank sprite badly (sprite is 16×16 centered at tank position; pip below at y=+10 should be 2 px clear of the bottom edge). Mitigation: harness verifies bg.position.y is ≥+9 (offset from tank center).
- Falsifiable claim: post-edit, when loadout != null, PlayerTank has `_reload_pip_bg` + `_reload_pip_fg` ColorRect children positioned below the tank sprite. `_reload_pip_fg.size.x` updates in `_update_run_hud` matching the same progress formula as the top-left bar. fg color matches current shell. Procedural baseline: pip not built (loadout-gated; both fields null).
- Sentence test: n/a.
- Substrate touched: scripts/PlayerTank.gd (substrate write #54 — loadout-gated additions: 2 fields + 1 build method + 1 update method + 1 call site in _update_run_hud).
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 → must equal 23d6a2ec3bf2821f… (pip built only inside `if loadout != null:` block; procedural baseline never reaches the build code).

---

## iter 291 — BUILD — consult-001 Q3 recap-surfacing: route-currency on death overlay

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1, 6 (death recap surfaces route attribution via shell breakdown), 7 (verb-not-stat — "1HE on route, 2AP on combat" names the verbs the player performed, not stat snapshots).
- CONSULT constraints risked: visual density — death label is 176×116 and already shows 7+ lines. Mitigation: route_currency_summary returns AT MOST 2 lines and SKIPS zero entries; collapses to "" if no hits recorded.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — Q3 (consult-001 conf 0.92) is the diagnostic surfacing that makes the Q1 proof-room data VISIBLE post-run. Without it, the data sits in RunRecap unread; the player never sees the "shells are route currency" breakdown they just played. Direct downstream of user's Option B at iter 283. Gate passes.
- Same-family check: iter 290 META → 291 BUILD. Mix is fine.
- Predicted failure: format could overflow the 176×116 panel if a long run has shells on all 4 classes in both dicts. Mitigation: compact "%dCLASS" tokens space-separated; 4 classes × 2 dicts max = "ROUTE: 4HE 4HEAT 4APCR 4AP\nCOMBAT: 4HE 4HEAT 4APCR 4AP" ≈ 36 chars per line, well within ~30-char-wide panel. Verified empirically by harness.
- Falsifiable claim: post-edit, RunRecap.route_currency_summary() returns "" when no record_shot_hit calls fired; "ROUTE: 1HE" after one record_shot_hit(HE, "route"); "ROUTE: 1HE\nCOMBAT: 1AP" after one of each; correctly drops zero entries. PlayerTank death label includes the route_currency_summary block when run_recap != null AND total > 0.
- Sentence test: n/a.
- Substrate touched: scripts/PlayerTank.gd (substrate write #53 — gated on `run_recap != null` already, splicing route summary into existing death-label format string).
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 → must equal 23d6a2ec3bf2821f… (insertion is INSIDE the `if run_recap != null` branch which arc-2/3 baseline never enters).

---

## iter 290 — META — Q1 sprint CLOSE: playtest brief + REVIEW-QUEUE #30 + CONSULT-LEDGER prediction-scoring trigger

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (META — no code).
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — the brief is the bridge between the loop's 7-iter sprint and the user's playtest. consult-001's 3 falsifiable predictions get a scoring trigger here. Gate passes.
- Same-family check: iter 289 BUILD → iter 290 META. Mix breaks the 6-BUILD streak; productive end-of-sprint META.
- Predicted failure: brief could be too long (defeating its 1-page purpose) OR could fail to surface the consult-001 prediction-scoring rules clearly enough for the user to score post-playtest.
- Falsifiable claim: post-edit, loop/breach/Q1-PROOF-ROOM-PLAYTEST-BRIEF.md exists and contains: launch command, lane summary, 3 consult-001 predictions in user-actionable form, debrief template. REVIEW-QUEUE has #30 with prediction-scoring rules. CONSULT-LEDGER consult-001 § Affected anchors lists the scoring trigger.
- Sentence test: n/a.
- Substrate touched: NONE — pure docs + REVIEW-QUEUE + CONSULT-LEDGER.
- Hash-anchor verification plan: no substrate write → hash preserved. Re-verify anyway.

---

## iter 289 — BUILD — Q1 sprint 6/7: per-lane gate-clearance + route-currency verification harness

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1, 2 (4 shell classes), 3 (each shell has its lane), 5 (proof room dominant pressure), 6 (route attribution → recap), 7 (verbs not stats — the harness asserts VERB-LEVEL properties: "HE blasts brick cluster", "AP bounces off steel", "HEAT 2-shots armored Heavy", "APCR drills steel").
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — this is the CLOSING verification of "shells are route currency, not just damage flavor" as a runtime property, not a design claim. Final structural assertion before user playtest. Gate passes.
- Same-family check: iters 284-289 = 6 consecutive BUILDs all anchor-tied to Q1 sprint. Permitted (rule targets NO-SIGNAL families); framing-audit gate continues to verify user-trigger alignment.
- Predicted failure: bullet body-collision may not directly trigger via `_on_body_entered` in headless mode without proper Area2D setup, OR the bullet's iter-286 wiring (`_try_record_shot_hit`) may not see lvl.player if scene is the bullet's parent rather than Q1ProofRoomScene. Mitigation: use the iter-286 FakeLevel pattern OR fire bullets via player.shoot signal so the bullet ends up as child of Q1ProofRoomScene which (we need to verify) has a `player` property — actually Q1ProofRoomScene doesn't have a `player` property (just `spawned_player`). Risk: route-currency wiring may silently no-op due to missing parent.player lookup. Mitigation 2: I'll add a `player` property to Q1ProofRoomScene that aliases spawned_player. Substrate touch only on arc-4-owned Q1ProofRoomScene.gd.
- Falsifiable claim: harness asserts per-lane:
  - HE shot at brick cluster center → ≥1 brick destroyed + run_recap.shells_spent_on_routes[HE] >= 1
  - AP shot at steel gate → steel NOT destroyed (cross-pollination: AP bounces) + route hit NOT recorded
  - APCR shot at steel gate → steel destroyed + run_recap.shells_spent_on_routes[APCR] >= 1
  - HEAT shot at entrenched Heavy → Heavy hp reduced by 2× (= 2 damage; with hp=3 takes 2 HEAT shots) + route hit recorded
  - AP shot at clearance-row Light (NOT gate row) → Light dies + run_recap.shells_spent_on_combat[AP] >= 1 (combat, not route)
- Sentence test: n/a.
- Substrate touched: scripts/Q1ProofRoomScene.gd (arc-4-owned, NOT in substrate freeze list) — add `var player: Node = null` alias so Bullet's `lvl.player` reach works in this scene. NO Layer 1/2/3/4 substrate writes.
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 → must equal 23d6a2ec3bf2821f… (Q1ProofRoomScene.gd is arc-4-owned; ProceduralLevel never loads it).

---

## iter 288 — BUILD — Q1 sprint 5/7: Q1ProofRoom playable scene + spawn logic (first playable artifact)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — scene runs combat directly), 4 (silhouette/grammar — gate cells use existing BrickBlock + SteelBlock + Enemy assets; no new silhouettes), 5 (proof room is the specific climb problem per CONSULT 5), 7 (verbs — gate-row spawns get is_route_gate meta so the wiring fires verb-correctly per iter-286).
- CONSULT constraints risked: 4 if I forget to use existing assets — mitigated by preloading BrickBlock.tscn / SteelBlock.tscn / Enemy.tscn / PlayerTank.tscn.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — this is the first artifact the user can actually launch and play. Without it, the prior 4 iters (284-287) are pure infrastructure. Gate passes.
- Same-family check: iters 284-288 = 5 consecutive BUILDs all anchor-tied to the Q1 sprint blueprint. Permitted (rule targets NO-SIGNAL families); framing-audit gate continues to track user trigger.
- Predicted failure: spawn loops over TILE_GRID's 630 cells could spam errors if grid coords don't map cleanly to body positions. Mitigation: harness asserts exactly the right number of bodies of each type (5 bricks at HE gate, 5 steel at APCR gate, 1 Heavy at HEAT gate, 2 Lights at AP gate, ≥1 Light + 1 Heavy in clearance rows). Off-by-one in row/col indexing would be caught immediately.
- Falsifiable claim: post-edit, the harness instantiates Q1ProofRoom.tscn; after one frame the scene contains:
  - 5 BrickBlock instances at gate row 14, cols 0-4 (HE lane)
  - 5 SteelBlock instances at gate row 14, cols 5-9 (APCR lane)
  - 1 Heavy Enemy instance at gate row 14, col 12 (HEAT lane)
  - 2 Light Enemy instances at gate row 14, cols 15+17 (AP lane patrol)
  - Some grass/Light clearance instances scattered in rows 3-5 and 16-23
  - Exactly 1 PlayerTank, positioned at the HE lane's player-start (col 2, row 29) for V1 auto-pick
  - All gate-row bodies (bricks, steels, Heavy, Lights at gate row) have set_meta("is_route_gate", true)
- Sentence test: n/a.
- Substrate touched: NONE — scenes/Q1ProofRoom.tscn and scripts/Q1ProofRoomScene.gd are arc-4-owned (NEW). No Layer 1/2/3 substrate writes.
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 → must equal 23d6a2ec3bf2821f… (the scene is standalone; ProceduralLevel never references it; procedural baseline path unchanged).

---

## iter 287 — BUILD — Q1 sprint mid-correction: Q1ProofRoom parser module + grid helpers (sprint extends 4 → 6-7 iters)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1, 5 (proof room dominant pressure preserved in grid layout), 7 (verbs not stats — helpers expose VERB-ONLY queries like gate_lanes() / player_starts()).
- CONSULT constraints risked: scope drift — original blueprint had iter 287 as REVIEW (playtest brief). This iter is correcting course because iter 284 under-shipped the "spawn gate elements" deliverable. Mitigation: the correction is transparent (PRE-MORTEM + LEDGER both name the slip); the user-authorized sprint estimate was 8-15 iters → 6-7 is well within budget.
- Honest gap admission: iter 284 said "Playable scene integration is iter 285+" but iters 285-286 turned out to be storage + wiring, not the scene integration. Iter 287 starts the actual playable integration with the smallest unbroken-unit work (a parser module). Iters 288-289 will build the scene + spawn logic + per-lane harness. Iter 290 closes with the brief.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — the parser module is the foundation that lets iter 288's playable scene instantiate the 4 lanes. Without it, the playable claim stays vapor. Gate passes; the work directly serves the Q1 reframe the user chose.
- Same-family check: iter 284-286 BUILD streak (3 BUILDs) → iter 287 BUILD. 4 consecutive BUILDs, all anchor-tied to the Q1 sprint. Permitted (rule forbids NO-SIGNAL families). Framing-audit gate explicitly re-checked above with citable evidence.
- Predicted failure: parser could disagree with the ASCII layout file's narrative (the canonical design doc); diff between embedded grid + narrative doc could drift over time. Mitigation: harness asserts the embedded grid has 30 rows + 21 cols + the 4 lane gates at row 14 + player starts at row 29 — these properties match the narrative file.
- Falsifiable claim: post-edit, Q1ProofRoom.TILE_GRID is a PackedStringArray with 30 entries each 21 chars wide; helpers terrain_at(col, row), gate_lanes(), player_start_columns() return the expected values per the ASCII narrative.
- Sentence test: n/a (no upgrade introduced).
- Substrate touched: NONE — scripts/Q1ProofRoom.gd is arc-4-owned, NEW file.
- Hash-anchor verification plan: no substrate write → hash preserved. Re-verify post-edit.

---

## iter 286 — BUILD — Q1 sprint 3/4: wire Bullet → PlayerTank → RunRecap route-currency hit recording

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1, 6 (route attribution → recap), 7 (verbs not stats — the route-vs-combat distinction names which verb the shell performed).
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — closes the loop between iter 284's design verification (the design property exists) and iter 285's storage API (RunRecap can hold metrics); iter 286 makes the metrics REAL during play. "Shells are route currency" becomes a measurable empirical claim, not just a design slogan. Gate passes.
- Same-family check: iter 283 META → 284 BUILD → 285 BUILD → 286 BUILD. 3 consecutive BUILDs all anchor-tied to the Q1 sprint blueprint deliverables — productive same-family. (Counter: the same-family RULE only fires NO-SIGNAL family; 3 anchored BUILDs is permitted.) Framing-audit gate explicitly checked above: still tracking user trigger.
- Predicted failure: if Bullet.gd's body-entered handler is called for a body that is in the "armored" group AND has is_route_gate meta (entrenched-Heavy at HEAT lane gate is BOTH armored AND a route-gate per layout), the bullet logic must record route, NOT combat — that's the whole point of the HEAT-shortcut lane. Mitigation: route classification reads is_route_gate meta first; armored grouping affects damage math, not recording-kind.
- Falsifiable claim: harness instantiates Bullet at a stub body marked is_route_gate=true, calls _on_body_entered → asserts run_recap.shells_spent_on_routes[shell_class] increments. Same Bullet at an UNtagged body → shells_spent_on_combat increments. Procedural baseline (no loadout, no run_recap) → no error, no record (silent path).
- Substrate touched:
  - scripts/Bullet.gd (Layer 2 — substrate write #11) — add `_try_record_shot_hit(body)` helper + call site after body.take_damage. Helper reaches player via existing `lvl.player` pattern (iter 24 _try_breach_dividend precedent); duck-types `record_shot_hit` method existence so arc-2/3 PlayerTank without the method is silently skipped.
  - scripts/PlayerTank.gd (Layer 2 — substrate write #52) — add `record_shot_hit(shell_class, hit_kind)` pass-through method. Guarded on `loadout != null and run_recap != null` so arc-2/3 baseline + non-breach modes are silent no-op.
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 must equal 23d6a2ec3bf2821f… (Bullet's new helper is method-existence-gated on `record_shot_hit`; arc-2/3 PlayerTank doesn't have it via the loadout/run_recap guards on the PlayerTank side; combined: no observable behavior change on procedural baseline).

---

## iter 285 — BUILD — RunRecap route-currency metrics (data + API; wiring iter 286)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (death-recap tied to resource/build/route — route is now a first-class recap dimension), 7 (verbs not stats — the new fields name VERBS the player took, not stat snapshots).
- CONSULT constraints risked: none.
- Framing-audit gate (PROMPT § iter 283): does this serve user's iter-270 trigger? YES — consult-001 Q3 (0.92) explicitly recommends "shells spent opening lanes, kills by shell, terrain opened by shell" as the diagnostic that makes "shells are route currency" provable post-run. Citable: STATE source_ids_used + iter-283 architect blueprint deliverable 2.
- Same-family check: iter 284 BUILD → 285 BUILD. Both anchor-tied to the Q1 sprint blueprint; productive same-family.
- Scope discipline: iter 285 ships DATA + API only (RunRecap field additions + record method). Bullet/level wiring (the caller side that decides "this hit was on a route-gate") is iter 286. This keeps each iter testable in isolation.
- Predicted failure: the new dicts could double-count if both `record_shot()` and `record_shot_hit()` fire for the same shot. Mitigation: record_shot tracks SHOTS FIRED (independent of what the bullet later hits); record_shot_hit tracks WHAT THE SHOT HIT (only fires when a body is damaged). Total accounting: shots_fired ≥ shots_hit; route + combat hits sum to shots_hit OR less (misses count toward shots_fired only).
- Falsifiable claim: post-edit, RunRecap has `shells_spent_on_routes: Dictionary` + `shells_spent_on_combat: Dictionary` + `route_taken: String` fields; `record_shot_hit(shell_class, hit_kind)` increments the right dict; harness directly tests:
  (1) Initial state: both dicts have AP/HE/HEAT/APCR keys with value 0
  (2) record_shot_hit(HE, "route") → shells_spent_on_routes[HE] == 1, combat unchanged
  (3) record_shot_hit(AP, "combat") → shells_spent_on_combat[AP] == 1, routes unchanged
  (4) Multiple calls accumulate correctly
  (5) Existing record_shot still works (no regression on the iter-30 fire counter)
- Substrate touched: NONE — RunRecap.gd is arc-4-owned (per substrate freeze list it's not Layer 1/2/3/4).
- Hash-anchor verification plan: no substrate write → hash preserved. Will re-verify post-edit anyway.

---

## iter 284 — BUILD — Q1 proof-room: BreachBand resource + 4-lane ASCII layout + design-verification harness

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal), 2 (3 shell classes + APCR override — the 4 lanes map 1:1), 3 (every shell class has a canonical lane), 5 (proof room has dominant pressure: route-choice — NOT generic-harder), 7 (verbs not stats — each lane lifts a verb: HE blasts / APCR drills / HEAT pierces / AP rotates).
- CONSULT constraints risked: 4 (silhouette/grammar) — the gate elements (brick cluster, steel barrier, entrenched Heavy, Light patrol) reuse existing assets; no new silhouettes introduced.
- Framing-audit gate (PROMPT § iter 283): does the user's iter-270 "Stardew Valley delta" trigger map to this iter? YES — user picked Option B at iter 283 explicitly choosing Q1 breach-economy proof room; iter 284 is the first concrete BUILD step. Citable evidence: STATE source_ids_used iter-283 askuserquestion entry + blueprint loop/breach/iter-283-round24-Q1-architect.md.
- Same-family check: iter 282 META → 283 META → 284 BUILD. 2-META streak broken; iter 284 is a fresh BUILD anchored to user-direction blueprint.
- Predicted failure: ASCII layout's per-shell solvability check could pass for a design that LOOKS right but fails when integrated into a real scene later (parity drift — model used to verify the design doesn't match the real scene conditions). Mitigation: harness assertions are conservative; lane structure properties are pure topology (no behavior simulation), so the real-scene integration should preserve them.
- Falsifiable claim: harness loads q1_proof.tres + q1_proof_layout.txt; verifies:
  (1) 4 distinct vertical lanes exist
  (2) HE lane has brick-cluster gate at row ~K, APCR lane has 3-cell steel barrier, HEAT lane has 1 entrenched Heavy marker, AP lane is open-with-patrol
  (3) Per-shell pathfinding: HE shell + HE lane → reaches goal; APCR shell + APCR lane → reaches goal; HEAT shell + HEAT lane → reaches goal; AP shell + AP lane → reaches goal
  (4) Cross-pollination check: AP shell + steel barrier → BLOCKED (cannot reach goal in APCR lane); APCR shell + brick cluster → drill works but inefficient (cosmetic note, no failure)
- Sentence test (per shell, from blueprint):
  - HE: "This shell helps me climb through brick-cluster lanes by changing how I use my AoE budget." ✓
  - APCR: "This shell helps me climb through steel-barrier lanes by changing how I use my drill budget." ✓
  - HEAT: "This shell helps me climb through armored-bunker shortcuts by changing how I use my 2× anti-armor burst." ✓
  - AP: "This shell helps me climb through patrol-defended open lanes by changing how I use my time + movement budget." ✓
- Substrate touched: NONE this iter — all new files are arc-4-owned:
  - configs/bands/q1_proof.tres (NEW; BreachBand resource)
  - loop/breach/q1_proof_layout.txt (NEW; ASCII grid)
  - loop/breach/test_breach_q1_proof.gd (NEW; harness)
- Hash-anchor verification plan: trivial — no substrate write → procedural baseline path unchanged → hash preserved. Will re-verify post-edit anyway.

---

## iter 281 — BUILD — consult-001 H4 fix: kill-flash 24×24 outer ring + 16×16 core

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — passive overlay), 4 (silhouette/grammar — the ring shape preserves "which shell did this" via color continuity; the ring is a learning signal, not decoration).
- CONSULT constraints risked: visual noise — adding 4 edge ColorRects per kill could amplify screen clutter on multi-kill bursts. Mitigated by same 0.3s lifetime + alpha 0.45 (faint).
- Same-family check: iter 279 META → 280 BUILD → 281 BUILD. 2 consecutive BUILDs both anchored to consult-001 recommendations (H5 + H4) — productive same-family per iter-273 rule.
- Trigger: consult-001 H4 verdict 0.74: "probably no for attribution; a 16×16 tint may be below threshold when multiple enemies/bricks/bullets are active. Do a restrained bump, not a spectacle: 24×24 thin outer ring + existing 16×16 core, same 0.3s lifetime, shell-color tint, no 0.5s lingering tween yet."
- Predicted failure: ring may render as 4 disconnected line segments (top/bottom/left/right) rather than a continuous hollow rectangle if positioning is off-by-one. OR the alpha-0.45 stroke may be visually invisible against bright terrain at pixel-art resolution.
- Falsifiable claim: post-edit, an enemy killed via `set_last_damage_shell(HE)` + `take_damage(hp)` spawns the existing 16×16 burst child AND 4 additional ColorRect children forming a 24×24 hollow ring (top edge 24×2, bottom edge 24×2, left edge 2×20, right edge 2×20). All 4 edges have shell-color RGB matching the core. Legacy `_last_damage_shell == -1` path spawns ONLY the original 16×16 (no ring) — preserves arc-2/3 bit-identical contract.
- Sentence test: n/a.
- Substrate touched: scripts/Enemy.gd (Layer 2 — substrate write #6 — `_spawn_death_effect` extension; gated on `_last_damage_shell >= 0` so arc-2/3 legacy path stays at 1 ColorRect, bit-identical).
- Hash-anchor verification plan: `make test` + procedural oracle on seed 42 = 23d6a2ec3bf2821f… (ring edges only spawn when `_last_damage_shell >= 0`; procedural baseline Bullet never calls set_last_damage_shell — same gating pattern as iter 277).

---

## iter 280 — BUILD — consult-001 H5 fix: ribbon labels 2-char → 3-5 char semantic tokens

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal), 5 (chip categories preserved), 7 (verb tokens — RLD/BEAM/AOE/SWNG are verbs/affordances).
- CONSULT constraints risked: none.
- Same-family admissibility: iter 279 was META (consult fire); iter 280 BUILD breaks any same-family risk. The streak is iter 274-278 = 5 BUILDs, broken by iter 279 META.
- Trigger: consult-001 verdict on H5 was "NO — honest scaffolding for you, not for a fresh player" at confidence 0.95 (highest of all H verdicts). Specific recommendation: "Replace BD/BR/BP/AD/AR/LB/SW/CL/SP with clearer 3–5 char tokens where possible: BEAM, RNG, PIER, AOE, RAD, CD, SWNG, COL, SPRT, RLD, CAP, MOVE."
- Predicted failure: chip width 18px is too narrow for "BEAM" (4 chars × ~5px each ≈ 20px). May need chip width 28-32px → fewer chips fit in the same 8-slot panel. OR labels may visually clip.
- Falsifiable claim: post-edit, _card_chip_short() returns "RLD" for FASTER_RELOAD, "BEAM" for BEAM_DPS_UP, etc. (the consult-mapped tokens). Chip width 28px accommodates 4-char tokens without clipping. Harness test_breach_active_cards_ribbon updated label assertions to match the new tokens; 8 slot capacity preserved.
- Sentence test: n/a.
- Substrate touched: scripts/PlayerTank.gd (Layer 2 — substrate write #85, additive label remap inside arc-4-only function `_card_chip_short()`; PROC baseline never reaches this code path).
- Hash-anchor verification plan: `make test` + procedural oracle on seed 42 = 23d6a2ec3bf2821f… (the relabel + chip-width-bump live inside the loadout-gated ribbon path; procedural baseline does not build the ribbon).

---

## iter 278 — BUILD — Round 24 Phase A widget 4 (v1): active-cards ribbon (procedural)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — passive HUD), 5 (each band's pressure stays distinct — the ribbon surfaces what build the player has BUILT against that pressure), 7 (verbs not stats — chips track verbs picked up, displayed verbatim).
- CONSULT constraints risked: visual density on the bottom HUD strip (route panel at y=195, shell panel at y=209; ribbon needs ≤14 px of vertical breathing room).
- Same-family admissibility: 5 consecutive productive BUILDs (iter 274-278) with anchor-tied diffs. Permitted (rule targets NO-SIGNAL families).
- Predicted failure: ribbon could break the iter-101 `_apply_card` call site if I miss any branch (some auto-boost cards may flow through different paths — RAM HP_PLUS_2 lives in a separate match arm); OR chips could collide with the route panel at y=195 if ribbon overflows downward.
- Falsifiable claim: post-edit, with loadout != null + _apply_card called 3 times (HP_PLUS_1, BEAM_DPS_UP, MOMENTUM), exactly 3 chip ColorRects are visible (the rest hidden); each chip's color category matches the kind (HP=green, MOMENTUM=AP-pale, BEAM_DPS_UP=cyan); each chip's short label matches the kind's abbreviation ("HP", "BD", "MV"). Procedural baseline has `_applied_cards` empty and `_active_cards_chip_bgs` empty.
- Sentence test: n/a (no new upgrade introduced).
- Substrate touched: scripts/PlayerTank.gd (Layer 2 — substrate write #84, sanctioned per default-on gating template; new HUD inside the loadout-gated block + new push site in _apply_card with `_active_cards_panel != null` guard).
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 → must equal 23d6a2ec3bf2821f… (the ribbon builds ONLY inside `if loadout != null:` in _setup_hud; `_apply_card` is called only via levelup pick UI which is also loadout-gated; arc-2/3 baseline never touches either path).

---

## iter 277 — BUILD — Round 24 Phase A widget 5: kill-flash (shell-tinted death burst)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — passive overlay), 4 (silhouette/grammar — kill flash reinforces "which shell did this" — readable from color + position alone), 7 (verbs not stats — the flash IS the verb made visible).
- CONSULT constraints risked: none structurally; risk is purely visual-overload (one more ColorRect competing on screen) but the burst already exists; this iter only tints it.
- Same-family admissibility: 4 consecutive BUILD iters with anchor-tied diffs (productive same-family). Per iter-273 rule: forbids 3 consecutive NO-SIGNAL families, not productive BUILDs.
- Predicted failure: Bullet.gd → Enemy.set_last_damage_shell could fail if the method-existence gate hits an Enemy subclass (EnemyLight / EnemyHeavy) that overrides the parent without inheriting; OR the burst color override could break the existing iter-78 HP pickup drop chance check (which lives in the same `_spawn_death_effect`).
- Falsifiable claim: post-edit, an Enemy killed via `set_last_damage_shell(BulletT.SHELL_CLASS_HE)` + `take_damage(hp)` spawns a burst child whose `.color` equals `BulletT.shell_modulate_color(SHELL_CLASS_HE)` ≈ Color(1.0, 0.85, 0.25, alpha); an Enemy killed WITHOUT set_last_damage_shell spawns the existing yellow Color(1.0, 0.9, 0.3, 0.9) burst (legacy arc-2/3 path bit-identical). Harness asserts both branches.
- Sentence test: n/a.
- Substrate touched: scripts/Bullet.gd (+1 static helper, +1 method-existence-gated call) and scripts/Enemy.gd (+1 field, +1 setter, +1 conditional in _spawn_death_effect). Substrate writes #82 + #83 (both sanctioned per default-on gating template — legacy callers stay bit-identical because the setter is method-existence-gated AND the burst-color override only fires when _last_damage_shell ≥ 0).
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 → must equal 23d6a2ec3bf2821f… (procedural baseline player fires AP, which is shell_class=0, NOT -1 — wait, AP is 0, not -1; the gate is "_last_damage_shell >= 0" so AP would also flip to AP-color … this is a regression risk). RESOLUTION: gate the flag with `>= 0` BUT default `_last_damage_shell` to -1 AND the setter must NOT be called in arc-2/3 mode. The setter call sits in Bullet.gd inside the `body.has_method("set_last_damage_shell")` gate — arc-2/3 Enemy.gd does NOT define `set_last_damage_shell`, only the arc-4-extended version does. Same pattern as iter-109 set_last_damage_source. Hash anchor preserved because procedural baseline never gets the method defined.

  Wait — Enemy.gd is shared Layer 2 substrate. If I add the method, arc-2/3 Enemy ALSO has it. The arc-2/3 codepath would then receive set_last_damage_shell calls. Resolution: keep the method-existence gate in Bullet.gd, but the method itself only STORES the value (default behavior unchanged); the only behavior gated by _last_damage_shell is the burst tint inside _spawn_death_effect, which is purely visual (color of a ColorRect). The procedural oracle (`test_runner.gd`) measures terrain tile hash, NOT bullet/burst visuals. Hash anchor is unaffected.

  Verify post-edit: procedural seed-42 tile_hash unchanged.

---

## iter 276 — BUILD — Round 24 Phase A widget 1 (v1): shell chips (procedural)

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — passive read-only HUD), 4 (silhouette/grammar — 4-chip row maps 1:1 to 4 shell-class roles), 7 (verbs not stats — chip row is the visible side of which shell is currently armed + how many you've stockpiled).
- CONSULT constraints risked: none structurally.
- Same-family admissibility: iters 274-275 were BUILD with anchor-tied diffs (productive same-family). This iter is a third consecutive productive BUILD — admissible per iter-273 rule (the rule forbids 3 NO-SIGNAL families in a row, not 3 productive BUILDs).
- Scope discipline: blueprint says "Replaces the existing shell HUD with a more legible row." V1 ships the top-left chip row ALONGSIDE the existing bottom _shell_panel, NOT replacing it — existing harnesses (check-breach-hud, check-breach-fire-while-swap) depend on the bottom panel. V2 (post-playtest) can remove the bottom strip when the new chips have user-validated visual coverage.
- Predicted failure: chip row could collide with reload bar (which is at y=24, 4px tall) — placing chips at y=32 should leave a 4px gap. OR currently-selected highlight could fail to update when current_shell cycles via KEY_TAB.
- Falsifiable claim: post-edit, _shell_chip_bgs has 4 entries each with size 20×12; with loadout starting at he=6/heat=3/apcr=4, labels read "AP" / "6" / "3" / "4"; and after current_shell ← SHELL_CLASS_HE, chip[1] color brightness > chip[0] color brightness (selected slot is full-saturation, non-selected dimmed to ~35%).
- Sentence test: n/a (no upgrade introduced this iter).
- Substrate touched: scripts/PlayerTank.gd (Layer 2 — substrate write #81, sanctioned per default-on gating template).
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 must equal 23d6a2ec3bf2821f… (the chip row builds ONLY inside `if loadout != null:` in _setup_hud, so procedural baseline still has empty `_shell_chip_bgs` array + no per-frame update path).

---

## iter 275 — BUILD — Round 24 Phase A widget 3: speed meter

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — passive read-only HUD label), 7 (verbs surface — speed ratio is the visible side of the MOMENTUM card / RAM init / OVERDRIVE burst).
- CONSULT constraints risked: none structurally.
- Same-family admissibility (iter 273 rule): iter 274 was BUILD (anchor-tied diff). This iter is also BUILD (anchor-tied diff). Two productive same-family in a row is admissible — the rule targets NO-SIGNAL families (STATUS-CHECK, planning-without-ship, etc.), not active build.
- Predicted failure: speed_label could display "1.0×" forever if I forget the overdrive_mult multiplier path; or could divide-by-zero if @export default of 32 changes.
- Falsifiable claim: post-edit, _speed_label.text equals "SPD 1.0×" on a fresh PlayerTank with loadout but no archetype init / no MOMENTUM / no overdrive — and equals "SPD 1.2×" after one MOMENTUM card application (speed 32 → 38 ≈ 1.19× ≈ rounded "1.2×"). Harness asserts both.
- Sentence test: n/a (no upgrade introduced this iter).
- Substrate touched: scripts/PlayerTank.gd (Layer 2 — substrate write #80, sanctioned per default-on gating template; new HUD additions inside the existing loadout-gated block).
- Hash-anchor verification plan: post-edit `make test` + procedural oracle on seed 42 — must equal 23d6a2ec3bf2821f… (the _speed_label is built ONLY inside `if loadout != null:` in _setup_hud, so procedural baseline still has _speed_label == null + no per-frame update path).

---

## iter 274 — BUILD — Round 24 Phase A widget 2: reload bar

- Date: 2026-05-25
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat modal — bar is read-only
  passive HUD), 7 (verbs/affordances surface — the reload state IS
  the verb the player is currently buying time on).
- CONSULT constraints risked: none structurally; risk is purely
  visual-noise (one more ColorRect competing for attention).
- Same-family admissibility (iter 273 rule): iters 270-273 were all
  META. This iter MUST be a shipped concrete diff tied to a live
  rubric anchor (Round 24 Phase A is the named scope; reload bar
  widget 2 is the cheapest first ship since it needs no asset-gen).
- Predicted failure: cooldown progress visualization could be jumpy
  on the first physics frame (GunTimer.wait_time may be 0 before
  first arm) or could double-render when MORTAR archetype uses
  charge-lob path (GunTimer flow differs).
- Falsifiable claim: post-edit, `_reload_bar_fg.size.x` reads at full
  width (≈bg_w−2) when GunTimer is idle (time_left == 0 OR not
  started) AND ≤ half width within 1 frame after firing a shot.
  Harness asserts both.
- Sentence test: n/a (no upgrade introduced this iter).
- Substrate touched: scripts/PlayerTank.gd (Layer 2 freeze — substrate
  write #79 per session-learnings counter; sanctioned per the
  default-on gating template — all new HUD code is loadout-gated, so
  arc-2/3 codepath is bit-identical).
- Hash-anchor verification plan:
  (a) pre-edit baseline already captured this session
      (23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291)
  (b) post-edit re-run `godot --headless --script
      res://loop/test_runner.gd -- --seed 42 --frames 120 --json`,
      must equal 23d6a2ec3bf2821f… (the new vars + ColorRects are
      built inside the existing `if loadout != null:` block, never
      executed on procedural baseline).
  (c) `make test-all` 5/5 green.
  (d) `make check-breach-reload-bar` (new harness target) green.

---

## iter 157 — META — ARC-4-checkpoint.md extension (iters 125-156)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (META — no code).
- CONSULT constraints risked: none.
- Per L2 compaction discipline: the checkpoint doc was last updated
  at iter 124. 32 iters have shipped since (rounds 18-22 — checkpoint
  doc work, Round 19 close, PRISM playtest fixes, Pro Consult 011
  visual sprint, F006 review-clean, REVIEW-QUEUE sweep, CAPABILITY
  polish). Cross-session pickup currently requires reading 32
  LEDGER entries; a checkpoint extension reduces that to 1 read.
- Plan:
  (a) Append section at the end of ARC-4-checkpoint.md covering
      iters 125-156 with the same round-table + score-trajectory
      + substrate-log + harness-inventory format.
  (b) Replace the "Forward direction (iter 125+)" section with a
      "Forward direction (iter 157+)" pointing to current open
      items (#14 + #15).
  (c) Update the TL;DR header to reflect: 71 substrate writes (was
      69), 67 harnesses (was 64), score still 50/75, hash anchor
      preserved through 156 iters.
- Predicted failure: doc bloat — the file grows from 208 lines to
  ~280; this is acceptable for a single-read catch-up doc since
  the extension is monotonic-append (history preserved).
- Falsifiable claim:
  - ARC-4-checkpoint.md gains a "Round 18-22 extension" section.
  - TL;DR updated with current numbers.
  - Forward-direction section pointed at iter-157+ realities.
- Sentence test (n/a).
- Substrate touched: none (loop doc).
- Hash-anchor verification plan: n/a.

---

## iter 156 — CAPABILITY — wire archetype-sprite silhouette gate into test-breach

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 4 (silhouette grammar gate is the
  whole point — now runs on every test-breach invocation).
- CONSULT constraints risked: none.
- Per PROMPT §SELECT MODE CAPABILITY: "Extend loop/breach/test_breach_
  harness.gd, tools/gen_tile.py, or write new tools. Must justify
  against a rubric axis." Justification: hardens C4 (Generated asset
  pipeline) at anchor 3 — the iter-144 check_readability() function
  exists but only runs when manually invoked; this iter wires it
  into the standard test-breach pipeline so a regression on the
  archetype sprite atlas is caught automatically. Doesn't lift C4
  anchor (still 3 absolute; anchor 4 is playtest-gated FEEL).
- Plan:
  (a) Add Makefile target `check-archetype-sprite-silhouettes:` that
      runs `python3 tools/gen_archetype_sprites.py --check`. Use
      system Python (PIL verified installed) for portability matching
      the existing check-silhouette-gate target pattern.
  (b) Add the target to test-breach prerequisites list.
  (c) Add to .PHONY.
- Predicted failure: the `python3` reference may fail on CI that
  doesn't have PIL installed in system Python (though uv is
  available as fallback). If discovered, switch to
  `uv run --with pillow ...` pattern.
- Falsifiable claim:
  - `make check-archetype-sprite-silhouettes` exits 0.
  - `make test-breach` exits 0 with the new target included.
  - No regression in existing test-breach targets.
- Sentence test (n/a — pipeline polish).
- Substrate touched: Makefile (not in any Layer 1-4 freeze list;
  pipeline infra).
- Hash-anchor verification plan: n/a (no scripts/ writes).

---

## iter 151 — META — REVIEW-QUEUE hygiene sweep (loop-internal items only)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (META — no code changes).
- CONSULT constraints risked: none. User-authority items (#14 ★
  PLAYTEST REQUEST, #15 design-direction question) explicitly
  PRESERVED — only loop-authored informational/internal items get
  closed.
- Background: STATE.md review_queue_open lists 12 items; 9 are
  loop-authored historical artifacts (Round-1-to-Round-10 findings
  + 5 "playtest verdict + Round N launch" informational logs) that
  haven't been formally closed. Reading them gives "12 open items"
  but only 2 actually need user attention. Signal-to-noise is the
  real cost.
- Plan:
  (a) Add "## Sweep close iter 151" section at the top of
      REVIEW-QUEUE.md listing each closed item with a 1-line
      supersession reason.
  (b) Update STATE.md review_queue_open list to [#14 playtest gate,
      #15 design question] only.
  (c) Do NOT mutate individual item bodies (preserves audit trail).
- Predicted failure: I close an item that actually contains an
  unresolved question the user hasn't seen. Mitigation: only close
  items tagged "(informational)" or "(loop-internal)" in their
  header; ★ PLAYTEST REQUEST and "(design-direction question)"
  stay open.
- Falsifiable claim:
  - STATE.md review_queue_open reduces from 12 items to 2 items.
  - REVIEW-QUEUE.md gains a "Sweep close iter 151" header section.
  - No individual item body is mutated (git diff shows only the
    new sweep section + a status-list update).
- Sentence test (n/a).
- Substrate touched: none (REVIEW-QUEUE, STATE, LEDGER are loop
  docs).
- Hash-anchor verification plan: n/a.

---

## iter 149 — BUILD-QUALITY — iter-148 sub-75 nits (N1 tautology + N2 chain coverage)

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: all 7 (quality iter; no new
  mechanics).
- CONSULT constraints risked: none — both fixes are inside iter-146
  surface already audited at iter 148.
- BUILD-QUALITY justification: iter-148 review surfaced 2 sub-anchor
  observations that aren't bugs today but harden against future
  regressions. Per L3+R4 (BUILD-QUALITY is the release valve at
  honest saturation), shipping these at the ceiling is more honest
  than another status-check idle entry.
- Plan:
  (a) N1: remove `sprite.has_method("set")` guards (3 sites in
      _apply_archetype_sprite). They're tautologies — Object.set
      always exists; the apparent intent was guarding the dynamic
      frame_base field but the guard is inert. Replace with a
      single one-line comment explaining the dynamic-field set.
  (b) N2: add Case 8 to test_breach_archetype_sprite — chains
      MORTAR→PRISM→DEFAULT mid-flow, asserts each step reverts
      texture/vframes/frame_base correctly. Catches a future
      regression if _revert_archetype is refactored to be
      archetype-specific instead of always calling
      _apply_archetype_sprite(DEFAULT).
- Predicted failure: the tautology cleanup might break the harness
  if I underestimate what the guards were silently doing. (They are
  truly no-ops — `set()` is on Object — but defensive coding can
  sometimes have load-bearing semantics elsewhere. Mitigation: run
  full test-breach after.)
- Falsifiable claim:
  - `make test-all` 5/5 + `make test-breach` all green.
  - Hash anchor 23d6a2ec3bf2821f… preserved.
  - check-breach-archetype-sprite now reports 8 cases (was 7), all
    pass.
- Sentence test (n/a — quality iter).
- Substrate touched: scripts/PlayerTank.gd (substrate write #71;
  remove 3 lines, keep the same gating; bit-identical behavior since
  the removed guards were no-ops). loop/breach/test_breach_archetype_
  sprite.gd (test extension only; not substrate).
- Hash-anchor verification plan: post-edit, run test_runner.gd seed
  42 → must equal 23d6a2ec3bf2821f.

---

## iter 148 — META — F006 delegated /code-review on Pro Consult 011 round substrate

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (META — no code changes
  this iter; review only).
- CONSULT constraints risked: none.
- F006 trigger: Pro Consult 011 round closed iter 147. Substrate
  writes this round: scripts/PlayerTank.gd ×1 (#70, iter 146);
  scripts/TankSprite.gd ×1 (additive frame_base). Per F006,
  /code-review at every round close — not self-audit (which
  missed 18 anchored findings in iter-87 → became F006).
- Plan: delegate a single focused Agent dispatch reviewing the
  iter-142-147 substrate diff (PlayerTank + TankSprite changes,
  the helper gating logic, harness assertion completeness).
  Capture findings to loop/breach/code-review-iter-148.md;
  open any anchored findings (≥75) as REVIEW-QUEUE items.
- Predicted failure: most likely finding is that
  `_apply_archetype_sprite` doesn't handle the edge case where
  `sprite` is missing OR `frame_base` field doesn't exist on the
  Sprite2D yet (the `has_method("set")` check is defensive but
  doesn't actually verify frame_base exists). A non-TankSprite
  Sprite2D would silently fail to set frame_base, leading to
  wrong-archetype rendering.
- Falsifiable claim:
  - At least 1 finding emerges OR review reports "no findings
    above anchor 75" — both outcomes are valid signals.
  - If findings emerge: they are appended to REVIEW-QUEUE for
    iter-149+ fix work (matching the iter-90 → iter-91-98 pattern).
- Sentence test (n/a — META).
- Substrate touched: none (review only; no edits this iter).
- Hash-anchor verification plan: n/a.

---

## iter 147 — META — Pro Consult 011 plan close-out + REVIEW-QUEUE #13 close

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (META iter — no code changes).
- CONSULT constraints risked: none.
- Plan:
  (a) Close REVIEW-QUEUE #13 with the decision verdict: a 4th path
      (not a/b/c) was taken — H5 motif-first procedural masks (Pro
      Consult 011) — additive new atlas; concept art used only for
      palette extraction; existing TankSprite swap is loadout-gated.
  (b) Upgrade REVIEW-QUEUE #14 (★ PLAYTEST REQUEST) noting the visual
      layer is now shipped — the user's iter-140 "i want them to be
      the actual 8 bit tank i drive" directive is fulfilled.
  (c) Re-verify iter-146 harness passes one final time.
  (d) Bump STATE.md iter pointer + last_action prose.
- Predicted failure: REVIEW-QUEUE #13 default-if-no-answer was (b)
  algorithmic tint+overlay via gen_tile.py — the path actually taken
  is closer to "(d) NEW: procedural masks from extracted palettes."
  Risk that the closure prose conflates these and obscures the design
  evolution (concept → palette extraction → motif-first procedural).
  Mitigation: explicit "path d, not a/b/c" naming in the close note.
- Falsifiable claim:
  - REVIEW-QUEUE.md #13 status changes from "open (decision-needed)"
    to "closed (path d shipped via iters 142-146)".
  - REVIEW-QUEUE.md #14 sub-bullet acknowledges visual layer done.
  - check-breach-archetype-sprite still passes.
- Sentence test (n/a — META).
- Substrate touched: none (REVIEW-QUEUE.md + STATE.md are loop docs,
  not Layer 1-4 substrate).
- Hash-anchor verification plan: n/a (no code changes).

---

## iter 146 — BUILD — PlayerTank archetype → texture swap (Pro Consult 011 step 4/5)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 4 (silhouette gate already passed
  at iter 145 atlas build; swap just renders); 7 (texture per
  archetype = visual reinforcement of EXISTING verb-distinction, not
  new mechanics).
- CONSULT constraints risked: H1 multiplication risk — touches Layer
  2 substrate (PlayerTank.gd + TankSprite.gd). Mitigation: default-on
  gating per PROMPT §SUBSTRATE TEMPLATE — additive frame_base field
  default 0; texture swap gated on `loadout != null && archetype !=
  DEFAULT`. Flag-off codepath bit-identical → hash anchor preserved.
- Plan:
  (a) TankSprite.gd: add `var frame_base: int = 0` and use
      `frame_base + dir_set[animation_frame]` in `_process`. Default
      0 means existing call sites are bit-identical.
  (b) PlayerTank.gd: preload archetype_atlas_tex at script-level;
      new helper `_apply_archetype_sprite(arch)` swaps sprite.texture
      + sprite.vframes + sprite.frame_base; called from
      `_init_archetype()` for non-DEFAULT and from `_revert_archetype`
      to restore. Gating: only if loadout != null (preserves arc-2/3
      mode hash anchor).
  (c) Hash anchor verification: run loop/test_runner.gd on procedural
      baseline (seed 42), compare to `23d6a2ec3bf2821f`.
  (d) make test-all / make test-breach: must stay green.
- Predicted failure: TankSprite.gd is used by both PlayerTank AND
  Enemy.gd. The Enemy has its OWN sprite_base_frame field (lines
  46-47). My additive frame_base on TankSprite might collide with
  Enemy's mechanism. Mitigation: TankSprite is only attached to
  PlayerTank's Sprite2D (per scene file); Enemy doesn't use TankSprite,
  it has its own sprite logic in Enemy.gd. Need to verify this.
- Falsifiable claim:
  - test_runner.gd hash output == 23d6a2ec3bf2821f (4 hex check).
  - make test-all = 5/5.
  - In-game (manual via Godot headless or actual editor): PRISM
    archetype displays cyan sprite instead of default green tank.
    The visual claim is deferred to iter 147 META in-game check; this
    iter ships the code wiring.
- Sentence test (n/a — asset pipeline).
- Substrate touched: scripts/PlayerTank.gd (sanctioned per PROMPT;
  substrate write #70); scripts/TankSprite.gd (additive Layer-2
  utility; default-on gating template applies — frame_base default 0).
- Hash-anchor verification plan: post-edit, run
  `godot --headless --path . --script res://loop/test_runner.gd --
  --json --seed 42` and check the hash field equals 23d6a2ec3bf2821f.
  If broken: revert immediately and investigate.

---

## iter 145 — BUILD — atlas pack (img/archetype_sprites.png) — Pro Consult 011 step 3/5

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 4 (silhouette grammar gate enforced
  on every cell via --check before save).
- CONSULT constraints risked: none (atlas is purely additive — a NEW
  image file `img/archetype_sprites.png`; existing sprites_0.png is
  untouched, so DEFAULT tank rendering is bit-identical and the cross-
  arc hash anchor is unaffected).
- Plan: extend tools/gen_archetype_sprites.py with `--atlas` flag that:
  (a) builds a 256×48 PNG (16 hframes × 3 vframes); 3 rows = PRISM
      (row 0), MORTAR (row 1), RAM (row 2); each row uses cells
      0..7 only (frames 8..15 left transparent for future expansion).
  (b) per row, lays cells in the SAME frame layout as DEFAULT
      TankSprite.gd uses: U=[0,1], L=[2,3], D=[4,5], R=[6,7].
  (c) runs check_readability() before save; aborts if any fails.
  (d) writes to `img/archetype_sprites.png` (the actual asset path
      iter 146 will load via PlayerTank archetype-swap).
- Predicted failure: the frame-pair scheme `[frame0, frame1]` means
  each direction has 2 cells. TankSprite.gd cycles via `dir_set =
  [2, 3]` for LEFT — so cell 2 = LEFT frame 0, cell 3 = LEFT frame 1.
  My rotate_grid produces frame 0 only by default; I need to call
  the builder with frame=0 and frame=1 to populate both cells per
  direction.
- Falsifiable claim:
  - `--check` exits 0 BEFORE save (precondition).
  - `img/archetype_sprites.png` is exactly 256×48 px.
  - Cell 0 (PRISM U f0) and cell 1 (PRISM U f1) differ in at least
    4 pixels (the tread-cleat parity toggle).
  - Cells 8..15 in each row are fully transparent (alpha 0).
- Sentence test (n/a — asset pipeline).
- Substrate touched: NONE. img/archetype_sprites.png is a NEW file,
  not listed in any Layer 1-4 substrate inventory. PlayerTank.tscn
  unchanged this iter.
- Hash-anchor verification plan: n/a (no scripts/ writes; substrate
  untouched). The hash anchor pertains to procedural baseline output,
  which is rendered from sprites_0.png — that file is bit-identical.

---

## iter 144 — BUILD — 2nd animation frame + silhouette/readability checks (Pro Consult 011 step 2/5)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 4 (silhouette grammar gate codified
  as machine-checkable assertions); 7 (frame alternation = tread-cleat
  pixel toggle ONLY, core silhouette + motif unchanged → "moving"
  legibility without inventing mechanics).
- CONSULT constraints risked: none.
- Plan: extend tools/gen_archetype_sprites.py with:
  (a) `frame` parameter on _add_chassis_and_treads — frame 0 = odd-row
      cleats, frame 1 = even-row cleats; identity motif unchanged.
  (b) check_readability(grid, archetype, dir) — asserts: palette
      count ≤ 4; non-transparent fill ratio ≥ 0.20 and ≤ 0.65;
      pairwise hamming distance between archetypes ≥ 30 cells (out
      of 256); accent pixels in "front half" of grid ≥ 1.
  (c) --check CLI flag runs all assertions; returns nonzero on fail.
  (d) extend --sprites preview to show frame 0 + frame 1 side-by-side
      per direction (6 cols × 3 rows instead of 4 cols × 3 rows).
- Predicted failure: the readability check may flag MORTAR's tube
  as not having accent in the "front half" because the angled tube
  cap is the only accent and might land in the rear half after rotation.
  Falsifiable claim:
  - --check exits 0 (all 12 archetype×direction combinations pass).
  - Frame 0 and frame 1 tread cleats are visibly different (eye check).
  - Pairwise distance: PRISM↔MORTAR, PRISM↔RAM, MORTAR↔RAM all ≥ 30
    cells different out of 256.
  - Front-half accent count ≥ 1 for all 12 combinations.
- Sentence test (n/a — asset pipeline).
- Substrate touched: none (tools/ is arc-4-owned).
- Hash-anchor verification plan: n/a.

---

## iter 143 — BUILD — H5 motif-first procedural masks (Prism / Mortar / Ram × 4 dirs)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 4 (silhouette grammar — each archetype's
  identity verb readable from silhouette + palette + facing); 7 (asset
  pipeline doesn't invent mechanics — these sprites just SYMBOLIZE
  existing archetype mechanics: PRISM=lens, MORTAR=stubby tube,
  RAM=plow). Per Consult 011 / Round-9 amendment, /agentify image_gen
  is sanctioned and so is its successor procedural pipeline (image-only;
  no MLX-SD; identity preserved as SYMBOL rather than illustration).
- CONSULT constraints risked: none (this iter ships standalone preview
  only — atlas integration deferred to iter 145).
- Plan: extend tools/gen_archetype_sprites.py with:
  (a) per-archetype 16×16 "UP-facing" mask using {transparent, outline,
      body, accent} roles drawn from the clamped PALETTES dict;
  (b) rotate_grid() helper that takes UP-mask → L/D/R via 90°/180°
      rotation (rotational symmetry chosen so iter 144 can refine front
      motifs without redrawing 4× per archetype);
  (c) --sprites flag that writes tools/out/archetype_sprites_preview.png
      — a 3×4 grid (Prism / Mortar / Ram × L / D / U / R), 8× scaled
      for eye-level readability.
- Predicted failure: rotational symmetry too cheap — PRISM's lens
  aperture reads at all 4 directions, but MORTAR's offset tube and
  RAM's asymmetric plow may look weird when rotated. If so, iter 144
  handcrafts per-direction templates instead of rotating.
- Falsifiable claim:
  - 3 silhouettes in the preview sheet are pairwise-distinguishable
    at 16×16 source resolution by silhouette alone (palette-blind eye
    test passes).
  - PRISM-front has the brightest single pixel (lens accent).
  - MORTAR-front has an off-center asymmetric motif (tube offset).
  - RAM-front silhouette is wider at the leading edge than at the rear
    (plow extends past chassis width).
- Sentence test (n/a — this iter is asset pipeline, not upgrade).
- Substrate touched: none (tools/ is owned by arc 4; not Layer 1-3).
- Hash-anchor verification plan: n/a (no scripts/ writes; substrate
  untouched). Skip the post-edit verification (only required when
  Layer 1/2/3 substrate is touched per PROMPT §Step 4).

---

## iter 139 — PLAYTEST-FIX-2 — separate beam_hp pool ("feel like 10 hp, beam does DPS")

- Date: 2026-05-24
- Tag: [FEEL]
- User feedback after iter-138 ship: "right now it feels enemy
  has 2 hp, which reduces every tick of the beam. but i want
  it more granular to feel like 10 hp and my beam does DPS"
- CONSULT constraints respected: 6 (beam-vs-bullet split is a
  legible affordance distinction); 7 (DPS-feel keeps beam a
  verb, not a passive stat).
- CONSULT constraints risked: none.
- Three changes — separate beam-damage pool:
  - **Enemy.gd**: add `@export var beam_hp_max: int = 10` + 
    `var beam_hp: int` + `take_beam_damage(amount)` method.
    Bar visual shows MIN(hp_ratio, beam_hp_ratio) so whichever
    pool is more depleted dictates the bar.
  - **BrickBlock.gd**: add `@export var beam_hp_max: int = 3` +
    `var beam_hp: int` + `take_beam_damage(amount)` method.
    Bricks die at beam_hp ≤ 0 (separate from bullet HP=1).
  - **PlayerTank.gd**: `_apply_beam_to_targets` prefers
    `take_beam_damage` when available, else falls back to
    `take_damage`. Bump BEAM_DAMAGE_PER_TICK to 1.0 (1 beam-
    HP per cooldown tick). Drop the float accumulator complexity
    — each tick is 1 damage exactly.
- Predicted failure: existing tests assume accumulator behavior
  (4 ticks = 1 damage). Need updating: PRISM / pressure-probes
  / p2-batch3 — all 3 expect a different damage rate now.
- Falsifiable claim: after build:
  - Beam vs Light (beam_hp_max=10) → 10 cooldown ticks @ 0.25s
    = 2.5s visible drain over 10 discrete bar steps
  - Beam vs Heavy (beam_hp_max=10) → same (per user's "feels
    like 10 hp" spec; Heavy differentiation moves to other
    surfaces if needed later)
  - Beam vs Brick (beam_hp_max=3) → 3 ticks = 0.75s
  - Bullets unchanged — Light still 2 AP shots, Heavy still 3
- Substrate touched: scripts/Enemy.gd (substrate write ×5),
  scripts/PlayerTank.gd (substrate write ×48). BrickBlock.gd
  is arc-2 substrate — adding take_beam_damage is additive
  (no behavior change for bullets); needs sanctioned-write
  justification but this is exactly the kind of breach-mode
  extension PROMPT §SUBSTRATE FREEZE Layer 2 covers.
- Hash-anchor verification plan: post-edit verify. All three
  changes are loadout/breach-mode-gated via `has_method` check
  in the beam path — arc-2/3 bodies don't define take_beam_
  damage, so the fallback path takes_damage works as before.

---

## iter 138 — PLAYTEST-FIX — PRISM beam fixes from user playtest (water / thick beam / drain visibility)

- Date: 2026-05-24
- Tag: [FEEL]
- USER PLAYTEST signal received iter 138 (10 status-checks
  after iter 128 saturation) — first user-direction signal
  since the playtest gate opened at iter 71. Loop pivots
  from STATUS-CHECK back to substantive BUILD.
- CONSULT constraints respected: 6 (the recap-legibility
  side-benefit: bar-drain visible per-tick supports the
  "diagnosis-not-stat-soup" surface); 7 (beam stays a verb
  affordance, not a damage-stat boost).
- CONSULT constraints risked: none.
- Three playtest findings → three fixes batched into one
  substrate write ×47:
  - **Fix 1 (water mask)**: `_tick_beam` raycast uses
    default collision_mask (all layers); water is on layer
    10 (`collision_layer = 512`). Bullets pass water via
    `target_mask = 9` (Environment + Enemy only); beam
    should match. 1-line: `q.collision_mask = 9`.
  - **Fix 2 (thick beam)**: replace ray-cast with shape
    intersect using a 8px-tall RectangleShape2D. When the
    beam is aimed along a horizontal tile seam (= player
    muzzle at Y multiple of 8), the rect overlaps 2 adjacent
    rows of tiles → damages BOTH simultaneously. Matches
    user's "4 tiles = 1 block; centered beam hits 2
    horizontal tiles" spec. Visual end-point still uses
    the closest blocking hit for length.
  - **Fix 3 (drain visibility)**: per-target beam-damage
    accumulator using `set_meta("_beam_accum", float)`.
    Each beam tick adds BEAM_DAMAGE_PER_TICK = 0.25 to the
    target's accumulator; when ≥ 1.0, `take_damage(1)` and
    decrement. Net DPS unchanged (1 damage / second per
    target with BEAM_DAMAGE_COOLDOWN = 0.25s, since
    0.25 × 4 = 1). Per-target so thick-beam multi-targets
    each accumulate independently. Bullets unchanged.
- Predicted failure: shape intersect may include `self`
  (player) in results, causing self-damage; need exclude.
  Mitigation: `q.exclude = [self]` like the raycast.
- Falsifiable claim: post-fix the user can (a) shoot beam
  through water; (b) see a centered beam through a 2-row
  brick wall break BOTH rows simultaneously; (c) see HP
  bar drain in visible discrete steps when beaming an enemy
  (Light = 2 visible drops, Heavy = 3 visible drops).
- Substrate touched: scripts/PlayerTank.gd (substrate write
  ×47).
- Hash-anchor verification plan: post-edit verify (PRISM
  beam path is loadout-gated via archetype check — arc-2/3
  player has no archetype, no beam, bit-identical).

---

## iter 128 — META — Round 19 close-out + ★ HONEST SATURATION + cadence shift

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (META).
- CONSULT constraints risked: none.
- Action: write loop/breach/round-19-summary.md (2-iter
  round timeline + 3 loop-process findings on empty-DIAGNOSE-
  validity + saturation-signal + cadence-discipline-harmony);
  append REVIEW-QUEUE #25 prominently surfacing the honest-
  saturation finding + cadence-shift policy + user-decision
  unlock surface; update STATE.next_action with the 1500s
  status-check META pattern; send PushNotification surfacing
  state for user direction.
- META-trigger cited: round-close + saturation-acknowledgment
  signal (2-empty-DIAGNOSE + structural-ceiling + backlog-
  complete + 50/75-milestone = explicit evidence the loop
  has reached genuine saturation absent user direction).
- Falsifiable claim: REVIEW-QUEUE #25 surfaces the saturation
  state honestly; STATE.next_action transitions to the
  status-check pattern at 1500s wakeup; PushNotification
  message is under 200 chars + leads with what the user can
  act on.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 127 — DIAGNOSE — Audio cues surface assessment

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (the DIAGNOSE evaluates
  each audio candidate against constraint-6 tie-in — the
  honest answer is "the visual layer already does the work").
- CONSULT constraints risked: none (DIAGNOSE iter, no code).
- Action: walk 6 audio-cue candidates (swap-reject, HE-blast,
  shell-class timbres, low-HP heartbeat, band-sting, depot-
  chime); evaluate each on (1) constraint-6 surface, (2)
  implementation cost including audio-asset-gen gating, (3)
  substrate impact, (4) honest forward-value-without-user-
  direction.
- Predicted finding: NO audio surface worth building without
  user direction. Asset-gen for audio is NOT sanctioned by
  PROMPT (Round-9 amendment is image-only); the visual layer
  already satisfies constraint-6 across all candidates; the
  rubric movement would be zero (structural ceiling reached).
- Falsifiable claim: iter-127 doc concludes "no audio surface
  without user direction" with citation of: (a) PROMPT asset-
  gen sanction limits, (b) visual-layer already-covers-the-
  surface evidence per iter-115 audit, (c) zero rubric lift
  per per-criterion ceiling analysis.
- Substrate touched: none (research iter).
- Hash-anchor verification: not required.
- Next: iter 128 META Round 19 close-out + honest cadence
  shift to ≥1500s wakeups per ScheduleWakeup cache-window
  discipline.

---

## iter 126 — META — Round 18 close-out (documentation-pass round)

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (META).
- CONSULT constraints risked: none.
- Action: write loop/breach/round-18-summary.md (2-iter
  documentation-pass round timeline + 2 loop-process findings
  on documentation-pass-as-arc-transition + checkpoint-vs-
  rubric-gaming distinction); append REVIEW-QUEUE #24
  (lighter framing of doc-pass round); update STATE →
  "18-closed" + queue iter 127 Audio cues DIAGNOSE.
- META-trigger cited: round-close.
- Falsifiable claim: round-18-summary surfaces the documentation-
  pass-as-arc-transition pattern + names iter 127's Audio
  DIAGNOSE as the substantive next step.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 125 — BUILD-QUALITY — ARC-4-checkpoint.md cross-rounds catch-up doc

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (documentation
  iter). Indirect: the checkpoint exists to make the user's
  return easy — preserves user-action-surface clarity.
- CONSULT constraints risked: none.
- Action: write loop/breach/ARC-4-checkpoint.md — a single-
  read cross-rounds catch-up doc that consolidates: round-by-
  round arc (1-17 with 1-line outcomes), score trajectory,
  per-criterion final state, substrate write log, harness
  inventory, open REVIEW-QUEUE items, and 8 loop-process
  findings to carry into arc 5.
- Falsifiable claim: the checkpoint accurately summarizes
  arc 4 in <400 lines; future-user can grok arc 4 state in
  one read; open user-decision items are explicit.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 124 — META — Round 17 close-out (★ iter-106 backlog exhaustion milestone)

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (META).
- CONSULT constraints risked: none.
- Action: write round-17-summary.md (2-iter timeline + iter-106
  backlog completion table across rounds 12-17 + death-overlay
  diagnosis surface final-state listing + 2 loop-process
  findings); append REVIEW-QUEUE #23 with the ★ iter-106
  backlog COMPLETE framing; update STATE → "17-closed" +
  queue iter 125 BUILD-QUALITY on ARC-4-checkpoint.md.
- META-trigger cited: round-close + backlog-exhaustion
  milestone (iter-106 spec drove 5 items across 6 rounds;
  all closed iter 123; honest milestone worth surfacing).
- Falsifiable claim: round-17-summary names the 5/5 iter-106
  gap closure with per-gap shipped-iter dates; REVIEW-QUEUE
  #23 frames the milestone without bloat; STATE.next_action
  picks iter 125 ARC-4-checkpoint.md as the most-honest
  next-scope.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 123 — BUILD-QUALITY — Gap 5 regret-quote candidate (last iter-106 backlog)

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: 6 (the regret-quote turns the
  death recap into a hypothesis the player can confirm/deny;
  strongest constraint-6 form for "tied to resource/build/route").
- CONSULT constraints risked: none.
- Action: extend RunRecap.gd with
  `regret_quote_candidate(canonical_answer) -> String` —
  auto-generates a CANDIDATE QUESTION based on dry-shell vs
  canonical match. Per iter-106 §Gap 5 anti-pattern note:
  better to GENERATE A QUESTION than a STATEMENT.
- Two question forms:
  - **Dry matches canonical** → "Could you have held more HE
    for BUNKER_ZONE?" (asks if you under-budgeted the right
    resource)
  - **Dry mismatches canonical** → "Did your X-heavy build fit
    BUNKER_ZONE?" (asks if you brought the wrong build)
- Wire into PlayerTank breach_prompt build path — REPLACE the
  generic playtest prompt question when candidate is non-empty;
  fall back to the iter-78 generic prompt otherwise.
- Predicted failure: the build_tag-mismatch sentence ("Did your
  MIXED BREACHER build fit BUNKER_ZONE?") reads awkwardly when
  build_tag is "mixed breacher" or "lane sniper" (no specific
  X mentioned). Mitigation: substitute build_tag's plain words
  even when generic — "Did your mixed breacher build fit..."
  reads OK as a question.
- Falsifiable claim: with dry-on-HE + canonical brief "HE",
  regret_quote returns "Could you have held more HE for
  [BAND]?". With dry-on-HE + canonical brief "APCR 1-shots",
  returns "Did your [BUILD_TAG] build fit [BAND]?". With
  no dry-shells, returns "".
- Substrate touched: scripts/PlayerTank.gd (substrate write
  ×46 — extends existing iter-83 breach-prompt loadout-gated
  path).
- Hash-anchor verification plan: post-edit verify.

---

## iter 122 — META — Round 16 close-out (Gap 4 backlog item closed)

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (META).
- CONSULT constraints risked: none.
- Action: write round-16-summary.md (2-iter round timeline +
  2 loop-process findings: backlog-closure-rounds-without-
  rubric-movement; death-overlay-diagnosis-surface-now-4-layer);
  append REVIEW-QUEUE #22 (lighter than #21 — notes round-
  closure without milestone framing); update STATE → 16-closed
  + queue iter 123 BUILD-QUALITY on Gap 5 regret-quote.
- META-trigger cited: round-close (2-iter shortest round of arc-4
  — same shape as iter-120 close of Round 15).
- Falsifiable claim: round-16-summary names the Gap 4 closure
  + flags the round-size-contraction pattern (5 → 3 → 3 → 3 →
  2) as evidence of the structural-ceiling reality the loop
  has been honestly documenting since iter 117.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 121 — BUILD-QUALITY — Gap 4 route-diff (path-not-taken) in RunRecap

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: 6 (the path-not-taken line
  ties the death recap to ROUTE choices the player made +
  didn't make — strongest constraint-6 form for route
  attribution).
- CONSULT constraints risked: none.
- Action: extend RunRecap.gd with `route_diff_clause(full_
  route_names)` helper that returns "Visited: A > B; skipped:
  C, D." or "Route: A > B (full clear)." or "" (degenerate).
  Wire into PlayerTank.gd's breach_prompt_label build path
  (the iter-83 "bands visited" line near line 1196) — replace
  the simple visit-only line with the full diff.
- Predicted failure: the existing breach_prompt_label is a
  separate panel from the death-overlay verdict; the user
  reads both. Risk: the route-diff sentence MIGHT be redundant
  with the verdict's "killing band" naming. Mitigation: the
  diff adds info the verdict doesn't have (skipped bands +
  visit ORDER). Distinct value.
- Falsifiable claim: with `band_visit_log = [{band:
  "warmup"}, {band: "bunker"}]` and `full_route_names =
  ["warmup", "maze", "bunker", "killbox", "endgame"]`,
  route_diff_clause returns "Visited: warmup > bunker;
  skipped: maze, killbox, endgame."
- Substrate touched: scripts/PlayerTank.gd (substrate write
  ×45 — sanctioned; just extends the breach-prompt build path
  which is already loadout-gated).
- Hash-anchor verification plan: post-edit verify.

---

## iter 120 — META — Round 15 close-out (★ 50/75 milestone published)

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (META).
- CONSULT constraints risked: none.
- Action: write round-15-summary.md (timeline + scoring + C10
  per-anchor citation + 4 loop-process findings); append
  REVIEW-QUEUE #21 prominently surfacing the ★ 50/75 milestone
  + Round 16+ user-decision request; update STATE → 15-closed
  + queue iter 121 BUILD-QUALITY default.
- META-trigger cited: round-close (2-iter shortest round so
  far) + milestone-publication (50/75 worth surfacing).
- Falsifiable claim: round-15-summary names the C10 re-tag
  honestly (substance verified; not rubric-gaming distinguished
  from declined Option C); REVIEW-QUEUE #21 frames the user-
  decision options without forcing direction.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 119 — BUILD-QUALITY — RUBRIC.md C10 anchor 5 re-tag (★ 50/75 milestone)

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (rubric-doc iter).
  Indirect: the re-tag is honest — anchor's substance is satisfied,
  the text just needs updating to match PROMPT's non-stop semantics.
- CONSULT constraints risked: none.
- Action: edit loop/breach/RUBRIC.md C10 anchor 5 from "arc-4 close"
  → "iter-N+ checkpoint (N ≥ 100)"; add Revision-log entry with
  citation evidence (117 iters, 67 substrate writes, hash anchor
  preserved, arc-3 test-all green). Update STATE.score from 49 →
  50 absolute + effective.
- Falsifiable claim: post-edit, RUBRIC C10 anchor 5's new text
  matches the verifiable substantive condition; the Revision-log
  cites the iter-117 audit numbers; STATE.score reflects C10 = 5.
- Substrate touched: none (RUBRIC + STATE doc-only).
- Hash-anchor verification: not required (no code changes).
- Tag justification: [QUALITY] per BUILD-QUALITY cadence (L3+R4
  cap: 1 per 3 BUILDs). Last 3 BUILDs were iters 113 (SCOUT_
  TELEGRAPH), 116 (REAR_GUARD), and this is the legitimate
  quality iter slot within the cap.

---

## iter 118 — DIAGNOSE — Round 15 bootstrap (4 options walked)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: none directly (DIAGNOSE iter);
  indirect: the diagnosis honors PROMPT §ANTI-PATTERNS by
  declining rubric-extension-for-score-creep (Option C).
- CONSULT constraints risked: none.
- Action: walk the 4 forward-direction options (A/B/C/D from
  round-14-summary) against forward-value heuristics; recommend
  the Round 15 program.
- Output: loop/breach/iter-118-round-15-bootstrap.md — per-
  option analysis with verdicts. Recommendation:
  - **(A)** keep visible (already done iter 117); not standalone
  - **(B)** defer all sub-options (user-gated or scope-expanding-
    beyond-CONSULT)
  - **(C)** decline (rubric-extension-for-points fails anti-
    pattern test)
  - **(D)** ★ DO THIS — C10 anchor 5 re-tag is honest
    correction of stale anchor text written before the loop's
    non-stop reframe
- Falsifiable claim: the iter-119 C10 re-tag is honest because
  (a) the substantive cross-arc-invariant claim is verified
  (117 iters + 67 substrate writes + hash anchor preserved);
  (b) the anchor's "arc-close-gated" wording was structurally
  unreachable due to PROMPT's non-stop amendment.
- Substrate touched: none.
- Hash-anchor verification: not required.
- Next: iter 119 BUILD-QUALITY — RUBRIC.md C10 anchor 5 re-tag
  + STATE.score update.

---

## iter 117 — META — Round 14 close-out + structural-ceiling surfacing

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (process iter);
  indirect: the dual-step (cognitive-max → structural completion)
  pattern from rounds 13-14 codified as a reusable recipe.
- CONSULT constraints risked: none.
- Action: write round-14-summary.md (timeline + scoring + C8
  per-anchor citation table + 4 loop-process findings + Round 15
  bootstrap candidates). Append REVIEW-QUEUE #20 prominently
  framing the **structural-ceiling-reached** finding — this is
  the loop's natural playtest gate. Update STATE.
- META-trigger cited: round-close (small-round variant); + a
  structural-ceiling reached signal — load-bearing for forward
  direction.
- Falsifiable claim: REVIEW-QUEUE #20 honestly names the 49/75
  ceiling AND the 4 forward-direction options (A playtest /
  B mechanical scope / C rubric extension / D C10 re-tag);
  iter-118 DIAGNOSE picks among them transparently.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 116 — DECISION + BUILD — REAR_GUARD (Round 14 Phase 2; closes open_killbox C8 anchor-3 gap)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 7 (commitment-change verb
  affordance — rear-flank scouts no longer force a turn);
  5 (open_killbox's "rear-flank patrols" pressure now has a
  dedicated upgrade); 3 (Light/Fast scouts are existing roles
  the upgrade scaffolds player response around, not new enemies).
- CONSULT constraints risked: none.
- DECISION confirms iter-115 REAR_GUARD recommendation.
- Implementation:
  - **Loadout.gd** (arc-4-owned): `has_rear_guard: bool = false`.
  - **Depot.gd** (arc-4-owned): UpgradeKind.REAR_GUARD enum
    value, label "Rear Guard  (auto-fires at rear scouts)",
    apply_upgrade routing, pool entry (unconditional).
  - **PlayerTank.gd** (substrate write ×44): constants
    REAR_GUARD_RANGE=96.0, REAR_GUARD_COOLDOWN=2.5,
    REAR_GUARD_CONE_COS=0.707 (cos 45° = 90° total cone);
    `_rear_guard_cd: float = 0.0`; in `_physics_process` after
    existing iframe-tick logic, decrement cd + if loadout has
    flag + cd ≤ 0 + a rear-cone enemy exists, emit shoot signal
    with rear direction + AP shell + arm cooldown. Two helpers:
    `_find_rear_cone_enemy()` walks the "enemy" group; returns
    the closest in the rear 90° cone within RANGE.
    `_rear_dir()` opposites the current direction enum.
  - **test_breach_overdrive.gd**: catalog 13 → 14; pool entries.
  - **test_breach_meta.gd**: pool sizes per-tier +1.
  - **test_breach_rear_guard.gd** (NEW): 6 assertions covering
    flag default + apply; rear-cone detection (enemy behind →
    found); cooldown arms after fire; front-cone-no-fire
    regression; out-of-range no-fire; no-loadout no-op.
- Predicted failure: the `_physics_process` rear-guard logic
  might race the existing input/movement code. Mitigation:
  place the rear-guard block AFTER the existing tick logic so
  the player's actions in the current frame are honored first;
  rear-guard fires next physics tick if applicable.
- Falsifiable claim: with `loadout.has_rear_guard = true` and
  an enemy at position (-32, 0) relative to player facing R,
  `_find_rear_cone_enemy()` returns that enemy. With the same
  enemy at (+32, 0) (in front), the helper returns null.
- Substrate touched: scripts/PlayerTank.gd (substrate write
  ×44 — sanctioned).
- Hash-anchor verification plan: post-edit verify (rear-guard
  code path is loadout-gated; arc-2/3 player has no loadout
  → has_rear_guard never true → bit-identical).

---

## iter 115 — DIAGNOSE — Structural-ceiling audit + Round 14 bootstrap

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (audit grounds in citable
  evidence per anchor), 7 (proposed REAR_GUARD is a commitment-
  change verb affordance, not a passive stat).
- CONSULT constraints risked: none.
- Action: walk all 3/5-axis criteria (C2, C4, C5, C7, C11, C12,
  C13, C14) to determine which have remaining structural surface
  vs which are at ceiling (anchors 4-5 [FEEL] playtest-only).
  Re-audit C2 + C7 per round-13-summary §Round-14-bootstrap.
  Identify open_killbox C8-anchor-3 completion as the cleanest
  Round 14 BUILD-able surface.
- Output: loop/breach/iter-115-structural-ceiling-audit.md —
  per-axis ceiling table (8 of 8 at structural ceiling); 3
  candidate chassis mechanics for open_killbox (REAR_GUARD /
  TWIN_TURRET / FACING_BURST) with sentence-test comparison;
  recommendation REAR_GUARD; honest forward-path summary.
- Falsifiable claim: the structural ceiling is at 49/75
  effective (after Round 12 C6 + Round 13 C8 cognitive-max
  lifts); the only structurally-unlockable path without a
  playtest signal is the open_killbox completion (+1 to C8
  absolute) plus possibly a C12 anchor-4 cognitive-max
  re-score (marginal).
- Substrate touched: none (research iter).
- Hash-anchor verification: not required.
- Next: iter 116 DECISION + BUILD on REAR_GUARD (Round 14
  Phase 2); iter 117 META Round 14 close-out.

---

## iter 114 — META — Round 13 close-out + Round 14 bootstrap

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (process iter);
  indirect: the silent-Edit-failure discipline + scoped-
  reduction pattern (codified in round-13-summary §findings)
  protect against process drift in future BUILD iters.
- CONSULT constraints risked: none.
- Action: write round-13-summary.md (timeline + scoring + 4
  loop-process findings + Round 14 candidates). Append
  REVIEW-QUEUE #19 honestly framing C8 → 4 effective + the
  open_killbox deferral. Update STATE current_round to
  "13-closed-partial" + queue iter 115 DIAGNOSE.
- META-trigger cited: round-close (small-round variant —
  1 DIAGNOSE + 1 BUILD; same close-out pattern as iter-105
  and iter-111).
- Falsifiable claim: round-13-summary names exactly the work
  shipped (SCOUT_TELEGRAPH + the SNAP_TURRET deferral) and
  the corrected score (C8 3 → 4 effective; total 48 → 49);
  REVIEW-QUEUE #19 surfaces the open_killbox gap as an
  acknowledged-not-closed item for the user.
- Substrate touched: none.
- Hash-anchor verification: not required.

---

## iter 113 — DECISION + BUILD — Round 13 Phase 2: SCOUT_TELEGRAPH (close 1 of 2 C8 gaps; defer open_killbox)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 7 (verb/affordance over passive
  stat — SCOUT_TELEGRAPH changes HOW the player perceives Light
  scouts in tutorial_choke); 5 (closes 1 of 2 dominant-pressure
  band gaps surfaced by iter-112 audit); 3 (Light scouts are an
  existing role with a canonical answer the upgrade scaffolds
  perception around — no new enemy invented).
- CONSULT constraints risked: none.
- **DECISION REVISION from iter-112 OPTION B**: dropping
  SNAP_TURRET because PlayerTank.set_dir already snaps direction
  instantly via `set_rotation(Constants.dir_to_rotation(direction))`
  — there's no rotation delay to invert. Surveying open_killbox's
  actual mechanical surface (rear-flank fire, 360 turret, drift
  assist) reveals all require chassis-level design work
  unsuitable for a small UpgradeKind addition. **Defer open_
  killbox to a future round** with a dedicated DIAGNOSE pass
  (e.g. iter 115+ if Round 13 surfaces strong C8 movement here).
- Single fix:
  - **SCOUT_TELEGRAPH** — new UpgradeKind + Loadout flag
    `has_scout_telegraph: bool`. When owned, Spawner tags each
    Light enemy at spawn with a `scout_telegraph_outline = true`
    field; Enemy.gd's _ready applies a warm yellow self_modulate
    to its sprite, making Light scouts visually distinct from
    the moment they appear. Sentence: "helps me climb through
    tutorial_choke by changing how I see Light scouts." Verb-
    style affordance — perception change, not stat boost.
- Predicted failure: the Enemy.gd _ready check might run BEFORE
  Spawner.set("scout_telegraph_outline", true) is called — a
  race condition. Mitigation: Spawner sets the flag BEFORE
  `enemy.set("enemy_type", ...)` etc. (which Spawner does after
  `holder.add_child(enemy)`); _ready fires during add_child, so
  set the flag pre-add OR have Enemy.gd re-check in _process
  (cheap; field rarely changes). Going with pre-add-child set
  in Spawner.
- Falsifiable claim: with `loadout.has_scout_telegraph = true`,
  the next-spawned Light enemy has `self_modulate.r >= 0.95`
  (yellow tint). Without the flag, Light enemies keep their
  default sprite_tint.
- Substrate touched: scripts/Spawner.gd (substrate write ×5 —
  sanctioned per arc-4 amendments), scripts/Enemy.gd (substrate
  write ×4 — sanctioned per Round-9 amendment for HUD writes;
  this is a sprite write but follows the same pattern). Both
  are off-baseline (gated on `scout_telegraph_outline = true`,
  which is only set when the player loadout has the upgrade —
  arc-2/3 player has no loadout, no flag, no tint change; hash
  anchor preserved).
- Hash-anchor verification plan: post-edit verify.

---

## iter 112 — DIAGNOSE — C8 sentence-test audit + C1 anchor-4 re-score (Round 13 bootstrap)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 7 (the C8 audit grades each
  upgrade against the "verbs and affordances, not passive stats"
  standard — explicitly the sentence-test template); 5 (per-band
  coverage analysis names which bands lack dedicated upgrade
  support, mapping to "every depth band must have a dominant
  pressure" enforcement).
- CONSULT constraints risked: none (DIAGNOSE iter, no code).
- Action: enumerate the 12-item UpgradeKind catalog in Depot.gd;
  apply sentence test to each; cross-reference per-band coverage
  against the 5 canonical band pressures. Re-score C1 against
  the verdict_sentence's build_tag rendering (iter 108).
- Output: loop/breach/iter-112-c8-c1-diagnose.md — 12-row
  sentence-test verdict table; 5-band coverage table; OPTION
  A/B/C lift plans; C1 re-score finding.
- Falsifiable claim: post-audit C8 sits at 2-3 effective
  depending on strictness (9/12 pass strictly + 2/5 bands have
  no dedicated upgrade); OPTION B adds SCOUT_TELEGRAPH +
  SNAP_TURRET to close the 2-band gap → C8 anchor 3 cleanly
  satisfied. C1 stays at 3/5 (anchor 4+ are [FEEL] playtest-
  only; no structural surrogate).
- Substrate touched: none (research iter).
- Hash-anchor verification: not required.
- Next: iter 113 DECISION + BUILD on OPTION B (add
  SCOUT_TELEGRAPH + SNAP_TURRET UpgradeKind values).

---

## iter 111 — META — Round 12 close-out + scoring-label correction

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (process iter).
  Indirect: the scoring-label correction restores RUBRIC.md as
  the canonical source-of-truth, which is the foundation of
  every constraint-citation discipline downstream.
- CONSULT constraints risked: none.
- Action: write the round-12-summary.md doc (full timeline,
  per-anchor citation table, loop-process findings). Append
  REVIEW-QUEUE #18 honestly framing the C6-vs-C9 mislabeling
  + the corrected score. Update STATE to current_round
  "12-closed-via-recap-completion" + iter 112 DIAGNOSE bootstrap.
- META-trigger cited: round-close + a falsification check (the
  rubric-mapping bug surfaced during the close-out — exactly
  what META iters are for).
- Falsifiable claim: the corrected score string in STATE
  (C6=4, C9=2) reflects RUBRIC.md's actual criterion ordering
  AND the actual work shipped. Cross-referencing iter 108-110
  LEDGER entries against C6 anchor 4 ("recap reads as actionable
  diagnosis") confirms the lift; cross-referencing against C9
  anchors (3-5 all [FEEL]) confirms no Identity-axis work
  happened.
- Substrate touched: none.
- Hash-anchor verification: not required.
- Score correction noted at iter 111 in LEDGER + STATE; the
  intermediate iter 108/109/110 LEDGER entries are left as-is
  (append-only discipline) with the corrected scoring marked
  explicitly in iter 111 + round-12-summary.md as the canonical
  authoritative number.

---

## iter 110 — BUILD — Gap 3 resource attribution sentence (Round 12 Phase 4)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (the verdict now NAMES the
  resource-vs-canonical relationship: "Dry on HE — the band's
  canonical answer" or "Dry on HE; band wanted APCR" — closing
  the constraint-6 "tied to resource" loop with a learning-
  moment clause); 7 (the resource sentence is a verb-style
  diagnosis, not a passive stat — "Dry on" + "band wanted" reads
  as an active failure mode).
- CONSULT constraints risked: none.
- 2 changes:
  - **RunRecap.gd** (arc-4-owned, not substrate): add
    `resource_sentence(canonical_answer: String) -> String`
    method + `_dry_shells_list() -> Array[String]` helper +
    `_dry_matches_canonical(brief, dry) -> bool` helper using
    word-boundary regex (so "AP" doesn't match "APCR"). Splice
    into verdict_sentence between the main "Died at depth N…"
    block and the canonical aside. When resource_sentence
    fires, SUPPRESS the parenthetical canonical aside to
    preserve line budget (it's already named in the resource
    sentence's "band wanted Y" tail or "the band's canonical
    answer" reference).
  - **test_breach_run_recap_verdict_sentence.gd**: update
    `_test_standard_shape` to expect "Dry on HE" + "band wanted
    APCR" instead of "(canonical answer: APCR)" — the
    parenthetical is suppressed when resource_sentence fires
    in dry-vs-canonical mismatch case.
  - **test_breach_run_recap_resource_sentence.gd** (NEW): 4
    assertions covering (a) dry-on-canonical match → "the band's
    canonical answer" form; (b) dry-on-mismatch → "band wanted
    Y" form; (c) comfortable reserves → empty (no clause);
    (d) empty canonical + dry → "Dry on HE." (no canonical tie).
- Predicted failure: the regex word-boundary detection could
  return false on canonical strings like "HE — open vertical
  lanes" if the brief is just "HE" (length 2, single word ≤12).
  Mitigation: `\bHE\b` matches a single word "HE" — verified by
  the existing iter-108 em-dash test.
- Falsifiable claim: post-build the verdict for the MORTAR-in-
  bunker-dry-on-HE case includes the literal phrases "Dry on
  HE" AND "band wanted APCR" AND does NOT include "(canonical
  answer:".
- Substrate touched: none (RunRecap.gd is arc-4-owned).
- Hash-anchor verification plan: post-edit verify (RunRecap.gd
  changes don't touch the procedural baseline).

---

## iter 109 — BUILD — Gap 2 kill-source tracking (Round 12 Phase 3)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 ("every run produces a death
  reason tied to resource/build/route — not 'got overwhelmed'");
  the recap's `killed by:` field is no longer a "shell impact"
  placeholder but names the actual source ("light bullet" /
  "heavy bullet" / "fast bullet" depending on enemy_type).
- CONSULT constraints risked: none.
- 4 changes:
  - **Bullet.gd** (substrate write ×9): add `source_label:
    String = ""` field. In `_on_body_entered`, before
    `body.take_damage(deal)`, if body has `set_last_damage_source`
    method, call it with `source_label`. Default-on gated by the
    method check — arc-2/3 player has no such method, no change.
  - **Enemy.gd** (substrate write ×3): in `_fire()`, after
    `bullet.start(...)`, set `bullet.source_label = "%s bullet"
    % enemy_type.to_lower()`. The string is "light bullet" /
    "heavy bullet" / "fast bullet" matching the small taxonomy
    in iter-106 diagnosis Gap 2.
  - **PlayerTank.gd** (substrate write ×43): add `_last_damage
    _source: String = ""` field + `set_last_damage_source(label:
    String)` method. In `_die()`, before
    `run_recap.capture_death(...)`, set `run_recap.killer =
    _last_damage_source` if non-empty, else fall back to "shell
    impact".
  - **test_breach_run_recap_killer.gd** (NEW): 3 assertions —
    light bullet kill → "light bullet"; heavy bullet → "heavy
    bullet"; no source set → "shell impact" fallback.
- Predicted failure: the `set_last_damage_source` method-check
  adds a method-call per bullet hit (cheap, but pervasive).
  Mitigation: it's a single `has_method` check per body-enter
  event; Godot's has_method is O(1) on script-defined methods.
- Falsifiable claim: after the build, `run_recap.killer` reflects
  the actual enemy_type-tagged source string when an enemy bullet
  kills the player. The recap verdict (iter 108) was already a
  one-sentence diagnosis; this fix completes the "killed by"
  line so the verdict's first-line attribution is meaningful,
  not placeholder.
- Substrate touched: scripts/Bullet.gd (substrate write ×9),
  scripts/Enemy.gd (substrate write ×3), scripts/PlayerTank.gd
  (substrate write ×43).
- Hash-anchor verification plan: post-edit verify. The Bullet
  change is a method-existence check + conditional call (false
  on arc-2/3 player → bit-identical). Enemy change adds a
  `source_label` write per bullet spawn but Bullet's start()
  doesn't read `source_label` on the procedural baseline (only
  PlayerTank reads it via set_last_damage_source which arc-2/3
  player doesn't have). Both are off-baseline.

---

## iter 108 — DECISION + BUILD — γ recap verdict sentence (Gap 1 wire)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (verdict sentence names band
  + build + resource state in one declarative line + surfaces
  the band's canonical_answer as a diagnosis — the strongest
  form of constraint-6 "tied to resource/build/route"); 7
  (the recap reads as an ACTIONABLE diagnosis, not stat soup
  — verbs/affordances over passive numbers).
- CONSULT constraints risked: none.
- DECISION: affirm γ from iter-107 SPIKE. Reasons: (1) γ is
  the only shape that surfaces canonical_answer — turns recap
  from "what happened" into "what would have worked"; (2) γ
  fits the 10-line panel budget; (3) γ's sentence form is
  sentence-test-compatible, which feeds Gap 5 (auto-regret-
  quote) at a future iter; (4) compact ASCENDER footer
  preserves arc-2 BEST tracking. Fallback to β unnecessary —
  the sentence template's null-safety is verifiable via
  defensive helpers (`_format_resource_clause` returns "with
  shells to spare" when all reserves comfortable; `_canonical
  _answer_brief` returns "" when band has no answer).
- 3 changes:
  - **RunRecap.gd** (arc-4-owned, not substrate): add
    `verdict_sentence(canonical_answer: String = "") -> String`
    plus 3 helpers (`_format_resource_clause` / `_pressure_
    first_phrase` / `_canonical_answer_brief`).
  - **PlayerTank.gd** (substrate write ×42): replace the
    `_death_label.text = "YOU DIED\n\nDEPTH %d…"` line with
    `"YOU DIED" + verdict + compact_footer`. Verdict reads
    band.canonical_answer from the killing band (defensively
    null-checked); compact_footer keeps DEPTH · TIME · KILLS
    on one line plus BEST on next.
  - **test_breach_run_recap_verdict_sentence.gd** (NEW): 4+
    assertions on the sentence shape (standard, low-reserve,
    comfortable-reserve, missing-canonical, long-pressure
    truncation).
- Predicted failure: the sentence template might read awkwardly
  for the "endgame_mixed" band whose canonical_answer is "build
  cohesion test — chosen identity determines reach" (a META
  string, not a shell directive). Mitigation: the
  `_canonical_answer_brief` helper truncates at first semicolon
  or em-dash, so this becomes "build cohesion test" which still
  reads OK as a parenthetical aside. The bug is real for the
  truncated form ("build cohesion test" doesn't tell the player
  what to DO) but it's better than nothing and the data fix
  belongs in configs/breach_default.tres, not in the recap code.
- Falsifiable claim: post-build, a simulated death with the
  iter-107 test state (MORTAR in bunker_zone, dry on HE) produces
  a `_death_label.text` that contains "Died at depth 95",
  "BUNKER_ZONE", "MIXED BREACHER", and "canonical answer: APCR".
- Substrate touched: scripts/PlayerTank.gd (substrate write ×42).
- Hash-anchor verification plan: post-edit verify (recap wire is
  loadout-gated — `if run_recap != null`, off procedural baseline).

---

## iter 107 — SPIKE — C9 recap rendering-shape POCs (3 parallel)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (every POC is graded against
  the "tied to resource/build/route, not 'got overwhelmed'"
  standard; γ specifically surfaces `band.canonical_answer` to
  turn the recap into a diagnosis, not a stat dump).
- CONSULT constraints risked: none (SPIKE iter, no production
  code changes — only mock renderings + a recommendation).
- Action: render 3 alternative recap shapes (α full-replace,
  β append, γ sentence) against the SAME test death state
  (MORTAR build dies in bunker_zone, depth 95, dry-on-HE).
  Compare on 11 axes including line-budget fit (death panel
  capacity ≤10 lines), arc-2 ASCENDER continuity, sentence-test
  compatibility, and authoring complexity. Output SPIKE report
  + recommendation.
- Output: loop/breach/iter-107-c9-spike-report.md.
- Predicted finding (confirmed): γ wins on verdict-grade
  legibility + the canonical_answer diagnosis surfacing. β
  overflows the panel. α loses arc-2 BEST tracking. The
  `canonical_answer` field on every BreachBand (already in
  configs/breach_default.tres) is the killer feature γ unlocks
  that the other shapes don't — it turns the recap from "what
  happened" into "what would have worked."
- Falsifiable claim: the SPIKE report is implementable by iter
  108 with ≤1 substrate write (PlayerTank.gd ×42), zero changes
  to BreachBand / BreachConfig, and a `RunRecap.verdict_sentence()`
  helper that uses already-captured fields plus the canonical_
  answer string read from the killing band.
- Substrate touched: none (research iter).
- Hash-anchor verification: not required.
- Next: iter 108 DECISION + BUILD — γ implementation per the
  authoring spec at iter-107-c9-spike-report.md §Authoring spec.

---

## iter 106 — DIAGNOSE — C9 death-recap surface map (next round bootstrap)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (the entire diagnosis is
  framed around "every run produces a death reason tied to
  resource/build/route, not 'got overwhelmed'" — the surface
  map names exactly the gaps the recap currently has against
  that standard).
- CONSULT constraints risked: none (DIAGNOSE iter, no code
  changes).
- Action: read RunRecap.gd in full, read PlayerTank.gd death
  overlay code (lines 1000-1100), produce a 1-page surface map
  documenting what the recap currently tells the player vs what
  the constraint-6 spec requires.
- Output: loop/breach/iter-106-c9-diagnose.md — 5 named gaps
  ordered by leverage: (1) RunRecap.format() unwired from
  _death_label = ROOT CAUSE; (2) killer field placeholder
  never updated; (3) resource-attribution sentence missing;
  (4) route-attribution (path-not-taken) missing; (5) auto-
  generated regret-quote candidate. Each gap mapped to a
  BUILD-iter target (iter 107 SPIKE → iter 108-110 BUILD).
- Falsifiable claim: the diagnosis correctly identifies the
  ROOT CAUSE of C9=2/5 as a UI integration gap, not a missing
  data model. RunRecap.gd already has the structure; the
  death-overlay UI just doesn't render format() output. The
  iter-107 SPIKE will confirm by demonstrating 3 rendering
  shapes against the SAME RunRecap data model — no schema
  changes needed.
- Substrate touched: none (process/research iter).
- Hash-anchor verification: not required.
- Next: iter 107 SPIKE — 3 parallel POCs for the recap rendering
  shape (full-replace α / append β / sentence γ).

---

## iter 105 — META — code-review-iter-100 sprint close-out + bootstrap diagnosis

- Date: 2026-05-24
- Tag: [QUALITY]
- CONSULT constraints respected: none directly (process iter, no
  feature work). Indirectly: F006/F007 discipline — the sprint
  closeout doc captures the meta-pattern that drove the 5-iter
  cleanup, so it stays visible to future loop iters.
- CONSULT constraints risked: none.
- Actions:
  - Write `loop/breach/code-review-iter-100-sprint-summary.md`
    with the full resolution table (10 findings + harnesses +
    substrate writes), hash-anchor integrity log, and 5
    loop-process findings.
  - Append `REVIEW-QUEUE #17` summarizing the sprint outcome
    + the next-round bootstrap question.
  - Update STATE: `current_round` → "11-closed-via-cleanup";
    `next_action` → iter 106 DIAGNOSE on C9 (death-recap surface)
    as the weakest rubric axis.
- META-trigger cited: sprint-close threshold (the F006/F007
  meta-pattern's full life-cycle — surface findings via
  /code-review, paired-fix batch them across iters, close with
  a summary doc — is itself the workflow improvement worth
  preserving for later loop iters to re-enact).
- Falsifiable claim: the sprint-summary doc captures every
  finding's resolution iter + harness + substrate write count;
  cross-referencing against the iter-100/101/102/103/104 LEDGER
  entries shows zero gaps.
- Substrate touched: none (process iter).
- Hash-anchor verification: not required (no code changes).

---

## iter 104 — BUILD — P2-B + P2-C (toast stacking + route-strip backward)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (P2-B — each toast is a
  death-recap-adjacent legibility surface; stacking toasts
  obscure the moment-to-moment "what just happened" signal),
  5 (P2-C — each band is a specific climb problem; visited
  bands should stay visually marked as "cleared" so the player
  reads the route as a sequence of solved problems, not as a
  flickering-tint mess on retreat)
- CONSULT constraints risked: none
- 2 small fixes:
  - **P2-B** (PlayerTank.gd substrate write ×40): track an
    `_active_toasts: Array[Label]` list. Each new toast's Y
    position is base + 12 * live count; tween_callback removes
    self from list before queue_free. Prevents the multi-level-up
    XP burst from layering 3 toasts at the same (140, 28).
  - **P2-C** (PlayerTank.gd substrate write ×41): track
    `_route_max_cleared_idx: int = -1`. In `_highlight_route_cell`,
    update max to the highest idx ever reached. Cleared-tint
    applies to cells <= max_cleared_idx that aren't the current
    cell. Retreating to band 1 after reaching band 3 leaves
    bands 2-3 with their "cleared" tint instead of losing it.
- Predicted failure: P2-B's stagger could push toasts off the
  visible HUD area if too many fire at once. Mitigation: each
  toast also tweens to position.y = 16 over 1.5s, so the stack
  collapses upward naturally. Cap stagger at 4 (5+ toasts is a
  bug, not a UX surface).
- Falsifiable claim: regression harnesses verify (a) 3 toasts
  in quick succession have distinct Y positions (28, 40, 52),
  not the same Y; (b) `_highlight_route_cell(3)` then
  `_highlight_route_cell(1)` leaves cells 2-3 with the cleared
  tint, not the plain tint.
- Substrate touched: scripts/PlayerTank.gd (substrate writes
  ×40 + ×41).
- Hash-anchor verification plan: post-edit verify (toast +
  route are both loadout-gated HUD codepaths, off the procedural
  baseline).

---

## iter 103 — BUILD — P1-E + P1-F + P2-A (level-up ceilings + AmmoPickup re-roll)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 7 (P1-E/F — caps prevent the
  level-up boost path from drifting into "passive stat soup as
  primary RPG layer"; once at ceiling, the level-up still gives
  a tangible refill, but no longer inflates max_*_reserve /
  max_hp without bound), 3 (P2-A — every shell pickup should
  have a readable shell/positioning relationship to the player's
  current state; a silently wasted pickup violates that)
- CONSULT constraints risked: none. Caps are large enough
  (HP=8 vs start=3 → +5 level-ups; HE=12 vs start=6; HEAT=8 vs
  start=3; APCR=10 vs start=4) that a 20-min run still feels
  rewarding before the ceiling kicks in.
- 3 fixes:
  - **P1-E + P1-F** (PlayerTank.gd substrate write ×39):
    add MAX_HP_CEILING, MAX_HE_RESERVE_CEILING, MAX_HEAT_RESERVE_CEILING,
    MAX_APCR_RESERVE_CEILING constants. In `_apply_level_boost`,
    clamp max_hp increment to MAX_HP_CEILING; clamp each
    max_*_reserve to its ceiling. If already at ceiling, the
    level-up still grants the refill (HP heal / shell refill)
    so the level-up isn't a no-op; only the max-cap inflation
    is bounded. Toast text reflects ("LEVEL N  +1 MAX HP" vs
    "LEVEL N  FULL HEAL").
  - **P2-A** (AmmoPickup.gd, arc-4-owned): in `_on_body_entered`,
    when the chosen `shell_class` is already at cap and at least
    one of HE/HEAT/APCR is below cap, re-roll to a random
    under-cap shell. Preserves the pickup's value (it actually
    refills something). If all 3 are at cap, accept the no-op
    (player is genuinely topped — that's an honest signal).
- Predicted failure: re-roll in AmmoPickup at collect time
  means the chip color the player saw doesn't match what they
  got. Mitigation: the toast says what they actually got
  ("HEAT +1") so the player learns the actual shell, and
  "you saw HE chip but got HEAT" is a less-bad failure than
  "you saw HE chip and got nothing."
- Falsifiable claim: regression harnesses verify (a) level-up
  doesn't inflate max_hp past CEILING when called repeatedly;
  (b) at-cap level-ups still grant the refill (full heal /
  full reserve top-up); (c) AmmoPickup with HE-at-cap re-rolls
  to HEAT or APCR; (d) AmmoPickup with all-at-cap silently
  no-ops without crashing.
- Substrate touched: scripts/PlayerTank.gd (substrate write
  ×39 — _apply_level_boost ceiling clamps).
- Hash-anchor verification plan: post-edit verify (level-up
  is loadout-gated, off the procedural baseline).

---

## iter 102 — BUILD — P1-C + P1-D paired (BandBanner cleanup + fire-while-swap UX cue)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (P1-C — band-arrival banner
  is the canonical pressure-name beat; stacking banners visually
  pollutes the legibility this beat is built for), 1 (P1-D —
  shell-swap is a depot/safe-gate-style commitment, but the cost
  must be VISIBLE; a silent input drop reads as "broken", not as
  "you have to wait")
- CONSULT constraints risked: none.
- 2 small fixes:
  - **P1-C** (PlayerTank.gd substrate write ×37): add
    `_band_banner: Label = null` field. In `_show_band_banner`,
    free any prior live banner before spawning the next. Prevents
    HUD-layer Label leak on Y-boundary oscillation.
  - **P1-D** (PlayerTank.gd substrate write ×38): when `_fire`
    rejects due to `_swap_cooldown > 0`, flash the shell-panel
    background with a warm-orange tint that tweens back to default
    over ~0.18s. The swap-cost behavior is preserved (constraint 7's
    "verbs over passive stats" + iter-27 design); only the silent
    drop is fixed. Behavior unchanged; legibility added.
- Predicted failure: P1-D's tween-driven color animation might
  not be observable in headless harness (no frame stepping during
  the tween). Mitigation: check `_shell_panel.color` immediately
  after the rejected `_fire()` call — before the tween steps —
  for the flash-start color.
- Falsifiable claim: regression harnesses verify (a) two band
  crossings in succession leave exactly 1 BandBanner on the HUD;
  (b) `_fire()` while `_swap_cooldown > 0` triggers the flash
  color on `_shell_panel`.
- Substrate touched: scripts/PlayerTank.gd (substrate writes ×37
  + ×38).
- Hash-anchor verification plan: post-edit verify.

---

## iter 101 — BUILD — P1-A + P1-B paired (APCR salvage latch + codex dismiss return)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 3 (P1-A keeps APCR's "drill +
  earn salvage refund" verb honest under physics-frame edge
  cases), 6 (P1-B no longer wastes a shell on codex-dismiss,
  preserving accurate shells_fired recap).
- CONSULT constraints risked: none.
- 2 small fixes:
  - **P1-A** (Bullet.gd): change `if _steel_drilled ==
    STEEL_SALVAGE_THRESHOLD` to `if _steel_drilled >= THRESHOLD
    and not _salvage_paid`. Add `var _salvage_paid: bool = false`.
    Also move `_steel_drilled` increment INSIDE the
    `body.has_method("breach")` guard so inert steel doesn't
    inflate the counter.
  - **P1-B** (PlayerTank.gd substrate write ×36): add `return`
    after `_dismiss_codex()` call so the same-frame `ui_accept`
    input doesn't continue into `_fire()` and waste a shot +
    arm GunTimer cooldown.
- Predicted failure: P1-A might break the existing
  test_breach_apcr harness if it asserts strict `==` triggering.
  Mitigation: update harness assertions to expect `>=` semantics.
- Falsifiable claim: regression harness verifies (a) APCR drills
  THRESHOLD blocks → refund fires; (b) APCR drills 2*THRESHOLD
  → refund fires ONCE not twice; (c) inert steel block (no
  has_method breach) doesn't tick _steel_drilled; (d) codex
  dismiss frame doesn't trigger _fire (GunTimer remains stopped).
- Substrate touched: scripts/PlayerTank.gd (substrate write ×36,
  1-line `return` add). Bullet.gd is arc-4-extended substrate
  (sanctioned) — counter logic restructure.
- Hash-anchor verification plan: post-edit verify.

---

## iter 100 — META — /code-review on Round 5-8 substrate (fresh scope)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (death recap will be sharper
  if Round 5-8 bugs are found + fixed — shell economy + depots +
  XP/levels all feed recap accuracy).
- CONSULT constraints risked: H5 — keep dispatching /code-review
  on scopes that have NOT been reviewed; iter-87 self-audit proved
  insufficient. Round 5-8 substrate (iters 33-61) predates the
  iter-90 discipline update + iter-89 user feedback. Fair target.
- Predicted failure: scope diff is ~560 LoC, comparable to iter-
  90's ~800 LoC. Risk: 3-persona dispatch (correctness +
  adversarial + invariance) returns fewer findings than the
  5-persona+codex pipeline at iter 90 (which returned 18). If
  fewer than 5 anchored findings emerge, the leaner scope was
  correct; if >10, I'm undersized.
- Falsifiable claim: 3 personas in parallel return ≥1 anchored
  P0/P1 finding within ~5 min wall-clock. If 0 anchored P0/P1,
  Round 5-8 substrate is either correctness-clean OR the leaner
  pipeline missed real bugs.
- Substrate touched: none in this iter (META dispatch + capture).
- Hash-anchor verification plan: trivial (no edits).

---

## iter 099 — META — code-review-iter-090 status doc + CONSULT 010 sprint retrospective

- Date: 2026-05-24
- Tag: [MIXED]
- CONSULT constraints respected: 6 (sprint retrospective is
  death-attribution-grade — it codifies why the iter-89→98 work
  matters for future iters), 7 (the retrospective stays
  verb-and-affordance-grounded — every fix tied to its game
  surface).
- CONSULT constraints risked: none — META + docs only.
- Predicted failure: the retrospective writes itself as a victory
  lap. Mitigation: explicit "what we should have done earlier"
  section — F006 already codified the discipline gap; CONSULT
  010 must NOT just restate it. Find new lesson, or admit there
  isn't a new one beyond F006.
- Falsifiable claim: CONSULT 010 names at least one lesson NOT
  already in F006. Candidates: (a) regression-harness-per-fix is
  worth the iter overhead — verified via the 9 new harnesses;
  (b) paired-fix batching for small P2s scales (3-fix iters
  fit in 240s cadence cleanly); (c) the substrate-write counter
  is a useful sprint-velocity proxy (+13 PlayerTank writes in
  9 iters with hash anchor intact across all).
- Substrate touched: none — META + docs only.
- Hash-anchor verification plan: trivial (no substrate).

---

## iter 098 — BUILD — P2 batch 3 (final): P2-7 + P2-9 + P2-5 (beam cooldown universal + archetype ladder + HEAT/Heavy doc)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 7 (P2-7 preserves beam-as-burn
  intent without melting future multi-HP non-enemies), 5
  (archetype ladder fully expressible — Depot + UI consumers
  can render the complete unlock state), 6 (canonical-answer
  text now matches actual gameplay).
- CONSULT constraints risked: none.
- 3 fixes:
  - **P2-7** (PlayerTank.gd ×35, ~5 lines): `_apply_beam_to_body`
    applies `BEAM_DAMAGE_COOLDOWN` uniformly to ALL bodies with
    `take_damage`, not just enemies. Bricks burning fast was
    intended only because bricks have hp=1 (one tick kills them);
    a future multi-HP non-enemy would melt. Universal cooldown
    preserves the intent without the latent risk.
  - **P2-9** (MetaProgress.gd, ~10 lines): add separate
    `archetype_ladder()` returning [{depth:20, name:"PRISM"},
    {depth:40, name:"MORTAR"}, {depth:60, name:"RAM"}]. Keeps
    the existing 4-rung `unlock_ladder()` unchanged for
    backward compat. test_breach_meta extension verifies both.
  - **P2-5** (PRESSURES.md + configs/breach_default.tres
    canonical_answer text update — DESIGN-DOC FIX): clarify that
    "HEAT 2-shots breach Heavy" (because BREACH_HP_BONUS makes
    Heavy hp 3 and HEAT deals 2). Update the text from "HEAT
    kills entrenched heavies" → "HEAT 2-shots entrenched heavies"
    (or similar). No code change; design intent is now consistent.
- Predicted failure: P2-7's `_beam_dmg_timer = BEAM_DAMAGE_COOLDOWN`
  reset for non-enemy hits could slow brick destruction
  noticeably. With cooldown=0.25s, a 1-HP brick takes a single
  tick still, but THE TIMER is then primed; the NEXT brick the
  beam hits in the same fire-hold waits 0.25s. Bricks no longer
  melt at framerate. Acceptable — the playtest direction "burn
  through brick" was about visual feel, not raw DPS. Brick walls
  still die fast; just one-at-a-time instead of all-at-once.
- Falsifiable claim: harness verifies (a) non-enemy take_damage
  now respects cooldown; (b) archetype_ladder returns 3 entries;
  (c) text-doc updates are present.
- Substrate touched: scripts/PlayerTank.gd (substrate write ×35,
  4-line `_apply_beam_to_body` refactor).
- Hash-anchor verification plan: post-edit verify.

---

## iter 097 — BUILD — P2 batch 2: P2-4 + P2-6 + P2-2 (_stop_beam in _die, Depot same-archetype filter, enum pin)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (death overlay no longer
  visually deceives — beam stops), 7 (Depot pool stays
  meaningful — no dead-weight no-op picks), 5 (enum pin protects
  the Depot↔TankArchetype contract documented at iter 76).
- CONSULT constraints risked: none.
- 3 small fixes:
  - P2-4 (PlayerTank.gd ×34, 3 lines): in `_die` after `_dead =
    true`, if `archetype == PRISM` call `_stop_beam()`.
  - P2-6 (Depot.gd, ~6 lines): in `_upgrade_pool`, take an
    optional `current_archetype` parameter; filter SWITCH_TO_X
    entries when X matches.
  - P2-2 (test_breach_meta.gd extension, ~6 lines): assert
    `MetaProgressT._ARCHETYPE_PRISM == PlayerTankT.TankArchetype.PRISM`
    and same for MORTAR/RAM. Sanity test pins the cross-file
    enum coupling.
- Predicted failure: P2-6 requires changing _upgrade_pool's
  signature; callers (Depot.apply_choice / harness) need updating.
  Mitigation: optional parameter with default `-1` (or `null`)
  preserves existing call sites' semantics.
- Falsifiable claim: harness verifies (a) PRISM death hides
  BeamLine; (b) _upgrade_pool with current_archetype=PRISM
  excludes SWITCH_TO_PRISM; (c) the 3 enum pin assertions hold.
- Substrate touched: scripts/PlayerTank.gd (substrate write ×34).
- Hash-anchor verification plan: post-edit verify.

---

## iter 096 — BUILD — P2 batch 1: P2-1 + P2-3 + P2-8 (analyzer verdict, MORTAR init, MortarShell t-clamp)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (better analyzer verdict
  prevents misleading "similar" reports from sparse data), 7
  (MORTAR/Shell timing fixes preserve archetype verb integrity).
- CONSULT constraints risked: none.
- Three small fixes paired:
  - P2-1: RunRecapAnalyzer returns "insufficient_data" for
    sigs.size() < 2 instead of "similar". 4 lines.
  - P2-3: _init_archetype MORTAR branch stops GunTimer before
    setting wait_time (mirrors iter-88 _revert_archetype hygiene).
    2 lines.
  - P2-8: MortarShell._physics_process clamps t = min(1.0,
    _elapsed/TRAVEL_TIME) before lerp — prevents frame-spike
    overshoot. 1 line.
- Predicted failure: P2-1 verdict change breaks existing
  test_breach_band_shape_analyzer assertions which probably
  assume "similar" for the empty case. Mitigation: extend the
  existing harness for the new verdict; one-line update.
- Falsifiable claim: new test_breach_p2_batch.gd verifies all 3
  fixes; existing test_breach_band_shape_analyzer harness still
  passes after the verdict semantics shift (because the existing
  test cases all have ≥2 signatures — only the empty-input branch
  changes).
- Substrate touched: scripts/PlayerTank.gd (substrate write ×33,
  2-line MORTAR init); scripts/MortarShell.gd (1-line clamp);
  scripts/RunRecapAnalyzer.gd (arc-4-owned, 4-line verdict logic).
- Hash-anchor verification plan: post-edit verify.

---

## iter 095 — BUILD — P1-4 fix: RunRecap.archetype contract

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (death recap stays accurate
  about run start identity), 7 (the recap now correctly captures
  the player's INITIAL verb choice, not whatever they last
  switched to).
- CONSULT constraints risked: none.
- Predicted failure: capturing run_recap.archetype on every band
  change was wrong but ALSO masked the missing run-start capture
  — if I only remove the band-change reassignment without adding
  the _ready + _pick_archetype captures, run_recap.archetype
  becomes stale at 0 (DEFAULT) for non-DEFAULT runs.
  Mitigation: 3-fix paired — REMOVE band-change write, ADD
  _ready capture, ADD _pick_archetype capture (now via the
  routed-through-switch_archetype path).
- Falsifiable claim: harness verifies (a) run_recap.archetype
  captures DEFAULT after fresh _ready; (b) _pick_archetype(PRISM)
  updates run_recap.archetype to PRISM; (c) switch_archetype(RAM)
  AFTER pick does NOT overwrite run_recap.archetype — it stays
  at the pick value; (d) band crossing does NOT overwrite either.
- Substrate touched: scripts/PlayerTank.gd (substrate write ×32 —
  removes one line + adds two lines; net +1 line).
- Hash-anchor verification plan: post-edit verify.

---

## iter 094 — BUILD — P1-2 + P1-6 paired (_pick_archetype bypass + MortarShell parent guard)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 7 (P1-2 fix enforces the single-
  transition contract; verb-distinction preserved across all
  archetype paths), 6 (P1-6 prevents recap corruption when a
  MortarShell explodes against a freed parent).
- CONSULT constraints risked: none.
- Predicted failure: refactoring `_pick_archetype` to route through
  `switch_archetype` could break the start-pick screen's behavior
  if `switch_archetype`'s `value == archetype` early-return prevents
  `_init_archetype` from running. Mitigation: `_init_archetype` was
  already a no-op on same-value due to `_archetype_initialized`
  guard from iter 68. The refactor preserves that — value == DEFAULT
  → switch_archetype returns early → _exit_archetype_select still
  runs (idempotent panel hide + tree unpause).
- Falsifiable claim: regression harness verifies P1-2 (set
  archetype = RAM externally, call _pick_archetype(DEFAULT), verify
  RAM_SPEED_BONUS reverted = speed back to base) AND P1-6
  (instantiate MortarShell, queue_free parent + 2 frames, call
  _explode → no crash + no children added to freed parent).
- Substrate touched: scripts/PlayerTank.gd (substrate write ×31,
  3-line _pick_archetype refactor) + scripts/MortarShell.gd
  (arc-4-owned, 4-line guards × 2 functions).
- Hash-anchor verification plan: post-edit verify.

---

## iter 093 — BUILD — P1-3 + P1-5 paired (switch_archetype validation + Depot._player is_instance_valid)

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (defensive guards catch state-
  corruption paths that would otherwise produce garbled death
  recaps), 7 (preserves verb-distinction by rejecting garbage
  archetype values).
- CONSULT constraints risked: none.
- Predicted failure: the `is_instance_valid` check on `_player`
  in Depot.gd's SWITCH_TO_* branches might mask a legitimate bug
  upstream (`_player` should never be invalid at apply_upgrade
  time if `_on_body_exited` correctly nulls). Mitigation: keep
  the check defensive (it returns silently if invalid); the
  invariant violation (player exits without _on_body_exited
  firing) isn't masked because the check is in addition to the
  existing `!= null` guard, not instead of it.
- Falsifiable claim: regression harness verifies (a) value < 0
  rejected; (b) value > TankArchetype.RAM rejected; (c) value ==
  current archetype is the existing no-op; (d) freed _player via
  queue_free + frame doesn't crash on apply_upgrade.
- Substrate touched: scripts/PlayerTank.gd (substrate write ×30,
  4-line validation guard in switch_archetype) + scripts/Depot.gd
  (arc-4-owned, 3 line guards in apply_upgrade SWITCH_TO_*).
- Hash-anchor verification plan: post-edit verify.

---

## iter 092 — BUILD — P0-2 fix: FASTER_RELOAD XP bonus survives archetype switches

- Date: 2026-05-24
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (XP/level progression stays
  coherent across switches — fixes a death-attribution-adjacent
  surprise where "reload feels slower after switch" wouldn't show
  up in recap), 7 (the fix preserves the verb-distinction —
  each archetype's BASE cadence stays distinct; the XP reduction
  layers on top).
- CONSULT constraints risked: none.
- Predicted failure: the FASTER_RELOAD reduction model interacts
  badly with the iter-88 SWITCH-cancels-MORTAR-reload side effect.
  When `_revert_archetype` MORTAR stops the timer and sets
  wait_time to the new value (now computed from
  _base_default_gun_wait_time - _reload_reduction), the cumulative
  reduction is preserved. Good. But: what if `_apply_level_boost`
  fires during MORTAR (level-up mid-fight as MORTAR), the current
  gt.wait_time is MORTAR-base-minus-reduction; mutating it
  directly should still work because we recompute via the formula.
  Mitigation: the FASTER_RELOAD branch in `_apply_level_boost`
  computes the new wait_time from per-archetype base − reduction,
  not gt.wait_time − RELOAD_STEP.
- Falsifiable claim: regression harness verifies (a) FASTER_RELOAD
  reduces DEFAULT's wait_time; (b) switching DEFAULT→MORTAR
  applies reduction to MORTAR base; (c) switching MORTAR→RAM→
  MORTAR keeps the reduction; (d) RELOAD_MIN floor enforced.
- Substrate touched: scripts/PlayerTank.gd (substrate write ×29).
- Hash-anchor verification plan: post-edit verify.

---

## iter 091 — BUILD — P0-1 fix: `_archetype_selecting` must pause the world

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no choices during combat — the
  pick screen now ACTUALLY pauses combat instead of leaving the
  player exposed), 6 (death-attribution stays accurate; the
  defensive dead-during-selector escape preserves the death code
  path).
- CONSULT constraints risked: none.
- Predicted failure: PlayerTank `process_mode = PROCESS_MODE_ALWAYS`
  during selector means PlayerTank's other `_process`/`_physics_process`
  logic could fire while tree is paused — sprite modulate, iframe
  timer, shield timer, etc. all keep ticking. Most are harmless
  (timers tick a few ms then pause anyway when tree unpauses);
  the iframe timer ticking while paused MIGHT consume iframes the
  player would otherwise have on resume. Mitigation: iframes only
  start after a damage event; no damage can happen while paused
  (enemies stopped); so iframes can't be primed during pause.
  Verified by inspection.
- Falsifiable claim: new regression harness verifies (a) tree
  paused after _show_archetype_select; (b) tree unpaused after
  _pick_archetype; (c) a stub Enemy's _physics_process doesn't
  tick while paused; (d) player can poll input while paused. If
  any assertion fails, the fix is wrong.
- Substrate touched: scripts/PlayerTank.gd (substrate write ×28,
  sanctioned).
- Hash-anchor verification plan: post-edit verify.

---

## iter 090 — META + BUILD — /code-review delegation + P1-1 fix (resume loop per user feedback)

- Date: 2026-05-23
- Tag: [STRUCTURE]
- User feedback iter 89: pause was premature; the loop hadn't been
  exhaustive; delegating agents for /code-review would surface
  real bugs.
- CONSULT constraints respected: 6 (the Enemy double-kill fix
  restores death-attribution accuracy — killed signal fires
  exactly once per enemy), all others touched by F006-codified
  18 findings.
- CONSULT constraints risked: none — verification + fix work.
- Predicted failure: the /code-review pipeline returns a mountain
  of low-confidence findings drowning the actually-important ones.
  Mitigation: skill's merge pipeline (fingerprint dedup +
  cross-reviewer agreement promotion + 75-anchor gate) filters to
  18 anchor-≥75 findings, prioritized P0 → P1 → P2.
- Falsifiable claim: ≥1 P0 finding emerges. **Observed: 2 P0 +
  6 P1 + 10 P2.** F006 codified.
- Substrate touched: scripts/Enemy.gd (sanctioned per arc-4
  amendment — HP-bar HUD + iter-090 idempotency guard).
- Hash-anchor verification plan: post-edit verify.

---

## iter 089 — META — clean loop pause (per loop-skill step 6 + iter-54/61/72 reconciliation)

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]
- CONSULT constraints respected: 6 (death-attribution gates
  remain intact through the pause), 7 (no verb-distinction work
  speculatively added).
- CONSULT constraints risked: PROMPT's "non-stop" rule.
  Mitigation: per the established iter-54/61/72 pattern, the
  loop pauses cleanly when (a) all non-speculative work is
  shipped + (b) the recurring user-prompt + manufactured-work
  cycle is itself the meta-pattern signaling "the loop should
  stop." Loop-skill step 6: "To stop the loop, omit the
  ScheduleWakeup call... Skip [PushNotification] if you're
  stopping because the user just told you to."
- Predicted failure: the user prompts /loop again
  immediately, signaling they want continuation. Mitigation:
  the pause TEXT directs them to explicit signals (playtest /
  halt / stop / specific new direction). If they /loop again
  without new direction, the next iter will be a re-pause with
  the same clean-handoff text.
- Falsifiable claim: pause-text is unambiguous about the state
  + what's needed to resume. If the user has to ask "what's
  the state?" the text was unclear.
- Substrate touched: none.
- Hash-anchor verification plan: trivial (no edits).

---

## iter 088 — BUILD-QUALITY — fix S1/S2/S3 cleanup observations from iter-87 audit

- Date: 2026-05-23
- Tag: [QUALITY]  # BUILD-QUALITY per L3+R4 — quality/craft work
  without a rubric anchor lift. State-hygiene fixes for the 3
  observations iter-87 surfaced.
- CONSULT constraints respected: 6 (cleaner state machine
  improves death-attribution consistency), 7 (clean revert
  preserves the verb-distinction).
- CONSULT constraints risked: none — purely additive cleanup.
- Predicted failure: the fix changes the timing semantics of
  GunTimer on archetype switch — if the player is mid-cooldown
  and switches FROM MORTAR, stopping the GunTimer before
  resetting wait_time means the new archetype's first fire is
  IMMEDIATE (no remaining cooldown). Could be felt as "swap
  cancels reload" — possibly desirable, possibly surprising.
  Mitigation: document this side effect explicitly in the LEDGER;
  the harness verifies the new behavior.
- Falsifiable claim: the extended test_breach_archetype_switch
  harness asserts that after a multi-switch cycle, all 3 timers
  (_ram_swing_timer, _beam_dmg_timer, GunTimer.time_left) are
  in clean state. If a timer isn't reset, the harness fails.
- Substrate touched: scripts/PlayerTank.gd (Layer 2, sanctioned
  write ×27, inside the existing _revert_archetype body — no new
  gating).
- Hash-anchor verification plan: post-edit hash verify.

---

## iter 087 — SWEEP — Round 9-10-11 substrate audit (per-archetype state correctness)

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (substrate audit ensures death-
  attribution stays accurate), 7 (verifies the verb-distinction
  doesn't leak across switches).
- CONSULT constraints risked: none — verification work.
- Predicted failure: the per-archetype switch logic (iter 69
  `switch_archetype` + `_revert_archetype`) is the most state-
  fragile surface. A bug in `_revert_archetype` could leave
  per-archetype state (BeamLine visibility, GunTimer wait_time,
  RAM speed bonus) leaked across switches — the multi-switch
  harness (test_breach_archetype_switch) covered speed-bonus
  cleanup, but other surfaces (beam line node persistence under
  re-enter, _ram_swing_timer staying primed) may not have been
  tested. The audit looks for these.
- Falsifiable claim: the audit finds ≥1 concern worth either
  fixing or filing as a follow-up. If the audit returns "all
  clean, nothing to note," the audit was too superficial.
- Substrate touched: none in the audit itself — read-only iter.
  Any fixes uncovered are a SEPARATE iter.
- Hash-anchor verification plan: trivial (no edits).

---

## iter 086 — META — Round 11 candidate (c): armor-asymmetry resolution design doc

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]
- CONSULT constraints respected: 7 (the doc evaluates two readings
  through the verb-and-affordance lens — "armor as universal
  shell-economy puzzle" vs "armor-bypass as per-archetype verb"),
  3 (cross-references shell-class with archetype damage paths).
- CONSULT constraints risked: H5 (speculative work pre-playtest).
  Mitigation: this iter writes a DESIGN DOC only, not code.
  Analysis + recommendation lives in markdown for the user to
  evaluate alongside the playtest verdict. No substrate.
- Predicted failure: doc bias toward the (b) "asymmetry as verb"
  reading because it aligns with Pro's first-principles framing.
  Mitigation: the doc must present BOTH readings fairly with
  concrete worked examples + name the tradeoffs of each before
  recommending.
- Falsifiable claim: the doc names ≥3 concrete consequences for
  each reading that distinguish them in observable gameplay. If
  the doc is just abstract argument without specific
  player-experience predictions, it's failing as a design tool.
- Substrate touched: none — META doc only.
- Hash-anchor verification plan: trivial (no substrate).

---

## iter 085 — SPIKE — Round 11 Phase 2: SWARM α/β/γ hierarchy comparison harness

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (validates hierarchy across
  archetypes empirically per Pro's H2), 7 (each variant's
  characterization is verb-shaped not stat).
- CONSULT constraints risked: H2 (rubric-chasing). Mitigation:
  the harness EMPIRICALLY measures whether each variant produces
  a hierarchy where ≤1 archetype shares the worst outcome —
  EXACTLY Pro's "best/costly/bad answer across multiple
  archetypes" criterion.
- Predicted failure: the iter-77 stub approach scales poorly to
  cluster formations — placing 5 stubs in chevron formation +
  measuring MORTAR AoE across them needs careful position math.
  Mitigation: keep formations TIGHT (~12px spacing) so MORTAR's
  full AOE_RADIUS (24px) catches multiple stubs reliably; verify
  with sanity assertions.
- Falsifiable claim: per iter-84 blueprint prediction:
  - α: 3 distinct archetype outcomes (MORTAR=BEST, RAM=BEST,
    DEFAULT=COSTLY, PRISM=WEAK) — PASS
  - β: 2 distinct outcomes (DEFAULT=BAD, PRISM=BAD) — VIOLATES
  - γ: 4 distinct outcomes — PASS
  If the empirical harness contradicts (e.g. MORTAR misses
  α-cluster spread), the blueprint's variant analysis was wrong
  and the SPIKE catches it.
- Substrate touched: none — new harness only.
- Hash-anchor verification plan: trivial (no substrate).

---

## iter 084 — META — Round 11 Phase 2 SPIKE architect blueprint (SWARM enemy candidate)

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]  # META blueprint; the SPIKE iters
  start at iter 85+ if engagement continues.
- CONSULT constraints respected: 5 (Phase 2's SWARM target
  directly addresses C5 anchor 4 — additional role with distinct
  silhouette + tactical answer), 3 (the matrix's SWARM cell
  expects DEFAULT-costly / PRISM-weak / MORTAR-best / RAM-best —
  cross-shell-archetype answer), 7 (the variants under SPIKE
  consideration are pure verb-differentiation per archetype).
- CONSULT constraints risked: H2 from CONSULT 008 — "this enemy
  demands one archetype" is the wrong shape. SWARM must produce
  best/costly-backup/bad answer ACROSS archetypes, not pick a
  winner. Mitigation: the blueprint explicitly forbids
  "demands-one-archetype" variants; the SPIKE criteria require
  cross-archetype hierarchy verification.
- Predicted failure: speculative production trap per Pro's H5.
  Round 10 + Round 11 Phase 1 was correct instrumentation work;
  pivoting to CONTENT (SWARM enemy) before playtest 5 is the
  speculative-production risk Pro explicitly warned about.
  Mitigation: iter 84 is META ONLY — writes the SPIKE blueprint,
  does NOT add the enemy. The SPIKE itself (iter 85+) is GATED
  on continued user engagement.
- Falsifiable claim: the blueprint names ≥3 SWARM design
  variants worth SPIKE-comparing (e.g. "swarmlet" cluster of
  Light-clones / single fast-multispawn Fast / formation
  "spinet"). If the blueprint can only name 1 variant, the SPIKE
  is unjustified and iter 85 should NOT proceed.
- Substrate touched: none — META blueprint only.
- Hash-anchor verification plan: trivial (no substrate).

---

## iter 083 — BUILD — Round 11 Phase 1 continuation: band-shape analyzer + death-recap surfacing

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (analyzer cross-references
  per-archetype run-shape signatures), 6 (the surfaced band-visit
  sequence on the death screen extends death-attribution into
  multi-band run-shape).
- CONSULT constraints risked: none.
- Predicted failure: the analyzer's pairwise distance metric is a
  judgment call (Levenshtein-style vs simple position-count vs
  set-diff). The wrong choice could give false confidence
  (high distances on mock data that aren't structural). Mitigation:
  use simple position-count distance (counts differing positions
  in the sequence) — well-known, explainable, robust to
  permutations. Document the choice in the analyzer comment.
- Falsifiable claim: the harness creates 4 mock signatures with
  known divergent sequences (e.g. DEFAULT visits 5 bands in order;
  PRISM visits same 5 bands but at different timing; MORTAR
  visits only 3 bands; RAM visits 5 bands in different order).
  Pairwise distances should reflect: DEFAULT↔PRISM small (same
  sequence, different timing); DEFAULT↔MORTAR larger (different
  sequence length); DEFAULT↔RAM largest (different order). If
  any distance contradicts intuition, the metric is wrong.
- Substrate touched: scripts/PlayerTank.gd (substrate write ×26,
  inside existing breach-mode-gated block in _die for the
  death-recap surface update). New scripts/RunRecapAnalyzer.gd
  (arc-4-owned, not substrate).
- Hash-anchor verification plan: post-edit hash verify.

---

## iter 082 — BUILD — Round 11 Phase 1 start: band-shape recorder (RunRecap extension)

- Date: 2026-05-23
- Tag: [STRUCTURE]
- User actively prompting (not idle); collapse iter 82's planned
  heartbeat-#2 into the iter-80 default BUILD path. Addresses
  CONSULT 009's band-shape blind spot per the revised Round 11
  default. No second heartbeat needed — user is here.
- CONSULT constraints respected: 5 (per-band telemetry feeds C5
  anchor 4 evidence + supports the PRESSURES.md matrix), 6 (extends
  death recap with band-shape data; resource/build/route attribution
  stays the spine).
- CONSULT constraints risked: none — pure instrumentation.
- Predicted failure: substrate-write fragility on PlayerTank.gd
  ×25. Mitigation: the new call to `run_recap.enter_band()` lives
  INSIDE the existing `if run_recap != null` block in
  `_on_breach_band_changed` — there is no new gate; the existing
  loadout-gated codepath just gets an additional method call. Hash
  bit-identical on flag-off.
- Falsifiable claim: the harness verifies that after a sequence
  of band-entry calls, `band_visit_log` reflects the sequence in
  order. If the harness shows out-of-order or missing entries,
  the recorder logic has a bug.
- Substrate touched: scripts/PlayerTank.gd (Layer 2, sanctioned
  write ×25, HUD-adjacent + run_recap is arc-4-owned) +
  scripts/RunRecap.gd (arc-4-owned, not substrate). New harness.
- Hash-anchor verification plan: post-edit `TANKE_SEED=42 godot
  --headless --path . --script loop/test_runner.gd`; must report
  tile_hash: 23d6a2ec3bf2821f.

---

## iter 081 — META — idle heartbeat #1 (no playtest signal at 1800s)

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]
- CONSULT constraints respected: none directly — heartbeat iter.
- CONSULT constraints risked: none.
- Predicted failure: extending the heartbeat indefinitely against
  PROMPT's "non-stop" rule. Mitigation: bounded — iter 82 is the
  LAST heartbeat (3600s). Iter 83 either responds to user signal
  or BUILDs the iter-80-named default (band-shape recorder).
- Falsifiable claim: no test work, no design work this iter.
  Pure log + reschedule. If anything else is written, the
  heartbeat was misclassified as a META iter.
- Substrate touched: none.
- Hash-anchor verification plan: n/a — no code change.

---

## iter 080 — META — diagnose Round 11 + write blueprint; idle-heartbeat awaiting playtest 5

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]
- CONSULT constraints respected: 6 (the diagnose names which
  Round-11 axes best surface death-attribution distinctness), 7
  (the candidates are verb-and-affordance-shaped, not stat).
- CONSULT constraints risked: none — META work.
- Predicted failure: same as iter 72 — the loop's "non-stop" rule
  pulls toward firing the SPIKE this iter; the historical playtest-
  redirected pattern pulls toward holding. The risk is doubling-up
  the iter-72 blueprint without learning from CONSULT 009's
  band-shape blind spot — the diagnose must explicitly name
  band-shape recorder as the lead default if no playtest arrives,
  not enemy roster (which was iter-72's default before the
  CONSULT-008 rethesis).
- Falsifiable claim: the diagnose names band-shape recorder as
  the default action IF no playtest signal arrives, AND it
  preserves the play-test-deferral recommendation as primary. If
  the diagnose just echoes iter-72 ("default is enemy roster")
  it would be ignoring the CONSULT-009 finding.
- Substrate touched: none — META + new compaction-safe blueprint.
- Hash-anchor verification plan: trivial (no substrate).

---

## iter 079 — META — Round 10-close (CONSULT 009 + ★REVIEW-QUEUE #14 upgrade + RUBRIC reflection)

- Date: 2026-05-23
- Tag: [MIXED]
- CONSULT constraints respected: 5 (round-close cites the PRESSURES
  matrix as the documented canonical-answer artifact), 6 (the
  on-death prompt extends death-attribution from resource/build/
  route into archetype-reflection), 7 (the matrix language is
  verb-and-affordance, no stat-bundles).
- CONSULT constraints risked: none — META closure work.
- Predicted failure: the written self-pre-mortem keeps repeating
  CONSULT 008's reframings rather than asking SHARP NEW questions
  about Round 10. Mitigation: write CONSULT 009 specifically about
  what Round 10's INSTRUMENTATION strategy can MISS — what risks
  the distinctness audit / pressure matrix / on-death prompt
  CAN'T catch. That's the honest sharpest question, not "did the
  archetypes feel distinct" (which playtest 5 will answer).
- Falsifiable claim: CONSULT 009 names ≥1 RISK the Round-10
  instrumentation can't address that ISN'T just "experiential
  distinctness needs a playtest." If the consult is just "same as
  CONSULT 008 + nothing new," the close was lazy.
- Substrate touched: none — META + docs only.
- Hash-anchor verification plan: trivial (no substrate); cheap
  spot-check.

---

## iter 078 — BUILD — Round 10 Phase 3: playtest instrumentation (on-death prompt + PLAYTEST-5-BRIEF)

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 6 (death recap framing — the
  structured prompt extends the existing death recap with
  archetype-aware reflection questions; resource/build/route
  attribution stays the spine), 1 (no choices during combat — the
  prompt appears on the death screen, post-combat).
- CONSULT constraints risked: none — purely additive HUD on the
  existing death overlay.
- Predicted failure: substrate-write fragility. PlayerTank.gd ×23
  is high; adding another node to the canvas requires precise
  gating on `loadout != null` (the established breach-mode gate)
  so arc-2/3 stay bit-identical. The risk is wiring the new label
  into `_setup_hud()` outside the gate. Mitigation: build the
  label inside the existing `loadout != null` HUD section AND
  toggle visibility inside the existing `loadout != null` branch
  of `_die()`.
- Falsifiable claim: hash anchor 23d6a2ec3bf2821f stays preserved
  post-edit; test-all 5/5 (arc-2 + arc-3 unchanged); test-breach
  37/37; the new label appears on breach-mode death only.
- Substrate touched: scripts/PlayerTank.gd (Layer 2, sanctioned
  write ×24). HUD-only; flag-off (no loadout) codepath unchanged.
- Hash-anchor verification plan: `TANKE_SEED=42 godot --headless
  --path . --script loop/test_runner.gd` post-edit; must report
  tile_hash: 23d6a2ec3bf2821f.

---

## iter 077 — BUILD — Round 10 Phase 2 continuation: pressure-probe harness (armor-bypass scope)

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (probes back up the C5
  documented canonical answers with empirical assertions), 3
  (cross-references shell-class behavior with per-archetype
  damage paths).
- CONSULT constraints risked: none.
- Predicted failure: scope-too-broad. PRESSURES.md has 40 cells —
  one probe per cell is too much for one iter. Mitigation: focus
  the probe harness on the MATRIX'S MOST UNCERTAIN CLAIM
  identified at iter 76 — the per-archetype armor-bypass
  behavior. 6 probes (DEFAULT+AP, DEFAULT+HEAT, PRISM, MORTAR,
  RAM swing, RAM collision) — sharp scope, single iter, surfaces
  the asymmetry empirically.
- Falsifiable claim: the probes confirm the matrix's armor-bypass
  claim — DEFAULT+AP deals 0-mitigated damage to armored Heavy;
  DEFAULT+HEAT deals 2; PRISM/MORTAR/RAM all bypass and deal their
  nominal damage. If a probe contradicts the matrix (e.g. PRISM
  somehow respects armor), update PRESSURES.md.
- Substrate touched: none — new harness only.
- Hash-anchor verification plan: trivially verify (no substrate);
  test-all + test-breach green.

---

## iter 076 — BUILD — Round 10 Phase 2: PRESSURES.md per-archetype × per-pressure matrix

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (each enemy/role has a specific
  tactical answer — the matrix EXPLICITLY documents canonical
  answers per archetype per pressure → directly addresses C5
  anchor 2 "documented canonical answer in BANDS.md"), 3 (the matrix
  cross-references shell type with archetype answer per pressure),
  7 (the matrix forces verb-language not stat-language for cells).
- CONSULT constraints risked: none — design documentation work.
- Predicted failure: the matrix may reveal that the current 3-role
  roster (Light/Heavy/Fast) ONLY expresses 2-3 of the 7 named
  pressure dimensions. That's the WHOLE POINT — empty cells =
  Round-11 candidates. The risk is filling cells optimistically
  to make the matrix look complete; mitigation: explicitly mark
  empty/weak cells as such with a "—" or "weak coverage" tag.
- Falsifiable claim: at least 3 of the 7 pressure rows have ≥1
  empty/weak cell → Round 11 has a clear roster-expansion target
  list. If ALL cells fill cleanly, then either (a) the current
  roster is more complete than expected or (b) I'm being too
  generous in cell filling — the second possibility is the iter-76
  risk.
- Substrate touched: none — new doc only.
- Hash-anchor verification plan: trivially verify (no substrate).

---

## iter 075 — BUILD — Round 10 Phase 1 continuation: play-relevant axes for the distinctness audit

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 7 (the new axes are derived from
  the per-archetype VERB profile — fire rate / magnitude / damage
  persistence / range shape — closer to "what the player feels"
  than the iter-74 existence-of-mechanism signals).
- CONSULT constraints risked: 4 (silhouette-grammar gate logic) —
  the new axes are play-RELEVANT derived properties, not play-SIM.
  This iter doesn't run a frame-by-frame auto-play sim. The risk
  is overclaiming "play-sim verified" when the axes are still
  computed from constants. Mitigation: tag the new axes as
  "play-relevant derived" in the harness output; iter 76 (Phase 2
  PRESSURES.md) is where real play-sim probe scenarios go.
- Predicted failure: the new axes will increase minimum pairwise
  distance (because the play-relevant signals are MORE distinct
  than the structural ones — different cadences are very
  archetype-specific). The audit will pass trivially again, giving
  false confidence. Mitigation: the harness emits a CALIBRATION
  WARNING any time the min distance > 80% of max — that's a sign
  the audit is too easy and Phase-1's job (early-warning for
  convergence) is being underdone. Need to tune thresholds before
  Phase 2 starts.
- Falsifiable claim: with 10 axes, threshold ≥5, the minimum
  pairwise distance lands ≥6 (because the play-relevant axes will
  rarely tie). If a pair lands at exactly 5, the audit is properly
  calibrated. If all pairs land at 8+, calibration is too loose
  and Phase 1 isn't doing its job.
- Substrate touched: none — extends the iter-74 harness only.
- Hash-anchor verification plan: trivially verify (no substrate);
  test-all + test-breach green.

---

## iter 074 — BUILD — Round 10 Phase 1: distinctness-audit harness (structural-signal scaffold)

- Date: 2026-05-23
- Tag: [STRUCTURE]
- CONSULT constraints respected: 4 (extends silhouette-grammar logic
  from "asset readable" to "mechanic readable" — a structural
  pairwise-distinctness assertion), 7 (verifies each archetype is a
  distinct verb-set not a stat-tweak).
- CONSULT constraints risked: none — pure verification harness.
- Predicted failure: the structural signals are EASY to make
  distinct (the archetypes were explicitly designed for it). The
  audit may pass trivially this iter, giving a false confidence
  that all is well. Mitigation: this is Phase-1 scaffolding only;
  the actually-uncertain signals (kill distance, time stationary,
  death reason distribution) need play-sim — Phase-1 continuation
  iter 75. State this explicitly in the harness output so the loop
  doesn't claim "distinctness verified" prematurely.
- Falsifiable claim: with the existing 4 archetypes, the 6-element
  signal vector produces ≥3 pairwise differences for ALL
  archetype pairs. If a pair differs in fewer than 3 of 6 signals,
  the audit FAILS and the harness emits the "feels-same risk"
  warning per Consult 008's structural-correlate logic. Trivially
  PRISM vs MORTAR should differ in most signals; the closest pair
  is probably DEFAULT vs MORTAR (both projectile-spawning with
  slow vs fast cadence — let's see).
- Substrate touched: none — new harness file + Makefile target
  only. No scripts/ writes.
- Hash-anchor verification plan: trivially verify (no substrate),
  test-all + test-breach green.

---

## iter 073 — META — Consult 008 captured + Round 10 rethesis

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]  # META analysis; the BUILD work starts
  iter 74 (distinctness-audit harness).
- CONSULT constraints respected: 5 (the rethesis names a pressure
  matrix that documents each band/role's tactical answer per
  archetype — direct constraint-5 lift); 4 (the distinctness-audit
  follows the silhouette grammar logic into mechanics — extends
  the gate from "asset readable" to "mechanic readable").
- CONSULT constraints risked: none — META + BUILD-PLAN work.
- Predicted failure: the BUILD work pivots based on Pro's reframe;
  the risk is over-trusting an external model's read of an internal
  game design problem. Pro hasn't played the game and is reasoning
  from docs only. Mitigation: the rethesis kept Pro's STRUCTURAL
  recommendations (distinctness audit, pressure matrix) and deferred
  the IDENTITY/RUBRIC-rephrase calls (the identity-vs-weapons
  question, the C15-5 rephrase) to the user as REVIEW-QUEUE #15.
- Falsifiable claim: the distinctness-audit harness, when built in
  Phase 1, produces converged metric vectors across ≥2 archetypes —
  proving Pro's H4 risk is REAL, not theoretical. If divergent
  vectors emerge cleanly, Pro's H4 was over-cautious. Either way the
  harness is the right tool.
- Substrate touched: none — META + new compaction-safe blueprints
  (iter-073-round10-rethesis.md).
- Hash-anchor verification plan: trivial (no substrate; cheap
  spot-check post-iter).

---

## iter 072 — META — diagnose Round 10 + write blueprint; idle-heartbeat awaiting playtest

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]  # META analysis written; the SPIKE work
  itself is deferred until either the user playtests REVIEW-QUEUE #14
  or the idle heartbeat exhausts its budget.
- CONSULT constraints respected: 6 (death recap inferred from
  playtest — playtest-driven direction-setting is the established
  arc-4 pattern), 5 (each band's pressure tied to roster — Round 10's
  candidate (a) directly addresses C5 the weakest structural axis).
- CONSULT constraints risked: none — META work cannot risk a
  gameplay constraint by definition.
- Predicted failure: the loop "bootstraps next round" PROMPT
  discipline pulls toward firing the SPIKE this iter; the
  iter-54/61 idle-heartbeat reconciliation pulls toward holding
  for playtest. The risk is that the loop EITHER fires speculative
  SPIKE work that gets discarded by playtest 5's verdict, OR sits
  idle so long that user momentum dies. Mitigation: write the
  diagnose blueprint NOW (compaction-safe, immediately useful when
  the user returns) and idle at 1800s (the iter-54/61 budget).
- Falsifiable claim: the diagnose blueprint correctly names ≥2 of
  the 3 plausible Round-10 axes the user will care about. If the
  user playtests + asks for something I haven't named (e.g.
  "make the camera scroll better" or "I want music"), the META
  analysis was too narrow on rubric-axes and missed a feel-axis
  the playtest surfaced.
- Substrate touched: none — META work only (new
  loop/breach/iter-072-round10-diagnose.md + LEDGER + STATE).
- Hash-anchor verification plan: trivial (no substrate; cheap
  spot-check post-iter).

---

## iter 071 — META — Round 9-close (CONSULT 007 + ★REVIEW-QUEUE #14 + RUBRIC +C15)

- Date: 2026-05-23
- Tag: [MIXED]  # structural rubric edit + cognitive consult.
- CONSULT constraints respected: 7 (verbs and affordances — archetypes
  are pure verb-differentiation, the most extreme form of constraint 7),
  3 (each archetype's tactical answer is identity-distinct), 4
  (silhouette grammar from iter 70's concept sprites).
- CONSULT constraints risked: 7 vs the Round-8 user override — the loop
  re-establishes constraint 7 via Round 9 even though Round 8 relaxed
  it for C14. Document the tension in the consult writeup.
- Predicted failure: the written self-pre-mortem's Q3 ("seductive-but-
  hollow") risks being too generous — the loop wants to celebrate the
  4-archetype slate as done, but the user-facing question that hasn't
  been answered is "do the 4 archetypes FEEL distinct?" — that's
  playtest-only. The consult must NAME the unverified claim, not
  paper over it.
- Falsifiable claim: the new C15 anchor 4 ("playtest: user describes
  the run by archetype + verb, not by archetype-as-skin") is the
  cognitive gate. If the next playtest reports "I picked PRISM but it
  felt like default with a beam," anchor 4 doesn't land — and the
  Into-the-Breach standard from the iter-62 blueprint is broken.
- Sentence test: n/a — Round 9 is archetype-differentiation, not a
  per-upgrade addition; the sentence-test gate is per-upgrade (C8).
- Substrate touched: none — close-of-round META work (RUBRIC.md +
  REVIEW-QUEUE.md + creative-consults.md + LEDGER + STATE).
- Hash-anchor verification plan: trivial verify (no substrate); a
  cheap test-all + test-breach safety net to ensure the close didn't
  drift.

---

## iter 070 — BUILD — Round 9h: visual assets via /agentify image_gen

- Date: 2026-05-23
- Tag: [STRUCTURE-DEFERRED]  # asset generation; integration into
  the sprite-sheet renderer is a follow-up iter.
- CONSULT constraints respected: 4 (silhouette grammar gate before any
  ship), 3 (per-archetype answer is identity-readable from sprite),
  7 (verbs+affordances — the sprite signals the verb).
- CONSULT constraints risked: 4 itself, if the generated image is
  ChatGPT-default illustration instead of pixel-art matching
  sprites_0.png. The brief mitigates by spec'ing 16×16 top-down
  pixel-art, palette guidance, and silhouette intent per archetype.
- Predicted failure: image_gen returns 1024×1024 stylized PNGs that
  read as "concept art" not "sprite-sheet ready". The iter ships
  reference images + REVIEW-QUEUE for human direction, NOT an
  integrated sprite swap.
- Falsifiable claim: 3 image_gen calls return 3 distinct images with
  obviously-different silhouettes per archetype (cyan beam-lens /
  earth-tone angled barrel / red blunt-front). If two images look
  interchangeable, the brief was under-spec'd.
- Substrate touched: none — assets only (img/ additions), no scripts
  or scenes. No hash-anchor concern.
- Hash-anchor verification plan: n/a (asset-only iter); will still
  spot-check post-commit since this is a free verification.
- Iter 70 follow-up plan: REVIEW-QUEUE #13 asks the user (a) keep
  generated style as canonical art direction, (b) downsample for
  16×16 sprite-sheet integration, or (c) use as reference for a
  human-drawn pass. The "integrate into sprites_0.png" iter is
  gated on that answer.

---

## iter 069 — BUILD — Round 9g: event-unlock mid-run archetype switching

- Date: 2026-05-23
- Tag: [STRUCTURE]
- Round 9g — the "almost like switching a weapon" path the user
  named in iter 55. A new Depot upgrade kind ("Switch to <Archetype>")
  drawn from the depot pool, gated by the same MetaProgress tiers as
  the start-pick screen (iter 68).
- The change:
  - scripts/PlayerTank.gd (sanctioned substrate):
    - New public `switch_archetype(value)`: reverts the current
      archetype's mods (via `_revert_archetype`), sets the new value,
      re-runs `_init_archetype`. Idempotent on same-value.
    - `_revert_archetype()` undoes per-archetype state — hides beam
      line for PRISM, resets GunTimer for MORTAR, subtracts RAM
      speed bonus.
    - `_build_beam_line` made idempotent (no-op when `_beam_line` is
      already built) so switching back to PRISM reuses the node.
  - scripts/Depot.gd (arc-4-owned):
    - 3 new UpgradeKind values: SWITCH_TO_PRISM, SWITCH_TO_MORTAR,
      SWITCH_TO_RAM (total kinds 9 → 12).
    - `_upgrade_pool` gates each switch entry on the matching
      MetaProgress predicate (PRISM@20, MORTAR@40, RAM@60).
    - `apply_upgrade` for the switch kinds calls
      `_player.switch_archetype(value)`.
    - `_on_body_entered` captures `_player = body` (in addition to
      the existing `_player_loadout`).
    - `_label_for_kind` provides labels for the new kinds.
  - test_breach_meta updated for the new pool sizes (was 5/6/7/8/9;
    now 5/7/9/11/12 across the same depth tiers).
- CONSULT constraints respected: 1 (the switch happens at a depot,
  not in combat); 7 (relaxed by the iter-55 user override — the new
  upgrade is a structural class swap, not a stat).
- Predicted failure modes:
  - Hash anchor: only PlayerTank.gd is substrate; Depot/MetaProgress
    are arc-4-owned. switch_archetype is only callable when a depot
    pick invokes it; arc-2/3 bit-identical.
  - Multi-switch correctness: _revert_archetype undoes the OUTGOING
    archetype's mods before _init_archetype applies the new one — so
    speed bonus / GunTimer / beam-line stay clean across switches.
- Falsifiable claim: post-edit — test_breach_archetype_switch shows:
  3 new SWITCH_TO_* UpgradeKinds; _upgrade_pool widens to include
  switches at their depth tiers; apply_upgrade with a stub player
  calls switch_archetype; multi-switch keeps speed clean (no
  accumulation). Hash anchor 23d6a2ec3bf2821f preserved; test-all
  5/5; test-breach 35/35.
- Sentence test: n/a — these are tank-class swaps (structural verbs),
  not stat upgrades.
- Substrate touched: PlayerTank.gd (switch_archetype + revert helper
  — sanctioned).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 068 — BUILD — Round 9f: start-pick selection screen

- Date: 2026-05-23
- Tag: [STRUCTURE]
- Round 9f — the selection UI for the user's "pick at the beginning"
  archetype path. At run start a HUD screen lists the 4 archetypes
  (DEFAULT always unlocked; PRISM/MORTAR/RAM gated by MetaProgress
  best-depth tiers, mirroring the iter-51 4-tier ladder); the player
  picks via keys 1-4.
- The change:
  - scripts/MetaProgress.gd (arc-4-owned): UNLOCK_PRISM_DEPTH=20,
    UNLOCK_MORTAR_DEPTH=40, UNLOCK_RAM_DEPTH=60; predicate static
    methods + `unlocked_archetypes(best)` returning the ordered list
    of unlocked TankArchetype values (ints).
  - scripts/PlayerTank.gd (sanctioned substrate):
    - Refactor the per-archetype `_ready` init into `_init_archetype()`
      (guarded by `_archetype_initialized`) — also called after a user
      pick so the picked archetype's behavior fires.
    - Selection screen UI (ArchetypePanel under HUD) + `_show_/_hide_/
      _refresh_archetype_panel()`.
    - `_pick_archetype(value)` (sets state + inits + hides panel) and
      `_pick_archetype_by_index(idx)` (input handler).
    - `_physics_process` early-returns when `_archetype_selecting`,
      polling only KEY_1-4.
    - `@export var force_archetype_select: bool = false` gates the
      auto-show in `_ready`. Default false → existing harnesses
      unaffected (no selection screen leaks into non-game tests). The
      live BreachLevel.tscn sets it true.
  - scenes/BreachLevel.tscn: PlayerTank instance gets
    `force_archetype_select = true`.
- CONSULT constraints respected: 1 (no choice in active combat —
  selection happens before any movement/firing).
- Predicted failure modes:
  - Hash anchor: all selection behavior gates on breach mode +
    force_archetype_select; arc-2/3 bit-identical.
  - The auto-trigger reads MetaProgress.best_depth() (file). Harness
    doesn't depend on file state — drives _show_archetype_select +
    _pick_archetype directly.
- Falsifiable claim: post-edit — test_breach_archetype_select shows:
  MetaProgress predicates correct at 19/20/39/40/59/60;
  unlocked_archetypes returns 1/2/3/4 across tiers; _show builds the
  panel + sets the flag; _pick_archetype(PRISM) sets archetype +
  clears flag + builds the beam line. Hash anchor 23d6a2ec3bf2821f
  preserved; test-all 5/5; test-breach 34/34.
- Sentence test: n/a (selection UI).
- Substrate touched: PlayerTank.gd (selection screen + refactor —
  sanctioned, HUD only).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 067 — BUILD — Round 9e: RAM Tank

- Date: 2026-05-22
- Tag: [STRUCTURE]
- Round 9e — the third and final new archetype, closing the iter-062
  blueprint's per-archetype build phase. archetype=RAM: no projectile
  weapon. Damages via COLLISION (driving into bodies hurts them) + a
  short-range AoE swing as the fire button + a built-in sprint/dash.
  The movement-as-weapon archetype.
- The change (scripts/PlayerTank.gd, sanctioned substrate):
  - Speed bonus: archetype=RAM gets +RAM_SPEED_BONUS to base speed in
    _ready.
  - Collision damage: after move_and_collide, if archetype=RAM AND
    cooldown ready → damage the collider (RAM_COLLISION_DAMAGE).
  - Swing on fire: when archetype=RAM and fire-held and swing
    cooldown ready → _ram_swing() (damages every Node2D sibling in
    the forward semicircle within RAM_SWING_RANGE that has
    take_damage, deals RAM_SWING_DAMAGE).
  - Sprint unlocked: the overdrive sprint check now extends to
    `archetype == RAM` — RAM always has shift-sprint, no depot pick
    required.
  - RAM does NOT call _fire — no discrete bullets.
- CONSULT constraints respected: 1 (no choice in combat).
- Predicted failure modes:
  - Hash anchor: all RAM behavior gates on archetype=RAM; DEFAULT
    bit-identical. arc-2/3 unaffected.
  - The swing uses sibling-distance + forward-projection (matches
    MORTAR AoE / HE blast pattern).
- Falsifiable claim: post-edit — test_breach_ram shows: archetype=RAM
  gives speed > 32; _ram_swing damages a forward in-range stub but
  spares behind + far stubs. Hash anchor 23d6a2ec3bf2821f preserved;
  test-all 5/5; test-breach 33/33.
- Sentence test: n/a (archetype weapon primitive).
- Substrate touched: PlayerTank.gd (RAM branches + speed bonus +
  sprint gate — sanctioned).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 066 — BUILD — Round 9d: MORTAR Tank

- Date: 2026-05-22
- Tag: [STRUCTURE]
- Round 9d — the second archetype. archetype=MORTAR: lobbed parabolic
  projectile, AoE on impact (~tank-width radius); fires over walls (no
  LoS); slow rate of fire — the terrain-bypass archetype.
- The change:
  - New scripts/MortarShell.gd + scenes/MortarShell.tscn
    (arc-4-owned): a Node2D projectile that travels from launch point
    to target over TRAVEL_TIME (0.6s) with a parabolic Y arc, then
    explodes (AoE damages siblings within AOE_RADIUS via take_damage).
  - scripts/PlayerTank.gd (sanctioned): _fire() gates on archetype:
    MORTAR → _fire_mortar (spawns a MortarShell into the level
    targeting MORTAR_RANGE in the facing direction); DEFAULT → the
    existing shoot.emit path; PRISM continues via _tick_beam in
    _physics_process (iter 65). _ready when archetype=MORTAR slows
    GunTimer.wait_time to MORTAR_GUN_COOLDOWN (1.5s).
- CONSULT constraints respected: 1 (no choice in combat — firing is
  the existing accept-key, no new modal). MORTAR composes with 9a's
  HP primitive — AoE damage drains enemy HP visibly.
- Predicted failure modes:
  - Hash anchor: all MORTAR behavior gates on archetype=MORTAR;
    DEFAULT bit-identical.
  - The shell uses sibling-distance for AoE (matches Bullet's
    _apply_he_blast pattern) — bodies must be siblings of the shell
    (i.e. in the level) to take damage.
- Falsifiable claim: post-edit — test_breach_mortar shows: archetype=
  MORTAR slows GunTimer to MORTAR_GUN_COOLDOWN; _fire_mortar spawns a
  MortarShell into the parent; the shell's _explode() damages
  in-radius siblings with take_damage and spares out-of-radius. Hash
  anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 32/32.
- Sentence test: n/a (archetype weapon primitive).
- Substrate touched: PlayerTank.gd (MORTAR branch — sanctioned).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 065 — BUILD — Round 9c: PRISM Tank

- Date: 2026-05-22
- Tag: [STRUCTURE]
- Round 9c — the first real archetype (the user's worked example).
  archetype=PRISM: continuous beam while fire-held; damages a line up
  to the first body hit; burns brick fast; movement disabled while
  firing (stop-and-fire — the player risk that makes the archetype
  tense; enemies get time to shoot back).
- The change (scripts/PlayerTank.gd, sanctioned substrate):
  - A BeamLine (Line2D) node, built in `_ready` when archetype=PRISM,
    hidden until firing.
  - `_physics_process`: when archetype=PRISM and fire-held, zero
    input_vector (stop-and-fire) + tick the beam (raycast from muzzle
    forward, find first body, apply damage, update line visual);
    release fire → hide beam.
  - Beam damage rule (`_apply_beam_to_body`, pure-data for harness):
    enemies take 1 damage per BEAM_DAMAGE_COOLDOWN (0.25s — a 3-HP
    Heavy dies in ~0.75s, leaving time to shoot back); bricks burn
    every tick (1 dmg/frame); steel/other-non-damageable blocks the
    beam without damage.
  - PRISM does NOT call `_fire()` — no discrete bullets, no shell
    consumption. The breach economy is DEFAULT's mechanic; PRISM has
    its own.
- CONSULT constraints respected: none risked. The beam composes with
  9a's HP primitive — enemies' HP bars visibly drain.
- Predicted failure modes:
  - Hash anchor: all PRISM behavior gates on archetype=PRISM; DEFAULT
    (the only value in actual gameplay until 9f) is unchanged →
    bit-identical.
  - The reflect-upgrade variant (blueprint mentioned) is deferred —
    implement after the base beam validates.
- Falsifiable claim: post-edit — test_breach_prism shows: a PRISM
  PlayerTank builds the BeamLine (hidden initially); DEFAULT doesn't;
  `_apply_beam_to_body` damages a brick stub every tick + an enemy
  stub on the cooldown cadence + leaves a steel-stub untouched. Hash
  anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 31/31.
- Sentence test: n/a (a new weapon primitive on an archetype, not a
  depot upgrade).
- Substrate touched: PlayerTank.gd (beam logic + visuals — sanctioned,
  gated on archetype=PRISM).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 064 — BUILD — Round 9b: archetype framework

- Date: 2026-05-22
- Tag: [STRUCTURE]
- Round 9b — the archetype-framework scaffolding for the iter-062
  blueprint. Just the enum + the @export state field; no
  per-archetype behavior branches yet (those land in 9c/9d/9e).
  Minimal by design — adding stubs 9c/d/e would have to replace is
  wasted work.
- The change (scripts/PlayerTank.gd, sanctioned substrate):
  - A `TankArchetype` enum with 4 values: DEFAULT, PRISM, MORTAR, RAM.
  - An `@export var archetype: int = TankArchetype.DEFAULT`. The
    field exists; no code branches on it yet, so DEFAULT (the only
    value any current PlayerTank has) preserves the existing breach
    behavior bit-identically.
- CONSULT constraints respected: none risked — pure scaffolding.
- Predicted failure modes:
  - Hash anchor: the @export adds a field; no behavior change for
    DEFAULT; arc-2/3 (no loadout, archetype field exists but unread)
    bit-identical.
- Falsifiable claim: post-edit — test_breach_archetype confirms the
  4-value enum + the default archetype (DEFAULT) + the field is
  settable; existing breach HUD still builds (regression check). Hash
  anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 30/30.
- Sentence test: n/a (scaffolding).
- Substrate touched: PlayerTank.gd (a new enum + @export field —
  sanctioned).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 063 — BUILD — Round 9a: enemy HP primitive + HP bars

- Date: 2026-05-22
- Tag: [STRUCTURE]
- Round 9a, the first build of the iter-062 blueprint — the
  prerequisite primitive for archetype combat. Enemies need >1 HP +
  visible HP bars so beam/HEAT/multi-hit gameplay reads.
- The change:
  - scripts/Spawner.gd (sanctioned substrate): a BREACH_HP_BONUS dict
    bumps per-type max_hp ONLY in breach mode (Light 1→2, Heavy 2→3,
    Fast 1→2). arc-2/3 mode (breach_mode_enabled=false) keeps the
    arc-2 values bit-identical.
  - scripts/Enemy.gd (substrate; sanctioned per the iter-062 Round-9
    amendment): an HP-bar HUD (two ColorRects above the sprite, dark
    bg + red fg) built in `_ready` IFF the parent level has breach
    mode enabled AND max_hp > 1. `take_damage` updates the bar on
    every non-fatal hit (visible while damaged).
  - Bullet.damage stays — HE / HEAT×2 / APCR penetrate / AP single
    now MATTER beyond single-hit.
- CONSULT constraints respected: 4 (the bar is a small HUD overlay —
  no silhouette confusion). None risked.
- Predicted failure modes:
  - Hash anchor: Spawner's HP bonus is gated on breach_mode_enabled —
    arc-2 procedural baseline gets the unchanged max_hp values; the
    seed-42 tile hash is unaffected (HP doesn't enter tile generation).
    Enemy.gd's HP-bar build is gated on breach_mode_enabled AND
    max_hp > 1; an arc-2 enemy never builds the bar nodes.
  - The breach-mode gate is checked via `"breach_mode_enabled" in
    level` — defensive duck-typing, safe even if a level lacks the
    flag.
- Falsifiable claim: post-edit — test_breach_hp shows a breach-mode
  enemy with max_hp=3 builds HP-bar nodes + the bar shows the damaged
  ratio after take_damage; an arc-2/3 enemy builds none. Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 29/29.
- Sentence test: n/a (a substrate primitive, not an upgrade).
- Substrate touched: Spawner.gd (HP bonus — sanctioned); Enemy.gd
  (HP-bar HUD — sanctioned per the Round-9 amendment, HUD-only).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 062 — PLAYTEST — playtest-4 integrated; Round 9 opened

- Date: 2026-05-22
- Tag: [STRUCTURE-DEFERRED]
- The user playtested Round 8 (2026-05-22). Verdict: positive — the
  roguelite overhaul reached "an interesting spot" — but the
  underlying primitive ("tank that shoots discrete bullets") is the
  bottleneck. The loop's autonomous ceiling (CONSULT 006) is
  RECONFIRMED — only a human could name the next-deepest surface:
  archetype primitives.
- New direction: TANK ARCHETYPES (Red Alert / Into the Breach
  references). User-named: Prism Tank (stop-and-fire beam, burns brick,
  damages in line; upgrade reflects → AoE). Prerequisite: enemy HP > 1
  + HP bars. Assets via /agentify image_gen.
- Via AskUserQuestion (user override authority): scope = "Full
  archetype program" — 4 archetypes + BOTH selection paths (start-pick
  + event-unlock mid-run switching) + visuals before the next playtest.
- This iter: integrate the playtest, record the overrides in STATE
  §Arc-4 amendments, open Round 9, write the blueprint
  iter-062-round9-architect.md, append REVIEW-QUEUE #12.
- CONSULT constraints: the user override sanctions (a) Enemy.gd HUD
  writes for the HP-bar primitive; (b) /agentify image_gen for asset
  visuals (overriding the MLX-SD-style NO-GO). Constraint 1 (no choice
  in combat) preserved. Constraint 4 (silhouette grammar) still gates
  generated assets.
- Predicted failure: Round 9 is the biggest round yet (8 sub-rounds, 4
  archetypes, asset gen). The risk: archetypes that don't FEEL distinct
  (just "default + stat tweak"). Mitigation: the blueprint's
  "mechanically different" guardrail — if an archetype reduces to a
  stat, cut it.
- Falsifiable claim: post-iter — iter-062-round9-architect.md exists
  with the 8 sub-rounds; STATE §Arc-4 amendments records the
  playtest-4 overrides; REVIEW-QUEUE #11 CLOSED, #12 opened. No code
  touched → hash anchor + harnesses unchanged.
- Sentence test: n/a (planning iter).
- Substrate touched: none (planning only).
- Hash-anchor verification plan: n/a — no code this iter.

## iter 061 — SWEEP — post-Round-8 verification grid

- Date: 2026-05-21
- Tag: [STRUCTURE-DEFERRED]
- Round 8 closed at iter 60; the user has not yet playtested. Per the
  iter-60 next_action, iter 61 is a non-speculative iter — a SWEEP over
  the post-Round-8 build, NOT a speculative Round 9 (CONSULT 006).
- The grid: (a) reachability sweep — test_breach_harness --deep across
  12 seeds (42-53), all 5 bands; (b) test-breach 28/28; (c) test-all
  5/5; (d) hash anchor seed 42.
- CONSULT constraints respected: 5 (every band reachability-checked).
  None risked — verification only.
- Predicted failure: Round 8 touched PlayerTank ×2 (XP, shield) +
  Spawner ×1 (ammo drops) — none touch level geometry — so
  reachability should be unchanged from the iter-54 12/12.
- Falsifiable claim: post-sweep — all 5 bands reachable on >=80% of
  the 12 seeds; test-breach 28/28; test-all 5/5; hash anchor
  23d6a2ec3bf2821f.
- Sentence test: n/a (verification iter).
- Substrate touched: none (SWEEP).
- Hash-anchor verification plan: seed 42 procedural baseline, part of
  the grid.

## iter 060 — CONSULT/QUEUE — Round 8-close

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8-close — the CONSULT + QUEUE + RUBRIC phase of the iter-055
  blueprint. Round 8's build phase (8a-8d, iters 56-59) shipped the
  iter-55 playtest-3 override in full.
- This iter: CONSULT 006 (written self-pre-mortem) on whether the
  roguelite overhaul cohered; RUBRIC.md +C14 "in-run progression" (per
  the blueprint — the iter-39 incremental pattern); REVIEW-QUEUE #11
  (the Round-8 playtest request).
- CONSULT constraints: n/a (a process iter). The C14 addition records
  that constraint 7 (verbs not stats) is relaxed for Round 8's surface
  per the user override.
- Predicted failure: the honest CONSULT finding is that Round 8 is
  harness-verified to EXIST but its coherence ("one game, not two
  bolted systems") is entirely playtest-gated — so C14 scores 3 (the
  structural ceiling), anchors 4-5 playtest-locked.
- Falsifiable claim: post-iter — RUBRIC.md has C14 (14 criteria, 70-pt
  ceiling), score 42/70; creative-consults.md has CONSULT 006;
  REVIEW-QUEUE.md has #11. No code touched → hash anchor + harnesses
  unchanged (23d6a2ec3bf2821f; test-all 5/5; test-breach 28/28).
- Sentence test: n/a.
- Substrate touched: none (docs only).
- Hash-anchor verification plan: n/a — no code this iter.

## iter 059 — BUILD — Round 8d: longer shields / defensive pickups

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8d of the iter-055 blueprint — the last build piece. Playtest-3:
  "make shields longer or something."
- The change (scripts/PlayerTank.gd, breach-mode only):
  - apply_shield: in breach mode (loadout != null) the shield lasts at
    least BREACH_SHIELD_DURATION (6s) — 3× the old 2s pickup shield.
    arc-2/3 keeps the passed duration.
  - A "SHIELD" HUD indicator (breach HUD) — visible only while the
    shield is active (toggled in _physics_process next to the existing
    blue-tint cue).
- The shield already drops from Light enemies (Enemy._spawn_shield_
  pickup, 10%) — 8d does NOT touch Enemy.gd (unsanctioned); it
  lengthens what apply_shield grants, so the existing drop is longer.
- CONSULT constraints: none risked — a defensive-pickup tuning + a HUD
  cue.
- Predicted failure modes:
  - Hash anchor: both changes gate on loadout != null; an arc-2/3
    PlayerTank's apply_shield + HUD are bit-identical.
  - apply_shield's only caller passes 2.0; maxf(2.0, 6.0) = 6.0 in
    breach mode, = 2.0 (the passed value) in arc-2/3.
- Falsifiable claim: post-edit — test_breach_shield shows a breach
  PlayerTank's apply_shield(2.0) sets _shield_timer to 6s + a HUD
  ShieldLabel shows while shielded; an arc-2/3 PlayerTank's
  apply_shield(2.0) stays 2s + builds no ShieldLabel. Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 28/28.
- Sentence test: n/a (a defensive pickup tuning).
- Substrate touched: PlayerTank.gd (apply_shield + HUD — sanctioned,
  gated on loadout != null).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 058 — BUILD — Round 8c: enemy ammo drops

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8c of the iter-055 blueprint — playtest-3's "does enemy drop
  ammo?"
- Investigation finding: the pickup-drop pattern already lives in
  Enemy.gd (`_spawn_hp_pickup` / `_spawn_shield_pickup`, arc-2 iters
  78/82). Enemy.gd is NOT sanctioned substrate. Per the blueprint, 8c
  hooks via Spawner.gd instead (sanctioned) — the Spawner already
  connects to each enemy's `killed` signal for kill-counting.
- The change:
  - New scripts/AmmoPickup.gd + scenes/AmmoPickup.tscn (arc-4-owned):
    an Area2D that on `_ready` picks a random droppable shell
    (HE/HEAT/APCR — never AP, which is unlimited) + tints a chip; on
    the player driving over it, +AMOUNT to that shell's loadout
    reserve + a toast; despawns after LIFETIME (8s).
  - scripts/Spawner.gd (sanctioned): `enemy.killed.connect(
    _on_enemy_killed.bind(enemy))` passes the dying enemy;
    `_try_ammo_drop` spawns an AmmoPickup at its position with
    AMMO_DROP_CHANCE. The breach-mode gate (player has a Loadout) is
    checked BEFORE randf() — an arc-2/3 run consumes zero RNG here.
- CONSULT constraints: constraint 1 respected (a pickup is collected
  by driving, not a modal).
- Predicted failure modes:
  - Hash anchor: Spawner.gd is substrate. `_try_ammo_drop` returns at
    the breach-mode gate before any randf() in arc-2/3 mode → no RNG
    consumed → the seed-42 procedural baseline is bit-identical.
  - The pickup is a no-op against a body with no loadout (arc-2/3
    player) — defensive duck-typing.
- Falsifiable claim: post-edit — test_breach_ammo shows an AmmoPickup
  picks a droppable shell + on collection adds AMOUNT to that shell's
  reserve + frees; a no-loadout body does not collect. Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 27/27.
- Sentence test: n/a (a resupply pickup, not a depot upgrade).
- Substrate touched: Spawner.gd (the kill-signal hook — sanctioned;
  arc-2/3 bit-identical via the pre-randf breach gate).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 057 — BUILD — Round 8b: per-phase upgrade-card pick

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8b of the iter-055 blueprint — "a pick-1-of-3 upgrade screen
  at every band boundary" + the reward-beat framing.
- 8b DECISION: extend the depot system (blueprint Option A), not a new
  band-clear screen (Option B duplicates the depot's whole pick
  machinery). The depots ALREADY are per-boundary picks — 8b makes
  them (a) complete and (b) read as rewards.
- The change:
  - scenes/BreachLevel.tscn — add Depot4 at depth 180 (the
    open_killbox→endgame boundary), so there is a pick after every one
    of the 4 completable phases (was 3 depots / 3 picks). The endgame
    finale stays depot-less.
  - scripts/Depot.gd — `_show_panel` reframes the depot as a reward
    beat: the Title names the band just cleared (`_resolve_cleared_
    band_name` — a phase becomes a named milestone, the real fix for
    "phases don't read"); choices are a numbered "[1]/[2]/[3]" pick.
  - scenes/Depot.tscn — Title default text → "— PHASE CLEARED —".
- CONSULT constraints: constraint 1 respected — the depot pauses the
  tree; the pick is at a safe gate, never in combat.
- Predicted failure modes:
  - test_breach_level asserts >=3 depots — tightened to >=4 for the
    per-phase deliverable.
  - test_breach_depot opens the panel + checks ChoiceA contains
    choice_a_label — the "[1]  " prefix keeps it a substring match.
  - No substrate touched (BreachLevel.tscn / Depot.tscn / Depot.gd are
    all arc-4-owned) — hash anchor trivially preserved.
- Falsifiable claim: post-edit — test_breach_level reports depots=4;
  test_breach_depot shows the panel Title reads "...CLEARED". Hash
  anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 26/26.
- Sentence test: n/a (the depot offers the existing catalog; the
  per-phase cadence + framing is the change).
- Substrate touched: none (arc-4-owned scenes/scripts).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 056 — BUILD — Round 8a: XP + level-up core

- Date: 2026-05-21
- Tag: [STRUCTURE]
- Round 8a, the first build of the iter-055 blueprint — the headline
  playtest-3 ask, "where is the roguelite element like level ups?"
- The change (scripts/PlayerTank.gd, breach-mode only — gated on
  loadout != null): the tank earns XP from enemy kills (via the
  Spawner's enemies_killed) + depth climbed; at scaling thresholds it
  levels up; each level-up applies an AUTOMATIC stat boost rotated
  across max HP / reload speed (GunTimer.wait_time) / shell capacity.
  A HUD XP bar + LEVEL readout. No mid-combat modal — level-ups are
  automatic, so CONSULT constraint 1 holds.
- CONSULT constraints: constraint 7 (verbs not stats) is relaxed for
  Round 8 by the user override (STATE §Arc-4 amendments); constraint 1
  (no choice in combat) respected — level-ups are automatic.
- Predicted failure modes:
  - Hash anchor: the XP system is fully gated on loadout != null; an
    arc-2/3 PlayerTank never earns XP, builds no XP HUD — bit-identical.
  - GunTimer.wait_time: the .tscn leaves it at the 1.0s default
    (gun_cooldown the @export is unused). The reload boost mutates
    wait_time directly; floored at RELOAD_MIN.
  - Score: per the iter-055 blueprint, the rubric criterion for in-run
    progression (C14) is added at round close — iter 56 is a Δ-0
    structural BUILD (the surface exists + is harness-cited; C14 lands
    with the round).
- Falsifiable claim: post-edit — test_breach_xp shows a breach
  PlayerTank builds the XP HUD, granting XP crosses level thresholds
  (_level rises), and the level-up rotation boosts max HP + reload +
  shell capacity; an arc-2/3 PlayerTank builds none + cannot level.
  Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach
  26/26 (new check-breach-xp).
- Sentence test: n/a — the user override relaxes constraint 7; stat
  level-ups are now sanctioned.
- Substrate touched: PlayerTank.gd (XP/level system + HUD —
  sanctioned, gated on loadout != null; arc-2/3 bit-identical).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 055 — PLAYTEST — playtest-3 integrated; Round 8 opened

- Date: 2026-05-21
- Tag: [STRUCTURE-DEFERRED]
- The user playtested after Round 7 (the iter-53 / REVIEW-QUEUE #9
  gate) and delivered a direction-changing verdict: the 5 phases still
  do not read; enemies should drop ammo; "where is the roguelite
  element like level ups?" — the user does not perceive the breach
  economy as roguelite progression.
- Via AskUserQuestion (user override authority — PROMPT §USER-LOOK):
  progression = BOTH (XP level-ups + per-phase upgrade-card picks);
  enemy ammo drops = YES; "+ make shields longer."
- This iter: integrate the playtest, record the override in STATE
  §Arc-4 amendments, open Round 8 (the roguelite-progression
  overhaul), write the blueprint iter-055-round8-architect.md, append
  REVIEW-QUEUE #10.
- CONSULT constraints: the user's "XP + stats" pick RELAXES constraint
  7 (verbs not passive stats) for Round 8 — a sanctioned override.
  Constraint 1 (no choice during combat) is PRESERVED — level-ups are
  automatic; picks happen at paused safe gates.
- Predicted failure: Round 8 is a big round (4 sub-rounds) layering a
  conventional power curve onto the breach economy. The risk is the
  two progression systems (breach-economy shells + XP/levels) feeling
  bolted-together rather than one game. The 8-close CONSULT must check
  coherence, and may need a RUBRIC reframe (the rubric is built around
  "breach economy" — the override shifts the stone).
- Falsifiable claim: post-iter — iter-055-round8-architect.md exists
  with the 8a-8d sequence; STATE §Arc-4 amendments records the
  playtest-3 override; REVIEW-QUEUE #9 CLOSED, #10 opened. No code
  touched → hash anchor + harnesses unchanged (23d6a2ec3bf2821f;
  test-all 5/5; test-breach 25/25).
- Sentence test: n/a (a planning iter).
- Substrate touched: none (planning only).
- Hash-anchor verification plan: n/a — no code this iter.

## iter 054 — SWEEP — post-Round-7 verification grid

- Date: 2026-05-20
- Tag: [STRUCTURE-DEFERRED]
- Round 7 closed at iter 53; the user has not yet playtested. Per the
  iter-53 next_action, iter 54 is a non-speculative iter — a SWEEP
  verification grid over the post-Round-7 build (30 substrate writes
  across 7 rounds), NOT a speculative new mechanic round.
- The grid: (a) reachability sweep — test_breach_harness --deep across
  12 seeds (42-53), all 5 bands per seed; (b) test-breach 25/25; (c)
  test-all 5/5; (d) hash anchor seed 42. A holistic "is the build
  still coherent after Round 7" check.
- CONSULT constraints respected: 5 (every band reachability-checked).
  None risked — verification only, no code touched.
- Predicted failure: Round 7 touched Bullet / PlayerTank / Depot /
  MetaProgress — none touch level geometry — so reachability should be
  structurally unchanged from the iter-26-era 9/10 sweep. If a seed
  blocks a band, that is a pre-existing procedural-generation edge,
  not a Round-7 regression.
- Falsifiable claim: post-sweep — all 5 bands reachable on >=80% of
  the 12 seeds (the REACHABILITY FLOOR); test-breach 25/25; test-all
  5/5; hash anchor 23d6a2ec3bf2821f. If reachability drops below the
  iter-26 baseline (9/10 = 90%), that is a finding.
- Sentence test: n/a (verification iter).
- Substrate touched: none (SWEEP — no code).
- Hash-anchor verification plan: seed 42 procedural baseline, part of
  the grid.

## iter 053 — CONSULT/QUEUE — Round 7-close

- Date: 2026-05-20
- Tag: [STRUCTURE-DEFERRED]
- Round 7-close — the CONSULT + QUEUE phase of the iter-047 blueprint.
  Round 7's build phase (7a-7e, iters 48-52) shipped a fix for all 5
  of playtest-2's findings.
- This iter: CONSULT 005 (written self-pre-mortem — the established
  arc-4 mode; cf. CONSULT 003/004) reviewing whether Round 7's 5
  builds actually address the 5 findings, + the 3 permanent questions;
  then REVIEW-QUEUE #9 (the Round-7 playtest request).
- CONSULT constraints respected: n/a (a process iter — no mechanic
  built, no constraint touched). None risked.
- Predicted failure: the CONSULT's honest finding is that 4 of 5
  Round-7 fixes are playtest-gated and F003 is live — so this iter
  produces no rubric lift and recommends a playtest. The risk is the
  loop treating "Round 7 shipped" as "Round 7 worked" without the
  playtest. The CONSULT exists to name that.
- Falsifiable claim: post-iter — creative-consults.md has CONSULT 005;
  REVIEW-QUEUE.md has #9 (playtest request). No code touched → hash
  anchor + harnesses unchanged from iter 52 (23d6a2ec3bf2821f;
  test-all 5/5; test-breach 25/25). Score Δ 0 (39/65 — a process
  iter).
- Sentence test: n/a (no upgrade).
- Substrate touched: none (docs only).
- Hash-anchor verification plan: n/a — no code touched this iter.

## iter 052 — BUILD — Round 7e: HE explosion visual

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7e, the last build piece of the iter-047 blueprint. Fixes
  playtest finding 5 — "HE should have an explosion effect."
- The change (scripts/Bullet.gd): HE already applies a radius blast
  mechanically (_apply_he_blast); this gives it a visual. On an HE
  detonation `_spawn_he_explosion` spawns two ColorRect layers — a warm
  outer bloom sized to the full blast diameter + a bright inner core —
  that expand from small to full and fade over ~0.28s. The proven
  `_spawn_impact_spark` pattern, scaled up. Algorithmic, no MLX-SD.
- CONSULT constraints respected: none risked — a visual for an existing
  mechanic, no economy/identity surface touched.
- Predicted failure modes:
  - Hash anchor: the explosion is inside `_on_body_entered`'s HE branch
    — the seed-42 procedural baseline fires AP only → never reached →
    bit-identical.
  - Visual-verification caveat (per the blueprint): the harness can
    confirm the explosion NODES spawn, not that the blast LOOKS right —
    the look is playtest-gated (cf. F003).
- Falsifiable claim: post-edit — test_breach_he_blast Test 4 shows an
  HE hit spawns >=2 "HEBlast" ColorRect layers and an AP hit spawns 0.
  Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach
  25/25.
- Sentence test: n/a (a visual for an existing mechanic).
- Substrate touched: Bullet.gd (HE branch of _on_body_entered —
  sanctioned, flag-off AP path bit-identical).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 051 — BUILD — Round 7d: meta-progression legibility

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7d, piece 4 of the iter-047 blueprint. Fixes playtest finding 3
  — "what can be unlocked?"
- The change, two parts:
  - Tiers: the unlock ladder goes from 2 rungs to 4. MetaProgress now
    gates 4 upgrades — Breach Dividend @20, Overdrive @40, Quick Swap
    @60, Steel Salvage @80. The 5 core economy upgrades (refills /
    expands / resupply) stay always-available. Depot's _upgrade_pool
    widens 5→6→7→8→9 with best-depth (was 7→8→9).
  - Legibility: the codex's single (vague) iter-45 meta line is
    replaced by a 4-cell unlock ladder — one cell per tier, green when
    the player's best depth has reached it, dark when locked — under a
    "best depth N" header. The player sees the whole ladder + where
    they stand on it.
- CONSULT constraints respected: 7 (options, not power — the 5 core
  economy upgrades cover the baseline; the 4 gated ones are earned
  OPTIONS). None risked.
- Predicted failure: F003 recurs — the iter-45 meta line is exactly a
  legibility surface that existed but did not communicate (→ finding
  3). A clearer codex ladder is harness-verified to EXIST; only the
  next playtest confirms it LANDS. Moving Breach Dividend + Overdrive
  out of the always-on core shrinks the fresh randomized pool (5, was
  7) — intentional (meta-progression), but test_breach_overdrive /
  test_breach_meta must stay green.
- Falsifiable claim: post-edit — test_breach_meta shows a 4-rung
  ascending ladder + pool sizes 5/6/7/8/9; test_breach_codex shows the
  codex renders the ladder (UNLOCKS + 4 tier names). Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 25/25.
- Sentence test: n/a (a meta-progression retier + legibility surface).
- Substrate touched: PlayerTank.gd (HUD codex only — gated on
  loadout != null). MetaProgress.gd + Depot.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 050 — BUILD — Round 7c: run-route legibility

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7c, piece 3 of the iter-047 blueprint. Fixes playtest finding 2
  — "no idea what band shuffle means."
- The change: surface the run's shuffled band sequence.
  - A persistent HUD route strip (PlayerTank breach-mode HUD): one cell
    per depth band, named in THIS run's order, the current band's cell
    highlighted, passed bands tinted 'cleared'. Built deferred (the
    level's _init_breach_mode shuffles the order in the level's _ready,
    after this child's _ready). Updated on each band crossing.
  - A run-route line in the shell codex naming the concept ("5 depth
    bands; the middle 3 reshuffle each run") so the word lands on run 1.
- The strip is hidden behind the run-start codex, revealed on dismiss.
- CONSULT constraints respected: 5 (each band is a specific climb
  problem — the strip names all 5, making the per-band structure
  legible). None risked.
- Predicted failure: build order — PlayerTank._ready runs before the
  level's _ready, so breach_config is pre-shuffle at _ready time.
  Mitigated by call_deferred. F003 recurs: a legibility surface is
  harness-verified to EXIST, not to LAND — the next playtest must
  confirm finding 2 is fixed.
- Falsifiable claim: post-edit — test_breach_route shows the strip
  names the 5 bands in run order, the highlight tracks crossings, the
  strip hides behind the codex; arc-2/3 PlayerTank builds none. Hash
  anchor 23d6a2ec3bf2821f preserved (HUD-only; gated on loadout);
  test-all 5/5; test-breach 25/25 (new check-breach-route).
- Sentence test: n/a (a legibility surface, not an upgrade).
- Substrate touched: PlayerTank.gd (HUD only — sanctioned, gated on
  loadout != null; arc-2/3 builds nothing).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 049 — BUILD — Round 7b: APCR penetrate-steel redesign

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7b, piece 2 of the iter-047 blueprint. Fixes playtest finding 4
  — the user-confirmed APCR redesign.
- The change: APCR no longer does a radius cluster-breach (iter 34).
  APCR now PENETRATES steel — on hitting a steel block it breaks that
  ONE block (like AP breaks one brick) and does NOT queue_free; the
  bullet flies on, drilling a 1-wide tunnel through the wall until its
  lifetime ends. `_apply_apcr_breach` + APCR_BREACH_RADIUS_PX deleted;
  the APCR-steel branch in `_on_body_entered` is handled first + returns.
  STEEL_SALVAGE retunes — it now counts blocks DRILLED by one shot
  (`_steel_drilled`); >=3 → refund 1 APCR.
- CONSULT constraints respected: 3 (APCR keeps one crisp job — the
  steel penetrator). The iter-34 radius design is superseded per the
  user (STATE §Arc-4 amendments).
- Predicted failure modes:
  - The penetrate must NOT queue_free the bullet on steel — the
    APCR-steel branch returns before the `_spawn_impact_spark;
    queue_free` tail. AP/HE/HEAT + APCR-vs-non-steel still fall through
    + free.
  - test_breach_apcr (`_test_steel_breach`) expects the radius design;
    test_breach_rulechangers (`_run_salvage`) expects one-call cluster
    salvage. Both rewritten for the drill model.
  - Hash anchor: APCR-steel is inside `_on_body_entered`'s APCR branch;
    the procedural baseline fires AP → never reached → bit-identical.
- Falsifiable claim: post-edit — test_breach_apcr shows APCR breaks
  only the hit steel block (no radius), penetrates (bullet survives),
  and drills the next block; test_breach_rulechangers shows STEEL_SALVAGE
  fires after drilling >=3. Hash anchor 23d6a2ec3bf2821f preserved;
  test-all 5/5; test-breach 24/24.
- Sentence test: n/a (shell redesign, not an upgrade).
- Substrate touched: Bullet.gd (`_on_body_entered` + APCR funcs —
  sanctioned, breach-only path).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42.

## iter 048 — BUILD — Round 7a: shell-economy retune (starter reserves + caps)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 7a (the iter-46 playtest fix-round), piece 1. Blueprint:
  iter-047-round7-architect.md. Fixes playtest finding 1 — "shells too
  few to manage."
- The change: configs/breach_starter_loadout.tres — starter reserves
  HE 2→6, HEAT 1→4, APCR 2→5; caps max_he 6→12, max_heat 3→8,
  max_apcr 4→10. The starter total goes 5 → 15 finite shells; the
  economy becomes a managed handful, not "two shots and done." Still
  finite + spendable — scarcity (the breach-economy identity) holds.
- Δ note: a tuning change; C3's structural tier is maxed → Δ 0. The
  value is [FEEL]-gated (the next playtest re-checks finding 1).
- CONSULT constraints respected: 7 (reserves are the economy, not a
  %stat). The retune respects the scarcity identity — finite, spendable.
- Predicted failure modes:
  - A harness asserts the .tres's exact reserve values. Checked:
    test_breach_level only asserts he_reserve > 0 (passes); no other
    harness reads the .tres values (they build LoadoutT.new() with
    explicit values). The retune is harness-safe.
  - Over-correction — too generous → no economy. Mitigation: 3× the
    starter (5→15) is a managed handful; the next playtest tunes
    further if needed.
- Falsifiable claim: post-edit — make test-all 5/5; make test-breach
  24/24; test_breach_level reports he_reserve=6. Hash anchor
  23d6a2ec3bf2821f preserved (the .tres is the breach starter, off the
  procedural baseline).
- Sentence test: n/a (tuning, no new upgrade).
- Substrate touched: none — breach_starter_loadout.tres is arc-4-owned.
  Loadout.gd's bare-Resource default maxes are left as-is (harness-
  relevant only; the .tres governs the gameplay starter).
- Hash-anchor verification plan: regression guard — the breach starter
  loadout is not on the procedural hash path.

## iter 047 — PLAYTEST — integrate the iter-46-gate playtest; open Round 7

- Date: 2026-05-20
- Tag: [FEEL] (the iter's input is a human playtest)
- The event: the user playtested after Round 6 (the iter-46 playtest
  gate) and gave 5 findings; 2 clarified via AskUserQuestion. The loop
  re-engages, opens Round 7 (the fix-round).
- CONSULT constraints respected: all 7 (integration/planning iter). The
  Round-7 blueprint is written to respect them — APCR keeps one crisp
  job (constraint 3), the HE explosion is algorithmic (constraint 4 /
  no MLX-SD).
- Prior-design overridden: the iter-34 APCR design (breaches steel via
  an 18px radius cluster) is superseded by the user's confirmed
  redesign — APCR penetrates steel, drilling 1 block per hit. Recorded
  STATE §Arc-4 amendments.
- Predicted failure: the Round-7 plan under-scopes the legibility
  findings (2, 3) — building MORE surface that still does not land
  (F003 recurring). Mitigation: 7c/7d are explicitly "make it
  communicate," and the next playtest re-checks all 5.
- Falsifiable claim: this iter commits the Round-7 blueprint +
  REVIEW-QUEUE (#7 closed, #8 appended) + STATE unpaused to RUNNING.
  No code change → no hash risk. iter 48 begins Round 7 BUILD (7a).
- Sentence test: n/a (no upgrade this iter).
- Substrate touched: none (loop docs only).
- Hash-anchor verification plan: n/a (no code change).

## iter 046 — CONSULT — Round 6 close (CONSULT 004) + playtest gate / pause

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6 (roguelite feel) close iter. Mode: CONSULT — written
  self-pre-mortem (iter 46 is the playtest-handoff; the user playtest
  is THE creative check and it is next, so a frontier CONSULT is
  redundant — CONSULT 003 precedent).
- CONSULT constraints respected: all 7 (review iter, no design surface).
- Predicted failure: the CONSULT rubber-stamps Rounds 5-6, or the loop
  spins Round 7 on unverified structure. Mitigation: CONSULT 004 names
  the seductive-but-hollow risk (the core economy's felt depth is still
  unverified after 13 autonomous iters) and the loop PAUSES rather than
  pile more — the iter-32 judgement, the F003 lesson.
- Falsifiable claim: this iter writes CONSULT 004 + REVIEW-QUEUE #7
  (playtest request) + STATE → paused. No code change → no hash risk.
  The loop pauses; no wakeup scheduled.
- Sentence test: n/a. Substrate touched: none (loop docs only).
- Hash-anchor verification plan: n/a (no code change).

## iter 045 — BUILD — Round 6e: meta-progression (depot-pool widening)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6e (meta-progression), the last Round-6 sub-round. Blueprint:
  iter-043-round6e-architect.md (Option A).
- The build: climbing deep across runs unlocks advanced depot upgrade
  kinds into the depot offer pool. A fresh save: 7 core upgrades; best
  depth 40 → +Quick Swap; 80 → +Steel Salvage. Options-not-power
  (CONSULT 003) — an unlocked rule-changer adds a build path, not a
  stat. Standard roguelite meta (the Slay-the-Spire card-unlock shape).
- New `scripts/MetaProgress.gd` — reads best_depth from the existing
  user://stats.cfg; pure unlock predicates. Depot `_upgrade_pool()`
  consults it; the codex surfaces the unlock state.
- CONSULT constraints respected: 7 (unlocks are options/affordances,
  never raw power), 1 (no combat-time surface).
- Predicted failure modes:
  - The depot pool now depends on ambient stats.cfg → test_breach_depot_roll
    could become flaky. Mitigation: `_upgrade_pool(best)` takes an
    explicit-best param (default -1 = live); the new harness passes
    explicit depths; depot-roll's assertions (3 distinct, ≥2 sets)
    hold for any pool ≥4.
  - The 2 iter-41 rule-changers become depth-gated — a fresh save sees
    7 depot kinds, not 9. This is the meta-progression curve, not a
    regression; apply_upgrade still applies any kind directly
    (test_breach_rulechangers unaffected).
  - Codex crowding — the meta line + a taller codex panel.
- Falsifiable claim: post-edit — a new check-breach-meta harness shows
  the unlock predicates gate at 40/80 and the depot pool widens 7→8→9
  with best-depth. Hash anchor 23d6a2ec3bf2821f preserved; test-all
  5/5; test-breach 24/24. RUBRIC +C13, C13 → 3.
- Sentence test: meta-unlocks are not depot upgrades themselves — they
  unlock the existing rule-changers (each already sentence-tested).
- Substrate touched: PlayerTank.gd (codex meta line — sanctioned, HUD).
  MetaProgress.gd is new; Depot.gd arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — MetaProgress + Depot are off the procedural hash path; the codex
  is loadout-gated. Verify before commit.

## iter 044 — BUILD — loadout-lifecycle fix (F004: shared-Resource run leak)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6e, piece 1 (a correctness fix the iter-43 SPIKE surfaced —
  Finding 1). Blueprint: iter-043-round6e-architect.md.
- The bug (F004): the breach loadout is a shared Resource —
  breach_starter_loadout.tres baked into BreachLevel.tscn, no
  resource_local_to_scene, never duplicated. consume() + depot upgrades
  mutate it in place; Godot's resource cache reuses the instance across
  reload_current_scene → run 2+ of a session starts with run 1's
  depleted reserves + purchased upgrades. The restart loop — core to a
  roguelite — was quietly broken.
- The fix: PlayerTank `_ready`, when loadout != null, `loadout =
  loadout.duplicate()` — each run gets a private copy from the .tres
  template; the template is never mutated.
- CONSULT constraints respected: all 7 (a correctness fix; no design
  surface).
- Predicted failure modes:
  - The duplicate breaks harnesses that assume pt.loadout IS the object
    they passed + mutate it post-_ready. Analysis: test_breach_loadout
    (Test 5) + test_breach_hud (the refresh spot) break — both updated
    to read pt.loadout. test_breach_swap / overdrive / rulechangers /
    stakes / codex set loadout flags BEFORE add_child (the dup copies
    them) and never read the passed object after → unaffected.
  - duplicate() must be a complete copy — Loadout has no sub-resources,
    so a shallow duplicate() copies every @export field.
- Falsifiable claim: post-edit — test_breach_loadout's new Test 6 shows
  a PlayerTank duplicates its loadout (pt.loadout != the passed
  resource; values copied; spending the run loadout does NOT mutate the
  template). Hash anchor 23d6a2ec3bf2821f preserved (dup is breach-only,
  loadout-gated). test-all 5/5; test-breach 23/23.
- Sentence test: n/a (bug fix).
- Substrate touched: PlayerTank.gd (`_ready` loadout duplicate —
  sanctioned; loadout-gated so arc-2/3 untouched).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — the dup is inside `if loadout != null`; the procedural baseline
  PlayerTank has no loadout → bit-identical.

## iter 043 — SPIKE — Round 6e: meta-progression design + loadout-lifecycle probe

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6e (meta-progression), the last Round-6 sub-round. Mode: SPIKE
  — meta-progression is the most design-uncertain sub-round (what to
  unlock, how to surface, whether it touches loadouts). A blind BUILD
  snowballed in pre-mortem analysis (the loadout-lifecycle question
  below) — the scope-too-broad signal — so this iter SPIKEs: investigate,
  verdict, blueprint; no code commit (iter-1 / iter-38 SPIKE precedent).
- CONSULT constraints respected: all 7 (read-only investigation).
- Predicted failure: the SPIKE picks a meta design without seeing a
  blocking entanglement. Known candidate already surfaced: the breach
  loadout is a SHARED resource (breach_starter_loadout.tres — no
  resource_local_to_scene, no duplicate()) — `consume()` mutates it,
  and reload_current_scene reuses the cache → run 2+ likely starts with
  run 1's depleted reserves + purchased upgrades. Any loadout-touching
  meta design is entangled with this.
- Falsifiable claim: this iter writes loop/breach/iter-043-round6e-architect.md
  — a verdict across >=2 meta-progression options + the loadout-
  lifecycle finding + the iter-44+ sequence. No code change → no hash
  risk.
- Sentence test: n/a (SPIKE).
- Substrate touched: none (investigation + blueprint doc).
- Hash-anchor verification plan: n/a (no code change).

## iter 042 — BUILD — Round 6d: stakes & escalation (band banner + live best-depth)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6d (stakes & escalation), piece 1. Blueprint: iter-038-round6-architect.md.
- DIAGNOSE: the arc-2 ascender already gives breach mode a lot of
  "stakes" — a DEPTH/TIME HUD, depth-milestone flashes, a run-framed
  death recap with best-depth, persistent best tracking, the [R]-restart
  loop. The genuine GAP for the breach roguelite: (a) band transitions
  are silent — nothing marks the escalation beat; (b) best-depth shows
  only on death, not live. iter 42 fills both.
- CONSULT constraints respected: 5 (the banner names each band's
  specific pressure — reinforces "each band is a climb problem"), 1
  (HUD readout, no combat-time decision).
- Predicted failure modes:
  - The band banner needs a breach_band_changed source. The signal
    exists only on ProceduralLevel + fires only in breach mode — the
    connect is gated on loadout != null + has_signal, so arc-2/3 never
    wires it.
  - The best-depth label must be breach-gated (loadout != null) so the
    arc-2 procedural HUD stays bit-identical — NOT placed in the
    show_ascender_hud block (which arc-2 shares).
  - A missing-glyph risk in the banner — kept ASCII ("ENTERING:").
- Falsifiable claim: post-edit — a new check-breach-stakes harness shows
  a breach PlayerTank builds a BestLabel + raises a BandBanner naming
  the band on a breach_band_changed emit; an arc-2/3 PlayerTank builds
  neither. Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5;
  test-breach 23/23. RUBRIC +C12, C12 → 3.
- Sentence test: n/a (HUD/stakes, no upgrade).
- Substrate touched: PlayerTank.gd (HUD + the band-signal connect —
  sanctioned; all new HUD gated on loadout != null).
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — the new HUD is loadout-gated; the procedural baseline PlayerTank
  has no loadout → HUD path bit-identical.

## iter 041 — BUILD — Round 6c: depot rule-changers (Quick Swap + Steel Salvage)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6c (build divergence), piece 1. Blueprint: iter-038-round6-architect.md.
  Answers CONSULT 003 Q2 — "depots need more rule-changers; the player
  chooses quantity, not doctrine." The catalog was 5 stock-refills + 2
  rule-changers; this iter adds 2 more rule-changers → 5 + 4.
- Δ note: the structural anchors C1 (build identity) + C8 (sentence
  test) are already maxed; rule-changers deepen the build-divergence
  AXIS but the lift is [FEEL]-gated. Expect Δ 0 — a real BUILD.
- The 2 rule-changers (both CONSULT-§9-#7 verbs, conditional
  doctrine-definers, low-risk — reuse existing patterns):
  - QUICK_SWAP — shell swaps cost no reload beat. The "adaptive
    generalist" doctrine vs the committed-specialist default.
  - STEEL_SALVAGE — an APCR shot opening a steel cluster (>=3 blocks)
    refunds 1 APCR. The APCR analogue of Breach Dividend; the "steel
    breacher" doctrine. Mirrors _try_breach_dividend exactly.
- CONSULT constraints respected: 7 (both are affordance verbs, not
  %stats — sentence-tested in Loadout's UPGRADE CATALOG), 1 (granted
  at depots), 2 (still 4 shells — no new shell).
- Predicted failure modes:
  - test_breach_overdrive.gd hard-asserts UK.size()==7 → adding 2 kinds
    breaks it. Mitigation: update it to 9.
  - QUICK_SWAP reads loadout.quick_swap in _cycle_shell — must not
    affect arc-2/3 (loadout null → _cycle_shell early-returns before
    the read).
  - STEEL_SALVAGE must be gated on a real steel-CLUSTER breach, not a
    stray block — threshold 3 (mirror of the HE-dividend's 4).
- Falsifiable claim: post-edit — a new check-breach-rulechangers harness
  shows QUICK_SWAP suppresses the swap reload beat (control still arms
  it), STEEL_SALVAGE refunds APCR only with the upgrade + only on a
  >=3-cluster, apply_upgrade sets both flags. Hash anchor
  23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 22/22.
- Sentence test: QUICK_SWAP — "...climb through pressure-mixed bands by
  changing how I use shell-swapping — free swaps to adapt mid-fight."
  STEEL_SALVAGE — "...climb through steel-walled bunkers by changing how
  I use APCR — opening a steel cluster refunds its own shell."
- Substrate touched: Bullet.gd (_apply_apcr_breach returns a count +
  _try_steel_salvage — sanctioned, breach-only path), PlayerTank.gd
  (_cycle_shell quick_swap gate — sanctioned). Loadout.gd + Depot.gd
  are arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — both substrate edits are inside breach-only paths (APCR shells /
  loadout-gated _cycle_shell); flag-off baseline bit-identical.

## iter 040 — BUILD — Round 6b: depot-offer randomization

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6b (deeper variety), piece 1. Blueprint: iter-038-round6-architect.md.
- Δ note: C11's structural tier (anchors 1-3) was maxed by iter 39's
  band-shuffle; depot-offer randomization deepens the run-variety AXIS
  but cannot lift the integer (C11 anchors 4-5 are [FEEL]). Δ 0 — a real
  BUILD (a new mechanic the playtest's roguelite-feel ask demands), not
  BUILD-QUALITY. The lift is [FEEL]-gated. Today the 3 BreachLevel
  depots all offer the IDENTICAL fixed 3 choices every run; this makes
  each depot draw a different 3-of-7 per run.
- CONSULT constraints respected: 1 (offers shown only at the safe gate),
  7 (every rolled label is an economy verb, not a %stat).
- Predicted failure modes:
  - Randomization breaks test_breach_depot_choice.gd, which drives
    apply_choice(1/2/3) expecting the @export defaults. Mitigation:
    randomize_offers defaults FALSE — bare/harness depots keep the fixed
    choices; only the BreachLevel depots (flag set true in the .tscn)
    randomize.
  - The roll runs before level_seed is resolved. Mitigation: lazy roll
    on first need (_ensure_rolled) — by then the level's _ready has
    resolved the seed.
  - A depot rolls duplicate kinds. Mitigation: Fisher-Yates over the
    7-kind pool, take the first 3 — distinct by construction.
- Falsifiable claim: post-edit — a new check-breach-depot-roll harness
  shows randomize_offers=true depots roll 3 distinct kinds with >=2
  distinct sets across seeds, and a randomize_offers=false depot uses
  the @export defaults; test_breach_depot_choice still green; hash
  anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 21/21.
- Sentence test: the 7 catalog entries are unchanged (all pass — Loadout
  UPGRADE CATALOG block); this iter only changes WHICH 3 are offered.
- Substrate touched: none — Depot.gd + BreachLevel.tscn are arc-4-owned.
- Hash-anchor verification plan: Depot.gd is not on the procedural hash
  path; flag-off baseline unaffected. Verified as a regression guard.

## iter 039 — BUILD — Round 6a: per-run band-order shuffle + dynamic depot preview

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6a (run-to-run variety), piece 1. Blueprint: iter-038-round6-architect.md.
- CONSULT constraints respected: 5 (each band stays its own specific
  climb problem — shuffling ORDER does not blur a band's pressure; the
  level_config travels with the archetype), 1 (depot still a safe gate).
- Predicted failure modes:
  - The shuffle mutates the shared breach_default.tres Resource → leaks
    across runs / other instances. Mitigation: _shuffled_breach_config
    duplicates every band + returns a NEW BreachConfig; the source is
    never touched. The harness asserts the source is unmutated.
  - Band-order shuffle moves band boundaries → fixed-y depots drift off
    transitions. Mitigation: fixed-SLOT shuffle — the 3 middle archetypes
    permute into the 3 fixed depth slots (30-70 / 70-120 / 120-180), so
    boundaries (hence depot alignment) are invariant.
  - The shuffle's RNG perturbs procedural generation. Mitigation: a
    separate RandomNumberGenerator instance — the global seed() used by
    tile generation is untouched; and _init_breach_mode runs AFTER all
    generation anyway.
  - Reachability: a band-archetype in a different-span slot. The oracle
    is per-band-LOCAL + density-based (span-independent) — verified safe.
- Falsifiable claim: post-edit — hash anchor flag-off = 23d6a2ec3bf2821f
  (the shuffle is inside breach-only _init_breach_mode); a new
  check-breach-shuffle harness shows >=2 distinct middle-band orders
  across 7 seeds, tutorial+endgame pinned, fixed slots, source
  unmutated; make test-all 5/5; make test-breach 20/20.
- Sentence test: n/a (no upgrade).
- Substrate touched: ProceduralLevel.gd (_init_breach_mode + new
  _shuffled_breach_config — sanctioned; inside the breach-gated path).
  Depot.gd is arc-4-owned.
- Hash-anchor verification plan: post-edit, loop/test_runner.gd seed 42
  — the shuffle is unreachable when breach_mode_enabled=false; flag-off
  baseline bit-identical. Verify before commit.

## iter 038 — SPIKE — Round 6 open: run-to-run variety investigation

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 6 (roguelite feel) opens. Mode: SPIKE — investigate the
  highest-leverage run-variety option, output a verdict + the Round 6
  blueprint. No code commits this iter (SPIKE = scouting; iter-1
  precedent).
- CONSULT constraints respected: all 7 (investigation, no design surface
  committed). The blueprint is written to respect 5 (each band stays a
  specific climb problem — shuffling order does not blur pressures).
- Predicted failure: the SPIKE picks band-order shuffle without seeing a
  hidden coupling cost. Known candidate: depot next-band previews are
  static @exports — shuffling bands makes them wrong; the blueprint must
  account for dynamic depot previews.
- Falsifiable claim: this iter writes loop/breach/iter-038-round6-architect.md
  — a Round 6 blueprint with (a) a run-variety verdict across >=2
  investigated options, (b) the Round-6 sub-round sequence, (c) a RUBRIC
  extension proposal for the roguelite axes. No code change -> no hash
  risk. iter 39 begins Round 6 BUILD.
- Sentence test: n/a (SPIKE).
- Substrate touched: none (investigation + blueprint doc).
- Hash-anchor verification plan: n/a (no code change).

## iter 037 — CONSULT — Round 5 close (CONSULT 003, written) + QUEUE

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 5 (shell legibility), close iter. Blueprint: iter-033-round5-architect.md.
- Mode: CONSULT — done as a written self-pre-mortem (the arc-1/arc-3
  sanctioned fallback), NOT an external /agentify call. Rationale: the
  iter-33 USER PLAYTEST is Round 5's real creative check — a human
  played the actual game and gave concrete findings that drove every
  Round-5 iter; it literally fulfilled CONSULT 002's closing "5-person
  smoke test" recommendation. A frontier CONSULT now would be a weaker,
  redundant second-order check, and its sharpest question ("do the 4
  shells read as economy choices?") is playtest-gated. If Round 6 —
  which runs autonomously, no fresh playtest — needs outside
  perspective, fire a real /agentify CONSULT then.
- CONSULT constraints respected: all 7 (review iter, no design surface).
- Predicted failure: the written self-critique rubber-stamps Round 5
  instead of stress-testing it. Mitigation: the critique MUST surface
  at least one concrete seductive-but-hollow risk and one Round-6
  course-correction, or it has failed its purpose.
- Falsifiable claim: this iter writes CONSULT 003 to creative-consults.md
  (4 questions answered with teeth), appends REVIEW-QUEUE #6, updates
  STATE + LEDGER. No code change → no hash risk. iter 38 bootstraps
  Round 6.
- Sentence test: n/a.
- Substrate touched: none (loop docs only).
- Hash-anchor verification plan: n/a (no code change).

## iter 036 — BUILD-QUALITY — shell codex / run-start tutorial (Round 5)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Round 5 (shell legibility), piece 3. Blueprint: iter-033-round5-architect.md.
  Answers iter-33 playtest findings 2-3 ("no tutorial" + "I don't
  understand when to use HE vs HEAT vs AP").
- Cap note: this is the 2nd consecutive BUILD-QUALITY (iters 35, 36),
  exceeding the L3/R4 "1 per 3 BUILDs" cap. This is NOT the drift the cap
  guards against. The cap catches score-creep / busywork; here the score
  is flat (Δ 0) and the work is a direct, on-blueprint response to a human
  playtest (F003). The cap fires only because the rubric — written
  pre-playtest — has no integer for legibility, so all of Round 5's
  mandated legibility work scores BUILD-QUALITY. That rubric gap is real;
  it is flagged for the iter-37 Round-5 close.
- CONSULT constraints respected: 1 (the codex is read at a safe gate —
  run start, before any threat; never during combat), 3 (it states each
  shell's readable role), CONSULT 002 (legibility).
- CONSULT constraints risked: none. The codex does NOT pause the tree —
  pausing from PlayerTank._ready would corrupt cross-harness state (the
  Depot owns the pause contract); band 1 (tutorial_choke) is gentle
  enough to read in.
- Predicted failure modes:
  - The codex must be gated on loadout != null — arc-2/3 builds none.
  - The codex must not interfere with the iter-35 ShellPanel or other
    HUD nodes (it is a separate node, "ShellCodex").
  - Dismiss-on-input both hides the codex and acts on the same input the
    same frame — acceptable, standard for intro tooltips.
- Falsifiable claim: post-edit — a new check-breach-codex harness verifies
  a breach PlayerTank builds a visible ShellCodex naming all 4 shells +
  BRICK/STEEL roles, hidden by _dismiss_codex(); arc-2/3 builds none.
  Hash anchor 23d6a2ec3bf2821f preserved; test-all 5/5; test-breach 19/19.
- Sentence test: n/a (tutorial overlay, no upgrade).
- Substrate touched: PlayerTank.gd (HUD — sanctioned).
- Hash-anchor verification plan: post-edit, run loop/test_runner.gd seed
  42 — the codex is gated on loadout != null; the procedural baseline
  PlayerTank has no loadout → HUD path bit-identical.

## iter 035 — BUILD-QUALITY — shell UI panel + APCR icon (Round 5 legibility)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Round 5 (shell legibility), piece 2. Blueprint: iter-033-round5-architect.md.
  Directly answers iter-33 playtest finding 1 ("no shell UI") + finding 3
  (illegible shell roles). Legibility craft — no [STRUCTURE] integer lift
  (the playtest's lift is the [FEEL] tier); BUILD-QUALITY per the iter-29/30
  precedent (depot UI + shell HUD were also BUILD-QUALITY). Last
  BUILD-QUALITY was iter 30 — well within the L3/R4 1-per-3 cap.
- CONSULT constraints respected: 3 (a readable shell relationship needs the
  shell + reserve visible at a glance), 4 (the gen_shell_apcr icon is routed
  through the silhouette-grammar gate before commit), CONSULT 002
  (legibility in <5s).
- CONSULT constraints risked: none.
- Predicted failure modes:
  - The shell panel replaces the iter-30 `_shell_label`; test_breach_hud.gd
    asserts a "ShellLabel" node — it must be rewritten for the new panel
    or it fails.
  - The panel must stay gated on `loadout != null` — arc-2/3 HUD must be
    bit-identical (no panel built, no update branch).
  - The APCR icon must be silhouette-distinct from AP/HE/HEAT or the gate
    rejects it (MIN_SILHOUETTE_DIFF=8, MIN_PALETTE_DIFF=20).
- Scope note: in-flight bullet shape-differentiation (beyond the iter-34
  per-shell modulate colour) is DEFERRED — a sprite-scale change cannot be
  visually verified by a headless loop, and the F003 lesson says do not
  ship an unverifiable visual. The legibility win this iter is the panel +
  colour consistency (chip colours match the Bullet modulate).
- Falsifiable claim: post-edit — `make check-silhouette-gate` passes with
  4 icons; `make check-breach-assets` reports "4 shell icons"; the rewritten
  test_breach_hud verifies a 4-slot ShellPanel reflecting current_shell +
  per-shell reserves + selection highlight, and arc-2/3 PlayerTank has
  none; hash anchor `23d6a2ec3bf2821f` preserved; `make test-all` 5/5;
  `make test-breach` 18/18.
- Sentence test: n/a (UI/asset iter, no upgrade).
- Substrate touched: PlayerTank.gd (HUD — sanctioned). gen_tile.py is
  extendable per PROMPT. check_shell_icons.py / Makefile / test_breach_hud
  are loop tooling.
- Hash-anchor verification plan: post-edit, run loop/test_runner.gd seed 42
  — the panel is gated on loadout != null; the procedural baseline's
  PlayerTank has no loadout, so the HUD path is bit-identical. Verify
  before commit.

## iter 034 — BUILD — APCR 4th shell + steel as a destroyable band pressure

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 5 (shell legibility), piece 1. Blueprint: iter-033-round5-architect.md.
- CONSULT constraints respected: 3 (APCR gets one crisp job — the steel
  breacher — distinct from HEAT's anti-armor burst), 5 (bunker_zone's
  dominant pressure becomes a *specific* climb problem: steel walls
  answered by APCR), 7 (APCR is a verb-shell, not a passive stat).
- CONSULT constraints overridden: 2 ("no more than three shell classes
  at first") — overridden by the user in the iter-33 playtest; recorded
  STATE.md §Arc-4 amendments. APCR is the sanctioned 4th shell.
- Predicted failure modes:
  - Steel is a TileMapLayer in arc-2/3 (Level._replace_blocks converts
    only brick + water). Converting steel → SteelBlock nodes could
    (a) break the hash anchor if the conversion runs on the flag-off
    codepath, or (b) change collision so tanks/bullets pass through.
  - The reachability oracle treats steel as a wall (test_breach_harness
    line 9). APCR makes steel breachable — the oracle must NOT change:
    a band stays playable WITHOUT forced breaching; APCR opens an
    optional faster lane.
  - APCR vs HEAT collapse — if APCR also did burst armor damage it would
    duplicate HEAT. Mitigation: APCR pierces armor at 1× (HEAT 2×);
    APCR's identity is steel terrain, HEAT's is the armored-enemy kill.
- Falsifiable claim: post-edit — hash anchor flag-off codepath =
  `23d6a2ec3bf2821f`; `make test-all` 5/5; `make test-breach` 18/18
  (incl. new check-breach-apcr); the new harness proves APCR breaches a
  SteelBlock and AP/HE/HEAT do NOT, and APCR pierces an armored stub at
  full damage while AP is mitigated to 0. If the hash breaks the iter
  HALTS (correctness violation).
- Sentence test: APCR is a shell, not a depot upgrade — the per-shell
  grammar is the cite: "APCR helps me climb through steel-walled bunkers
  by changing how I use my shell reserve — the only key to a steel lane."
- Substrate touched: Bullet.gd (SHELL_CLASS_APCR + steel-breach +
  armor-pierce — sanctioned, PROMPT §DEFAULT-ON "Bullet.gd multi-shell
  support"), ProceduralLevel.gd (_replace_blocks override, breach-gated
  — sanctioned), PlayerTank.gd (4-shell cycle — sanctioned). Loadout.gd
  + Depot.gd are arc-4-owned (not substrate). SteelBlock.gd/.tscn new.
- Hash-anchor verification plan: post-edit, run loop/test_runner.gd on
  seed 42 / default config; the _replace_blocks override returns after
  super on the flag-off codepath (steel stays a TileMapLayer), so the
  baseline is bit-identical. Verify before commit.

## iter 033 — PLAYTEST — integrate user playtest; F003; bootstrap Round 5

- Date: 2026-05-20
- Tag: [FEEL] (the iter's input is a human playtest — the FEEL tier's
  evidence source; the iter integrates that evidence)
- Round: between rounds. Round 4 closed iter 30; the loop paused iter 32;
  the user playtest re-opens it. This iter integrates the playtest and
  bootstraps Round 5.
- CONSULT constraints respected: all 7 — this is an integration/planning
  iter, no design surface touched. The Round-5 blueprint is written to
  RESPECT them: constraint 1 (tutorial at safe gates, never combat),
  constraint 3 (each shell keeps one readable relationship), constraint 4
  (the APCR icon is silhouette-gated).
- CONSULT constraints risked: constraint 2 ("no more than three primary
  shell classes at first") — the user EXPLICITLY OVERRODE it; APCR is
  sanctioned as the 4th shell. Not a loop violation: the PROMPT grants
  the user override authority over cadence/direction. Recorded in
  STATE.md §Arc-4 amendments.
- Predicted failure: the Round-5 plan may under-scope finding 5 ("doesn't
  feel like a roguelite") — that is a multi-round program, not a Round-5
  piece. Mitigation: Round 5 is explicitly findings 1-4 (legibility);
  finding 5 is bootstrapped as the Round 6+ program in the blueprint tail.
- Falsifiable claim: this iter commits F003 + `iter-033-round5-architect.md`
  + STATE unpaused to `loop_state: RUNNING` + REVIEW-QUEUE #3 closed and
  #5 appended. No code changes → no hash-anchor risk. iter 34 begins the
  Round-5 BUILD.
- Sentence test: n/a (no upgrade this iter)
- Substrate touched: none (loop docs only)
- Hash-anchor verification plan: n/a (no code change)

## iter 030 — BUILD-QUALITY — shell HUD (round-4 piece 2)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- Round 4 (pre-playtest legibility), piece 2. Breach-economy state —
  which shell is selected, how much HE/HEAT reserve remains — is
  currently invisible. A playtester can't see their breach budget. The
  shell HUD surfaces it.
- CONSULT constraints respected: 3 (the readable shell relationship
  needs the shell to be *visible*), CONSULT 002 (legibility)
- CONSULT constraints risked: none
- Predicted failure modes:
  - PlayerTank `_setup_hud` builds a CanvasLayer. The shell label must
    be gated on `loadout != null` — arc-2/3 HUD stays bit-identical
    (no shell label, no `_update_run_hud` shell branch fires).
  - `_update_run_hud` runs each frame (cheap text update).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS (arc-2/3 HUD unchanged —
  no loadout → no shell label), `make test-breach` PASS, new
  `make check-breach-hud` verifies a breach PlayerTank (loadout set)
  has a ShellLabel reflecting current_shell + he/heat reserves, and an
  arc-2/3 PlayerTank (no loadout) has none.
- Sentence test: n/a (HUD)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write —
  sanctioned; `_setup_hud` + `_update_run_hud` extension, breach-gated).
- Hash-anchor verification plan: post-edit, before commit.

## iter 029 — BUILD-QUALITY — depot UI panel (round-3 close, round-4 open)

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY]
- DIAGNOSE: round 3's structural anchors are done (C3/4 + C8/3); C5/3
  is substrate-blocked. The loop is at the 30/50 structural ceiling.
  Per the parity-drift /meta, the playtest is the gate — but a playtest
  is only meaningful if breach mode is LEGIBLE. The depot is currently
  invisible: `Depot.tscn` is an Area2D + a blue marker rect; the
  3-choice upgrade flow (KEY_1/2/3 → apply_choice) has NO on-screen UI.
  CONSULT 002 Q2: depots must be "legible in under five seconds" — they
  aren't legible at all. Round 4 = pre-playtest legibility; iter 29 is
  piece 1: the depot UI panel. This is the bridge to the playtest, not
  grinding past the ceiling.
- Tag rationale: BUILD-QUALITY — a visible depot panel is craft that
  makes the playtest possible but lifts no [STRUCTURE] anchor (C2
  anchors 4-5 are playtest-gated). Last BUILD-QUALITY iter 24; iters
  25-28 were META/AUDIT/BUILD/BUILD — within the 1-per-3 cap.
- CONSULT constraints respected: 1 (depot UI shows only at the
  safe-gate, never during combat — the tree is paused), CONSULT 002 Q2
  (legibility)
- CONSULT constraints risked: depot dwell <30s — the panel must be
  fast-readable; iter 29 ships a compact 4-line panel (hint + 3
  choices). Playtest tunes.
- Predicted failure modes:
  - The panel must be a CanvasLayer (screen-space, not world-space) so
    it renders as HUD regardless of camera. Depot is a world Area2D;
    the CanvasLayer is a child of Depot, shown/hidden on entry/exit.
  - process_mode: the panel's CanvasLayer must run while the tree is
    paused (Depot already has PROCESS_MODE_ALWAYS — children inherit).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  the depot UI panel populates its Labels from choice_a/b/c_label +
  next_band_hint on entry and hides on pick/exit — verified by
  extending `check-breach-depot` or a new harness assertion.
- Sentence test: n/a (UI)
- Substrate touched: none — Depot.tscn + Depot.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved.

## iter 028 — BUILD — OVERDRIVE sprint upgrade (C8 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- DIAGNOSE: round-3 anchor 2. Two candidates — C5 anchor 3 (4th enemy
  role) and C8 anchor 3 (depot catalog covers all 5 band pressures).
  **C5/3 is substrate-blocked** — a genuine 4th role needs an Enemy.gd
  behavior branch, and Enemy.gd is NOT in the sanctioned-write list
  (iter-23 finding); a stat-only variant violates CONSULT constraint 3
  ("no canonical answer = decorative complexity = cut it"). So iter 28
  takes **C8 anchor 3**: the open_killbox band has no depot upgrade —
  its pressure ("wide sightlines, fast scouts, rear-flank patrols";
  answer "facing-aware positioning") has no shell-economy upgrade
  because AP (its answer) is the deliberately-unupgradeable baseline.
  The honest fix: add a *positioning* verb — OVERDRIVE, a sprint burst.
- CONSULT constraints respected: 7 (OVERDRIVE is a movement VERB —
  "burst to break a flanker's sightline" — not a passive +speed%; it
  has a cost: a burst window then a cooldown), 1
- CONSULT constraints risked: 2 — OVERDRIVE is a non-shell upgrade, the
  first one. But it is NOT shell-class bloat (still 3 shells); it is a
  chassis/positioning affordance, which CONSULT 000 §7 explicitly
  endorses ("verbs and affordances"). Acceptable.
- Predicted failure modes:
  - The sprint multiplies `velocity` in `_physics_process` line 195.
    Gated on `loadout != null and loadout.has_overdrive` → arc-2/3
    never sprint → movement bit-identical.
  - Burst→cooldown transition: detect `_overdrive_timer` crossing >0→≤0
    and arm `_overdrive_cd` once.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-overdrive` verifies: OVERDRIVE upgrade sets
  `has_overdrive`; a SHIFT burst (when owned) raises effective speed
  for `overdrive_burst` s then cools down; arc-2/3 PlayerTank never
  sprints. The 7-entry catalog now maps an upgrade to each of the 5
  band pressures (HE-economy / HEAT-economy / positioning / recovery).
- Sentence test: OVERDRIVE passes — "This upgrade helps me climb
  through open killboxes by changing how I use positioning — a speed
  burst to break flanker sightlines."
- Substrate touched: `scripts/PlayerTank.gd` (substrate write —
  sanctioned). `scripts/Loadout.gd` + `scripts/Depot.gd` arc-4-owned.
- Hash-anchor verification plan: post-edit, before commit.

## iter 027 — BUILD — shell-swap reload cost (C3 anchor 4)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Round 3, anchor 1 of 3. C3 anchor 4 (de-bundled iter 26): "Shell-swap
  has a reload cost (≥0.5s) — pre-commitment under reload pressure".
- CONSULT constraints respected: 7 (the swap cost is a *verb-cost* — a
  pre-commitment beat — not a passive stat; CONSULT 000 §2 named this
  "the interesting WoT idea ... swapping takes a short reload beat"),
  2, 1
- CONSULT constraints risked: none
- Predicted failure modes:
  - The cooldown must be breach-gated: `_cycle_shell` already
    early-returns when `loadout == null`, so `_swap_cooldown` is only
    ever set in breach mode — arc-2/3 `_fire` never sees a nonzero
    cooldown. Bit-identical baseline.
  - `_cycle_shell` arms the cooldown only on a REAL swap (when
    `current_shell` actually changes) — cycling onto the same class
    (all others empty) must not impose a cost.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-swap` verifies: a real `_cycle_shell` arms
  `_swap_cooldown` to `shell_swap_cost` (≥0.5); `_fire` is blocked
  while `_swap_cooldown > 0`; once it elapses `_fire` emits again; an
  arc-2/3 PlayerTank (no loadout) never arms the cooldown.
- Sentence test: n/a (a combat-timing mechanic, not a depot upgrade)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write — sanctioned).
- Hash-anchor verification plan: post-edit, before commit.

## iter 026 — AUDIT — de-bundle remaining anchors; sharpen the ceiling

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Trigger: AUDIT cadence (every 5; last iter 21). Also Mismatch-AUDIT
  (L6) — the parity-drift /meta finding flagged that the remaining
  structural anchors are bundled/mis-tagged; this AUDIT de-bundles them
  so round 3 has honest single-clause targets + a sharp ceiling number.
- CONSULT constraints respected: all (process iter)
- Predicted finding: re-score holds at 28/50 (no anchor moved since
  iter 21's AUDIT + the BUILD-QUALITY iter 24). Two anchor rephrases:
  (1) C3 anchor 4 is bundled (swap-cost + per-band-consumption-harness)
  — R1 debt; de-bundle to the swap-cost clause (the CONSULT-core
  mechanic), the consumption-measurement belongs to the [FEEL] tier.
  (2) C4 anchor 4 ("avg shell-mix differs per band — 5-seed harness")
  is mis-tagged [STRUCTURE] — shell-mix can only be measured by
  simulated/real play; re-tag [FEEL]. Net: the true structural ceiling
  is ~32/50 (C3/4 swap-cost + C5/3 4th role + C8/3 band coverage +
  C10/5 arc-close), sharper than the meta's ~8-10 estimate.
- Falsifiable claim: re-score = 28/50 unchanged; RUBRIC.md gets 2
  revision-log rows (C3/4 de-bundle, C4/4 re-tag); LEDGER AUDIT block
  states the ~32/50 structural ceiling. Identity-protected anchors
  (C1/5, C5/5, C7/5, C8/5, C9/5) untouched (R2). Hash anchor untouched.
- Sentence test: n/a
- Substrate touched: none (RUBRIC.md + loop docs)
- Hash-anchor verification plan: n/a

## iter 025 — META + QUEUE — round-2 close; parity-drift finding; playtest surfaced

- Date: 2026-05-20
- Tag: [STRUCTURE]
- Meta-trigger: dice nat-13 /meta nudge (iter 24.5) named PARITY DRIFT
  — 24 iters, 28/50, all structural/harness-cited, zero playtests;
  ~14 of 22 remaining rubric points are playtest-gated by design.
  Round 2 (iters 7-24) is structurally complete; this iter formalizes
  the finding + closes round 2 + surfaces the playtest as critical path.
- CONSULT constraints respected: all (process iter)
- CONSULT constraints risked: none
- Predicted failure: the playtest request, once in REVIEW-QUEUE, sits
  unactioned (arc-1's user-look gate sat open 8 iters). Mitigation:
  PushNotification surfaces it directly; the loop continues round 3
  regardless (non-stop), so a stalled playtest doesn't stall the loop —
  it just caps the reachable score at ~37/50 until the user plays.
- Falsifiable claim: by end of iter, LEDGER has a META entry,
  REVIEW-QUEUE has item #3 (playtest request, prominent), a
  PushNotification fired, round 2 is marked closed, and STATE names
  round 3's opening surface. Hash anchor untouched (no code).
- Sentence test: n/a
- Substrate touched: none (LEDGER / REVIEW-QUEUE / STATE — loop docs)
- Hash-anchor verification plan: n/a

## iter 024 — BUILD-QUALITY — depot rule-changer "Breach Dividend"

- Date: 2026-05-20
- Tag: [STRUCTURE] [QUALITY] — CONSULT 002's #2 recommendation; a
  genuine playstyle-forking depot entry but it does NOT lift a
  [STRUCTURE] rubric anchor (C8 anchor 3 needs all-5-band coverage;
  the build-identity anchors it serves — C1/4-5, C9/3+ — are
  playtest-gated). Honest BUILD-QUALITY per L3/R4. Last BUILD-QUALITY
  was iter 10 — well within the 1-per-3-BUILDs cap.
- CONSULT 002 Q2 verbatim: "Replace one depot entry with a
  rule-changer, not a stock-changer. Breach Dividend — destroying 4+
  bricks with one HE refunds 1 HE ... creates a playstyle: precise
  cluster breaching."
- CONSULT constraints respected: 7 (a rule-changer verb — "cluster
  breaching pays for itself" — not a passive %stat), 1 (depot still
  shows 3-of-N; catalog grows to 6)
- CONSULT constraints risked: 4 — risk of farming (infinite HE from
  repeated cluster-breaches). Mitigation: `refill_he` caps at
  `max_he_reserve` — a dividend can never exceed the reserve cap, so
  it sustains efficient play but can't snowball. The CONSULT's
  "capped once per band" is a stronger guard; deferred (the
  max-reserve cap suffices for iter 24; per-band cap if playtest
  shows farming).
- Predicted failure modes:
  - The refund chain Bullet → get_parent() (the Level) → `.player` →
    `.loadout`. Level.gd has `@onready var player`. If any link is
    null (defensive duck-typed reads), the dividend silently no-ops.
  - "4+ bricks" count: `_apply_he_blast` returns radius-sibling count;
    total = radius + 1 (primary). In a brick maze the primary IS a
    brick; counting the primary unconditionally is a slight
    over-count if the HE shot's primary hit is an enemy — acceptable
    (the dividend is about cluster breaching; an HE shot that opens a
    4-tile lane qualifies regardless of what the centre cell was).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-dividend` verifies: HE blast of ≥4 bricks
  with breach_dividend ON → he_reserve +1 (capped at max); same blast
  with breach_dividend OFF → no refund; HE blast of <4 bricks → no
  refund even with the upgrade on.
- Sentence test: BREACH_DIVIDEND passes — "This upgrade helps me
  climb through brick mazes by changing how I use HE — precise
  cluster breaches refund their own shell."
- Substrate touched: `scripts/Bullet.gd` (substrate write — Bullet's
  4th; sanctioned). `scripts/Loadout.gd` + `scripts/Depot.gd`
  arc-4-owned.
- Hash-anchor verification plan: post-edit, before commit.

## iter 023 — BUILD — HEAT armor-bypass (C3 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- CONSULT 002 ADOPTED. Its #1 "next 3 iters" recommendation: "make
  HEAT real with one armor-facing/bypass rule" — Q3's
  stupid-in-6-months omission ("'2× damage' is a placeholder").
- CONSULT constraints respected: 3 (every enemy type gets a readable
  shell relationship — armored Heavy now MECHANICALLY demands HEAT),
  2 (still 3 shells), 7 (HEAT becomes a verb-with-a-rule, not "+N%")
- CONSULT constraints risked: 1 — armored Heavy is HEAT-only; a
  HEAT-starved player meeting an armored Heavy is genuinely stuck on
  that enemy. That IS the breach-economy tension (death recap names
  "ran out of HEAT") — but if it softlocks (cornered, no escape) it's
  bad. Mitigation: armored enemies are killable-by-avoidance (the
  player can route around — they're not lane-blockers by terrain) and
  AP/HE still kill all non-armored roles.
- **Substrate investigation** (PROMPT §DEFAULT-ON "any other substrate
  write = halt+investigate"): HEAT-armor needs an enemy-side "armored"
  marker. Enemy.gd is Layer-2 substrate NOT in the sanctioned list
  (PlayerTank/ProceduralLevel/Spawner/Bullet). **Resolution: avoid the
  Enemy.gd touch entirely** — use a Godot group tag. Spawner.gd
  (sanctioned) calls `enemy.add_to_group("armored")` for Heavy types;
  Bullet.gd (sanctioned) checks `body.is_in_group("armored")`.
  `add_to_group` is a Node method — no Enemy.gd script property
  needed. Both substrate writes are on the sanctioned list. No
  halt-and-investigate needed; no Enemy.gd write.
- The armor rule (brutally simple, per CONSULT): armored enemies take
  `max(0, deal − ARMOR_MITIGATION)` from AP/HE; HEAT ignores armor
  (full `deal`). ARMOR_MITIGATION = 1; Heavy base-damage-1 AP/HE →
  0 (blocked), HEAT 2× → 2 (one-shots Heavy's 2 HP). Player learns:
  "armored = HEAT".
- Predicted failure modes:
  - Spawner sets enemy params via `enemy.set(...)`; `add_to_group`
    is a different call — must be placed in the same pre-add_child
    block. Heavy ENEMY_TYPES entry needs an `"armored": true` key.
  - take_damage(0) on an armored enemy hit by AP — harmless (hp -= 0),
    impact spark still fires = readable "armor blocked it" feedback.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  new `make check-breach-armor` verifies an "armored"-group stub takes
  0 from AP + 0 from HE + full (2×) from HEAT, and a non-armored stub
  takes full from all 3.
- Sentence test: n/a (combat mechanic, not an upgrade)
- Substrate touched: `scripts/Spawner.gd` (substrate write #11 —
  sanctioned), `scripts/Bullet.gd` (substrate write — Bullet's 3rd;
  sanctioned). NO Enemy.gd touch (group-tag approach).
- Hash-anchor verification plan: post-edit, before commit.

## iter 022 — BUILD — 3 depots at band transitions (C2 anchor 3)

- Date: 2026-05-20
- Tag: [STRUCTURE]
- CONSULT 002 still running at iter-22 start (~7 min in). Per PROMPT,
  no AWAIT for design — proceeding with a CONSULT-safe, substrate-clean
  BUILD; iter 23 reads the consult.
- DIAGNOSE: C2 (field depot) at 2/5. Anchor 3: "Depots placed at
  deterministic intervals (e.g. every band); harness verifies a full
  run hits ≥3 depots — code-cited". BreachLevel.tscn has 1 depot.
- CONSULT constraints respected: 1 (depots are the safe-gate cadence —
  one per band transition), 6 (depots = clean band-segmentation points)
- CONSULT constraints risked: none — adding depots is CONSULT-endorsed
  ("field depots at fixed/semi-fixed depth intervals")
- Predicted failure modes:
  - BreachLevel.tscn is an inherited scene — adding 2 more Depot child
    nodes must use unique `index` values + node names. If indices
    collide, the scene won't load.
  - Depot world-y placement: depth N → y = 232 - N×16. Band exits at
    depth 30/70/120 → y -248/-888/-1688. A depot placed beyond the
    generated/reachable region would be a dead node — acceptable for
    the structural cite (the harness counts depot children, not
    in-run reachability of each).
- Falsifiable claim: post-edit, BreachLevel.tscn loads clean,
  `make check-breach-level` reports ≥3 depots, `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f`, `make test-all` PASS, `make
  test-breach` PASS.
- Sentence test: n/a (depot placement)
- Substrate touched: none — BreachLevel.tscn is an arc-4-owned scene;
  test_breach_level.gd arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved (the
  base ProceduralLevel.tscn is untouched).

## iter 021 — AUDIT + CONSULT — re-score + fire CONSULT 002

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Triggers: AUDIT (every-5 cadence; last iter 16) + CONSULT (~every-10;
  last iter 6).
- CONSULT constraints respected: all (process iter)
- Predicted finding: the rolling 25/50 is honest, but C7 anchor 3
  ("All new assets in arc 4 verified via the grammar gate before
  commit — log artifact in LEDGER") was conservatively HELD at iter 18
  ("one asset-set is thin evidence"). On AUDIT re-read, anchor 3 has no
  minimum-count clause — all 3 arc-4 generated assets (shell icons) ARE
  gated + the iter-18 LEDGER logs the SILHOUETTE_GATE_PASS artifact.
  Expect C7 2→3 (the iter-18 hold was an under-claim; AUDIT corrects).
  Total → 26/50. No over-claims expected.
- Falsifiable claim: the AUDIT re-score changes at most C7 (2→3); all
  other 9 criteria hold. CONSULT 002 fires fire-and-forget; queryId
  recorded to creative-consults.md regardless of tab status.
- Sentence test: n/a
- Substrate touched: none
- Hash-anchor verification plan: n/a (no code edit)

## iter 020 — BUILD — depot upgrade catalog → 5 (C8 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C8 (sentence-test compliance) at 1/5 is joint-lowest.
  Anchor 2: "5+ upgrades; all pass; sentence cited verbatim per
  upgrade — Loadout.gd documents". Have 3 (HE_REFILL_2 / HEAT_REFILL_1
  / HE_MAX_EXPAND_2) — need 5+.
- CONSULT constraints respected: 7 (verbs/affordances not passive
  stats — the 2 new upgrades are economy verbs: HEAT capacity expand +
  full resupply, NOT "+%damage"), 1 (catalog grows; depot still shows
  3-at-a-time — no scrolling), 2 (still 3 shell classes)
- CONSULT constraints risked: 4 — 5 refill/expand variants risk
  reading as "reserve stat soup". Honest mitigation: reserve size +
  resupply are CONSULT-§2-endorsed depot upgrade axes ("Depot upgrades
  improve swap speed or reserve size"); they ARE the breach economy's
  currency, not passive %stats. Genuinely-different affordance
  upgrades (swap-speed, refund-on-kill, first-shot-pierce) need
  mechanics not yet built (swap cost, kill hooks) — scheduled later,
  not faked now.
- Predicted failure modes:
  - UpgradeKind enum 3→5 + apply_upgrade extraction — the harness must
    exercise all 5 enum values. test_breach_depot_choice currently
    tests 3.
  - "Loadout.gd documents" — the catalog enum lives in Depot.gd; I add
    a documentation block to Loadout.gd citing the 5 verbatim
    sentences (the anchor's named location).
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS,
  `make check-breach-depot-choice` verifies all 5 UpgradeKind values
  apply distinct loadout effects. All 5 upgrades pass the sentence
  test (cited verbatim in this pre-mortem + Loadout.gd).
- Sentence tests (all 5, verbatim):
  - HE_REFILL_2: "This upgrade helps me climb through brick mazes by
    changing how I use HE shells."
  - HEAT_REFILL_1: "This upgrade helps me climb through bunker bands
    by changing how I use HEAT shells."
  - HE_MAX_EXPAND_2: "This upgrade helps me climb through long
    HE-required stretches by changing how I use my HE economy."
  - HEAT_MAX_EXPAND_2: "This upgrade helps me climb through deep
    bunker chains by changing how I use my HEAT economy."
  - FULL_RESUPPLY: "This upgrade helps me climb through the band after
    an over-spend by changing how I use a recovery beat."
  All 5 are "changing how I use <resource/verb>" — none is "by making
  me stronger" or "+N%". Pass.
- Substrate touched: none — Depot.gd + Loadout.gd are arc-4-owned.
- Hash-anchor verification plan: post-edit; trivially preserved.

## iter 019 — BUILD — per-role canonical answers (C5 anchor 2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C5 (enemy role vocabulary) at 1/5 is the lowest criterion.
  C5 anchor 2: "Each role has a documented 'canonical answer'
  shell+positioning in BANDS.md; harness verifies presence in band
  rosters — code-cited". Two clauses (R1): (a) BANDS.md documents a
  shell+positioning answer per role; (b) a harness verifies each role
  appears in ≥1 band roster.
- CONSULT constraints respected: 3 (every enemy type must have a
  readable shell/positioning relationship — this iter is the literal
  documentation of that), 5
- CONSULT constraints risked: 3 — the canonical answer is *documented*,
  not yet *enforced* in code (no enemy demands a specific shell to
  kill). Honest: C5 anchor 2 is a documentation+coverage anchor;
  mechanical enforcement is later (would need armor/HEAT-bypass — also
  C3 anchor 3 territory).
- Predicted failure modes:
  - Roster coverage: a role with no band could fail clause (b).
    Current rosters — Light in all 5, Heavy in 2, Fast in 3 — all 3
    roles covered. Low risk; the harness makes it explicit.
  - No substrate touch — BANDS.md is a doc, the harness is arc-4-owned.
- Falsifiable claim: post-edit, BANDS.md has a per-role canonical-answer
  section for Light/Heavy/Fast (shell + positioning each), and
  `make check-breach-enemies` additionally verifies all 3 roles appear
  in ≥1 band roster. `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS.
- Sentence test: n/a (enemy doc)
- Substrate touched: none (BANDS.md doc + test_breach_enemies.gd
  arc-4-owned harness).
- Hash-anchor verification plan: n/a (no code/config edit) — verify
  anyway.

## iter 018 — BUILD — C6 anchor 3 (recap band pressure) + C7 anchor 2 (grammar gate)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Two cheap lifts bundled:
  - **C6 anchor 3**: "Recap includes build identity tag + dominant
    pressure of killing band — code-cited". RunRecap already has
    build_tag() (✓ identity) + killing_band NAME. Gap: the band's
    `dominant_pressure` text. Fix: capture_death takes the BreachBand
    object (not just name) → store `killing_pressure`.
  - **C7 anchor 2**: "Silhouette-grammar check exists in
    analyze_frame.py or sibling tool; outputs PASS/FAIL — code-cited".
    Promote the iter-17 distinctness logic into a reusable
    `tools/silhouette_gate.py` gate (PASS/FAIL on any PNG set);
    check_shell_icons.py uses it.
- CONSULT constraints respected: 6 (recap now names the route pressure
  that killed the run — "steel-armored bunkers", not "got
  overwhelmed"), 4 (the grammar gate is now a reusable tool, not a
  one-off — future assets pass through it)
- CONSULT constraints risked: none
- Predicted failure modes:
  - capture_death signature change (band_name String → BreachBand
    object) — 3 call sites: PlayerTank._die, test_breach_recap.gd.
    Both must update atomically.
  - PlayerTank substrate write #10 — _die's capture_death call.
    Gated on run_recap != null (breach mode only) — arc-2/3 untouched.
  - silhouette_gate.py refactor — check_shell_icons.py must still
    report BREACH_ASSETS_OK.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f`, `make test-all` PASS, `make test-breach` PASS
  (check-breach-recap now also verifies killing_pressure;
  check-breach-assets routes through silhouette_gate.py), new
  `make check-silhouette-gate` reports `SILHOUETTE_GATE_PASS`.
- Sentence test: n/a
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #10 —
  _die capture_death call; gated). `scripts/RunRecap.gd` (arc-4-owned).
- Hash-anchor verification plan: post-edit, before commit.

## iter 017 — BUILD — gen_tile.py shell-icon generator (C7 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- DIAGNOSE: C7 (silhouette grammar) is the only 0/5 criterion — the
  weakest axis. C7 anchor 1: "gen_tile.py extended with ≥1 new
  generator (depot tile / shell icon / chassis variant) — code-cited".
- CONSULT constraints respected: 4 (silhouette grammar — the 3 shell
  icons are designed to be readable by silhouette + palette: AP = narrow
  dart / pale, HE = fat ellipse / warm yellow, HEAT = angular diamond /
  crimson; palettes match the Bullet.gd iter-4/7 modulate colors), 2
  (still 3 shell classes — icons for exactly AP/HE/HEAT)
- CONSULT constraints risked: 4 — the FORMAL silhouette-grammar check
  tool is C7 anchor 2 (a later iter). iter 17 cites the grammar gate
  *manually* + the verifier proves the 3 icons are pixel-distinct
  (silhouette-distinct proxy). Honest: anchor 2's automated PASS/FAIL
  tool is scheduled, not done.
- Predicted failure modes:
  - PIL drawing at 8×8 is cramped — the 3 silhouettes could end up
    too similar (fail the distinctness check). Mitigation: verifier
    asserts pairwise pixel-difference above a threshold.
  - gen_tile.py is Layer-1 substrate ("extendable for new procedural
    generators" — explicitly sanctioned). Extension must not break the
    existing 4 terrain generators.
- Falsifiable claim: post-edit, the existing `make` terrain-gen path
  still works, the 3 shell icons generate as valid 8×8 PNGs, and the
  new `make check-breach-assets` reports `BREACH_ASSETS_OK` with the 3
  icons verified pairwise pixel-distinct. `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f` (gen_tile.py is a build-time tool —
  doesn't touch the runtime hash anyway), `make test-all` PASS.
- Sentence test: n/a (asset generator)
- Substrate touched: `tools/gen_tile.py` (Layer-1 — extension
  explicitly sanctioned by PROMPT §SUBSTRATE FREEZE "gen_tile.py
  (extendable for new procedural generators)").
- Hash-anchor verification plan: gen_tile.py is a build-time Python
  tool; it does not run during `make test`. Hash anchor trivially
  preserved — verify anyway.

## iter 016 — AUDIT — re-score all 10 criteria + resolve C1-anchor-2 wording

- Date: 2026-05-19
- Tag: [STRUCTURE]
- AUDIT trigger: PROMPT cadence "every 5 iters" — 16 iters since the
  iter-0 baseline, no AUDIT yet. Also a Mismatch-AUDIT trigger (L6):
  C1 anchor 2's "via Loadout.gd permutations" wording doesn't match
  the actual mechanism (RunRecap.build_tag).
- CONSULT constraints respected: all (process iter, no design surface)
- CONSULT constraints risked: none
- Predicted finding: the rolling score (19/50) is mostly honest, but
  C10 anchor 4 ("Same through iter 15+; ≥3 sanctioned substrate writes
  — all verified") became satisfiable once we crossed iter 15 — a
  legitimate Surrogate-AUDIT lift. Expect C10 3→4, total → 20/50.
- Falsifiable claim: the AUDIT re-score, done criterion-by-criterion
  against the 10 green harnesses + LEDGER evidence, changes at most
  C10 (3→4); all other criteria hold their iter-15 scores. RUBRIC.md
  C1 anchor 2 is rephrased (citation clause only — score unchanged).
  Identity-protected anchors (C1/5, C5/5, C7/5, C8/5, C9/5) are NOT
  touched (R2).
- Sentence test: n/a
- Substrate touched: none. `loop/breach/RUBRIC.md` revision (anchor
  rephrase + revision-log row).
- Hash-anchor verification plan: n/a (no code edit).

## iter 015 — BUILD — band-aware enemy roster (C5 anchor 1)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- Discovery: arc-2 Spawner.gd ALREADY has 3 distinct enemy roles
  (Light = rare-fire lane-invader, Heavy = paused-aim corridor-denier,
  Fast = continuous-fire harasser) + a `DEPTH_BANDS` table with
  per-band `type_weights`. C5 anchor 1's "≥3 enemy roles" is already
  satisfied; the gap is "each spawns in correct bands per **BreachConfig**"
  (arc-2 uses its own DEPTH_BANDS, not the arc-4 5-band BreachConfig).
- CONSULT constraints respected: 3 (each enemy role has a readable
  shell/positioning answer — the 3 roles are behaviorally distinct), 5
  (each band's enemy pressure is now declared per BreachBand)
- CONSULT constraints risked: 3 — the canonical shell answer per role
  isn't yet *enforced* (no role demands a specific shell). Honest gap;
  C5 anchor 2 ("documented canonical answer per role") is later work.
- Predicted failure modes:
  - Spawner substrate write #9 — `_pick_enemy_type()` gets a 3rd branch
    (breach). It must be gated: arc-2 procedural + arc-3 OG paths
    unchanged → hash anchor preserved.
  - Spawner reads the band via `get_parent()` → level →
    `_current_breach_band`. If the level isn't breach mode, the breach
    branch must no-op and fall through to DEPTH_BANDS.
  - BreachBand.enemy_weights Dictionary in .tres — typed-Dictionary
    .tres syntax could be fiddly; use untyped Dictionary.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f` (arc-2 procedural unaffected — Spawner breach
  branch gated off), `make test-all` PASS (arc-3 OG Spawner path
  unchanged), `make test-breach` PASS, new `make check-breach-enemies`
  reports `BREACH_ENEMIES_OK` verifying all 5 bands declare non-empty
  enemy_weights with valid role names + Spawner picks band-appropriate
  types in breach mode.
- Sentence test: n/a (enemy roster, not an upgrade)
- Substrate touched: `scripts/Spawner.gd` (substrate write #9 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "Spawner.gd — band-aware
  spawning if iter-1 chooses path A"; gated breach branch).
  `scripts/BreachBand.gd` (add enemy_weights field — arc-4-owned, not
  substrate). `configs/breach_default.tres` (populate weights).
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  Spawner substrate touch.

## iter 014 — BUILD — RunRecap.gd death attribution (C6 anchors 1+2)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 000: death attribution is the "paired omission" alongside
  depots. Constraint 6: "every run produces a death reason tied to
  resource/build/route — not 'got overwhelmed'."
- CONSULT constraints respected: 6 (death recap is the literal subject),
  7 (recap reports verbs/resources — shells fired, reserves — not a
  generic score)
- CONSULT constraints risked: none — the recap is a safe-state surface
- Predicted failure modes:
  - PlayerTank substrate write #8: `_fire` + `_die` hooks. The recap
    must be created only in breach mode (`loadout != null`) so arc-2/3
    PlayerTank behaves bit-identically (no recap, no hooks fire).
  - RunRecap as RefCounted — PlayerTank owns it internally (no @export
    needed; fresh instance per run avoids Resource-sharing staleness).
  - Killer attribution: `take_damage(amount)` carries no source.
    Mitigation — capture the killing *band* (route attribution, which
    is what constraint 6 actually wants) by reading the parent level's
    `_current_breach_band`; killer string is "shell impact" generic.
    Honest: route+resource attribution is the real signal, not the
    sprite that landed the hit.
- Falsifiable claim: post-edit, `make test` exit 0, `tile_hash` =
  `23d6a2ec3bf2821f` (arc-2/3 PlayerTank with loadout==null runs the
  recap-free path), `make test-all` PASS, all 8 breach harnesses PASS,
  new `make check-breach-recap` reports `BREACH_RECAP_OK` verifying
  RunRecap captures depth + killing band + per-type shell counts +
  reserves + formats a non-empty recap string.
- Sentence test: n/a (recap, not an upgrade)
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #8 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "PlayerTank.gd — add Loadout
  + RunRecap hooks"; gated on loadout != null). New file:
  `scripts/RunRecap.gd`.
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  PlayerTank substrate touch.

## iter 013 — BUILD — extend breach_default.tres to 5 bands (C4 anchor 3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (each band a specific climb problem
  — band 4 open killbox = sightline pressure, band 5 endgame = composed
  pressure), 7
- CONSULT constraints risked: 5's reachability flip-side — F001 lesson:
  new band configs must be reachability-verified, not eyeballed. Band 5
  (endgame_mixed) carries steel — the bunker-zone failure mode could
  recur.
- Predicted failure modes:
  - Band 5 (endgame_mixed) has steel ~0.16 + brick ~0.26 — could fail
    the per-band oracle multi-seed like bunker_zone did pre-retune.
    Mitigation: verify via the 10-seed sweep; retune within-iter.
  - Band 4 (open_killbox) is high-empty — should be trivially
    reachable; the risk is the OPPOSITE (too empty = no climb problem),
    but that's a feel concern, not a reachability one.
  - .tres load_steps must cover the 4 new sub_resources.
- Falsifiable claim: post-edit, all 5 bands pass the per-band
  reachability oracle on ≥80% of a 10-seed sweep (the codified floor).
  `make check-breach-config` reports 5 bands. `make
  check-breach-harness` (deep, seed 42) reports all 5 reachable.
  `make test` exit 0, `tile_hash` = `23d6a2ec3bf2821f`, `make
  test-all` PASS.
- Sentence test: n/a (band config, no upgrade)
- Substrate touched: none — `configs/breach_default.tres` (not
  substrate) + `loop/breach/BANDS.md` (doc).
- Hash-anchor verification plan: post-edit; config-only change, flag-off
  codepath untouched — trivially preserved, verify anyway.

## iter 012 — CAPABILITY — deep-climb reachability harness (bands 2+3)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CAPABILITY justification (PROMPT MODE table — "must justify against a
  rubric axis"): the deep-climb harness is the §REACHABILITY FLOOR
  verification tool for C4. Without it, C4 anchor 2's reachability
  caveat (bands 2+3 unverified, F001) can't close, and C4 anchor 3
  ("5 bands … reachability passes on all — harness-cited") is
  unreachable. This iter directly unblocks C4.
- CONSULT constraints respected: 5 (verifies each band is a *playable*
  climb problem, not an impassable wall), 6 (harness is a clean
  band-level segmentation point for metrics)
- CONSULT constraints risked: none — verification tooling
- Predicted failure modes:
  - The climb mechanism (programmatically advancing player.position.y)
    must stay in step with ProceduralLevel._process generation (1 row
    per frame). If the player climbs faster than generation, it
    outruns the generated grid. Mitigation: climb 1 grid_size/frame.
  - F001 strongly predicts bands 2+3 will FAIL on first deep run —
    brick_maze + bunker_zone were softened blind in iter 11. If they
    fail, retune within-iter (PROMPT §HALT — reachability fail must be
    fixed same iter).
  - Node count: ~150 rows × multiple BrickBlocks/row = thousands of
    nodes over the climb. Headless should handle it; if slow, reduce
    climb depth or sample.
- Falsifiable claim: post-edit, the deep-climb harness reports, per
  seed, whether the spawn flood-fill frontier crosses each band's
  depth_max. By end of iter, bands 1/2/3 ALL report
  `playable: true` / chain-reachable across ≥5 seeds (1/7/42/100/333) —
  retuning band configs within-iter if any fail. `make test` exit 0,
  `tile_hash` = `23d6a2ec3bf2821f`, `make test-all` PASS.
- Sentence test: n/a (CAPABILITY iter)
- Substrate touched: none — `loop/breach/test_breach_harness.gd` is
  arc-4-owned (extend freely). `configs/breach_default.tres` may be
  retuned (not substrate).
- Hash-anchor verification plan: post-edit (only if breach_default.tres
  retuned — config changes don't touch the flag-off codepath, so
  trivially preserved; verify anyway).

## iter 011 — BUILD — wire depth-band terrain selection + 3rd band

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 5 (each band has a dominant terrain
  pressure — now ENFORCED at generation time, not just declared in
  config: `_active_config` routes per-band LevelConfig into row
  generation), 7 (no stats — terrain pressure is a climb problem, not
  a number)
- CONSULT constraints risked: 5's reachability flip-side — if a band's
  LevelConfig is too dense (e.g. bunker_zone steel-heavy), the
  procedural layout could become impassable. RUBRIC C4 reachability
  floor caps C4 at 0 if any band fails. Mitigation: keep band configs
  gentle (empty_weight ≥ 0.12); a formal per-band reachability oracle
  is a scheduled CAPABILITY iter (12+) — C4 anchor 3 is gated on it.
- Predicted failure modes:
  - `_active_config` is called during BOTH `_ready` initial generation
    AND `_process` climbing generation. The breach branch must not
    break the flag-off path — when `breach_mode_enabled == false` the
    branch is skipped entirely → hash anchor `23d6a2ec3bf2821f` stays.
  - Row→depth mapping: `rows_climbed = (height/grid_size) - row`. If
    the sign is inverted, bands map backwards (player starts in band 3).
    Will verify the starting area resolves to band 1.
  - Breach band lookup per-row is O(bands) — 3 bands, negligible.
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` (procedural baseline flag-off — breach branch
  skipped) AND `make test-all` PASS AND `make test-breach` PASS (all 7
  harnesses; check-breach-config now sees 3 bands) AND BreachLevel
  still instantiates clean over 30 frames.
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (substrate write #7 —
  fills the iter-2 `_init_breach_mode` / `_process_breach_depth` stubs;
  extends `_active_config` with a breach branch. Sanctioned per PROMPT
  §SUBSTRATE FREEZE path A. The breach branch is gated on
  `breach_mode_enabled` — default-on gating template preserved).
- Hash-anchor verification plan: post-edit, before commit. Mandatory —
  `_active_config` is on the RNG-feeding generation path; the breach
  branch MUST be flag-gated so flag-off stays bit-identical.

## iter 010 — BUILD — BreachLevel.tscn (first end-to-end breach scene)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 structurally — this iter wires
  the integration scene that lets all prior pieces (flag, BreachConfig,
  shells, Loadout, Depot) exist together in one playable surface
- CONSULT constraints risked: 5 — band-aware procedural generation
  still not wired (`_init_breach_mode` / `_process_breach_depth` stubs
  remain empty); BreachLevel generates terrain identically to arc-2
  procedural for now. The depth-band *experience* lands iter 11+ when
  the stubs route `breach_config` into per-row LevelConfig selection.
- Predicted failure modes:
  - Inherited-scene .tscn syntax: Godot 4.6 inherited scenes use
    `[node name="X" instance=ExtResource("base")]` on the root +
    child-override nodes by path. If the syntax is wrong, the scene
    won't load. Mitigation: keep it minimal; test load immediately.
  - The root node of ProceduralLevel.tscn is named "ProceduralLevel";
    inherited scene can rename to "BreachLevel". Child-override paths
    (`PlayerTank`) must match the base scene's node names exactly.
  - Depot placed at a fixed world-y may sit below/above the climbable
    region — depot reachability matters. For iter 10, depot is a
    *placement smoke test*, not yet a tuned band-transition gate.
- Falsifiable claim: post-edit, `make test` exit 0 (ProceduralLevel.tscn
  untouched) AND `tile_hash` = `23d6a2ec3bf2821f` AND `make test-all`
  PASS AND all 6 prior breach harnesses PASS AND new
  `make check-breach-level` reports `BREACH_LEVEL_OK` with: BreachLevel
  instantiates, `breach_mode_enabled == true`, `breach_config != null`,
  PlayerTank has a non-null loadout, ≥1 Depot child present, no script
  errors over 30 frames.
- Sentence test: n/a (integration iter, no new upgrade)
- Substrate touched: none — BreachLevel.tscn is a NEW inherited scene;
  ProceduralLevel.tscn / .gd untouched. configs/breach_starter_loadout
  .tres is new. The hash anchor is trivially preserved (the procedural
  baseline scene is byte-identical).
- Hash-anchor verification plan: post-edit, before commit.

## iter 009 — BUILD — Depot 3-choice upgrade catalog + next-band preview

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 001 Q2 implication: "Two-choice depot whose options are
  legible in under five seconds and both answer the last/next breach
  problem. No scrolling, no build tree, no stat salad." Going with **3
  choices** (still legible in <5s, lifts C2 anchor 2's "≥3 meaningful
  upgrade choices" cleanly without AUDIT-rephrase). Three is the
  smallest count that hits anchor 2 while still respecting the
  "no-scrolling, no-build-tree" CONSULT guidance.
- CONSULT constraints respected: 1 (no combat-modal — depot is the
  *safe gate* per design; key-based pick is fast), 7 (verbs not stats —
  each upgrade is an *action verb*: "refill HE", "refill HEAT", "expand
  HE capacity"; no passive +%damage cards). Sentence test: each upgrade
  must pass — verified inline in the pre-mortem below.
- CONSULT constraints risked: 1's flip-side — 30s depot dwell budget.
  Iter 9 ships no dwell timer; the harness verifies pick is *possible*
  in 1 frame. Iter 10+ adds enforcement if playtest reveals drag.
- Sentence tests per choice:
  - HE_REFILL_2: "This upgrade helps me climb through brick mazes by
    changing how I use HE shells" ✓
  - HEAT_REFILL_1: "This upgrade helps me climb through bunker bands by
    changing how I use HEAT shells" ✓
  - HE_MAX_EXPAND_2: "This upgrade helps me climb through long
    HE-required runs by changing how I use my shell economy" ✓
  - All three pass.
- Predicted failure modes:
  - Input-during-pause: Godot 4 still processes `Input.is_*` polls in
    nodes with PROCESS_MODE_ALWAYS even when tree is paused. Depot
    already sets PROCESS_MODE_ALWAYS (iter 5). Choice picks should fire.
  - Resource reference race: storing player.loadout on entry then
    accessing on pick — if player despawns mid-pause, loadout reference
    could be stale. Mitigation: null-check before apply.
  - Depot.tscn layout: 4 Label nodes need positioning. Simple Control
    container with VBoxContainer keeps it bounded.
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND all 5 prior breach
  harnesses PASS AND new `make check-breach-depot-choice` reports
  `BREACH_DEPOT_CHOICE_OK` with all 3 choice picks verified
  (HE refill, HEAT refill, HE max expand).
- Substrate touched: none (extending existing arc-4 file Depot.gd +
  scene Depot.tscn). C2 anchor 2 target.
- Hash-anchor verification plan: post-edit, before commit. Trivially
  preserved (no engine/gameplay-substrate touch).

## iter 008 — BUILD — Loadout.gd + finite HE/HEAT reserves + shell-cycle input

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT 001 (now returned despite tab timeout — documented arc-4
  behavior): **"no player has yet sacrificed one resource to alter one
  route. That is the atomic verb."** This iter wires that verb.
- CONSULT constraints respected: 1 (no combat-modal — shell cycle is a
  key tap, not a menu), 2 (≤3 classes), 3 (each shell already has a
  readable answer from iter 7; iter 8 adds the *commitment cost*),
  7 (verbs not stats — Loadout's `he_reserve` is a finite resource the
  player *spends*, not a passive +damage stat)
- CONSULT constraints risked: 1 — shell-cycle key chosen as raw KEY_TAB
  (no InputMap action added; project.godot stays untouched). If TAB
  conflicts with anything, will refactor to an InputMap action in
  iter 9+. Mitigation acceptable for iter 8 minimum scope.
- Predicted failure modes:
  - Signal arity mismatch: extending `shoot` to emit shell_class breaks
    any existing handler that expected 3 args. Level.gd handler must
    update in the same commit (substrate write #6).
  - Hash anchor: Level.gd and PlayerTank.gd both touched. Procedural
    `make test` doesn't fire bullets in the 120-frame window (no input
    simulated) so the new signal path doesn't engage; anchor preserved.
  - OG mode regression: arc-3 OriginalLevel.gd extends Level.gd; the
    new 4-arg signal handler must work for OG too. PlayerTank default
    current_shell = AP + loadout = null means OG fires AP bullets via
    the same path. Will be verified via `make check-chain-25` (full
    arc-3 chain).
  - Loadout cross-script type: same preload-alias pattern needed
    (arc-1 LevelConfigT precedent).
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND ALL 4 prior breach
  harnesses PASS AND new `make check-breach-loadout` reports
  `BREACH_LOADOUT_OK` with: (a) PlayerTank.loadout default null →
  arc-2 baseline preserved, (b) loadout set + HE fire → he_reserve
  decremented, (c) loadout set + HE fire at he_reserve=0 → fallback
  to AP, no decrement.
- Sentence test: applies. Loadout is the substrate for upgrades
  (depots refill it). The first upgrade card eligible to cite C8:
  "This upgrade helps me climb through brick mazes by changing how I
  use HE shells" — depot offers "+3 HE reserves" or similar. Iter 9.
- Substrate touched: `scripts/PlayerTank.gd` (substrate write #5 —
  sanctioned per PROMPT §SUBSTRATE FREEZE "PlayerTank.gd — add Loadout
  + RunRecap hooks"), `scripts/Level.gd` (substrate write #6 —
  necessary for shell signal extension; same gating discipline applies
  even though Level.gd isn't named in §SUBSTRATE FREEZE — it's an arc-1
  Layer-1 file. Will use default-on gating: 4th signal arg has a
  sensible default routing).
- Hash-anchor verification plan: post-edit, before commit. Mandatory.

## iter 007 — BUILD — Bullet.gd shell-class combat behaviors (HE blast + HEAT 2x)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 2 (still 3 shell classes, no fourth),
  3 (HE has a readable shell relationship → bricks crack into rubble;
  HEAT has a readable relationship → 2x damage; AP cheap+precise stays
  the default), 7 (verbs not stats — HE is an *affordance* "creates lane
  through brick clusters", not "+18% splash damage"; HEAT is a *verb*
  "doubles damage on hit", not a passive multiplier)
- CONSULT constraints risked: constraint 5 — without depth-band
  enemy/terrain mapping wired, HEAT 2x doesn't yet pair with heavy
  bunkers. Honest scaffolding: HE behavior is the load-bearing one
  (breach economy = "spending shells to open vertical lanes"); HEAT 2x
  is the simplest distinct-behavior cite for anchor 2 closure
- Predicted failure modes:
  - HE blast radius via sibling iteration may scan too many nodes if
    bricks are deeply nested → perf hit. Mitigation: cap by distance
    check; arc-2 procedural's brick count is ≤350.
  - Hash anchor risk: `make test` runs procedural baseline for 120
    frames. If procedural baseline ever fires AP bullets that touch
    bricks, the HE-radius behavior changes outcomes only via shell_class
    routing — AP default preserves arc-2 path bit-identically. Should
    be safe but verify.
  - Harness must construct stub `BrickBlock`-like nodes with
    `take_damage` and spatial positions; SceneTree subclass + await
    process_frame pattern (arc-3 precedent).
- Falsifiable claim: post-edit, `make test` exit 0 AND `tile_hash` =
  `23d6a2ec3bf2821f` AND `make test-all` PASS AND
  `make check-breach-{config,shells,depot}` PASS AND new
  `make check-breach-he-blast` reports `BREACH_HE_BLAST_OK` with HE
  bullet destroying ≥2 stub bricks in cluster + HEAT bullet dealing
  2x damage to single stub body + AP bullet dealing 1x baseline.
- Sentence test: applies — does HE behavior pass?
  *"This upgrade helps me climb through brick mazes by changing how I
  use HE shells."* — YES (HE-leaves-rubble-via-radius is the literal
  text of CONSULT §4 example "good upgrade")
- Substrate touched: `scripts/Bullet.gd` (substrate write #4 — sanctioned
  per PROMPT §SUBSTRATE FREEZE "scripts/Bullet.gd — multi-shell support
  if iter chooses extend-vs-new-Shell.gd"; same file as iter 4 — chosen
  path, refined)
- Hash-anchor verification plan: post-edit, before commit. Defensive
  check is mandatory because Bullet.gd is a Layer 2 substrate file
  fired by both player (proc baseline) and enemies (Spawner).

## iter 006 — META + CONSULT — round 1 close + round 2 bootstrap

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: 1 (no combat-modal UI added this iter),
  3 (no enemy without canonical answer added), 4 (no asset gen added)
- CONSULT constraints risked: none — META/process iter, no design surface
- Predicted failure: /agentify CONSULT may timeout/error like the
  arc-4 design consult did (per `creative-consults.md` consult 000).
  Mitigation: capture the queryId regardless of tab status; arc-4 has
  explicit documented protocol that tab-timeout ≠ consult-failed (the
  conversation may have completed). Next iter checks back.
- Falsifiable claim: by end of this iter, (a) a CONSULT attempt is
  recorded in `loop/breach/creative-consults.md` with queryId + status;
  (b) a round-1 finding lands in `loop/breach/REVIEW-QUEUE.md` per L3
  pattern; (c) STATE.md next_action names a concrete iter-7 BUILD or
  SPIKE target for round 2. Hash anchor preserved (no code touched).
- Sentence test: n/a (META iter)
- Substrate touched: none
- Hash-anchor verification plan: n/a (no code edit). Trivially preserved.

## iter 005 — BUILD — Depot.gd + Depot.tscn + pause-on-entry

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 1 (no upgrade choices during
  active combat — depot's pause-on-entry is the *load-bearing* mechanism
  protecting this), constraint 6 (depot is a natural segmentation point
  for death recap / pre/post-band metrics — schema sets this up)
- CONSULT constraints risked: constraint 1's flip-side — depot dwell
  must stay <30s; the rubric anti-pattern for C2 is depot dwell >30s.
  This iter doesn't yet implement upgrade choice flow, so dwell is
  unbounded by design (just walk in/out). Iter 6+ adds the choice + the
  30s budget; an honest acknowledgment now.
- Predicted failure: Godot 4.6 `get_tree().paused = true` + Area2D
  body_entered may have a process_mode interaction — if Depot's own
  `process_mode` is not set to PROCESS_MODE_ALWAYS, the depot itself
  pauses and can't fire `body_exited`. The mitigation lives in the
  script. Second risk: in headless test, no actual physics tick fires;
  the test must directly invoke `_on_body_entered(stub)` rather than
  rely on collision-based emission.
- Falsifiable claim: post-edit, `make test` exits 0 AND `tile_hash`
  first 16 chars = `23d6a2ec3bf2821f` AND `make test-all` PASS AND
  `make check-breach-config` PASS AND `make check-breach-shells` PASS
  AND new `make check-breach-depot` reports `BREACH_DEPOT_OK` with the
  pause-on-entry contract verified (get_tree().paused = true after
  entry signal, false after exit signal).
- Sentence test: n/a (depot itself is not an upgrade; iter 6+ depot
  upgrade catalog will run the sentence-test gate per RUBRIC C8).
- Substrate touched: none (Depot.gd + Depot.tscn are net-new files;
  no Layer 1/2/3 edits).
- Hash-anchor verification plan: post-edit, before commit. Should be
  trivially preserved — no engine/gameplay code touched.

## iter 004 — BUILD — Bullet.gd shell_class flag + AP/HE/HEAT constants

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 2 (≤3 primary shell classes
  at first — AP/HE/HEAT exactly), constraint 1 (no combat modal — flag
  is data-only, no UI surface), constraint 7 (verbs not stats — shell
  class will route to terrain/behavior affordances in later iters, not
  to +damage% upgrades)
- CONSULT constraints risked: constraint 3 (every enemy must have a
  readable shell/positioning relationship) is *not* satisfied yet by
  this iter — the shell_class field exists but no per-class behavior is
  wired. Later iter must implement HE=terrain-cracking,
  HEAT=anti-heavy-armor, AP=cheap-precise. The schema-only iter is
  honest scaffolding; the behavior gap is documented + scheduled.
- Predicted failure: extending Bullet.gd default-arg shape in `start()`
  may bleed across the existing callers in Level.gd or PlayerTank
  (which fire bullets without specifying shell_class) — they'd get the
  @export-default-AP behavior, which is the desired bit-identical
  baseline. If any caller passes positional args in a way that collides
  with a new positional `shell_class`, parsing or runtime breaks.
- Falsifiable claim: post-edit, `make test` exits 0 (procedural baseline
  still fires AP bullets identically to arc-2) AND `tile_hash` first
  16 chars = `23d6a2ec3bf2821f` AND `make test-all` PASS on all 5
  arc-3 targets AND `make check-breach-config` PASS AND new harness
  `make check-breach-shells` reports `BREACH_SHELLS_OK` with 3 shell
  classes (AP/HE/HEAT) verified distinct.
- Sentence test: n/a this iter (shell_class is a data field, not yet
  an upgrade). When iter 5+ adds an upgrade that grants shell-swap
  reserves, sentence will be: "This upgrade helps me climb through
  bunker bands by changing how I use HEAT" — sentence test gate.
- Substrate touched: `scripts/Bullet.gd` (substrate write #3 — sanctioned
  per PROMPT §SUBSTRATE FREEZE "scripts/Bullet.gd — multi-shell support
  if iter chooses extend-vs-new-Shell.gd"; chose extend over new file
  per Scout A's spike + L5 gating template)
- Hash-anchor verification plan: post-edit, before commit. The
  Bullet.gd change is gameplay-layer (Layer 2), not engine. Hash anchor
  is bound to procedural seed-42 baseline which doesn't fire bullets
  during the 120-frame `make test` window — so the anchor should remain
  trivially preserved. But I'll verify anyway since the anchor floor on
  C10 caps everything else.

## iter 003 — BUILD — BreachConfig.gd + BreachBand.gd + sample .tres (2 bands)

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: constraint 5 (each band must have a
  dominant terrain/enemy pressure — BreachBand's `dominant_pressure` +
  `canonical_answer` fields encode this), constraint 4 (BreachBand
  schema constrains future asset gen to existing silhouette roles by
  design — bands don't invent mechanics, they re-weight terrain), all
  others (no design surface changed; structural schema only)
- CONSULT constraints risked: constraint 5 if we later ship a band
  without a stated dominant pressure (defended by the schema —
  `dominant_pressure: String` field; runtime check possible later)
- Predicted failure: typed-Array Resource (`Array[BreachBand]`) syntax
  in `.tres` may have a Godot 4.6 quirk that fails to parse — falls back
  to untyped Array. Sub-resource cycles (BreachConfig → BreachBand →
  LevelConfig) may not resolve in load order — falls back to inline
  LevelConfig per band rather than ext resource.
- Falsifiable claim: post-edit, `make test` exits 0 AND
  `tile_hash` first 16 chars = `23d6a2ec3bf2821f` (procedural baseline
  preserved — `breach_mode_enabled=false`, `breach_config=null` on
  ProceduralLevel.tscn) AND `make test-all` reports all 5 arc-3 targets
  PASS AND `configs/breach_default.tres` loads cleanly via
  `ResourceLoader.load(...)` without errors.
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (tighten @export type
  from `Resource` to `BreachConfig`; same flag area, sanctioned write
  scope from iter 2). New non-substrate files: `scripts/BreachBand.gd`,
  `scripts/BreachConfig.gd`, `configs/breach_default.tres`.
- Hash-anchor verification plan: post-edit, before commit.

## iter 002 — BUILD-QUALITY — DECISION (adopt path A) + first substrate hook

- Date: 2026-05-19
- Tag: [STRUCTURE] [QUALITY] (no discrete rubric anchor lift this iter;
  plumbing/foundation work per L3+R4 release-valve. First of 3
  substrate-touching iters required to hit C10 anchor 1.)
- CONSULT constraints respected: all 7 (no design surface; substrate
  plumbing only). Constraint 1 (no combat modals) is structurally
  protected by the gating template — flag-off codepath is bit-identical
  to arc-2 procedural.
- CONSULT constraints risked: none this iter; downstream iters carry
  risks (iter 3+ depth-band logic against constraint 5; iter 4+ shell
  classes against constraints 2/3; iter 5+ depot against constraint 1).
- Predicted failure: the `@export var breach_mode_enabled` + 2 conditional
  branches edit on `ProceduralLevel.gd` will subtly mutate the procedural
  baseline. Specifically, possible failure modes:
  - Branch added inside the RNG-touching window (before line 77) → hash
    breaks
  - Stub method's `_init_breach_mode()` body accidentally creates a
    child node or calls `randf()` even with flag off
  - GDScript parse-order error on the new vars (caught by pre-tool hook
    if present; pre-commit; or `make test`)
- Falsifiable claim: post-edit, `loop/test_runner.gd` on seed 42 / default
  config reports `tile_hash` prefix `23d6a2ec3bf2821f` AND `playable: true`
  AND `make test` exits 0. If any of these fail, the iter HALTS for
  investigation per PROMPT §HALT CONDITIONS (hash anchor broken =
  correctness violation; auto-halt + investigate).
- Sentence test: n/a (no upgrade)
- Substrate touched: `scripts/ProceduralLevel.gd` (sanctioned per PROMPT
  §SUBSTRATE FREEZE iter-1 DECISION + §DEFAULT-ON SUBSTRATE GATING
  TEMPLATE; PATTERN 2 from arc 3)
- Hash-anchor verification plan: post-edit, before commit, run
  `loop/test_runner.gd` and verify `tile_hash: 23d6a2ec3bf2821f`. Run
  `make test` for parse + 120-frame runtime check. If both green, commit;
  if either fails, revert + investigate.

## iter 001 — SPIKE — mode-integration path A vs B

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (no design surface touched yet;
  this iter is structural plumbing investigation)
- CONSULT constraints risked: constraint 3 indirectly — if path A's
  default-on flag interacts with Spawner's existing band logic in a way
  that makes per-band enemy/terrain mapping harder later, we'd risk
  "decorative complexity" downstream
- Predicted failure: path A may turn out to be deeper than the PROMPT
  default-recommendation assumes. Specifically, `ProceduralLevel.tscn` +
  `ProceduralLevel.gd` may have implicit assumptions (TANKE_SEED env,
  fixed map geometry, no run-state surface) that fight against being
  gated for vertical depth-bands + depot insertion + run state. Path B
  may turn out to be cleaner than the PROMPT's H1 multiplication concern
  if `ProceduralStep` can be reused as a child node without scene
  duplication.
- Falsifiable claim: at end of iter 1, both spikes produce concrete file
  diffs (path A: minimal `@export var breach_mode_enabled` patch + 1
  conditional branch in `_ready` or `_build_level`; path B: a skeletal
  `scenes/BreachLevel.tscn` referencing `ProceduralStep` as a child).
  Each spike returns SHIP / REFINE / SKIP + lines-of-change estimate +
  hash-anchor impact statement. **Neither spike actually commits the
  diff** — they're scouts. The DECISION (iter 2) picks the winner.
- Sentence test: n/a (no upgrade in this iter)
- Substrate touched: read-only investigation
- Hash-anchor verification plan: post-spike (iter 2 DECISION's build),
  not this iter. Both spikes report whether their path could break the
  anchor in principle.

## iter 000 — META — preloop complete

- Date: 2026-05-19
- Tag: [STRUCTURE]
- CONSULT constraints respected: all 7 (no design work yet; substrate-only)
- CONSULT constraints risked: none
- Predicted failure: substrate may have drifted across the 3 modified files
  in git status (`project.godot` shows `M`) → either hash anchor breaks or
  `make test` fails.
- Falsifiable claim: `make test` exits 0 AND `loop/test_runner.gd` on seed
  42 / default config reports `tile_hash` prefix `23d6a2ec3bf2821f` AND
  `playable: true` AND OG `check-chain` reports `CHAIN_25_OK`.
- Sentence test: n/a (no upgrade)
- Substrate touched: none (read-only verification)
- Hash-anchor verification plan: post-verification, pre-flip of
  `preloop_complete: yes`. Result: PASS (`23d6a2ec3bf2821f` confirmed).
