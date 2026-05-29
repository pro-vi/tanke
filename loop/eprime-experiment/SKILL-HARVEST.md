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
