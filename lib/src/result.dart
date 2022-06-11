import 'package:collection/collection.dart';
import 'package:fluent_result/src/result_error.dart';
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

  /// Create fail `Result` with reason
  /// ```dart
  /// Result.fail(ResultError('fail reason'));
  /// ```
  @Deprecated('use withError instead')
  Result.fail(ResultError error)
      : isSuccess = false,
        _errors = [error];

  /// Create fail `Result` with reason
  /// ```dart
  /// Result.fail(ResultError('fail reason'));
  /// ```
  @Deprecated('use withErrors instead')
  Result.fails(List<ResultError> errors)
      : isSuccess = false,
        _errors = errors;

  /// Create fail `Result` with reason
  /// ```dart
  /// Result.fail(ResultError('fail reason'));
  /// ```
  Result.withError(ResultError error)
      : isSuccess = false,
        _errors = [error];

  /// Create fail `Result` with reason
  /// ```dart
  /// Result.fail(ResultError('fail reason'));
  /// ```
  Result.withErrors(List<ResultError> errors)
      : isSuccess = false,
        _errors = errors;

  ///
  Result.withErrorMessage(String message)
      : _errors = [ResultError(message)],
        isSuccess = false;

  ///
  Result.withException(Exception exception)
      : _errors = [ResultException(exception)],
        isSuccess = false;

  /// Returns whether the `Result` is success
  final bool isSuccess;

  /// Returns whether the `Result` is fail
  bool get isFail => !isSuccess;

  final List<ResultError> _errors;

  ///
  List<ResultError> get errors => _errors;

  ///
  ResultError? get error => errors.isEmpty ? null : errors.first;

  /// The reason why operation has been failed
  String? get errorMessage => error?.message;

  /// Contains the Result a error or not
  bool contains<T extends ResultError>() => get<T>() != null;

  /// try get the specific error
  T? get<T extends ResultError>() =>
      errors.firstWhereOrNull((element) => element is T) as T?;

  /// Add another error
  void add(ResultError error) {
    _errors.add(error);
  }

  /// Add other errors
  void addAll(List<ResultError> errors) {
    _errors.addAll(errors);
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
      return Result.withErrorMessage(reason);
    }

    return Result.ok;
  }

  ///
  // ignore: prefer_constructors_over_static_methods
  static Result okIf(bool Function() verify, String reason) {
    if (!verify()) {
      return Result.withErrorMessage(reason);
    }

    return Result.ok;
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
