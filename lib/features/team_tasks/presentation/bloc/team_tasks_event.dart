import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TeamTasksEvent extends Equatable {
  const TeamTasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeamTasksRequested extends TeamTasksEvent {
  final String teamId;

  const LoadTeamTasksRequested({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class TeamTasksStreamUpdated extends TeamTasksEvent {
  final List<TeamTaskEntity> tasks;

  const TeamTasksStreamUpdated({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class TeamTasksStreamErrored extends TeamTasksEvent {
  final String message;

  const TeamTasksStreamErrored({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateTeamTaskRequested extends TeamTasksEvent {
  final TeamTaskEntity task;

  const CreateTeamTaskRequested({required this.task});

  @override
  List<Object?> get props => [task];
}

class AssignTeamTaskRequested extends TeamTasksEvent {
  final String taskId;
  final String teamId;
  final String? assigneeId;

  const AssignTeamTaskRequested({
    required this.taskId,
    required this.teamId,
    this.assigneeId,
  });

  @override
  List<Object?> get props => [taskId, teamId, assigneeId];
}

class CompleteTeamTaskRequested extends TeamTasksEvent {
  final String taskId;
  final String teamId;

  const CompleteTeamTaskRequested({required this.taskId, required this.teamId});

  @override
  List<Object?> get props => [taskId, teamId];
}

class DeleteTeamTaskRequested extends TeamTasksEvent {
  final String taskId;
  final String teamId;

  const DeleteTeamTaskRequested({required this.taskId, required this.teamId});

  @override
  List<Object?> get props => [taskId, teamId];
}
