import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_bloc.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_event.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_state.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_bloc.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_event.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_state.dart';
import 'package:easy_todo/features/team_tasks/presentation/pages/create_team_page.dart';
import 'package:easy_todo/features/team_tasks/presentation/pages/join_team_page.dart';
import 'package:easy_todo/features/team_tasks/presentation/widgets/add_team_task_bottom_sheet.dart';
import 'package:easy_todo/features/team_tasks/presentation/widgets/member_avatar_list.dart';
import 'package:easy_todo/features/team_tasks/presentation/widgets/team_task_card.dart';
import 'package:easy_todo/features/tasks/presentation/widgets/task_list_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamTasksPage extends StatefulWidget {
  const TeamTasksPage({super.key});

  @override
  State<TeamTasksPage> createState() => _TeamTasksPageState();
}

class _TeamTasksPageState extends State<TeamTasksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final teamState = context.read<TeamBloc>().state;
      if (teamState is TeamLoaded) {
        _loadTeamTasks(teamState.team.id);
      }
    });
  }

  void _loadTeamTasks(String teamId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeamTasksBloc>()
        ..setCurrentUserId(authState.user.id)
        ..add(LoadTeamTasksRequested(teamId: teamId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamBloc, TeamState>(
      listener: (context, teamState) {
        if (teamState is TeamLoaded) {
          _loadTeamTasks(teamState.team.id);
        }
        if (teamState is TeamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(teamState.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, teamState) {
        final l10n = AppLocalizations.of(context)!;
        if (teamState is TeamInitial || teamState is TeamLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.teamPageTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (teamState is TeamNone) {
          return _buildNoTeamScaffold(context);
        }

        if (teamState is TeamLoaded) {
          return _buildTeamScaffold(context, teamState.team);
        }

        return Scaffold(appBar: AppBar(title: Text(l10n.teamPageTitle)));
      },
    );
  }

  Widget _buildNoTeamScaffold(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.teamPageTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.teamNoTeamTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.teamNoTeamSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TeamBloc>(),
                      child: BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: const CreateTeamPage(),
                      ),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.teamCreateButton),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TeamBloc>(),
                      child: BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: const JoinTeamPage(),
                      ),
                    ),
                  ),
                ),
                icon: const Icon(Icons.group_add_outlined),
                label: Text(l10n.teamJoinButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScaffold(BuildContext context, TeamEntity team) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocConsumer<TeamTasksBloc, TeamTasksState>(
      listener: (context, state) {
        if (state is TeamTasksError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, tasksState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(team.name),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: MemberAvatarList(members: team.members),
              ),
              Builder(
                builder: (ctx) {
                  final l10n = AppLocalizations.of(ctx)!;
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'invite') {
                        _showInviteCode(context, team.inviteCode);
                      } else if (value == 'leave') {
                        _confirmLeave(context, team.id, userId);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'invite',
                        child: ListTile(
                          leading: const Icon(Icons.share),
                          title: Text(l10n.teamMenuInviteCode),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'leave',
                        child: ListTile(
                          leading: const Icon(Icons.exit_to_app),
                          title: Text(l10n.teamMenuLeave),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: _buildTasksBody(context, tasksState, team),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTaskSheet(context, team, userId),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildTasksBody(
    BuildContext context,
    TeamTasksState state,
    TeamEntity team,
  ) {
    if (state is TeamTasksLoading || state is TeamTasksInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TeamTasksLoaded) {
      final l10n = AppLocalizations.of(context)!;
      final hasAny =
          state.assignedToMe.isNotEmpty ||
          state.unassigned.isNotEmpty ||
          state.assignedToOthers.isNotEmpty ||
          state.completed.isNotEmpty;

      if (!hasAny) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.teamEmptyTasksTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.teamEmptyTasksSubtitle,
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
            title: l10n.teamSectionMyTasks,
            tasks: state.assignedToMe,
            initiallyExpanded: true,
            itemBuilder: (task) => TeamTaskCard(
              task: task,
              members: team.members,
              onComplete: () => context.read<TeamTasksBloc>().add(
                CompleteTeamTaskRequested(taskId: task.id, teamId: team.id),
              ),
              onDelete: () => context.read<TeamTasksBloc>().add(
                DeleteTeamTaskRequested(taskId: task.id, teamId: team.id),
              ),
            ),
          ),
          TaskListSection(
            title: l10n.teamSectionUnassigned,
            tasks: state.unassigned,
            initiallyExpanded: true,
            itemBuilder: (task) => TeamTaskCard(
              task: task,
              members: team.members,
              onComplete: () => context.read<TeamTasksBloc>().add(
                CompleteTeamTaskRequested(taskId: task.id, teamId: team.id),
              ),
              onDelete: () => context.read<TeamTasksBloc>().add(
                DeleteTeamTaskRequested(taskId: task.id, teamId: team.id),
              ),
              onAssign: () => _showAssignDialog(context, task.id, team),
            ),
          ),
          TaskListSection(
            title: l10n.teamSectionOthers,
            tasks: state.assignedToOthers,
            initiallyExpanded: false,
            itemBuilder: (task) => TeamTaskCard(
              task: task,
              members: team.members,
              onComplete: () => context.read<TeamTasksBloc>().add(
                CompleteTeamTaskRequested(taskId: task.id, teamId: team.id),
              ),
              onDelete: () => context.read<TeamTasksBloc>().add(
                DeleteTeamTaskRequested(taskId: task.id, teamId: team.id),
              ),
              onAssign: () => _showAssignDialog(context, task.id, team),
            ),
          ),
          TaskListSection(
            title: l10n.teamSectionCompleted,
            tasks: state.completed,
            initiallyExpanded: false,
            itemBuilder: (task) => TeamTaskCard(
              task: task,
              members: team.members,
              onComplete: () {},
              onDelete: () => context.read<TeamTasksBloc>().add(
                DeleteTeamTaskRequested(taskId: task.id, teamId: team.id),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showAddTaskSheet(BuildContext context, TeamEntity team, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TeamTasksBloc>(),
        child: AddTeamTaskBottomSheet(
          teamId: team.id,
          createdBy: userId,
          members: team.members,
        ),
      ),
    );
  }

  void _showInviteCode(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.teamInviteCodeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.teamInviteCodeDescription,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.closeButton),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, String taskId, TeamEntity team) {
    final l10n = AppLocalizations.of(context)!;
    final memberEntries = team.members.entries.toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.teamAssignTaskTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: Text(l10n.teamAssignUnassigned),
                onTap: () {
                  context.read<TeamTasksBloc>().add(
                    AssignTeamTaskRequested(
                      taskId: taskId,
                      teamId: team.id,
                      assigneeId: null,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
              ...memberEntries.map((e) {
                final displayName = e.value.username ?? e.value.name ?? e.key;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(displayName),
                  subtitle: e.value.role == 'admin'
                      ? Text(l10n.teamRoleAdmin)
                      : null,
                  onTap: () {
                    context.read<TeamTasksBloc>().add(
                      AssignTeamTaskRequested(
                        taskId: taskId,
                        teamId: team.id,
                        assigneeId: e.key,
                      ),
                    );
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, String teamId, String userId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.teamLeaveTitle),
        content: Text(l10n.teamLeaveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () {
              context.read<TeamBloc>().add(
                LeaveTeamRequested(teamId: teamId, userId: userId),
              );
              Navigator.pop(context);
            },
            child: Text(l10n.teamLeaveButton),
          ),
        ],
      ),
    );
  }
}
