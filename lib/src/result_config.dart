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

  static ResultOf<dynamic> _defaultExceptionHandler(dynamic e) {
    log('🔴 FAIL: $e');
    return fail(e);
  }

  ///
  static ResultOf Function(dynamic e) exceptionHandler =
      _defaultExceptionHandler;
}
