import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/notifications/local_notification_service.dart';
import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:easy_todo/features/tasks/domain/usecases/complete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/create_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/delete_task.dart';
import 'package:easy_todo/features/tasks/domain/usecases/get_tasks.dart';
import 'package:easy_todo/features/tasks/domain/usecases/update_task.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:easy_todo/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTasks extends Mock implements GetTasks {}

class MockCreateTask extends Mock implements CreateTask {}

class MockUpdateTask extends Mock implements UpdateTask {}

class MockDeleteTask extends Mock implements DeleteTask {}

class MockCompleteTask extends Mock implements CompleteTask {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

void main() {
  late TasksBloc tasksBloc;
  late MockLocalNotificationService mockNotificationService;
  late MockGetTasks mockGetTasks;
  late MockCreateTask mockCreateTask;
  late MockDeleteTask mockDeleteTask;
  late MockCompleteTask mockCompleteTask;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 10, 0);
  final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);

  final tTodayTask = TaskEntity(
    id: 'today-1',
    userId: 'user-1',
    title: 'Today Task',
    createdAt: today,
    dueDate: today,
  );
  final tUpcomingTask = TaskEntity(
    id: 'upcoming-1',
    userId: 'user-1',
    title: 'Upcoming Task',
    createdAt: today,
    dueDate: tomorrow,
  );
  final tCompletedTask = TaskEntity(
    id: 'done-1',
    userId: 'user-1',
    title: 'Done Task',
    createdAt: today,
    isCompleted: true,
  );

  setUpAll(() {
    registerFallbackValue(const GetTasksParams(userId: ''));
    registerFallbackValue(tTodayTask);
    registerFallbackValue(const DeleteTaskParams(taskId: '', userId: ''));
    registerFallbackValue(const CompleteTaskParams(taskId: '', userId: ''));
  });

  setUp(() {
    mockNotificationService = MockLocalNotificationService();
    mockGetTasks = MockGetTasks();
    mockCreateTask = MockCreateTask();
    mockDeleteTask = MockDeleteTask();
    mockCompleteTask = MockCompleteTask();
    tasksBloc = TasksBloc(
      notificationService: mockNotificationService,
      getTasks: mockGetTasks,
      createTask: mockCreateTask,
      deleteTask: mockDeleteTask,
      completeTask: mockCompleteTask,
    );
  });

  tearDown(() => tasksBloc.close());

  test('initial state should be TasksInitial', () {
    expect(tasksBloc.state, isA<TasksInitial>());
  });

  group('LoadTasksRequested', () {
    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoading, TasksLoaded] when tasks load successfully',
      build: () {
        when(() => mockGetTasks(any())).thenAnswer(
          (_) =>
              Stream.value(Right([tTodayTask, tUpcomingTask, tCompletedTask])),
        );
        return tasksBloc;
      },
      act: (bloc) => bloc.add(const LoadTasksRequested(userId: 'user-1')),
      expect: () => [isA<TasksLoading>(), isA<TasksLoaded>()],
    );

    blocTest<TasksBloc, TasksState>(
      'groups tasks correctly into today/upcoming/completed',
      build: () {
        when(() => mockGetTasks(any())).thenAnswer(
          (_) =>
              Stream.value(Right([tTodayTask, tUpcomingTask, tCompletedTask])),
        );
        return tasksBloc;
      },
      act: (bloc) => bloc.add(const LoadTasksRequested(userId: 'user-1')),
      expect: () => [TasksLoading(), isA<TasksLoaded>()],
      verify: (bloc) {
        final state = bloc.state as TasksLoaded;
        expect(state.todayTasks, contains(tTodayTask));
        expect(state.upcomingTasks, contains(tUpcomingTask));
        expect(state.completedTasks, contains(tCompletedTask));
      },
    );

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoading, TasksError] when loading fails',
      build: () {
        when(() => mockGetTasks(any())).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure(message: 'Error'))),
        );
        return tasksBloc;
      },
      act: (bloc) => bloc.add(const LoadTasksRequested(userId: 'user-1')),
      expect: () => [isA<TasksLoading>(), isA<TasksError>()],
    );
  });

  group('DeleteTaskRequested', () {
    blocTest<TasksBloc, TasksState>(
      'calls deleteTask use case with correct params',
      build: () {
        when(
          () => mockDeleteTask(any()),
        ).thenAnswer((_) async => const Right(null));
        return tasksBloc;
      },
      act: (bloc) => bloc.add(
        const DeleteTaskRequested(taskId: 'task-1', userId: 'user-1'),
      ),
      verify: (_) {
        verify(
          () => mockDeleteTask(
            const DeleteTaskParams(taskId: 'task-1', userId: 'user-1'),
          ),
        ).called(1);
      },
    );
  });

  group('CompleteTaskRequested', () {
    blocTest<TasksBloc, TasksState>(
      'calls completeTask use case with correct params',
      build: () {
        when(
          () => mockCompleteTask(any()),
        ).thenAnswer((_) async => Right(tCompletedTask));
        return tasksBloc;
      },
      act: (bloc) => bloc.add(
        const CompleteTaskRequested(taskId: 'done-1', userId: 'user-1'),
      ),
      verify: (_) {
        verify(
          () => mockCompleteTask(
            const CompleteTaskParams(taskId: 'done-1', userId: 'user-1'),
          ),
        ).called(1);
      },
    );
  });

  group('CreateTaskRequested — notifications', () {
    final tTaskWithNotification = TaskEntity(
      id: '',
      userId: 'user-1',
      title: 'Task with notification',
      createdAt: today,
      dueDate: today,
      notificationId: 12345,
    );
    final tTaskWithoutNotification = TaskEntity(
      id: '',
      userId: 'user-1',
      title: 'Task without notification',
      createdAt: today,
    );

    blocTest<TasksBloc, TasksState>(
      'schedules notification when task has notificationId',
      build: () {
        when(
          () => mockCreateTask(any()),
        ).thenAnswer((_) async => Right(tTaskWithNotification));
        when(
          () => mockNotificationService.scheduleTaskNotification(
            tTaskWithNotification,
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {});
        return tasksBloc;
      },
      act: (bloc) => bloc.add(
        CreateTaskRequested(
          task: tTaskWithNotification,
          notificationTitle: 'Test title',
          notificationBody: 'Test body',
        ),
      ),
      verify: (_) {
        verify(
          () => mockNotificationService.scheduleTaskNotification(
            tTaskWithNotification,
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).called(1);
      },
    );

    blocTest<TasksBloc, TasksState>(
      'does not schedule notification when notificationId is null',
      build: () {
        when(
          () => mockCreateTask(any()),
        ).thenAnswer((_) async => Right(tTaskWithoutNotification));
        return tasksBloc;
      },
      act: (bloc) => bloc.add(
        CreateTaskRequested(
          task: tTaskWithoutNotification,
          notificationTitle: 'Test title',
          notificationBody: 'Test body',
        ),
      ),
      verify: (_) {
        verifyNever(
          () => mockNotificationService.scheduleTaskNotification(
            any(),
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        );
      },
    );
  });

  group('DeleteTaskRequested — notifications', () {
    blocTest<TasksBloc, TasksState>(
      'cancels notification when deleting a task with notificationId',
      build: () {
        when(() => mockGetTasks(any())).thenAnswer(
          (_) => Stream.value(Right([tTodayTask.copyWith(notificationId: 99)])),
        );
        when(
          () => mockDeleteTask(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockNotificationService.cancelNotification(99),
        ).thenAnswer((_) async {});
        return tasksBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadTasksRequested(userId: 'user-1'));
        await Future.delayed(Duration.zero);
        bloc.add(
          const DeleteTaskRequested(taskId: 'today-1', userId: 'user-1'),
        );
      },
      verify: (_) {
        verify(() => mockNotificationService.cancelNotification(99)).called(1);
      },
    );
  });
}
