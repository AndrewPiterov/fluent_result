/// A failure reason carried by an [Err].
///
/// [message] is human-readable. [code] is an optional stable identifier.
/// [cause] is the original thrown object (if any). [stackTrace] is the captured
/// trace (if any). Equality includes [runtimeType], so distinct subtypes with
/// the same [message] are not equal.
class ResultError {
  /// Creates a result error.
  const ResultError(
    this.message, {
    this.code,
    this.cause,
    this.stackTrace,
  });

  /// Builds a [ResultError] from an arbitrary [reason]. A [ResultError] is
  /// returned as-is; any other value becomes [message] via `toString()` and is
  /// kept as [cause].
  factory ResultError.of(Object reason, [StackTrace? stackTrace]) {
    if (reason is ResultError) return reason;
    return ResultError(
      reason.toString(),
      cause: reason,
      stackTrace: stackTrace,
    );
  }

  /// Human-readable failure message.
  final String message;

  /// Optional stable error code.
  final String? code;

  /// The original thrown object, if this error wraps one.
  final Object? cause;

  /// The captured stack trace, if any.
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      other is ResultError &&
      other.runtimeType == runtimeType &&
      other.message == message &&
      other.code == code;

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() => 'ResultError: $message';
}
