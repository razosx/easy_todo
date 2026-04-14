import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskEntity> todayTasks;
  final List<TaskEntity> upcomingTasks;
  final List<TaskEntity> completedTasks;

  const TasksLoaded({
    required this.todayTasks,
    required this.upcomingTasks,
    required this.completedTasks,
  });

  @override
  List<Object?> get props => [todayTasks, upcomingTasks, completedTasks];
}

class TasksError extends TasksState {
  final String message;

  const TasksError({required this.message});

  @override
  List<Object?> get props => [message];
}
