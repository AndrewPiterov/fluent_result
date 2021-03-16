import 'package:fluent_result/fluent_result.dart';
import 'package:fluent_result/src/result_error.dart';

class Customer {
  Customer(this.id, this.name);

  final int id;
  final String name;
}

class User {
  User(this.id);
  final int id;
}

ResultOf<Customer> getRandomCustomer({int id = 1}) {
  final customer = Customer(id, 'Andrew');
  return ResultOf.success(customer);
}

Result getRandomCustomerForNonGeneric() {
  final customer = Customer(777, 'Andrew');
  return ResultOf.success(customer);
}

class CustomerNotFound extends ResultError {
  const CustomerNotFound({
    required this.customerId,
  }) : super('Customer not found with ID $customerId');

  final int customerId;

  @override
  String toString() => message;
}

// class DetailedCustomerNotFound extends ResultError {
//   const DetailedCustomerNotFound({
//     @required this.customerId,
//     this.phoneNumber,
//   }) : super(
//             'Customer not found with ID $customerId and phone number $phoneNumber');

//   final int customerId;
//   final String phoneNumber;

//   @override
//   String toString() => message;
// }
