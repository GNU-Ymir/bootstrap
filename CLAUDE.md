# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`ymirc` is the frontend of the Ymir language compiler, self-hosted: it is written in Ymir
and compiled by the `gyc` GCC-based Ymir compiler. It parses Ymir source, performs semantic
validation, and lowers the result to an intermediate language (YIL) for a backend compiler
(GCC). This repo is the bootstrap frontend only — no backend/codegen lives here.

## Pull request titles

PR titles must read `[YMI-XXX][kind] Log` — `YMI-XXX` is the Linear issue, and `[kind]` is
optional and defaults to a feature. Known kinds: `feat`/`feature`, `fix`, `perf`, `refactor`,
`doc(s)`, `test(s)`, `chore`/`ci`/`build`/`style`, `breaking`. This is not cosmetic: the release
notes are generated from these titles by `.github/scripts/changelog.sh`, one entry per merged PR
(the commits inside a PR are never listed), grouped by kind. **A PR whose title does not follow
the format — no issue key, or a kind outside that list — is left out of the release notes
entirely**; the skip is logged on stderr by the release job, but the change goes unannounced.

## Build / run / test

Build system is `gyllir` (config in `gyllir.toml`, compiler path points at a local `gyc` build).

- `gyllir build` → `libymirc.a`. **This project is `type = "library"`** (see `gyllir.toml`), so
  it does *not* link a runnable compiler. Any `./ymirc` binary sitting in the repo root is a
  leftover from an older layout and is almost certainly stale — do not use it to check
  behavior. To run the compiler over a `.yr` snippet, write a test (see below).
- `gyllir test` → builds `./ymirc.test` and runs it. `gyllir test --dry` builds the binary
  without running it, which is what you want before invoking `./ymirc.test` yourself.
  Results are cached in `.ymir_test_success`.
- `gyllir build --release` / `gyllir test --release` for release-mode builds.

### Running tests

```
./ymirc.test -f "integration::<module>::*"
```

- The filter matches the **test module path**, not the resource directory, and the trailing
  `::*` is required. `integration::class_ops::*` works; neither `integration::class_ops` nor
  `integration::class_ops*` matches anything.
- **A filter that matches nothing prints nothing and exits 0.** Empty output means "no test
  ran", never "everything passed". Always confirm you see `[SUCCESS] : integration::<module>…`.
- The module name often differs from the resource directory — e.g. `test_resources/lit_class/operators`
  is registered by `test/integration/class_ops.yr`. Find the owner with
  `grep -rn "<resource-dir>" test/`.
- Golden diffs are written to **stderr** while the test log goes to stdout, so capture them
  separately (`2>err.txt`) and strip ANSI codes (`sed -e 's/\x1b\[[0-9;]*m//g'`) before reading.
- Other flags: `-sf/--stop-first`, `--resume` (re-run only previously-failed tests),
  `-j/--jobs`, `-cov/--coverage`, `-ct/--call-tree`.

### Test layout

Test categories live under `test/integration/`: `test/integration.yr` lists them as
`mod ::<category>;`, each backed by `test/integration/<category>.yr` containing a
`__test { ... }` block. (`test/__test__.yr` only pulls in `integration` and `ymirc_test`.)
Those blocks call, from `test/integration/utils.yr`, either:

- `utils::registerTest("test_resources/<dir>/testN.yr")` — a single case, or
- `utils::registerTests("test_resources/<dir>", lo, hi)` — cases `test<lo>.yr` … `test<hi>.yr`,
  contiguous; each case runs even if an earlier one fails, and all failures are reported together.

Either way, each case:

1. Compiles the given `.yr` file through the real `Parser` pipeline.
2. Compares the result against golden files with the same basename:
   - `testN.stx` — expected formatted dump of the *syntax* tree (`Formatter`-rendered
     `Declaration`), if this file exists. This is the only thing that exercises the
     `Formattable` impls of the syntax nodes, so it is compared whether or not the case
     compiles: the tree is produced by the syntax step, before anything can fail.
     `test_resources/syntax/` is the directory dedicated to it, one case per construct family.
   - `testN.err` — expected formatted `ErrorMsg` output, if compilation is expected to fail.
   - `testN.sem` — expected formatted dump of the semantic generators (`Formatter`-rendered),
     if compilation is expected to succeed.
   - `testN.yil` — expected formatted dump of the expanded YIL nodes/types (only compared if
     this file exists, since not every test needs to check lowering). This is the *raw*
     expander output, whatever the optimization level, so it stays valid when a case is
     optimized.
   - `testN.yil.opt` — the same dump after the optimizer ran. A case carrying this file is
     compiled at `-O1` instead of `-O0`; absent, no pass runs. This is where a pass is
     regression tested, one case per pass under `test_resources/optimizer/`.

