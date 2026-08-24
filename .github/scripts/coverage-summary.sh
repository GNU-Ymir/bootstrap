#!/usr/bin/env bash
#
# Renders the log of the final `./ymirc.test --resume -cov` run into $GITHUB_STEP_SUMMARY: the
# whole-suite coverage report (merged from every shard's coverage files) with a badge on success,
# the raw log on failure.
#
#   usage: coverage-summary.sh <log-file> <outcome of the step that produced it>

set -uo pipefail

LOG="${1:?usage: coverage-summary.sh <log-file> <outcome>}"
OUTCOME="${2:-failure}"
SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

if [ ! -f "$LOG" ]; then
    echo "## No test output" >> "$SUMMARY"
    exit 0
fi

# ymirc.test writes NUL bytes into its output; left in, every grep below treats the log as binary
# and answers "binary file matches" instead of giving back the line.
CLEAN="$(tr -d '\000' < "$LOG" | sed -E 's/\x1b\[[0-9;]*m//g')"

if [ "$OUTCOME" != "success" ]; then
    {
        echo "## Tests failed - no coverage report"
        echo
        echo '```'
        echo "$CLEAN"
        echo '```'
    } >> "$SUMMARY"
    exit 0
fi

HEADER_LINE="$(echo "$CLEAN" | grep -n 'COVERAGE' | head -1 | cut -d: -f1)"
if [ -z "$HEADER_LINE" ]; then
    # The run passed but printed no report - the coverage files never made it into the container.
    {
        echo "## Coverage report missing"
        echo
        echo "The tests passed but \`ymirc.test --resume -cov\` printed no COVERAGE section."
        echo
        echo '```'
        echo "$CLEAN"
        echo '```'
    } >> "$SUMMARY"
    echo "::warning::the final --resume run printed no coverage report"
    exit 0
fi

REPORT="$(echo "$CLEAN" | tail -n "+$((HEADER_LINE - 1))")"
TOTAL_LINE="$(echo "$CLEAN" | grep -E 'TOTAL:' | tail -1)"
TOTAL_PCT="$(echo "$TOTAL_LINE" | grep -oE '^\[[0-9]+%\]' | tr -d '[]')"
TOTAL_NUM="${TOTAL_PCT%\%}"

if [ -z "$TOTAL_NUM" ]; then
    BADGE_COLOR="lightgrey"
    TOTAL_NUM="unknown"
elif [ "$TOTAL_NUM" -lt 50 ]; then
    BADGE_COLOR="red"
elif [ "$TOTAL_NUM" -gt 95 ]; then
    BADGE_COLOR="brightgreen"
else
    BADGE_COLOR="yellow"
fi

# Every test a shard ran is already recorded as passed in the merged success map, so --resume only
# ever runs what no shard claimed. Those tests did run - the suite stays complete whatever the
# shard filters say - but they ran here, serially, instead of in parallel with the rest.
UNCLAIMED="$(echo "$CLEAN" | grep -E '^\[RUN\] : ' | sed -E 's/^\[RUN\] : //')"
UNCLAIMED_COUNT=0
if [ -n "$UNCLAIMED" ]; then
    UNCLAIMED_COUNT="$(echo "$UNCLAIMED" | wc -l)"
fi

{
    echo "## Coverage ![coverage](https://img.shields.io/badge/coverage-${TOTAL_NUM}%25-${BADGE_COLOR})"
    echo
    echo '```'
    echo "$REPORT"
    echo '```'
} >> "$SUMMARY"

if [ "$UNCLAIMED_COUNT" -ne 0 ]; then
    {
        echo
        echo "### ${UNCLAIMED_COUNT} test(s) matched no shard"
        echo
        echo "They ran here instead of in a shard. Add them to a shard's \`filters\` in"
        echo "\`.github/workflows/ci.yml\` to run them in parallel with the rest."
        echo
        echo '```'
        echo "$UNCLAIMED"
        echo '```'
    } >> "$SUMMARY"

    echo "::warning::${UNCLAIMED_COUNT} test(s) matched no shard filter and ran serially in the coverage job"
fi
