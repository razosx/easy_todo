import 'dart:async';

import 'package:easy_todo/core/locale/locale_cubit.dart';
import 'package:easy_todo/core/notifications/local_notification_service.dart';
import 'package:easy_todo/core/router/app_router.dart';
import 'package:easy_todo/core/theme/app_theme.dart';
import 'package:easy_todo/core/theme/theme_cubit.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:easy_todo/features/auth/domain/usecases/check_username_available.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_out.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/features/tasks/domain/usecases/complete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/create_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/delete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/get_tasks.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/assign_task_to_member.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/complete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/create_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/create_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/delete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team_tasks.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/join_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/leave_team.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_bloc.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_event.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// flutter_localizations imported via AppLocalizations.localizationsDelegates;

class EasyTodoApp extends StatefulWidget {
  final LocalNotificationService localNotificationService;
  final AuthRepository authRepository;
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final CheckUsernameAvailable checkUsernameAvailable;
  // Personal tasks
  final GetTasks getTasks;
  final CreateTask createTask;
  final DeleteTask deleteTask;
  final CompleteTask completeTask;
  // Team
  final GetTeam getTeam;
  final CreateTeam createTeam;
  final JoinTeam joinTeam;
  final LeaveTeam leaveTeam;
  // Team tasks
  final GetTeamTasks getTeamTasks;
  final CreateTeamTask createTeamTask;
  final AssignTaskToMember assignTaskToMember;
  final CompleteTeamTask completeTeamTask;
  final DeleteTeamTask deleteTeamTask;

  const EasyTodoApp({
    super.key,
    required this.localNotificationService,
    required this.authRepository,
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.checkUsernameAvailable,
    required this.getTasks,
    required this.createTask,
    required this.deleteTask,
    required this.completeTask,
    required this.getTeam,
    required this.createTeam,
    required this.joinTeam,
    required this.leaveTeam,
    required this.getTeamTasks,
    required this.createTeamTask,
    required this.assignTaskToMember,
    required this.completeTeamTask,
    required this.deleteTeamTask,
  });

  @override
  State<EasyTodoApp> createState() => _EasyTodoAppState();
}

class _EasyTodoAppState extends State<EasyTodoApp> {
  late final AuthBloc _authBloc;
  late final TasksBloc _tasksBloc;
  late final TeamBloc _teamBloc;
  late final TeamTasksBloc _teamTasksBloc;
  late final ThemeCubit _themeCubit;
  late final LocaleCubit _localeCubit;
  late final AppRouter _appRouter;
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();

    _authBloc = AuthBloc(
      authRepository: widget.authRepository,
      signInWithEmail: widget.signInWithEmail,
      signUpWithEmail: widget.signUpWithEmail,
      signInWithGoogle: widget.signInWithGoogle,
      signOut: widget.signOut,
    );

    _tasksBloc = TasksBloc(
      notificationService: widget.localNotificationService,
      getTasks: widget.getTasks,
      createTask: widget.createTask,
      deleteTask: widget.deleteTask,
      completeTask: widget.completeTask,
    );

    _teamBloc = TeamBloc(
      getTeam: widget.getTeam,
      createTeam: widget.createTeam,
      joinTeam: widget.joinTeam,
      leaveTeam: widget.leaveTeam,
    );

    _teamTasksBloc = TeamTasksBloc(
      getTeamTasks: widget.getTeamTasks,
      createTeamTask: widget.createTeamTask,
      assignTaskToMember: widget.assignTaskToMember,
      completeTeamTask: widget.completeTeamTask,
      deleteTeamTask: widget.deleteTeamTask,
    );

    _themeCubit = ThemeCubit()..loadTheme();
    _localeCubit = LocaleCubit()..loadLocale();
    _appRouter = AppRouter(_authBloc);

    // Check persisted session on startup
    _authBloc.add(AuthCheckRequested());

    // Load tasks and team whenever auth becomes authenticated
    _authSub = _authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        _tasksBloc.add(LoadTasksRequested(userId: state.user.id));
        _teamBloc.add(LoadTeamRequested(userId: state.user.id));
        _teamTasksBloc.setCurrentUserId(state.user.id);
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _authBloc.close();
    _tasksBloc.close();
    _teamBloc.close();
    _teamTasksBloc.close();
    _themeCubit.close();
    _localeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _tasksBloc),
        BlocProvider.value(value: _teamBloc),
        BlocProvider.value(value: _teamTasksBloc),
        BlocProvider.value(value: _themeCubit),
        BlocProvider.value(value: _localeCubit),
        RepositoryProvider.value(value: widget.localNotificationService),
        RepositoryProvider.value(value: widget.checkUsernameAvailable),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, AppTheme>(
            builder: (context, appTheme) {
              return MaterialApp.router(
                title: 'Easy Todo',
                debugShowCheckedModeBanner: false,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: AppThemeData.light(appTheme),
                darkTheme: AppThemeData.dark(appTheme),
                themeMode: AppThemeData.themeMode(appTheme),
                routerConfig: _appRouter.router,
              );
            },
          );
        },
      ),
    );
  }

}
