import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:equatable/equatable.dart';

class TeamTaskEntity extends Equatable {
  final String id;
  final String teamId;
  final String title;
  final String description;
  final String? assignedTo;
  final String createdBy;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final TaskPriority priority;

  const TeamTaskEntity({
    required this.id,
    required this.teamId,
    required this.title,
    this.description = '',
    this.assignedTo,
    required this.createdBy,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.priority = TaskPriority.medium,
  });

  TeamTaskEntity copyWith({
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    bool clearAssignee = false,
    bool clearDueDate = false,
  }) {
    return TeamTaskEntity(
      id: id,
      teamId: teamId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: clearAssignee ? null : (assignedTo ?? this.assignedTo),
      createdBy: createdBy,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [
    id,
    teamId,
    title,
    description,
    assignedTo,
    createdBy,
    dueDate,
    isCompleted,
    createdAt,
    priority,
  ];
}
