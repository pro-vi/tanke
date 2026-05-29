#!/usr/bin/env bash
# AC-007 — the LLM-between-runs orchestration entry point. A thin wrapper an
# outer loop (/loop, /goal, a future E' arm-loop) invokes to run a subset (or
# all) of the bot x seed matrix and get back a consolidated summary JSON it can
# read to decide the next iteration. NO LLM drives the tank — this is the
# scripted-bot batch layer the LLM uses BETWEEN runs (consult-001 §3).
#
# Usage:
#   tools/bot_runner.sh --bots <all|a,b,..> --seeds <all|1,2,..> --out <summary.json>
#
# Runs loop/eprime-experiment/bot_runner.gd (per-run telemetry JSONs to a temp
# dir), then aggregates them via tools/bot_summary.py into <summary.json>.
# Exits non-zero (no summary) if the batch fails or a bot id is unknown — never
# a silent skip.
set -uo pipefail

GODOT="${GODOT:-godot}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BOTS="all"
SEEDS="all"
OUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --bots)  BOTS="${2:-}"; shift 2 ;;
    --seeds) SEEDS="${2:-}"; shift 2 ;;
    --out)   OUT="${2:-}"; shift 2 ;;
    *) echo "bot_runner.sh: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

if [[ -z "$OUT" ]]; then
  echo "bot_runner.sh: --out <summary.json> is required" >&2
  exit 2
fi

RUN_DIR="$(mktemp -d)"
trap 'rm -rf "$RUN_DIR"' EXIT

# Run the batch; per-run telemetry JSONs land in RUN_DIR. bot_runner.gd exits
# non-zero + prints RUNS_FAIL on any failure (incl. unknown bot).
"$GODOT" --headless --path "$PROJECT_DIR" --fixed-fps 60 \
  --script res://loop/eprime-experiment/bot_runner.gd -- \
  --bots "$BOTS" --seeds "$SEEDS" --out "$RUN_DIR" \
  > "$RUN_DIR/_run.log" 2>&1 || true

if ! grep -q "^RUNS_OK" "$RUN_DIR/_run.log"; then
  echo "bot_runner.sh: batch did not succeed — no summary written:" >&2
  grep -E "RUNS_FAIL|unknown bot|SCRIPT ERROR" "$RUN_DIR/_run.log" >&2 || true
  exit 1
fi

python3 "$PROJECT_DIR/tools/bot_summary.py" --in "$RUN_DIR" --out "$OUT"
echo "bot_runner.sh: $(grep -o '^RUNS_OK [0-9]*/[0-9]*' "$RUN_DIR/_run.log") -> summary $OUT"
