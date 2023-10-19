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
      time: DateTime.now(),
    );
  }

  static ResultOf<dynamic> _defaultExceptionHandler(dynamic e, StackTrace? st) {
    if (exceptionHandlerMatchers.containsKey(e.runtimeType)) {
      return exceptionHandlerMatchers[e.runtimeType]!(e, st);
    }

    final closure = _defaultExceptionHandlerMatchers[Exception];
    if (closure != null) {
      return closure(e, st);
    }
    return fail(e);
  }

  static final Map<Type, ResultOf Function(dynamic e, StackTrace? stackTrace)>
      _defaultExceptionHandlerMatchers = {
    Exception: (e, stackTrace) {
      _logger.d(
        '🔴 Failed result',
        error: e,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      return fail(e);
    },
  };

  /// Log a success result
  static void Function(Result result) logSuccessResult = _defaultSuccessHandler;

  /// Log a fail result
  static ResultOf Function(dynamic e, StackTrace? st) exceptionHandler =
      _defaultExceptionHandler;

  ///
  static Map<Type, ResultOf Function(dynamic e, StackTrace? st)>
      exceptionHandlerMatchers = _defaultExceptionHandlerMatchers;
}
