import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  test('this test should fail', () {
    final result = _someFunc();
    result.isFail.should.beTrue();
  });
}

Result _someFunc() {
  return Result.trySync(() {
    throw 'some error';
  });
}
