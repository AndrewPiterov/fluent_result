import 'package:fluent_result/fluent_result.dart';

/// Global, process-wide configuration for `fluent_result`.
///
/// Wire a crash reporter via [onException]. Validation failures (`failIf`/`okIf`)
/// build through [failBuilder] and are never reported. Call [reset] in test
/// `tearDown` to avoid cross-test leakage.
class ResultConfig {
  ResultConfig._();

  /// Report hook for UNEXPECTED caught exceptions. No-op by default.
  static void Function(Object error, StackTrace? stack) onException =
      (_, __) {};

  /// Success telemetry. No-op by default. Invoked via the guarded
  /// [notifySuccess] on every successful `try*`.
  static void Function(Result<dynamic> result) onSuccess = (_) {};

  /// Ordered, subtype-aware matchers. First match wins. Empty by default.
  static List<ResultMatcher> matchers = <ResultMatcher>[];

  /// Builds the [ResultError] for a validation failure (`failIf`/`okIf`). Pure.
  static ResultError Function(Object reason) failBuilder =
      (reason) => ResultError.of(reason);

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

  /// Invoke [onSuccess] for a successful [result], guarded so a throwing
  /// telemetry hook can neither flip a success into a failure nor escape
  /// `try*`. A `try*`/`trySync` body that simply RETURNS an [Err] (without
  /// throwing) is not a success, so [onSuccess] does not fire for it.
  static void notifySuccess(Result<dynamic> result) {
    if (!result.isSuccess) return;
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

  /// Build the [ResultError] payload for a caught [error]: the [matched]
  /// matcher's build, else `ResultError.of(error, stack)` (which preserves the
  /// captured [stack] on the resulting error).
  static ResultError buildError(
    Object error,
    StackTrace? stack,
    ResultMatcher? matched,
  ) {
    if (matched != null) return matched.build(error, stack);
    return ResultError.of(error, stack);
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

  /// Restore every hook and matcher to its default.
  static void reset() {
    onException = (_, __) {};
    onSuccess = (_) {};
    matchers = <ResultMatcher>[];
    failBuilder = (reason) => ResultError.of(reason);
  }
}
