import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_task_repository.dart';
import 'package:equatable/equatable.dart';

class CompleteTeamTask extends UseCase<TeamTaskEntity, CompleteTeamTaskParams> {
  final TeamTaskRepository repository;

  CompleteTeamTask(this.repository);

  @override
  Future<Either<Failure, TeamTaskEntity>> call(CompleteTeamTaskParams params) {
    return repository.completeTeamTask(params.taskId, params.teamId);
  }
}

class CompleteTeamTaskParams extends Equatable {
  final String taskId;
  final String teamId;

  const CompleteTeamTaskParams({required this.taskId, required this.teamId});

  @override
  List<Object?> get props => [taskId, teamId];
}
