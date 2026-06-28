import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  tearDown(ResultConfig.reset);

  test('defaults: no-op hooks, empty matchers, failBuilder, sentinel bridge',
      () {
    ResultConfig.matchers.should.beEmpty();
    // failBuilder turns a reason into a fail Result.
    final r = ResultConfig.failBuilder('boom');
    r.isFail.should.beTrue();
    r.errorMessage.should.be('boom');
    // exceptionHandler not overridden => buildFailResult falls through to
    // failBuilder (rule 4), proving the sentinel bridge is in place.
    ResultConfig.buildFailResult('x', null, null).errorMessage.should.be('x');
  });

  test('logSuccessResult is a forwarding alias of onSuccess', () {
    Result? seen;
    // ignore: deprecated_member_use_from_same_package
    ResultConfig.logSuccessResult = (r) => seen = r;
    ResultConfig.onSuccess(Result.ok);
    seen.should.not.beNull();
  });

  test('reset restores every hook, matcher and alias', () {
    ResultConfig.onException = (_, __) {};
    ResultConfig.onSuccess = (_) {};
    ResultConfig.matchers = [ResultMatcher((e) => true, (e, st) => fail(e))];
    ResultConfig.failBuilder = (r) => fail('x');
    // ignore: deprecated_member_use_from_same_package
    ResultConfig.exceptionHandler = (e, st) => fail(e);
    // ignore: deprecated_member_use_from_same_package
    ResultConfig.exceptionHandlerMatchers = {String: (e, st) => fail(e)};

    ResultConfig.reset();

    ResultConfig.matchers.should.beEmpty();
    // ignore: deprecated_member_use_from_same_package
    ResultConfig.exceptionHandlerMatchers.should.beEmpty();
    ResultConfig.failBuilder('boom').errorMessage.should.be('boom');
    // exceptionHandler restored to the sentinel => buildFailResult uses
    // failBuilder again, not the custom handler set above.
    ResultConfig.buildFailResult('boom', null, null)
        .errorMessage
        .should
        .be('boom');
  });

  test('ResultMatcher carries test/build/expected', () {
    final m = ResultMatcher(
      (e) => e is StateError,
      (e, st) => fail(e),
      expected: true,
    );
    m.test(StateError('x')).should.beTrue();
    m.test(Exception('x')).should.beFalse();
    m.expected.should.beTrue();
    m.build(StateError('x'), null).isFail.should.beTrue();
  });
}
