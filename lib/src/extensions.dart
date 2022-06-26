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
      return fail(this);
    }

    if (this is Error) {
      return fail(ResultError.of(this));
    }

    if (this is Exception) {
      return fail(ResultException(this as Exception));
    }

    return successWith(this as T);
  }
}
