import 'package:test/test.dart';
import 'package:fluent_result/fluent_result.dart';

import 'helpers.dart';

void main() {
  group('Result Error', () {
    test('is fail with custom error', () {
      final result = Result.fail(const CustomerNotFound(customerId: 33));
      expect(result.isFail, true);
      expect(result.isSuccess, false);
      expect(result.error is CustomerNotFound, true);
      expect(result.errorMessage.contains('not found'), true);
      expect(result.errorMessage.contains('33'), true);
    });
  });
}
