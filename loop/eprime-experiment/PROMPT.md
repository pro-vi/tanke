> **Loop provenance — composed by `/loopgen` 2026-05-28.**
> Archetype: `goal`  ·  Divergences: `none` (all 6 axes match goal defaults).
> Consult-capability: `tier-2` (`mcp__agentify-desktop__*` available; PAL not in env).
> Evaluator tier: `n/a` (goal archetype does not use T0-T6 ladder).
> Frontload — resolved: motive · acceptance-inventory · cheap-channel · final-verify · scope-manifest · forbidden-shortcuts · artifact-locations · runner; defaulted: stuck-attempt-N=3; open gaps: none.
> Primitive sources: pure goal archetype + arc-4 operational continuity (`loop/breach/PROMPT.md` lineage carries hash-anchor invariant, default-on substrate gating, visual-verification discipline as inherited disciplines — NOT primitive divergences).
> Re-derive (do not hand-edit) when intent, sources, or environment change.

You are running a terminal goal loop on this repository.

Your job is not to explore the frontier.
Your job is to make a finite acceptance inventory pass without weakening it.

## Motive

Ship the bot-harness scaffolding shared by both arms of the **tanke E′ experiment** (per /agentify Pro consult 2026-05-27 — `loop/breach/CONSULT-LEDGER.md` + `refs/second-opinion-2026-05-25-loop-design.md` in Psyche). 7 deterministic GDScript bot policies + telemetry contract + 12-seed bank + headless 84-run batch + LLM-between-runs orchestration entry point, all preserving the cross-arc hash anchor.

## Runner contract

This prompt is runner-agnostic. A *runner* re-invokes this prompt iteratively; `/loop`, `/goal`, and external harnesses (gnhf, cocc, ralph) are all runners. The prompt assumes only:

1. Iterative re-invocation — you are one iteration.
2. File-persisted state — durable progress lives in named files, not memory.
3. A logical halt signal — emit `stop-and-summarize` when no useful iteration remains; the runner maps it.
4. A logical escalate signal — emit `escalate: <reason>` only when blocked on something genuinely irreversible or external (paid API without budget cap, public-publish, secrets, decisions that cannot be rolled back). Reversible judgment is not escalation — see the judgment default.

External ceilings (token limits, max-iterations, session length) are runner concerns, not repository failure. Preserve the worktree and summarize unresolved work for the next run.

## Judgment default

When the iteration hits a taste-based or inferred judgment call, prefer the narrow reversible choice + log over pausing:

1. Pick the smallest reversible action consistent with the strongest available source.
2. Record an Alignment Review with: problem · context · options considered · chosen contract · alignment cost · rollback trigger · review question for the human.
3. Continue. Human review happens after the fact.

Escalate (do not proceed) only when the action is irreversible, externally blocked, or requires authority the loop cannot establish:

- paid APIs without budget caps,
- public-publish or messages-sent actions,
- secrets / credentials,
- product-direction changes whose rollback is unclear,
- source conflict between authoritative-current sources.

## Oracle principles

This loop is honest by construction:

1. **Oracle is binary** — pass/fail; never subjective, never self-assessment.
2. **Oracle independence** — a verifier you author must first fail against the unmet behavior (mutation, sentinel, known wrong fixture). If it cannot fail, it cannot prove.
3. **Consumer-side oracle** — *"if this passes, does the downstream arm-loop have a working bot harness?"* If the answer requires inference, the verifier is wrong.
4. **Anti-theater** — `FIXED ≠ CLOSED`. A criterion's own verifier passing is `PASS_PENDING_FINAL`, not `PASS`. `PASS` requires the **final-verify** to prove the whole inventory in one repo state.

## Terminal contract

The run is complete only when **every criterion** in `loop/eprime-experiment/ACCEPTANCE.md` for goal version `bot-harness-v0.1` reaches `PASS`.

Completion is a specific halt:

1. emit `criteria-met`
2. then emit `stop-and-summarize`
3. label the halt cause `criteria-met`

