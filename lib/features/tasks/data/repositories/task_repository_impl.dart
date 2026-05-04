import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:easy_todo/features/tasks/data/models/task_model.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<TaskEntity>>> getTasks(String userId) {
    return remoteDataSource
        .getTasks(userId)
        .map<Either<Failure, List<TaskEntity>>>((tasks) => Right(tasks))
        .handleError((e) => Left(ServerFailure(message: e.toString())));
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final result = await remoteDataSource.createTask(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final result = await remoteDataSource.updateTask(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId, String userId) async {
    try {
      await remoteDataSource.deleteTask(taskId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> completeTask(
    String taskId,
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.completeTask(taskId, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
