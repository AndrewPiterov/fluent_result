import 'package:fluent_result/fluent_result.dart';

/// Result extensions
extension ResultExtension on Object {
  /// Map the `object` into `ResultOf<T>`.
  ///
  /// Example:
  /// ```dart
  /// ResultOf<int> intResult = 1.asResult();
  /// ResultOf<String> stringResult = 'some data'.asResult();
  /// ```
  ResultOf<T?> asResult<T>() {
    if (this is ResultError) {
      return ResultOf.withError<T>(this as ResultError);
    }

    if (this is Error) {
      return ResultOf.withError<T>(ResultError.of(this as Error));
    }

    if (this is Exception) {
      return ResultOf.withError<T>(ResultException(this as Exception));
    }

    return ResultOf.success(this as T);
  }
}
