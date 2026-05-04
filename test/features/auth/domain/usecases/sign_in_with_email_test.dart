import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithEmail usecase;
  late MockAuthRepository mockRepository;

  const tUser = UserEntity(
    id: 'uid-1',
    email: 'test@test.com',
    displayName: 'Test User',
  );
  const tParams = SignInWithEmailParams(
    email: 'test@test.com',
    password: '123456',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInWithEmail(mockRepository);
  });

  test('should return UserEntity when sign in succeeds', () async {
    when(
      () => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(tUser));

    final result = await usecase(tParams);

    expect(result, const Right(tUser));
    verify(
      () => mockRepository.signInWithEmail(
        email: 'test@test.com',
        password: '123456',
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return AuthFailure when credentials are invalid', () async {
    when(
      () => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const Left(AuthFailure(message: 'Invalid credentials')),
    );

    final result = await usecase(tParams);

    expect(result, const Left(AuthFailure(message: 'Invalid credentials')));
  });

  test('should return ServerFailure when a server error occurs', () async {
    when(
      () => mockRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'Server error')),
    );

    final result = await usecase(tParams);

    expect(result, const Left(ServerFailure(message: 'Server error')));
  });
}
