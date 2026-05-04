import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final String userId;

  const AddTaskBottomSheet({super.key, required this.userId});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  bool _notificationEnabled = false;
  TimeOfDay? _notificationTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    DateTime? finalDueDate = _dueDate;
    int? notificationId;

    if (_notificationEnabled && _dueDate != null && _notificationTime != null) {
      finalDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _notificationTime!.hour,
        _notificationTime!.minute,
      );
      notificationId = const Uuid().v4().hashCode.abs();
    }

    final task = TaskEntity(
      id: '',
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: finalDueDate,
      createdAt: DateTime.now(),
      priority: _priority,
      notificationId: notificationId,
    );

    context.read<TasksBloc>().add(
      CreateTaskRequested(
        task: task,
        notificationTitle: l10n.notificationTitle(task.title),
        notificationBody: task.description.isNotEmpty
            ? task.description
            : l10n.notificationDefaultBody,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _onNotificationToggled(bool? value) async {
    if (value == true) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _notificationEnabled = true;
          _notificationTime = time;
        });
      }
    } else {
      setState(() {
        _notificationEnabled = false;
        _notificationTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.homeTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.taskTitleLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.taskTitleRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.taskDescriptionLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _dueDate == null
                          ? l10n.taskNoDate
                          : DateFormat('d MMM yyyy', locale).format(_dueDate!),
                    ),
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() {
                      _dueDate = null;
                      _notificationEnabled = false;
                      _notificationTime = null;
                    }),
                    icon: const Icon(Icons.clear, size: 18),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    initialValue: _priority,
                    decoration: InputDecoration(
                      labelText: l10n.taskPriorityLabel,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(switch (p) {
                          TaskPriority.low => l10n.taskPriorityLow,
                          TaskPriority.medium => l10n.taskPriorityMedium,
                          TaskPriority.high => l10n.taskPriorityHigh,
                        }),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                ),
              ],
            ),
            if (_dueDate != null) ...[
              const SizedBox(height: 4),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  _notificationEnabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_none_outlined,
                  color: _notificationEnabled
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  _notificationEnabled && _notificationTime != null
                      ? l10n.taskNotificationAt(
                          _notificationTime!.format(context),
                        )
                      : l10n.taskScheduleNotification,
                ),
                value: _notificationEnabled,
                onChanged: _onNotificationToggled,
              ),
            ],
            const SizedBox(height: 8),
            FilledButton(onPressed: _submit, child: Text(l10n.addTaskButton)),
          ],
        ),
      ),
    );
  }
}
