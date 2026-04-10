#!/bin/bash
# Usage: discuss-timer.sh <timer-env-path>
# Output: JSON with remaining time, phase, and synthesis budget
# Phases: early (>50%), mid (25-50%), late (<=25% and >synth), wrap-up (<=synth)

set -euo pipefail

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
    echo '{"error":"Usage: discuss-timer.sh <timer-env-path>"}' >&2
    exit 1
fi

source "$1"

NOW=$(date '+%s')
ELAPSED=$((NOW - START_EPOCH))
REMAINING=$((DURATION_SEC - ELAPSED))
if [ "$REMAINING" -lt 0 ]; then REMAINING=0; fi
TOTAL=$DURATION_SEC

# synthesis_budget = max(120, total * 15 / 100)
SYNTH=$((TOTAL * 15 / 100))
if [ "$SYNTH" -lt 120 ]; then SYNTH=120; fi

# Phase calculation (percentage-only with synthesis_budget floor for wrap-up)
PCT=$((REMAINING * 100 / TOTAL))
if [ "$REMAINING" -le "$SYNTH" ]; then PHASE="wrap-up"
elif [ "$PCT" -le 25 ]; then PHASE="late"
elif [ "$PCT" -le 50 ]; then PHASE="mid"
else PHASE="early"
fi

# Human-readable
RMIN=$((REMAINING / 60))
RSEC=$((REMAINING % 60))
EMIN=$((ELAPSED / 60))
ESEC=$((ELAPSED % 60))

printf '{"remaining_sec":%d,"remaining_human":"%dm%02ds","elapsed_sec":%d,"elapsed_human":"%dm%02ds","phase":"%s","total_sec":%d,"synthesis_budget_sec":%d}\n' \
  "$REMAINING" "$RMIN" "$RSEC" "$ELAPSED" "$EMIN" "$ESEC" "$PHASE" "$TOTAL" "$SYNTH"
