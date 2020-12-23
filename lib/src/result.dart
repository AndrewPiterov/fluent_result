import 'package:fluent_result/src/result_error.dart';
import 'package:meta/meta.dart';

/// `Result` is an object indicating success or failure of an operation
class Result {
  ///
  const Result({
    @required this.isSuccess,
    this.error,
  });

  /// Create success `Result` with value
  /// ```dart
  /// Result.success();
  /// ```
  const Result.success()
      : isSuccess = true,
        error = null;

  /// Create fail `Result` with reason
  /// ```dart
  /// Result.fail(ResultError('fail reason'));
  /// ```
  Result.fail(this.error)
      : assert(error != null),
        isSuccess = false;

  ///
  Result.withErrorMessage(String message)
      : assert(message != null && message.isNotEmpty),
        error = ResultError(message),
        isSuccess = false;

  ///
  Result.withException(Exception exception)
      : assert(exception != null),
        error = ResultException(exception),
        isSuccess = false;

  /// Returns whether the `Result` is success
  final bool isSuccess;

  /// Returns whether the `Result` is fail
  bool get isFail => !isSuccess;

  ///
  final ResultError error;

  /// The reason why operation has been failed
  String get errorMessage => error?.message;

  // ignore: prefer_const_constructors
  /// Returns success `Result`
  static Result get ok => const Result.success();
}
