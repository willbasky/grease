# Development

## Build

To build and install from source, you'll need to install:

- GHC 9.4, 9.6, or 9.8
- `cabal-install` 3.6 or later

Follow the instructions on the [Haskell installation page][install-haskell].

[install-haskell]: https://www.haskell.org/downloads/

Then, clone GREASE and its submodules:

```sh
git clone https://github.com/GaloisInc/grease
cd grease
git submodule update --init
```

Then, build with `cabal`:

```sh
cabal build exe:grease
```

## Docker

GREASE also offers a nightly Docker image that gets built after each commit to
the `main` branch. To run GREASE on an input using Docker, run the following

```sh
docker run ghcr.io/galoisinc/grease:nightly <input>
```

GREASE's test suite can also be run through Docker, although it requires
changing the entrypoint to use `grease-tests` instead:

```sh
docker run --entrypoint grease-tests ghcr.io/galoisinc/grease:nightly
```

The Docker image is available for both `amd64` and `arm64` architectures.

## Documentation

Documentation is built with [mdBook]. Install with `cargo` (or with a package
manager):

[mdBook]: https://rust-lang.github.io/mdBook/

```sh
cargo install mdbook
```

Then build the book with:

```sh
cd doc
mdbook build
```

As always, see `--help` for more options.

## Linting

### Generic scripts

We have a few Python scripts in `scripts/lint/` that perform one-off
checks. They generally take some number of paths as arguments, check
`.github/workflows/lint.yml` to see how they are invoked in CI.

### hlint

We treat a small number of hlint warnings as errors in CI. To run hlint locally, try:

```sh
hlint grease{,-aarch32,-ppc,-x86}/src grease-cli/{main,src,tests}
```

### ruff

We lint and format the Python linting scripts with [ruff].

```sh
ruff format scripts/lint
ruff check scripts/lint
```

[ruff]: https://docs.astral.sh/ruff/

### typos

We run [typos] on `doc/` to spell-check the documentation. To run it locally,
try:

```bash
typos doc/
```

[typos]: https://github.com/crate-ci/typos

## Source code

The `grease` source code is split up into a number of smaller libraries, each
residing in its own top-level directory:

* `grease`: This comprises the core of `grease` as a library.
* `grease-aarch32`: This extends the `grease` library with the ability to reason
  about AArch32 binaries.
* `grease-ppc`: This extends the `grease` library with the ability to reason
  about 32-bit and 64-bit PowerPC binaries.
* `grease-x86`: This extends the `grease` library with the ability to reason
  about x86-64 binaries.
* `grease-cli`: This defines a command-line application on top of the library
  code in `grease`.

## Test suite

To run the tests:

```sh
$ cabal test pkg:grease-cli
```

The tests reside in the `grease-cli/tests/` directory. They are automatically
discovered by the test harness based on their file name. They are written using
[Oughta][oughta].

[oughta]: https://github.com/GaloisInc/oughta

We divide the tests into two general categories: (1) tests involving binaries,
and (2) tests involving LLVM bitcode or S-expression files.

### Binary test cases

These test `grease`'s machine code frontend by ingesting binaries. These test
cases are organized into different subdirectories:

1. `prop/`: Tests that exercise particular property assertions (i.e., requirements). This directory has sub-directories for each property supported by grease. Within each property-specific directory, there can be several directories:

    a. `pos/`: "true positives", tests that should trigger (fail) the assertion, and do

    b. `neg/`: "true negatives", tests that should not trigger (pass) the assertion, and don't

    c. `xfail-pos/`: "false positives", i.e., type I error, tests that should not trigger the assertion, but do

    d. `xfail-neg/`: "false negatives", i.e., type II error, tests that should trigger the assertion, but don't

