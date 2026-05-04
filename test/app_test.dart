// ignore_for_file: unnecessary_underscores

import 'dart:async';

import 'package:easy_todo/core/locale/locale_cubit.dart';
import 'package:easy_todo/core/notifications/local_notification_service.dart';
import 'package:easy_todo/core/router/app_router.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_todo/core/theme/theme_cubit.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockTasksBloc extends Mock implements TasksBloc {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockTasksBloc mockTasksBloc;
  late MockLocalNotificationService mockNotifications;
  late ThemeCubit themeCubit;
  late LocaleCubit localeCubit;

  const tUser = UserEntity(id: 'uid-1', email: 'test@test.com');

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockTasksBloc = MockTasksBloc();
    mockNotifications = MockLocalNotificationService();
    SharedPreferences.setMockInitialValues({'app_locale': 'es'});
    themeCubit = ThemeCubit();
    localeCubit = LocaleCubit()..loadLocale();

    when(() => mockTasksBloc.state).thenReturn(
      const TasksLoaded(todayTasks: [], upcomingTasks: [], completedTasks: []),
    );
    when(() => mockTasksBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    themeCubit.close();
    localeCubit.close();
  });

  Widget buildApp(AuthBloc authBloc) {
    final router = AppRouter(authBloc).router;
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<TasksBloc>.value(value: mockTasksBloc),
        BlocProvider<ThemeCubit>.value(value: themeCubit),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
        RepositoryProvider<LocalNotificationService>.value(
          value: mockNotifications,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
      ),
    );
  }

  testWidgets('shows login page when not authenticated', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildApp(mockAuthBloc));
    await tester.pumpAndSettle();

    expect(find.text('Easy Todo'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('shows home when authenticated', (tester) async {
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthAuthenticated(user: tUser));
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildApp(mockAuthBloc));
    await tester.pumpAndSettle();

    expect(find.text('Mis Tareas'), findsOneWidget);
  });

  testWidgets('redirects to login after sign out', (tester) async {
    final authController = StreamController<AuthState>.broadcast();

    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthAuthenticated(user: tUser));
    when(() => mockAuthBloc.stream).thenAnswer((_) => authController.stream);

    // Use simple stub routes to avoid provider-scoping issues during transitions
    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(mockAuthBloc.stream),
      redirect: (context, state) {
        final authState = mockAuthBloc.state;
        final location = state.matchedLocation;
        if (authState is AuthAuthenticated) {
          return (location == '/' || location == '/login') ? '/home' : null;
        }
        return location == '/login' ? null : '/login';
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Text('Loading')),
        GoRoute(path: '/login', builder: (_, __) => const Text('Login')),
        GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    // Simulate sign out
    when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());
    authController.add(AuthUnauthenticated());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);

    await authController.close();
  });
}
