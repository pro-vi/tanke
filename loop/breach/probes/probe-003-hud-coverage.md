# Probe 003 — HUD coverage math + label-size audit

**Iter shipped:** 309
**Round:** 25 (probe sprint — third + final probe per blueprint)
**Harness:** `loop/breach/test_breach_hud_coverage.gd` (run via `make check-breach-hud-coverage`)
**Raw output:** `tools/out/hud_coverage.json`

---

## Question

The PROMPT names a load-bearing structural constraint — *"HUD area ≤ 25% of viewport per blueprint"* — and the iter-299 typography pass mandated 8pt as the compact-HUD floor. **No harness has enforced either constraint.** Iter 300's WoT-tray relocation + iter 298's z-index audit + iter 299's typography pass were verified by screenshot only. A regression that introduces a giant overlay panel or a default-16pt label would slip through.

Probe 3 measures both constraints + reports quadrant occupancy + writes the data to `tools/out/hud_coverage.json` for future iters to diff against.

---

## Method

1. Instantiate `PlayerTank` with a `Loadout` (so the breach HUD layer builds).
2. Dismiss the run-start `ShellCodex` (264×206 ≈ 71% of viewport — only visible at run-start, not steady-state).
3. Recursively enumerate ALL `CanvasItem` descendants of the HUD `CanvasLayer`.
4. Filter to visually-present nodes (visible + parent-visible + modulate.a ≥ 0.1).
5. Sum `ColorRect` areas (skip Labels for the coverage metric — they paint on top of backing ColorRects, so counting both would double-count painted pixels).
6. Walk all visible `Label`s; check `theme font_size override`; assert ≥ 8pt floor.
7. Quadrant breakdown by center-of-ColorRect (TL/TR/BL/BR with split at viewport center 160, 120).

---

## Results (steady-state HUD, default loadout, post-codex-dismiss)

| Metric | Value | Budget |
|---|---|---|
| **HUD ColorRect area** | 5,424 px² | (none stated) |
| **Viewport area** | 76,800 px² (320 × 240) | — |
| **HUD coverage fraction** | **7.1%** | ≤ 25% |
| **Headroom remaining** | 17.9% (~13,700 px²) | — |
| **Visible CanvasItems** | 21 | — |
| **Hidden CanvasItems** | 45 | — |
| **Visible labels** | 10 | — |
| **Labels at 8pt** | 10 (100%) | All visible labels ≥ 8pt |
| **Labels at Godot default 16pt** | 0 | (would be the iter-299 regression) |

### Quadrant breakdown

| Quadrant | ColorRect coverage | Notes |
|---|---|---|
| TL (top-left) | 1.2% | HP bar + reload bar + XP bar |
| TR (top-right) | 0.0% | DEPTH/TIME/BEST/SPD labels only — no ColorRects |
| BL (bottom-left) | 1.3% | active-cards ribbon at default 0 chips visible |
| BR (bottom-right) | **4.5%** | shell tray at (93, 215, 136×18) — center x=161 just clears the 160 split → counted as BR |

The bottom-right number is artificially weighted because the bottom-center WoT tray sits at center x=161 (just past the 160 quadrant boundary). True center-of-mass is **bottom-center** of the viewport, as iter 300 designed it. The 4.5% BR number understates how visually balanced the placement actually is.

---

## Findings

### F1 — Steady-state HUD uses 7.1% of viewport (well within 25% budget)

The "≤25%" PROMPT constraint has been BACKED by structural data for the first time. The HUD currently uses 7.1% — about a quarter of the budget. iter 298's z-index audit + iter 299's typography pass + iter 300's WoT relocation collectively produced an honest, compact HUD that has substantial room for the queued visual-identity work (Round 25 candidate at REVIEW-QUEUE #27) without breaching the structural cap.

**Headroom:** **17.9%** = ~13,700 px² unused budget. For reference: the iter-300 WoT shell tray + chips ColorRects total 4,496 px² (5.85% of viewport). The HUD has room for another 3× of similar weight before hitting cap.

### F2 — All 10 visible labels are at 8pt — no Godot-16pt regression

The iter-299 typography fix is structurally LOCKED. Every visible Label has an explicit `font_size` override at 8pt. Zero labels are at Godot's default 16pt. The harness will catch a regression on the next added label.

Note: hidden modal labels (death panel, levelup choices, archetype-select choices) carry their own font sizes (12-13pt for modal titles, 9-10pt for choice text) — these are excluded from the floor assertion because they're only visible during their respective modal states, not in steady combat play.

### F3 — Visual weight is bottom-heavy; top-right has labels but zero ColorRect mass

