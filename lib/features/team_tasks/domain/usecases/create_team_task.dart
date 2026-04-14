import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_task_repository.dart';

class CreateTeamTask extends UseCase<TeamTaskEntity, TeamTaskEntity> {
  final TeamTaskRepository repository;

  CreateTeamTask(this.repository);

  @override
  Future<Either<Failure, TeamTaskEntity>> call(TeamTaskEntity params) {
    return repository.createTeamTask(params);
  }
}
