import 'package:easy_todo/features/team_tasks/domain/entities/team_member_entity.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MemberAvatarList extends StatelessWidget {
  final Map<String, TeamMemberEntity> members;
  final double avatarRadius;
  final double overlap;

  const MemberAvatarList({
    super.key,
    required this.members,
    this.avatarRadius = 16,
    this.overlap = 8,
  });

  @override
  Widget build(BuildContext context) {
    final memberList = members.values.toList();
    if (memberList.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: avatarRadius * 2,
      width:
          avatarRadius * 2 +
          (memberList.length - 1) * (avatarRadius * 2 - overlap),
      child: Stack(
        children: List.generate(memberList.length, (i) {
          final member = memberList[i];
          final isAdmin = member.role == 'admin';
          final displayName = member.username ?? member.name ?? member.userId;
          return Positioned(
            left: i * (avatarRadius * 2 - overlap),
            child: Tooltip(
              message:
                  displayName +
                  (isAdmin
                      ? AppLocalizations.of(context)!.teamAdminSuffix
                      : ''),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: isAdmin
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: avatarRadius * 0.8,
                    color: isAdmin
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