The iter-300 WoT-tray relocation put the visual weight of shell info at bottom-center (4.5% of viewport). The top-right is text-only (DEPTH/TIME/BEST/SPD = 0% ColorRect mass) because those readouts are pure 8pt labels — no backing panels. This is a CLEAN structural pattern: stats are textual; affordances (HP, reload, shells, XP) get visual mass.

**Design implication:** if Round 25 visual identity adds sprite-based icons or particle effects, the natural slot is the TOP-RIGHT 0% area (currently labels-only). Adding ~3000-5000 px² of visual mass there would balance the bottom-heavy current state.

### F4 — 45 hidden vs 21 visible CanvasItems

Two-thirds of the HUD's CanvasItems are HIDDEN at default state (death overlay, levelup panel, archetype-select, codex, route panel with empty cells, active-card chips with empty slots, etc.). The HUD has substantial LAZY ARCHITECTURE — most build-time elements are conditional on game state.

**This is a strength.** The 7.1% steady-state number represents the actually-onscreen HUD, not the worst-case-modal-open coverage. A future probe (Round 26 candidate?) could measure worst-case modal coverage to ensure no MODAL state breaks the 25% rule either — though modals are by-definition focal/intentional so a higher cap may apply.

### F5 — Probe 3 closes the Round 25 blueprint at 3 of 3 probes

Per the iter-306 blueprint, Round 25 caps at 3 probes OR 12 iters (whichever first). Probes 1 (Q1 bot run) + 2 (shell × target matrix) + 3 (HUD coverage) ship the planned 3-probe set in 3 active-build iters (307, 308, 309). Round 25 is at natural closure on this scope.

---

## What this probe CAN'T tell us (non-consultable)

- Whether the HUD FEELS uncluttered to a real player (the 7.1% number doesn't capture visual heaviness — texture density, animation, contrast all matter)
- Whether the BL/BR placement is the right design choice (Stardew/牧場物語 reference comparison still pending)
- Whether 8pt is actually legible on the target display sizes (depends on monitor scaling)
- Whether the modal-open states (death overlay, archetype-select, levelup, codex) feel "earned" or "abrupt" (modal-coverage probe would be a separate axis)

These are still real-playtest-gated. Probe 3 produces structural floor evidence; FEEL is non-consultable.

---

## Substrate impact

- Files added: `loop/breach/test_breach_hud_coverage.gd`, `loop/breach/probes/probe-003-hud-coverage.md`
- Files modified: `Makefile` (added `check-breach-hud-coverage` target + added to test-breach aggregate)
- Layer 1/2/3 substrate writes: **0**
- substrate_writes_this_arc unchanged at 92.
- Hash anchor `23d6a2ec3bf2821f` preserved.
- test-breach: 88 → 89 OK markers (+1 for hud-coverage harness).
- test-all: 5/5 unchanged.

---

## Round 25 closure — cumulative

| Probe | Iter | Output | Key finding |
|---|---|---|---|
| 1 — Q1 bot baseline | 307 | 4 JSON tables + 5 findings + e2e harness | dominant_per_lane is the only policy with routes 1/1/1/1; HE radius destroys 5× in cluster |
| 2 — Shell × target matrix | 308 | 4×4 matrix + 6 findings + fingerprint harness | AP=HE per-cell; AP×Heavy = 10 routes / 0 damage (ledger conflation); APCR universal |
| 3 — HUD coverage | 309 | Coverage 7.1% + label-size locked + JSON | HUD has 17.9% headroom for Round 26 visual identity; iter-299 8pt floor locked |

Substrate writes through Round 25: **0** (budget was 5; untouched). All 3 probes were tooling + harness + report. Hash anchor preserved through all 3 probes. test-breach grew 86 → 89 OK markers (+3).

The structural calibration data the loop COULD produce without real playtest is now captured. consult-001 expires at iter 309 per the original blueprint buffer — without user prediction scoring, the calibration count stays at `{hits:0, partial:0, misses:0, untested:0}` and `feel_consult_cap` stays at uncalibrated 3.

iter 310 candidates: (a) META iter closing Round 25 + consolidating Probes 1+2+3 into a single REVIEW-QUEUE entry (anti-accretion check: REVIEW-QUEUE has open items #14 + #15; closing one of those simultaneously satisfies the iter-305 WATCH-FOR); (b) Bootstrap next surface from PROMPT § work-valid-without-playtest list; (c) Halt voluntarily if probes saturate the structural ceiling.

The user's iter-270 trigger ("Stardew delta") remains gated on FEEL playtest evidence. Probes 1+2+3 give the structural floor. The loop has done what it can without the user.
