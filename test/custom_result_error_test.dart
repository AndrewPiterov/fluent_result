// ignore_for_file: prefer_const_constructors

import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Result Error', () {
    test('is fail with custom error', () {
      final result = Result.fail(const CustomerNotFound(customerId: 33));
      expect(result.isFail, true);
      expect(result.isSuccess, false);
      expect(result.error is CustomerNotFound, true);
      expect(result.errorMessage!.contains('not found'), true);
      expect(result.errorMessage!.contains('33'), true);
    });

    test('with error message', () {
      final result = Result.withErrorMessage('error message');
      expect(result.isFail, true);
    });
  });

  test('Many errors', () {
    final err1 = CustomerNotFound(customerId: 1);
    final err2 = InvalidPasswordError('The password 123456 is invalid');
    final res = Result.fails([err1, err2]);

    res.isFail.should.beTrue();

    final err1Copy = CustomerNotFound(customerId: 1);
    res.contains<CustomerNotFound>().should.beTrue();

    final err2Copy = InvalidPasswordError('The password 123456 is invalid');
    res.contains<InvalidPasswordError>().should.beTrue();
  });

  test('Caontains error', () {
    final err1 = CustomerNotFound(customerId: 1);
    final res = Result.fail(err1);

    res.contains<CustomerNotFound>().should.beTrue();
    res.get<CustomerNotFound>().should.not.beNull();
    res.contains<InvalidPasswordError>().should.beFalse();
    res.get<InvalidPasswordError>().should.beNull();

    final err2 = InvalidPasswordError('The password 123456 is invalid');
    res.add(err2);
    res.contains<InvalidPasswordError>().should.beTrue();
    res.get<InvalidPasswordError>().should.not.beNull();
  });

  test('Add error', () {
    final err1 = CustomerNotFound(customerId: 1);
    final err2 = InvalidPasswordError('The password 123456 is invalid');
    final res = Result.fail(err1);

    res.add(err2);
  });

  test('Equal results', () {
    final err1 = CustomerNotFound(customerId: 1);
    final err2 = InvalidPasswordError('The password 123456 is invalid');
    final res1 = Result.fails([err1, err2]);

    final err11 = CustomerNotFound(customerId: 1);
    final err22 = InvalidPasswordError('The password 123456 is invalid');
    final res2 = Result.fails([err11, err22]);

    res2.should.be(res1);
  });
}
