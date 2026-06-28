import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

class _DioLikeError extends Error {
  _DioLikeError(this.message);
  final String message;
}

void main() {
  tearDown(ResultConfig.reset);

  test('overridden exceptionHandler is honored verbatim (rule 1)', () async {
    // ignore: deprecated_member_use_from_same_package
    ResultConfig.exceptionHandler = (e, st) => fail('custom: $e');
    final r = await Result.tryAsync(() async => throw Exception('x'));
    r.errorMessage.should.be('custom: Exception: x');
  });

  test(
      'legacy exceptionHandlerMatchers map dispatched by exact runtimeType '
      '(rule 3), incl. an Error subtype', () async {
    // ignore: deprecated_member_use_from_same_package
    ResultConfig.exceptionHandlerMatchers = {
      _DioLikeError: (e, st) => fail('dio: ${(e as _DioLikeError).message}'),
    };
    final r = await Result.tryAsync(() async => throw _DioLikeError('timeout'));
    r.errorMessage.should.be('dio: timeout');
  });

  test(
      'B2: overridden reporting handler + onException reports twice '
      '(documented combination)', () async {
    var count = 0;
    // ignore: deprecated_member_use_from_same_package
    ResultConfig.exceptionHandler = (e, st) {
      count++; // legacy handler also reports
      return fail(e);
    };
    ResultConfig.onException = (_, __) => count++;
    await Result.tryAsync(() async => throw Exception('x'));
    count.should.be(2); // documented: move reporting into onException to avoid
  });
}
