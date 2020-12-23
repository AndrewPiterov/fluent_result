/// Base Result Error object
class ResultError {
  ///
  const ResultError(this.message);

  /// Error message
  final String message;
}

/// Result Error caused by exception
class ResultException extends ResultError {
  ///
  ResultException(this.exception) : super(exception.toString());

  ///
  final Exception exception;
}
