import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  tearDown(ResultConfig.reset);

  test('an Exception always becomes Err (never rethrows)', () async {
    final r = await Result.tryAsync<void>(() async => throw Exception('boom'));
    r.isFail.should.beTrue();
  });

  test('an unmatched Error RETHROWS from tryAsync', () async {
    Object? thrown;
    try {
      await Result.tryAsync<void>(() async => throw StateError('bug'));
    } catch (e) {
      thrown = e;
    }
    thrown.should.beOfType<StateError>();
  });

  test('an unmatched Error RETHROWS from sync guard', () {
    Object? thrown;
    try {
      Result.guard<int>(() => throw StateError('bug'));
    } catch (e) {
      thrown = e;
    }
    thrown.should.beOfType<StateError>();
  });

  test('a MATCHED Error becomes Err and does NOT rethrow', () async {
    ResultConfig.matchers = [
      ResultMatcher((e) => e is StateError, (e, st) => ResultError.of(e)),
    ];
    final r =
        await Result.tryAsync<void>(() async => throw StateError('claimed'));
    r.isFail.should.beTrue();
    r.errorMessage.should.contain('claimed');
  });
}
