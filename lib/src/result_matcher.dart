import 'package:fluent_result/fluent_result.dart';

/// A subtype-aware classifier for a caught error.
///
/// [test] MUST be a pure, side-effect-free predicate (e.g. `(e) => e is DioError`).
/// [build] produces the [ResultError] payload for a matched error (the framework
/// wraps it as `Err<T>`). When [expected] is `true`, the error is normal control
/// flow: it is NOT reported via `onException`, and — for an `Error` subtype — a
/// match also SUPPRESSES the rethrow.
class ResultMatcher {
  /// Creates a matcher.
  const ResultMatcher(this.test, this.build, {this.expected = false});

  /// Pure predicate deciding whether this matcher handles the error.
  final bool Function(Object error) test;

  /// Builds the [ResultError] payload for a matched error.
  final ResultError Function(Object error, StackTrace? stack) build;

  /// Whether a matched error is expected control flow (suppresses reporting
  /// and, for `Error` subtypes, the rethrow).
  final bool expected;
}
