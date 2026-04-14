import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TeamEvent extends Equatable {
  const TeamEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeamRequested extends TeamEvent {
  final String userId;

  const LoadTeamRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class TeamStreamUpdated extends TeamEvent {
  final TeamEntity? team;

  const TeamStreamUpdated({required this.team});

  @override
  List<Object?> get props => [team];
}

class TeamStreamErrored extends TeamEvent {
  final String message;

  const TeamStreamErrored({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateTeamRequested extends TeamEvent {
  final String name;
  final String userId;

  const CreateTeamRequested({required this.name, required this.userId});

  @override
  List<Object?> get props => [name, userId];
}

class JoinTeamRequested extends TeamEvent {
  final String inviteCode;
  final String userId;

  const JoinTeamRequested({required this.inviteCode, required this.userId});

  @override
  List<Object?> get props => [inviteCode, userId];
}

class LeaveTeamRequested extends TeamEvent {
  final String teamId;
  final String userId;

  const LeaveTeamRequested({required this.teamId, required this.userId});

  @override
  List<Object?> get props => [teamId, userId];
}
