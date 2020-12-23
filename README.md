# Fluent Result

![Pub Version](https://img.shields.io/pub/v/fluent_result?style=plastic)

Fluent Result is a lightweight Dart library developed to solve a common problem. It returns an object indicating success or failure of an operation instead of throwing/using exceptions.

## Usage

### Simple Non-Generic Result

```dart
Result result = Result.success();
```

```dart
Result result = Result.fail('a fail reason');
```

### Generic Result

```dart
ResultOf<MyObject> result = ResultOf.success(MyObject());
MyObject value = result.value;
```

```dart
ResultOf<MyObject> result = ResultOf.fail<MyObject>('a fail reason');
MyObject value = result.value;
```

## Contributing

We accept the following contributions:

* Improving documentation
* Reporting issues
* Fixing bugs

## Maintainers

* Andrew Piterov
