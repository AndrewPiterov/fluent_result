# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`fluent_result` is a published, **pure Dart** library (on pub.dev). It models success/failure as a returned value (`Result` / `ResultOf<T>`) instead of throwing exceptions. Despite the CI using `flutter test`, there is no Flutter dependency — it runs under the plain Dart SDK.

## Commands

```bash
dart pub get                       # install dependencies
dart analyze                       # static analysis / lint (must be clean for CI)
dart test                          # run all tests
dart test test/fold_test.dart      # run a single test file
dart test -n "either left"         # run tests matching a name
dart format .                      # format (CI does not enforce, but keep clean)
```

CI (`.github/workflows/dart.yml`) runs `dart analyze` then `flutter test --coverage` on push/PR to `main`. `dart test` is the equivalent local runner.

## Architecture

**Single barrel + self-import convention.** `lib/fluent_result.dart` re-exports everything in `lib/src/`. Every internal file imports the package through itself — `import 'package:fluent_result/fluent_result.dart';` — rather than via relative paths. Follow this when adding files: export from the barrel and import the barrel.

**Two parallel API surfaces** (both are public and tested — keep them in sync when changing behavior):
- Static constructors/factories on the classes: `Result.success()`, `Result.failWith(...)`, `Result.ok`, `Result.trySync/tryAsync`, `Result.failIf/okIf`, `ResultOf.success(v)`, `ResultOf.failWith(...)`.
- Top-level functions in `lib/src/methods.dart`: `success()`, `successWith(v)`, `fail(reason)`.

**Type hierarchy:**
- `Result` (`lib/src/result.dart`) — base, no value. Holds `List<ResultError>`; exposes `isSuccess/isFail`, `errors`, `error`, `errorMessage` (non-nullable, defaults to `''`), `add/addAll`, typed lookup `contains<T>()` / `get<T>()`, and `fold(onFail, onSuccess)`.
- `ResultOf<T>` (`lib/src/result_of.dart`) extends `Result`, adds a nullable `value`, `foldWithValue`, and `map<U>([converter])`. Note: `failWith`/`fail` return `ResultOf<T?>` (value-less fails are valid), and `map()` on a fail short-circuits to `fail(error)`; on success it **throws** if no converter is given.

**Errors** (`lib/src/errors/`):
- `ResultError(message)` is the base; subclass it for domain errors (see README "Custom errors").
- `ResultException` wraps a Dart `Exception`.
- `ResultError.of(reason)` is the central normalizer: `Exception` → `ResultException`, existing `ResultError` → passthrough, anything else → `ResultError(reason.toString())`. All fail paths funnel through it.

**Global config** (`lib/src/result_config.dart`) — `ResultConfig` is a static singleton holding three swappable hooks:
- `exceptionHandler` — converts a caught `(e, stackTrace)` into a fail `ResultOf`. Used by `trySync`/`tryAsync` and by `failIf`/`okIf`.
- `exceptionHandlerMatchers` — `Map<Type, handler>` keyed by the caught object's `runtimeType`, for mapping third-party errors (e.g. `DioError`) to custom `ResultError`s.
- `logSuccessResult` — success logging hook (uses `package:logger`).
These are mutable global state set during app/test setup; tests mutate them directly.

## Conventions & gotchas

- **Lint is strict** (`analysis_options.yaml` + `package:lint`): `public_member_api_docs: true` means **every public member needs a `///` doc comment** or analysis fails. Also `prefer_single_quotes`, `always_declare_return_types`, and `unawaited_futures`/`missing_return` as errors.
- **`fail` name collision**: this package exports a top-level `fail()` and `package:test` exports `fail()`. Test files that use both import test with `import 'package:test/test.dart' hide fail;`.
- **Two test styles coexist**, pick whichever matches the file you're editing:
  - Plain `package:test` (`test(...)` / `expect(...)`) — e.g. `test/fold_test.dart`.
  - BDD via `given_when_then_unit_test` (`given/when/then/before`) + `shouldly` assertions (`x.should.beTrue()`, `x.should.beOfType<T>()`) — e.g. `test/result_config_custom_matcher_test.dart`.
  - Shared test fixtures (`Customer`, `User`, custom errors) live in `test/helpers.dart`.

## Releasing

Bump `version` in `pubspec.yaml` and add a matching top entry to `CHANGELOG.md` (existing style: `# [x.y.z]` heading + `* [Tag] change` bullets, where Tag is `Add`/`Fix`/`Change`/`Update`). The version line and the latest changelog entry must agree.
