import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';

class CompleteTask extends UseCase<TaskEntity, CompleteTaskParams> {
  final TaskRepository repository;

  CompleteTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(CompleteTaskParams params) {
    return repository.completeTask(params.taskId, params.userId);
  }
}

class CompleteTaskParams extends Equatable {
  final String taskId;
  final String userId;

  const CompleteTaskParams({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}
