# Fluent Result

Fluent Result is a lightweight Dart library developed to solve a common problem. It returns an object indicating success or failure of an operation instead of throwing/using exceptions.

## Usage

### Simple Non-Generic Result

```dart
Result result = Result.success();
```

```dart
Result result = Result.fail('Fail reason');
```

### Generic Result

```dart
Result<MyObject> result = Result.success(value: MyObject());
final value = result.value;
```

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* Andrew Piterov
