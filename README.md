# fluent_result


[![pub package](https://img.shields.io/pub/v/fluent_result.svg?label=fluent_result&color=blue)](https://pub.dev/packages/fluent_result)
[![codecov](https://codecov.io/gh/AndrewPiterov/fluent_result/branch/main/graph/badge.svg?token=VM9LTJXGQS)](https://codecov.io/gh/AndrewPiterov/fluent_result)
[![likes](https://img.shields.io/pub/likes/fluent_result)](https://pub.dev/packages/fluent_result/score)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
[![Dart](https://github.com/AndrewPiterov/fluent_result/actions/workflows/dart.yml/badge.svg)](https://github.com/AndrewPiterov/fluent_result/actions/workflows/dart.yml)

`fluent_result` is a lightweight Dart library developed to solve a common problem. It returns an object indicating success or failure of an operation instead of throwing/using exceptions.

- Store multiple errors in one Result object
- Store powerful and elaborative Error object instead of only error messages in string format
- Designing Errors in an object-oriented way

## Usage

### Creating a `Result`

Create a result which indicates success

```dart
Result result = Result.success();
Result sameResult = Result.ok;
Result sameResult2 = success();
```

Create a result which indicates failure

```dart
Result errorResult1 = Result.failWith('a fail reason');
Result errorResult2 = Result.failWith(ResultError('my error message'));
Result errorResult3 = Result.failWith(MyException('exception description'));
Result errorResult4 = Result.failWith(['a fail reason', ResultError('my error message')]);

Result same = fail(MyException('exception description'));
```

### Generic `ResultOf<T>`

Success result with value:

```dart
ResultOf<MyObject> result = ResultOf.success(MyObject());
ResultOf<MyObject> sameResult = successWith(MyObject());
MyObject? value = result.value;
```

Fail result with error and without value:

```dart
ResultOf<MyObject> result = ResultOf.failWith<MyObject>(ResultError('a fail reason'));
MyObject? value = result.value; // is null because of the fail result
```

### `failIf()` and `okIf()`

With the methods `failIf()` and `okIf()` you can also write in a more readable way:

```dart
final result1 = Result.failIf(() => firstName.isEmpty, "First Name is empty");
final result2 = Result.okIf(() => firstName.isNotEmpty, 'First name should not be empty');
```

### Try

#### Sync

```dart
final res = Result.trySync(() {
  throw 'Some exception';
});

res.isFail.should.beTrue();
res.errorMessage.should.be('Some exception');
```

#### Async

```dart
final res = await Result.tryAsync(() async {
  await Future.delayed(const Duration(seconds: 2));
  print('Done');
});

res.isSuccess.should.beTrue();
```

### Fold

```dart
Result res = fail('error reason');
res.fold(
  onFail: (errors) {
    // process errors
  },
  onSuccess: () {
    // process success path
  },
);
```

```dart
ResultOf<String> resultWithData = successWith('someData');
resultWithData.foldWithValue(
  onFail: (errors) {
    // process errors
  },
  onSuccess: (data) {
    // process success path with data
  },
);
```

### Converting Result to another

To convert one success result to another success result has to be provided a `valueConverter` function.

```dart
final anotherResult =
    result.map((customer) => User(customer.id));
```

To convert one fail result to another fail result

```dart
final anotherResult = failResult.map<Customer>();
```

### Combinators

`ResultOf<T>` provides combinators for composing results without unwrapping:

```dart
// chain a success into another Result (errors pass through on a fail)
final r = successWith(2).flatMap((v) => successWith(v * 10)); // ResultOf(20)

// collapse into a value (the value-returning counterpart to fold)
final label = r.match(
  onFail: (errors) => 'failed: ${errors.first.message}',
  onSuccess: (value) => 'ok: $value',
);

// extract with a fallback (eager or lazy)
final value = r.valueOr(0);
final lazy = r.getOrElse(() => compute());

// recover a fail into a success, or transform every error
final recovered = failResult.recover((errors) => 0);
final remapped = failResult.mapError((e) => ResultError('[${e.message}]'));
```

Wrap a plain, possibly-throwing computation with `guard` / `guardAsync` — the body returns a
bare value, not a pre-lifted `Result`:

```dart
final parsed = ResultOf.guard(() => int.parse(input));
final fetched = await ResultOf.guardAsync(() => api.fetch(id));
```

### Custom errors

To make your codebase more robust. Create your own error collection of the App by extending `ResultError`.

```dart

class InvalidPasswordError extends ResultError {
  const InvalidPasswordError(String message)
      : super(message);
}

class CustomerNotFound extends ResultError {
  const CustomerNotFound({
    required this.customerId,
  }) : super('Customer not found with ID $customerId');

  final int customerId;

  @override
  String toString() => message;
}
```

### Collect errors

For example, easy to work with errors which comes from HTTP API.

```dart
final err1 = CustomerNotFound(customerId: 1);
final res = Result.failWith(err1);

final err2 = InvalidPasswordError('The password 123456 is invalid');
res.add(err2);

res.contains<InvalidPasswordError>(); // true
res.get<InvalidPasswordError>().should.not.beNull();
```

### Observability (crash reporting)

`fluent_result` keeps two error paths separate:

- **Validation** (`failIf` / `okIf`) — deliberate, expected failures. These are **never** reported.
- **Caught exceptions** (`trySync` / `tryAsync` / `guard`) — unexpected throws. These are reported **once** to `ResultConfig.onException`.

Wire your crash reporter once at startup (no-op by default, so nothing is reported until you do):

```dart
ResultConfig.onException = (error, stack) {
  Sentry.captureException(error, stackTrace: stack);
};
```

Classify errors with `ResultMatcher`. Matchers are **subtype-aware** (`e is T`) and the first
match wins. Flag expected control flow (offline, cancellation, 404, …) as `expected: true` so it
fails quietly without reaching `onException`:

```dart
ResultConfig.matchers = [
  // expected control flow — built into a fail Result, NOT reported
  ResultMatcher((e) => e is SocketException, (e, st) => fail(e), expected: true),
  // map a third-party error to a typed ResultError (reported, since not expected)
  ResultMatcher((e) => e is DioException, (e, st) => fail(DioErrorResult(e))),
];
```

> Some third-party errors extend `Error` rather than `Exception` (e.g. `DioError extends Error`),
> so match them with `(e) => e is DioError` (or `e is Error`) — an `e is Exception` catch-all will
> not match them.

Call `ResultConfig.reset()` in your test `tearDown` to keep this global config from leaking
between tests.

#### Migrating from `exceptionHandler` / `exceptionHandlerMatchers`

Both are **deprecated** but still work — prefer `onException` + `matchers`. If your old
`exceptionHandler` reported errors itself, move that reporting into `onException`; otherwise an
unexpected error is reported twice (once by `onException`, once by your handler).

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* [Andrew Piterov](mailto:piterov1990@gmail.com?subject=[GitHub]%20Source%20Dart%20fluent_result)
