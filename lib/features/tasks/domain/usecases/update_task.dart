import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/repositories/task_repository.dart';

class UpdateTask extends UseCase<TaskEntity, TaskEntity> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(TaskEntity params) {
    return repository.updateTask(params);
  }
}
