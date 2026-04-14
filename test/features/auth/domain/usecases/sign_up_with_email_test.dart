import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpWithEmail usecase;
  late MockAuthRepository mockRepository;

  const tUser = UserEntity(id: 'uid-2', email: 'new@test.com');
  const tParams = SignUpWithEmailParams(email: 'new@test.com', password: 'password123');

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignUpWithEmail(mockRepository);
  });

  test('should return UserEntity when sign up succeeds', () async {
    when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Right(tUser));

    final result = await usecase(tParams);

    expect(result, const Right(tUser));
    verify(() => mockRepository.signUpWithEmail(
          email: 'new@test.com',
          password: 'password123',
        )).called(1);
  });

  test('should return AuthFailure when email already in use', () async {
    when(() => mockRepository.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async =>
        const Left(AuthFailure(message: 'Email already in use')));

    final result = await usecase(tParams);

    expect(result, const Left(AuthFailure(message: 'Email already in use')));
  });
}
