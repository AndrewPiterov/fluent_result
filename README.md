# fluent_result


[![pub package](https://img.shields.io/pub/v/fluent_result.svg?label=fluent_result&color=blue)](https://pub.dev/packages/fluent_result)
[![codecov](https://codecov.io/gh/AndrewPiterov/fluent_result/branch/main/graph/badge.svg?token=VM9LTJXGQS)](https://codecov.io/gh/AndrewPiterov/fluent_result)
[![likes](https://badges.bar/fluent_result/likes)](https://pub.dev/packages/fluent_result/score)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
[![Dart](https://github.com/AndrewPiterov/fluent_result/actions/workflows/dart.yml/badge.svg)](https://github.com/AndrewPiterov/fluent_result/actions/workflows/dart.yml)

`fluent_result` is a lightweight Dart library developed to solve a common problem. It returns an object indicating success or failure of an operation instead of throwing/using exceptions.

## Usage

### Simple Non-Generic Result

```dart
Result result = Result.success();
```

```dart
Result result = Result.fail(ResultError('a fail reason'));
```

```dart
Result result = Result.withErrorMessage('a fail reason');
```

```dart
Result result = Result.withException(MyException('exception description'));
```

### Generic Result

```dart
ResultOf<MyObject> result = ResultOf.success(MyObject());
MyObject value = result.value;
```

```dart
ResultOf<MyObject> result = ResultOf.fail<MyObject>(ResultError('a fail reason'));
MyObject value = result.value;
```

```dart
Result result = ResultOf.withErrorMessage<MyObject>('a fail reason');
```

```dart
Result result = ResultOf.withException(MyException<MyObject>('exception description'));
```

### Converting Result to another

To convert one success result to another success result has to be provided a `valueConverter`

```dart
final anotherResult =
    result.toResult(valueConverter: (customer) => User(customer.id));
```

To convert one fail result to another fail result

```dart
final anotherResult = failResult.toResult<Customer>();
```

### Custom errors

To make your codebase more robust. Create your own error collection of the App by extending `ResultError`. \
`ResultError` has `key` property which you can use for localization.

```dart

class InvalidPasswordError extends ResultError {
  const InvalidPasswordError(String message)
      : super(message, key: 'InvalidPasswordError');
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

res.contains(err2); // true
```

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* [Andrew Piterov](mailto:piterov1990@gmail.com?subject=[GitHub]%20Source%20Dart%20fluent_result)
