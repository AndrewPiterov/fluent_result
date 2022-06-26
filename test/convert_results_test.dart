// ignore_for_file: avoid_redundant_argument_values

import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Convert success Result', () {
    test('to another success Result', () {
      final result = getRandomCustomer(id: 1);

      expect(result.isSuccess, true);

      final detailedResult = result.map((customer) => User(customer.id));
      expect(detailedResult.value is User, true);
      expect(detailedResult.value!.id == 1, true);
    });
  });

  group('Convert fail Result', () {
    test('to another fail Result', () {
      const reason = 'customer not found';
      final res = getCustomer(failReason: reason);
      res.isFail.should.beTrue();
      res.errorMessage.should.be(reason);
      res.error.should.beOfType<CustomerNotFound>();
    });

    test('to another fail Result on user', () {
      const reason = 'user not found';
      final res = getCustomerWithFailOnUser(failReason: reason);
      res.isFail.should.beTrue();
      res.errorMessage.should.be(reason);
      res.error.should.beOfType<UserNotFound>();
    });
  });
}

ResultOf<Customer?> getCustomerWithFailOnUser({String? failReason}) {
  final userResult = getUser(failReason: failReason);
  if (userResult.isFail) {
    return userResult.map();
  }

  return Customer(1, 'Andrew').asResult();
}

ResultOf<Customer?> getCustomer({String? failReason}) {
  final userResult = getUser();
  if (userResult.isFail) {
    return userResult.map();
  }

  if (failReason != null) {
    return ResultOf.failWith(CustomerNotFound(failReason));
  }

  return Customer(1, 'Andrew').asResult();
}

ResultOf<User?> getUser({String? failReason}) {
  if (failReason != null) {
    return ResultOf.failWith(UserNotFound(failReason));
  }
  return const User(1).asResult();
}

class UserNotFound extends ResultError {
  UserNotFound(String message) : super(message);
}

class CustomerNotFound extends ResultError {
  CustomerNotFound(String message) : super(message);
}
