# [8.5.0]

* [Add] Global observability seam `ResultConfig.onException` (no-op by default) — the single place to wire crash reporting (e.g. Sentry). Unexpected caught exceptions are reported exactly once.
* [Add] `ResultMatcher` + `ResultConfig.matchers`: ordered, subtype-aware error classification with an `expected` flag (expected errors are never reported).
* [Add] `ResultConfig.onSuccess`, `failBuilder`, and `reset()` (call in test `tearDown` to avoid global-config leakage).
* [Add] `onErrorWithStack` parameter on `trySync`/`tryAsync`.
* [Add] `ResultOf.guard`/`guardAsync` to wrap a plain value-returning body.
* [Add] Combinators on `ResultOf<T>`: `flatMap`, `flatMapAsync`, `match`, `valueOr`, `getOrElse`, `recover`, `mapError`.
* [Change] `failIf`/`okIf` route through `failBuilder` — validation failures are never reported.
* [Change] `fail`/`failWith` return `ResultOf<T>` (was `ResultOf<T?>`) — covariant, non-breaking.
* [Change] Caught and successful results are no longer logged by default; the default `exceptionHandlerMatchers` is now empty.
* [Change] SDK lower bound raised to `>=2.14.0`.
* [Deprecate] `exceptionHandler`, `exceptionHandlerMatchers`, `logSuccessResult` — kept as functional aliases.
* [Remove] `logger` and `quiver` dependencies.

#### Migration

* If your `ResultConfig.exceptionHandler` reported errors itself, move that reporting into `ResultConfig.onException` to avoid double-reporting.
* For `Error`-derived third-party exceptions (e.g. `DioError extends Error`), match with `(e) => e is Error` — the `e is Exception` catch-all does not match them.

# [8.4.1]

* [Fix] `Result.hashCode` is now stable and contract-correct, so equal Results share a hash code and work as `Set`/`Map` keys
* [Fix] `ResultOf.map()` no longer drops all but the first error when mapping a multi-error fail result
* [Fix] `foldWithValue`/`map` throw a clear `StateError` instead of an opaque `TypeError` when a non-nullable success value is `null`
* [Docs] correct README `exceptionHandlerMatchers` matcher signature, nullable `ResultOf.value`, and `Result.failWith` usage

# [8.4.0]

* [Fix] can pass `null` in `successWith(null)`

# [8.3.0]

* add `onFinally` method to `ResultOf` and `Result`
* update `logger` dependency to `^2.2.0`

# [8.2.0]

* update `logger` dependency

# [8.1.0]

* downgrade `collection: ^1.17.1`

# [8.0.0]

* [Fix] logging stack trace.
* [Update] dependencies.

# [7.3.0]

* [Add] [Logger](https://pub.dev/packages/logger).

# [7.2.0]

* [Add] exception handler matchers.

# [7.1.1]

* [Add] **onError** in `trySync`/`tryAsync` for error handler  customization.

# [7.1.0]

* [Add] **logSuccessResult** into `ResultConfig`
* [Change] **errorMessage** now is non-nullable, by default is empty string.

# [7.0.0]

* [Add] `ResultConfig` to customize `exceptionHandler`
* [Fix] `tries`

# [6.0.0]

* [Add] `success`, `successWith`, `fail` methods
* [Add] `trySync`, `tryAsync` methods
* [Change] `toResult` into `map`

# [5.0.0]

#### Breaking changes

* `ResultError` has not const constructor anymore.

#### Updates

* Use `withError` and `withErrors` instead of `fail` and `fails` respectively.
* [Add] folding onFail and onSuccess with `fold(onFail, onSuccess)`.
* [Add] mapping any object to `ResultOf<T>` with `toResult()`.
* [Add] `failIf(condition, reason)` and `okIf(condition, failReason)`.

# [4.3.0]

* [Fix] `contains<T>()`
* [Add] getting specific error from collection by `get<T>`

# [4.2.0]

* [Fix] `contains<T>()`

# [4.1.0]

* [Add] errors collection

# [4.0.1]

* [Migrate] to null-safety

# [4.0.0]

* [Update] dependencies for migration to null-safety

# [3.0.2]

* Add `withErrorMessage(String)` method to `ResultOf`
* Add `withException(Exception)` method to `ResultOf`

# [3.0.1]

* [Add] `withErrorMessage(String)` method to `Result`
* [Add] `withException(Exception)` method to `Result`

# [3.0.0+1]

Correct README.md

# [3.0.0]

* [Add] `ResultError` object that describes a error and allows the errors to be typed.

# [2.0.0+1]

Correct README.md

# [2.0.0]

* [Add] `ResultOf<T>` for generic Result to hold value of T.
* [Remove] `flutter` dependency

# [1.0.0+1]

* [Add] correct description

# [1.0.0]

Initial Version of the library.

* Includes the ability to create Success and Fail Results
* Includes the ability to create Generic Result with value
