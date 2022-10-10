import 'dart:developer';

import 'package:fluent_result/fluent_result.dart';

///
class ResultConfig {
  static final ResultConfig _singleton = ResultConfig._internal();

  ///
  factory ResultConfig() {
    return _singleton;
  }

  ResultConfig._internal();

  static void _defaultSuccessHandler(Result result) {
    log('🟢 Result success: ${result is ResultOf ? result.value.toString() : result.isSuccess}');
  }

  static ResultOf<dynamic> _defaultExceptionHandler(dynamic e) {
    if (exceptionHandlerMatchers.containsKey(e.runtimeType)) {
      return exceptionHandlerMatchers[e.runtimeType]!(e);
    }

    _defaultExceptionHandlerMatchers[Exception]!(e);
    return fail(e);
  }

  static final Map<Type, ResultOf Function(dynamic e)>
      _defaultExceptionHandlerMatchers = {
    Exception: (e) {
      log('🔴 $e', name: 'Result');
      return fail(e);
    },
  };

  /// Log a success result
  static void Function(Result result) logSuccessResult = _defaultSuccessHandler;

  /// Log a fail result
  static ResultOf Function(dynamic e) exceptionHandler =
      _defaultExceptionHandler;

  ///
  static Map<Type, ResultOf Function(dynamic e)> exceptionHandlerMatchers =
      _defaultExceptionHandlerMatchers;
}
