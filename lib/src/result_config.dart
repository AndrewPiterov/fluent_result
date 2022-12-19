import 'package:fluent_result/fluent_result.dart';
import 'package:logger/logger.dart';

///
class ResultConfig {
  static final ResultConfig _singleton = ResultConfig._internal();

  ///
  factory ResultConfig() {
    return _singleton;
  }

  ResultConfig._internal();

  static final Logger _logger = Logger();

  static void _defaultSuccessHandler(Result result) {
    _logger.d(
      '🟢 Result success: ${result is ResultOf ? result.value.toString() : result.isSuccess}',
    );
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
      _logger.d('🔴 Failed result', e);
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
