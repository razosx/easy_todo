import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class SignUpWithEmail extends UseCase<UserEntity, SignUpWithEmailParams> {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) {
    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignUpWithEmailParams extends Equatable {
  final String email;
  final String password;

  const SignUpWithEmailParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
