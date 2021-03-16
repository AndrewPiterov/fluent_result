import 'package:fluent_result/src/result_error.dart';

import 'result.dart';

/// Generic version of `Result` that holds value
class ResultOf<T> extends Result {
  ///
  ResultOf({
    required bool isSuccess,
    required this.value,
    ResultError? error,
  }) : super(
          isSuccess: isSuccess,
          error: error,
        );

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
  /// ResultOf.fail<MyObject>(ResultError('fail reason'));
  /// ```
  static ResultOf<T?> fail<T>(ResultError? error) {
    return ResultOf<T?>(isSuccess: false, value: null, error: error);
  }

  ///
  static ResultOf<T?> withErrorMessage<T>(String message) =>
      ResultOf<T?>(isSuccess: false, value: null, error: ResultError(message));

  ///
  static ResultOf<T?> withException<T>(Exception exception) => ResultOf<T?>(
      isSuccess: false, value: null, error: ResultException(exception));

  /// <summary>
  /// Convert result with value to result with another value. Use valueConverter
  /// parameter to specify the value transformation logic.
  /// </summary>
  ResultOf<U?> toResult<U>({U Function(T)? valueConverter}) {
    if (isSuccess) {
      if (valueConverter == null) {
        throw Exception(
            'If result is success then valueConverter should not be null');
      }
      return ResultOf.success<U>(valueConverter(value));
    }

    return ResultOf.fail<U>(error);
  }
}
