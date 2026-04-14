import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_task_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteTeamTask extends UseCase<void, DeleteTeamTaskParams> {
  final TeamTaskRepository repository;

  DeleteTeamTask(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTeamTaskParams params) {
    return repository.deleteTeamTask(params.taskId, params.teamId);
  }
}

class DeleteTeamTaskParams extends Equatable {
  final String taskId;
  final String teamId;

  const DeleteTeamTaskParams({required this.taskId, required this.teamId});

  @override
  List<Object?> get props => [taskId, teamId];
}