2. `refine/`: Tests that exercise the precondition refinement process but are not particularly relevant to any property assertions. Subdirectories:

    a. `bug/`: tests that encounter an error that grease can't work around that might be a bug

    b. `pos/`: "true positives", tests that have some sufficient precondition for successful execution, and grease finds it

    c. `neg/`: "true negatives", tests that have no sufficient precondition for successful execution, and grease can't find one

    d. `xfail-pos/`: "false positives", i.e., type I error, tests that have no sufficient precondition for successful execution, but grease still "finds" one

    e. `xfail-neg/`: "false negatives", i.e., type II error, tests that have some sufficient precondition for successful execution, but grease can't find it

3. `sanity/`: Tests that exercise earlier or more fundamental parts of `grease`, such as disassembly or machine code semantics. For these tests, we don't particularly care whether `grease` finds a refined precondition. This directory has a few subdirectories:

    a. `pass/`, for tests that don't cause any issues

    b. `xfail-panic/`, for tests that cause unhandled exceptions in `grease`

    c. `xfail-iters/`, for tests that cause unbounded iterations of the refinement loop

`xfail` tests may represent known bugs, or yet-to-be-implemented improvements. In this case, it's helpful to add a comment to the top of the C source file referring to a specific issue that describes the bug or feature, and to additionally provide a short synopsis of that issue. `xfail` tests may also represent fundamental limitations of the tool's architecture or design that are not expected to be fixed, in which case the comment should instead describe this limitation (or point to documentation that does).

To add a new test, add a new directory under the appropriate directory above. It should contain at least one of the following executables:

- A 32-bit ARM ELF executable named `test.armv7l.elf`
- A 32-bit PowerPC ELF executable named `test.ppc32.elf`. (At the moment, we don't include 64-bit PowerPC executables, but we could if the need arose.)
- An x86_64 executable named `test.x64.elf`.

### LLVM bitcode and S-expression test cases

Test cases that do not involve binaries fall into this category. They are
organized into different subdirectories:

1. `llvm/`: LLVM CFGs (via crucible-llvm-syntax). Each of these test cases has
   the file extension `*.llvm.cbl`.

2. `llvm-bc/`: LLVM bitcode files (via `grease`'s LLVM frontend). Each of these
   test cases has the file extension `*.bc`.

3. `arm`: AArch32 machine-code CFGs (via `macaw-aarch32-syntax`). Each of these
   test cases has the file extension `*.armv7l.cbl`.

4. `ppc32`: PPC32 machine-code CFGs (via `macaw-ppc-syntax`). Each of these test
   cases has the file extension `*.ppc32.cbl`.

5. `x86`: x86-64 machine-code CFGs (via `macaw-x86-syntax`). Each of these test
   cases has the file extension `*.x64.cbl`.

### Lua API

The test harness provides the following Lua API, which enriches that of Oughta
with GREASE-specific functionality. The API is presented with Haskell-style
type signatures:

- `prog`: The name of the program under test, e.g., `"test.llvm.cbl"`.
- `go(prog_name)`: Run GREASE with the given string as the name of the program.
  Frequently, `prog` is passed as the argument, e.g., `go(prog)`. `go` may be
  called multiple times per test, see `func-ptr.llvm.cbl` for an example.
- `flags(fs)`: Append the given flags to the arguments passed to GREASE when
  `go` is invoked. The flags are cleared after `go` is run.

It is common (though not necessary) to define a function named `test` and to
specify it as the only entrypoint:
```c
// all: flags {"--symbol", "test"}
// all: go(prog)

void test(/* ... */) { /* ... */ }
```

### Writing good tests

The Rust Compiler Development Guide has some [helpful guidance] on writing
high-quality tests. The GREASE test suite is generally quite similar in
structure to that of rustc, so almost all of the advice there applies *mutatis
mutandis*.

[helpful guidance]: (https://github.com/rust-lang/rust/blob/3350c1eb3fd8fe1bee1ed4c76944d707bd256876/src/doc/rustc-dev-guide/src/tests/best-practices.md)

<!-- Copyright (c) Galois, Inc. 2024. -->
