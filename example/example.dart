import 'package:fluent_result/fluent_result.dart';

void main() {
  // Configure global observability once (e.g. wire Sentry here).
  ResultConfig.onException = (error, stack) {
    // ignore: avoid_print
    print('Reported unexpected: $error');
  };
  ResultConfig.matchers = [
    // Expected control flow - fail quietly, do NOT report.
    ResultMatcher(
      (e) => e is FormatException,
      (e, st) => ResultError.of(e),
      expected: true,
    ),
  ];

  // Wrap a throwing computation; never rethrows an Exception.
  final parsed = Result.guard<int>(() => int.parse('not-a-number'));
  final message = switch (parsed) {
    Ok(:final value) => 'parsed $value',
    Err(:final error) => 'parse failed: ${error.message}',
  };
  // ignore: avoid_print
  print(message);

  // Validation never reaches onException.
  final v = Result.failIf(() => message.isEmpty, 'message required');
  // ignore: avoid_print
  print(v.isFail ? v.errorMessage : 'ok');
}
