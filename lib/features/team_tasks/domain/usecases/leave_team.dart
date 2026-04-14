import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_repository.dart';
import 'package:equatable/equatable.dart';

class LeaveTeam extends UseCase<void, LeaveTeamParams> {
  final TeamRepository repository;

  LeaveTeam(this.repository);

  @override
  Future<Either<Failure, void>> call(LeaveTeamParams params) {
    return repository.leaveTeam(params.teamId, params.userId);
  }
}

class LeaveTeamParams extends Equatable {
  final String teamId;
  final String userId;

  const LeaveTeamParams({required this.teamId, required this.userId});

  @override
  List<Object?> get props => [teamId, userId];
}
