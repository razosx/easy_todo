import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final TaskPriority priority;
  final int? notificationId;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.priority = TaskPriority.medium,
    this.notificationId,
  });

  TaskEntity copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    int? notificationId,
    bool clearDueDate = false,
  }) {
    return TaskEntity(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      priority: priority ?? this.priority,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    dueDate,
    isCompleted,
    createdAt,
    priority,
    notificationId,
  ];
}
