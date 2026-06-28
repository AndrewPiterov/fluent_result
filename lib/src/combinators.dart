import 'package:fluent_result/fluent_result.dart';

/// Value combinators over a sealed [Result].
extension ResultCombinators<T> on Result<T> {
  /// Transform a success value; pass an [Err] through unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok(:final value) => Ok<R>(transform(value)),
        final Err<T> e => e.cast<R>(),
      };

  /// Chain a success into another [Result]; pass an [Err] through unchanged.
  Result<R> flatMap<R>(Result<R> Function(T value) next) => switch (this) {
        Ok(:final value) => next(value),
        final Err<T> e => e.cast<R>(),
      };

  /// Async [flatMap].
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T value) next,
  ) async =>
      switch (this) {
        Ok(:final value) => await next(value),
        final Err<T> e => e.cast<R>(),
      };

  /// Collapse into a single value by handling both branches.
  R fold<R>(
    R Function(T value) onOk,
    R Function(ResultError error) onErr,
  ) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Err(:final error) => onErr(error),
      };

  /// Named-parameter form of [fold].
  R match<R>({
    required R Function(T value) onOk,
    required R Function(ResultError error) onErr,
  }) =>
      fold(onOk, onErr);

  /// The success value, or [fallback] on an [Err].
  T valueOr(T fallback) => switch (this) {
        Ok(:final value) => value,
        Err() => fallback,
      };

  /// The success value, or the result of [orElse] on an [Err].
  T getOrElse(T Function(ResultError error) orElse) => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => orElse(error),
      };

  /// Turn an [Err] into an [Ok] via [recovery]; a no-op on an [Ok].
  Result<T> recover(T Function(ResultError error) recovery) => switch (this) {
        Ok() => this,
        Err(:final error) => Ok<T>(recovery(error)),
      };

  /// Transform the error of an [Err]; a no-op on an [Ok].
  Result<T> mapError(ResultError Function(ResultError error) transform) =>
      switch (this) {
        Ok() => this,
        Err(:final error) => Err<T>(transform(error)),
      };
}
