import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';

class GetTasks extends StreamUseCase<List<TaskEntity>, GetTasksParams> {
  final TaskRepository repository;

  GetTasks(this.repository);

  @override
  Stream<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) {
    return repository.getTasks(params.userId);
  }
}

class GetTasksParams extends Equatable {
  final String userId;

  const GetTasksParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
