import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOut usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignOut(mockRepository);
  });

  test('should call signOut on repository', () async {
    when(() => mockRepository.signOut())
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(const NoParams());

    expect(result, const Right(null));
    verify(() => mockRepository.signOut()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when sign out fails', () async {
    when(() => mockRepository.signOut())
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Sign out error')));

    final result = await usecase(const NoParams());

    expect(result, const Left(ServerFailure(message: 'Sign out error')));
  });
}
