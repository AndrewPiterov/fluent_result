// ignore_for_file: prefer_const_constructors

// Regression tests for the 8.5.0 pre-merge adversarial review findings.

import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  tearDown(ResultConfig.reset);

  test('a throwing matcher.test never escapes and the original is reported',
      () async {
    final reported = <Object>[];
    ResultConfig.onException = (e, __) => reported.add(e);
    ResultConfig.matchers = [
      ResultMatcher((e) => throw StateError('test bug'), (e, st) => fail(e)),
    ];
    final original = Exception('boom');
    final r = await Result.tryAsync(() async => throw original);
    r.isFail.should.beTrue(); // did not rethrow
    reported.contains(original).should.beTrue(); // original still reported
  });

  test('a throwing matcher.test never escapes guard (sync)', () {
    ResultConfig.matchers = [
      ResultMatcher((e) => throw StateError('test bug'), (e, st) => fail(e)),
    ];
    final r = ResultOf.guard<int>(() => throw Exception('boom'));
    r.isFail.should.beTrue();
  });

  test('a throwing onSuccess does not flip a success into a fail', () async {
    ResultConfig.onSuccess = (_) => throw StateError('telemetry bug');
    final r = await Result.tryAsync(() async => success());
    r.isSuccess.should.beTrue();
  });

  test('recover throws StateError on an incoherent non-null success with null',
      () {
    final incoherent = ResultOf<int>(isSuccess: true, value: null);
    expect(() => incoherent.recover((_) => 0), throwsA(isA<StateError>()));
  });

  test('mapError throws StateError on an incoherent non-null success with null',
      () {
    final incoherent = ResultOf<int>(isSuccess: true, value: null);
    expect(
      () => incoherent.mapError((e) => ResultError('x')),
      throwsA(isA<StateError>()),
    );
  });
}
