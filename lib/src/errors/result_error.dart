import 'package:fluent_result/fluent_result.dart';

/// Base Result Error object
class ResultError {
  ///
  const ResultError(this.message);

  /// Error message
  final String message;

  ///
  factory ResultError.of(Object reason) {
    if (reason is Exception) {
      return ResultException(reason);
    }

    if (reason is Error) {
      // you should not process error
    }
    if (reason is ResultError) {
      return reason;
    }

    return ResultError(reason.toString());
  }

  @override
  bool operator ==(Object other) =>
      other is ResultError && other.message == message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'ResultError: $message';
}
