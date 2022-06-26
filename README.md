# fluent_result


[![pub package](https://img.shields.io/pub/v/fluent_result.svg?label=fluent_result&color=blue)](https://pub.dev/packages/fluent_result)
[![codecov](https://codecov.io/gh/AndrewPiterov/fluent_result/branch/main/graph/badge.svg?token=VM9LTJXGQS)](https://codecov.io/gh/AndrewPiterov/fluent_result)
[![likes](https://badges.bar/fluent_result/likes)](https://pub.dev/packages/fluent_result/score)
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
MyObject value = result.value;
```

Fail result with error and without value:

```dart
ResultOf<MyObject> result = ResultOf.failWith<MyObject>(ResultError('a fail reason'));
MyObject value = result.value; // is null because of the fail result
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
final res = Result.fail(err1);

final err2 = InvalidPasswordError('The password 123456 is invalid');
res.add(err2);

res.contains<InvalidPasswordError>(); // true
res.get<InvalidPasswordError>().should.not.beNull();
```

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* [Andrew Piterov](mailto:piterov1990@gmail.com?subject=[GitHub]%20Source%20Dart%20fluent_result)
