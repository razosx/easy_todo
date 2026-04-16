# Plan de Migración: BLoC + GetIt → Riverpod

**Fecha:** 2026-04-15
**Objetivo:** Crear una copia completa del proyecto (incluyendo `lib/`,
`pubspec.yaml` y `pubspec.lock`) en una carpeta aislada `easy_todo_riverpod/`
y migrar toda la gestión de estado de BLoC a Riverpod, eliminando `get_it`,
`injectable` y `flutter_bloc` del proyecto copiado. Los archivos originales
(`pubspec.yaml`, `pubspec.lock`, `lib/`) no se modifican.

---

## Inventario actual (lo que se migra)

| Componente | Archivo(s) | Tipo BLoC |
|------------|-----------|-----------|
| AuthBloc | `features/auth/presentation/bloc/auth_bloc.dart` + events + state | Bloc (5 eventos, 5 estados) |
| TasksBloc | `features/tasks/presentation/bloc/tasks_bloc.dart` + events + state | Bloc (6 eventos, 4 estados, stream subscription) |
| TeamBloc | `features/team_tasks/presentation/bloc/team_bloc.dart` + events + state | Bloc (6 eventos, 5 estados, stream subscription) |
| TeamTasksBloc | `features/team_tasks/presentation/bloc/team_tasks_bloc.dart` + events + state | Bloc (7 eventos, 4 estados, stream subscription) |
| ThemeCubit | `core/theme/theme_cubit.dart` | Cubit (estado: AppTheme enum) |
| LocaleCubit | `core/locale/locale_cubit.dart` | Cubit (estado: Locale) |
| DI (GetIt) | `core/di/injection.dart` + `injection.config.dart` | GetIt + Injectable (no usado realmente) |
| Router | `core/router/app_router.dart` | GoRouter con `GoRouterRefreshStream(authBloc.stream)` |
| App Bootstrap | `main.dart`, `app.dart` | Manual DI + MultiBlocProvider |

### Widgets que usan BLoC (deben migrar a ConsumerWidget/Consumer)

| Widget | Archivo | Uso de BLoC |
|--------|---------|-------------|
| LoginPage | `auth/presentation/pages/login_page.dart` | `BlocListener<AuthBloc, AuthState>` |
| EmailSignInForm | `auth/presentation/widgets/email_sign_in_form.dart` | `BlocBuilder<AuthBloc, AuthState>`, `context.read<AuthBloc>()` |
| GoogleSignInButton | `auth/presentation/widgets/google_sign_in_button.dart` | `BlocBuilder<AuthBloc, AuthState>`, `context.read<AuthBloc>()` |
| HomePage | `tasks/presentation/pages/home_page.dart` | `BlocBuilder<AuthBloc>`, `BlocConsumer<TasksBloc>`, `context.read<TasksBloc>()` |
| MainScaffold | `tasks/presentation/pages/main_scaffold.dart` | `BlocBuilder` (probablemente) |
| AddTaskBottomSheet | `tasks/presentation/widgets/add_task_bottom_sheet.dart` | `context.read<TasksBloc>()` |
| TeamTasksPage | `team_tasks/presentation/pages/team_tasks_page.dart` | `BlocConsumer<TeamBloc>`, `context.read<TeamTasksBloc>()`, `context.read<AuthBloc>()` |
| CreateTeamPage | `team_tasks/presentation/pages/create_team_page.dart` | `BlocConsumer<TeamBloc>`, `context.read<AuthBloc>()` |
| JoinTeamPage | `team_tasks/presentation/pages/join_team_page.dart` | `BlocConsumer<TeamBloc>`, `context.read<AuthBloc>()` |
| AddTeamTaskBottomSheet | `team_tasks/presentation/widgets/add_team_task_bottom_sheet.dart` | `context.read<TeamTasksBloc>()` |
| SettingsPage | `settings/presentation/pages/settings_page.dart` | `BlocBuilder<AuthBloc>`, `BlocBuilder<ThemeCubit>`, `BlocBuilder<LocaleCubit>` |
| app.dart | `app.dart` | `MultiBlocProvider`, `BlocBuilder<LocaleCubit>`, `BlocBuilder<ThemeCubit>` |

### Tests que se deben re-escribir

| Test | Archivo | Patrón actual |
|------|---------|---------------|
| AuthBloc test | `test/features/auth/presentation/bloc/auth_bloc_test.dart` | `blocTest<AuthBloc, AuthState>` |
| TasksBloc test | `test/features/tasks/presentation/bloc/tasks_bloc_test.dart` | `blocTest<TasksBloc, TasksState>` |
| TeamBloc test | `test/features/team_tasks/presentation/bloc/team_bloc_test.dart` | `blocTest<TeamBloc, TeamState>` |
| TeamTasksBloc test | `test/features/team_tasks/presentation/bloc/team_tasks_bloc_test.dart` | `blocTest<TeamTasksBloc, TeamTasksState>` |
| App test | `test/app_test.dart` | Usa `MultiBlocProvider` |
| SettingsPage test | `test/features/settings/presentation/pages/settings_page_test.dart` | Usa BLoC mocks |

---

## Mapeo BLoC → Riverpod

| BLoC/Cubit actual | Provider Riverpod equivalente | Justificación |
|-------------------|-------------------------------|---------------|
| `AuthBloc` | `AsyncNotifierProvider<AuthNotifier, AuthStatus>` | Maneja múltiples operaciones async con estados complejos |
| `TasksBloc` | `StreamNotifierProvider<TasksNotifier, TasksData>` o `AsyncNotifierProvider` con stream interno | Suscripción a Firestore stream + operaciones CRUD |
| `TeamBloc` | `AsyncNotifierProvider<TeamNotifier, TeamData>` con stream interno | Suscripción a Firestore stream + operaciones CRUD |
| `TeamTasksBloc` | `AsyncNotifierProvider<TeamTasksNotifier, TeamTasksData>` con stream interno | Suscripción a stream + categorización |
| `ThemeCubit` | `NotifierProvider<ThemeNotifier, AppTheme>` | Estado síncrono simple con persistencia |
| `LocaleCubit` | `NotifierProvider<LocaleNotifier, Locale>` | Estado síncrono simple |
| `GetIt` / Injectable | Eliminado — providers de Riverpod reemplazan la DI | Riverpod ES el sistema de DI |
| `RepositoryProvider` (CheckUsernameAvailable) | `Provider<CheckUsernameAvailable>` | Singleton simple |
| `RepositoryProvider` (LocalNotificationService) | `Provider<LocalNotificationService>` | Singleton simple |

---

## Phase 1: Preparación del entorno [✓]

### Descripción
Crear la copia de `lib/`, actualizar `pubspec.yaml` para la nueva versión, y
verificar que la copia compila antes de empezar los cambios.

### Sub-tareas

1. [✓] **Crear carpeta del proyecto copiado `easy_todo_riverpod/`**
   - Crear la carpeta al mismo nivel que `easy_todo/`:
     ```bash
     mkdir -p ../easy_todo_riverpod
     ```

2. [✓] **Copiar `lib/` al nuevo proyecto**
   - ```bash
     cp -r lib/ ../easy_todo_riverpod/lib/
     ```
   - Verificar que la copia es completa

3. [✓] **Copiar `pubspec.yaml` y `pubspec.lock` al nuevo proyecto**
   - ```bash
     cp pubspec.yaml ../easy_todo_riverpod/pubspec.yaml
     cp pubspec.lock ../easy_todo_riverpod/pubspec.lock
     ```
   - **IMPORTANTE:** A partir de aquí, todos los cambios a dependencias se hacen
     sobre `../easy_todo_riverpod/pubspec.yaml` y `../easy_todo_riverpod/pubspec.lock`.
     Los archivos originales en `easy_todo/` NO se tocan.