If a case has *no* golden file at all, the only assertion is "compilation raised no error" —
and when it does raise one, the full formatted error is printed to stderr. That makes a
golden-less case the way to see what the compiler currently does with a snippet.

Every test compile also runs the YIL verifier (`activateYilVerify()` in `compileFile`), which
checks the well-formedness of every frame after every pass — see below.

When you change validator/semantic behavior, the golden `.sem`/`.err`/`.yil` files are the
source of truth for expected behavior — treat a diff against them as a real regression/fix
signal, not just noise to silence. When behavior intentionally changes, regenerate/update the
corresponding golden file rather than special-casing the test.

### Regenerating a golden file

Truncate the golden to empty, re-run the test, and the whole produced output comes back as
added lines in the diff:

```sh
: > test_resources/<dir>/testN.err
./ymirc.test -f "integration::<module>*" 2>err.txt >/dev/null
sed -e 's/\x1b\[[0-9;]*m//g' err.txt        # every produced line is now "+      | <content>"
```

Strip the `+`/`| ` gutter to rebuild the file, then re-run to confirm `[SUCCESS]`. Truncating
first matters: against a non-empty golden the diff elides unchanged regions as `...`, so you
cannot reconstruct the full file from it. Read the resulting diff before committing it — the
point is to check the new behavior is what you intended, not to make the test go green.

### Creating a temporary throwaway test

To exercise the compiler on an ad-hoc snippet (there is no runnable binary to do it directly):

1. `mkdir test_resources/tmpcheck` and write `test1.yr` … `testN.yr` there, contiguous, one
   case per behavior you want to probe. Write **no** golden files — then a case passes iff it
   compiles, and prints its error to stderr if it doesn't.
2. Create `test/integration/tmpcheck.yr`:
   ```
   in tmpcheck;

   use ymirc::utils::_;
   use utils;

   __test {
       utils::registerTests ("test_resources/tmpcheck", 1, N);
   }
   ```
3. Add `mod ::tmpcheck;` to `test/integration.yr`.
4. `gyllir test --dry` then `./ymirc.test -f "integration::tmpcheck*" 2>err.txt`.

Probe *both* directions of whatever you are testing (the accepted form and the rejected one),
and prefer cases whose outcome is observable in the type system — e.g. give two overloads
different return types and assign the result to a typed variable — so a "compiles" result tells
you which one was selected.

