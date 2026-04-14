import 'dart:async';

import 'package:easy_todo/core/notifications/local_notification_service.dart';
import 'package:easy_todo/core/utils/date_utils.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/usecases/complete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/create_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/delete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/get_tasks.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final LocalNotificationService notificationService;
  final GetTasks getTasks;
  final CreateTask createTask;
  final DeleteTask deleteTask;
  final CompleteTask completeTask;

  StreamSubscription? _tasksSubscription;

  TasksBloc({
    required this.notificationService,
    required this.getTasks,
    required this.createTask,
    required this.deleteTask,
    required this.completeTask,
  }) : super(TasksInitial()) {
    on<LoadTasksRequested>(_onLoad);
    on<TasksStreamUpdated>(_onStreamUpdated);
    on<TasksStreamErrored>(_onStreamErrored);
    on<CreateTaskRequested>(_onCreate);
    on<DeleteTaskRequested>(_onDelete);
    on<CompleteTaskRequested>(_onComplete);
  }

  void _onLoad(LoadTasksRequested event, Emitter<TasksState> emit) {
    emit(TasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = getTasks(GetTasksParams(userId: event.userId)).listen(
      (result) {
        result.fold(
          (failure) => add(TasksStreamErrored(message: failure.message)),
          (tasks) => add(TasksStreamUpdated(tasks: tasks)),
        );
      },
    );
  }

  void _onStreamUpdated(TasksStreamUpdated event, Emitter<TasksState> emit) {
    final today = <TaskEntity>[];
    final upcoming = <TaskEntity>[];
    final completed = <TaskEntity>[];

    for (final task in event.tasks) {
      if (task.isCompleted) {
        completed.add(task);
      } else if (task.dueDate != null && TaskDateUtils.isFuture(task.dueDate!)) {
        upcoming.add(task);
      } else {
        today.add(task);
      }
    }

    emit(TasksLoaded(
      todayTasks: today,
      upcomingTasks: upcoming,
      completedTasks: completed,
    ));
  }

  void _onStreamErrored(TasksStreamErrored event, Emitter<TasksState> emit) {
    emit(TasksError(message: event.message));
  }

  Future<void> _onCreate(
      CreateTaskRequested event, Emitter<TasksState> emit) async {
    final result = await createTask(event.task);
    await result.fold(
      (failure) async => emit(TasksError(message: failure.message)),
      (_) async {
        if (event.task.notificationId != null) {
          await notificationService.scheduleTaskNotification(
            event.task,
            title: event.notificationTitle,
            body: event.notificationBody,
          );
        }
      },
    );
  }

  Future<void> _onDelete(
      DeleteTaskRequested event, Emitter<TasksState> emit) async {
    await _cancelNotificationForTask(event.taskId);
    final result = await deleteTask(
      DeleteTaskParams(taskId: event.taskId, userId: event.userId),
    );
    result.fold(
      (failure) => emit(TasksError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onComplete(
      CompleteTaskRequested event, Emitter<TasksState> emit) async {
    await _cancelNotificationForTask(event.taskId);
    final result = await completeTask(
      CompleteTaskParams(taskId: event.taskId, userId: event.userId),
    );
    result.fold(
      (failure) => emit(TasksError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _cancelNotificationForTask(String taskId) async {
    final currentState = state;
    if (currentState is! TasksLoaded) return;
    final allTasks = [
      ...currentState.todayTasks,
      ...currentState.upcomingTasks,
      ...currentState.completedTasks,
    ];
    final task = allTasks.where((t) => t.id == taskId).firstOrNull;
    if (task?.notificationId != null) {
      await notificationService.cancelNotification(task!.notificationId!);
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