4. [✓] **Copiar archivos de configuración necesarios al nuevo proyecto**
   - ```bash
     cp -r test/ ../easy_todo_riverpod/test/
     cp -r android/ ../easy_todo_riverpod/android/
     cp -r ios/ ../easy_todo_riverpod/ios/
     cp -r web/ ../easy_todo_riverpod/web/        # si existe
     cp -r assets/ ../easy_todo_riverpod/assets/   # si existe
     cp -r l10n/ ../easy_todo_riverpod/l10n/       # si existe
     cp analysis_options.yaml ../easy_todo_riverpod/
     cp -r .dart_tool/ ../easy_todo_riverpod/      # si es necesario
     ```
   - Copiar cualquier otro archivo de configuración necesario para que el
     proyecto compile de forma independiente (firebase_options, google-services, etc.)

5. [✓] **Actualizar `../easy_todo_riverpod/pubspec.yaml` — Agregar dependencias de Riverpod**
   ```yaml
   # Agregar:
   flutter_riverpod: ^2.6.1
   riverpod_annotation: ^2.6.1

   # Agregar en dev_dependencies:
   riverpod_generator: ^2.6.3    # Opcional si se usan anotaciones
   riverpod_lint: ^2.6.3         # Linting para Riverpod
   ```

6. [✓] **Actualizar `../easy_todo_riverpod/pubspec.yaml` — Eliminar dependencias de BLoC y GetIt**
   ```yaml
   # Eliminar:
   flutter_bloc: ^9.0.0
   bloc: (si existe como transitiva explícita)
   get_it: ^9.2.1
   injectable: ^2.4.4

   # Eliminar de dev_dependencies:
   bloc_test: ^10.0.0
   injectable_generator: ^2.6.2
   ```

7. [✓] **Ejecutar `flutter pub get`** dentro de `../easy_todo_riverpod/` para
   regenerar el `pubspec.lock` con las nuevas dependencias

8. [✓] **Test de compilación base**: `flutter analyze` en `../easy_todo_riverpod/`
   (esperamos errores por los imports de BLoC — eso está bien, se corregirán en
   las fases siguientes)

> **Nota:** Desde la Phase 2 en adelante, todos los paths `lib_riverpod/` del
> plan se refieren a `../easy_todo_riverpod/lib/`. El proyecto original
> `easy_todo/` queda intacto durante toda la migración.

---

## Phase 2: Infraestructura de DI con Riverpod (reemplazar GetIt + main.dart) [✓]

### Descripción
Crear los providers de Riverpod que reemplazan la inyección manual de dependencias
que hoy se hace en `main.dart`. Esto incluye providers para Firebase, data sources,
repositories, use cases y servicios.

### Sub-tareas

1. [ ] **Eliminar `lib_riverpod/core/di/injection.dart` y `injection.config.dart`**
   - Estos archivos ya no se necesitan

2. [ ] **Crear `lib_riverpod/core/providers/firebase_providers.dart`**
   ```dart
   // Providers para instancias de Firebase
   final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
     return FirebaseAuth.instance;
   });

   final firestoreProvider = Provider<FirebaseFirestore>((ref) {
     return FirebaseFirestore.instance;
   });

   final googleSignInProvider = Provider<GoogleSignIn>((ref) {
     return GoogleSignIn();
   });
   ```

3. [ ] **Crear `lib_riverpod/core/providers/service_providers.dart`**
   ```dart
   // Providers para servicios de notificaciones
   final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
     return LocalNotificationServiceImpl();
   });

   final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
     return PushNotificationServiceImpl();
   });
   ```

4. [ ] **Crear `lib_riverpod/core/providers/data_source_providers.dart`**
   ```dart
   // Auth
   final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
     return AuthRemoteDataSourceImpl(
       firebaseAuth: ref.watch(firebaseAuthProvider),
       googleSignIn: ref.watch(googleSignInProvider),
       firestore: ref.watch(firestoreProvider),
     );
   });

   // Tasks
   final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
     return TaskRemoteDataSourceImpl(
       firestore: ref.watch(firestoreProvider),
     );
   });

   // Team
   final teamRemoteDataSourceProvider = Provider<TeamRemoteDataSource>((ref) {
     return TeamRemoteDataSourceImpl(
       firestore: ref.watch(firestoreProvider),
     );
   });

   // Team Tasks
   final teamTaskRemoteDataSourceProvider = Provider<TeamTaskRemoteDataSource>((ref) {
     return TeamTaskRemoteDataSourceImpl(
       firestore: ref.watch(firestoreProvider),
     );
   });
   ```

5. [ ] **Crear `lib_riverpod/core/providers/repository_providers.dart`**
   ```dart
   final authRepositoryProvider = Provider<AuthRepository>((ref) {
     return AuthRepositoryImpl(
       remoteDataSource: ref.watch(authRemoteDataSourceProvider),
     );
   });

   final taskRepositoryProvider = Provider<TaskRepository>((ref) {
     return TaskRepositoryImpl(
       remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
     );
   });

   final teamRepositoryProvider = Provider<TeamRepository>((ref) {
     return TeamRepositoryImpl(
       remoteDataSource: ref.watch(teamRemoteDataSourceProvider),
     );
   });

   final teamTaskRepositoryProvider = Provider<TeamTaskRepository>((ref) {
     return TeamTaskRepositoryImpl(
       remoteDataSource: ref.watch(teamTaskRemoteDataSourceProvider),
     );
   });
   ```

6. [ ] **Crear `lib_riverpod/core/providers/usecase_providers.dart`**
   ```dart
   // Auth use cases
   final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
     return SignInWithEmail(ref.watch(authRepositoryProvider));
   });
   final signUpWithEmailProvider = Provider<SignUpWithEmail>((ref) {
     return SignUpWithEmail(ref.watch(authRepositoryProvider));
   });
   final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
     return SignInWithGoogle(ref.watch(authRepositoryProvider));
   });
   final signOutProvider = Provider<SignOut>((ref) {
     return SignOut(ref.watch(authRepositoryProvider));
   });
   final checkUsernameAvailableProvider = Provider<CheckUsernameAvailable>((ref) {
     return CheckUsernameAvailable(ref.watch(authRepositoryProvider));
   });

   // Task use cases
   final getTasksProvider = Provider<GetTasks>((ref) {
     return GetTasks(ref.watch(taskRepositoryProvider));
   });
   final createTaskProvider = Provider<CreateTask>((ref) {
     return CreateTask(ref.watch(taskRepositoryProvider));
   });
   final deleteTaskProvider = Provider<DeleteTask>((ref) {
     return DeleteTask(ref.watch(taskRepositoryProvider));
   });
   final completeTaskProvider = Provider<CompleteTask>((ref) {
     return CompleteTask(ref.watch(taskRepositoryProvider));
   });

   // Team use cases
   final getTeamProvider = Provider<GetTeam>((ref) {
     return GetTeam(ref.watch(teamRepositoryProvider));
   });
   final createTeamProvider = Provider<CreateTeam>((ref) {
     return CreateTeam(ref.watch(teamRepositoryProvider));
   });
   final joinTeamProvider = Provider<JoinTeam>((ref) {
     return JoinTeam(ref.watch(teamRepositoryProvider));
   });
   final leaveTeamProvider = Provider<LeaveTeam>((ref) {
     return LeaveTeam(ref.watch(teamRepositoryProvider));
   });

   // Team Task use cases
   final getTeamTasksProvider = Provider<GetTeamTasks>((ref) {
     return GetTeamTasks(ref.watch(teamTaskRepositoryProvider));
   });
   final createTeamTaskProvider = Provider<CreateTeamTask>((ref) {
     return CreateTeamTask(ref.watch(teamTaskRepositoryProvider));
   });
   final assignTaskToMemberProvider = Provider<AssignTaskToMember>((ref) {
     return AssignTaskToMember(ref.watch(teamTaskRepositoryProvider));
   });
   final completeTeamTaskProvider = Provider<CompleteTeamTask>((ref) {
     return CompleteTeamTask(ref.watch(teamTaskRepositoryProvider));
   });
   final deleteTeamTaskProvider = Provider<DeleteTeamTask>((ref) {
     return DeleteTeamTask(ref.watch(teamTaskRepositoryProvider));
   });
   ```

