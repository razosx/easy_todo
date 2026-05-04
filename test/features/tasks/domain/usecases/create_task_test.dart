import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/repositories/task_repository.dart';
import 'package:easy_todo/features/tasks/domain/usecases/create_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CreateTask usecase;
  late MockTaskRepository mockRepository;

  final tTask = TaskEntity(
    id: 'task-1',
    userId: 'user-1',
    title: 'New Task',
    createdAt: DateTime(2024, 1, 15),
  );

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = CreateTask(mockRepository);
    registerFallbackValue(tTask);
  });

  test('should return created TaskEntity when repository succeeds', () async {
    when(
      () => mockRepository.createTask(any()),
    ).thenAnswer((_) async => Right(tTask));

    final result = await usecase(tTask);

    expect(result, Right(tTask));
    verify(() => mockRepository.createTask(tTask)).called(1);
  });

  test('should return ServerFailure when repository fails', () async {
    when(() => mockRepository.createTask(any())).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'Create error')),
    );

    final result = await usecase(tTask);

    expect(result, const Left(ServerFailure(message: 'Create error')));
  });
}
