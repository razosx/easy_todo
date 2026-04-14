import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_repository.dart';
import 'package:equatable/equatable.dart';

class CreateTeam extends UseCase<TeamEntity, CreateTeamParams> {
  final TeamRepository repository;

  CreateTeam(this.repository);

  @override
  Future<Either<Failure, TeamEntity>> call(CreateTeamParams params) {
    return repository.createTeam(params.name, params.userId);
  }
}

class CreateTeamParams extends Equatable {
  final String name;
  final String userId;

  const CreateTeamParams({required this.name, required this.userId});

  @override
  List<Object?> get props => [name, userId];
}