7. [ ] **Escribir tests para los providers de DI**
   - Crear `test/core/providers/provider_initialization_test.dart`
   - Test: verificar que cada provider se puede crear dentro de un `ProviderContainer`
   - Test: verificar que las dependencias se resuelven correctamente en cadena
   - Test: verificar que los providers devuelven las implementaciones correctas

---

## Phase 3: Migrar ThemeCubit y LocaleCubit a Riverpod Notifiers [✓]

### Descripción
Estos son los más simples de migrar. Son Cubits con estado síncrono y lógica
mínima. Se convierten en `Notifier` de Riverpod.

### Sub-tareas

1. [ ] **Escribir tests para `ThemeNotifier`**
   - Crear `test/core/theme/theme_notifier_test.dart`
   - Test: estado inicial es el tema por defecto
   - Test: `setTheme(AppTheme.dark)` cambia el estado
   - Test: `initialize()` carga el tema desde SharedPreferences
   - Test: `setTheme()` persiste en SharedPreferences
   - Usar `ProviderContainer` para tests

2. [ ] **Migrar `ThemeCubit` → `ThemeNotifier`**
   - Renombrar archivo: `lib_riverpod/core/theme/theme_cubit.dart` → `theme_notifier.dart`
   - Cambiar de `Cubit<AppTheme>` a `Notifier<AppTheme>`
   - Crear `themeNotifierProvider`:
   ```dart
   final themeNotifierProvider = NotifierProvider<ThemeNotifier, AppTheme>(
     ThemeNotifier.new,
   );

   class ThemeNotifier extends Notifier<AppTheme> {
     @override
     AppTheme build() => AppTheme.light;  // Estado inicial

     Future<void> initialize() async {
       final prefs = await SharedPreferences.getInstance();
       final saved = prefs.getString('theme');
       if (saved != null) {
         state = AppTheme.values.firstWhere(
           (t) => t.name == saved,
           orElse: () => AppTheme.light,
         );
       }
     }

     Future<void> setTheme(AppTheme theme) async {
       state = theme;
       final prefs = await SharedPreferences.getInstance();
       await prefs.setString('theme', theme.name);
     }
   }
   ```

3. [ ] **Verificar que los tests de `ThemeNotifier` pasan**

4. [ ] **Escribir tests para `LocaleNotifier`**
   - Crear `test/core/locale/locale_notifier_test.dart`
   - Test: estado inicial es locale del dispositivo o 'en'
   - Test: `setLocale(Locale('es'))` cambia el estado
   - Test: `setLocale(Locale('en'))` cambia el estado

5. [ ] **Migrar `LocaleCubit` → `LocaleNotifier`**
   - Renombrar archivo: `lib_riverpod/core/locale/locale_cubit.dart` → `locale_notifier.dart`
   - Cambiar de `Cubit<Locale>` a `Notifier<Locale>`:
   ```dart
   final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale>(
     LocaleNotifier.new,
   );

   class LocaleNotifier extends Notifier<Locale> {
     @override
     Locale build() {
       // Lógica existente: detectar locale del dispositivo
       final deviceLocale = PlatformDispatcher.instance.locale;
       final supported = ['en', 'es'];
       if (supported.contains(deviceLocale.languageCode)) {
         return deviceLocale;
       }
       return const Locale('en');
     }

     void setLocale(Locale locale) {
       state = locale;
     }
   }
   ```

6. [ ] **Verificar que los tests de `LocaleNotifier` pasan**

---

## Phase 4: Migrar AuthBloc → AuthNotifier [✓]

### Descripción
Este es el BLoC más crítico. Maneja autenticación, sesión persistida y
determina el flujo de navegación. Se convierte en un `AsyncNotifier` con un
estado sealed class.

### Sub-tareas

1. [ ] **Definir el estado de auth para Riverpod**
   - Crear `lib_riverpod/features/auth/presentation/notifiers/auth_state.dart`:
   ```dart
   // Reusar las mismas clases de estado existentes (AuthInitial, AuthLoading, etc.)
   // O migrar a un sealed class:
   sealed class AuthStatus {
     const AuthStatus();
   }
   class AuthStatusInitial extends AuthStatus { const AuthStatusInitial(); }
   class AuthStatusLoading extends AuthStatus { const AuthStatusLoading(); }
   class AuthStatusAuthenticated extends AuthStatus {
     final UserEntity user;
     const AuthStatusAuthenticated(this.user);
   }
   class AuthStatusUnauthenticated extends AuthStatus { const AuthStatusUnauthenticated(); }
   class AuthStatusError extends AuthStatus {
     final String message;
     const AuthStatusError(this.message);
   }
   ```

2. [ ] **Escribir tests para `AuthNotifier`**
   - Crear `test/features/auth/presentation/notifiers/auth_notifier_test.dart`
   - Tests a escribir (mismos escenarios que `auth_bloc_test.dart`):
     - Test: `checkAuth()` → cuando `currentUser == null` → emite `AuthStatusUnauthenticated`
     - Test: `checkAuth()` → cuando `currentUser != null` y `getFullCurrentUser` retorna user → emite `AuthStatusAuthenticated(user)`
     - Test: `signInWithEmail(email, password)` → success → emite `AuthStatusAuthenticated(user)`
     - Test: `signInWithEmail(email, password)` → failure → emite `AuthStatusError(message)`
     - Test: `signUpWithEmail(...)` → success → emite `AuthStatusAuthenticated(user)`
     - Test: `signUpWithEmail(...)` → failure → emite `AuthStatusError(message)`
     - Test: `signInWithGoogle()` → success → emite `AuthStatusAuthenticated(user)`
     - Test: `signInWithGoogle()` → failure → emite `AuthStatusError(message)`
     - Test: `signOut()` → success → emite `AuthStatusUnauthenticated`
     - Test: `signOut()` → failure → emite `AuthStatusError(message)`
   - Patrón de test con Riverpod:
   ```dart
   final container = ProviderContainer(
     overrides: [
       authRepositoryProvider.overrideWithValue(mockAuthRepo),
       signInWithEmailProvider.overrideWithValue(mockSignInWithEmail),
       // ... demás mocks
     ],
   );
   final notifier = container.read(authNotifierProvider.notifier);
   await notifier.signInWithEmail('test@test.com', '123456');
   expect(container.read(authNotifierProvider), isA<AuthStatusAuthenticated>());
   ```

