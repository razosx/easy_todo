import 'dart:async';

import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/assign_task_to_member.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/complete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/create_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/delete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team_tasks.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_event.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamTasksBloc extends Bloc<TeamTasksEvent, TeamTasksState> {
  final GetTeamTasks getTeamTasks;
  final CreateTeamTask createTeamTask;
  final AssignTaskToMember assignTaskToMember;
  final CompleteTeamTask completeTeamTask;
  final DeleteTeamTask deleteTeamTask;

  StreamSubscription? _tasksSubscription;
  String? _currentUserId;

  TeamTasksBloc({
    required this.getTeamTasks,
    required this.createTeamTask,
    required this.assignTaskToMember,
    required this.completeTeamTask,
    required this.deleteTeamTask,
  }) : super(TeamTasksInitial()) {
    on<LoadTeamTasksRequested>(_onLoad);
    on<TeamTasksStreamUpdated>(_onStreamUpdated);
    on<TeamTasksStreamErrored>(_onStreamErrored);
    on<CreateTeamTaskRequested>(_onCreate);
    on<AssignTeamTaskRequested>(_onAssign);
    on<CompleteTeamTaskRequested>(_onComplete);
    on<DeleteTeamTaskRequested>(_onDelete);
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  void _onLoad(LoadTeamTasksRequested event, Emitter<TeamTasksState> emit) {
    emit(TeamTasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = getTeamTasks(
      GetTeamTasksParams(teamId: event.teamId),
    ).listen((result) {
      result.fold(
        (failure) => add(TeamTasksStreamErrored(message: failure.message)),
        (tasks) => add(TeamTasksStreamUpdated(tasks: tasks)),
      );
    });
  }

  void _onStreamUpdated(
      TeamTasksStreamUpdated event, Emitter<TeamTasksState> emit) {
    final assignedToMe = <TeamTaskEntity>[];
    final unassigned = <TeamTaskEntity>[];
    final assignedToOthers = <TeamTaskEntity>[];
    final completed = <TeamTaskEntity>[];

    for (final task in event.tasks) {
      if (task.isCompleted) {
        completed.add(task);
      } else if (task.assignedTo == null) {
        unassigned.add(task);
      } else if (task.assignedTo == _currentUserId) {
        assignedToMe.add(task);
      } else {
        assignedToOthers.add(task);
      }
    }

    emit(TeamTasksLoaded(
      assignedToMe: assignedToMe,
      unassigned: unassigned,
      assignedToOthers: assignedToOthers,
      completed: completed,
    ));
  }

  void _onStreamErrored(
      TeamTasksStreamErrored event, Emitter<TeamTasksState> emit) {
    emit(TeamTasksError(message: event.message));
  }

  Future<void> _onCreate(
      CreateTeamTaskRequested event, Emitter<TeamTasksState> emit) async {
    final result = await createTeamTask(event.task);
    result.fold(
      (failure) => emit(TeamTasksError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onAssign(
      AssignTeamTaskRequested event, Emitter<TeamTasksState> emit) async {
    final result = await assignTaskToMember(
      AssignTaskParams(
        taskId: event.taskId,
        teamId: event.teamId,
        assigneeId: event.assigneeId,
      ),
    );
    result.fold(
      (failure) => emit(TeamTasksError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onComplete(
      CompleteTeamTaskRequested event, Emitter<TeamTasksState> emit) async {
    final result = await completeTeamTask(
      CompleteTeamTaskParams(taskId: event.taskId, teamId: event.teamId),
    );
    result.fold(
      (failure) => emit(TeamTasksError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onDelete(
      DeleteTeamTaskRequested event, Emitter<TeamTasksState> emit) async {
    final result = await deleteTeamTask(
      DeleteTeamTaskParams(taskId: event.taskId, teamId: event.teamId),
    );
    result.fold(
      (failure) => emit(TeamTasksError(message: failure.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