Do not emit `criteria-met` for partial completion, local green commands, manual confidence, or "all easy rows done." 84 of 84 runs must succeed in the same `make bot-harness` invocation that verifies the hash anchor.

## Goal version

`bot-harness-v0.1` — fingerprint of the frozen inventory (AC-001 through AC-007) + authority sources (consult-001 §3 bot-playtester architecture + /agentify Pro 2026-05-27 §3 + §8 wind-tunnel + Procgen seed-bank lesson) + final-verify (`make bot-harness`).

If an authoritative source changes mid-run, do **not** silently absorb it. Stop, record the source change, and re-derive a new goal version.

## Acceptance inventory

`loop/eprime-experiment/ACCEPTANCE.md` is the live anchor inventory. Statuses:

- `OPEN` — no criterion-specific proof yet.
- `PASS_PENDING_FINAL` — the criterion's own verifier passed, but the final-verify hasn't proved the whole inventory together since.
- `PASS` — the final-verify proved this criterion in the same repo state as every other criterion.
- `STUCK` — 3 consecutive failed hypotheses with no new evidence.
- `BLOCKED_EXTERNAL` — genuine irreversible / external blocker.
- `QUARANTINED` — provenance, criteria, or verifier integrity conflict.

Only `PASS` counts for terminal completion. Every accepted change cites ≥1 criterion ID.

## Verifier discipline

Each criterion has a `verifier` command and `pass_evidence` in `loop/eprime-experiment/ACCEPTANCE.md`.

**Valid pass evidence:**

- named test selector passes (with criterion-specific assertion)
- JSON field equals expected value (telemetry contract conformance)
- CLI output contains exact semantic line (e.g. "BOT_HARNESS_OK 84/84")
- generated artifact exists and validates (e.g. all 84 JSON files emit + parse + schema-conform)
- hash diff against `arc-4-close` baseline: identical
- harness exit code 0 with stdout sentinel

**Invalid pass evidence:**

- "looks good" / manual inspection
- "the suite is green" with no criterion mapping
- snapshot refreshed to current wrong output
- skipped / xfailed criterion
- mocked path replacing the headless Godot run
- assertion-free fixture
- a test you just authored, used as both verifier *and* source of intent

