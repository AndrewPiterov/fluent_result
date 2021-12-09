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
  Result.fail(ResultError error)
      : isSuccess = false,
        _errors = [error];

  /// Create fail `Result` with reason
  /// ```dart
  /// Result.fail(ResultError('fail reason'));
  /// ```
  Result.fails(List<ResultError> errors)
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
  bool contains(ResultError error) => errors.contains(error);

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
