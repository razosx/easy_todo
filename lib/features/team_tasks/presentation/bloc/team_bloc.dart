import 'dart:async';

import 'package:easy_todo/features/team_tasks/domain/usecases/create_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/join_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/leave_team.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_event.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final GetTeam getTeam;
  final CreateTeam createTeam;
  final JoinTeam joinTeam;
  final LeaveTeam leaveTeam;

  StreamSubscription? _teamSubscription;

  TeamBloc({
    required this.getTeam,
    required this.createTeam,
    required this.joinTeam,
    required this.leaveTeam,
  }) : super(TeamInitial()) {
    on<LoadTeamRequested>(_onLoad);
    on<TeamStreamUpdated>(_onStreamUpdated);
    on<TeamStreamErrored>(_onStreamErrored);
    on<CreateTeamRequested>(_onCreate);
    on<JoinTeamRequested>(_onJoin);
    on<LeaveTeamRequested>(_onLeave);
  }

  void _onLoad(LoadTeamRequested event, Emitter<TeamState> emit) {
    emit(TeamLoading());
    _teamSubscription?.cancel();
    _teamSubscription =
        getTeam(GetTeamParams(userId: event.userId)).listen((result) {
      result.fold(
        (failure) => add(TeamStreamErrored(message: failure.message)),
        (team) => add(TeamStreamUpdated(team: team)),
      );
    });
  }

  void _onStreamUpdated(TeamStreamUpdated event, Emitter<TeamState> emit) {
    if (event.team == null) {
      emit(TeamNone());
    } else {
      emit(TeamLoaded(team: event.team!));
    }
  }

  void _onStreamErrored(TeamStreamErrored event, Emitter<TeamState> emit) {
    emit(TeamError(message: event.message));
  }

  Future<void> _onCreate(
      CreateTeamRequested event, Emitter<TeamState> emit) async {
    emit(TeamLoading());
    final result = await createTeam(
      CreateTeamParams(name: event.name, userId: event.userId),
    );
    result.fold(
      (failure) => emit(TeamError(message: failure.message)),
      (team) => emit(TeamLoaded(team: team)),
    );
  }

  Future<void> _onJoin(
      JoinTeamRequested event, Emitter<TeamState> emit) async {
    emit(TeamLoading());
    final result = await joinTeam(
      JoinTeamParams(inviteCode: event.inviteCode, userId: event.userId),
    );
    result.fold(
      (failure) => emit(TeamError(message: failure.message)),
      (team) => emit(TeamLoaded(team: team)),
    );
  }

  Future<void> _onLeave(
      LeaveTeamRequested event, Emitter<TeamState> emit) async {
    emit(TeamLoading());
    final result = await leaveTeam(
      LeaveTeamParams(teamId: event.teamId, userId: event.userId),
    );
    result.fold(
      (failure) => emit(TeamError(message: failure.message)),
      (_) => emit(TeamNone()),
    );
  }

  @override
  Future<void> close() {
    _teamSubscription?.cancel();
    return super.close();
  }
}
