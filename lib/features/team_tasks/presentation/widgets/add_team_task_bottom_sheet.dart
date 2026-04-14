import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_member_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_bloc.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_event.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddTeamTaskBottomSheet extends StatefulWidget {
  final String teamId;
  final String createdBy;
  final Map<String, TeamMemberEntity> members;

  const AddTeamTaskBottomSheet({
    super.key,
    required this.teamId,
    required this.createdBy,
    required this.members,
  });

  @override
  State<AddTeamTaskBottomSheet> createState() => _AddTeamTaskBottomSheetState();
}

class _AddTeamTaskBottomSheetState extends State<AddTeamTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  String? _assignedTo;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final task = TeamTaskEntity(
      id: '',
      teamId: widget.teamId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      assignedTo: _assignedTo,
      createdBy: widget.createdBy,
      dueDate: _dueDate,
      createdAt: DateTime.now(),
      priority: _priority,
    );

    context.read<TeamTasksBloc>().add(CreateTeamTaskRequested(task: task));
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final memberEntries = widget.members.entries.toList();
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
            Text(
              l10n.addTeamTaskTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                    onPressed: () => setState(() => _dueDate = null),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            if (memberEntries.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _assignedTo,
                decoration: InputDecoration(
                  labelText: l10n.teamTaskAssignLabel,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.teamAssignUnassigned),
                  ),
                  ...memberEntries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.key),
                      )),
                ],
                onChanged: (v) => setState(() => _assignedTo = v),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.addTaskButton),
            ),
          ],
        ),
      ),
    );
  }
}
