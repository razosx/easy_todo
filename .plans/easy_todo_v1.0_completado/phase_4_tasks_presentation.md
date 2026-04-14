# Fase 4 — Tareas: Presentación (Home Screen)

## Objetivo

Pantalla Home con las tareas del usuario agrupadas en tres secciones: **Hoy**, **Siguientes** y **Completadas**. BottomNavigationBar principal con 3 tabs.

## Lógica de agrupación

```
Hoy        → dueDate == hoy  OR  (dueDate == null AND !isCompleted AND createdAt == hoy)
Siguientes → dueDate > hoy AND !isCompleted
Completadas → isCompleted == true
```

Implementada en `TaskDateUtils` (ya en `lib/core/utils/date_utils.dart`).

## Estructura de archivos

```
lib/features/tasks/presentation/
├── bloc/
│   ├── tasks_event.dart
│   ├── tasks_state.dart
│   └── tasks_bloc.dart
├── pages/
│   ├── home_page.dart
│   └── main_scaffold.dart
└── widgets/
    ├── task_list_section.dart
    ├── task_card.dart
    └── add_task_bottom_sheet.dart

test/features/tasks/presentation/
├── bloc/tasks_bloc_test.dart
├── widgets/task_card_test.dart
└── widgets/task_list_section_test.dart
```

## BLoC

### `tasks_event.dart`
```dart
abstract class TasksEvent extends Equatable {}

class LoadTasksRequested extends TasksEvent {
  final String userId;
  const LoadTasksRequested({required this.userId});
  @override List<Object?> get props => [userId];
}

class CreateTaskRequested extends TasksEvent {
  final TaskEntity task;
  const CreateTaskRequested({required this.task});
  @override List<Object?> get props => [task];
}

class UpdateTaskRequested extends TasksEvent {
  final TaskEntity task;
  const UpdateTaskRequested({required this.task});
  @override List<Object?> get props => [task];
}

class DeleteTaskRequested extends TasksEvent {
  final String taskId;
  final String userId;
  const DeleteTaskRequested({required this.taskId, required this.userId});
  @override List<Object?> get props => [taskId, userId];
}

class CompleteTaskRequested extends TasksEvent {
  final String taskId;
  final String userId;
  const CompleteTaskRequested({required this.taskId, required this.userId});
  @override List<Object?> get props => [taskId, userId];
}

class TasksStreamUpdated extends TasksEvent {
  final List<TaskEntity> tasks;
  const TasksStreamUpdated({required this.tasks});
  @override List<Object?> get props => [tasks];
}
```

### `tasks_state.dart`
```dart
abstract class TasksState extends Equatable {}

class TasksInitial extends TasksState { ... }

class TasksLoading extends TasksState { ... }

class TasksLoaded extends TasksState {
  final List<TaskEntity> todayTasks;
  final List<TaskEntity> upcomingTasks;
  final List<TaskEntity> completedTasks;

  const TasksLoaded({
    required this.todayTasks,
    required this.upcomingTasks,
    required this.completedTasks,
  });

  @override
  List<Object?> get props => [todayTasks, upcomingTasks, completedTasks];
}

class TasksError extends TasksState {
  final String message;
  const TasksError({required this.message});
  @override List<Object?> get props => [message];
}
```

