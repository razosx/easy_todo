import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_todo/features/auth/data/models/user_model.dart';
import 'package:easy_todo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  const tUserModel = UserModel(id: 'uid-1', email: 'test@test.com');

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('signInWithEmail', () {
    test('should return UserEntity when data source call succeeds', () async {
      when(
        () => mockDataSource.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.signInWithEmail(
        email: 'test@test.com',
        password: '123456',
      );

      expect(result, const Right(tUserModel));
    });

    test('should return AuthFailure when AuthException is thrown', () async {
      when(
        () => mockDataSource.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException(message: 'Invalid credentials'));

      final result = await repository.signInWithEmail(
        email: 'test@test.com',
        password: 'wrong',
      );

      expect(result, const Left(AuthFailure(message: 'Invalid credentials')));
    });

    test(
      'should return ServerFailure when ServerException is thrown',
      () async {
        when(
          () => mockDataSource.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const ServerException(message: 'Server error'));

        final result = await repository.signInWithEmail(
          email: 'test@test.com',
          password: '123456',
        );

        expect(result, const Left(ServerFailure(message: 'Server error')));
      },
    );
  });

  group('signInWithGoogle', () {
    test('should return UserEntity when Google sign in succeeds', () async {
      when(
        () => mockDataSource.signInWithGoogle(),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.signInWithGoogle();

      expect(result, const Right(tUserModel));
    });

    test('should return AuthFailure when AuthException is thrown', () async {
      when(
        () => mockDataSource.signInWithGoogle(),
      ).thenThrow(const AuthException(message: 'Cancelled'));

      final result = await repository.signInWithGoogle();

      expect(result, const Left(AuthFailure(message: 'Cancelled')));
    });
  });

  group('signOut', () {
    test('should return void when sign out succeeds', () async {
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right(null));
    });

    test(
      'should return ServerFailure when ServerException is thrown',
      () async {
        when(
          () => mockDataSource.signOut(),
        ).thenThrow(const ServerException(message: 'Sign out error'));

        final result = await repository.signOut();

        expect(result, const Left(ServerFailure(message: 'Sign out error')));
      },
    );
  });
}
