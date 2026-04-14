import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TeamState extends Equatable {
  const TeamState();

  @override
  List<Object?> get props => [];
}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamNone extends TeamState {}

class TeamLoaded extends TeamState {
  final TeamEntity team;

  const TeamLoaded({required this.team});

  @override
  List<Object?> get props => [team];
}

class TeamError extends TeamState {
  final String message;

  const TeamError({required this.message});

  @override
  List<Object?> get props => [message];
}
