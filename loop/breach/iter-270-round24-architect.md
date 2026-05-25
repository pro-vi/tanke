# Round 24 architect — Stardew delta: HUD legibility + scaling curve + enemy-HP recurve

**Opened:** iter 270 (2026-05-24)
**Trigger:** user message — "i want more distinction from raw BC.. start feel more modern.. Stardew Valley delta against 牧场物語."
**Closes saturation pattern:** iter 200-269 status-check idle pivots back to active build.

---

## Brief

The user named the gap: systems shipped but the player can't SEE them. Ammo invisible (reads as one bullet), reload invisible (reads as random RoF), speed invisible (upgrades feel imaginary), cards implicit. Coupled with flat scaling — depth 50+ plays like depth 5.

The 4 archetypes shipped structurally but feel raw. The 14-card upgrade catalog applies but doesn't visibly compound. The breach economy works in code but doesn't read on screen.

## North star

**Same BC primitives, modern HUD + progression feel.** Not breaking the grammar, lifting the surface presentation + progression onto modern-roguelite expectations. Stardew::牧场物語 in our terms.

Sentence test (preserved from arc-4 CONSULT): every new HUD element must answer "what is blocking my climb / what tool answers it / what will it cost me?" within one glance.

Test it lands: a stranger watching the screen should be able to name the current shell + reload state + active build within 3 seconds. At depth 50 with full upgrades, the player should feel measurably stronger than at depth 5 — kill-time and traversal feel different.

---

## 3 phases (sequenced — A ships before B starts; B ships before C)

### Phase A — HUD-as-status (legibility)

Render every existing system to the player without them taking action.

**Asset pipeline (iter-271 amendment):** /agentify image_gen is the FIRST CHOICE for HUD widget icons — it's a confirmed standing capability (Round 9 archetype concept sprites + Pro Consult 011 motif-first masks both shipped end-to-end). Use the same loop: prompt → image → palette extraction → 16×16 / 8×8 silhouette compliance → atlas pack. Procedural PIL (`tools/gen_tile.py`, `tools/gen_archetype_sprites.py`) remains the same-iter fallback if /agentify is unavailable. Hand-coded solid-color stubs only if BOTH paths fail.

**Deliverables (5 widgets):**

1. **Shell chips (WoT-style)** — chip row showing AP / HE / HEAT / APCR icons + reserve counts; currently-selected highlighted. Icons via /agentify (4 small shell-type sprites referencing the existing palette). Replaces the existing shell HUD with a more legible row layout. Position: top-left, under HP.
2. **Reload bar** — linear bar OR radial arc; fills 0→100% as cooldown progresses; color matches current shell. Position: under tank sprite (so player's eye stays on combat). Likely procedural (no asset gen needed — it's a colored rect).
3. **Speed meter** — small numeric badge or bar showing current speed normalized to baseline (1.0× / 1.2× / 1.5× tier marks). Reflects current Loadout speed boosts. Position: top-right HUD corner. Likely procedural.
4. **Active cards ribbon** — current upgrade cards as small chips with 1-word labels + icon. Updates as cards stack. Position: bottom-left, above route strip. Icons via /agentify (14 small card-art sprites, one per UpgradeKind — re-uses Round-9 archetype palette).
5. **Kill-flash** — when an enemy dies, briefly show the shell icon at hit point (~0.5s). Reinforces "which shell did this." Re-uses the shell chip icons from widget 1.

**Folded scope:** Round 23's `pick_card_on_levelup` flag (REVIEW-QUEUE #14) flips to default `true` as part of this phase — cards are now visibly part of the loop and the pick UI is part of the HUD legibility story.

