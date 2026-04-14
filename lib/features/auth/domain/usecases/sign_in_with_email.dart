import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class SignInWithEmail extends UseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) {
    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
