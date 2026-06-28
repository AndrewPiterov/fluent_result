// Regression tests for the 9.0.0 pre-merge adversarial review findings.

import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  tearDown(ResultConfig.reset);

  test('a caught exception lands its stack trace in the Err', () {
    final r = Result.guard<int>(() => throw Exception('boom'));
    r.isFail.should.beTrue();
    r.error!.stackTrace.should.not.beNull();
  });

  test('onSuccess does NOT fire for a body-returned Err, nor is it reported',
      () async {
    var successes = 0;
    var reports = 0;
    ResultConfig.onSuccess = (_) => successes++;
    ResultConfig.onException = (_, __) => reports++;
    final r = await Result.tryAsync<int>(() async => fail('x'));
    r.isFail.should.beTrue();
    successes.should.be(0);
    reports.should.be(0);
  });

  test('a throwing failBuilder cannot escape the try* catch path', () async {
    ResultConfig.matchers = [
      ResultMatcher((e) => true, (e, st) => throw StateError('build bug')),
    ];
    ResultConfig.failBuilder = (r) => throw StateError('failBuilder bug');
    final r = await Result.tryAsync<void>(() async => throw Exception('boom'));
    r.isFail.should.beTrue();
  });
}
