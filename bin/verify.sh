#!/usr/bin/env bash
#
# bin/verify.sh — the ONE command that decides whether this project is "done".
#
# Goes in <your-repo>/bin/verify.sh. Commit it on day one, before any feature code.
# Whatever this script checks IS your definition of done; if it exits 0, you may
# say "done", and not before. Claude is told to run it in CLAUDE.md.
#
# Start small. A single `run_step "build" "npm run build"` is a valid first version.
# Grow it as the project grows — every regression that bites you becomes a step here.
#
# PROVE EACH STEP CAN FAIL, once, when you add it. Break the thing it checks on
# purpose, confirm the step goes red, then fix it. Exit code 3 catches a script
# with no steps, but nothing catches a step that runs and never detects anything —
# and that is the more dangerous shape, because it reports green forever.
#   Real example: `node --check file.js` reliably rejects broken CommonJS, but
#   returns 0 on a file using `export` even when the syntax is plainly invalid.
#   The step looked fine. It proved nothing.
#
# Usage:
#   bash bin/verify.sh          # full (default): every step
#   bash bin/verify.sh fast     # fast: cheap steps only, for per-edit hooks
#   bash bin/verify.sh full     # explicit full
#
# Exit codes:
#   0 — every step that ran passed
#   1 — one or more steps failed (per-step log path is printed above)
#   2 — usage error, or not run from the repo root
#   3 — NO STEPS DEFINED. This is a failure, not a pass: an empty gate that
#       reports success is worse than no gate, because automation reads it as
#       green. Define at least one run_step before wiring this to a hook.
#
# Requirements:
#   - Run from the repo root.
#   - bash and grep only.

set -uo pipefail

# ---------------------------------------------------------------------------
# Mode: fast (cheap checks only) or full (everything). Default is full.
# ---------------------------------------------------------------------------
MODE="${1:-full}"
case "$MODE" in
    fast|full) ;;
    *) echo "Usage: bash bin/verify.sh [fast|full]" >&2; exit 2 ;;
esac

# ---------------------------------------------------------------------------
# Guard: must run from the repo root (skipped when this is not a git repo)
# ---------------------------------------------------------------------------
if git rev-parse --show-toplevel >/dev/null 2>&1; then
    ROOT="$(cd "$(git rev-parse --show-toplevel)" && pwd -P)"
    CURRENT="$(pwd -P)"
    if [[ "$CURRENT" != "$ROOT" ]]; then
        echo "Error: run this from the repo root."
        echo "  expected: $ROOT"
        echo "  current:  $CURRENT"
        exit 2
    fi
fi

LOG_DIR="$(mktemp -d)"
PASS=0
FAIL=0
FAILED_STEPS=()

# run_step "<label>" "<shell command>"
#   Runs the command, hides its output unless it fails, and tallies the result.
run_step() {
    local label="$1"
    local cmd="$2"
    local log_file="$LOG_DIR/${label// /_}.log"

    printf "→ %-38s " "$label"

    if bash -c "$cmd" > "$log_file" 2>&1; then
        printf "✅ PASS\n"
        PASS=$((PASS + 1))
    else
        printf "❌ FAIL\n"
        echo "   log: $log_file"
        FAIL=$((FAIL + 1))
        FAILED_STEPS+=("$label")
    fi
}

# run_step_full "<label>" "<shell command>"
#   Same as run_step, but skipped in fast mode. Use it for anything too slow to
#   run after every edit: test suites, builds, simulators.
run_step_full() {
    if [[ "$MODE" == "fast" ]]; then
        printf "→ %-38s ⏭  SKIP (fast)\n" "$1"
        return 0
    fi
    run_step "$@"
}

echo "minchiaHuang profile — verification [$MODE]"
echo "====================================="

# ---------------------------------------------------------------------------
# Steps. Offline on purpose: a live link check depends on the network and on
# third-party sites, so it cannot be a stable definition of done.
#
# Broken on purpose (2026-09-15): an http:// link, a relative link, and a
# README with no links each made this step go red.
# ---------------------------------------------------------------------------

# README.md must exist, contain at least one link, and every link must be
# https:// or mailto: — no relative paths, no http://, no empty targets.
run_step "README links well-formed" '[ -s README.md ] && grep -qE "\]\((https://|mailto:)" README.md && ! grep -oE "\]\([^)]*\)" README.md | grep -vE "^\]\((https://[^ )]+|mailto:[^ )]+)\)$"'

# ---------------------------------------------------------------------------

echo

if (( PASS == 0 && FAIL == 0 )); then
    echo "❌ No steps defined — this script currently proves nothing."
    echo "   Add at least one run_step above. Exiting 3 (unconfigured) so that"
    echo "   automation cannot mistake an empty gate for a passing one."
    rm -rf "$LOG_DIR"
    exit 3
fi

echo "Summary: $PASS passed, $FAIL failed."

if (( FAIL > 0 )); then
    echo "Failed steps:"
    for step in "${FAILED_STEPS[@]}"; do
        echo "  - $step"
    done
    echo "Logs preserved under $LOG_DIR"
    exit 1
fi

# Cleanup logs on full success only.
rm -rf "$LOG_DIR"
echo "All steps passed."
exit 0
