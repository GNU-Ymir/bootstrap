#!/usr/bin/env bash
#
# Turns the compiler warnings left in the build log into GitHub annotations, and says how many
# there were. Run by the `build` job of ci.yml, on the log the Dockerfile's `build` stage teed
# into the image.
#
#   usage: build-warnings.sh <build-log>
#
# Writes `build-warnings.md` beside it: the same list as markdown, for the job summary and for
# the body of that check run.
#
# A warning is only *reported* in debug mode, which is how that stage compiles - outside it the
# same diagnostic is thrown - so a warning never fails the build here either. It is made visible
# instead: the job stays green, `count` drives the neutral check run the workflow publishes next
# to it, and a release is no longer the first thing to notice.
#
# The compiler prints a warning over two lines, the second carrying the location:
#
#   Warning[E3038] : no symbol is resolved through the use of ymirc::lexing::word
#    --> src/ymirc/lint/expander/value/union_.yr:(33,27)
#
# The log is read in order rather than searched: the same message occurs at several places in a
# run - one unused `use` repeated across files reads identically - so a warning is paired with
# the location that follows it, never with the first one matching its text.

set -euo pipefail

log="${1:?usage: build-warnings.sh <build-log>}"

# The log comes from a terminal-less docker build, but gyc colours unconditionally, and an escape
# left in the message would reach the annotation verbatim.
plain="$(mktemp)"
sed -e 's/\x1b\[[0-9;]*m//g' "$log" > "$plain"

# The markdown table, written whether or not anything is appended to it, so a clean build still
# says so in the job summary.
list="$(mktemp)"
count=0

# A warning the compiler emitted without a location still counts and is still annotated - on the
# workflow file, as GitHub places a file-less annotation - rather than being dropped for want of
# somewhere to sit.
emit() {
    local code="$1" message="$2" file="$3" line="$4" col="$5"

    count=$((count + 1))
    if [ -n "$file" ]; then
        printf '::warning file=%s,line=%s,col=%s,title=%s::%s\n' "$file" "$line" "$col" "$code" "$message"
        printf '| `%s` | `%s`:%s | %s |\n' "$code" "$file" "$line" "$message" >> "$list"
    else
        printf '::warning title=%s::%s\n' "$code" "$message"
        printf '| `%s` | | %s |\n' "$code" "$message" >> "$list"
    fi
}

code=""
message=""
pending=0

while IFS= read -r line; do
    if [ "$pending" -eq 1 ]; then
        pending=0
        if [[ "$line" =~ ^[[:space:]]*--\>[[:space:]](.+):\(([0-9]+),([0-9]+)\)$ ]]; then
            emit "$code" "$message" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
            continue
        fi
        emit "$code" "$message" "" "" ""
    fi

    if [[ "$line" == Warning\[* ]]; then
        code="${line#Warning[}"
        code="${code%%]*}"
        message="${line#*] : }"
        pending=1
    fi
done < "$plain"

[ "$pending" -eq 1 ] && emit "$code" "$message" "" "" ""

# The annotations above are capped by GitHub at ten of a kind per step, so the full list is
# written out as well - it is the only place every warning is guaranteed to be readable. It goes
# to a file of its own because the check run published next to the job needs the same text.
{
    if [ "$count" -eq 0 ]; then
        printf '## Compiler warnings\n\nNone.\n'
    else
        printf '## Compiler warnings (%s)\n\n| Code | Where | Message |\n|---|---|---|\n' "$count"
        cat "$list"
    fi
} > build-warnings.md

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    cat build-warnings.md >> "$GITHUB_STEP_SUMMARY"
    printf '\n' >> "$GITHUB_STEP_SUMMARY"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "count=$count" >> "$GITHUB_OUTPUT"
fi

rm -f "$plain" "$list"

echo "$count compiler warning(s)" >&2
