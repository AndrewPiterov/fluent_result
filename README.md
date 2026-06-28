# fluent_result

[![pub package](https://img.shields.io/pub/v/fluent_result.svg?label=fluent_result&color=blue)](https://pub.dev/packages/fluent_result)
[![likes](https://img.shields.io/pub/likes/fluent_result)](https://pub.dev/packages/fluent_result/score)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
[![Dart](https://github.com/AndrewPiterov/fluent_result/actions/workflows/dart.yml/badge.svg)](https://github.com/AndrewPiterov/fluent_result/actions/workflows/dart.yml)

`fluent_result` returns a value describing the success or failure of an operation instead of throwing. Since **9.0.0** the core is a **Dart 3 sealed** `Result<T>` — `Ok<T>` (with a non-null value) or `Err<T>` (with a single `ResultError`) — so the compiler enforces exhaustive handling and success values are never null.

- A sealed `Result<T>` with `Ok<T>` / `Err<T>` and exhaustive `switch`.
- A **non-null** `Ok.value` — no more `value!`.
- A global `onException` seam to wire crash reporting (e.g. Sentry) in one place.
- Zero runtime dependencies; SDK `>=3.0.0`.

> Migrating from 8.x? See [Migration (8.5 → 9.0)](#migration-85--90) at the bottom.

## Creating a result

```dart
Result<void> ok = success();          // value-free success (Result<void>)
Result<int> okValue = successWith(7); // success carrying a value
Result<int> failed = fail('boom');    // failure from any Object / Exception / ResultError

// The variants are also constructible directly:
Result<int> a = Ok(7);
Result<int> b = Err(ResultError('boom'));
```

## Consuming a result

Pattern-match exhaustively (the compiler requires both arms):

```dart
final label = switch (result) {
  Ok(:final value) => 'ok: $value',          // value is non-null
  Err(:final error) => 'failed: ${error.message}',
};
```

Or use the convenience accessors / combinators:

```dart
result.isSuccess;          // / isFail
result.valueOrNull;        // T? — null on Err
result.error;              // ResultError? — null on Ok
result.errorMessage;       // '' on Ok

result.valueOr(0);                   // value, or a fallback
result.getOrElse((e) => 0);          // value, or compute from the error
result.fold((v) => '$v', (e) => e.message);          // collapse to one value
result.match(onOk: (v) => '$v', onErr: (e) => e.message);
```

## Combinators

```dart
successWith(2).map((v) => v * 10);             // Ok(20)
successWith(2).flatMap((v) => successWith(v + 1));
await successWith(2).flatMapAsync((v) async => successWith(v));
fail<int>('x').recover((e) => 0);              // Ok(0); no-op on Ok
fail<int>('x').mapError((e) => ResultError('[${e.message}]'));
```

`map`/`flatMap` pass an `Err` through unchanged (via `Err.cast<R>()`), so a failure flows down a chain without a converter.

## `try*` and `guard`

Wrap throwing code. `trySync`/`tryAsync` take a body that already returns a `Result`; `guard`/`guardAsync` wrap a plain value-returning body:

```dart
final r1 = Result.guard<int>(() => int.parse(input));        // Result<int>
final r2 = await Result.guardAsync<User>(() => api.fetch(id));

final r3 = await Result.tryAsync<Order>(() async {
  final order = await repo.load(id);   // returns a Result<Order>
  return order;
});
```

These never rethrow an `Exception` (it becomes an `Err`). A thrown **`Error`** — a programming bug — **rethrows** by default (see [Error policy](#error-rethrow-policy)).

### `failIf` / `okIf`

```dart
Result.failIf(() => name.isEmpty, 'Name is required');
Result.okIf(() => name.isNotEmpty, 'Name is required');
```

Validation failures build through `ResultConfig.failBuilder` and are **never** reported to `onException`.

## Custom errors

`ResultError` carries a `message` plus optional `code`, `cause`, and `stackTrace`. Equality includes `runtimeType`, so distinct subtypes with the same message are not equal.

```dart
class NotFound extends ResultError {
  const NotFound(int id) : super('Not found: $id', code: 'not_found');
}

final r = fail<User>(const NotFound(42));
r.error?.code; // 'not_found'
```

## Observability (crash reporting)

`fluent_result` keeps two error paths separate:

- **Validation** (`failIf` / `okIf`) — deliberate, expected failures. **Never** reported.
- **Caught exceptions** (`trySync` / `tryAsync` / `guard` / `guardAsync`) — unexpected throws. Reported **once** to `ResultConfig.onException`.

Wire a reporter once at startup (no-op by default):

```dart
ResultConfig.onException = (error, stack) {
  Sentry.captureException(error, stackTrace: stack);
};
```

Classify errors with `ResultMatcher`. Matchers are **subtype-aware** (`e is T`), first match wins, and `build` returns the `ResultError` payload. Flag expected control flow (offline, cancellation, 404, …) as `expected: true` so it fails quietly and is not reported:

```dart
ResultConfig.matchers = [
  ResultMatcher((e) => e is SocketException, (e, st) => ResultError.of(e),
      expected: true),
];
```

Call `ResultConfig.reset()` in your test `tearDown` to keep this global config from leaking between tests.

### Error-rethrow policy

A thrown **`Error`** (e.g. `StateError`, `TypeError`) is a bug. By default an `Error` that **no matcher claims** is **rethrown** from `try*`/`guard`, so it reaches the Zone / `PlatformDispatcher.onError` / your crash reporter instead of being silently swallowed into an `Err`. An `Exception` always becomes an `Err`.

Some third-party libraries misuse `Error` for expected failures (e.g. `DioError extends Error`). To convert such an `Error` into an `Err` instead of rethrowing, claim it with a matcher:

```dart
ResultConfig.matchers = [
  ResultMatcher((e) => e is DioError, (e, st) => ResultError.of(e)),
];
```

## Migration (8.5 → 9.0)

| 8.x | 9.0 |
|-----|-----|
| `ResultOf<T>` | `Result<T>` (`Ok<T>` / `Err<T>`); value-free is `Result<void>` |
| `result.value!` / `result.value` | pattern matching, `valueOrNull`, or `valueOr` |
| `void fold({onFail, onSuccess})` | value-returning `fold((v) => …, (e) => …)` / `match(onOk:, onErr:)` |
| `result.map<U>()` (fail passthrough) | `Err.cast<R>()` (or just keep `map`/`flatMap`, which pass `Err` through) |
| `getOrElse(() => x)` / `recover((errors) => x)` | now receive the error: `getOrElse((e) => x)` / `recover((e) => x)` |
| `ResultConfig.exceptionHandler` | `ResultConfig.onException` (move reporting here) |
| `ResultConfig.exceptionHandlerMatchers` (map) | `ResultConfig.matchers` (list of `ResultMatcher`) |
| `ResultConfig.logSuccessResult` | `ResultConfig.onSuccess` |
| `ResultException(e)` | `ResultError(message, cause: e)` |
| `asResult`, `add`/`addAll`, multi-error `errors`, `contains<T>`/`get<T>` | removed (single-error model) |

A matcher `build` now returns a `ResultError` (was a `ResultOf`). And a thrown `Error` not claimed by a matcher now rethrows instead of becoming a fail — add a `ResultMatcher((e) => e is Error, …)` if you relied on the old swallow.

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* [Andrew Piterov](mailto:piterov1990@gmail.com?subject=[GitHub]%20Source%20Dart%20fluent_result)
