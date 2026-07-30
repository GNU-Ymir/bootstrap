# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`ymirc` is the frontend of the Ymir language compiler, self-hosted: it is written in Ymir
and compiled by the `gyc` GCC-based Ymir compiler. It parses Ymir source, performs semantic
validation, and lowers the result to an intermediate language (YIL) for a backend compiler
(GCC). This repo is the bootstrap frontend only — no backend/codegen lives here.

## Build / run / test

Build system is `gyllir` (config in `gyllir.toml`, compiler path points at a local `gyc` build).

- Build the compiler: `gyllir build` → produces `./ymirc` in the repo root.
- Run the compiler on a file: `./ymirc <path/to/file.yr>` (prints the syntax dump, then the
  semantic generators, then the expanded YIL nodes, separated by `====...====` lines — see
  `src/main.yr` for the exact driver).
- Run the full self-test suite: `gyllir test` → builds `./ymirc.test` and runs it. Test source
  lives in `test/*.yr`; results are cached in `.ymir_test_success`.
- Run a subset of tests directly against the built test binary:
  `./ymirc.test --filter <substring>` (also supports `-sf/--stop-first`, `--resume` to re-run
  only previously-failed tests, `-cov/--coverage`, `-ct/--call-tree`).
- `gyllir build --release` / `gyllir test --release` for release-mode builds.

### Test layout

Each test category is a module in `test/__test__.yr` (e.g. `mod .scope_guards;`) backed by a
file `test/<category>.yr` containing a `__test { ... }` block. These call
`utils::registerTest("test_resources/<category>/testN.yr")` (see `test/utils.yr`), which:

1. Compiles the given `.yr` file through the real `Parser` pipeline.
2. Compares the result against golden files with the same basename:
   - `testN.err` — expected formatted `ErrorMsg` output, if compilation is expected to fail.
   - `testN.sem` — expected formatted dump of the semantic generators (`Formatter`-rendered),
     if compilation is expected to succeed.
   - `testN.yil` — expected formatted dump of the expanded YIL nodes/types (only compared if
     this file exists, since not every test needs to check lowering).

When you change validator/semantic behavior, the golden `.sem`/`.err`/`.yil` files are the
source of truth for expected behavior — treat a diff against them as a real regression/fix
signal, not just noise to silence. When behavior intentionally changes, regenerate/update the
corresponding golden file rather than special-casing the test.

## Architecture: the pipeline

The whole frontend is orchestrated by `Parser` (`src/ymirc/parser.yr`), in three stages:

1. **Syntax** (`src/ymirc/lexing`, `src/ymirc/syntax`): lexes and parses a root module into a
   `Declaration` tree (`syntax/declaration`) built from `Expression` nodes
   (`syntax/expression`); `syntax/visitor` drives the actual recursive-descent parsing per
   construct (function, class, enum, trait, etc.).

2. **Validation** (`src/ymirc/semantic`): the largest part of the codebase.
   - `semantic/declarator`: declares symbols from the syntax tree into the symbol table.
   - `semantic/symbol`: symbol table entities (modules, classes, enums, templates, etc.).
   - `semantic/validator`: the semantic checker — turns syntax `Expression`s into typed
     `Value`s and enforces language rules. Organized by what's being validated:
     `validator/type`, `validator/value` (further split by expression kind: `control`,
     `operator`, `instruction`, `memory`, `variable`, ...), `validator/symbol`,
     `validator/template_`, `validator/pragma`, and `validator/context` (the
     `ValidationContext` — the single mutable object threaded through validation, tracking
     scopes, current function, scope-guard/unsafe/throw state, etc. — see
     `context.yr`/`context/`).
   - `semantic/generator`: the typed IR produced by validation (`Value`s and `Type`s), split
     into `generator/value`, `generator/type`, `generator/global`. This is what golden `.sem`
     files are a dump of.
   - `semantic/interpret`: the compile-time (CTE) interpreter/reducer that folds constant
     expressions during validation.
   - `semantic/template_`: template (generics) instantiation and resolution.

3. **Expansion / lowering** (`src/ymirc/lint`): lowers semantic generators into `YILNode`s
   (`lint/node`) — desugaring operators, normalizing control flow, scheduling destructors,
   finalizing types (`lint/expander`, `lint/optimizer`), and optionally serializing YIL
   (`lint/serialize`).

Cross-cutting: `src/ymirc/errors` (the `ErrorMsg` type and its pretty-printing/formatting —
this is what both compiler diagnostics and `.err` golden files render through),
`src/ymirc/global` (process-wide compiler state, versions, include dirs, debug/dump flags —
`global::state::resetToDefault()` is called between test compiles to reset this),
`src/ymirc/utils` (bigint/bigfloat, string/formatting helpers, logging).

### Key control-flow/validation invariant worth knowing

Scope guards (`exit`/`success`/`failure` blocks) and `throw`/try-catch interact non-trivially:
a `throw` is only illegal inside a scope-guard body if it can actually escape that body
uncaught. A `throw` inside a nested block that has its own `catch` handling all thrown types
does not count as crossing the guard, even though it's lexically inside one — see
`ValueValidation::validateTryBlock` in `src/ymirc/semantic/validator/value/validate.yr` and the
`THROW_SCOPE_GUARD`/`THROW_SCOPE_GUARD_RETHROW` errors in `validator/errors.yr` for the
distinction. `ValidationContext`'s `_inScopeGuard` flag is per function-frame, not per block, so
this had to be explicitly suspended/restored around caught try-bodies.