3. [ ] **Crear `AuthNotifier`**
   - Crear `lib_riverpod/features/auth/presentation/notifiers/auth_notifier.dart`
   ```dart
   final authNotifierProvider = NotifierProvider<AuthNotifier, AuthStatus>(
     AuthNotifier.new,
   );

   class AuthNotifier extends Notifier<AuthStatus> {
     @override
     AuthStatus build() {
       // Revisar sesión al construir el provider
       _checkAuth();
       return const AuthStatusInitial();
     }

     Future<void> _checkAuth() async {
       final authRepo = ref.read(authRepositoryProvider);
       final currentUser = authRepo.currentUser;
       if (currentUser == null) {
         state = const AuthStatusUnauthenticated();
         return;
       }
       final result = await authRepo.getFullCurrentUser();
       result.fold(
         (failure) => state = const AuthStatusUnauthenticated(),
         (user) => user != null
             ? state = AuthStatusAuthenticated(user)
             : state = const AuthStatusUnauthenticated(),
       );
     }

     Future<void> signInWithEmail(String email, String password) async {
       state = const AuthStatusLoading();
       final result = await ref.read(signInWithEmailProvider).call(
         SignInWithEmailParams(email: email, password: password),
       );
       result.fold(
         (failure) => state = AuthStatusError(failure.message),
         (user) => state = AuthStatusAuthenticated(user),
       );
     }

     Future<void> signUpWithEmail({
       required String email,
       required String password,
       required String name,
       required String username,
     }) async {
       state = const AuthStatusLoading();
       final result = await ref.read(signUpWithEmailProvider).call(
         SignUpWithEmailParams(
           email: email, password: password,
           name: name, username: username,
         ),
       );
       result.fold(
         (failure) => state = AuthStatusError(failure.message),
         (user) => state = AuthStatusAuthenticated(user),
       );
     }

     Future<void> signInWithGoogle() async {
       state = const AuthStatusLoading();
       final result = await ref.read(signInWithGoogleProvider).call(NoParams());
       result.fold(
         (failure) => state = AuthStatusError(failure.message),
         (user) => state = AuthStatusAuthenticated(user),
       );
     }

     Future<void> signOut() async {
       state = const AuthStatusLoading();
       final result = await ref.read(signOutProvider).call(NoParams());
       result.fold(
         (failure) => state = AuthStatusError(failure.message),
         (_) => state = const AuthStatusUnauthenticated(),
       );
     }
   }
   ```

4. [ ] **Eliminar archivos BLoC de auth**
   - Eliminar `lib_riverpod/features/auth/presentation/bloc/` (directorio completo)

5. [ ] **Verificar que los tests de `AuthNotifier` pasan**

---

## Phase 5: Migrar TasksBloc → TasksNotifier [✓]

### Descripción
El `TasksBloc` tiene una suscripción a un stream de Firestore y lógica
de categorización de tareas. Se convierte en un `AsyncNotifier` que maneja
el stream internamente.

### Sub-tareas

1. [ ] **Definir el estado de tasks para Riverpod**
   - Crear `lib_riverpod/features/tasks/presentation/notifiers/tasks_state.dart`:
   ```dart
   sealed class TasksStatus {
     const TasksStatus();
   }
   class TasksStatusInitial extends TasksStatus { const TasksStatusInitial(); }
   class TasksStatusLoading extends TasksStatus { const TasksStatusLoading(); }
   class TasksStatusLoaded extends TasksStatus {
     final List<TaskEntity> todayTasks;
     final List<TaskEntity> upcomingTasks;
     final List<TaskEntity> completedTasks;
     const TasksStatusLoaded({
       required this.todayTasks,
       required this.upcomingTasks,
       required this.completedTasks,
     });
   }
   class TasksStatusError extends TasksStatus {
     final String message;
     const TasksStatusError(this.message);
   }
   ```

2. [ ] **Escribir tests para `TasksNotifier`**
   - Crear `test/features/tasks/presentation/notifiers/tasks_notifier_test.dart`
   - Tests:
     - Test: `loadTasks(userId)` → suscribe al stream → categoriza tareas correctamente
     - Test: categorización — completed va a `completedTasks`, future dueDate a `upcomingTasks`, resto a `todayTasks`
     - Test: `createTask(task, title, body)` → llama `createTask` use case + programa notificación
     - Test: `deleteTask(taskId, userId)` → llama `deleteTask` use case + cancela notificación
     - Test: `completeTask(taskId, userId)` → llama `completeTask` use case + cancela notificación
     - Test: error en stream → emite `TasksStatusError`
     - Test: notificación se programa con los datos correctos

3. [ ] **Crear `TasksNotifier`**
   - Crear `lib_riverpod/features/tasks/presentation/notifiers/tasks_notifier.dart`:
   ```dart
   final tasksNotifierProvider = NotifierProvider<TasksNotifier, TasksStatus>(
     TasksNotifier.new,
   );

   class TasksNotifier extends Notifier<TasksStatus> {
     StreamSubscription? _tasksSubscription;

     @override
     TasksStatus build() {
       ref.onDispose(() => _tasksSubscription?.cancel());
       return const TasksStatusInitial();
     }

     void loadTasks(String userId) {
       state = const TasksStatusLoading();
       _tasksSubscription?.cancel();

       final stream = ref.read(getTasksProvider).call(
         GetTasksParams(userId: userId),
       );

       _tasksSubscription = stream.listen(
         (either) => either.fold(
           (failure) => state = TasksStatusError(failure.message),
           (tasks) => _categorizeTasks(tasks),
         ),
       );
     }

     void _categorizeTasks(List<TaskEntity> tasks) {
       final now = DateTime.now();
       final today = DateTime(now.year, now.month, now.day);
       final completed = <TaskEntity>[];
       final upcoming = <TaskEntity>[];
       final todayList = <TaskEntity>[];

       for (final task in tasks) {
         if (task.isCompleted) {
           completed.add(task);
         } else if (task.dueDate != null && task.dueDate!.isAfter(today.add(const Duration(days: 1)))) {
           upcoming.add(task);
         } else {
           todayList.add(task);
         }
       }

       state = TasksStatusLoaded(
         todayTasks: todayList,
         upcomingTasks: upcoming,
         completedTasks: completed,
       );
     }

     Future<void> createTask(TaskEntity task, String notifTitle, String notifBody) async {
       final result = await ref.read(createTaskProvider).call(task);
       result.fold(
         (failure) => state = TasksStatusError(failure.message),
         (createdTask) {
           if (createdTask.dueDate != null && createdTask.notificationId != null) {
             ref.read(localNotificationServiceProvider).scheduleTaskNotification(
               id: createdTask.notificationId!,
               title: notifTitle,
               body: notifBody,
               scheduledDate: createdTask.dueDate!,
             );
           }
         },
       );
     }

     Future<void> deleteTask(String taskId, String userId) async {
       ref.read(localNotificationServiceProvider).cancelNotification(taskId.hashCode);
       await ref.read(deleteTaskProvider).call(
         DeleteTaskParams(taskId: taskId, userId: userId),
       );
     }

     Future<void> completeTask(String taskId, String userId) async {
       ref.read(localNotificationServiceProvider).cancelNotification(taskId.hashCode);
       await ref.read(completeTaskProvider).call(
         CompleteTaskParams(taskId: taskId, userId: userId),
       );
     }
   }
   ```

4. [ ] **Eliminar archivos BLoC de tasks**
   - Eliminar `lib_riverpod/features/tasks/presentation/bloc/` (directorio completo)

5. [ ] **Verificar que los tests de `TasksNotifier` pasan**

---

## Phase 6: Migrar TeamBloc → TeamNotifier [✓]

### Descripción
Similar al `TasksBloc`, el `TeamBloc` tiene suscripción a stream + operaciones
CRUD. Se convierte en `Notifier`.

### Sub-tareas

1. [ ] **Definir el estado de team para Riverpod**
   - Crear `lib_riverpod/features/team_tasks/presentation/notifiers/team_state.dart`:
   ```dart
   sealed class TeamStatus {
     const TeamStatus();
   }
   class TeamStatusInitial extends TeamStatus { const TeamStatusInitial(); }
   class TeamStatusLoading extends TeamStatus { const TeamStatusLoading(); }
   class TeamStatusNone extends TeamStatus { const TeamStatusNone(); }
   class TeamStatusLoaded extends TeamStatus {
     final TeamEntity team;
     const TeamStatusLoaded(this.team);
   }
   class TeamStatusError extends TeamStatus {
     final String message;
     const TeamStatusError(this.message);
   }
   ```

