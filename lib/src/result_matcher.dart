import 'package:fluent_result/fluent_result.dart';

/// A subtype-aware classifier for a caught error.
///
/// [test] decides whether this matcher applies (use `(e) => e is SomeType`).
/// It MUST be a pure, side-effect-free predicate — it is evaluated to classify
/// the error and may be consulted again to build the result. [build] produces
/// the fail [ResultOf] for a matched error. When [expected] is `true`, the
/// error is normal control flow (offline / cancellation / 404) and
/// `ResultConfig.onException` is NOT invoked for it.
class ResultMatcher {
  /// Creates a matcher. See the class docs for the contract of each argument.
  const ResultMatcher(this.test, this.build, {this.expected = false});

  /// Pure predicate deciding whether this matcher handles [error].
  final bool Function(Object error) test;

  /// Builds the fail result for a matched [error] and optional [stack].
  final ResultOf<dynamic> Function(Object error, StackTrace? stack) build;

  /// Whether a matched error is expected control flow (suppresses reporting).
  final bool expected;
}
