import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TeamTasksState extends Equatable {
  const TeamTasksState();

  @override
  List<Object?> get props => [];
}

class TeamTasksInitial extends TeamTasksState {}

class TeamTasksLoading extends TeamTasksState {}

class TeamTasksLoaded extends TeamTasksState {
  final List<TeamTaskEntity> assignedToMe;
  final List<TeamTaskEntity> unassigned;
  final List<TeamTaskEntity> assignedToOthers;
  final List<TeamTaskEntity> completed;

  const TeamTasksLoaded({
    required this.assignedToMe,
    required this.unassigned,
    required this.assignedToOthers,
    required this.completed,
  });

  @override
  List<Object?> get props => [
    assignedToMe,
    unassigned,
    assignedToOthers,
    completed,
  ];
}

class TeamTasksError extends TeamTasksState {
  final String message;

  const TeamTasksError({required this.message});

  @override
  List<Object?> get props => [message];
}
