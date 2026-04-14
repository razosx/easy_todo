import 'package:equatable/equatable.dart';

class TeamMemberEntity extends Equatable {
  final String userId;
  final String role; // 'admin' | 'member'
  final DateTime joinedAt;

  const TeamMemberEntity({
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, role, joinedAt];
}
