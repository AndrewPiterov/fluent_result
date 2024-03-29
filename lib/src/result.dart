import 'package:collection/collection.dart';
import 'package:fluent_result/fluent_result.dart';
import 'package:quiver/core.dart';

final _eq = const ListEquality().equals;

/// `Result` is an object indicating success or failure of an operation
class Result {
  ///
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

  ///
  List<ResultError> get errors => List.unmodifiable(_errors);

  ///
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

  ///
  // ignore: prefer_constructors_over_static_methods
  static Result failIf(bool Function() verify, String reason) {
    if (verify()) {
      return ResultConfig.exceptionHandler(reason, null);
    }

    return Result.ok;
  }

  ///
  // ignore: prefer_constructors_over_static_methods
  static Result okIf(bool Function() verify, String reason) {
    if (!verify()) {
      return ResultConfig.exceptionHandler(reason, null);
    }

    return Result.ok;
  }

  /// Wrapped on try/catch
  factory Result.trySync(
    Result Function() func, {
    Result Function(dynamic e)? onError,
    void Function()? onFinally,
  }) {
    try {
      final result = func();
      // ResultConfig.logResult(result);
      return result;
    } catch (e, st) {
      if (onError != null) {
        return onError(e);
      }
      return ResultConfig.exceptionHandler(e, st);
    } finally {
      onFinally?.call();
    }
  }

  /// Wrapped on try/catch
  static Future<Result> tryAsync(
    Future<Result> Function() func, {
    Result Function(dynamic e)? onError,
    void Function()? onFinally,
  }) async {
    try {
      final result = await func();
      // ResultConfig.logResult(result);
      return result;
    } catch (e, st) {
      if (onError != null) {
        return onError(e);
      }
      return ResultConfig.exceptionHandler(e, st);
    } finally {
      onFinally?.call();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Result &&
      other.isSuccess == isSuccess &&
      _eq(other.errors, errors);

  @override
  int get hashCode => hash2(
        isSuccess.hashCode,
        errors.hashCode,
      );

  @override
  String toString() =>
      isFail ? errors.map((e) => e.toString()).join('\n') : 'Success';
}