### `tasks_bloc.dart`
```dart
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks _getTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final CompleteTask _completeTask;
  StreamSubscription? _tasksSubscription;

  TasksBloc({...}) : super(TasksInitial()) {
    on<LoadTasksRequested>(_onLoad);
    on<TasksStreamUpdated>(_onStreamUpdated);
    on<CreateTaskRequested>(_onCreate);
    on<UpdateTaskRequested>(_onUpdate);
    on<DeleteTaskRequested>(_onDelete);
    on<CompleteTaskRequested>(_onComplete);
  }

  void _onLoad(LoadTasksRequested event, Emitter<TasksState> emit) {
    emit(TasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = _getTasks(GetTasksParams(userId: event.userId))
        .listen((result) {
      result.fold(
        (failure) => add(TasksStreamUpdated(tasks: [])), // or error event
        (tasks) => add(TasksStreamUpdated(tasks: tasks)),
      );
    });
  }

  void _onStreamUpdated(TasksStreamUpdated event, Emitter<TasksState> emit) {
    final now = DateTime.now();
    final today = event.tasks.where((t) =>
      !t.isCompleted && (
        (t.dueDate != null && TaskDateUtils.isToday(t.dueDate!)) ||
        (t.dueDate == null && TaskDateUtils.isToday(t.createdAt))
      )
    ).toList();

    final upcoming = event.tasks.where((t) =>
      !t.isCompleted && t.dueDate != null && TaskDateUtils.isFuture(t.dueDate!)
    ).toList();

    final completed = event.tasks.where((t) => t.isCompleted).toList();

    emit(TasksLoaded(
      todayTasks: today,
      upcomingTasks: upcoming,
      completedTasks: completed,
    ));
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
```

## Widgets

### `task_list_section.dart`
```dart
// Sección colapsable con título, contador y lista de tarjetas
class TaskListSection extends StatelessWidget {
  final String title;
  final List<TaskEntity> tasks;
  final bool initiallyExpanded;
  final Widget Function(TaskEntity) itemBuilder;
  ...
}
```

### `task_card.dart`
```dart
// Tarjeta de tarea con:
// - Checkbox para marcar como completada
// - Título y descripción
// - Badge de prioridad (color según TaskPriority)
// - dueDate formateada (intl)
// - Swipe derecha: completar
// - Swipe izquierda: eliminar (con confirmación)
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  ...
}
```

### `add_task_bottom_sheet.dart`
```dart
// Bottom sheet modal con:
// - TextField para título (required)
// - TextField para descripción (optional)
// - DatePicker para dueDate (optional)
// - DropdownButton para prioridad
// - Botón "Agregar tarea"
class AddTaskBottomSheet extends StatefulWidget { ... }
```

### `main_scaffold.dart`
```dart
class MainScaffold extends StatefulWidget { ... }

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TeamTasksPlaceholder(), // Fase 2 del proyecto
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Equipo'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
```

## Tests clave

### `test/features/tasks/presentation/bloc/tasks_bloc_test.dart`
```dart
blocTest<TasksBloc, TasksState>(
  'emits [TasksLoading, TasksLoaded] when load succeeds',
  build: () {
    when(() => mockGetTasks(any())).thenAnswer((_) =>
        Stream.value(Right([tTask])));
    return TasksBloc(getTasks: mockGetTasks, ...);
  },
  act: (bloc) => bloc.add(LoadTasksRequested(userId: 'user1')),
  expect: () => [
    TasksLoading(),
    isA<TasksLoaded>(),
  ],
);

blocTest<TasksBloc, TasksState>(
  'groups tasks correctly: today/upcoming/completed',
  ...
);
```

### `test/features/tasks/presentation/widgets/task_card_test.dart`
```dart
testWidgets('shows task title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TaskCard(
        task: tTask,
        onComplete: () {},
        onDelete: () {},
        onTap: () {},
      ),
    ),
  );
  expect(find.text(tTask.title), findsOneWidget);
});

testWidgets('calls onComplete when checkbox tapped', (tester) async { ... });
```

## Comandos

```bash
flutter test test/features/tasks/presentation/
flutter run  # verificar Home Screen en emulador
```

## Verificación

- [ ] TasksBloc tests pasan (grouping correcto)
- [ ] TaskCard muestra título, prioridad y fecha
- [ ] Swipe a la derecha completa la tarea
- [ ] Swipe a la izquierda elimina (con diálogo)
- [ ] FAB abre AddTaskBottomSheet y crea tarea
- [ ] BottomNavigationBar cambia entre tabs
- [ ] Tareas se agrupan correctamente en Hoy/Siguientes/Completadas
