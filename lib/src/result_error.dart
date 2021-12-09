import 'package:quiver/core.dart';

/// Base Result Error object
class ResultError {
  ///
  const ResultError(this.message, {this.key = 'ResultError'});

  /// Key of error
  final String key;

  /// Error message
  final String message;

  @override
  bool operator ==(Object other) =>
      other is ResultError && other.key == key && other.message == message;

  @override
  int get hashCode => hash2(
        key.hashCode,
        message.hashCode,
      );

  @override
  String toString() => '$key: $message';
}

/// Result Error caused by exception
class ResultException extends ResultError {
  ///
  ResultException(this.exception) : super(exception.toString());

  ///
  final Exception exception;
}
