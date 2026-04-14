import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/team_tasks/data/datasources/team_task_remote_data_source.dart';
import 'package:easy_todo/features/team_tasks/data/models/team_task_model.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_task_repository.dart';

class TeamTaskRepositoryImpl implements TeamTaskRepository {
  final TeamTaskRemoteDataSource remoteDataSource;

  TeamTaskRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<TeamTaskEntity>>> getTeamTasks(String teamId) {
    return remoteDataSource
        .getTeamTasks(teamId)
        .map<Either<Failure, List<TeamTaskEntity>>>((tasks) => Right(tasks))
        .handleError((e) => Left(ServerFailure(message: e.toString())));
  }

  @override
  Future<Either<Failure, TeamTaskEntity>> createTeamTask(
      TeamTaskEntity task) async {
    try {
      final model = TeamTaskModel.fromEntity(task);
      final result = await remoteDataSource.createTeamTask(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TeamTaskEntity>> assignTask(
    String taskId,
    String teamId,
    String? assigneeId,
  ) async {
    try {
      final result =
          await remoteDataSource.assignTask(taskId, teamId, assigneeId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TeamTaskEntity>> completeTeamTask(
    String taskId,
    String teamId,
  ) async {
    try {
      final result =
          await remoteDataSource.completeTeamTask(taskId, teamId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeamTask(
      String taskId, String teamId) async {
    try {
      await remoteDataSource.deleteTeamTask(taskId, teamId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