Afterwards, delete `test_resources/tmpcheck/` and `test/integration/tmpcheck.yr`, revert the
`mod ::tmpcheck;` line, and re-run `gyllir test --dry` so the built binary no longer references
the removed module. Verify with `git status` that nothing temporary is left behind.

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

   `lint/optimizer` is the pass pipeline: `Optimizer` (`optimizer/visitor.yr`) applies an
   ordered list of `OptimizerPass`es to every frame — sweeping the whole list again while a
   pass still reports having changed something (`MAX_PIPELINE_ROUNDS`), since the passes feed
   each other in both directions and one sweep leaves work behind: dead code removes the
   copies copy propagation left, and the straight-line runs it makes by folding the jumps are
   runs copy propagation never saw. A round asks whether a pass's counters moved rather than
   resetting them: they are cumulative, and are what `--fopt-stats` reports at the end.
   `optimizer/cfg.yr` builds the per-frame
   control flow graph, and `optimizer/verifier.yr` checks the well-formedness of a frame —
   variables declared, labels defined and unique, affectations moving compatible widths,
   `YILBeginCatch` inside a handler, calls covered by `YILFrame::refs`, non-void frames
   returning. That last one reads the edges, not the blocks: an edge into the exit is
   `EdgeKind::UNWIND` when what leaves the frame is an unwinding resuming past the finally
   part that interrupted it (`cfg.yr`'s unwind copy of a `YILTryFinally`), and a frame left
   that way returns nothing whatever its return type — demanding a return there reports a
   correct frame as malformed. What it can rely on is that a path stops where control
   stops: a call to a function `defuse.yr`'s `runtimeNeverReturns` names (`_yrt_exc_panic`,
   `_yrt_exc_throw`) ends its block on nothing, control reappearing in a handler protecting
   it or nowhere in the frame. That table is the only thing telling YIL a call never comes
   back, so a new runtime helper that aborts or throws belongs in it: left out, it makes the
   graph invent a path leaving it, and every analysis reads that path.
   Verification runs on the raw expander output and again after every pass, so a
   pass is only ever blamed for what it introduced; it is gated by `--fverify-yil` and is
   always on in the test suite. YIL types are looser than they look — pointers, arrays and
   pointer-wide integers are the same address, integer widths are the backend's business —
   so the verifier compares storage classes, not types.

   `optimizer/defuse.yr`, `optimizer/dataflow.yr` and `optimizer/analysis.yr` are the
   dataflow framework the passes consume. `DefUse` says what one instruction reads and
   writes, `dataflow.yr` is a worklist fixpoint solver parameterised by direction and meet,
   and `FrameDataflow` (`analysis.yr`) instantiates it up to three times per frame: liveness
   (backward, union), reaching definitions (forward, union) and available expressions
   (forward, intersection). Only liveness is always solved — it is what `hasFacts` answers
   from; the other two are asked for (`withReaching`/`withAvailable`), since solving one is
   not free and `buildAvailable` alone enumerates every expression of the frame into an
   `ExprTable`. Reading an analysis that was not solved panics rather than answering the empty
   set, which reads as "nothing holds" and is a lie, not a conservative default. It also fills `BasicBlock::getGens()`/`getKills()`, the liveness
   summary of every block. Two things it deliberately gets right, and that a change here must
   keep: an address passed to a runtime function whose signature is in the `runtimeParamModes`
   table is a *definition* when the callee writes the pointee (`_yrt_dup_slice(&YI_4, ...)`)
   and a use when it reads it; and a variable whose address escaped is never killed by
   anything but a direct assignment to it, every unknown call and every store through a
   pointer only *may* write it. A third: an exception edge leaves from the *middle* of the
   instruction closing its block, so what that block contributes on such an edge is its
   `preGen`/`preKill` — the block minus that instruction — never its whole-block sets. A
   forward analysis meets those at the top of the handler (`meetOf`), a backward one
   transfers what the handler needs through them (`transferOf`), which is why a backward
   analysis meets *after* the transfer instead of before: applying the closing instruction's
   kill to what a handler reads reports dead a variable it reads.
   `--fdump-dataflow=<frame>` writes the three analyses per block
   to `<module>.<frame>.dataflow.txt`, naming the temporaries the way the YIL dump does so the
   two can be read side by side. The `.df` goldens under `test_resources/dataflow/` are that
   dump (`test/integration/dataflow.yr`, which also checks the fixpoint equations hold on
   every frame of a sweep of packages, exception edges included).

   `optimizer/copyprop.yr` is the first pass of the pipeline (`copy-prop`, `-O1`). It walks a
   frame forward holding, per variable, the value it is known to hold, and does two things
   with it: it renames a read of `x` to `y` after `x = y` (the copy itself survives until dead
   code elimination lands), and it substitutes a compiler-generated temporary the frame
   assigns once and reads once into that read, deleting the assignment (`YI_2 = a + 9;
   return YI_2;` becomes `return a + 9;`). The environment is dropped at every label, jump and
   handler boundary, so a substituted value is always written earlier on the same straight-line
   run as its use, and dominance holds without a dominator tree. The two ends are not
   necessarily in the same basic block — a call in a try region ends one in the middle of that
   run, and the pass keeps its environment across it — the invariant to check a change against
   is dominance, not same-block. Four rules keep it honest and must survive
   any change: nothing is ever substituted under a `&` (which covers the runtime out
   parameters and the address-taken variables at once), the left of an assignment is storage
   rather than a value and is left alone, only a side-effect-free expression is coalesced
   (no call, no read through a pointer, no indexing, no division), and nothing naming a
   variable outside the frame's universe is moved — a reference to a global symbol carries the
   id `0`, no write to it is ever recorded as a def, so nothing would invalidate a value that
   reads it. A destination and its value
   must also have the same type — YIL types are looser than the backend's, and moving a value
   must not move that difference somewhere unchecked. The pass reruns over a frame while it
   still changes something, since each transformation exposes the other.

   `optimizer/dce.yr` is the second pass (`dead-code`, `-O1`), and the one that makes the
   copies copy-prop leaves behind actually disappear. It does four things per round and
   repeats the round until none of them fires: it deletes the instructions of every block no
   path reaches, it deletes an assignment to a whole variable that is not live afterwards and
   whose right hand side has no effect of its own (`_ = t._1;`), it folds the control flow (a
   conditional jump on a literal or on twice the same label becomes a goto — keeping the
   condition, as the `YILCall` that is what YIL calls a value evaluated as a statement, when
   the frame evaluates it for its effect rather than for the branch — a goto into a
   label that only jumps is retargeted to the end of that chain, a goto into the label right
   after it is dropped, a label nothing names is dropped), and it drops the declaration of
   every variable the body stopped naming. The four feed each other, which is why the round
   repeats: folding a jump orphans a block, deleting a block unnames a label, deleting a store
   unuses a variable.

   Five things it must keep getting right. **A landing pad is a root of reachability**: a
   handler is entered by the personality routine and never by a jump, so `CFG::deadBlocks` —
   not `CFG::unreachableBlocks`, which answers the graph's question and is what the `.dot`
   dump reports — seeds the walk from the entry *and* from every `YILTryCatch`/`YILTryFinally`
   pad. Deciding a pad is dead is YMI-84's job, not this pass's. **A block the pad walk keeps
   alive has no dataflow facts**: the solver runs over `CFG::reversePostOrder()`, which is
   entry-rooted, so a pad protecting a region no path reaches is in the graph, not in the
   solution, and `Solution::inOf`/`outOf` answer it the empty set — "no variable is live",
   which is a lie, not a conservative default. `FrameDataflow::hasFacts` is the question to
   ask before reading the facts of a block, and `dce.yr` skips the dead-store analysis of a
   block that fails it. **The closing instruction of a block does not kill on the exception
   edge**: it is the instruction an exception leaves from the middle of, so the backward walk
   in `markDeadStores` puts back, after transferring it, whatever the handlers protecting the
   block read — the instruction-at-a-time form of the `preGen`/`preKill` sets `transferOf`
   applies on such an edge. Without it, `[x = <pure>, x = <throwing call>]` reports the first
   store dead while the handler is exactly what reads it. **Only a whole variable is
   ever stored-dead**: writing a field or an element leaves the rest alone, and a variable
   whose address escaped is read by things that do not name it, so liveness has nothing to say
   about either. **A read must be rooted in the frame to be removable**: a call, a
   `YILBeginCatch`, a division and a dereference all stay, an index into a real array does
   not. `YILFrame::refs` is deliberately *not* narrowed when an unreachable call goes: the
   dependency files come out wider than needed, which costs a rebuild and never misses one,
   whereas its entries are not only calls (typeinfos, vtables, globals) and dropping one of
   those does go unnoticed. Block layout in reverse post order is not implemented: the YIL
   body is a tree whose `YILTryCatch`/`YILTryFinally` nodes say which region an instruction is
   protected by, so blocks cannot be reordered across them, and the fallthrough that layout
   buys is what dropping the goto into the following label already gives.

   The first two of those five are tested by `test/integration/dead_code.yr`, on frames built
   by hand the way `integration::verifier` builds its own, and for the same reason: no source
   program makes the expander produce either shape. It hoists every call into a temporary
   written once, so a block never closes on a store to a variable a handler reads, and the
   validator rejects every source shape whose protected region cannot throw (`nothing to
   catch`, `failure guard cannot be used when guarding a scope that cannot throw`,
   `unreachable statement`), so a pad is never left out of the solution. Both invariants are
   therefore contracts with the framework rather than properties of anything compiled today —
   a golden cannot state them, and dropping either one leaves the whole corpus green. The
   condition kept across a folded branch is stated there too, and is latent for the same kind
   of reason: the expander hoists every condition into a temporary, and copy propagation only
   ever substitutes a pure value back into one, so the condition of a condjmp is pure in
   everything the pipeline produces.

   The pass is tied back to the tree by an ordinal. `CFG` numbers every instruction of the
   body in preorder as it builds (`BasicBlock::getOrds()`, `NO_ORD` for the jumps the builder
   synthesizes at a fallthrough), the pass decides about ranks on the graph, and the walk
   rewriting the body counts exactly the same way to find the instruction again. A change to
   the order `CFG::visit` walks the body in has to be mirrored in `dce::strip`. One subtree is
   built twice: the finally part of a `YILTryFinally`, once for the region completing normally
   and once for the unwinding leaving it. Every one of those copies is a region of its own, so
   each gets its own map from label id to block — a label is what decides which block an
   instruction lands in, and resolving two copies through one map hands them one block, which
   then holds the same ordinal twice and votes twice on a liveness that merges paths that
   never run together. One map per unwind copy is not enough: a `YILTryFinally` inside another
   one's finally part is built once per copy of the enclosing part, the inner *normal* copy
   included, which is why `visitTryFinally` saves the map and replaces it with an empty one
   around every copy it builds under one. `integration::cfg` states it: no block holds a rank
   twice, over a sweep that includes `scope_guards/test13.yr`, a guard inside a guard's body
   whose own body holds a jump. Both copies are numbered from the same rank and the
   walk resumes past the part at `nbOrdsList(finPart)`, never at wherever a copy left the
   counter — either copy is skipped when nothing reaches it, and a rank counted one copy short
   names another instruction from there on. A rank is therefore reachable from two blocks, and
   removing it removes it from both paths, so a block only *votes* in `markDead`: a rank goes
   when every block carrying it voted, since what the unwinding no longer needs may be exactly
   what the normal path returns.

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
