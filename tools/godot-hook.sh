#!/usr/bin/env bash
# PostToolUse hook: run headless runtime check after .gd / .tscn edits.
# Injects errors back into Claude's context via hookSpecificOutput.

FILE=$(jq -r '.tool_input.file_path // ""')
echo "$FILE" | grep -qE '\.(gd|tscn)$' || exit 0

cd /Users/provi/Development/_projs/tanke
OUT=$(make test 2>&1)
[ -z "$OUT" ] && exit 0

jq -n --arg msg "Godot runtime errors:\n$OUT" \
  '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":$msg}}'
