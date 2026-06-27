# fluent_result 8.5.0 — Observability Seam, Ergonomics & Cleanup

**Date:** 2026-06-27
**Status:** Approved design — ready for implementation plan
**Release:** 8.5.0 (minor, **fully additive / non-breaking**)
**Predecessor:** 8.4.1 (correctness patch — C2/C3/C4)
**Successor (out of scope):** 9.0.0 (Dart 3 sealed rewrite)

## 1. Motivation

The driving goal is **clean crash-reporting (e.g. Sentry) integration**. Today the only extension seam, `ResultConfig.exceptionHandler(dynamic e, StackTrace? st)`, is overloaded for two opposite jobs:

1. **Caught exceptions** — `trySync`/`tryAsync` pass a real exception + stack (*unexpected*).
2. **Validation failures** — `failIf`/`okIf` pass a deliberate reason with `st == null` (*expected*).

Because both flow through one hook, wiring Sentry into it reports every validation failure as a crash (**O1**), while the no-override default only does a DEBUG-level log that is stripped in release, so real crashes silently vanish (**O3**). Secondary debt: a forced `logger` dependency for two log lines (**D1**), exact-`runtimeType` matcher dispatch (**O4**), no test-reset for global config (**O6**), a thin combinator surface, and pub.dev hygiene gaps.

8.5.0 fixes the observability model and rounds out the ergonomics **without breaking any existing consumer**. The breaking redesign (sealed `Success`/`Failure`, value-equality, immutable error bag) stays in 9.0.0.

## 2. Goals / Non-goals

**Goals**
- Separate the **validation path** (never reported) from the **caught-exception path** (reported once).
- Add a dependency-free, no-op-by-default `onException(error, stack)` report hook — the single place to wire Sentry.
- Subtype-aware matchers with an `expected` flag so control-flow exceptions (offline, cancel, 404) never reach the report hook.
- Round out combinators (`flatMap`, `match`, `recover`, `mapError`, `valueOr`, `guard`) and stack-aware error handling.
- Drop the `logger` and `quiver` dependencies; improve pub.dev hygiene.
- **Zero breakage:** every public symbol and documented usage from 8.4.x keeps working, old config API kept as `@Deprecated` aliases.

**Non-goals (deferred to 9.0.0)**
- Sealed `Success`/`Failure` union; non-null `Success.value`.
- `ResultOf` value-equality (C1); immutable `add`/`addAll` (C5).
- Splitting `map` into `map`/`castFailure` (A6); typed error hierarchy with `code`/`cause` (A11).
- `A3` plain-`bool` `failIf`/`okIf` — **dropped** (Dart has no overloading; parallel names add surface for marginal value).
- `andThen` alias for `flatMap` — **dropped** (redundant).

## 3. Decisions (locked)

| # | Decision | Choice |
|---|----------|--------|
| Scope | How much in 8.5.0 | **Full report 8.5.0**: observability + ergonomics + dep cleanup + hygiene |
| O8 | `onException` vs per-call `onError` | **Always report unexpected** — `onException` fires for every unexpected caught exception even when `onError` is supplied; only matcher-`expected` exceptions and validation failures are suppressed |
| Report vs build | Architecture | **Decoupled** — `reportUnexpected` (fires `onException` once) is separate from `buildFailResult`, so legacy custom handlers keep working *and* gain reporting, with no double-report |
| Default `onException` | Out-of-the-box behavior | **No-op** (silent). The failure is already in the returned `Result`; a Result library should not force logging. Removes the old DEBUG-log-of-failures behavior (deliberate, non-breaking) |
| collection dep | Keep or drop | **Keep** (first-party, lightweight; used by matchers + `ListEquality`) |

## 4. Section 1 — Observability seam + backward-compat bridge

### 4.1 New `ResultConfig` surface (additive)

```dart
class ResultConfig {
  // ---- caught-exception path (UNEXPECTED, reported once) ----
  /// Report hook for unexpected caught exceptions. No-op by default.
  /// Wire your crash reporter here (e.g. Sentry.captureException).
  static void Function(Object error, StackTrace? stack) onException = (_, __) {};

  /// Optional success telemetry. No-op by default.
  static void Function(Result result) onSuccess = (_) {};

  /// Ordered, subtype-aware matchers. First match wins. Empty by default.
  static List<ResultMatcher> matchers = [];

  // ---- validation path (EXPECTED, never reported) ----
  /// Pure builder used by failIf/okIf. Never reports, never logs.
  static ResultOf<dynamic> Function(Object reason) failBuilder = (r) => fail(r);

  /// Restore every hook/matcher to defaults. Call in test tearDown.
  static void reset();

  // ---- DEPRECATED but fully functional (bridged) ----
  @Deprecated('Use matchers + onException instead')
  static ResultOf<dynamic> Function(dynamic e, StackTrace? st) exceptionHandler = _legacyDefault;

  @Deprecated('Use matchers instead')
  static Map<Type, ResultOf Function(dynamic e, StackTrace? st)> exceptionHandlerMatchers = {};

  @Deprecated('Use onSuccess instead')
  static void Function(Result result) logSuccessResult; // forwards to onSuccess
}

/// A subtype-aware matcher: classify a caught error, build its fail Result,
/// and declare whether it is EXPECTED (suppresses crash reporting).
class ResultMatcher {
  const ResultMatcher(this.test, this.build, {this.expected = false});

  /// e.g. (e) => e is DioException
  final bool Function(Object error) test;

  /// Build the fail Result for a matched error.
  final ResultOf<dynamic> Function(Object error, StackTrace? stack) build;

  /// When true, this is expected control flow (offline/cancel/404);
  /// onException is NOT invoked for it.
  final bool expected;
}
```

