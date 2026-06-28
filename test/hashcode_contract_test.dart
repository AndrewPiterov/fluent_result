import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  test('equal results have equal, stable hashCodes', () {
    final a = Result.failWith('e');
    final b = Result.failWith('e');
    (a == b).should.beTrue();
    a.hashCode.should.be(b.hashCode);
    a.hashCode.should.be(a.hashCode); // stable across calls
    final set = <Result>{a};
    set.contains(b).should.beTrue();
  });
}
