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
