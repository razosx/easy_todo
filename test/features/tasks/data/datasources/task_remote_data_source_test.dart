import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:easy_todo/features/tasks/data/models/task_model.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_priority.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TaskRemoteDataSourceImpl dataSource;
  late FakeFirebaseFirestore fakeFirestore;

  final tCreatedAt = DateTime(2024, 1, 15, 10, 0);
  final tTask = TaskModel(
    id: '',
    userId: 'user-1',
    title: 'Test Task',
    description: 'Test description',
    createdAt: tCreatedAt,
    priority: TaskPriority.medium,
  );

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = TaskRemoteDataSourceImpl(firestore: fakeFirestore);
  });

  group('getTasks', () {
    test('should return stream of tasks for userId', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('tasks')
          .add({
        'userId': 'user-1',
        'title': 'Existing Task',
        'description': '',
        'isCompleted': false,
        'createdAt': Timestamp.fromDate(tCreatedAt),
        'priority': 'low',
      });

      final stream = dataSource.getTasks('user-1');
      final tasks = await stream.first;

      expect(tasks, isA<List<TaskModel>>());
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Existing Task');
      expect(tasks.first.userId, 'user-1');
    });

    test('should return empty list when no tasks exist', () async {
      final stream = dataSource.getTasks('user-1');
      final tasks = await stream.first;

      expect(tasks, isEmpty);
    });
  });

  group('createTask', () {
    test('should add task to Firestore and return task with generated id', () async {
      final result = await dataSource.createTask(tTask);

      expect(result.id, isNotEmpty);
      expect(result.title, 'Test Task');
      expect(result.userId, 'user-1');
      expect(result.description, 'Test description');
    });

    test('should persist task in Firestore', () async {
      await dataSource.createTask(tTask);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('tasks')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['title'], 'Test Task');
    });
  });

  group('updateTask', () {
    test('should update existing task in Firestore', () async {
      final created = await dataSource.createTask(tTask);
      final updatedTask = TaskModel(
        id: created.id,
        userId: 'user-1',
        title: 'Updated Title',
        createdAt: tCreatedAt,
      );

      final result = await dataSource.updateTask(updatedTask);

      expect(result.title, 'Updated Title');
      expect(result.id, created.id);
    });
  });

  group('deleteTask', () {
    test('should remove task from Firestore', () async {
      final created = await dataSource.createTask(tTask);

      await dataSource.deleteTask(created.id, 'user-1');

      final doc = await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('tasks')
          .doc(created.id)
          .get();

      expect(doc.exists, isFalse);
    });
  });

  group('completeTask', () {
    test('should mark task as completed in Firestore', () async {
      final created = await dataSource.createTask(tTask);

      final result = await dataSource.completeTask(created.id, 'user-1');

      expect(result.isCompleted, isTrue);
    });
  });
}
