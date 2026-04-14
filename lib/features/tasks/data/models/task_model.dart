import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.dueDate,
    super.isCompleted,
    required super.createdAt,
    super.priority,
    super.notificationId,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (data['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      notificationId: data['notificationId'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority.name,
      'notificationId': notificationId,
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      priority: entity.priority,
      notificationId: entity.notificationId,
    );
  }
}
