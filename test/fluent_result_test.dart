import 'package:test/test.dart';
import 'package:fluent_result/fluent_result.dart';

import 'helpers.dart';

void main() {
  group('Non-generic Result', () {
    test('is success', () {
      final result = Result.ok;
      expect(result.isFail, false);
      expect(result.isSuccess, true);
    });

    test('is fail and has message', () {
      const errorMessage = 'Some error';
      final result = Result.fail(errorMessage);
      expect(result.isFail, true);
      expect(result.isSuccess, false);
      expect(result.errorMessage, errorMessage);
    });
  });

  group('Generic Result', () {
    test('is success', () {
      const data = 'Some date';
      final result = ResultOf.success(data);
      expect(result.isFail, false);
      expect(result.isSuccess, true);
      expect(result.value == data, true);
    });

    test('has value', () {
      final customer = getRandomCustomer();
      expect(customer.isSuccess, true);
      expect(customer.value != null, true);
    });

    test('is fail and has message', () {
      const errorMessage = 'Some error';
      final result = ResultOf.fail<Customer>(errorMessage);
      expect(result.isFail, true);
      expect(result.isSuccess, false);
      expect(result.value == null, true);
      expect(result.errorMessage, errorMessage);
    });
  });
}
