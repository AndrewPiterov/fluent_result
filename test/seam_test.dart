import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  tearDown(ResultConfig.reset);

  test('onException fires once for an unexpected exception', () async {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    final r = await Result.tryAsync<void>(() async => throw Exception('boom'));
    r.isFail.should.beTrue();
    count.should.be(1);
  });

  test('onException does NOT fire for a matcher-expected exception', () async {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    ResultConfig.matchers = [
      ResultMatcher(
        (e) => e is FormatException,
        (e, st) => ResultError.of(e),
        expected: true,
      ),
    ];
    await Result.tryAsync<void>(() async => throw const FormatException('x'));
    count.should.be(0);
  });

  test('onException fires even when onError is supplied (O8)', () async {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    final r = await Result.tryAsync<int>(
      () async => throw Exception('boom'),
      onError: (e) => fail('mapped'),
    );
    r.errorMessage.should.be('mapped');
    count.should.be(1);
  });

  test('failIf/okIf never report; onSuccess fires once on success', () async {
    var reports = 0;
    var successes = 0;
    ResultConfig.onException = (_, __) => reports++;
    ResultConfig.onSuccess = (_) => successes++;
    Result.failIf(() => true, 'bad').isFail.should.beTrue();
    Result.okIf(() => false, 'bad').isFail.should.beTrue();
    await Result.tryAsync<void>(() async => success());
    reports.should.be(0);
    successes.should.be(1);
  });

  test('a throwing matcher build never escapes - falls back to fail', () async {
    ResultConfig.matchers = [
      ResultMatcher((e) => true, (e, st) => throw StateError('handler bug')),
    ];
    final r = await Result.tryAsync<void>(() async => throw Exception('boom'));
    r.isFail.should.beTrue();
    r.errorMessage.should.be('Exception: boom');
  });

  test('a throwing matcher test never escapes and the original is reported',
      () async {
    final reported = <Object>[];
    ResultConfig.onException = (e, __) => reported.add(e);
    ResultConfig.matchers = [
      ResultMatcher(
        (e) => throw StateError('test bug'),
        (e, st) => ResultError.of(e),
      ),
    ];
    final original = Exception('boom');
    final r = await Result.tryAsync<void>(() async => throw original);
    r.isFail.should.beTrue(); // did not escape
    reported.contains(original).should.beTrue(); // original still reported
  });

  test('a throwing onSuccess neither flips the success nor rethrows', () async {
    ResultConfig.onSuccess = (_) => throw StateError('telemetry bug');
    final r = await Result.tryAsync<int>(() async => successWith(7));
    r.isSuccess.should.beTrue();
    r.valueOrNull.should.be(7);
  });

  test('reset round-trips a customized failBuilder', () {
    ResultConfig.failBuilder = (r) => const ResultError('custom');
    ResultConfig.reset();
    ResultConfig.failBuilder('boom').message.should.be('boom');
  });
}
