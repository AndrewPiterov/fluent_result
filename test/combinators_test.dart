import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  test('flatMap chains a success into another Result', () {
    final r = successWith(2).flatMap<int>((v) => successWith(v * 10));
    r.value.should.be(20);
  });

  test('flatMap on a fail passes ALL errors through, does not call next', () {
    var called = false;
    final r = ResultOf.failWith<int>(['e1', 'e2']).flatMap<int>((v) {
      called = true;
      return successWith(0);
    });
    called.should.beFalse();
    r.errors.length.should.be(2);
  });

  test('flatMapAsync chains async', () async {
    final r =
        await successWith(3).flatMapAsync<int>((v) async => successWith(v + 1));
    r.value.should.be(4);
  });

  test('match returns a value on both branches', () {
    successWith(5).match(onFail: (_) => -1, onSuccess: (v) => v).should.be(5);
    ResultOf.failWith<int>('x')
        .match(onFail: (_) => -1, onSuccess: (v) => v)
        .should
        .be(-1);
  });

  test('valueOr / getOrElse fall back on fail', () {
    ResultOf.failWith<int>('x').valueOr(99).should.be(99);
    ResultOf.failWith<int>('x').getOrElse(() => 7).should.be(7);
    successWith(1).valueOr(99).should.be(1);
  });

  test('recover turns a fail into a success; no-op on success', () {
    ResultOf.failWith<int>('x').recover((_) => 42).value.should.be(42);
    successWith(1).recover((_) => 42).value.should.be(1);
  });

  test('mapError transforms EVERY error (multi-error preserved)', () {
    final r = ResultOf.failWith<int>(['a', 'b'])
        .mapError((e) => ResultError('[${e.message}]'));
    expect(r.errors.map((e) => e.message).toList(), ['[a]', '[b]']);
  });
}
