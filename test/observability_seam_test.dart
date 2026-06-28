import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  tearDown(ResultConfig.reset);

  test('onException fires once for an unexpected caught exception', () async {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    final r = await Result.tryAsync(() async => throw Exception('boom'));
    r.isFail.should.beTrue();
    count.should.be(1);
  });

  test('onException does NOT fire for a matcher-expected exception', () async {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    ResultConfig.matchers = [
      ResultMatcher((e) => e is StateError, (e, st) => fail(e), expected: true),
    ];
    final r = await Result.tryAsync(() async => throw StateError('cancel'));
    r.isFail.should.beTrue();
    count.should.be(0);
  });

  test('onException fires even when onError is supplied (O8)', () async {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    final r = await Result.tryAsync(
      () async => throw Exception('boom'),
      onError: (e) => fail('mapped'),
    );
    r.errorMessage.should.be('mapped');
    count.should.be(1);
  });

  test('onException does NOT fire for failIf/okIf validation', () {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    Result.failIf(() => true, 'bad').isFail.should.beTrue();
    Result.okIf(() => false, 'bad').isFail.should.beTrue();
    count.should.be(0);
  });

  test('onSuccess fires once on a successful tryAsync', () async {
    var count = 0;
    ResultConfig.onSuccess = (_) => count++;
    await Result.tryAsync(() async => success());
    count.should.be(1);
  });

  test('a throwing matcher.build never escapes - fall back to fail', () async {
    ResultConfig.matchers = [
      ResultMatcher((e) => true, (e, st) => throw StateError('handler bug')),
    ];
    final r = await Result.tryAsync(() async => throw Exception('boom'));
    r.isFail.should.beTrue();
    r.errorMessage.should.be('Exception: boom');
  });

  test('onErrorWithStack wins over onError and receives the stack', () async {
    StackTrace? seen;
    final r = await Result.tryAsync(
      () async => throw Exception('boom'),
      onError: (e) => fail('plain'),
      onErrorWithStack: (e, st) {
        seen = st;
        return fail('with-stack');
      },
    );
    r.errorMessage.should.be('with-stack');
    seen.should.not.beNull();
  });
}
