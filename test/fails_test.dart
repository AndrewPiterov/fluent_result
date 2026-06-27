import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  test('trySync wraps a thrown String into a fail result', () {
    final result = _someFunc();
    result.isFail.should.beTrue();
  });
}

Result _someFunc() {
  return Result.trySync(() {
    throw 'some error';
  });
}
