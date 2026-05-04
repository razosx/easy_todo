import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Stream<Either<Failure, List<TaskEntity>>> getTasks(String userId);
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId, String userId);
  Future<Either<Failure, TaskEntity>> completeTask(
    String taskId,
    String userId,
  );
}
