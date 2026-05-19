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
