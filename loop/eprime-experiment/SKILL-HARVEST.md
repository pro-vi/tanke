# Skill Harvest — bot-harness-v0.1

Reusable process lessons surfaced by this loop. Format per PROMPT.md § Skill Harvest.

---

## SH-001 (iter 1): Godot `class_name` cache must be regenerated before `--script` sees a new type

- **target skill**: this scaffolding's repo-specific overlay (PROMPT.md § Repo-specific overlay); generalizes to any Godot-4 loop in `/loopgen` / `/architect`.
- **observed gap**: The blueprint and PROMPT overlay document the headless input pattern and hash-anchor verifier, but NOT the fact that creating a new `class_name X` `.gd` file does not register `X` until the project's global class cache is rebuilt. Running `godot --headless --path . --script res://…` against a test that references the new type fails with `Parse Error: Identifier "X" not declared in the current scope` — which reads like a code bug, not a stale-cache artifact.
- **evidence iteration**: iter 1. After writing `scripts/bots/{BotAction,BotObservation,BotPolicy}.gd`, the verifier kept parse-failing on `BotAction not declared` even though the files were correct. Fix: `godot --headless --path . --import` once → `.godot/global_script_class_cache.cfg` gains the three entries → verifier runs green.
- **proposed rule**: Add to the repo-specific overlay: "After creating ANY new `class_name` `.gd` file, run `godot --headless --path . --import` once before invoking it via `--script`, to register it in `.godot/global_script_class_cache.cfg`. A `Parse Error: Identifier … not declared` on a freshly-created `class_name` type is almost always a stale class cache, not a code error."
- **why it generalizes**: Any Godot-4 goal/frontier loop that adds new `class_name` scripts and verifies them via headless `--script` hits this. It is invisible in the editor (which rescans live) and only bites headless/CI flows — exactly the flows loops use.
- **suggested patch wording**: (above — drop into PROMPT.md § Repo-specific overlay as a new bullet, and into `/loopgen`'s Godot repo-overlay template if one exists.)
- **accidental-encouragement risk**: Low. Could tempt an agent to run `--import` reflexively after every edit (wasting ~2s each). Mitigate by scoping the rule to "new `class_name` files only," not every edit — `--import` is unnecessary for edits to existing scripts or to non-`class_name` scripts.

---

## SH-002 (iter 6): a headless SceneTree verifier that hits a runtime error before quit() HANGS — guard before dereferencing

- **target skill**: this scaffolding's repo overlay; generalizes to any headless Godot SceneTree test harness in `/loopgen` / `/architect`.
- **observed gap**: A `--script`-run SceneTree test reaches `quit()` only if `_initialize()` runs to completion. An unhandled GDScript runtime error (e.g. dereferencing `null.move_dir` when a mutated function returns null) aborts the function mid-way, `quit()` is never called, and the headless process runs FOREVER — the verifier neither passes nor fails, it just hangs. This bit a mutation test (deliberately broke a bot to return null to prove the verifier's teeth): the verifier *correctly detected* the null in an early loop, but a later assertion dereferenced the same null and hung before the failure could be reported.
- **evidence iteration**: iter 6. The teeth-test command had to be killed (TaskStop) after >60s; the file mutation could not be git-restored (untracked, not yet committed) so it was reverted by hand.
- **proposed rule**: "In a headless SceneTree verifier, fail-fast: after each validation stage, if failures were found, `print(SENTINEL_FAIL); quit(1); return` BEFORE any later code that dereferences the just-validated value. Never let a downstream assertion run on a value an earlier stage already flagged invalid — a runtime error there hangs the process instead of reporting the failure. When running a mutation/teeth test, invoke the harness with an external timeout (`gtimeout`/background+kill) so a hang surfaces as a failure, not an indefinite stall."
- **why it generalizes**: Any loop that authors headless oracles and runs mutation tests against them will eventually mutate a function into returning a type the oracle then dereferences. Without fail-fast + an external timeout, the mutation test hangs the whole loop.
- **suggested patch wording**: (above — add to the repo overlay / `/architect` test-scenario guidance for headless harnesses.)
- **accidental-encouragement risk**: Low. Fail-fast could mask *later* independent failures by bailing on the first stage — acceptable for a gate (any failure = fail) but note it in harnesses meant to enumerate ALL failures for triage; there, collect-then-guard-each-deref instead of bailing.

---

## SH-003 (iter 7): GDScript lambdas capture LOCAL variables by value — `signal.connect(func(x): local = x)` silently no-ops

- **target skill**: this scaffolding; generalizes to any GDScript code in `/architect` / `/build` that uses lambdas + signals.
- **observed gap**: A common pattern to "capture a signal payload into a variable" — `var captured := {}; obj.signal.connect(func(t): captured = t)` — does NOT work when `captured` is a LOCAL: GDScript lambdas capture enclosing locals by VALUE, so the assignment mutates the lambda's private copy, leaving the outer local untouched. It DOES work when the target is a MEMBER variable (the lambda reaches it via `self`). This is silent: no error, the variable just stays at its default.
- **evidence iteration**: iter 7. The batch runner's per-run capture used a local + `recorded.connect(func(t): captured = t)` and reported "no telemetry emitted" for all 84 runs even though 84 valid files were written. The earlier 1-run probe used the identical pattern but worked — because the probe's capture var was a class MEMBER, not a local. Diagnosis took a full 84-run cycle.
- **proposed rule**: "To read a value produced by a signal/callback in GDScript, do NOT assign to an enclosing LOCAL inside the lambda (captured by value — the write is lost). Either (a) assign to a class MEMBER var, (b) have the producer STORE the result in a field the consumer reads directly (preferred for one-shot reads — e.g. recorder._result), or (c) await the signal instead of connecting a lambda."
- **why it generalizes**: The local-by-value capture is a language-level GDScript semantic; any agent reaching for the idiomatic 'collect into a closure variable' pattern (common from JS/Python habits where closures capture by reference) hits it. It is silent and survives small tests (which often use members), surfacing only at scale.
- **suggested patch wording**: (above — add to `/architect`/`/build` GDScript gotchas, and the repo overlay.)
- **accidental-encouragement risk**: Negligible — it steers toward member-var or direct-field reads, both safe.

---

## SH-004 (arc-harness-v0.2): trust FileAccess output, NEVER tool-display output, for numerical telemetry

- **target skill**: any `/loopgen` / `/build` loop that reads numerical results back from a headless run; deserves a Psyche concept note (cross-session loop hazard).
- **observed gap**: In this environment, Bash stdout AND the Read tool's display of long/many-line content were intermittently **garbled** — returning *plausible but wrong* numbers (e.g. a depth distribution displayed as "median 39/42" when the true value, written to a file, was 13). Because the wrong numbers were plausible, they were trusted and written into acceptance docs / oracle thresholds before being caught. This happened more than once in one session and cost multiple iterations of rework + correction.
- **evidence iteration**: arc-harness-v0.2 U10. A bot rewrite was reported as a 3× depth win ("median 39") from garbled reads; the FileAccess-written `_dist.txt` showed the same build was actually median 8.5 (worse than baseline 13). The error was only caught by writing a one-line summary via `FileAccess` and reading THAT.
- **proposed rule**: "Never report or threshold a metric you have not read back from a FILE the run wrote via `FileAccess`. Pattern: have the GDScript probe write a SHORT result (ideally one summary line) to `res://…_out.txt`, read it with the Read tool or `od -c`, and cross-check by re-running and `diff`-ing two batches (determinism is itself a correctness check). Treat any number that appears only in streamed Bash stdout or in a long Read render as UNVERIFIED."
- **why it generalizes**: Any loop that measures a headless harness and feeds the measurement into a gate/threshold/report is exposed. Garbled display is silent and the numbers look real, so it survives until cross-checked. The fix (short FileAccess summary + diff) is cheap and universal.
- **environment sub-gotchas (same family — silent EMPTY output)**: `godot` is on PATH (`/opt/homebrew/bin/godot`), NOT `./godot`; macOS has **no `timeout`** command — use the runner's own timeout. Both produce empty output that can be mis-read as "test ran and found nothing."
- **accidental-encouragement risk**: Low. Slightly more ceremony per measurement (write-file + re-run-diff); worth it — an unverified metric in a gate is a false PASS/FAIL.

---

## SH-005 (arc-harness-v0.2): disconfirmation is a deliverable — revert the premise, keep the sub-finding

- **target skill**: `/loopgen` / `/build` bounded-attempt discipline; `/architect` risk framing.
- **observed gap**: When a planned approach (here: the U10 motion-primitive controller, blessed by the plan + a frontier-model second opinion) is measured WORSE than the existing baseline, the instinct is to keep tuning it (sunk cost) or to quietly lower the acceptance threshold so it "passes." Both corrupt the loop.
- **evidence iteration**: arc-harness-v0.2 U10. Two motion-controller variants measured worse than the committed baseline (8.5 and 2 vs 13). The correct move was: REVERT the bot to baseline (no regression), KEEP only the orthogonal sub-finding that independently held (a determinism re-seed that fixed a real RNG-leak), and RECORD the negative result in the handover so the next session does not redo motion tuning. The premise died; the instrumentation lived.
- **proposed rule**: "A bounded attempt that measures worse than baseline is a successful experiment, not a failure to hide. Revert the regressing change, salvage any orthogonal sub-finding that holds on its own measurement, and write the disconfirmation into the next-session handover with the numbers. NEVER lower an acceptance threshold to make a regressing change pass — raise the bar only when capability earns it."
- **why it generalizes**: Every iterative loop will eventually pursue a plausible hypothesis that doesn't pan out. Treating the negative result as a recorded deliverable (with a 'do not redo' note) prevents the next session from re-burning the same budget.
- **accidental-encouragement risk**: Low. Could be misread as "give up early"; mitigate by requiring the revert be *measurement-driven* (worse than a real baseline across the bounded attempt), not vibes.
