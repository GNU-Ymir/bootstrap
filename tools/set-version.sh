#! /bin/sh
#
# Rewrites the version placeholders in src/ymirc/global/common.yr from the
# repo's own version sources, so they never have to be hand-edited in sync:
#
#   - __YMIR_VERSION__ <- gyllir.toml's own `version` (this ymirc release)
#   - MIDGARD_VERSION  <- YMIR_VERSION's MIDGARD_VERSION (the midgard release
#     this ymirc release looks up under include/ymir/<major.minor>)
#
# Both are truncated to major.minor, matching the directory/lib-name
# convention used by midgard's own CMakeLists.txt and the CD_suite packaging
# job. Run automatically as a pre-build command, see gyllir.toml.
set -e

YMIR_VERSION_SHORT=$(sed -nE 's/^version = "([0-9]+\.[0-9]+).*/\1/p' gyllir.toml)
MIDGARD_VERSION_SHORT=$(sed -nE 's/^MIDGARD_VERSION=([0-9]+\.[0-9]+).*/\1/p' YMIR_VERSION)

test -n "$YMIR_VERSION_SHORT" || { echo "set-version: could not read 'version' from gyllir.toml" >&2; exit 1; }
test -n "$MIDGARD_VERSION_SHORT" || { echo "set-version: could not read MIDGARD_VERSION from YMIR_VERSION" >&2; exit 1; }

# Written through a temporary file and moved back only when the content really
# changed: 'sed -i' rewrites the file unconditionally, and since this runs as a
# pre-build command that would bump common.yr's mtime at every build, making
# gyllir recompile it (and everything importing it) even on an untouched tree.
COMMON=src/ymirc/global/common.yr
TMP=$(mktemp "${COMMON}.XXXXXX")
trap 'rm -f "$TMP"' EXIT

sed -E \
    -e "s/^pub lazy __YMIR_VERSION__ = \"[^\"]*\";/pub lazy __YMIR_VERSION__ = \"$YMIR_VERSION_SHORT\";/" \
    -e "s/^pub lazy MIDGARD_VERSION = \"[^\"]*\";/pub lazy MIDGARD_VERSION = \"$MIDGARD_VERSION_SHORT\";/" \
    "$COMMON" > "$TMP"

if ! cmp -s "$TMP" "$COMMON"; then
    cat "$TMP" > "$COMMON"
fi

# echo "set-version: __YMIR_VERSION__=$YMIR_VERSION_SHORT MIDGARD_VERSION=$MIDGARD_VERSION_SHORT"
