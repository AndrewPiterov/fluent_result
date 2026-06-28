import 'package:fluent_result/fluent_result.dart';

/// Generic version of `Result` that holds value
class ResultOf<T> extends Result {
  ///
  ResultOf({
    required bool isSuccess,
    required this.value,
    List<ResultError> error = const [],
  }) : super(
          isSuccess: isSuccess,
          errors: error,
        );

  /// Value of result
  final T? value;

  // ignore: prefer_constructors_over_static_methods
  /// Create success `Result` with value
  /// ```dart
  /// ResultOf.success(MyObject());
  /// ```
  static ResultOf<T> success<T>(T data) =>
      ResultOf<T>(isSuccess: true, value: data);

  /// Result with fail reason
  /// ```dart
  /// ResultOf.failWith('fail reason');
  /// ```
  static ResultOf<T> failWith<T>(dynamic reason) {
    final List reasons = reason is Iterable ? reason.toList().cast() : [reason];

    return ResultOf<T>(
      isSuccess: false,
      value: null,
      error: reasons.map((e) => ResultError.of(e)).toList(),
    );
  }

  /// Wrapped on try/catch.
  ///
  /// On a thrown error, an unexpected exception is reported once via
  /// `ResultConfig.onException` (matcher-`expected` errors are not), then the
  /// fail result is built. [onErrorWithStack] takes precedence over [onError].
  /// Never rethrows: a throwing handler is reported and falls back to a plain
  /// fail of the original error.
  static ResultOf<T?> trySync<T>(
    ResultOf<T?> Function() func, {
    ResultOf<T?> Function(dynamic e)? onError,
    ResultOf<T?> Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) {
    try {
      final result = func();
      ResultConfig.onSuccess(result);
      return result;
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onErrorWithStack != null) return onErrorWithStack(e, st);
        if (onError != null) return onError(e);
        return ResultConfig.buildFailResult(e, st, matched).map();
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return ResultConfig.failBuilder(e).map();
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  /// Wrapped on try/catch. See [ResultOf.trySync] for the error semantics.
  static Future<ResultOf<T?>> tryAsync<T>(
    Future<ResultOf<T?>> Function() func, {
    ResultOf<T?> Function(dynamic e)? onError,
    ResultOf<T?> Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) async {
    try {
      final result = await func();
      ResultConfig.onSuccess(result);
      return result;
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onErrorWithStack != null) return onErrorWithStack(e, st);
        if (onError != null) return onError(e);
        return ResultConfig.buildFailResult(e, st, matched).map();
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return ResultConfig.failBuilder(e).map();
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  /// Wrap a plain, possibly-throwing [body] into a [ResultOf]. Unlike
  /// `trySync`, [body] returns a bare value, not a pre-lifted Result. A throw
  /// is reported via `ResultConfig.onException` (unless a matcher flags it
  /// expected) and converted to a fail; the call never rethrows.
  static ResultOf<T?> guard<T>(
    T Function() body, {
    ResultOf<T?> Function(Object e, StackTrace st)? onError,
    void Function()? onFinally,
  }) {
    try {
      return ResultOf<T?>(isSuccess: true, value: body());
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onError != null) return onError(e, st);
        return ResultConfig.buildFailResult(e, st, matched).map();
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return ResultConfig.failBuilder(e).map();
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  /// Async counterpart to [guard]; wraps a `Future`-returning [body].
  static Future<ResultOf<T?>> guardAsync<T>(
    Future<T> Function() body, {
    ResultOf<T?> Function(Object e, StackTrace st)? onError,
    void Function()? onFinally,
  }) async {
    try {
      return ResultOf<T?>(isSuccess: true, value: await body());
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onError != null) return onError(e, st);
        return ResultConfig.buildFailResult(e, st, matched).map();
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return ResultConfig.failBuilder(e).map();
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  /// Fold the `result`
  void foldWithValue({
    required Function(List<ResultError> errors) onFail,
    required Function(T value) onSuccess,
  }) {
    if (isFail) {
      onFail(errors);
    } else {
      onSuccess(_successValue());
    }
  }

  /// Safely read the success [value] as a non-null [T].
  ///
  /// Throws a [StateError] when the result is a success but its [value] is
  /// `null` while [T] is non-nullable — an incoherent state that previously
  /// surfaced as an opaque `TypeError` from `value as T`. A legitimately
  /// nullable [T] (where `null is T`) is preserved and never throws.
  T _successValue() {
    if (value == null && null is! T) {
      throw StateError(
        'ResultOf<$T> is success but its value is null. A non-nullable '
        'success value cannot be null; use ResultOf<$T?> if a null success '
        'value is intended.',
      );
    }
    return value as T;
  }

  /// <summary>
  /// Convert result with value to result with another value. Use valueConverter
  /// parameter to specify the value transformation logic.
  ///
  /// No need valueConverter for Fail result. But for Success you should define it.
  /// </summary>
  ResultOf<U?> map<U>([U Function(T)? valueConverter]) {
    if (isSuccess) {
      if (valueConverter == null) {
        throw Exception(
          'If result is success then valueConverter should not be null',
        );
      }
      return ResultOf.success<U>(valueConverter(_successValue()));
    }

    return ResultOf<U?>(isSuccess: false, value: null, error: errors.toList());
  }

  /// Chain a successful value into another [ResultOf]. On a fail, [next] is not
  /// called and ALL errors pass through unchanged.
  ResultOf<U?> flatMap<U>(ResultOf<U?> Function(T value) next) {
    if (isFail) {
      return ResultOf<U?>(
        isSuccess: false,
        value: null,
        error: errors.toList(),
      );
    }
    return next(_successValue());
  }

  /// Async counterpart to [flatMap].
  Future<ResultOf<U?>> flatMapAsync<U>(
    Future<ResultOf<U?>> Function(T value) next,
  ) async {
    if (isFail) {
      return ResultOf<U?>(
        isSuccess: false,
        value: null,
        error: errors.toList(),
      );
    }
    return next(_successValue());
  }

  /// Collapse this result into a single value of type [R] by handling both
  /// branches. The value-returning counterpart to [foldWithValue].
  R match<R>({
    required R Function(List<ResultError> errors) onFail,
    required R Function(T value) onSuccess,
  }) {
    return isFail ? onFail(errors) : onSuccess(_successValue());
  }

  /// The success value, or [fallback] when this is a fail.
  T valueOr(T fallback) => isFail ? fallback : _successValue();

  /// The success value, or the result of [orElse] when this is a fail.
  T getOrElse(T Function() orElse) => isFail ? orElse() : _successValue();

  /// Turn a fail into a recovered success via [recovery]. A success passes
  /// through unchanged.
  ResultOf<T?> recover(T Function(List<ResultError> errors) recovery) {
    if (isSuccess) {
      return ResultOf<T?>(isSuccess: true, value: value);
    }
    return ResultOf<T?>(isSuccess: true, value: recovery(errors));
  }

  /// Transform EVERY error 1:1, preserving the full error bag. No-op on success.
  ResultOf<T?> mapError(ResultError Function(ResultError error) transform) {
    if (isSuccess) {
      return ResultOf<T?>(isSuccess: true, value: value);
    }
    return ResultOf<T?>(
      isSuccess: false,
      value: null,
      error: errors.map(transform).toList(),
    );
  }
}
