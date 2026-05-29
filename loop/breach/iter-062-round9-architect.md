# Round 9 blueprint — Tank archetype program

Written iter 062. Compaction-safe per L2 — each Round-9 iter reads this.

## Origin

The user playtested Round 8 (2026-05-22). Verdict: positive — the
roguelite overhaul (XP/levels + per-phase picks + ammo drops + longer
shields) reached "an interesting spot" — but the underlying primitive
("tank that shoots discrete bullets") is the bottleneck. Direction:
introduce TANK ARCHETYPES with distinct personalities (Red Alert /
Into the Breach references).

User-named worked example: **Prism Tank** — stop-and-fire continuous
beam; burns brick; damages a line of enemies but stops at the first
hit (so multi-enemy positioning becomes the interactive moment, with
enemies shooting back during the exposed fire); upgrade reflects the
beam → AoE-ish. Prerequisite primitive: enemy HP > 1 with visible HP
bars (so beam combat / damage-numbers actually matter).

Via AskUserQuestion the user chose the **"Full archetype program"**
scope — 4 archetypes (Default + 3 new) + BOTH selection paths
(start-pick AND event-unlock mid-run switching) + visuals via
/agentify, before the next playtest.

## The overrides — what this round changes

Two PROMPT rules are sanctioned-overridden by the user for Round 9
(recorded in STATE §Arc-4 amendments):

- **MLX-SD/image-gen NO-GO** (PROMPT §Anti-patterns) is relaxed: asset
  visuals are generated via /agentify image_gen
  (`mcp__agentify-desktop__agentify_image_gen`). The PROMPT's intent
  was avoiding the arc-1 MLX-phantom-dependency trap; /agentify is a
  different MCP channel under the user's control. User-sanctioned.
- **Enemy.gd as unsanctioned Layer-2 substrate** is relaxed for the
  Round-9 HP-bar HUD overlay (the HP-as-primitive directive). Hash
  anchor is HUD-only — no effect on tile generation; bit-identical.
  User-sanctioned.

The breach economy (Rounds 1-8) STAYS. Round 8's progression
(XP/levels, per-phase picks, ammo drops, longer shields) STAYS, applied
universally to ALL archetypes. Round 9 adds archetype-differentiated
gameplay ON TOP — not a replacement.

## The 4 archetypes

| Archetype  | Combat loop                                       | Personality                          |
|------------|---------------------------------------------------|--------------------------------------|
| **DEFAULT**| Discrete bullets (AP/HE/HEAT/APCR), move + shoot  | Versatile, the breach economy itself |
| **PRISM**  | Stop-and-fire continuous beam, line damage        | High DPS, exposed, positioning-tight |
| **MORTAR** | Lobbed parabolic shells, AoE on impact, no LoS    | Indirect fire, terrain-bypass        |
| **RAM**    | Collision damage + short-range AoE swing + sprint | Movement-as-weapon                   |

Each must be MECHANICALLY DISTINCT (Into-the-Breach standard), not
just numerically. If a new archetype reduces to "default with a stat
tweak," cut it.

## Sub-round sequence

- **9a — Enemy HP primitive + HP bars.** Tune Enemy.max_hp > 1 per
  role (Heavy 3-4, Light 1-2, Fast 2). Add a small HP-bar HUD above
  damaged enemies — visible while hp < max_hp; despawns ~1s after no
  damage (or always-while-damaged — 9a decision). Bullet.damage stays
  as-is — HE / HEAT×2 / APCR penetrate / AP single now MATTER beyond
  single-hit. Substrate: Enemy.gd (HP-bar HUD — sanctioned per the
  Round-9 amendment; HUD-only, hash bit-identical).

- **9b — Archetype framework.** A TankArchetype enum on PlayerTank
  (DEFAULT / PRISM / MORTAR / RAM). PlayerTank.gd gates behavior on
  `archetype`. `archetype = DEFAULT` preserves the current behavior
  bit-identically (the breach economy as-is). Substrate: PlayerTank.gd
  (sanctioned).

- **9c — Prism Tank.** `archetype = PRISM`:
  - Weapon: continuous beam while fire-held. Per physics tick the beam
    casts a line from the muzzle; damages everything in the line up to
    the first body hit; burns brick in the line.
  - Stop-and-fire: movement disabled while firing; release fire to
    move again. (Player tension: "do I commit and fire, exposed?")
  - Upgrade: a new depot rule-changer "Prism Reflect" — the beam
    reflects on the first enemy hit at ±45° → AoE-ish behavior.
  - Substrate: PlayerTank.gd (sanctioned); new arc-4 BeamWeapon helper.

