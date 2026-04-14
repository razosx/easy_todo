import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_todo/app.dart';
import 'package:easy_todo/core/notifications/local_notification_service.dart';
import 'package:easy_todo/core/notifications/push_notification_service.dart';
import 'package:easy_todo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_todo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:easy_todo/features/auth/domain/usecases/check_username_available.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_out.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:easy_todo/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:easy_todo/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:easy_todo/features/tasks/domain/usecases/complete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/create_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/delete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/get_tasks.dart';
import 'package:easy_todo/features/team_tasks/data/datasources/team_remote_data_source.dart';
import 'package:easy_todo/features/team_tasks/data/datasources/team_task_remote_data_source.dart';
import 'package:easy_todo/features/team_tasks/data/repositories/team_repository_impl.dart';
import 'package:easy_todo/features/team_tasks/data/repositories/team_task_repository_impl.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/assign_task_to_member.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/complete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/create_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/create_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/delete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team_tasks.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/join_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/leave_team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';

/// Top-level handler for FCM messages received while the app is terminated or
/// in the background. Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background messages are handled silently; foreground handling is in the service.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await initializeDateFormatting('en');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background FCM handler before any other Firebase calls.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications.
  final localNotifications = LocalNotificationServiceImpl();
  await localNotifications.initialize();

  // Initialize push notifications and request permission.
  final pushNotifications = PushNotificationServiceImpl();
  await pushNotifications.requestPermission();

  // Auth dependencies
  final authDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn.instance,
    firestore: FirebaseFirestore.instance,
  );
  final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);

  // Task dependencies
  final taskDataSource =
      TaskRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
  final taskRepository = TaskRepositoryImpl(remoteDataSource: taskDataSource);

  // Team dependencies
  final teamDataSource =
      TeamRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
  final teamRepository = TeamRepositoryImpl(remoteDataSource: teamDataSource);

  final teamTaskDataSource =
      TeamTaskRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
  final teamTaskRepository =
      TeamTaskRepositoryImpl(remoteDataSource: teamTaskDataSource);

  runApp(
    EasyTodoApp(
      localNotificationService: localNotifications,
      authRepository: authRepository,
      signInWithEmail: SignInWithEmail(authRepository),
      signUpWithEmail: SignUpWithEmail(authRepository),
      signInWithGoogle: SignInWithGoogle(authRepository),
      signOut: SignOut(authRepository),
      checkUsernameAvailable: CheckUsernameAvailable(authRepository),
      getTasks: GetTasks(taskRepository),
      createTask: CreateTask(taskRepository),
      deleteTask: DeleteTask(taskRepository),
      completeTask: CompleteTask(taskRepository),
      getTeam: GetTeam(teamRepository),
      createTeam: CreateTeam(teamRepository),
      joinTeam: JoinTeam(teamRepository),
      leaveTeam: LeaveTeam(teamRepository),
      getTeamTasks: GetTeamTasks(teamTaskRepository),
      createTeamTask: CreateTeamTask(teamTaskRepository),
      assignTaskToMember: AssignTaskToMember(teamTaskRepository),
      completeTeamTask: CompleteTeamTask(teamTaskRepository),
      deleteTeamTask: DeleteTeamTask(teamTaskRepository),
    ),
  );
}
