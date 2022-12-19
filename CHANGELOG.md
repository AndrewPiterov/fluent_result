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
