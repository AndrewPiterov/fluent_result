import 'dart:developer';

import 'package:fluent_result/fluent_result.dart';

/// Generic version of `Result` that holds value
class ResultOf<T> extends Result {
  ///
  ResultOf({
    required bool isSuccess,
    required this.value,
    List<ResultError> error = const [],
  }) : super(
          isSuccess: isSuccess,
          errors: error,
        );

  /// Value of result
  final T? value;

  // ignore: prefer_constructors_over_static_methods
  /// Create success `Result` with value
  /// ```dart
  /// ResultOf.success(MyObject());
  /// ```
  static ResultOf<T> success<T>(T data) =>
      ResultOf<T>(isSuccess: true, value: data);

  /// Result with fail reason
  /// ```dart
  /// ResultOf.failWith('fail reason');
  /// ```
  static ResultOf<T?> failWith<T>(Object reason) {
    final List<Object> reasons =
        reason is Iterable ? reason.toList().cast() : [reason];

    return ResultOf(
      isSuccess: false,
      value: null,
      error: reasons.map((e) => ResultError.of(e)).toList(),
    );
  }

  /// Wrapped on try/catch
  static ResultOf<T?> trySync<T>(ResultOf<T> Function() func) {
    try {
      return func();
    } catch (e) {
      log(e.toString());
      return ResultOf.failWith(e);
    }
  }

  /// Wrapped on try/catch
  static Future<ResultOf<T?>> tryAsync<T>(
      Future<ResultOf<T>> Function() func) async {
    try {
      return await func();
    } catch (e) {
      log(e.toString());
      return ResultOf.failWith(e);
    }
  }

  /// Fold the `result`
  void foldWithValue({
    required Function(List<ResultError> errors) onFail,
    required Function(T value) onSuccess,
  }) {
    if (isFail) {
      onFail(errors);
    } else {
      onSuccess(value!);
    }
  }

  /// <summary>
  /// Convert result with value to result with another value. Use valueConverter
  /// parameter to specify the value transformation logic.
  ///
  /// No need valueConverter for Fail result. But for Success you should define it.
  /// </summary>
  ResultOf<U?> map<U>([U Function(T)? valueConverter]) {
    if (isSuccess) {
      if (valueConverter == null) {
        throw Exception(
          'If result is success then valueConverter should not be null',
        );
      }
      return ResultOf.success<U>(valueConverter(value!));
    }

    return fail(error!);
  }
}
