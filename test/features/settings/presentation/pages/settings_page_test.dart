import 'package:easy_todo/core/locale/locale_cubit.dart';
import 'package:easy_todo/core/notifications/local_notification_service.dart';
import 'package:easy_todo/core/theme/app_theme.dart';
import 'package:easy_todo/core/theme/theme_cubit.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/features/settings/presentation/pages/settings_page.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockLocalNotificationService mockNotifications;
  late ThemeCubit themeCubit;
  late LocaleCubit localeCubit;

  const tUser = UserEntity(
    id: 'uid-1',
    email: 'test@test.com',
    displayName: 'Test User',
  );

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockNotifications = MockLocalNotificationService();
    SharedPreferences.setMockInitialValues({'app_locale': 'es'});
    themeCubit = ThemeCubit();
    localeCubit = LocaleCubit()..loadLocale();
  });

  tearDown(() {
    themeCubit.close();
    localeCubit.close();
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<ThemeCubit>.value(value: themeCubit),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
        RepositoryProvider<LocalNotificationService>.value(
          value: mockNotifications,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const SettingsPage(),
      ),
    );
  }

  testWidgets('shows user info when authenticated', (tester) async {
    when(() => mockAuthBloc.state)
        .thenReturn(const AuthAuthenticated(user: tUser));
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@test.com'), findsOneWidget);
  });

  testWidgets('shows notifications toggle', (tester) async {
    when(() => mockAuthBloc.state)
        .thenReturn(const AuthAuthenticated(user: tUser));
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.text('Notificaciones locales'), findsOneWidget);
  });

  testWidgets('shows theme dropdown with all 5 options', (tester) async {
    when(() => mockAuthBloc.state)
        .thenReturn(const AuthAuthenticated(user: tUser));
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // El dropdown muestra la opción activa actual
    expect(find.text('Sistema'), findsOneWidget);

    // Abre el dropdown
    await tester.tap(find.text('Sistema'));
    await tester.pumpAndSettle();

    // Todas las opciones deben aparecer
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);
    expect(find.text('Desierto'), findsOneWidget);
    expect(find.text('Bosque'), findsOneWidget);
  });

  testWidgets('selecting Desierto emits AppTheme.desierto', (tester) async {
    when(() => mockAuthBloc.state)
        .thenReturn(const AuthAuthenticated(user: tUser));
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Sistema'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Desierto'));
    await tester.pumpAndSettle();

    expect(themeCubit.state, AppTheme.desierto);
  });

  testWidgets('dispatches SignOutRequested when logout confirmed',
      (tester) async {
    when(() => mockAuthBloc.state)
        .thenReturn(const AuthAuthenticated(user: tUser));
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Cerrar sesión').first);
    await tester.pumpAndSettle();

    // Confirm in dialog
    await tester.tap(find.text('Cerrar sesión').last);
    await tester.pump();

    verify(() => mockAuthBloc.add(SignOutRequested())).called(1);
  });
}
