import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  tearDown(ResultConfig.reset);

  test('guard wraps a plain value into a success ResultOf', () {
    final r = ResultOf.guard<int>(() => 42);
    r.isSuccess.should.beTrue();
    r.value.should.be(42);
  });

  test('guard converts a throw into a reported fail', () {
    var count = 0;
    ResultConfig.onException = (_, __) => count++;
    final r = ResultOf.guard<int>(() => throw Exception('boom'));
    r.isFail.should.beTrue();
    count.should.be(1);
  });

  test('guardAsync wraps an async value', () async {
    final r = await ResultOf.guardAsync<int>(() async => 7);
    r.value.should.be(7);
  });

  test('guard onError maps the failure and onFinally always runs', () {
    var finallyRan = false;
    final r = ResultOf.guard<int>(
      () => throw Exception('boom'),
      onError: (e, st) => fail('mapped'),
      onFinally: () => finallyRan = true,
    );
    r.errorMessage.should.be('mapped');
    finallyRan.should.beTrue();
  });
}
