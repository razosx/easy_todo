import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_task_repository.dart';
import 'package:equatable/equatable.dart';

class GetTeamTasks
    extends StreamUseCase<List<TeamTaskEntity>, GetTeamTasksParams> {
  final TeamTaskRepository repository;

  GetTeamTasks(this.repository);

  @override
  Stream<Either<Failure, List<TeamTaskEntity>>> call(
    GetTeamTasksParams params,
  ) {
    return repository.getTeamTasks(params.teamId);
  }
}

class GetTeamTasksParams extends Equatable {
  final String teamId;

  const GetTeamTasksParams({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}
