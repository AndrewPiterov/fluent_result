import 'package:fluent_result/fluent_result.dart';
import 'package:given_when_then_unit_test/res/given.dart';
import 'package:given_when_then_unit_test/res/test_fixtures.dart';
import 'package:given_when_then_unit_test/res/then.dart';
import 'package:given_when_then_unit_test/res/when.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  given('Result config with custom error matchers', () {
    ResultConfig.exceptionHandlerMatchers = {
      DioError: (e, st) {
        // ignore: avoid_print
        print(
          '🟠 MY ERROR RESULT: $e',
        );
        final failure = ResultOf.failWith(DioErrorResult(e as DioError));
        return failure;
      },
    };

    when('Dio error occurs', () {
      late Result res;
      before(() {
        res = Result.trySync(() {
          throw DioError(401, 'Unauthorized');
        });
      });

      then(
        'should be Dio error result',
        () {
          res.error.should.beOfType<DioErrorResult>();
        },
        and: {
          'should show formatted Dio message': () {
            // ignore: avoid_print
            print((res.error! as DioErrorResult).formattedMessage);
          }
        },
      );
    });
  });

  when('common exception occurs', () {
    late Result res;
    before(() {
      res = Result.trySync(() {
        throw 'Some exception';
      });
    });

    then('should be ResultError', () {
      res.error.should.beOfType<ResultError>();
    });
  });
}

/// Third party error
class DioError extends Error {
  DioError(this.status, this.message);

  final int status;
  final String message;
}

/// Third party error result
class DioErrorResult extends ResultError {
  DioErrorResult(this.error) : super(error.message);

  final DioError error;

  String get formattedMessage => '[${error.status}]: ${error.message}';
}
