import 'package:easy_todo/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    group('ServerFailure', () {
      test('should have correct message', () {
        const failure = ServerFailure(message: 'Server error');
        expect(failure.message, 'Server error');
      });

      test('two ServerFailures with same message should be equal', () {
        const f1 = ServerFailure(message: 'Error');
        const f2 = ServerFailure(message: 'Error');
        expect(f1, equals(f2));
      });

      test('two ServerFailures with different messages should not be equal', () {
        const f1 = ServerFailure(message: 'Error 1');
        const f2 = ServerFailure(message: 'Error 2');
        expect(f1, isNot(equals(f2)));
      });
    });

    group('CacheFailure', () {
      test('should have correct message', () {
        const failure = CacheFailure(message: 'Cache error');
        expect(failure.message, 'Cache error');
      });

      test('two CacheFailures with same message should be equal', () {
        const f1 = CacheFailure(message: 'Cache miss');
        const f2 = CacheFailure(message: 'Cache miss');
        expect(f1, equals(f2));
      });
    });

    group('AuthFailure', () {
      test('should have correct message', () {
        const failure = AuthFailure(message: 'Auth error');
        expect(failure.message, 'Auth error');
      });

      test('two AuthFailures with same message should be equal', () {
        const f1 = AuthFailure(message: 'Invalid credentials');
        const f2 = AuthFailure(message: 'Invalid credentials');
        expect(f1, equals(f2));
      });
    });

    group('NetworkFailure', () {
      test('should have correct message', () {
        const failure = NetworkFailure(message: 'No internet');
        expect(failure.message, 'No internet');
      });
    });

    test('different failure types with same message should not be equal', () {
      const serverFailure = ServerFailure(message: 'Error');
      const authFailure = AuthFailure(message: 'Error');
      expect(serverFailure, isNot(equals(authFailure)));
    });
  });
}
