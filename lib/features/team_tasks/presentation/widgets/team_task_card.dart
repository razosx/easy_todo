import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeamTaskCard extends StatelessWidget {
  final TeamTaskEntity task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback? onAssign;

  const TeamTaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: task.isCompleted ? null : (_) => onComplete(),
          shape: const CircleBorder(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? theme.colorScheme.onSurface.withAlpha(128)
                : null,
          ),
        ),
        subtitle: _buildSubtitle(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PriorityDot(priority: task.priority),
            if (onAssign != null)
              IconButton(
                icon: const Icon(Icons.person_add_outlined, size: 20),
                onPressed: onAssign,
                tooltip: 'Asignar',
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final parts = <String>[];
    if (task.dueDate != null) {
      parts.add(DateFormat('d MMM', 'es').format(task.dueDate!));
    }
    if (task.assignedTo != null) {
      parts.add('→ ${task.assignedTo}');
    }
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.green,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(radius: 5, backgroundColor: color),
    );
  }
}
