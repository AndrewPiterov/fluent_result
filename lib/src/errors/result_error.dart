import 'package:fluent_result/fluent_result.dart';

/// Base Result Error object
class ResultError {
  /// Creates an error described by [message].
  const ResultError(this.message);

  /// Error message
  final String message;

  /// Normalizes any [reason] into a [ResultError]: an [Exception] becomes a
  /// [ResultException], an existing [ResultError] passes through, and anything
  /// else is stringified.
  factory ResultError.of(dynamic reason) {
    if (reason is Exception) {
      return ResultException(reason);
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
