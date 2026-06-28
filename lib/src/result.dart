import 'package:fluent_result/fluent_result.dart';

/// The outcome of an operation: either [Ok] with a value, or [Err] with an error.
///
/// Consume with an exhaustive `switch`:
/// ```dart
/// final label = switch (result) {
///   Ok(:final value) => 'ok: $value',
///   Err(:final error) => 'failed: ${error.message}',
/// };
/// ```
sealed class Result<T> {
  /// Const base constructor.
  const Result();

  /// True for [Ok].
  bool get isSuccess;

  /// True for [Err].
  bool get isFail => !isSuccess;

  /// The success value, or `null` for an [Err]. Prefer pattern matching or
  /// [ResultCombinators.valueOr]/[ResultCombinators.getOrElse]; a convenience
  /// for migration and display.
  T? get valueOrNull;

  /// The error, or `null` for an [Ok].
  ResultError? get error;

  /// The error message, or `''` for an [Ok].
  String get errorMessage => error?.message ?? '';

  /// A value-free success.
  static Result<void> get ok => success();

  /// Wrap an async body that returns a [Result]. Catches exceptions into an
  /// [Err]; rethrows an unmatched `Error`; never rethrows on the normal path.
  static Future<Result<T>> tryAsync<T>(
    Future<Result<T>> Function() body, {
    Result<T> Function(Object e)? onError,
    Result<T> Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) async {
    try {
      final result = await body();
      ResultConfig.notifySuccess(result);
      return result;
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      if (e is Error && matched == null) rethrow;
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onErrorWithStack != null) return onErrorWithStack(e, st);
        if (onError != null) return onError(e);
        return Err<T>(ResultConfig.buildError(e, st, matched));
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return Err<T>(ResultError.of(e, st));
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  /// Synchronous [tryAsync].
  static Result<T> trySync<T>(
    Result<T> Function() body, {
    Result<T> Function(Object e)? onError,
    Result<T> Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) {
    try {
      final result = body();
      ResultConfig.notifySuccess(result);
      return result;
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      if (e is Error && matched == null) rethrow;
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onErrorWithStack != null) return onErrorWithStack(e, st);
        if (onError != null) return onError(e);
        return Err<T>(ResultConfig.buildError(e, st, matched));
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return Err<T>(ResultError.of(e, st));
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  /// Wrap a plain async value-returning body into a [Result].
  static Future<Result<T>> guardAsync<T>(
    Future<T> Function() body, {
    Result<T> Function(Object e)? onError,
    Result<T> Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) =>
      tryAsync<T>(
        () async => Ok<T>(await body()),
        onError: onError,
        onErrorWithStack: onErrorWithStack,
        onFinally: onFinally,
      );

  /// Wrap a plain sync value-returning body into a [Result].
  static Result<T> guard<T>(
    T Function() body, {
    Result<T> Function(Object e)? onError,
    Result<T> Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) =>
      trySync<T>(
        () => Ok<T>(body()),
        onError: onError,
        onErrorWithStack: onErrorWithStack,
        onFinally: onFinally,
      );

  /// Fail with [reason] when [verify] is true, else a value-free success.
  static Result<void> failIf(bool Function() verify, String reason) =>
      verify() ? Err<void>(ResultConfig.failBuilder(reason)) : success();

  /// Succeed when [verify] is true, else fail with [reason].
  static Result<void> okIf(bool Function() verify, String reason) =>
      verify() ? success() : Err<void>(ResultConfig.failBuilder(reason));
}

/// A successful [Result] carrying a [value].
final class Ok<T> extends Result<T> {
  /// Creates a success carrying [value].
  const Ok(this.value);

  /// The success value. Non-null when [T] is non-nullable (the common case);
  /// for a nullable [T] it may be null.
  final T value;

  @override
  bool get isSuccess => true;

  @override
  T? get valueOrNull => value;

  @override
  ResultError? get error => null;

  // Unparameterized `is Ok` keeps `==` symmetric across covariant type args.
  @override
  bool operator ==(Object other) => other is Ok && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);
}

/// A failed [Result] carrying a single [error].
final class Err<T> extends Result<T> {
  /// Creates a failure carrying [error].
  const Err(this.error);

  @override
  final ResultError error;

  @override
  bool get isSuccess => false;

  @override
  T? get valueOrNull => null;

  /// Re-type a failure to another value type (the error is value-agnostic).
  Err<R> cast<R>() => Err<R>(error);

  @override
  bool operator ==(Object other) => other is Err && other.error == error;

  @override
  int get hashCode => Object.hash(Err, error);
}
