# Fase 8 — Integración Final y Pulido

## Objetivo

Conectar todas las capas, implementar navegación con auth guard, manejo global de errores, tema visual, splash screen y tests de integración end-to-end.

## Tareas

### 1. Navegación con GoRouter

Agregar `go_router: ^14.0.0` a pubspec.yaml.

```dart
// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter(this._authBloc);

  late final router = GoRouter(
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated = _authBloc.state is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScaffold(),
      ),
    ],
  );
}

// Helper para escuchar streams en GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

### 2. Manejo global de errores con SnackBars

```dart
// En cada BlocListener que corresponda:
BlocListener<TasksBloc, TasksState>(
  listener: (context, state) {
    if (state is TasksError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
)
```

### 3. Loading states

- Mostrar `CircularProgressIndicator` cuando `TasksLoading` o `AuthLoading`
- Deshabilitar botones durante carga para evitar doble tap

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return LoginForm(...);
  },
)
```

### 4. Tema visual

```dart
// lib/app.dart — actualizar EasyTodoApp
ThemeData _buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
```

Con toggle en Settings:
```dart
// shared_preferences key: 'theme_mode' → 'light' | 'dark' | 'system'
```

### 5. Splash Screen

Usar `flutter_native_splash: ^2.4.1` (opcional — añadir a pubspec.yaml).

O implementar manualmente con una pantalla que espera el primer estado de `AuthBloc`.

### 6. Inyección de dependencias completa

```dart
// lib/core/di/injection.dart — registrar todos los servicios

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();
}
```

Todos los repositorios, data sources y use cases decorados con `@injectable` o `@lazySingleton`.

### 7. `main.dart` completo

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();

  // Inicializar notificaciones locales
  final localNotifService = getIt<LocalNotificationService>();
  await localNotifService.initialize();

  // Inicializar push notifications (FCM)
  final pushService = getIt<PushNotificationService>();
  await pushService.initialize();
  await pushService.requestPermission();

  runApp(const EasyTodoApp());
}
```

## Tests de integración

### `test/app_test.dart`

```dart
void main() {
  testWidgets('shows login page when not authenticated', (tester) async {
    // Pump EasyTodoApp con AuthBloc mockeado en estado Unauthenticated
    // Verificar que LoginPage está visible
  });

  testWidgets('shows home when authenticated', (tester) async {
    // Pump EasyTodoApp con AuthBloc mockeado en AuthAuthenticated
    // Verificar que MainScaffold / HomePage está visible
  });

  testWidgets('redirects to login after sign out', (tester) async {
    // Empezar en Authenticated, disparar SignOut, verificar redirect a Login
  });
}
```

## Checklist final

- [ ] GoRouter navega correctamente según estado de auth
- [ ] Auth guard funciona: usuario no auth → login; auth → home
- [ ] Sign out redirige a login y cancela suscripciones
- [ ] Loading indicators en auth y tasks
- [ ] SnackBars muestran errores de auth y tasks
- [ ] Tema claro funciona visualmente
- [ ] Splash screen / estado inicial correcto
- [ ] `flutter analyze` sin errores
- [ ] `flutter test --coverage` pasa en verde
- [ ] App corre en Android e iOS sin crashes

## Comando final de verificación

```bash
flutter analyze
flutter test --coverage
flutter build apk --debug   # o flutter build ios --debug
```
