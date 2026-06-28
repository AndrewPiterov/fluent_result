import 'package:fluent_result/fluent_result.dart';

// Cached value-free success. `Ok<void>(null)` is valid (the void value is
// statically unreadable, which is fine — nothing reads it).
const Result<void> _okVoid = Ok<void>(null);

/// A value-free success.
Result<void> success() => _okVoid;

/// A success carrying [value].
Result<T> successWith<T>(T value) => Ok<T>(value);

/// A failure built from [reason] (an `Object`, `Exception`, or `ResultError`).
Result<T> fail<T>(Object reason) => Err<T>(ResultError.of(reason));
