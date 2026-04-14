import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/entities/team_member_entity.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/create_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/get_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/join_team.dart';
import 'package:easy_todo/features/team_tasks/domain/usecases/leave_team.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_bloc.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_event.dart';
import 'package:easy_todo/features/team_tasks/presentation/bloc/team_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTeam extends Mock implements GetTeam {}

class MockCreateTeam extends Mock implements CreateTeam {}

class MockJoinTeam extends Mock implements JoinTeam {}

class MockLeaveTeam extends Mock implements LeaveTeam {}

void main() {
  late TeamBloc teamBloc;
  late MockGetTeam mockGetTeam;
  late MockCreateTeam mockCreateTeam;
  late MockJoinTeam mockJoinTeam;
  late MockLeaveTeam mockLeaveTeam;

  final tMember = TeamMemberEntity(
    userId: 'user-1',
    role: 'admin',
    joinedAt: DateTime(2024, 1, 1),
  );
  final tTeam = TeamEntity(
    id: 'team-1',
    name: 'Test Team',
    createdBy: 'user-1',
    inviteCode: 'ABC123',
    members: {'user-1': tMember},
  );

  setUpAll(() {
    registerFallbackValue(const GetTeamParams(userId: ''));
    registerFallbackValue(const CreateTeamParams(name: '', userId: ''));
    registerFallbackValue(const JoinTeamParams(inviteCode: '', userId: ''));
    registerFallbackValue(const LeaveTeamParams(teamId: '', userId: ''));
  });

  setUp(() {
    mockGetTeam = MockGetTeam();
    mockCreateTeam = MockCreateTeam();
    mockJoinTeam = MockJoinTeam();
    mockLeaveTeam = MockLeaveTeam();
    teamBloc = TeamBloc(
      getTeam: mockGetTeam,
      createTeam: mockCreateTeam,
      joinTeam: mockJoinTeam,
      leaveTeam: mockLeaveTeam,
    );
  });

  tearDown(() => teamBloc.close());

  test('initial state should be TeamInitial', () {
    expect(teamBloc.state, isA<TeamInitial>());
  });

  group('LoadTeamRequested', () {
    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamLoaded] when user has a team',
      build: () {
        when(() => mockGetTeam(any())).thenAnswer(
          (_) => Stream.value(Right(tTeam)),
        );
        return teamBloc;
      },
      act: (bloc) => bloc.add(const LoadTeamRequested(userId: 'user-1')),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as TeamLoaded;
        expect(state.team.name, equals('Test Team'));
      },
    );

    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamNone] when user has no team',
      build: () {
        when(() => mockGetTeam(any())).thenAnswer(
          (_) => Stream.value(const Right(null)),
        );
        return teamBloc;
      },
      act: (bloc) => bloc.add(const LoadTeamRequested(userId: 'user-1')),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamNone>(),
      ],
    );

    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamError] when stream errors',
      build: () {
        when(() => mockGetTeam(any())).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure(message: 'Error'))),
        );
        return teamBloc;
      },
      act: (bloc) => bloc.add(const LoadTeamRequested(userId: 'user-1')),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamError>(),
      ],
    );
  });

  group('CreateTeamRequested', () {
    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamLoaded] when team is created successfully',
      build: () {
        when(() => mockCreateTeam(any()))
            .thenAnswer((_) async => Right(tTeam));
        return teamBloc;
      },
      act: (bloc) => bloc.add(
        const CreateTeamRequested(name: 'Test Team', userId: 'user-1'),
      ),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamLoaded>(),
      ],
    );

    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamError] when creation fails',
      build: () {
        when(() => mockCreateTeam(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return teamBloc;
      },
      act: (bloc) => bloc.add(
        const CreateTeamRequested(name: 'Test Team', userId: 'user-1'),
      ),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamError>(),
      ],
    );
  });

  group('JoinTeamRequested', () {
    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamLoaded] when join succeeds',
      build: () {
        when(() => mockJoinTeam(any()))
            .thenAnswer((_) async => Right(tTeam));
        return teamBloc;
      },
      act: (bloc) => bloc.add(
        const JoinTeamRequested(inviteCode: 'ABC123', userId: 'user-1'),
      ),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamLoaded>(),
      ],
    );

    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamError] when invite code is invalid',
      build: () {
        when(() => mockJoinTeam(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Código de invitación inválido')),
        );
        return teamBloc;
      },
      act: (bloc) => bloc.add(
        const JoinTeamRequested(inviteCode: 'XXXXX', userId: 'user-1'),
      ),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamError>(),
      ],
    );
  });

  group('LeaveTeamRequested', () {
    blocTest<TeamBloc, TeamState>(
      'emits [TeamLoading, TeamNone] when leave succeeds',
      build: () {
        when(() => mockLeaveTeam(any()))
            .thenAnswer((_) async => const Right(null));
        return teamBloc;
      },
      act: (bloc) => bloc.add(
        const LeaveTeamRequested(teamId: 'team-1', userId: 'user-1'),
      ),
      expect: () => [
        isA<TeamLoading>(),
        isA<TeamNone>(),
      ],
    );
  });
}