2. [ ] **Escribir tests para `TeamNotifier`**
   - Crear `test/features/team_tasks/presentation/notifiers/team_notifier_test.dart`
   - Tests:
     - Test: `loadTeam(userId)` → suscribe al stream → emite `TeamStatusLoaded` o `TeamStatusNone`
     - Test: `createTeam(...)` → success → no cambia state (stream se encarga)
     - Test: `createTeam(...)` → failure → emite `TeamStatusError`
     - Test: `joinTeam(...)` → success/failure
     - Test: `leaveTeam(...)` → success → emite `TeamStatusNone`
     - Test: error en stream → emite `TeamStatusError`

3. [ ] **Crear `TeamNotifier`**
   - Crear `lib_riverpod/features/team_tasks/presentation/notifiers/team_notifier.dart`:
   ```dart
   final teamNotifierProvider = NotifierProvider<TeamNotifier, TeamStatus>(
     TeamNotifier.new,
   );

   class TeamNotifier extends Notifier<TeamStatus> {
     StreamSubscription? _teamSubscription;

     @override
     TeamStatus build() {
       ref.onDispose(() => _teamSubscription?.cancel());
       return const TeamStatusInitial();
     }

     void loadTeam(String userId) {
       state = const TeamStatusLoading();
       _teamSubscription?.cancel();
       final stream = ref.read(getTeamProvider).call(
         GetTeamParams(userId: userId),
       );
       _teamSubscription = stream.listen(
         (either) => either.fold(
           (failure) => state = TeamStatusError(failure.message),
           (team) => team != null
               ? state = TeamStatusLoaded(team)
               : state = const TeamStatusNone(),
         ),
       );
     }

     Future<void> createTeam({
       required String name,
       required String userId,
       String? username,
       String? memberName,
     }) async { ... }

     Future<void> joinTeam({
       required String inviteCode,
       required String userId,
       String? username,
       String? memberName,
     }) async { ... }

     Future<void> leaveTeam(String teamId, String userId) async { ... }
   }
   ```

4. [ ] **Eliminar archivos BLoC de team**
   - Eliminar `lib_riverpod/features/team_tasks/presentation/bloc/team_bloc.dart`
   - Eliminar `lib_riverpod/features/team_tasks/presentation/bloc/team_event.dart`
   - Eliminar `lib_riverpod/features/team_tasks/presentation/bloc/team_state.dart`

5. [ ] **Verificar que los tests de `TeamNotifier` pasan**

---

## Phase 7: Migrar TeamTasksBloc → TeamTasksNotifier [ ]

### Descripción
El `TeamTasksBloc` tiene la lógica más compleja de categorización
(assignedToMe, unassigned, assignedToOthers, completed) y necesita conocer
el `currentUserId`.

### Sub-tareas

1. [ ] **Definir el estado de team tasks para Riverpod**
   - Crear `lib_riverpod/features/team_tasks/presentation/notifiers/team_tasks_state.dart`:
   ```dart
   sealed class TeamTasksStatus {
     const TeamTasksStatus();
   }
   class TeamTasksStatusInitial extends TeamTasksStatus { const TeamTasksStatusInitial(); }
   class TeamTasksStatusLoading extends TeamTasksStatus { const TeamTasksStatusLoading(); }
   class TeamTasksStatusLoaded extends TeamTasksStatus {
     final List<TeamTaskEntity> assignedToMe;
     final List<TeamTaskEntity> unassigned;
     final List<TeamTaskEntity> assignedToOthers;
     final List<TeamTaskEntity> completed;
     const TeamTasksStatusLoaded({
       required this.assignedToMe,
       required this.unassigned,
       required this.assignedToOthers,
       required this.completed,
     });
   }
   class TeamTasksStatusError extends TeamTasksStatus {
     final String message;
     const TeamTasksStatusError(this.message);
   }
   ```

2. [ ] **Crear un provider para el `currentUserId`**
   - En `lib_riverpod/core/providers/user_providers.dart`:
   ```dart
   // StateProvider simple para el userId actual
   final currentUserIdProvider = StateProvider<String?>((ref) => null);
   ```

3. [ ] **Escribir tests para `TeamTasksNotifier`**
   - Crear `test/features/team_tasks/presentation/notifiers/team_tasks_notifier_test.dart`
   - Tests:
     - Test: `loadTeamTasks(teamId)` → suscribe al stream → categoriza correctamente
     - Test: tareas con `assignedTo == currentUserId` van a `assignedToMe`
     - Test: tareas con `assignedTo == null` van a `unassigned`
     - Test: tareas con `assignedTo != currentUserId` van a `assignedToOthers`
     - Test: tareas con `isCompleted == true` van a `completed`
     - Test: `createTeamTask(task)` → success/failure
     - Test: `assignTask(taskId, teamId, assigneeId)` → success/failure
     - Test: `completeTeamTask(taskId, teamId)` → success/failure
     - Test: `deleteTeamTask(taskId, teamId)` → success/failure

4. [ ] **Crear `TeamTasksNotifier`**
   - Crear `lib_riverpod/features/team_tasks/presentation/notifiers/team_tasks_notifier.dart`:
   ```dart
   final teamTasksNotifierProvider = NotifierProvider<TeamTasksNotifier, TeamTasksStatus>(
     TeamTasksNotifier.new,
   );

   class TeamTasksNotifier extends Notifier<TeamTasksStatus> {
     StreamSubscription? _tasksSubscription;

     @override
     TeamTasksStatus build() {
       ref.onDispose(() => _tasksSubscription?.cancel());
       return const TeamTasksStatusInitial();
     }

     void loadTeamTasks(String teamId) {
       state = const TeamTasksStatusLoading();
       _tasksSubscription?.cancel();
       final stream = ref.read(getTeamTasksProvider).call(
         GetTeamTasksParams(teamId: teamId),
       );
       _tasksSubscription = stream.listen(
         (either) => either.fold(
           (failure) => state = TeamTasksStatusError(failure.message),
           (tasks) => _categorizeTasks(tasks),
         ),
       );
     }

     void _categorizeTasks(List<TeamTaskEntity> tasks) {
       final currentUserId = ref.read(currentUserIdProvider);
       final assignedToMe = <TeamTaskEntity>[];
       final unassigned = <TeamTaskEntity>[];
       final assignedToOthers = <TeamTaskEntity>[];
       final completed = <TeamTaskEntity>[];

       for (final task in tasks) {
         if (task.isCompleted) {
           completed.add(task);
         } else if (task.assignedTo == currentUserId) {
           assignedToMe.add(task);
         } else if (task.assignedTo == null) {
           unassigned.add(task);
         } else {
           assignedToOthers.add(task);
         }
       }

       state = TeamTasksStatusLoaded(
         assignedToMe: assignedToMe,
         unassigned: unassigned,
         assignedToOthers: assignedToOthers,
         completed: completed,
       );
     }

     Future<void> createTeamTask(TeamTaskEntity task) async { ... }
     Future<void> assignTask(String taskId, String teamId, String? assigneeId) async { ... }
     Future<void> completeTeamTask(String taskId, String teamId) async { ... }
     Future<void> deleteTeamTask(String taskId, String teamId) async { ... }
   }
   ```

5. [ ] **Eliminar archivos BLoC de team tasks**
   - Eliminar `lib_riverpod/features/team_tasks/presentation/bloc/team_tasks_bloc.dart`
   - Eliminar `lib_riverpod/features/team_tasks/presentation/bloc/team_tasks_event.dart`
   - Eliminar `lib_riverpod/features/team_tasks/presentation/bloc/team_tasks_state.dart`

6. [ ] **Verificar que los tests de `TeamTasksNotifier` pasan**

---

