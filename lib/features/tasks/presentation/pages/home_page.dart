import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:easy_todo/features/tasks/presentation/widgets/add_task_bottom_sheet.dart';
import 'package:easy_todo/features/tasks/presentation/widgets/task_card.dart';
import 'package:easy_todo/features/tasks/presentation/widgets/task_list_section.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();

        return BlocConsumer<TasksBloc, TasksState>(
          listener: (context, state) {
            if (state is TasksError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.homeTitle),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<TasksBloc>().add(
                      LoadTasksRequested(userId: authState.user.id),
                    ),
                  ),
                ],
              ),
              body: _buildBody(context, state, authState.user.id),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showAddTaskSheet(context, authState.user.id),
                child: const Icon(Icons.add),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TasksState state, String userId) {
    if (state is TasksLoading || state is TasksInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TasksLoaded) {
      final l10n = AppLocalizations.of(context)!;
      final hasAnyTask =
          state.todayTasks.isNotEmpty ||
          state.upcomingTasks.isNotEmpty ||
          state.completedTasks.isNotEmpty;

      if (!hasAnyTask) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.homeEmptyTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeEmptySubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        children: [
          const SizedBox(height: 8),
          TaskListSection(
            title: l10n.homeSectionToday,
            tasks: state.todayTasks,
            initiallyExpanded: true,
            itemBuilder: (task) => TaskCard(
              task: task,
              onComplete: () => context.read<TasksBloc>().add(
                CompleteTaskRequested(taskId: task.id, userId: userId),
              ),
              onDelete: () => context.read<TasksBloc>().add(
                DeleteTaskRequested(taskId: task.id, userId: userId),
              ),
              onTap: () {},
            ),
          ),
          TaskListSection(
            title: l10n.homeSectionUpcoming,
            tasks: state.upcomingTasks,
            initiallyExpanded: true,
            itemBuilder: (task) => TaskCard(
              task: task,
              onComplete: () => context.read<TasksBloc>().add(
                CompleteTaskRequested(taskId: task.id, userId: userId),
              ),
              onDelete: () => context.read<TasksBloc>().add(
                DeleteTaskRequested(taskId: task.id, userId: userId),
              ),
              onTap: () {},
            ),
          ),
          TaskListSection(
            title: l10n.homeSectionCompleted,
            tasks: state.completedTasks,
            initiallyExpanded: false,
            itemBuilder: (task) => TaskCard(
              task: task,
              onComplete: () => context.read<TasksBloc>().add(
                CompleteTaskRequested(taskId: task.id, userId: userId),
              ),
              onDelete: () => context.read<TasksBloc>().add(
                DeleteTaskRequested(taskId: task.id, userId: userId),
              ),
              onTap: () {},
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showAddTaskSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TasksBloc>(),
        child: AddTaskBottomSheet(userId: userId),
      ),
    );
  }
}
