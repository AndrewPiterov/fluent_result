// ignore_for_file: prefer_const_constructors

import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('object ro result', () {
    const Object val = 1;
    final intRes = val.asResult();
    intRes.should.be(ResultOf.success(1));
  });

  test('int ro result', () {
    final intRes = 1.asResult();
    intRes.should.be(ResultOf.success(1));
  });

  test('bool ro result', () {
    final intRes = true.asResult();
    intRes.should.be(ResultOf.success(true));
  });

  test('string ro result', () {
    final intRes = 'Flutter'.asResult();
    intRes.should.be(ResultOf.success('Flutter'));
  });

  test('double ro result', () {
    final intRes = 1.23.asResult();
    intRes.should.be(ResultOf.success(1.23));
  });

  test('map ro result', () {
    final intRes = {'name': 'Andrew'}.asResult();
    intRes.should.be(ResultOf.success({'name': 'Andrew'}));
  });

  test('list ro result', () {
    final intRes = [1, 2, 3].asResult();
    intRes.should.be(ResultOf.success([1, 2, 3]));
  });

  test('custom object ro result', () {
    final intRes = const User(123).asResult();
    intRes.should.be(ResultOf.success(const User(123)));
  });

  test('the error should be ErrorResult', () {
    final res = ArgumentError().asResult();
    res.isFail.should.beTrue();
    // res.should.be(Result)
  });

  test('the error should be ErrorResult', () {
    final res = ResultError('some error').asResult();
    res.isFail.should.beTrue();
    // res.should.be(Result)
  });

  test('the exception should be ErrorResult', () {
    final res = Exception('some exception').asResult();
    res.isFail.should.beTrue();
    // res.should.be(Result)
  });
}
