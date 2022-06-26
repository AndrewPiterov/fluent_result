// ignore_for_file: prefer_const_constructors

import 'package:fluent_result/fluent_result.dart';
import 'package:test/test.dart' hide fail;

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
    final res = Result.failWith([
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

  test('either left', () {
    final res = fail([
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

  test('Either with ResultOf<T>', () {
    const someData = 'Some data';
    final res = successWith(someData);

    res.foldWithValue(
      onFail: (error) {
        expect(error, isNull);
      },
      onSuccess: (data) {
        expect(data, someData);
      },
    );
  });
}
