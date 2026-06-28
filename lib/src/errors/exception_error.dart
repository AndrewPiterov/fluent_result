import 'package:fluent_result/fluent_result.dart';

/// Result Error caused by exception
class ResultException extends ResultError {
  /// Wraps [exception], using its `toString()` as the error message.
  ResultException(this.exception) : super(exception.toString());

  /// The wrapped exception.
  final Exception exception;
}
