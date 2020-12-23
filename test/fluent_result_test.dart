import 'package:flutter_test/flutter_test.dart';

import 'package:fluent_result/fluent_result.dart';

class Customer {
  final int id;
  final String name;

  Customer(this.id, this.name);
}

Result<Customer> getRandomCustomer() {
  final customer = Customer(1, 'Andrew');
  return Result.success(value: customer);
}

Result getRandomCustomerForNonGeneric() {
  final customer = Customer(777, 'Andrew');
  return Result.success(value: customer);
}

void main() {
  group('Non-generic Result', () {
    test('is success', () {
      final result = Result.success();
      expect(result.isFail, false);
      expect(result.isSuccess, true);
      expect(result.value == null, true);
    });

    test('is fail and has message', () {
      const String errorMessage = 'Some error';
      final result = Result.fail(errorMessage);
      expect(result.isFail, true);
      expect(result.isSuccess, false);
      expect(result.value == null, true);
      expect(result.errorMessage, errorMessage);
    });

    test('with value', () {
      final result = getRandomCustomerForNonGeneric();
      expect(result.isFail, false);
      expect(result.isSuccess, true);
      expect(result.value is Customer, true);
    });
  });

  group('Generic Result', () {
    test('is success', () {
      const String data = 'Some date';
      final result = Result.success(value: data);
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
      const String errorMessage = 'Some error';
      final result = Result.fail(errorMessage);
      expect(result.isFail, true);
      expect(result.isSuccess, false);
      expect(result.value == null, true);
      expect(result.errorMessage, errorMessage);
    });
  });
}