**Acceptance:**
- All 5 widgets render in breach mode without player action
- Stranger-on-screen test: name shell + reload + build within 3 seconds (recorded as a playtest note for #14)
- Total HUD area ≤ 25% of viewport
- All widgets BC pixel-art compliant (no anti-aliasing, palette-aligned to existing tanks)
- `make test-breach` adds `check-breach-hud` harness asserting all 5 widgets exist + are positioned correctly
- Hash anchor `23d6a2ec…` preserved (breach-mode-gated HUD additions only)

**Anti-patterns:**
- Modal dialogs (CONSULT constraint 1 stands)
- HUD elements that require reading during combat (arc-2 F013 lesson)
- Adding HUD to procedural baseline (must be breach-mode-gated CanvasLayer)
- HUD widgets that don't reflect a system the player can actually affect

**Expected iters:** 5-8.

---

### Phase B — Scaling audit + tier breakthroughs

Audit existing UpgradeCatalog.gd cards. Most are likely linear (% boosts). Convert ≥3 cards per archetype to tier-breakthroughs so cumulative cards visibly compound, not creep.

**Deliverables:**

1. **Card audit** — classify all 14 cards by class:
   - Linear-bonus (+10% damage / +15% reload)
   - Tier-breakthrough (AP becomes pierce-2 at level 3; reload halves once SWAP×3 owned)
   - Qualitative-change (mortar charge gets quick-detonate; ram sprint becomes dash)
2. **Convert ≥3 per archetype** from linear to tier-breakthrough. Examples:
   - `RELOAD +5%` (DEFAULT) → `at SWAP×3 owned, shell-swap is instant`
   - `BEAM_DPS +15%` (PRISM) → `at BEAM_DPS×3, beam pierces armor`
   - `AOE_RADIUS +1` (MORTAR) → `at AOE_RADIUS×3, blast leaves rubble ramp`
   - `COLLISION +10%` (RAM) → `at COLLISION×3, sprint-impact stuns 1s`
3. **HUD shows next breakthrough threshold** in active-cards ribbon (e.g. "BEAM_DPS 2/3 → pierce")
4. **Damage curve recorded** in this blueprint after audit (per-archetype power table)

**Acceptance:**
- Sim harness: unupgraded vs fully-upgraded at depth 50 shows ≥2× kill-time ratio
- Each archetype has ≥1 tier-breakthrough card that changes mechanic, not stat
- HUD next-threshold cue tested in `check-breach-hud`
- Hash anchor preserved
- No card breaks the breach economy (HE still scarce; APCR still finite)

**Anti-patterns:**
- Power-creep cards that destroy the breach decision (CONSULT §4)
- Cards that make all bands soluble by one strategy (CONSULT constraint 5)
- Stat soup expansion — every new card must pass the sentence test ("This upgrade helps me climb through ___ by changing how I use ___")

**Expected iters:** 4-6.

---

### Phase C — Enemy-HP recurve

Currently enemy HP is likely fixed per role. Recurve so kill-time at depth K with full upgrades feels MEANINGFULLY DIFFERENT from depth K without, AND so a depth-50 experienced player outpowers a depth-5 fresh player.

**Deliverables:**

1. **Audit Enemy.gd HP** per role (LIGHT / MEDIUM / HEAVY / SCOUT / MORTAR)
2. **Recurve formula** — enemy HP scales with depth, but slower than player damage curve from upgrades. Result: deep-runs feel like wading through stronger mobs WITH a stronger tank, not a treadmill.
3. **Visible HP delta** — if enemy HP scales meaningfully across bands, enemy HP bars should show it (a depth-1 LIGHT and depth-50 LIGHT visibly differ in HP bar segments)
4. **Harness** — kill-time-per-depth × upgrade-stack grid; assert curve has player-advantage zone (full-upgrade depth-50 player faster than no-upgrade depth-5)

**Target curve (tunable):**
- Depth-5 fresh: avg kill-time 2.0s per enemy
- Depth-50 no-upgrade: avg kill-time 3.5s (treadmill if unupgraded — pressure builds)
- Depth-50 full-upgrade: avg kill-time 1.5s (player outpaces — progression FELT)

**Acceptance:**
- Sim harness asserts the 3 target zones
- Hash anchor preserved (Enemy.gd HP scaling is loadout-gated when added to breach mode; arc-2/3 enemies unaffected)
- No band becomes trivial (CONSULT constraint 5 — every band keeps its pressure)
- `make test-all` green (arc-3 OG mode enemies unaffected)

**Anti-patterns:**
- HP scaling that out-runs damage curve (depth treadmill)
- HP scaling that makes lower bands trivially easy (loses pressure)
- Enemies that scale faster than the player's tier-breakthrough cards (depth-50 with full build still slow = scaling lies)

**Expected iters:** 3-5.

---

## Cron + cadence

Active-build cadence: **240s** (per session-learnings L16). Round 24 is active build across all 3 phases.

After all 3 phases ship: REVIEW-QUEUE entry summarizing the Stardew delta as shipped → loop bootstraps next round (DIAGNOSE next surface) OR awaits playtest signal on #14 if user has already signaled intent.

Saturation-watch: if a phase's BUILD iters stall (≥2 empty DIAGNOSE in a row, no rubric movement, no shippable advancement) within a phase → write a candid blocker note to STATE + REVIEW-QUEUE, escalate via PushNotification, then pivot to next phase OR pause for user direction. Do not run 70 idle status-checks (the iter-200-268 anti-pattern).

---

## Substrate + hash anchor discipline

Layer-2 freeze (PlayerTank.gd, Spawner.gd, Enemy.gd, Bullet.gd, BrickBlock.gd) continues. All Round-24 writes are:
- Breach-mode-gated (CanvasLayer additions under `breach_mode_enabled` branch)
- Loadout-gated (HUD widgets only render when `loadout != null`)
- Archetype-aware (shell chips hide non-applicable types per the iter-190 pattern)
- Hash anchor `23d6a2ec3bf2821f…` verified post-each-substrate-write

Enemy.gd HUD writes (HP bars from iter 62) + /agentify image_gen (for any HUD icons not procedurally generatable) remain sanctioned per Round-9 amendment.

---

## Done criteria for round 24

- All 3 phases shipped, each meets its acceptance
- `make test-all` + `make test-breach` green
- Hash anchor preserved
- REVIEW-QUEUE entry appended summarizing what shipped
- User invited to playtest (closes #14) OR loop bootstraps next round if user not signaling

---

## Phase ordering — why A → B → C

- **A first** — HUD-only changes prove the systems EXIST to the player. Cheap. No mechanical changes. Phase B's tier-breakthroughs are useless if the player can't see they're stacking.
- **B second** — once HUD is in, you can actually see whether cards compound. Tier-breakthroughs without HUD = invisible upgrades (arc-2 F013 redux).
- **C third** — enemy HP recurve is the last lever. Without B, recurving HP just makes things harder. Without A, the player can't see they have the tools to keep up. C makes the curve LAND.

Doing A only = visible-but-impotent. Doing B only = invisible-but-real. Doing C only = harder game, not richer game. All three = the Stardew delta.
