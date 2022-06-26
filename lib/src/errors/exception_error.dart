import 'package:fluent_result/fluent_result.dart';

/// Result Error caused by exception
class ResultException extends ResultError {
  ///
  ResultException(this.exception) : super(exception.toString());

  ///
  final Exception exception;
}
