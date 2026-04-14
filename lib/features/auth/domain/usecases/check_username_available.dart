import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';

class CheckUsernameAvailable {
  final AuthRepository repository;

  CheckUsernameAvailable(this.repository);

  Future<Either<Failure, bool>> call(String username) {
    return repository.checkUsernameAvailable(username);
  }
}