### 4.2 Catch-block flow (all four `trySync`/`tryAsync`)

```dart
} catch (e, st) {
  ResultConfig.reportUnexpected(e, st);          // onException ONCE unless a matcher flags expected
  if (onErrorWithStack != null) return onErrorWithStack(e, st);
  if (onError != null) return onError(e);        // legacy mapper still BUILDS the Result
  return ResultConfig.buildFailResult(e, st);    // build only; does NOT re-report
} finally {
  _guardFinally(onFinally);                       // O10: a throwing onFinally cannot escape
}
```

Internal helpers on `ResultConfig`:

- `reportUnexpected(e, st)` → `if (!_isExpected(e)) _safeReport(e, st);`
  - `_isExpected(e)` = any `matchers` entry where `test(e) && expected`.
  - `_safeReport` wraps `onException` in try/catch so a throwing reporter can never mask the original error.
- `buildFailResult(e, st)` precedence:
  1. If `exceptionHandler` was overridden by the consumer (`!identical(exceptionHandler, _legacyDefault)`) → delegate to it (legacy full-control path).
  2. Else first matching `matchers` entry → `build(e, st)`.
  3. Else legacy `exceptionHandlerMatchers[e.runtimeType]` → that closure (backward-compat Map).
  4. Else `failBuilder(e)`.

### 4.3 Validation path

`Result.failIf` / `Result.okIf` route through `ResultConfig.failBuilder(reason)` instead of `exceptionHandler`. This **fixes O1**: validation failures never reach `onException`/Sentry.

### 4.4 Why this is non-breaking

- `result_config_test.dart` sets `exceptionHandler` → still honored verbatim via precedence rule 1; `reportUnexpected` additionally fires (`onException` is no-op unless the consumer set it).
- `result_config_custom_matcher_test.dart` + README set `exceptionHandlerMatchers` (Map, `DioError extends Error`) → honored via precedence rule 3, matched by `runtimeType` exactly as today.
- `onError`/`onFinally` per-call params unchanged; `onErrorWithStack` is additive and wins only when supplied.
- Default `onException` no-op + `logger` removed → the only observable default change is that caught failures are no longer DEBUG-logged. Acceptable in a minor (less output, no API change).

### 4.5 Sentry wiring (target consumer experience)

```dart
void configureResultObservability() {
  ResultConfig.onException = Sentry.captureException;       // unexpected → reported once
  ResultConfig.matchers = [
    ResultMatcher((e) => e is SocketException, (e, st) => fail(e), expected: true), // offline: quiet
    ResultMatcher((e) => e is CancelledException, (e, st) => fail(e), expected: true),
    ResultMatcher((e) => e is Exception, (e, st) => fail(e)),  // catch-all last, reported
  ];
}
// Result.failIf(() => name.isEmpty, 'Name required') → never reaches Sentry, by construction.
```

## 5. Section 2 — Ergonomics & combinators (additive)

On `ResultOf<T>` (and `Result` where value-free), reusing the 8.4.1 `_successValue()` guard.

```dart
// chain success → another Result (errors pass through on fail)
ResultOf<U?> flatMap<U>(ResultOf<U?> Function(T value) next);
Future<ResultOf<U?>> flatMapAsync<U>(Future<ResultOf<U?>> Function(T value) next);

// value-returning counterpart to the void fold/foldWithValue
R match<R>({required R Function(List<ResultError> errors) onFail, required R Function(T value) onSuccess});

// extract with fallback (eager + lazy)
T valueOr(T fallback);
T getOrElse(T Function() orElse);

// turn a fail into a recovered success
ResultOf<T?> recover(T Function(List<ResultError> errors) recovery);

// transform the error side
ResultOf<T?> mapError(ResultError Function(ResultError error) transform);

// wrap a PLAIN value-returning body (vs today's try* which needs a pre-lifted Result)
static ResultOf<T?> guard<T>(
  T Function() body, {
  ResultOf<T?> Function(Object e, StackTrace st)? onError,
  void Function()? onFinally,
});
static Future<ResultOf<T?>> guardAsync<T>(
  Future<T> Function() body, {
  ResultOf<T?> Function(Object e, StackTrace st)? onError,
  void Function()? onFinally,
});
```

