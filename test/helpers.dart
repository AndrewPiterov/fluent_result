import 'package:fluent_result/fluent_result.dart';

class Customer {
  Customer(this.id, this.name);

  final int id;
  final String name;
}

ResultOf<Customer> getRandomCustomer() {
  final customer = Customer(1, 'Andrew');
  return ResultOf.success(customer);
}

Result getRandomCustomerForNonGeneric() {
  final customer = Customer(777, 'Andrew');
  return ResultOf.success(customer);
}
