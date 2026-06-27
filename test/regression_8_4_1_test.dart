// ignore_for_file: prefer_const_constructors

// Regression tests for the 8.4.1 patch.
//
// C2 - Result.hashCode stability / Set & Map usability
// C3 - ResultOf.map() preserves all errors of a multi-error fail
// C4 - foldWithValue/map throw a clear StateError (not an opaque TypeError)
//      when a non-nullable success value is null

import 'package:fluent_result/fluent_result.dart';
import 'package:test/test.dart' hide fail;

void main() {
  group('C2: hashCode contract', () {
    test('is stable across reads of the same instance', () {
      final result = Result.failWith(['a', 'b']);
      expect(result.hashCode, result.hashCode);
    });

    test('equal results have equal hashCodes', () {
      final r1 = Result.failWith(['a', 'b']);
      final r2 = Result.failWith(['a', 'b']);
      expect(r1, r2);
      expect(r1.hashCode, r2.hashCode);
    });

    test('success results hash equally', () {
      expect(Result.ok.hashCode, Result.success().hashCode);
    });

    test('a Result is found in a Set, even via an equal-but-distinct key', () {
      final result = Result.failWith(['a', 'b']);
      final set = {result};
      expect(set.contains(result), isTrue);
      expect(set.contains(Result.failWith(['a', 'b'])), isTrue);
    });

    test('serves as a Map key', () {
      final map = {Result.failWith(['a', 'b']): 1};
      expect(map[Result.failWith(['a', 'b'])], 1);
    });
  });

  group('C3: map() preserves every error', () {
    test('mapping a multi-error fail keeps all errors', () {
      final failed = ResultOf.failWith<int>(['e1', 'e2', 'e3']);
      expect(failed.errors.length, 3);

      final mapped = failed.map<String>((value) => value.toString());

      expect(mapped.isFail, isTrue);
      expect(mapped.errors.length, 3);
      expect(
        mapped.errors.map((e) => e.message).toList(),
        ['e1', 'e2', 'e3'],
      );
    });

    test('passthrough map of a single-error fail keeps its error type', () {
      final failed = ResultOf.failWith<int>('boom');
      final mapped = failed.map<String>();

      expect(mapped.isFail, isTrue);
      expect(mapped.errorMessage, 'boom');
    });
  });

  group('C4: incoherent non-null success with null value', () {
    test('foldWithValue throws StateError, not TypeError', () {
      final incoherent = ResultOf<String>(isSuccess: true, value: null);
      expect(
        () => incoherent.foldWithValue(
          onFail: (_) {},
          onSuccess: (_) {},
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('map throws StateError, not TypeError', () {
      final incoherent = ResultOf<String>(isSuccess: true, value: null);
      expect(
        () => incoherent.map<int>((s) => s.length),
        throwsA(isA<StateError>()),
      );
    });

    test('a legitimately nullable success value is preserved', () {
      final ok = successWith<String?>(null);
      String? captured = 'unset';
      ok.foldWithValue(
        onFail: (_) {},
        onSuccess: (value) => captured = value,
      );
      expect(captured, isNull);
    });
  });
}
