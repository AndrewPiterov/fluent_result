import 'package:fluent_result/fluent_result.dart';
import 'package:test/test.dart';

void main() {
  test('either right', () {
    final res = Result.ok;

    // assert
    res.fold(
      onFail: (errors) {
        expect(errors, isNotEmpty);
      },
      onSuccess: () {
        expect(1, 1);
      },
    );
  });

  test('either left', () {
    final res = Result.withErrors([
      ResultError('some error'),
      ResultError('some error 2'),
    ]);

    // assert
    res.fold(
      onFail: (errors) {
        expect(errors, isNotEmpty);
        expect(res.errors.length, 2);
      },
      onSuccess: () {
        expect(0, 1);
      },
    );
  });

  // test('either', () {
  //   const someData = 'Some data';
  //   final res = ResultOf.success(someData);

  //   res.either(
  //     left: (error) {
  //       expect(error, isNull);
  //     },
  //     right: (data) {
  //       expect(data, someData);
  //     },
  //   );
  // });
}
