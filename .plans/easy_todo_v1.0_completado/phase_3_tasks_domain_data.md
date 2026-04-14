# Fase 3 — Tareas: Domain & Data

## Objetivo

Definir el modelo de tarea, los use cases CRUD y el repositorio Firestore. Toda la capa de datos se testa con `fake_cloud_firestore`.

## TaskEntity

```dart
// Campos:
// id          String
// userId      String
// title       String
// description String (puede ser vacío)
// dueDate     DateTime? (nullable)
// isCompleted bool
// createdAt   DateTime
// priority    TaskPriority (low, medium, high)
// notificationId int? (para notificaciones locales)
```

## Colección Firestore

```
Firestore
└── users/{userId}/tasks/{taskId}
      title: String
      description: String
      dueDate: Timestamp?
      isCompleted: bool
      createdAt: Timestamp
      priority: String ('low'|'medium'|'high')
      notificationId: int?
```

## Estructura de archivos

```
lib/features/tasks/
├── domain/
│   ├── entities/
│   │   ├── task_entity.dart
│   │   └── task_priority.dart
│   ├── repositories/task_repository.dart
│   └── usecases/
│       ├── get_tasks.dart
│       ├── create_task.dart
│       ├── update_task.dart
│       ├── delete_task.dart
│       └── complete_task.dart
├── data/
│   ├── datasources/task_remote_data_source.dart
│   ├── models/task_model.dart
│   └── repositories/task_repository_impl.dart

test/features/tasks/
├── domain/
│   ├── entities/task_entity_test.dart
│   └── usecases/
│       ├── get_tasks_test.dart
│       ├── create_task_test.dart
│       ├── update_task_test.dart
│       ├── delete_task_test.dart
│       └── complete_task_test.dart
├── data/
│   ├── datasources/task_remote_data_source_test.dart
│   └── repositories/task_repository_impl_test.dart
```

## Domain Layer

### `lib/features/tasks/domain/entities/task_priority.dart`
```dart
enum TaskPriority { low, medium, high }
```

### `lib/features/tasks/domain/entities/task_entity.dart`
```dart
import 'package:equatable/equatable.dart';
import 'task_priority.dart';

class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final TaskPriority priority;
  final int? notificationId;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.priority = TaskPriority.medium,
    this.notificationId,
  });

  TaskEntity copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    int? notificationId,
  }) {
    return TaskEntity(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      priority: priority ?? this.priority,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, title, description, dueDate,
    isCompleted, createdAt, priority, notificationId,
  ];
}
```

### `lib/features/tasks/domain/repositories/task_repository.dart`
```dart
abstract class TaskRepository {
  Stream<Either<Failure, List<TaskEntity>>> getTasks(String userId);
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId, String userId);
  Future<Either<Failure, TaskEntity>> completeTask(String taskId, String userId);
}
```

### Use Cases

```dart
// get_tasks.dart
class GetTasksParams extends Equatable {
  final String userId;
  const GetTasksParams({required this.userId});
  @override List<Object?> get props => [userId];
}

class GetTasks extends StreamUseCase<List<TaskEntity>, GetTasksParams> {
  final TaskRepository repository;
  GetTasks(this.repository);

  @override
  Stream<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) {
    return repository.getTasks(params.userId);
  }
}

// create_task.dart
class CreateTask extends UseCase<TaskEntity, CreateTaskParams> { ... }

// update_task.dart
class UpdateTask extends UseCase<TaskEntity, UpdateTaskParams> { ... }

// delete_task.dart
class DeleteTaskParams extends Equatable {
  final String taskId;
  final String userId;
  ...
}
class DeleteTask extends UseCase<void, DeleteTaskParams> { ... }

// complete_task.dart (igual que DeleteTask pero para toggle completed)
```

## Data Layer

### `lib/features/tasks/data/models/task_model.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.dueDate,
    super.isCompleted,
    required super.createdAt,
    super.priority,
    super.notificationId,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (data['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      notificationId: data['notificationId'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority.name,
      'notificationId': notificationId,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
```

### `lib/features/tasks/data/datasources/task_remote_data_source.dart`
```dart
abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasks(String userId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId, String userId);
  Future<TaskModel> completeTask(String taskId, String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  @override
  Stream<List<TaskModel>> getTasks(String userId) {
    return _tasksCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // create, update, delete, complete implementados aquí
}
```

## Tests

### `test/features/tasks/data/datasources/task_remote_data_source_test.dart`
```dart
// Usa FakeFirebaseFirestore para tests sin Firebase real
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late TaskRemoteDataSourceImpl dataSource;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = TaskRemoteDataSourceImpl(firestore: fakeFirestore);
  });

  group('getTasks', () {
    test('should return stream of tasks for userId', () async {
      // Arrange: insertar tarea en fakeFirestore
      await fakeFirestore
          .collection('users')
          .doc('user1')
          .collection('tasks')
          .add({
        'userId': 'user1',
        'title': 'Test Task',
        'description': '',
        'isCompleted': false,
        'createdAt': Timestamp.now(),
        'priority': 'medium',
      });

      // Act
      final stream = dataSource.getTasks('user1');

      // Assert
      expect(stream, emits(isA<List<TaskModel>>()));
    });
  });

  group('createTask', () {
    test('should add task to Firestore and return it with id', () async {
      final task = TaskModel(
        id: '',
        userId: 'user1',
        title: 'Nueva tarea',
        createdAt: DateTime.now(),
      );

      final result = await dataSource.createTask(task);

      expect(result.id, isNotEmpty);
      expect(result.title, 'Nueva tarea');
    });
  });
}
```

## Comandos

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/tasks/
```

## Verificación

- [ ] Todos los tests de domain pasan
- [ ] Todos los tests de data pasan con FakeFirestore
- [ ] `task_model.g.dart` generado correctamente
- [ ] CRUD de tareas funciona en Firestore Emulator (opcional)
