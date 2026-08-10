#!/usr/bin/env bash
# Prints the package version, read from the top-level `version` key of gyllir.toml - the single
# source of truth for it. Used by the release workflows so they cannot drift on how the value is
# parsed.
set -euo pipefail

TOML="${1:-gyllir.toml}"

# Only the keys above the first [table] header are top-level, so a `version` inside e.g.
# [dependencies.foo] is never picked up by mistake.
VERSION="$(awk '
  /^[[:space:]]*\[/ { exit }
  /^[[:space:]]*version[[:space:]]*=/ {
    if (match($0, /"[^"]*"/)) { print substr($0, RSTART + 1, RLENGTH - 2) }
    exit
  }
' "$TOML")"

if [ -z "$VERSION" ]; then
  echo "No top-level 'version = \"...\"' key found in ${TOML}" >&2
  exit 1
fi

echo "$VERSION"
