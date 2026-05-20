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
