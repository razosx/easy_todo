import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksRequested extends TasksEvent {
  final String userId;

  const LoadTasksRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class TasksStreamUpdated extends TasksEvent {
  final List<TaskEntity> tasks;

  const TasksStreamUpdated({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class TasksStreamErrored extends TasksEvent {
  final String message;

  const TasksStreamErrored({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateTaskRequested extends TasksEvent {
  final TaskEntity task;
  final String notificationTitle;
  final String notificationBody;

  const CreateTaskRequested({
    required this.task,
    required this.notificationTitle,
    required this.notificationBody,
  });

  @override
  List<Object?> get props => [task, notificationTitle, notificationBody];
}

class UpdateTaskRequested extends TasksEvent {
  final TaskEntity task;

  const UpdateTaskRequested({required this.task});

  @override
  List<Object?> get props => [task];
}

class DeleteTaskRequested extends TasksEvent {
  final String taskId;
  final String userId;

  const DeleteTaskRequested({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}

class CompleteTaskRequested extends TasksEvent {
  final String taskId;
  final String userId;

  const CompleteTaskRequested({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}
