import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  test('fail if', () {
    const firstName = '';
    final res = Result.failIf(() => firstName.isEmpty, 'First name is empty');
    res.should.be(Result.failWith('First name is empty'));
  });

  test('ok if', () {
    const firstName = 'Andrew';
    final res = Result.okIf(
      () => firstName.isNotEmpty,
      'First name should not be empty',
    );
    res.should.be(Result.ok);
  });
}
