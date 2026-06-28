import 'package:fluent_result/fluent_result.dart';

/// Global, process-wide configuration for `fluent_result`.
///
/// All members are static. Two error paths are kept separate:
/// the **validation** path ([failBuilder], used by `failIf`/`okIf`) never
/// reports; the **caught-exception** path ([onException] + [matchers]) reports
/// unexpected exceptions exactly once. Wire your crash reporter via
/// [onException]. Call [reset] in test `tearDown` to avoid cross-test leakage.
class ResultConfig {
  /// `ResultConfig` is a static-only configuration holder. This constructor
  /// exists only for backward compatibility and returns a shared instance with
  /// no usable instance API — use the static members directly.
  factory ResultConfig() => _instance;

  ResultConfig._();

  static final ResultConfig _instance = ResultConfig._();

  /// Report hook for UNEXPECTED caught exceptions. No-op by default.
  /// Wire your crash reporter here, e.g. `Sentry.captureException`.
  static void Function(Object error, StackTrace? stack) onException =
      (_, __) {};

  /// Success telemetry hook, fired on every successful `try*`. No-op by default.
  static void Function(Result result) onSuccess = (_) {};

  /// Ordered, subtype-aware matchers. First match wins. Empty by default.
  static List<ResultMatcher> matchers = <ResultMatcher>[];

  /// Pure builder turning a deliberate reason into a fail [ResultOf].
  /// Used by `Result.failIf`/`Result.okIf`. Never reports, never logs.
  static ResultOf<dynamic> Function(Object reason) failBuilder =
      (reason) => fail(reason);

  /// Inert identity sentinel meaning "[exceptionHandler] not overridden".
  /// Does NOT itself read [exceptionHandlerMatchers]; the legacy map is
  /// consulted only by [buildFailResult] rule 3 (single source of truth).
  /// A static tear-off is canonical, so `identical(...)` checks are stable.
  static ResultOf<dynamic> _legacyDefault(dynamic e, StackTrace? st) =>
      failBuilder(e as Object);

  /// DEPRECATED. Legacy full-control caught-exception handler.
  /// Honored verbatim when overridden (see [buildFailResult] rule 1).
  @Deprecated('Use matchers + onException instead')
  static ResultOf<dynamic> Function(dynamic e, StackTrace? st) exceptionHandler =
      _legacyDefault;

  /// DEPRECATED. Legacy exact-`runtimeType` matcher map.
  @Deprecated('Use matchers instead')
  static Map<Type, ResultOf<dynamic> Function(dynamic e, StackTrace? st)>
      exceptionHandlerMatchers =
      <Type, ResultOf<dynamic> Function(dynamic e, StackTrace? st)>{};

  /// DEPRECATED. Alias of [onSuccess]; reading returns [onSuccess].
  @Deprecated('Use onSuccess instead')
  static void Function(Result result) get logSuccessResult => onSuccess;

  /// DEPRECATED. Alias of [onSuccess]; setting it sets [onSuccess].
  @Deprecated('Use onSuccess instead')
  static set logSuccessResult(void Function(Result result) handler) =>
      onSuccess = handler;

  /// The first matcher whose [ResultMatcher.test] accepts [error], else null.
  ///
  /// A throwing predicate must never break error handling nor hide the original
  /// error: a matcher whose [ResultMatcher.test] throws is reported via
  /// [safeReport] and skipped, and classification continues with the next one.
  static ResultMatcher? classify(Object error) {
    for (final matcher in matchers) {
      try {
        if (matcher.test(error)) return matcher;
      } catch (testError, testStack) {
        safeReport(testError, testStack);
      }
    }
    return null;
  }

  /// Invoke [onException] guarded, so a throwing reporter never escapes.
  static void safeReport(Object error, StackTrace? stack) {
    try {
      onException(error, stack);
    } catch (_) {
      // Never let the reporter mask the original error.
    }
  }

  /// Invoke [onSuccess] guarded, so a throwing telemetry hook can never flip a
  /// successful result into a failure.
  static void notifySuccess(Result result) {
    try {
      onSuccess(result);
    } catch (e, st) {
      safeReport(e, st);
    }
  }

  /// Report [error] via [onException] unless [matched] flags it expected.
  static void reportIfUnexpected(
    Object error,
    StackTrace? stack,
    ResultMatcher? matched,
  ) {
    if (matched == null || !matched.expected) {
      safeReport(error, stack);
    }
  }

  /// Build the fail [ResultOf] for a caught [error], without reporting.
  ///
  /// Precedence: (1) an overridden [exceptionHandler]; (2) the [matched]
  /// matcher; (3) legacy [exceptionHandlerMatchers] by exact runtimeType;
  /// (4) [failBuilder].
  static ResultOf<dynamic> buildFailResult(
    Object error,
    StackTrace? stack,
    ResultMatcher? matched,
  ) {
    // ignore: deprecated_member_use_from_same_package
    if (!identical(exceptionHandler, _legacyDefault)) {
      // ignore: deprecated_member_use_from_same_package
      return exceptionHandler(error, stack);
    }
    if (matched != null) {
      return matched.build(error, stack);
    }
    // ignore: deprecated_member_use_from_same_package
    final legacy = exceptionHandlerMatchers[error.runtimeType];
    if (legacy != null) {
      return legacy(error, stack);
    }
    return failBuilder(error);
  }

  /// Run [onFinally] guarded, routing any throw through [safeReport].
  static void guardFinally(void Function()? onFinally) {
    if (onFinally == null) return;
    try {
      onFinally();
    } catch (e, st) {
      safeReport(e, st);
    }
  }

  /// Restore every hook, matcher and deprecated alias to its default.
  static void reset() {
    onException = (_, __) {};
    onSuccess = (_) {};
    matchers = <ResultMatcher>[];
    failBuilder = (reason) => fail(reason);
    // ignore: deprecated_member_use_from_same_package
    exceptionHandler = _legacyDefault;
    // ignore: deprecated_member_use_from_same_package
    exceptionHandlerMatchers =
        <Type, ResultOf<dynamic> Function(dynamic e, StackTrace? st)>{};
  }
}
