import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';

class TeamTaskModel extends TeamTaskEntity {
  const TeamTaskModel({
    required super.id,
    required super.teamId,
    required super.title,
    super.description,
    super.assignedTo,
    required super.createdBy,
    super.dueDate,
    super.isCompleted,
    required super.createdAt,
    super.priority,
  });

  factory TeamTaskModel.fromFirestore(DocumentSnapshot doc, String teamId) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamTaskModel(
      id: doc.id,
      teamId: teamId,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      assignedTo: data['assignedTo'] as String?,
      createdBy: data['createdBy'] as String,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (data['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority.name,
    };
  }

  factory TeamTaskModel.fromEntity(TeamTaskEntity entity) {
    return TeamTaskModel(
      id: entity.id,
      teamId: entity.teamId,
      title: entity.title,
      description: entity.description,
      assignedTo: entity.assignedTo,
      createdBy: entity.createdBy,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      priority: entity.priority,
    );
  }
}
