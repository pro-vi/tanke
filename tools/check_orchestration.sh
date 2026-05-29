#!/usr/bin/env bash
# AC-007 verifier — exercises the orchestration entry point tools/bot_runner.sh.
#   1. happy path: 2 bots x 2 seeds -> a parseable summary JSON with 4 run entries.
#   2. teeth: an unknown bot id MUST fail loudly (non-zero exit, no summary) —
#      never a silent skip.
# Emits ORCHESTRATION_OK on full pass; ORCHESTRATION_FAIL + non-zero otherwise.
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="$PROJECT_DIR/tools/bot_runner.sh"
SUMMARY="$(mktemp -u)_summary.json"
BOGUS_OUT="$(mktemp -u)_bogus.json"
rm -f "$SUMMARY" "$BOGUS_OUT"

# --- 1. happy path: 4 runs ---
if ! bash "$RUNNER" --bots move-to-cover,panic-random --seeds 1,7 --out "$SUMMARY" >/dev/null 2>&1; then
  echo "  FAIL — bot_runner.sh exited non-zero on valid input"
  echo "ORCHESTRATION_FAIL"; exit 1
fi
if [[ ! -f "$SUMMARY" ]]; then
  echo "  FAIL — no summary JSON produced at $SUMMARY"
  echo "ORCHESTRATION_FAIL"; exit 1
fi
N=$(python3 -c "import json,sys; print(len(json.load(open('$SUMMARY')).get('runs',[])))" 2>/dev/null || echo "-1")
if [[ "$N" != "4" ]]; then
  echo "  FAIL — summary has $N run entries (expected 4)"
  echo "ORCHESTRATION_FAIL"; exit 1
fi
echo "  case happy-path 2bots x 2seeds = 4 run entries OK"

# --- 2. teeth: unknown bot must fail loudly ---
if bash "$RUNNER" --bots no-such-bot --seeds 1 --out "$BOGUS_OUT" >/dev/null 2>&1; then
  echo "  FAIL — TEETH: unknown bot did NOT fail (silent skip)"
  echo "ORCHESTRATION_FAIL"; exit 1
fi
if [[ -f "$BOGUS_OUT" ]]; then
  echo "  FAIL — TEETH: summary written despite unknown bot"
  echo "ORCHESTRATION_FAIL"; exit 1
fi
echo "  case unknown-bot-fails-loudly OK"

rm -f "$SUMMARY" "$BOGUS_OUT"
echo "ORCHESTRATION_OK"