A verifier you author must first **fail** (oracle principle #2). For each criterion, ask: *if this passes, can the arm-loops use this scaffolding to run their bot probes?* If the answer requires inference, redesign the verifier (principle #3).

## Channels

- **Cheap inner channel:** `make test` — run after edits, before the criterion-specific verifier.
- **Per-criterion verifier:** the `verifier` field on each criterion (see ACCEPTANCE.md).
- **Final-verify:** `make bot-harness` — runs all 84 bot×seed combos in headless Godot, validates each telemetry JSON against schema, verifies hash anchor against arc-4-close baseline. Emits `BOT_HARNESS_OK 84/84` on success. Acceptable wall time: <5 min total.

## Dependency topology

```
AC-001 (bot policies)     ┐
AC-002 (telemetry schema) ├─→ AC-004 (84 runs clean) ─→ AC-006 (make bot-harness green) ─→ AC-007 (orchestration entry point)
AC-003 (seed bank)        ┘                          ↑
                                                     │
AC-005 (hash anchor preserved) ──────────────────────┘  (cross-cutting: gates every substrate-touching iter)
```

- AC-001/002/003 are independent (can ship in any order).
- AC-004 depends on all three being shipped.
- AC-005 is cross-cutting — verified after every substrate write, gates AC-006.
- AC-006 depends on AC-004 (need 84 clean runs) + AC-005 (hash preserved).
- AC-007 depends on AC-001/002/003/004 (orchestration assumes underlying scaffolding works).

Selection order: unmet dependencies first → cheapest verifier feedback → highest regression risk on substrate touches.

## Iteration protocol

1. Read `loop/eprime-experiment/STATE.md` (orientation + next_action), `loop/eprime-experiment/ACCEPTANCE.md` (the 7 frozen criteria), `loop/eprime-experiment/iter-0-architect.md` (Deep blueprint — 9 implementation units, substrate-touch checklist, bug-trace cross-check), and latest verification artifacts. Confirm the goal version still matches the frozen inventory. Follow the blueprint's implementation order: U1 → U2 → (U3 ‖ U4) → U5 → U6 → U7 → (U8 ‖ U9). U2 is the ONE substrate touch — apply default-on gating template + hash-anchor verification per blueprint § Substrate-touch checklist.
2. **Oracle integrity check** before editing:
   - criteria text unchanged except `status` / `last_verification`,
   - verifiers unchanged except via approved Oracle Change Notes,
   - no skipped / xfailed selectors added,
   - no snapshot refreshed without a semantic assertion,
   - no expected evidence weakened.
3. If every criterion is `PASS_PENDING_FINAL` or `PASS`, run the **final-verify** (`make bot-harness`). If it proves the whole inventory in the same repo state: set all to `PASS`, write `loop/eprime-experiment/VERIFY.md` with the matrix, emit `criteria-met` → `stop-and-summarize`.
4. Otherwise pick one primary failing / `OPEN` criterion by topology + cheapest verifier feedback. If every remaining unpassed criterion is `STUCK` / `BLOCKED_EXTERNAL` / `QUARANTINED` / wrong-loop-shaped, go to halt classification.
5. Before editing, write one line: `criterion-id | failing-evidence | hypothesis | edit-surface | rollback`.
6. Make one small reversible change. Run the cheap inner channel (`make test`); if it fails, fix or revert before broader proof. **If touching substrate (Layer 1-4): immediately verify hash anchor against arc-4-close baseline before commit.**
7. Run the criterion's verifier. Then run impact guards for already-passing criteria the edit could disturb (especially AC-005 hash anchor).
8. Accept the change only if: the criterion moves toward pass (or gains sharper failure evidence), no passing criterion regresses, the oracle was not weakened, AND (for substrate touches) the hash anchor verified bit-identical. Otherwise revert and record the failed hypothesis.
9. If the criterion verifier passes, mark `PASS_PENDING_FINAL` — not `PASS`. `PASS` waits for the next final-verify.
10. On 3 consecutive failures with no new evidence, mark the criterion `STUCK` and switch to another unblocked criterion.

## Oracle-drift guard

The headline failure mode. The loop must not:

- delete a criterion (e.g. "we don't really need all 7 bot policies")
- rewrite a criterion into a weaker form (e.g. "5 policies are enough")
- merge criteria in a way that drops obligations (e.g. AC-001+AC-002 → "bot+telemetry shipped")
- narrow a verifier selector to avoid a failing case (e.g. exclude historical-bug seeds from AC-003)
- skip / xfail / invert / remove a failing test
- refresh a snapshot without a semantic assertion proving the new output
- reduce expected evidence specificity (e.g. "the telemetry has fields" → "the telemetry exists")
- lower a threshold without an authoritative source change
- replace integration proof with mocked proof (e.g. unit test that doesn't actually launch Godot)
- mark subjective confidence as machine proof
- treat a loop-authored test as source intent

**Verifier changes** require an **Oracle Change Note** appended inline to `loop/eprime-experiment/STATE.md`:

```text
oracle_change:
  criterion: AC-XXX
  source_criterion_unchanged: yes
  old_verifier: <cmd>
  new_verifier: <cmd>
  fault: false-positive | false-negative | flake | missing-evidence-hook | non-deterministic
  strictness_proof: <mutation, red/green pair, or sentinel showing new >= old>
  why_not_acceptance_weakening: <one line>
  rollback_trigger: <condition>
```

If strictness-preservation cannot be proved, restore the old verifier or emit `oracle-drift` and stop.

## Rules

### Scope manifest (binary in/out)

**ALLOWED edits:**
- New files under `scenes/BotHarness*.tscn`
- New files under `scripts/bots/*.gd` (bot policies + base class)
- New files under `scripts/telemetry/*.gd` (capture + schema)
- New files under `tools/bot_runner.{py,gd,sh}` (orchestration entry point)
- New files under `data/seed_bank/*.json` (12 seed specs)
- New harnesses under `loop/eprime-experiment/test_*.gd` (per-criterion verifiers)
- `Makefile` (NEW targets: `bot-harness`, `check-bots-{1..7}`, `check-telemetry-schema`, `check-seed-bank`, etc.)
- `loop/eprime-experiment/{PROMPT,ACCEPTANCE,STATE,LEDGER,VERIFY}.md` — this scaffolding's own state

**SUBSTRATE-TOUCHING (allowed only with default-on gating + hash-anchor verification post-commit):**
- `scripts/PlayerTank.gd` — only if a bot-input hook is needed AND it cannot live in a new scripts/bots/ helper; default-off flag mandatory; hash anchor verified bit-identical post-write
- Any other Layer 1-3 substrate file — same rule

**FORBIDDEN edits:**
- `.research/repos/Tanks/` (H2 tripwire — read-only canonical)
- `scripts/{LevelConfig,BiomeConfig,LevelDNA,ProceduralStep,ProceduralLevel}.gd` (hard substrate)
- `scenes/{ProceduralLevel,OriginalLevel,TitleScreen,BreachLevel,Q1ProofRoom}.tscn` (existing scenes — bot harness loads them, doesn't modify them)
- Anything that breaks `make test-all` (arc-3 regression guard)
- C# code (GDScript only)
- MLX-SD asset gen (P1 NO-GO from arc 4)
- Anything beyond the bot-harness scaffolding scope (e.g. building Round 25 assets, scoring consult-001 predictions — those are out-of-scope; this loop is INSTRUMENTATION only)

### Partial completion is not success

The loop continues while at least one unpassed criterion has a legal reversible next move inside scope. Halt with `partial-deadlock` only when every unpassed criterion is `STUCK` / `BLOCKED_EXTERNAL` / `QUARANTINED` / wrong-loop-shaped.

When halting partial: preserve pass evidence, list every unpassed criterion with its latest failing evidence, name the next required authority / verifier / reroute. Do not lower the bar.

### Status-theater prohibition

Do not emit upfront plans or rollout narration. Do not produce completion summaries mid-run. Traces, diffs, and oracle outputs are truth; notes are memory.

### Forbidden shortcuts

No `--no-verify`. No deleting tests. No reducing assertions. No moving a criterion out of the final-verify. No "temporarily skipped" rows. No snapshot refresh without semantic proof. No mocked Godot launches (the headless Godot run IS the integration proof for AC-004). No LLM-controlling-tank-in-frame-loop (per /agentify Pro 2026-05-27 §3 — bot policies are scripted GDScript only; LLM operates BETWEEN runs).

## Halt conditions

Halt = emit `stop-and-summarize`. Terminal success additionally emits `criteria-met` first. Escalate (rare, irreversible-only) is a separate signal — see the Runner contract.

Halt when:

- all criteria reach `PASS` in the final-verify → `criteria-met` → `stop-and-summarize`
- every remaining unpassed criterion is `STUCK` / `BLOCKED_EXTERNAL` / `QUARANTINED` / wrong-loop-shaped → `partial-deadlock`
- oracle drift is detected and cannot be repaired without authority → `oracle-drift`
- a genuine irreversible / external blocker prevents proof → `escalate`
- **hash anchor breaks on procedural baseline and cannot be restored same-iter** → halt + investigate (arc-4 carry; non-negotiable)

### Halt-cause classifier

When emitting `criteria-met`, `stop-and-summarize`, or `escalate: <reason>`, label:

- `criteria-met` — terminal completion; every criterion in `bot-harness-v0.1` passed in the final-verify.
- `partial-deadlock` — finite goal not met; remaining criteria are stuck / blocked / quarantined.
- `oracle-drift` — the criteria / verifier / evidence / final-verify cannot be preserved without weakening the acceptance contract.
- `derivation-gap` — blocked on something derivation could have asked for. Next derivation pass adds it to the Frontload audit.
- `genuine-escalate` — irreversible / external / authority-needed.
- `wrong-loop` — the work is not terminal goal-shaped; reroute:
  - `frontier-loop` if a criterion needs open-ended search or evaluator discovery (shouldn't happen — bot policies are scripted heuristics, schema is pre-specified);
  - `greenfield-loop` if a criterion turns out to be under-specified rather than a contract (would mean the frontload missed something — close the gap);
  - `story-loop` if the next job is discovering or reconciling product promises (out of scope — this is INSTRUMENTATION, not product).

`derivation-gap` is the feedback signal — the Frontload audit was incomplete; close it next run.

## Artifacts to maintain

- `loop/eprime-experiment/ACCEPTANCE.md` — frozen criteria, mutable `status` / `last_verification`.
- `loop/eprime-experiment/STATE.md` — goal version, iteration, current criterion, stuck counters, Oracle Change Notes (inline), last action, next action.
- `loop/eprime-experiment/LEDGER.md` — per-iter log (append-only, one entry per iter).
- `loop/eprime-experiment/VERIFY.md` — latest final-verify transcript; written on `criteria-met`.
- Evidence artifacts: telemetry JSON (`data/telemetry/seed_NN_bot_X.json`), harness logs, hash-diff outputs.

### Skill Harvest

When an iteration exposes a reusable process lesson — a failure mode the skill didn't yet name, an invariant that would have prevented drift, a pattern that generalizes beyond this specific run — write a **Skill Harvest note** to `loop/eprime-experiment/SKILL-HARVEST.md`:

- **target skill** — `/loopgen`, `/architect`, this scaffolding, or a sibling
- **observed gap** — the rule that's missing or under-specified
- **evidence iteration** — which iteration revealed it
- **proposed rule** — suggested wording for the patch
- **why it generalizes** — or note that it doesn't
- **suggested patch wording** — drop-in text
- **accidental-encouragement risk** — what bad behavior the new rule could enable

Location: `loop/eprime-experiment/SKILL-HARVEST.md` (create on first harvest).

## Repo-specific overlay

- **Godot 4.6.2 headless input pattern** (from arc-3 session-learnings L1+L5): use `Input.parse_input_event(event)` with `await process_frame` to drive the tank from GDScript outside the player input chain. Reference: `loop/originals/iter027-meta-arc3-ceiling.md` PATTERN 5.
- **Bot input hook**: if PlayerTank.gd needs a "input override" flag, gate it default-off (existing default-on substrate gating template). Hash anchor on flag-off codepath verifies bit-identical to arc-4-close.
- **Scenario host**: `scenes/Q1ProofRoom.tscn` (existing, playable, has BreachBand + ASCII layout + parser + spawn). Bot harness loads it, runs the bot through it, captures telemetry on death/win.
- **Telemetry path**: emit JSON to `data/telemetry/seed_NN_bot_X.json` (NEW directory). Schema: one file per run; final-verify aggregates all 84 + validates.
- **Hash-anchor baseline**: `23d6a2ec3bf2821f9e45943364483fef4f91b7af55e1badb1140fa7634024291` (cross-arc invariant since arc 1 iter 0). Verified by `loop/test_runner.gd --seed 42 --json | jq .tile_hash`.
- **Known false-green zones**: a bot that "completes" by exploiting a movement bug (out-of-bounds, clipping, infinite-loop spawn) counts as a fail — telemetry must include physics-sanity checks (movement velocity bounds, position-inside-playfield asserts).
- **Wall-time budget**: 84 runs × <3 sec each = ~4 min headless. Acceptable. If a single run exceeds 30 sec, that's a `timeout` death_cause and the run is recorded — don't crash the batch.
