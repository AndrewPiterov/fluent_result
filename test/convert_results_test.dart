// ignore_for_file: avoid_redundant_argument_values

import 'package:fluent_result/fluent_result.dart';
import 'package:fluent_result/src/result_error.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Convert success Result', () {
    test('to another succes Result', () {
      final result = getRandomCustomer(id: 1);

      expect(result.isSuccess, true);

      final detailedResult =
          result.toResult(valueConverter: (customer) => User(customer.id));
      expect(detailedResult.value is User, true);
      expect(detailedResult.value!.id == 1, true);
    });
  });

  group('Convert fail Result', () {
    test('to another fail Result', () {
      final result = ResultOf.fail<User>(const ResultError('user not found'));

      expect(result.isFail, true);

      final detailedResult = result.toResult<Customer>();
      expect(detailedResult.value == null, true);
    });
  });
}
