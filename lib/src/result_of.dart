import 'package:meta/meta.dart';

import 'result.dart';

/// Generic version of `Result` that holds value
class ResultOf<T> extends Result {
  ///
  ResultOf({
    @required bool isSuccess,
    @required this.value,
    String errorMessage,
  }) : super(isSuccess: isSuccess, errorMessage: errorMessage);

  /// Value of result
  final T value;

  // ignore: prefer_constructors_over_static_methods
  /// Create success `Result` with value
  /// ```dart
  /// ResultOf.success(MyObject());
  /// ```
  static ResultOf<T> success<T>(T data) =>
      ResultOf<T>(isSuccess: true, value: data);

  // ignore: prefer_constructors_over_static_methods
  /// Create fail `Result` with reason of fail
  /// ```dart
  /// ResultOf.fail<MyObject>('fail reason');
  /// ```
  static ResultOf<T> fail<T>(String message) {
    return ResultOf<T>(isSuccess: false, value: null, errorMessage: message);
  }
}
