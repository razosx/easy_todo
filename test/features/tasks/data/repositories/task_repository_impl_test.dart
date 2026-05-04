import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:easy_todo/features/tasks/data/models/task_model.dart';
import 'package:easy_todo/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRemoteDataSource extends Mock implements TaskRemoteDataSource {}

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskRemoteDataSource mockDataSource;

  final tCreatedAt = DateTime(2024, 1, 15);
  final tTaskModel = TaskModel(
    id: 'task-1',
    userId: 'user-1',
    title: 'Test Task',
    createdAt: tCreatedAt,
  );
  final tTaskEntity = TaskEntity(
    id: 'task-1',
    userId: 'user-1',
    title: 'Test Task',
    createdAt: tCreatedAt,
  );

  setUp(() {
    mockDataSource = MockTaskRemoteDataSource();
    repository = TaskRepositoryImpl(remoteDataSource: mockDataSource);
    registerFallbackValue(tTaskModel);
  });

  group('getTasks', () {
    test('should return stream of tasks when data source succeeds', () async {
      when(
        () => mockDataSource.getTasks(any()),
      ).thenAnswer((_) => Stream.value([tTaskModel]));

      final result = await repository.getTasks('user-1').first;

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (tasks) {
        expect(tasks.length, 1);
        expect(tasks.first.title, 'Test Task');
      });
    });
  });

  group('createTask', () {
    test('should return TaskEntity when creation succeeds', () async {
      when(
        () => mockDataSource.createTask(any()),
      ).thenAnswer((_) async => tTaskModel);

      final result = await repository.createTask(tTaskEntity);

      expect(result, Right<Failure, TaskEntity>(tTaskModel));
    });

    test(
      'should return ServerFailure when ServerException is thrown',
      () async {
        when(
          () => mockDataSource.createTask(any()),
        ).thenThrow(const ServerException(message: 'Create error'));

        final result = await repository.createTask(tTaskEntity);

        expect(result, const Left(ServerFailure(message: 'Create error')));
      },
    );
  });

  group('deleteTask', () {
    test('should return void when deletion succeeds', () async {
      when(
        () => mockDataSource.deleteTask(any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.deleteTask('task-1', 'user-1');

      expect(result, const Right(null));
    });

    test(
      'should return ServerFailure when ServerException is thrown',
      () async {
        when(
          () => mockDataSource.deleteTask(any(), any()),
        ).thenThrow(const ServerException(message: 'Delete error'));

        final result = await repository.deleteTask('task-1', 'user-1');

        expect(result, const Left(ServerFailure(message: 'Delete error')));
      },
    );
  });

  group('completeTask', () {
    test('should return completed TaskEntity when succeeds', () async {
      final completedModel = TaskModel(
        id: 'task-1',
        userId: 'user-1',
        title: 'Test Task',
        isCompleted: true,
        createdAt: tCreatedAt,
      );
      when(
        () => mockDataSource.completeTask(any(), any()),
      ).thenAnswer((_) async => completedModel);

      final result = await repository.completeTask('task-1', 'user-1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (task) => expect(task.isCompleted, isTrue),
      );
    });
  });
}
