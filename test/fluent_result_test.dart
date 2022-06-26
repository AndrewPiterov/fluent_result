// ignore_for_file: prefer_const_declarations

import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Non-generic Result', () {
    test('is success', () {
      final result = Result.ok;
      expect(result.isFail, false);
      expect(result.isSuccess, true);
    });

    test('is fail and has message', () {
      const errorMessage = 'Some error';
      final result = Result.withErr(const ResultError(errorMessage));
      result.isFail.should.beTrue();
      result.isSuccess.should.beFalse();
      expect(result.errorMessage, errorMessage);
    });
  });

  group('Generic Result', () {
    test('is success', () {
      const data = 'Some date';
      final result = ResultOf.success(data);
      expect(result.isFail, false);
      expect(result.isSuccess, true);
      expect(result.value == data, true);
    });

    test('has value', () {
      final customerResult = getRandomCustomer();
      expect(customerResult.isSuccess, true);
      customerResult.value.should.not.beNull();
    });

    test('is fail and has message', () {
      const errorMessage = 'Some error';
      final result = ResultOf.withError(ResultError(errorMessage));
      expect(result.isFail, true);
      expect(result.value == null, true);
      expect(result.errorMessage, errorMessage);
    });

    test('fail message', () {
      final result = Result.withErrorMessage('fail');
      expect(result.isFail, true);
      expect(result.error is ResultError, true);
    });

    test('fail message 2', () {
      final result = ResultOf.withErrorMessage<Customer>('fail reason');
      expect(result.isFail, true);
      expect(result.error is ResultError, true);
    });

    test('with exception', () {
      final message = 'fail';
      final result = Result.withException(FormatException(message));
      expect(result.isFail, true);
      expect(result.error is ResultException, true);
      expect(result.error!.message.contains(message), true);
    });

    test('generic with exception', () {
      final message = 'fail';
      final result = ResultOf.withException<User>(FormatException(message));
      expect(result.isFail, true);
      expect(result.error is ResultException, true);
      expect(result.error!.message.contains(message), true);
    });
  });

  group('wrapper', () {
    test('success sync call', () {
      final res = Result.trySync(() {
        print('Done');
      });

      res.isSuccess.should.beTrue();
    });

    test('fail sync call', () {
      final res = Result.trySync(() {
        throw 'Some exception';
      });

      res.isFail.should.beTrue();
      res.errorMessage.should.not.beNullOrEmpty();
    });

    test('success async call', () async {
      final res = await Result.tryAsync(() async {
        await Future.delayed(const Duration(seconds: 2));
        print('Done');
      });

      res.isSuccess.should.beTrue();
    });

    test('fail async call', () async {
      const errMessage = 'Some exception';
      final res = await Result.tryAsync(() async {
        await Future.delayed(const Duration(seconds: 2));
        print('Done');
        throw errMessage;
      });

      res.isFail.should.beTrue();
      res.errorMessage.should.be(errMessage);
    });
  });

  group('wrapper of', () {
    test('success sync call', () {
      final res = ResultOf.trySync(() {
        print('Done');
        return 1;
      });

      res.isSuccess.should.beTrue();
      res.value.should.be(1);
    });

    test('fail sync call', () {
      final res = ResultOf.trySync(() {
        throw 'Some exception';
      });

      res.isFail.should.beTrue();
      res.errorMessage.should.not.beNullOrEmpty();
    });

    test('success async call', () async {
      final res = await ResultOf.tryAsync(() async {
        await Future.delayed(const Duration(seconds: 2));
        print('Done');
        return 2;
      });

      res.isSuccess.should.beTrue();
      res.value.should.be(2);
    });

    test('fail async call', () async {
      const errMessage = 'Some exception';
      final res = await ResultOf.tryAsync<bool>(() async {
        await Future.delayed(const Duration(seconds: 2));
        print('Done');
        throw errMessage;
      });

      res.isFail.should.beTrue();
      res.errorMessage.should.be(errMessage);
    });
  });
}
