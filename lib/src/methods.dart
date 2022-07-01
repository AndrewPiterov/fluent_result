import 'package:fluent_result/fluent_result.dart';

/// Success result
Result success() {
  return Result.ok;
}

/// Success result with value
ResultOf<T> successWith<T>(T value) {
  return ResultOf.success(value);
}

/// Fail result with reason
ResultOf<T?> fail<T>(dynamic reason) {
  return ResultOf.failWith(reason);
}
