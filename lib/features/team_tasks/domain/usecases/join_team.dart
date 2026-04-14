import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_repository.dart';
import 'package:equatable/equatable.dart';

class JoinTeam extends UseCase<TeamEntity, JoinTeamParams> {
  final TeamRepository repository;

  JoinTeam(this.repository);

  @override
  Future<Either<Failure, TeamEntity>> call(JoinTeamParams params) {
    return repository.joinTeam(
        params.inviteCode, params.userId, params.username, params.memberName);
  }
}

class JoinTeamParams extends Equatable {
  final String inviteCode;
  final String userId;
  final String? username;
  final String? memberName;

  const JoinTeamParams({
    required this.inviteCode,
    required this.userId,
    this.username,
    this.memberName,
  });

  @override
  List<Object?> get props => [inviteCode, userId, username, memberName];
}
