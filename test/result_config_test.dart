import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  test('with default exception handler', () {
    final res = Result.trySync(() {
      throw 'Some exception';
    });

    res.isFail.should.beTrue();
    res.errorMessage.should.not.beNullOrEmpty();
  });

  test('with custom exception handler', () {
    ResultConfig.exceptionHandler = (e) {
      // ignore: avoid_print
      print(' 🟢 Fail: $e ');
      return fail(e);
    };

    final res = Result.trySync(() {
      throw 'Some exception';
    });

    res.isFail.should.beTrue();
    res.errorMessage.should.not.beNullOrEmpty();
  });

  test('with custom exception handler when async call', () async {
    ResultConfig.exceptionHandler = (e) {
      // ignore: avoid_print
      print(' 🟣 Fail: $e ');
      return fail(e);
    };

    final res = await ResultOf.tryAsync(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      // ignore: avoid_print
      print('Done');
      return successWith(2);
    });

    res.isSuccess.should.beTrue();
    res.value.should.be(2);
  });
}
