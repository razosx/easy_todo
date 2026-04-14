import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_member_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.createdBy,
    required super.inviteCode,
    required super.members,
  });

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final membersData = data['members'] as Map<String, dynamic>? ?? {};
    final members = membersData.map((userId, memberData) {
      final m = memberData as Map<String, dynamic>;
      return MapEntry(
        userId,
        TeamMemberEntity(
          userId: userId,
          role: m['role'] as String? ?? 'member',
          joinedAt: (m['joinedAt'] as Timestamp).toDate(),
          username: m['username'] as String?,
          name: m['name'] as String?,
        ),
      );
    });
    return TeamModel(
      id: doc.id,
      name: data['name'] as String,
      createdBy: data['createdBy'] as String,
      inviteCode: data['inviteCode'] as String,
      members: members,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdBy': createdBy,
      'inviteCode': inviteCode,
      'members': members.map(
        (userId, member) => MapEntry(userId, {
          'role': member.role,
          'joinedAt': Timestamp.fromDate(member.joinedAt),
          if (member.username != null) 'username': member.username,
          if (member.name != null) 'name': member.name,
        }),
      ),
    };
  }

  factory TeamModel.fromEntity(TeamEntity entity) {
    return TeamModel(
      id: entity.id,
      name: entity.name,
      createdBy: entity.createdBy,
      inviteCode: entity.inviteCode,
      members: entity.members,
    );
  }
}