**Stack-aware error handler (A9/O8):** add `onErrorWithStack: Result Function(Object e, StackTrace st)?` to all four `try*`. When both `onError` and `onErrorWithStack` are passed, `onErrorWithStack` wins.

**Return-type tightening (T2):** `fail` / `failWith` return `ResultOf<T>` instead of `ResultOf<T?>` (`successWith`/`ResultOf.success` already return `ResultOf<T>`). Non-breaking via covariance (`ResultOf<T>` is-a `ResultOf<T?>`); proven against the full suite during implementation.

**`guard`/`guardAsync` route through the same catch-block flow** as `trySync`/`tryAsync` (Section 4.2), so reporting and matchers apply uniformly.

## 6. Section 3 — Dependency cleanup & pub.dev hygiene

**Dependencies**
- Remove **`logger`** (D1) — the `_logger.d` calls become the no-op `onException`/`onSuccess` hooks.
- Remove **`quiver`** (D2) — `hash2(isSuccess.hashCode, hashObjects(_errors))` → `Object.hash(isSuccess, Object.hashAll(_errors))` (supersedes the 8.4.1 `hashObjects` use; identical behavior).
- Keep **`collection`** (D3).
- Raise SDK floor **`>=2.12.0` → `>=2.17.0`** (D6), still `< 4.0.0`. Unlocks `Object.hash`/`Object.hashAll`.

**pub.dev hygiene**
- Add **`example/example.dart`** (D4) — runnable: success/fail, `trySync` + a matcher, `match`, a custom `ResultError`.
- Fill the ~15 empty `///` stubs and convert the `<summary>` XML on `map` to dartdoc prose (D5). New members documented as written.
- Add **`topics: [result, error-handling, functional, either]`**, `repository:`, `issue_tracker:` to `pubspec.yaml` (D10).
- Fix the dead `badges.bar` likes badge in the README and the wrong `description` ("FluentResults" → correct name) (D11).

## 7. Testing strategy

New/updated tests (BDD `given_when_then` + `shouldly`, or plain `package:test`, matching neighboring files). Every test calls `ResultConfig.reset()` in `tearDown` to kill cross-test pollution (O6).

- **Observability seam:** `onException` fires exactly once for an unexpected exception; fires even when `onError`/`onErrorWithStack`/legacy `exceptionHandler` is supplied; does NOT fire for a matcher-`expected` exception; does NOT fire for `failIf`/`okIf`; a throwing `onException` does not escape `try*`.
- **Matchers:** subtype dispatch (`e is T`, not exact type); first-match-wins ordering; `expected` suppression; legacy `exceptionHandlerMatchers` Map still dispatched by `runtimeType`.
- **Backward-compat (regression):** all existing config tests pass unchanged; deprecated aliases still function.
- **Combinators:** `flatMap`/`flatMapAsync` chain + error passthrough; `match` value return on both branches; `valueOr`/`getOrElse`; `recover`; `mapError`; `guard`/`guardAsync` success + throw routing.
- **Deps/floor:** `dart analyze` clean; `dart pub publish --dry-run` 0 warnings; hashCode contract still holds with `Object.hash`.

## 8. Backward-compatibility checklist (must all stay green)

- [ ] `ResultConfig.exceptionHandler = ...` honored (build path).
- [ ] `ResultConfig.exceptionHandlerMatchers = { DioError: (e, st) => ... }` honored (README example).
- [ ] `ResultConfig.logSuccessResult` still settable (alias to `onSuccess`).
- [ ] `trySync/tryAsync(onError:, onFinally:)` unchanged.
- [ ] No public symbol removed or signature narrowed.
- [ ] Full 8.4.1 suite (74 tests) passes unchanged.

## 9. Release mechanics

- Bump `pubspec.yaml` → `8.5.0`; raise SDK floor to `>=2.17.0`; drop `logger`/`quiver`; add `topics`/repo metadata; fix description.
- `CHANGELOG.md` → `# [8.5.0]` entry grouped: `[Add]` observability seam + combinators, `[Change]` deprecations + SDK floor, `[Remove]` `logger`/`quiver` deps, `[Docs]` example + dartdoc.
- Update README: deprecate old matcher example, document `onException` + `ResultMatcher`, add combinators section, fix badge/description.
- Verify: `dart analyze` (exit 0), `dart test` (all green), `dart pub publish --dry-run` (0 warnings). Then commit, tag `v8.5.0`, GitHub release, publish.
