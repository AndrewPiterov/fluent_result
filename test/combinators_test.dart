import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  test('map transforms Ok, passes Err through', () {
    successWith(2).map((v) => v * 10).valueOrNull.should.be(20);
    fail<int>('e').map((v) => v * 10).isFail.should.beTrue();
  });

  test('flatMap chains Ok, passes Err through', () {
    successWith(2).flatMap((v) => successWith(v + 1)).valueOrNull.should.be(3);
    var called = false;
    fail<int>('e').flatMap((v) {
      called = true;
      return successWith(0);
    }).isFail.should.beTrue();
    called.should.beFalse();
  });

  test('flatMapAsync chains async', () async {
    final r = await successWith(3).flatMapAsync((v) async => successWith(v + 1));
    r.valueOrNull.should.be(4);
  });

  test('fold and match return a value on both branches', () {
    successWith(5).fold((v) => v, (e) => -1).should.be(5);
    fail<int>('x').fold((v) => v, (e) => -1).should.be(-1);
    successWith(5).match(onOk: (v) => v, onErr: (e) => -1).should.be(5);
  });

  test('valueOr / getOrElse fall back on Err', () {
    fail<int>('x').valueOr(99).should.be(99);
    fail<int>('x').getOrElse((e) => 7).should.be(7);
    successWith(1).valueOr(99).should.be(1);
  });

  test('recover turns Err into Ok; no-op on Ok', () {
    fail<int>('x').recover((e) => 42).valueOrNull.should.be(42);
    successWith(1).recover((e) => 42).valueOrNull.should.be(1);
  });

  test('mapError transforms the error; no-op on Ok', () {
    final r = fail<int>('a').mapError((e) => ResultError('[${e.message}]'));
    r.errorMessage.should.be('[a]');
    successWith(1)
        .mapError((e) => const ResultError('x'))
        .isSuccess
        .should
        .beTrue();
  });
}