- **9d — Mortar Tank.** `archetype = MORTAR`:
  - Weapon: lobbed parabolic projectile, AoE on impact (radius
    ~tank-width). Travel time matters — enemies can move out of the
    impact zone.
  - Can fire over walls — no LoS needed (the terrain-bypass archetype).
  - Slow rate of fire.
  - Substrate: PlayerTank.gd (sanctioned); new arc-4 MortarShell.

- **9e — Ram Tank.** `archetype = RAM`:
  - No projectile weapon. Damages via COLLISION (driving into an enemy
    hurts the enemy; smashes brick on collision).
  - Plus a short-range AoE swing as the fire button (a brief melee
    cone in the tank's facing direction — keeps the archetype playable
    when enemies kite).
  - Special ability: sprint/dash on demand (built into the archetype;
    independent of the existing OVERDRIVE depot upgrade).
  - Substrate: PlayerTank.gd (sanctioned).

- **9f — Start-pick selection screen.** At run start, a screen lists
  unlocked archetypes; player picks one before play begins. Default
  always unlocked; PRISM/MORTAR/RAM unlock at MetaProgress best-depth
  tiers (mirroring the iter-51 4-tier ladder — depth 20/40/60
  probably; tune in 9f). Substrate: PlayerTank.gd (the selection screen
  is HUD — sanctioned).

- **9g — Event-unlock mid-run switching.** A new depot upgrade kind:
  "Switch to <Archetype>." Drawn from the depot pool (gated by the
  same MetaProgress tiers); picking it changes the player's archetype
  mid-run — "almost like switching a weapon" per the user. Substrate:
  Depot.gd (arc-4-owned).

- **9h — Visual assets via /agentify.** Generate distinct sprites for
  Prism / Mortar / Ram via the
  `mcp__agentify-desktop__agentify_image_gen` MCP tool. Style: 16×16
  top-down pixel-art tank, consistent with the existing Default
  sprite. Each archetype's silhouette reflects its mechanic (Prism =
  beam-lens cool blue; Mortar = angled barrel earth-tone; Ram =
  blade/blunt front warm red). Drop into res://assets/. Per CONSULT
  constraint 4 (silhouette grammar), each must pass the
  silhouette-readability gate.

- **9-close — CONSULT 007 + REVIEW-QUEUE #12 + RUBRIC +C15.** Did the
  4 archetypes read as distinct personalities (the
  Into-the-Breach test), or just skins? Did the HP-bar + beam/mortar/
  ram primitives expand the playspace meaningfully? + the 3 permanent
  questions. RUBRIC.md +C15 "Tank archetypes" per the iter-39
  incremental pattern.

## Rubric

Round 9 adds a TANK ARCHETYPE surface the 14-criterion rubric does
not name. Per PROMPT §RUBRIC IS MEASUREMENT and the iter-39
incremental pattern, extend RUBRIC.md at 9-close with C15 "Tank
archetypes" — anchors covering: ≥2 archetypes exist (structural); ≥3
mechanically distinct (structural); the 4-archetype slate +
selection (structural); the [FEEL] anchors playtest-gated; the
identity-protected anchor checks the user describes archetypes by
personality, not stat.

## Guardrails

- Hash anchor 23d6a2ec3bf2821f preserved on every substrate write —
  all archetype behavior gates on `archetype != DEFAULT` (a new
  PlayerTank state, gated by the existing breach-mode loadout). The
  procedural baseline (arc-2 mode, no loadout, no archetype) is
  bit-identical.
- Enemy.gd HP-bar code is HUD-only — adds a small ColorRect / Sprite
  child; no effect on take_damage / tile generation. Bit-identical.
- Each sub-round: hash verify + `make test-all` + `make test-breach`
  green; a harness per BUILD.
- Round 8 systems (XP, picks, ammo drops, shields) STAY active across
  ALL archetypes — they layer universally.
- The 4 archetypes must read as MECHANICALLY DIFFERENT (cf. Into the
  Breach). If a new archetype reduces to a stat tweak, cut it.
- Visual asset generation via /agentify follows CONSULT constraint 4
  (silhouette readability) — each archetype passes the silhouette gate
  before commit.
- The next playtest re-checks: do the 4 archetypes feel like
  different ways to play, or just skins on top of one tank?
