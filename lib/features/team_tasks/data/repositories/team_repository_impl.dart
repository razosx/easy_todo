import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/team_tasks/data/datasources/team_remote_data_source.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource remoteDataSource;

  TeamRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, TeamEntity?>> getTeam(String userId) {
    return remoteDataSource
        .getTeam(userId)
        .map<Either<Failure, TeamEntity?>>((team) => Right(team))
        .handleError((e) => Left(ServerFailure(message: e.toString())));
  }

  @override
  Future<Either<Failure, TeamEntity>> createTeam(
      String name, String userId) async {
    try {
      final result = await remoteDataSource.createTeam(name, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> joinTeam(
      String inviteCode, String userId) async {
    try {
      final result = await remoteDataSource.joinTeam(inviteCode, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam(
      String teamId, String userId) async {
    try {
      await remoteDataSource.leaveTeam(teamId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
