import 'package:equatable/equatable.dart';

class TeamMemberEntity extends Equatable {
  final String userId;
  final String role; // 'admin' | 'member'
  final DateTime joinedAt;
  final String? username;
  final String? name;

  const TeamMemberEntity({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.username,
    this.name,
  });

  @override
  List<Object?> get props => [userId, role, joinedAt, username, name];
}
