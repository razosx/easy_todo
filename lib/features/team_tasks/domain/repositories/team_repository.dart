import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';

abstract class TeamRepository {
  Stream<Either<Failure, TeamEntity?>> getTeam(String userId);
  Future<Either<Failure, TeamEntity>> createTeam(String name, String userId);
  Future<Either<Failure, TeamEntity>> joinTeam(String inviteCode, String userId);
  Future<Either<Failure, void>> leaveTeam(String teamId, String userId);
}
