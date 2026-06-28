import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  test('fail returns ResultOf<T> (assignable to ResultOf<T?> by covariance)',
      () {
    final ResultOf<int> typed = fail<int>('boom');
    typed.isFail.should.beTrue();
    // covariance: ResultOf<int> is-a ResultOf<int?>
    final ResultOf<int?> widened = typed;
    widened.isFail.should.beTrue();
  });

  test('failWith returns ResultOf<T>', () {
    final ResultOf<String> r = ResultOf.failWith<String>('x');
    r.isFail.should.beTrue();
  });
}
