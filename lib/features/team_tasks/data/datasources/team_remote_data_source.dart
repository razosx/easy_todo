import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/core/error/exceptions.dart';
import 'package:easy_todo/features/team_tasks/data/models/team_model.dart';
import 'package:uuid/uuid.dart';

abstract class TeamRemoteDataSource {
  Stream<TeamModel?> getTeam(String userId);
  Future<TeamModel> createTeam(
    String name,
    String userId,
    String? username,
    String? memberName,
  );
  Future<TeamModel> joinTeam(
    String inviteCode,
    String userId,
    String? username,
    String? memberName,
  );
  Future<void> leaveTeam(String teamId, String userId);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final FirebaseFirestore _firestore;

  TeamRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Stream<TeamModel?> getTeam(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().asyncExpand((
      userDoc,
    ) {
      final teamId = userDoc.data()?['teamId'] as String?;
      if (teamId == null) return Stream.value(null);
      return _firestore
          .collection('teams')
          .doc(teamId)
          .snapshots()
          .map(
            (teamDoc) =>
                teamDoc.exists ? TeamModel.fromFirestore(teamDoc) : null,
          );
    });
  }

  @override
  Future<TeamModel> createTeam(
    String name,
    String userId,
    String? username,
    String? memberName,
  ) async {
    try {
      final inviteCode = const Uuid()
          .v4()
          .replaceAll('-', '')
          .substring(0, 6)
          .toUpperCase();
      final now = DateTime.now();
      final teamData = {
        'name': name,
        'createdBy': userId,
        'inviteCode': inviteCode,
        'members': {
          userId: {
            'role': 'admin',
            'joinedAt': Timestamp.fromDate(now),
            'username': ?username,
            'name': ?memberName,
          },
        },
      };
      final docRef = await _firestore.collection('teams').add(teamData);
      await _firestore.collection('users').doc(userId).set({
        'teamId': docRef.id,
      }, SetOptions(merge: true));
      final doc = await docRef.get();
      return TeamModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TeamModel> joinTeam(
    String inviteCode,
    String userId,
    String? username,
    String? memberName,
  ) async {
    try {
      final query = await _firestore
          .collection('teams')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw const ServerException(message: 'Código de invitación inválido');
      }
      final teamDoc = query.docs.first;
      final teamId = teamDoc.id;
      final now = DateTime.now();
      await _firestore.collection('teams').doc(teamId).update({
        'members.$userId': {
          'role': 'member',
          'joinedAt': Timestamp.fromDate(now),
          'username': ?username,
          'name': ?memberName,
        },
      });
      await _firestore.collection('users').doc(userId).set({
        'teamId': teamId,
      }, SetOptions(merge: true));
      final updatedDoc = await _firestore.collection('teams').doc(teamId).get();
      return TeamModel.fromFirestore(updatedDoc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> leaveTeam(String teamId, String userId) async {
    try {
      await _firestore.collection('teams').doc(teamId).update({
        'members.$userId': FieldValue.delete(),
      });
      await _firestore.collection('users').doc(userId).update({
        'teamId': FieldValue.delete(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