## Phase 8: Migrar main.dart y app.dart [ ]

### Descripción
Reescribir el bootstrap de la app para usar `ProviderScope` en lugar de
`MultiBlocProvider`, y eliminar toda la construcción manual de dependencias
de `main.dart`.

### Sub-tareas

1. [ ] **Escribir tests para la inicialización de la app**
   - Actualizar `test/app_test.dart`:
   - Test: la app se inicializa con `ProviderScope`
   - Test: cuando `AuthStatus` es `AuthStatusAuthenticated` → muestra `MainScaffold`
   - Test: cuando `AuthStatus` es `AuthStatusUnauthenticated` → muestra `LoginPage`

2. [ ] **Migrar `main.dart`**
   - Eliminar toda la construcción manual de dependencias (líneas 65-96 aprox.)
   - Mantener: inicialización de Firebase, notificaciones, date formatting
   - Envolver `EasyTodoApp` en `ProviderScope`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await initializeDateFormatting('es');
     await initializeDateFormatting('en');
     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

     // Notificaciones se inicializan via providers, no manualmente

     runApp(
       const ProviderScope(
         child: EasyTodoApp(),
       ),
     );
   }
   ```
   - **Nota:** Las notificaciones necesitan inicializarse temprano. Opción A: inicializar
     en `main()` y pasar via `ProviderScope(overrides: [...])`. Opción B: inicializar
     dentro del provider con un `FutureProvider`.

3. [ ] **Migrar `app.dart`**
   - Cambiar `EasyTodoApp` de `StatefulWidget` a `ConsumerStatefulWidget`
   - Eliminar: constructor con 15+ parámetros de dependencias
   - Eliminar: `_authBloc`, `_tasksBloc`, `_teamBloc`, `_teamTasksBloc`, `_themeCubit`, `_localeCubit`
   - Eliminar: `MultiBlocProvider` wrapper
   - Eliminar: `_authSub` StreamSubscription manual
   - Reemplazar `BlocBuilder<LocaleCubit, Locale>` → `ref.watch(localeNotifierProvider)`
   - Reemplazar `BlocBuilder<ThemeCubit, AppTheme>` → `ref.watch(themeNotifierProvider)`
   - Escuchar cambios de auth para cargar tasks/team:
   ```dart
   class EasyTodoApp extends ConsumerStatefulWidget {
     const EasyTodoApp({super.key});

     @override
     ConsumerState<EasyTodoApp> createState() => _EasyTodoAppState();
   }

   class _EasyTodoAppState extends ConsumerState<EasyTodoApp> {
     late final AppRouter _appRouter;

     @override
     void initState() {
       super.initState();
       _appRouter = AppRouter(ref);  // Pasar ref al router
       ref.read(themeNotifierProvider.notifier).initialize();
     }

     @override
     Widget build(BuildContext context) {
       final locale = ref.watch(localeNotifierProvider);
       final theme = ref.watch(themeNotifierProvider);

       // Escuchar auth state para cargar datos reactivamente
       ref.listen<AuthStatus>(authNotifierProvider, (prev, next) {
         if (next is AuthStatusAuthenticated) {
           ref.read(tasksNotifierProvider.notifier).loadTasks(next.user.id);
           ref.read(teamNotifierProvider.notifier).loadTeam(next.user.id);
           ref.read(currentUserIdProvider.notifier).state = next.user.id;
         }
       });

       return MaterialApp.router(
         locale: locale,
         theme: theme.toThemeData(),
         routerConfig: _appRouter.router,
         // ...
       );
     }
   }
   ```

4. [ ] **Verificar que los tests de app pasan**

---

## Phase 9: Migrar AppRouter (GoRouter + Auth Redirect) [ ]

### Descripción
El router actual usa `GoRouterRefreshStream(authBloc.stream)` para redirigir
basado en el estado del BLoC. Con Riverpod, se usa un `ChangeNotifier` que
escucha el provider de auth.

### Sub-tareas

1. [ ] **Migrar `AppRouter`**
   - Modificar `lib_riverpod/core/router/app_router.dart`:
   ```dart
   class AppRouter {
     final Ref _ref;

     AppRouter(this._ref);

     late final GoRouter router = GoRouter(
       initialLocation: '/',
       refreshListenable: _AuthRefreshNotifier(_ref),
       redirect: _redirect,
       routes: [
         GoRoute(path: '/', builder: (_, __) => const _LoadingPage()),
         GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
         GoRoute(path: '/home', builder: (_, __) => const MainScaffold()),
       ],
     );

     String? _redirect(BuildContext context, GoRouterState routerState) {
       final authStatus = _ref.read(authNotifierProvider);
       final currentPath = routerState.uri.path;

       return switch (authStatus) {
         AuthStatusInitial() || AuthStatusLoading() =>
           currentPath == '/' ? null : '/',
         AuthStatusAuthenticated() =>
           currentPath == '/home' ? null : '/home',
         AuthStatusUnauthenticated() || AuthStatusError() =>
           currentPath == '/login' ? null : '/login',
       };
     }
   }

   // Adaptador: escucha el provider y notifica a GoRouter
   class _AuthRefreshNotifier extends ChangeNotifier {
     _AuthRefreshNotifier(Ref ref) {
       ref.listen<AuthStatus>(authNotifierProvider, (_, __) {
         notifyListeners();
       });
     }
   }
   ```

2. [ ] **Eliminar `GoRouterRefreshStream`** (ya no se necesita)

3. [ ] **Verificar que el routing funciona con los tests de app**

---

## Phase 10: Migrar widgets de Auth (LoginPage, EmailSignInForm, GoogleSignInButton) [ ]

### Descripción
Migrar todos los widgets de autenticación de `BlocListener`/`BlocBuilder`
a `ConsumerWidget`/`ConsumerStatefulWidget` con `ref.watch`/`ref.listen`.

### Sub-tareas

1. [ ] **Migrar `LoginPage`**
   - Cambiar a `ConsumerWidget`
   - `BlocListener<AuthBloc, AuthState>` → `ref.listen<AuthStatus>(authNotifierProvider, ...)`
   - Eliminar imports de `flutter_bloc`
   ```dart
   class LoginPage extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       ref.listen<AuthStatus>(authNotifierProvider, (prev, next) {
         if (next is AuthStatusError) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(next.message)),
           );
         }
       });
       // ... resto del build
     }
   }
   ```

2. [ ] **Migrar `EmailSignInForm`**
   - Cambiar a `ConsumerStatefulWidget` + `ConsumerState`
   - `BlocBuilder<AuthBloc, AuthState>` → `ref.watch(authNotifierProvider)`
   - `context.read<AuthBloc>().add(SignInWithEmailRequested(...))` →
     `ref.read(authNotifierProvider.notifier).signInWithEmail(...)`
   - `context.read<AuthBloc>().add(SignUpWithEmailRequested(...))` →
     `ref.read(authNotifierProvider.notifier).signUpWithEmail(...)`
   - `RepositoryProvider.of<CheckUsernameAvailable>(context)` →
     `ref.read(checkUsernameAvailableProvider)`
   - Mantener la lógica de debounce del username intacta

3. [ ] **Migrar `GoogleSignInButton`**
   - Cambiar a `ConsumerWidget`
   - `BlocBuilder<AuthBloc, AuthState>` → `ref.watch(authNotifierProvider)`
   - `context.read<AuthBloc>().add(SignInWithGoogleRequested())` →
     `ref.read(authNotifierProvider.notifier).signInWithGoogle()`

4. [ ] **Verificar que la UI compila sin errores de BLoC**

---

## Phase 11: Migrar widgets de Tasks (HomePage, MainScaffold, AddTaskBottomSheet) [ ]

### Descripción
Migrar los widgets de la feature de tasks para usar `ref.watch` y `ref.read`
en lugar de `BlocBuilder`/`BlocConsumer`/`context.read<BLoC>()`.

### Sub-tareas

1. [ ] **Migrar `HomePage`**
   - Cambiar a `ConsumerWidget`
   - `BlocBuilder<AuthBloc, AuthState>` → `ref.watch(authNotifierProvider)`
   - `BlocConsumer<TasksBloc, TasksState>` → `ref.watch(tasksNotifierProvider)` + `ref.listen(...)`
   - `context.read<TasksBloc>().add(CompleteTaskRequested(...))` →
     `ref.read(tasksNotifierProvider.notifier).completeTask(...)`
   - `context.read<TasksBloc>().add(DeleteTaskRequested(...))` →
     `ref.read(tasksNotifierProvider.notifier).deleteTask(...)`
   - Snackbar en error: `ref.listen<TasksStatus>(tasksNotifierProvider, ...)`

2. [ ] **Migrar `MainScaffold`**
   - Cambiar a `ConsumerStatefulWidget` si usa state, o `ConsumerWidget`
   - Reemplazar cualquier uso de BLoC por providers

3. [ ] **Migrar `AddTaskBottomSheet`**
   - Cambiar a `ConsumerWidget` o `ConsumerStatefulWidget`
   - `context.read<TasksBloc>().add(CreateTaskRequested(...))` →
     `ref.read(tasksNotifierProvider.notifier).createTask(...)`
   - `context.read<AuthBloc>().state` →
     `ref.read(authNotifierProvider)` para obtener el userId

4. [ ] **Migrar `TaskCard` y `TaskListSection`** si tienen uso de BLoC

5. [ ] **Verificar que la UI de tasks compila**

---

## Phase 12: Migrar widgets de Team Tasks (TeamTasksPage, CreateTeamPage, JoinTeamPage) [ ]

### Descripción
Migrar los widgets de la feature de team tasks. Estos son los más complejos
porque usan `BlocConsumer<TeamBloc>` + `context.read<TeamTasksBloc>()` +
`context.read<AuthBloc>()` + `BlocProvider.value` para navegación.

### Sub-tareas

1. [ ] **Migrar `TeamTasksPage`**
   - Cambiar a `ConsumerStatefulWidget`
   - `BlocConsumer<TeamBloc, TeamState>` → `ref.watch(teamNotifierProvider)` + `ref.listen(...)`
   - `context.read<AuthBloc>().state` → `ref.read(authNotifierProvider)`
   - `context.read<TeamTasksBloc>().setCurrentUserId(...)` → ya no necesario (se usa `currentUserIdProvider`)
   - `context.read<TeamTasksBloc>().add(LoadTeamTasksRequested(...))` →
     `ref.read(teamTasksNotifierProvider.notifier).loadTeamTasks(...)`
   - **Eliminar `BlocProvider.value` en navegación** — con Riverpod los providers
     son globales, no necesitan pasarse via widget tree:
   ```dart
   // ANTES (BLoC):
   Navigator.push(context, MaterialPageRoute(
     builder: (_) => BlocProvider.value(
       value: context.read<TeamBloc>(),
       child: BlocProvider.value(
         value: context.read<AuthBloc>(),
         child: const CreateTeamPage(),
       ),
     ),
   ));

   // DESPUÉS (Riverpod):
   Navigator.push(context, MaterialPageRoute(
     builder: (_) => const CreateTeamPage(),
   ));
   ```

2. [ ] **Migrar `CreateTeamPage`**
   - Cambiar a `ConsumerStatefulWidget`
   - `BlocConsumer<TeamBloc, TeamState>` → `ref.watch` + `ref.listen`
   - `context.read<AuthBloc>().state` → `ref.read(authNotifierProvider)`
   - `context.read<TeamBloc>().add(CreateTeamRequested(...))` →
     `ref.read(teamNotifierProvider.notifier).createTeam(...)`

3. [ ] **Migrar `JoinTeamPage`**
   - Mismo patrón que `CreateTeamPage`
   - `context.read<TeamBloc>().add(JoinTeamRequested(...))` →
     `ref.read(teamNotifierProvider.notifier).joinTeam(...)`

4. [ ] **Migrar `AddTeamTaskBottomSheet`**
   - `context.read<TeamTasksBloc>().add(CreateTeamTaskRequested(...))` →
     `ref.read(teamTasksNotifierProvider.notifier).createTeamTask(...)`

5. [ ] **Migrar `TeamTaskCard` y `MemberAvatarList`** si tienen uso de BLoC

6. [ ] **Verificar que la UI de team tasks compila**

---

## Phase 13: Migrar SettingsPage [ ]

### Descripción
La settings page usa `BlocBuilder` para auth, theme y locale.

### Sub-tareas

1. [ ] **Migrar `SettingsPage`**
   - Cambiar a `ConsumerWidget`
   - `BlocBuilder<AuthBloc, AuthState>` → `ref.watch(authNotifierProvider)`
   - `BlocBuilder<ThemeCubit, AppTheme>` → `ref.watch(themeNotifierProvider)`
   - `BlocBuilder<LocaleCubit, Locale>` → `ref.watch(localeNotifierProvider)`
   - `context.read<ThemeCubit>().setTheme(...)` → `ref.read(themeNotifierProvider.notifier).setTheme(...)`
   - `context.read<LocaleCubit>().setLocale(...)` → `ref.read(localeNotifierProvider.notifier).setLocale(...)`
   - `context.read<AuthBloc>().add(SignOutRequested())` → `ref.read(authNotifierProvider.notifier).signOut()`

2. [ ] **Actualizar `test/features/settings/presentation/pages/settings_page_test.dart`**
   - Cambiar mocks de BLoC a `ProviderContainer` overrides

3. [ ] **Verificar que settings compila y tests pasan**

---

## Phase 14: Limpieza final y verificación [ ]

### Descripción
Eliminar todo rastro de BLoC/GetIt, verificar que no quedan imports huérfanos,
y asegurar que todo compila y los tests pasan.

### Sub-tareas

1. [ ] **Eliminar directorios `bloc/` residuales**
   - Verificar que no queda ningún directorio `bloc/` en `lib_riverpod/`
   - `find lib_riverpod -name "*_bloc*" -o -name "*_event*" -o -name "*_state.dart" | grep bloc`

2. [ ] **Eliminar archivos de GetIt/Injectable**
   - Confirmar eliminación de `lib_riverpod/core/di/injection.dart`
   - Confirmar eliminación de `lib_riverpod/core/di/injection.config.dart`
   - Eliminar directorio `lib_riverpod/core/di/` si queda vacío

3. [ ] **Buscar y eliminar imports huérfanos**
   - Buscar en todo `lib_riverpod/`: `import.*flutter_bloc`
   - Buscar en todo `lib_riverpod/`: `import.*get_it`
   - Buscar en todo `lib_riverpod/`: `import.*injectable`
   - Buscar en todo `lib_riverpod/`: `import.*bloc`
   - Ninguno debe existir

4. [ ] **Buscar y reemplazar patrones residuales**
   - Buscar: `context.read<` → no debe existir (reemplazado por `ref.read`)
   - Buscar: `context.watch<` → no debe existir (reemplazado por `ref.watch`)
   - Buscar: `BlocProvider` → no debe existir
   - Buscar: `BlocBuilder` → no debe existir
   - Buscar: `BlocListener` → no debe existir
   - Buscar: `BlocConsumer` → no debe existir
   - Buscar: `getIt` → no debe existir

5. [ ] **Verificar que `pubspec.yaml` no tiene dependencias de BLoC**
   - Confirmar eliminación de: `flutter_bloc`, `bloc`, `get_it`, `injectable`, `bloc_test`, `injectable_generator`
   - Confirmar presencia de: `flutter_riverpod`, `riverpod_annotation`
   - `equatable` se puede mantener (útil para entities)
   - `dartz` se mantiene (Either pattern no cambia)

6. [ ] **Ejecutar `flutter analyze` en `lib_riverpod/`**
   - Cero errores
   - Cero warnings relacionados a BLoC

7. [ ] **Ejecutar todos los tests**
   - `flutter test` debe pasar al 100%
   - Verificar que los tests migrados cubren los mismos escenarios que los originales

8. [ ] **Verificar compilación completa**
   - `flutter build apk --debug` (o `flutter run` en simulador)
   - La app debe funcionar idéntica a la versión BLoC

---

## Resumen de archivos por fase

### Archivos NUEVOS a crear

| Archivo | Phase |
|---------|-------|
| `lib_riverpod/core/providers/firebase_providers.dart` | 2 |
| `lib_riverpod/core/providers/service_providers.dart` | 2 |
| `lib_riverpod/core/providers/data_source_providers.dart` | 2 |
| `lib_riverpod/core/providers/repository_providers.dart` | 2 |
| `lib_riverpod/core/providers/usecase_providers.dart` | 2 |
| `lib_riverpod/core/providers/user_providers.dart` | 7 |
| `lib_riverpod/features/auth/presentation/notifiers/auth_state.dart` | 4 |
| `lib_riverpod/features/auth/presentation/notifiers/auth_notifier.dart` | 4 |
| `lib_riverpod/features/tasks/presentation/notifiers/tasks_state.dart` | 5 |
| `lib_riverpod/features/tasks/presentation/notifiers/tasks_notifier.dart` | 5 |
| `lib_riverpod/features/team_tasks/presentation/notifiers/team_state.dart` | 6 |
| `lib_riverpod/features/team_tasks/presentation/notifiers/team_notifier.dart` | 6 |
| `lib_riverpod/features/team_tasks/presentation/notifiers/team_tasks_state.dart` | 7 |
| `lib_riverpod/features/team_tasks/presentation/notifiers/team_tasks_notifier.dart` | 7 |

### Archivos a MODIFICAR (migrar)

| Archivo | Phase |
|---------|-------|
| `lib_riverpod/core/theme/theme_cubit.dart` → `theme_notifier.dart` | 3 |
| `lib_riverpod/core/locale/locale_cubit.dart` → `locale_notifier.dart` | 3 |
| `lib_riverpod/main.dart` | 8 |
| `lib_riverpod/app.dart` | 8 |
| `lib_riverpod/core/router/app_router.dart` | 9 |
| `lib_riverpod/features/auth/presentation/pages/login_page.dart` | 10 |
| `lib_riverpod/features/auth/presentation/widgets/email_sign_in_form.dart` | 10 |
| `lib_riverpod/features/auth/presentation/widgets/google_sign_in_button.dart` | 10 |
| `lib_riverpod/features/tasks/presentation/pages/home_page.dart` | 11 |
| `lib_riverpod/features/tasks/presentation/pages/main_scaffold.dart` | 11 |
| `lib_riverpod/features/tasks/presentation/widgets/add_task_bottom_sheet.dart` | 11 |
| `lib_riverpod/features/team_tasks/presentation/pages/team_tasks_page.dart` | 12 |
| `lib_riverpod/features/team_tasks/presentation/pages/create_team_page.dart` | 12 |
| `lib_riverpod/features/team_tasks/presentation/pages/join_team_page.dart` | 12 |
| `lib_riverpod/features/team_tasks/presentation/widgets/add_team_task_bottom_sheet.dart` | 12 |
| `lib_riverpod/features/settings/presentation/pages/settings_page.dart` | 13 |

### Archivos a ELIMINAR

| Archivo/Directorio | Phase |
|---------------------|-------|
| `lib_riverpod/core/di/injection.dart` | 2 |
| `lib_riverpod/core/di/injection.config.dart` | 2 |
| `lib_riverpod/features/auth/presentation/bloc/auth_bloc.dart` | 4 |
| `lib_riverpod/features/auth/presentation/bloc/auth_event.dart` | 4 |
| `lib_riverpod/features/auth/presentation/bloc/auth_state.dart` | 4 |
| `lib_riverpod/features/tasks/presentation/bloc/tasks_bloc.dart` | 5 |
| `lib_riverpod/features/tasks/presentation/bloc/tasks_event.dart` | 5 |
| `lib_riverpod/features/tasks/presentation/bloc/tasks_state.dart` | 5 |
| `lib_riverpod/features/team_tasks/presentation/bloc/team_bloc.dart` | 6 |
| `lib_riverpod/features/team_tasks/presentation/bloc/team_event.dart` | 6 |
| `lib_riverpod/features/team_tasks/presentation/bloc/team_state.dart` | 6 |
| `lib_riverpod/features/team_tasks/presentation/bloc/team_tasks_bloc.dart` | 7 |
| `lib_riverpod/features/team_tasks/presentation/bloc/team_tasks_event.dart` | 7 |
| `lib_riverpod/features/team_tasks/presentation/bloc/team_tasks_state.dart` | 7 |

### Tests NUEVOS a crear

| Test | Phase |
|------|-------|
| `test/core/providers/provider_initialization_test.dart` | 2 |
| `test/core/theme/theme_notifier_test.dart` | 3 |
| `test/core/locale/locale_notifier_test.dart` | 3 |
| `test/features/auth/presentation/notifiers/auth_notifier_test.dart` | 4 |
| `test/features/tasks/presentation/notifiers/tasks_notifier_test.dart` | 5 |
| `test/features/team_tasks/presentation/notifiers/team_notifier_test.dart` | 6 |
| `test/features/team_tasks/presentation/notifiers/team_tasks_notifier_test.dart` | 7 |

### Tests a MODIFICAR

| Test | Phase |
|------|-------|
| `test/app_test.dart` | 8 |
| `test/features/settings/presentation/pages/settings_page_test.dart` | 13 |

### Tests a ELIMINAR (reemplazados por versiones Riverpod)

| Test | Phase |
|------|-------|
| `test/features/auth/presentation/bloc/auth_bloc_test.dart` | 4 |
| `test/features/tasks/presentation/bloc/tasks_bloc_test.dart` | 5 |
| `test/features/team_tasks/presentation/bloc/team_bloc_test.dart` | 6 |
| `test/features/team_tasks/presentation/bloc/team_tasks_bloc_test.dart` | 7 |

---

## Notas importantes

### Lo que NO cambia
- **Domain layer completa:** Entities, Repository contracts, Use Cases — todo se mantiene idéntico
- **Data layer completa:** Models, Data Sources, Repository Implementations — todo se mantiene idéntico
- **Core utilities:** `core/error/`, `core/usecases/usecase.dart`, `core/utils/`, `core/notifications/` — sin cambios
- **l10n:** Internacionalización sin cambios
- **Lógica de negocio:** La categorización de tareas, el flujo de auth, la gestión de team — misma lógica, diferente contenedor de estado

### Ventajas post-migración
1. **Sin service locator externo** — Riverpod es DI + state management en uno
2. **Compile-time safety** — Riverpod detecta errores en tiempo de compilación que BLoC no detecta
3. **Sin `BuildContext` para acceder a estado** — `ref.read`/`ref.watch` no dependen del widget tree
4. **Testing más simple** — `ProviderContainer` con overrides vs. mocks de BLoC + dependency injection
5. **Menos boilerplate** — No más event classes separadas; los métodos del Notifier reemplazan eventos
6. **Auto-dispose** — `ref.onDispose` maneja limpieza de streams automáticamente
7. **Navegación simplificada** — No necesita `BlocProvider.value` al navegar entre pantallas
