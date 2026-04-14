import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithGoogle usecase;
  late MockAuthRepository mockRepository;

  const tUser = UserEntity(id: 'uid-1', email: 'google@test.com', displayName: 'Google User');

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInWithGoogle(mockRepository);
  });

  test('should return UserEntity when Google sign in succeeds', () async {
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => const Right(tUser));

    final result = await usecase(const NoParams());

    expect(result, const Right(tUser));
    verify(() => mockRepository.signInWithGoogle()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return AuthFailure when Google sign in is cancelled', () async {
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => const Left(AuthFailure(message: 'Sign in cancelled')));

    final result = await usecase(const NoParams());

    expect(result, const Left(AuthFailure(message: 'Sign in cancelled')));
  });

  test('should return ServerFailure when a server error occurs', () async {
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

    final result = await usecase(const NoParams());

    expect(result, const Left(ServerFailure(message: 'Server error')));
  });
}
