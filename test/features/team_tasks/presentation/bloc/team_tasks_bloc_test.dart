import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_task_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/assign_task_to_member.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/complete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/create_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/delete_team_task.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team_tasks.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_bloc.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_event.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_tasks_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTeamTasks extends Mock implements GetTeamTasks {}

class MockCreateTeamTask extends Mock implements CreateTeamTask {}

class MockAssignTaskToMember extends Mock implements AssignTaskToMember {}

class MockCompleteTeamTask extends Mock implements CompleteTeamTask {}

class MockDeleteTeamTask extends Mock implements DeleteTeamTask {}

void main() {
  late TeamTasksBloc teamTasksBloc;
  late MockGetTeamTasks mockGetTeamTasks;
  late MockCreateTeamTask mockCreateTeamTask;
  late MockAssignTaskToMember mockAssignTaskToMember;
  late MockCompleteTeamTask mockCompleteTeamTask;
  late MockDeleteTeamTask mockDeleteTeamTask;

  final now = DateTime.now();

  final tMyTask = TeamTaskEntity(
    id: 'task-1',
    teamId: 'team-1',
    title: 'My Task',
    createdBy: 'user-1',
    assignedTo: 'user-1',
    createdAt: now,
  );
  final tUnassignedTask = TeamTaskEntity(
    id: 'task-2',
    teamId: 'team-1',
    title: 'Unassigned Task',
    createdBy: 'user-1',
    createdAt: now,
  );
  final tOtherTask = TeamTaskEntity(
    id: 'task-3',
    teamId: 'team-1',
    title: 'Other Task',
    createdBy: 'user-2',
    assignedTo: 'user-2',
    createdAt: now,
  );
  final tCompletedTask = TeamTaskEntity(
    id: 'task-4',
    teamId: 'team-1',
    title: 'Done Task',
    createdBy: 'user-1',
    isCompleted: true,
    createdAt: now,
  );

  setUpAll(() {
    registerFallbackValue(const GetTeamTasksParams(teamId: ''));
    registerFallbackValue(TeamTaskEntity(
      id: '',
      teamId: '',
      title: '',
      createdBy: '',
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(
        const AssignTaskParams(taskId: '', teamId: '', assigneeId: null));
    registerFallbackValue(
        const CompleteTeamTaskParams(taskId: '', teamId: ''));
    registerFallbackValue(
        const DeleteTeamTaskParams(taskId: '', teamId: ''));
  });

  setUp(() {
    mockGetTeamTasks = MockGetTeamTasks();
    mockCreateTeamTask = MockCreateTeamTask();
    mockAssignTaskToMember = MockAssignTaskToMember();
    mockCompleteTeamTask = MockCompleteTeamTask();
    mockDeleteTeamTask = MockDeleteTeamTask();
    teamTasksBloc = TeamTasksBloc(
      getTeamTasks: mockGetTeamTasks,
      createTeamTask: mockCreateTeamTask,
      assignTaskToMember: mockAssignTaskToMember,
      completeTeamTask: mockCompleteTeamTask,
      deleteTeamTask: mockDeleteTeamTask,
    );
    teamTasksBloc.setCurrentUserId('user-1');
  });

  tearDown(() => teamTasksBloc.close());

  test('initial state should be TeamTasksInitial', () {
    expect(teamTasksBloc.state, isA<TeamTasksInitial>());
  });

  group('LoadTeamTasksRequested', () {
    blocTest<TeamTasksBloc, TeamTasksState>(
      'emits [TeamTasksLoading, TeamTasksLoaded] when tasks load successfully',
      build: () {
        when(() => mockGetTeamTasks(any())).thenAnswer(
          (_) => Stream.value(
            Right([tMyTask, tUnassignedTask, tOtherTask, tCompletedTask]),
          ),
        );
        return teamTasksBloc;
      },
      act: (bloc) =>
          bloc.add(const LoadTeamTasksRequested(teamId: 'team-1')),
      expect: () => [
        isA<TeamTasksLoading>(),
        isA<TeamTasksLoaded>(),
      ],
    );

    blocTest<TeamTasksBloc, TeamTasksState>(
      'groups tasks correctly into assignedToMe/unassigned/assignedToOthers/completed',
      build: () {
        when(() => mockGetTeamTasks(any())).thenAnswer(
          (_) => Stream.value(
            Right([tMyTask, tUnassignedTask, tOtherTask, tCompletedTask]),
          ),
        );
        return teamTasksBloc;
      },
      act: (bloc) =>
          bloc.add(const LoadTeamTasksRequested(teamId: 'team-1')),
      expect: () => [
        isA<TeamTasksLoading>(),
        isA<TeamTasksLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as TeamTasksLoaded;
        expect(state.assignedToMe, contains(tMyTask));
        expect(state.unassigned, contains(tUnassignedTask));
        expect(state.assignedToOthers, contains(tOtherTask));
        expect(state.completed, contains(tCompletedTask));
      },
    );

    blocTest<TeamTasksBloc, TeamTasksState>(
      'emits [TeamTasksLoading, TeamTasksError] when loading fails',
      build: () {
        when(() => mockGetTeamTasks(any())).thenAnswer(
          (_) => Stream.value(
            const Left(ServerFailure(message: 'Error')),
          ),
        );
        return teamTasksBloc;
      },
      act: (bloc) =>
          bloc.add(const LoadTeamTasksRequested(teamId: 'team-1')),
      expect: () => [
        isA<TeamTasksLoading>(),
        isA<TeamTasksError>(),
      ],
    );
  });

  group('CompleteTeamTaskRequested', () {
    blocTest<TeamTasksBloc, TeamTasksState>(
      'calls completeTeamTask use case with correct params',
      build: () {
        when(() => mockCompleteTeamTask(any()))
            .thenAnswer((_) async => Right(tCompletedTask));
        return teamTasksBloc;
      },
      act: (bloc) => bloc.add(
        const CompleteTeamTaskRequested(taskId: 'task-1', teamId: 'team-1'),
      ),
      verify: (_) {
        verify(() => mockCompleteTeamTask(
              const CompleteTeamTaskParams(taskId: 'task-1', teamId: 'team-1'),
            )).called(1);
      },
    );
  });

  group('DeleteTeamTaskRequested', () {
    blocTest<TeamTasksBloc, TeamTasksState>(
      'calls deleteTeamTask use case with correct params',
      build: () {
        when(() => mockDeleteTeamTask(any()))
            .thenAnswer((_) async => const Right(null));
        return teamTasksBloc;
      },
      act: (bloc) => bloc.add(
        const DeleteTeamTaskRequested(taskId: 'task-1', teamId: 'team-1'),
      ),
      verify: (_) {
        verify(() => mockDeleteTeamTask(
              const DeleteTeamTaskParams(taskId: 'task-1', teamId: 'team-1'),
            )).called(1);
      },
    );
  });

  group('AssignTeamTaskRequested', () {
    blocTest<TeamTasksBloc, TeamTasksState>(
      'calls assignTaskToMember use case with correct params',
      build: () {
        when(() => mockAssignTaskToMember(any()))
            .thenAnswer((_) async => Right(tMyTask));
        return teamTasksBloc;
      },
      act: (bloc) => bloc.add(
        const AssignTeamTaskRequested(
          taskId: 'task-2',
          teamId: 'team-1',
          assigneeId: 'user-1',
        ),
      ),
      verify: (_) {
        verify(() => mockAssignTaskToMember(
              const AssignTaskParams(
                  taskId: 'task-2', teamId: 'team-1', assigneeId: 'user-1'),
            )).called(1);
      },
    );
  });
}
