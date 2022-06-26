import 'dart:developer';

import 'package:fluent_result/fluent_result.dart';

/// Generic version of `Result` that holds value
class ResultOf<T> extends Result {
  ///
  ResultOf({
    required bool isSuccess,
    required this.value,
    ResultError? error,
  }) : super(
          isSuccess: isSuccess,
          errors: error == null ? [] : [error],
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

  // ignore: prefer_constructors_over_static_methods
  /// Create fail `Result` with reason of fail
  /// ```dart
  /// ResultOf.fail<MyObject>(ResultError('fail reason'));
  /// ```
  static ResultOf<T?> fail<T>(ResultError error) {
    return ResultOf<T?>(isSuccess: false, value: null, error: error);
  }

  // ignore: prefer_constructors_over_static_methods
  /// Create fail `Result` with reason of fail
  /// ```dart
  /// ResultOf.withError<MyObject>(ResultError('fail reason'));
  /// ```
  @Deprecated('Use `withErr(object)`')
  static ResultOf<T?> withError<T>(ResultError error) => withErr(error);

  ///
  @Deprecated('Use `withErr(object)`')
  static ResultOf<T?> withErrorMessage<T>(String message) => withErr(message);

  ///
  @Deprecated('Use `withErr(object)`')
  static ResultOf<T?> withException<T>(Exception exception) =>
      withErr(exception);

  ///
  static ResultOf<T?> withErr<T>(Object object) {
    if (object is Exception) {
      return ResultOf.fail(ResultException(object));
    }
    if (object is Error) {
      return ResultOf.fail(ResultError.of(object));
    }
    if (object is ResultError) {
      return ResultOf.fail(object);
    }
    return ResultOf.fail(ResultError(object.toString()));
  }

  /// Wrapped on try/catch
  static ResultOf<T?> trySync<T>(T Function() func) {
    try {
      final data = func();
      return ResultOf.success(data);
    } catch (e) {
      log(e.toString());
      return ResultOf.withErr(e);
    }
  }

  /// Wrapped on try/catch
  static Future<ResultOf<T?>> tryAsync<T>(Future<T> Function() func) async {
    try {
      final data = await func();
      return ResultOf.success(data);
    } catch (e) {
      log(e.toString());
      return ResultOf.withErr(e);
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
