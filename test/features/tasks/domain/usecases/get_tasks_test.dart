import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/repositories/task_repository.dart';
import 'package:easy_todo/features/tasks/domain/usecases/get_tasks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late GetTasks usecase;
  late MockTaskRepository mockRepository;

  final tTask = TaskEntity(
    id: 'task-1',
    userId: 'user-1',
    title: 'Test Task',
    createdAt: DateTime(2024, 1, 15),
  );
  const tParams = GetTasksParams(userId: 'user-1');

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = GetTasks(mockRepository);
  });

  test('should return stream of tasks from repository', () async {
    when(() => mockRepository.getTasks(any()))
        .thenAnswer((_) => Stream.value(Right([tTask])));

    final result = await usecase(tParams).first;

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (tasks) => expect(tasks, [tTask]),
    );
    verify(() => mockRepository.getTasks('user-1')).called(1);
  });

  test('should return stream with ServerFailure when repository fails', () async {
    when(() => mockRepository.getTasks(any())).thenAnswer(
        (_) => Stream.value(const Left(ServerFailure(message: 'Error'))));

    final result = await usecase(tParams).first;

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, const ServerFailure(message: 'Error')),
      (_) => fail('Expected Left'),
    );
  });

  test('should emit multiple values from stream', () async {
    final tTask2 = TaskEntity(
      id: 'task-2',
      userId: 'user-1',
      title: 'Second Task',
      createdAt: DateTime(2024, 1, 16),
    );

    when(() => mockRepository.getTasks(any())).thenAnswer(
      (_) => Stream.fromIterable([
        Right([tTask]),
        Right([tTask, tTask2]),
      ]),
    );

    final results = await usecase(tParams).toList();

    expect(results.length, 2);
    results[0].fold((_) => fail('Expected Right'), (tasks) => expect(tasks, [tTask]));
    results[1].fold((_) => fail('Expected Right'), (tasks) => expect(tasks, [tTask, tTask2]));
  });
}
