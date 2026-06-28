import 'package:fluent_result/fluent_result.dart';

/// A subtype-aware classifier for a caught error.
///
/// [test] MUST be a pure, side-effect-free predicate (e.g. `(e) => e is DioError`).
/// [build] produces the [ResultError] payload for a matched error (the framework
/// wraps it as `Err<T>`). Claiming an error with a matcher converts it to an
/// `Err` and — for an `Error` subtype — SUPPRESSES the rethrow, regardless of
/// [expected]. When [expected] is `true`, the error is normal control flow and
/// is additionally NOT reported via `onException`.
class ResultMatcher {
  /// Creates a matcher.
  const ResultMatcher(this.test, this.build, {this.expected = false});

  /// Pure predicate deciding whether this matcher handles the error.
  final bool Function(Object error) test;

  /// Builds the [ResultError] payload for a matched error.
  final ResultError Function(Object error, StackTrace? stack) build;

  /// Whether a matched error is expected control flow. When `true` it is not
  /// reported via `onException`. (The rethrow of a matched `Error` is
  /// suppressed by the match itself, independent of this flag.)
  final bool expected;
}
