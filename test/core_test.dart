// ignore_for_file: prefer_const_constructors

import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

class _SubError extends ResultError {
  const _SubError(super.message);
}

void main() {
  test('sealed exhaustive switch, non-null Ok.value', () {
    final Result<int> r = successWith(10);
    final label = switch (r) {
      Ok(:final value) => value + 1, // value is non-null int
      Err(:final error) => -1 * error.message.length,
    };
    label.should.be(11);
  });

  test('isSuccess/isFail, valueOrNull, error, errorMessage', () {
    successWith(1).isSuccess.should.beTrue();
    fail<int>('boom').isFail.should.beTrue();
    successWith(1).valueOrNull.should.be(1);
    fail<int>('boom').valueOrNull.should.beNull();
    successWith(1).error.should.beNull();
    fail<int>('boom').errorMessage.should.be('boom');
    successWith(1).errorMessage.should.be('');
  });

  test('value-free success is Result<void>, cached and equal', () {
    final a = success();
    final b = success();
    a.isSuccess.should.beTrue();
    (a == b).should.beTrue();
    Result.ok.isSuccess.should.beTrue();
  });

  test('equality is value-based and SYMMETRIC across type args', () {
    (successWith(1) == successWith(1)).should.beTrue();
    (successWith(1) == successWith(2)).should.beFalse();
    (fail<int>('e') == fail<int>('e')).should.beTrue();
    // symmetry: Ok<int>(1) vs Ok<num>(1)
    final Result<num> x = Ok<int>(1);
    final Result<num> y = Ok<num>(1);
    (x == y).should.be(y == x); // both true
    // hashCode contract + Set de-dup
    final set = <Result<int>>{successWith(1)};
    set.contains(successWith(1)).should.beTrue();
    set.add(successWith(1));
    set.length.should.be(1);
  });

  test('Err.cast re-types the error', () {
    final Err<int> e = Err<int>(const ResultError('nope'));
    final Err<String> c = e.cast<String>();
    c.error.message.should.be('nope');
  });

  test('ResultError carries code/cause/stackTrace; runtimeType in equality', () {
    final cause = Exception('x');
    final st = StackTrace.current;
    final err = ResultError('msg', code: 'E1', cause: cause, stackTrace: st);
    err.code.should.be('E1');
    err.cause.should.be(cause);
    err.stackTrace.should.be(st);
    (const ResultError('same') == const ResultError('same')).should.beTrue();
    (const ResultError('same') == const _SubError('same')).should.beFalse();
    ResultError.of(const ResultError('reuse')).message.should.be('reuse');
  });
}
