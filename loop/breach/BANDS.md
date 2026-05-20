# Depth Band Roadmap (arc 4, breach economy)

Five bands proposed; each is a *specific climb problem* (CONSULT constraint 5).
NOT generic-harder progression. Each band's dominant pressure demands a
specific breach answer (shell + positioning + build affordance).

Band depths are placeholders for iter-2-3 tuning. Reachability oracle
verifies each band's spawn-to-exit geometry pre-commit.

---

## Band 1 — Tutorial choke (depth 0-30)

| Aspect | Value |
|--------|-------|
| Dominant pressure | Brick walls + light scouts |
| Canonical answer | AP — cheap pierce; conserve HE+HEAT for later |
| Terrain palette | Brick (HP=1), open ground; minimal steel |
| Enemy roles | EnemyLight only |
| Depot at exit? | **Yes — Depot 1**: starter shells, first build choice |
| Acceptance | - [ ] Reachability passes 5/5 seeds<br>- [ ] Avg run uses ≥70% AP through band<br>- [ ] First-time playtest: completes band 1 without dying ≥80% of attempts |

---

## Band 2 — Brick maze (depth 30-70)

| Aspect | Value |
|--------|-------|
| Dominant pressure | Dense brick layouts; long detours unless breached |
| Canonical answer | HE — open vertical lanes; trade shells for time |
| Terrain palette | Brick dense, rubble (HE-created tile state), narrow corridors |
| Enemy roles | EnemyLight, EnemyMedium (NEW iter target) |
| Depot at exit? | **Yes — Depot 2**: HE-economy upgrade options |
| Acceptance | - [ ] Reachability passes 5/5 seeds<br>- [ ] HE accounts for ≥30% of shell consumption (vs ≤20% in band 1)<br>- [ ] Playtest: user cites lane-breach decision unprompted |

---

## Band 3 — Bunker zone (depth 70-120)

| Aspect | Value |
|--------|-------|
| Dominant pressure | Steel-armored bunkers; entrenched heavy tanks |
| Canonical answer | HEAT — anti-armor commitment; AP useless against bunkers |
| Terrain palette | Steel-cluster bunkers; brick perimeters; chokepoint geometry |
| Enemy roles | EnemyHeavy entrenched (NEW iter target: facing-aware armor) |
| Depot at exit? | **Yes — Depot 3**: HEAT reserves + chassis-class swap |
| Acceptance | - [ ] Reachability passes 5/5 seeds<br>- [ ] HEAT accounts for ≥40% of shell consumption in band<br>- [ ] Death-in-band recap cites "ran out of HEAT" pattern on ≥30% of deaths<br>- [ ] Playtest: user names "bunker band" unprompted |

---

## Band 4 — Open killbox (depth 120-180)

| Aspect | Value |
|--------|-------|
| Dominant pressure | Wide open spaces; fast scouts; rear-flanking patrols |
| Canonical answer | AP precision + facing-aware positioning; HE wasted on open ground |
| Terrain palette | Sparse cover; long sightlines; tactical brick pillars |
| Enemy roles | EnemyLight fast (NEW iter target: pursuit AI), EnemyMortar (NEW: telegraphed area denial) |
| Depot at exit? | **Yes — Depot 4**: speed/facing upgrades; last chance to rebuild loadout |
| Acceptance | - [ ] Reachability passes 5/5 seeds<br>- [ ] Front-vs-rear damage differential measurable in harness<br>- [ ] Mortar telegraph + dodge window ≥1.0s — code-cited<br>- [ ] Playtest: user cites facing-aware positioning |

---

## Band 5 — Endgame mixed (depth 180+)

| Aspect | Value |
|--------|-------|
| Dominant pressure | All prior pressures composed; no further depots |
| Canonical answer | Build cohesion test — chosen identity (bunker-cracker / lane-sniper / rubble-plow) determines reach |
| Terrain palette | All terrain types; band-3 bunkers reappear; band-4 killboxes reappear |
| Enemy roles | All enemy roles mixed |
| Depot at exit? | None (or final "victory" depot at depth 250) |
| Acceptance | - [ ] Reachability passes 5/5 seeds<br>- [ ] Different build identities reach different median depths (cohesion-as-divergence)<br>- [ ] Death recap distinguishes build-vs-execution failure<br>- [ ] Playtest: user names ≥2 distinct build identities across runs |

