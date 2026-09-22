# syntax=docker/dockerfile:1

# Nothing in the Ymir toolchain is built from source here, everything is downloaded as a
# prebuilt release asset, but the stdlib sources, taken from a git tag:
#   - `gyc`, the GCC-based Ymir compiler ymirc is compiled with (github.com/GNU-Ymir/gymir),
#   - `gyllir`, the build tool driving it (github.com/GNU-Ymir/Gyllir),
#   - the `midgard` standard library sources the test suite compiles against
#     (github.com/GNU-Ymir/yruntime).
# The build-args below have no default on purpose - YMIR_VERSION at the repo root is the single
# source of truth, and every CI workflow computes them from it. To build locally:
#   . ./YMIR_VERSION
#   GCC_MAJOR=$(echo "$GCC_VERSION" | cut -d. -f1)
#   docker build \
#     --build-arg GYC_RELEASE_TAG="$YMIR_BOOTSTRAP_VERSION" \
#     --build-arg GYC_ASSET="gyc-${GCC_MAJOR}_${YMIR_BOOTSTRAP_VERSION}_amd64.deb" \
#     --build-arg GYLLIR_RELEASE_TAG="${GYLLIR_VERSION}" \
#     --build-arg GYLLIR_ASSET="gyllir_${GYLLIR_VERSION}_amd64.deb" \
#     --build-arg MIDGARD_TAG="${MIDGARD_VERSION}" \
#     .
ARG GYC_RELEASE_TAG
ARG GYC_ASSET
ARG GYLLIR_RELEASE_TAG
ARG GYLLIR_ASSET
ARG MIDGARD_TAG

FROM ubuntu:26.04 AS toolchain
ARG GYC_RELEASE_TAG
ARG GYC_ASSET
ARG GYLLIR_RELEASE_TAG
ARG GYLLIR_ASSET
ARG MIDGARD_TAG
ENV DEBIAN_FRONTEND=noninteractive

RUN test -n "$GYC_RELEASE_TAG" && test -n "$GYC_ASSET" \
    && test -n "$GYLLIR_RELEASE_TAG" && test -n "$GYLLIR_ASSET" \
    && test -n "$MIDGARD_TAG" || \
    (echo "GYC_RELEASE_TAG, GYC_ASSET, GYLLIR_RELEASE_TAG, GYLLIR_ASSET and MIDGARD_TAG build-args are required - see YMIR_VERSION" >&2 && exit 1)

# gmp/mpfr are the compile-time arbitrary-precision arithmetic libraries ymirc links against
# (`libraries = ["gmp", "mpfr"]` in gyllir.toml). zip is only needed by the `package` stage
# (bundling the golden .yil files below), but installed here since this layer is shared/cached.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git unzip zip libgmp-dev libmpfr-dev \
    && rm -rf /var/lib/apt/lists/*

# The gyc .deb depends on g++-<N>/gcc-<N>/libgc-dev/libdwarf-dev; `apt-get install ./file.deb`
# resolves those from the archive instead of a manual dpkg -i + apt --fix-broken dance.
RUN curl -fsSL -o /tmp/gyc.deb \
        "https://github.com/GNU-Ymir/gymir/releases/download/${GYC_RELEASE_TAG}/${GYC_ASSET}" \
    && curl -fsSL -o /tmp/gyllir.deb \
        "https://github.com/GNU-Ymir/Gyllir/releases/download/${GYLLIR_RELEASE_TAG}/${GYLLIR_ASSET}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/gyc.deb /tmp/gyllir.deb \
    && rm -f /tmp/gyc.deb /tmp/gyllir.deb \
    && rm -rf /var/lib/apt/lists/*

RUN gyc --version && command -v gyllir

# The stdlib sources the *test suite* needs: every test_resources/*.yr compiled through ymirc
# loads the external package from <prefix>/include/ymir/<version> (see
# ymirc::global::state), i.e. the `midgard/` directory of the yruntime tree at MIDGARD_TAG.
# Staged version-agnostically here so the download stays cached; the build stage below links
# it under the exact version ymirc asks for.
RUN mkdir -p /tmp/midgard-src /opt/ymir-stdlib \
    && curl -fsSL "https://github.com/GNU-Ymir/yruntime/archive/refs/tags/${MIDGARD_TAG}.tar.gz" \
       | tar -xz -C /tmp/midgard-src --strip-components=1 \
    && cp -r /tmp/midgard-src/midgard/. /opt/ymir-stdlib/ \
    && rm -rf /tmp/midgard-src

# Compiles libymirc.a (debug) and, with `test --dry`, the ./ymirc.test unittest executable
# without running it - the `test` stage below (and the CI workflow, which needs to tee the
# output) are what actually run it.
FROM toolchain AS build
WORKDIR /bootstrap
COPY . .

# Read from YMIR_VERSION rather than from the MIDGARD_VERSION constant it is rewritten into:
# tools/set-version.sh does that rewrite as a pre-build command, so common.yr still carries the
# previous value here and linking from it would install the stdlib under the wrong version.
RUN YMIR_STDLIB_VERSION="$(sed -nE 's/^MIDGARD_VERSION=([0-9]+\.[0-9]+).*/\1/p' YMIR_VERSION)" \
    && test -n "$YMIR_STDLIB_VERSION" || \
       (echo "could not read MIDGARD_VERSION from YMIR_VERSION" >&2 && exit 1) \
    && mkdir -p /usr/include/ymir \
    && ln -sfn /opt/ymir-stdlib "/usr/include/ymir/${YMIR_STDLIB_VERSION}"

# The compiler output is kept in the image rather than only in the build log: a warning is
# non-fatal in debug, which is how this stage compiles, so CI has to read them back afterwards -
# and it must still see them when this layer comes from the cache and prints nothing.
RUN bash -o pipefail -c 'gyllir test --dry -j 12 2>&1 | tee build.log'

FROM build AS test
RUN ./ymirc.test -sf

# Depends on `test` (not `build`) so a release artifact can never be produced from a tree whose
# tests fail. `gyllir build --release` rewrites ./libymirc.a in place, hence the debug copy
# being stashed first.
#
# Also bundles the .yil files produced by the release build under .target/release/yils/ into a
# zip. These are build output (the expanded-YIL dumps for every module of the compiler itself),
# and let downstream consumers build ymirc without needing the Ymir source.
FROM test AS package
RUN gyllir build --release -j 12 \
    && cp libymirc.a /libymirc_release.a \
    && find .target/ymirc/release/yils -name '*.yil' -print | zip -q -j /ymirc_yil.zip -@
