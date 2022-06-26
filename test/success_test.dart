import 'package:fluent_result/fluent_result.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart' hide fail;

void main() {
  test('success', () {
    success().isFail.should.beFalse();
  });

  test('success 2', () {
    const username = 'my_username';
    final usernameResult = getUsername(username);
    usernameResult.isFail.should.beFalse();
    usernameResult.value.should.be(username);
  });

  test('fail', () {
    const reason = 'not found';
    final res = getUsernameFail(reason);
    res.isFail.should.beTrue();
    res.error.should.be(const ResultError(reason));
    res.errorMessage.should.be(reason);
  });
}

ResultOf<String> getUsername(String username) {
  return successWith(username);
}

ResultOf<String?> getUsernameFail(String failReason) {
  return fail(failReason);
}
