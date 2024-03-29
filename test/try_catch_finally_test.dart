import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  const expectedErrorMessage = 'Some error';
  const expectedFinallyErrorMessage = 'finally error';

  test(
    'finally is calling in Result.trySync',
    () {
      var actualFinallyErrorMessage = '';
      final res = Result.trySync(
        () {
          throw expectedErrorMessage;
        },
        onError: (e) {
          return fail(e);
        },
        onFinally: () {
          actualFinallyErrorMessage = expectedFinallyErrorMessage;
        },
      );
      res.errorMessage.should.be(expectedErrorMessage);
      actualFinallyErrorMessage.should.be(expectedFinallyErrorMessage);
    },
  );

  test(
    'finally is calling in Result.tryAsync',
    () async {
      var actualFinallyErrorMessage = '';
      final res = await Result.tryAsync(
        () {
          throw expectedErrorMessage;
        },
        onError: (e) {
          return fail(e);
        },
        onFinally: () {
          actualFinallyErrorMessage = expectedFinallyErrorMessage;
        },
      );
      res.errorMessage.should.be(expectedErrorMessage);
      actualFinallyErrorMessage.should.be(expectedFinallyErrorMessage);
    },
  );

  test(
    'finally is calling in ResultOf.trySync',
    () {
      var actualFinallyErrorMessage = '';
      final res = ResultOf.trySync(
        () {
          throw expectedErrorMessage;
        },
        onError: (e) {
          return fail(e);
        },
        onFinally: () {
          actualFinallyErrorMessage = expectedFinallyErrorMessage;
        },
      );
      res.errorMessage.should.be(expectedErrorMessage);
      actualFinallyErrorMessage.should.be(expectedFinallyErrorMessage);
    },
  );

  test(
    'finally is calling in ResultOf.tryAsync',
    () async {
      var actualFinallyErrorMessage = '';
      final res = await ResultOf.tryAsync(
        () {
          throw expectedErrorMessage;
        },
        onError: (e) {
          return fail(e);
        },
        onFinally: () {
          actualFinallyErrorMessage = expectedFinallyErrorMessage;
        },
      );
      res.errorMessage.should.be(expectedErrorMessage);
      actualFinallyErrorMessage.should.be(expectedFinallyErrorMessage);
    },
  );
}
