#! /bin/sh
#
# Builds a gyllir project in a scratch copy with the Boehm GC statistics on,
# and prints what the build allocated: the number of collections, the bytes
# allocated, the time spent collecting and the peak heap of a compiler process,
# next to the user CPU time of the whole build.
#
# Usage:
#   tools/gc-stats.sh [--release] [-j N] [--gyc COMPILER] [-C DIR] [-t TARGET] [REV]
#
# The project is the repo holding DIR, this one by default, and TARGET the one
# of its targets to build, the default one of `gyllir build` otherwise. With
# REV, the tree of that revision is built, otherwise the working tree,
# uncommitted changes included. The build never touches the project's own
# .target/, so it is always a full build, and it does not invalidate the
# incremental one. -j is the number of compiler processes gyllir runs (4 by
# default): each one reloads the modules its batch imports, so two
# measurements only compare under the same -j.
#
# The tree is compiled by COMPILER, gyllir.toml's own by default, so what is
# measured is the frontend of COMPILER, not the one of the tree: a frontend
# change is measured by building the ymir-dev preview on each side of it, and
# passing it (`--gyc ymirc`) with the same project, REV and -j.
#
# Every compiler process logs to a file of its own, and the numbers are sums
# over those processes, the peak heap excepted, which is the largest one.
# Boehm only reports what was allocated when it collects or grows the heap, so
# the allocation after the last of those events of a process is not counted.
set -e

MODE=
NAME=debug
JOBS=4
GYC=
DIR=.
TARGET=
REV=
while [ $# -gt 0 ]; do
    case "$1" in
        --release) MODE=--release; NAME=release ;;
        -j) shift; JOBS=$1 ;;
        --gyc) shift; GYC=$1 ;;
        -C) shift; DIR=$1 ;;
        -t) shift; TARGET=$1 ;;
        -h|--help) sed -n '3,/^set -e/p' "$0" | sed -n 's/^# \{0,1\}//p'; exit 0 ;;
        *) REV=$1 ;;
    esac
    shift
done

ROOT=$(git -C "$DIR" rev-parse --show-toplevel)
WORK=$(mktemp -d "${TMPDIR:-/tmp}/gc-stats.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

cd "$ROOT"
if [ -n "$REV" ]; then
    git archive "$REV" | tar -x -C "$WORK"
else
    git ls-files -z -co --exclude-standard | tar --null -T - --ignore-failed-read -c 2>/dev/null | tar -x -C "$WORK"
fi

GYC=$(command -v "${GYC:-$(sed -nE '/^\[/q; s/^compiler = "(.*)"/\1/p' gyllir.toml)}") || {
    echo "gc-stats: no compiler to build with" >&2
    exit 1
}

mkdir "$WORK/.gc"
cat > "$WORK/.gc/compiler" <<EOF
#! /bin/sh
GC_PRINT_STATS=1 GC_LOG_FILE="$WORK/.gc/\$\$.log" exec "$GYC" "\$@"
EOF
chmod +x "$WORK/.gc/compiler"
sed -i -E "s|^compiler = \".*\"|compiler = \"$WORK/.gc/compiler\"|" "$WORK/gyllir.toml"

cd "$WORK"
if ! /usr/bin/time -f "%U" -o "$WORK/.gc/cpu" gyllir build $TARGET $MODE --j "$JOBS" > "$WORK/.gc/build.txt" 2>&1; then
    cat "$WORK/.gc/build.txt" >&2
    echo "gc-stats: the build failed" >&2
    exit 1
fi

echo "$(basename "$ROOT")${TARGET:+ ($TARGET)} at ${REV:-the working tree}, $NAME build, $JOBS jobs, compiled by $GYC"
awk -v cpu="$(cat "$WORK/.gc/cpu")" '
    FNR == 1 { flush(); procs++ }
    /^--> Marking for collection/ { collections++; allocated += $(NF - 2); tail = 0 }
    /^Grow heap to/ { tail = $(NF - 2); if ($4 > peak) peak = $4 }
    /^GC #[0-9]+ freed/ { if ($7 > peak) peak = $7 }
    /^Complete collection took/ { gc += $4 / 1000 + $6 / 1e9 }
    function flush() { allocated += tail; tail = 0 }
    END {
        flush()
        printf "processes:    %d\n", procs
        printf "collections:  %d\n", collections
        printf "allocated:    %.2f GB\n", allocated / 1e9
        printf "gc time:      %.1f s\n", gc
        printf "user cpu:     %.1f s (%.0f%% in gc)\n", cpu, (cpu > 0 ? 100 * gc / cpu : 0)
        printf "peak heap:    %.2f GB\n", peak * 1024 / 1e9
    }' "$WORK"/.gc/*.log
