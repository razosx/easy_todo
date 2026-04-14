import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';

abstract class TeamTaskRepository {
  Stream<Either<Failure, List<TeamTaskEntity>>> getTeamTasks(String teamId);
  Future<Either<Failure, TeamTaskEntity>> createTeamTask(TeamTaskEntity task);
  Future<Either<Failure, TeamTaskEntity>> assignTask(
    String taskId,
    String teamId,
    String? assigneeId,
  );
  Future<Either<Failure, TeamTaskEntity>> completeTeamTask(
    String taskId,
    String teamId,
  );
  Future<Either<Failure, void>> deleteTeamTask(String taskId, String teamId);
}
