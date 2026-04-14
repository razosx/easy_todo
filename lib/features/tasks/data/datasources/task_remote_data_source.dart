import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/features/tasks/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasks(String userId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId, String userId);
  Future<TaskModel> completeTask(String taskId, String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  @override
  Stream<List<TaskModel>> getTasks(String userId) {
    return _tasksCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final data = task.toFirestore();
      final docRef = await _tasksCollection(task.userId).add(data);
      final doc = await docRef.get();
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      await _tasksCollection(task.userId)
          .doc(task.id)
          .update(task.toFirestore());
      final doc = await _tasksCollection(task.userId).doc(task.id).get();
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TaskModel> completeTask(String taskId, String userId) async {
    try {
      await _tasksCollection(userId)
          .doc(taskId)
          .update({'isCompleted': true});
      final doc = await _tasksCollection(userId).doc(taskId).get();
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
