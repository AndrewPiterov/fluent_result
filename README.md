# Fluent Result

![Pub Version](https://img.shields.io/pub/v/fluent_result?style=plastic)

Fluent Result is a lightweight Dart library developed to solve a common problem. It returns an object indicating success or failure of an operation instead of throwing/using exceptions.

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

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* [Andrew Piterov](mailto:piterov1990@gmail.com?subject=[GitHub]%20Source%20Dart%20fluent_result)
