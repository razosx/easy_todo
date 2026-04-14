import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/repositories/team_repository.dart';
import 'package:equatable/equatable.dart';

class GetTeam extends StreamUseCase<TeamEntity?, GetTeamParams> {
  final TeamRepository repository;

  GetTeam(this.repository);

  @override
  Stream<Either<Failure, TeamEntity?>> call(GetTeamParams params) {
    return repository.getTeam(params.userId);
  }
}

class GetTeamParams extends Equatable {
  final String userId;

  const GetTeamParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
