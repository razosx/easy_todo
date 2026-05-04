import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/features/team_tasks/data/models/team_task_model.dart';

abstract class TeamTaskRemoteDataSource {
  Stream<List<TeamTaskModel>> getTeamTasks(String teamId);
  Future<TeamTaskModel> createTeamTask(TeamTaskModel task);
  Future<TeamTaskModel> assignTask(
    String taskId,
    String teamId,
    String? assigneeId,
  );
  Future<TeamTaskModel> completeTeamTask(String taskId, String teamId);
  Future<void> deleteTeamTask(String taskId, String teamId);
}

class TeamTaskRemoteDataSourceImpl implements TeamTaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TeamTaskRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String teamId) =>
      _firestore.collection('teams').doc(teamId).collection('tasks');

  @override
  Stream<List<TeamTaskModel>> getTeamTasks(String teamId) {
    return _tasksCollection(teamId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TeamTaskModel.fromFirestore(doc, teamId))
              .toList(),
        );
  }

  @override
  Future<TeamTaskModel> createTeamTask(TeamTaskModel task) async {
    try {
      final data = task.toFirestore();
      final docRef = await _tasksCollection(task.teamId).add(data);
      final doc = await docRef.get();
      return TeamTaskModel.fromFirestore(doc, task.teamId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TeamTaskModel> assignTask(
    String taskId,
    String teamId,
    String? assigneeId,
  ) async {
    try {
      await _tasksCollection(
        teamId,
      ).doc(taskId).update({'assignedTo': assigneeId});
      final doc = await _tasksCollection(teamId).doc(taskId).get();
      return TeamTaskModel.fromFirestore(doc, teamId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TeamTaskModel> completeTeamTask(String taskId, String teamId) async {
    try {
      await _tasksCollection(teamId).doc(taskId).update({'isCompleted': true});
      final doc = await _tasksCollection(teamId).doc(taskId).get();
      return TeamTaskModel.fromFirestore(doc, teamId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTeamTask(String taskId, String teamId) async {
    try {
      await _tasksCollection(teamId).doc(taskId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
