import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_task_repository.dart';
import 'package:equatable/equatable.dart';

class AssignTaskToMember extends UseCase<TeamTaskEntity, AssignTaskParams> {
  final TeamTaskRepository repository;

  AssignTaskToMember(this.repository);

  @override
  Future<Either<Failure, TeamTaskEntity>> call(AssignTaskParams params) {
    return repository.assignTask(params.taskId, params.teamId, params.assigneeId);
  }
}

class AssignTaskParams extends Equatable {
  final String taskId;
  final String teamId;
  final String? assigneeId;

  const AssignTaskParams({
    required this.taskId,
    required this.teamId,
    this.assigneeId,
  });

  @override
  List<Object?> get props => [taskId, teamId, assigneeId];
}
