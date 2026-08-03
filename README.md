# ymirc

Ymirc is the frontend of the Ymir language compiler. It is written in Ymir (self-hosted), and
is meant to be used with a backend compiler (such as GCC) to produce final executables.

## Frontend

This frontend provides code verification and generation to a middle-level intermediate
language (YIL). All symbols of the intermediate language can be found in the module
`ymirc::semantic::generator`.

The frontend pipeline has three stages:

1. **Syntax** — lexing and parsing of source files into a syntax tree
   (`ymirc::lexing`, `ymirc::syntax`).
2. **Validation** — symbol declaration, type checking, and semantic validation, producing the
   typed generators (`ymirc::semantic`).
3. **Expansion** — lowering of the validated generators into YIL nodes: operator desugaring,
   control-flow normalization, destructor scheduling, and type finalization
   (`ymirc::lint`).

All three stages are driven by the `Parser` class (`src/ymirc/parser.yr`).

This repository builds as a **library** (`type = "library"` in `gyllir.toml`): `ymirc` is not
itself a standalone compiler executable, but a frontend meant to be linked into a driver that
pairs it with a backend to produce a working `ymir` compiler. `src/main.yr` is just a
placeholder entry point with no real `main`, kept around so the project can also be built as an
executable locally for manual smoke-testing (see below) — that mode is not how the project is
packaged or consumed.

## Requirements

- A working Ymir toolchain, including the [`gyc`](https://github.com/GNU-Ymir) GCC-based
  backend compiler, used to compile this project itself.
- The [`gyllir`](https://github.com/GNU-Ymir) build tool.
- `gmp` and `mpfr` development libraries (used for compile-time arbitrary-precision
  arithmetic).

The path to your local `gyc` binary is configured in `gyllir.toml`.

## Building

```sh
gyllir build
```

This compiles the `ymirc` library.

## Manual smoke-testing

For local, ad-hoc testing, `gyllir.toml`'s `type` can be switched to `"executable"` and
`src/main.yr` filled in with a real `main` that drives a `Parser` over a given file — this
produces a `./ymirc` binary you can run directly:

```sh
./ymirc path/to/file.yr
```

which runs the file through the full pipeline and prints, in order, the parsed syntax tree, the
validated semantic generators, and the expanded YIL nodes. This is a convenience for manual
debugging only; don't rely on `type = "executable"` or a working `src/main.yr` being the
project's normal, committed state — the actual correctness checks are the self-tests below.

## Testing

The project has an extensive self-test suite comparing compiler output against golden files.

```sh
gyllir test
```

This builds and runs `ymirc.test`. To run a subset of tests, or otherwise interact with the
test binary directly:

```sh
./ymirc.test --filter <substring>   # run only tests matching a substring
./ymirc.test --resume               # re-run only tests that failed last time
./ymirc.test --stop-first           # stop at the first failure
```

Each test category lives in `test/<category>.yr` (registered in `test/__test__.yr`) and drives
one or more `.yr` files under `test_resources/<category>/`. A test compiles its source file and
compares the result against golden files sharing the same basename:

- `.err` — expected formatted error, for inputs that should fail to compile.
- `.sem` — expected dump of the validated semantic generators, for inputs that should compile.
- `.yil` — expected dump of the expanded YIL (only checked when this file is present).

## Project layout

```
src/ymirc/
├── lexing/     tokenizing of source files
├── syntax/     parsing into the syntax tree (declarations, expressions, visitors)
├── semantic/   symbol declaration, validation, and typed generators
│   ├── declarator/  symbol declaration from the syntax tree
│   ├── symbol/      symbol table entities
│   ├── validator/   semantic checks (types, values, templates, pragmas, ...)
│   ├── generator/   typed IR (values and types)
│   ├── interpret/   compile-time expression evaluation
│   └── template_/   generics instantiation
├── lint/       lowering to YIL (expansion, optimization, serialization)
├── errors/     diagnostic messages and formatting
├── global/     process-wide compiler state
└── utils/      bigint/bigfloat, formatting, logging helpers

test/            self-test suite sources
test_resources/  inputs and golden output files used by the self-tests
```
