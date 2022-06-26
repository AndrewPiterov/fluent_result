import 'package:fluent_result/fluent_result.dart';

/// Base Result Error object
class ResultError {
  ///
  const ResultError(this.message);

  /// Error message
  final String message;

  ///
  factory ResultError.of(Object error) {
    if (error is Exception) {
      return ResultException(error);
    }

    if (error is Error) {
      // you should not process error
    }

    return ResultError(error.toString());
  }

  @override
  bool operator ==(Object other) =>
      other is ResultError && other.message == message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'ResultError: $message';
}
