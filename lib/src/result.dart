import 'package:meta/meta.dart';

/// `Result` is an object indicating success or failure of an operation
class Result {
  ///
  const Result({
    @required this.isSuccess,
    this.errorMessage,
  });

  /// Create success `Result` with value
  /// ```dart
  /// Result.success();
  /// ```
  const Result.success()
      : isSuccess = true,
        errorMessage = '';

  /// Create fail `Result` with reason
  /// ```dart
  /// Result.fail('fail reason');
  /// ```
  Result.fail(this.errorMessage)
      : assert(errorMessage != null && errorMessage.isNotEmpty),
        isSuccess = false;

  /// Returns whether the `Result` is success
  final bool isSuccess;

  /// Returns whether the `Result` is fail
  bool get isFail => !isSuccess;

  /// The reason why operation has been failed
  final String errorMessage;

  // ignore: prefer_const_constructors
  /// Returns success `Result`
  static Result get ok => const Result.success();
}
