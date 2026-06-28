import 'package:fluent_result/fluent_result.dart';

void main() {
  // 1. Configure global observability once (e.g. wire Sentry here).
  ResultConfig.onException = (error, stack) {
    // ignore: avoid_print
    print('Reported unexpected: $error');
  };
  ResultConfig.matchers = [
    // Expected control flow - fail quietly, do NOT report.
    ResultMatcher(
      (e) => e is FormatException,
      (e, st) => fail(e),
      expected: true,
    ),
  ];

  // 2. Wrap a throwing computation; never rethrows.
  final parsed = ResultOf.guard<int>(() => int.parse('not-a-number'));
  final message = parsed.match(
    onFail: (errors) => 'parse failed: ${errors.first.message}',
    onSuccess: (value) => 'parsed $value',
  );
  // ignore: avoid_print
  print(message);

  // 3. Validation never reaches onException.
  final v = Result.failIf(() => message.isEmpty, 'message required');
  // ignore: avoid_print
  print(v.isFail ? v.errorMessage : 'ok');
}
