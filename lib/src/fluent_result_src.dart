import 'package:flutter/foundation.dart';

/// Result is an object indicating success or failure of an operation
///
/// Use with Result.success() or Result.fail('fail reason')
class Result<T> {
  final bool isSuccess;
  bool get isFail => !isSuccess;

  final String errorMessage;

  final T value;

  const Result({
    @required this.isSuccess,
    this.errorMessage,
    this.value,
  });

  /// Create success Result
  const Result.success({T value})
      : isSuccess = true,
        errorMessage = '',
        value = value;

  /// Create fail Result
  Result.fail(this.errorMessage)
      : assert(errorMessage != null && errorMessage.isNotEmpty),
        isSuccess = false,
        value = null;

  // ignore: prefer_constructors_over_static_methods
  static Result get ok => const Result.success();
}
