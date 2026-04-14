# Fase 7 — Pantalla de Configuración

## Objetivo

Pantalla de Settings (Tab 3 del BottomNavigationBar) con perfil del usuario, opción para cerrar sesión y toggle de notificaciones locales.

## Archivos

```
lib/features/settings/
└── presentation/
    └── pages/settings_page.dart

test/features/settings/
└── presentation/pages/settings_page_test.dart
```

## Implementación

### `lib/features/settings/presentation/pages/settings_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String _notifEnabledKey = 'notifications_enabled';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }
          final user = state.user;
          return ListView(
            children: [
              // Sección de perfil
              _ProfileSection(user: user),
              const Divider(),

              // Sección de notificaciones
              _NotificationsSection(),
              const Divider(),

              // Sección de sesión
              _SessionSection(),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final UserEntity user;
  const _ProfileSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null
            ? Text(user.displayName?.substring(0, 1).toUpperCase() ??
                user.email.substring(0, 1).toUpperCase())
            : null,
      ),
      title: Text(user.displayName ?? 'Usuario'),
      subtitle: Text(user.email),
    );
  }
}

class _NotificationsSection extends StatefulWidget {
  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _enabled = value);

    if (!value) {
      // Cancelar todas las notificaciones locales
      context.read<LocalNotificationService>().cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Notificaciones locales'),
      subtitle: const Text('Recordatorios de tareas con fecha'),
      value: _enabled,
      onChanged: _toggleNotifications,
    );
  }
}

class _SessionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                child: const Text('Cerrar sesión',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Tests

### `test/features/settings/presentation/pages/settings_page_test.dart`

```dart
void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  testWidgets('shows user info when authenticated', (tester) async {
    const user = UserEntity(id: '1', email: 'test@test.com', displayName: 'Test User');
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user: user));
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const SettingsPage(),
        ),
      ),
    );

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@test.com'), findsOneWidget);
  });

  testWidgets('dispatches SignOutRequested when logout confirmed', (tester) async {
    // Setup y verificar que el evento se dispara
  });

  testWidgets('shows notifications toggle', (tester) async {
    // Verificar que el SwitchListTile existe
  });
}
```

## Verificación

- [ ] Pantalla muestra nombre y email del usuario
- [ ] Avatar muestra foto si está disponible, inicial si no
- [ ] Toggle de notificaciones persiste en SharedPreferences
- [ ] Sign out muestra diálogo de confirmación
- [ ] Sign out confirmado dispara SignOutRequested y redirige a login
- [ ] Tests de SettingsPage pasan