---

## Per-role canonical answers (C5 anchor 2)

The 3 enemy roles in `Spawner.gd` ENEMY_TYPES. Each has a canonical
shell + positioning answer (CONSULT §9 constraint 3 — "every enemy type
must have a readable shell/positioning relationship"). Role spawn
weights per band live in `configs/breach_default.tres` `enemy_weights`;
`make check-breach-enemies` verifies every role appears in ≥1 band.

| Role | Behavior | Canonical shell | Canonical positioning |
|------|----------|-----------------|------------------------|
| **Light** | rare-fire lane-invader (commits to a lane, fires seldom) | **AP** — 1 HP, cheap precise kill; never spend HE/HEAT | Intercept the lane head-on before it reaches the eagle line; a single AP shot resolves it |
| **Heavy** | paused-aim corridor-denier (stops, telegraphs, bursts when aligned) | **HEAT** — 2 HP, HEAT 2× one-shots it; or 2 AP if HEAT-starved | Break line-of-sight during the red aim telegraph; strike from the side while it is committed to a stop |
| **Fast** | continuous-fire harasser (high speed, fires while moving, no telegraph) | **AP** — 1 HP, volume threat not durability; lead the moving target | Keep moving, never get cornered; AP on the lead — do not waste HE/HEAT on a 1-HP rusher |

Bands compose these: tutorial_choke = Light only (AP economy intro);
bunker_zone = Heavy-dominant (HEAT band); open_killbox = Fast-dominant
(AP-precision + facing band); endgame_mixed = all three.

---

## Depot placement summary

| Depot | After band | Function |
|-------|------------|----------|
| 1 | Band 1 | Starter shells; first build commitment (AP-economy / HE-economy / HEAT-economy) |
| 2 | Band 2 | HE-economy upgrade slot; preview band-3 bunker pressure |
| 3 | Band 3 | HEAT reserve + chassis swap; preview band-4 open killbox |
| 4 | Band 4 | Speed/facing module slots; final rebuild before endgame |
| 5 (optional) | Band 5 | Victory state OR final-band rest beat |

**Depot dwell budget (CONSULT-derived anti-pattern guard)**: ≤30s per depot. Harness measures this on playtest captures.

---

## Status

**All 5 bands implemented in `configs/breach_default.tres` as of iter 13.**

| Band | Depth | Config | Reachability |
|------|-------|--------|--------------|
| 1 tutorial_choke | 0-30 | iter 3, retuned iter 11-12 | verified ✓ |
| 2 brick_maze | 30-70 | iter 3, retuned iter 11-12 | verified ✓ |
| 3 bunker_zone | 70-120 | iter 11, retuned iter 12 | verified ✓ |
| 4 open_killbox | 120-180 | iter 13 | verified ✓ |
| 5 endgame_mixed | 180-260 | iter 13 | verified ✓ |

Reachability is verified by `loop/breach/test_breach_harness.gd` (the
per-band pure-data oracle). **Floor: ≥80% of a 10-seed sweep** — the
per-band acceptance "Reachability passes 5/5 seeds" above was written
before F001 taught us reachability is a high-variance extremal metric
(arc-1 lesson). Current state: **9/10 seeds pass** all 5 bands (seed 77
fails — a spawn-area Eller artifact, not config-tunable). Canonical
seed 42 passes all 5 bands solidly.

Remaining per-band acceptance items (shell-mix %, playtest cites) are
still open — they need the iter-14+ shell-consumption harness + a
playtest. The depth bands' terrain experience is live in breach mode
(`scenes/BreachLevel.tscn`).

Update this file as bands ship (checkbox each acceptance item; cite LEDGER iter).
