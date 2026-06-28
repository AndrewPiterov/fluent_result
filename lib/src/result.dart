import 'package:collection/collection.dart';
import 'package:fluent_result/fluent_result.dart';

final _eq = const ListEquality().equals;

/// `Result` is an object indicating success or failure of an operation
class Result {
  /// Creates a result with the given [isSuccess] state and optional [errors].
  const Result({
    required this.isSuccess,
    List<ResultError> errors = const [],
  }) : _errors = errors;

  /// Create success `Result` with value
  /// ```dart
  /// Result.success();
  /// ```
  const Result.success()
      : isSuccess = true,
        _errors = const [];

  /// Result with fail reason
  /// ```dart
  /// Result.failWith('fail reason');
  /// ```
  factory Result.failWith(Object reason) {
    final List<Object> reasons =
        reason is Iterable ? reason.toList().cast() : [reason];
    return Result(
      isSuccess: false,
      errors: reasons.map((e) => ResultError.of(e)).toList(),
    );
  }

  /// Returns whether the `Result` is success
  final bool isSuccess;

  /// Returns whether the `Result` is fail
  bool get isFail => !isSuccess;

  final List<ResultError> _errors;

  /// All errors attached to this result (empty for a success).
  List<ResultError> get errors => List.unmodifiable(_errors);

  /// The first error, or `null` when there are none.
  ResultError? get error => errors.isEmpty ? null : errors.first;

  /// The reason why operation has been failed
  String get errorMessage => error?.message ?? '';

  /// Contains the Result a error or not
  bool contains<T extends ResultError>() => get<T>() != null;

  /// try get the specific error
  T? get<T extends ResultError>() =>
      errors.firstWhereOrNull((e) => e is T) as T?;

  /// Add another error
  void add(Object reason) {
    _errors.add(ResultError.of(reason));
  }

  /// Add other errors
  void addAll(List<Object> errors) {
    _errors.addAll(errors.map((e) => ResultError.of(e)));
  }

  /// Returns success `Result`
  // ignore: prefer_constructors_over_static_methods
  static Result get ok => const Result.success();

  /// Fold the `result`
  void fold({
    required Function(List<ResultError> errors) onFail,
    required Function() onSuccess,
  }) {
    if (isFail) {
      onFail(errors);
    } else {
      onSuccess();
    }
  }

  /// Fails with [reason] when [verify] returns `true`; otherwise succeeds.
  // ignore: prefer_constructors_over_static_methods
  static Result failIf(bool Function() verify, String reason) {
    if (verify()) {
      return ResultConfig.failBuilder(reason);
    }

    return Result.ok;
  }

  /// Succeeds when [verify] returns `true`; otherwise fails with [reason].
  // ignore: prefer_constructors_over_static_methods
  static Result okIf(bool Function() verify, String reason) {
    if (!verify()) {
      return ResultConfig.failBuilder(reason);
    }

    return Result.ok;
  }

  /// Wrapped on try/catch.
  ///
  /// On a thrown error, an unexpected exception is reported once via
  /// `ResultConfig.onException` (matcher-`expected` errors are not), then the
  /// fail result is built. [onErrorWithStack] takes precedence over [onError].
  /// Never rethrows: a throwing handler is reported and falls back to a plain
  /// fail of the original error.
  factory Result.trySync(
    Result Function() func, {
    Result Function(dynamic e)? onError,
    Result Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) {
    try {
      final result = func();
      ResultConfig.notifySuccess(result);
      return result;
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onErrorWithStack != null) return onErrorWithStack(e, st);
        if (onError != null) return onError(e);
        return ResultConfig.buildFailResult(e, st, matched);
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return ResultConfig.failBuilder(e);
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  /// Wrapped on try/catch. See [Result.trySync] for the error semantics.
  static Future<Result> tryAsync(
    Future<Result> Function() func, {
    Result Function(dynamic e)? onError,
    Result Function(Object e, StackTrace st)? onErrorWithStack,
    void Function()? onFinally,
  }) async {
    try {
      final result = await func();
      ResultConfig.notifySuccess(result);
      return result;
    } catch (e, st) {
      final matched = ResultConfig.classify(e);
      ResultConfig.reportIfUnexpected(e, st, matched);
      try {
        if (onErrorWithStack != null) return onErrorWithStack(e, st);
        if (onError != null) return onError(e);
        return ResultConfig.buildFailResult(e, st, matched);
      } catch (handlerError, handlerSt) {
        ResultConfig.safeReport(handlerError, handlerSt);
        return ResultConfig.failBuilder(e);
      }
    } finally {
      ResultConfig.guardFinally(onFinally);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Result &&
      other.isSuccess == isSuccess &&
      _eq(other.errors, errors);

  @override
  int get hashCode => Object.hash(isSuccess, Object.hashAll(_errors));

  @override
  String toString() =>
      isFail ? errors.map((e) => e.toString()).join('\n') : 'Success';
}
