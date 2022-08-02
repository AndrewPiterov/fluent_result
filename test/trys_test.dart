import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Custom error handler for Result', () {
    test('with sync', () {
      const errorMessage = 'Some error';
      final res = Result.trySync(
        () => throw errorMessage,
        onError: (e) => fail(1),
      );
      res.errorMessage.should.be('1');
    });

    test('with async', () async {
      const errorMessage = 'Some error';
      final res = await Result.tryAsync(
        () async => throw errorMessage,
        onError: (e) => fail(1),
      );
      res.errorMessage.should.be('1');
    });
  });

  group('Custom error handler for ResultOf<T>', () {
    test('with sync', () {
      const errorMessage = 'Some error';
      final res = ResultOf.trySync(
        () => throw errorMessage,
        onError: (e) => fail(1),
      );
      res.errorMessage.should.be('1');
    });

    test('with async', () async {
      const errorMessage = 'Some error';
      final res = await ResultOf.tryAsync(
        () async => throw errorMessage,
        onError: (e) => fail(1),
      );
      res.errorMessage.should.be('1');
    });
  });
}
