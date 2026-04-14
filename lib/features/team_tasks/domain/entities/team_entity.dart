import 'package:easy_todo/features/team_tasks/domain/entities/team_member_entity.dart';
import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String createdBy;
  final String inviteCode;
  final Map<String, TeamMemberEntity> members;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.inviteCode,
    required this.members,
  });

  @override
  List<Object?> get props => [id, name, createdBy, inviteCode, members];
}
