import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/tasks/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteTask extends UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) {
    return repository.deleteTask(params.taskId, params.userId);
  }
}

class DeleteTaskParams extends Equatable {
  final String taskId;
  final String userId;

  const DeleteTaskParams({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}
