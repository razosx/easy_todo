import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_out.dart';
import 'package:easy_todo/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSignInWithEmail extends Mock implements SignInWithEmail {}
class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}
class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}
class MockSignOut extends Mock implements SignOut {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignUpWithEmail mockSignUpWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;

  const tUser = UserEntity(id: 'uid-1', email: 'test@test.com');

  setUpAll(() {
    registerFallbackValue(const SignInWithEmailParams(email: '', password: ''));
    registerFallbackValue(const SignUpWithEmailParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignUpWithEmail = MockSignUpWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    authBloc = AuthBloc(
      authRepository: mockAuthRepository,
      signInWithEmail: mockSignInWithEmail,
      signUpWithEmail: mockSignUpWithEmail,
      signInWithGoogle: mockSignInWithGoogle,
      signOut: mockSignOut,
    );
  });

  tearDown(() => authBloc.close());

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('SignInWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
      build: () {
        when(() => mockSignInWithEmail(any()))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailRequested(
        email: 'test@test.com',
        password: '123456',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
      verify: (_) {
        verify(() => mockSignInWithEmail(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(() => mockSignInWithEmail(any())).thenAnswer(
            (_) async => const Left(AuthFailure(message: 'Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailRequested(
        email: 'test@test.com',
        password: 'wrong',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated with correct user',
      build: () {
        when(() => mockSignInWithEmail(any()))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailRequested(
        email: 'test@test.com',
        password: '123456',
      )),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(user: tUser),
      ],
    );
  });

  group('SignUpWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when sign up succeeds',
      build: () {
        when(() => mockSignUpWithEmail(any()))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpWithEmailRequested(
        email: 'new@test.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign up fails',
      build: () {
        when(() => mockSignUpWithEmail(any())).thenAnswer(
            (_) async => const Left(AuthFailure(message: 'Email already in use')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpWithEmailRequested(
        email: 'existing@test.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  group('SignInWithGoogleRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when Google sign in succeeds',
      build: () {
        when(() => mockSignInWithGoogle(any()))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithGoogleRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );
  });

  group('SignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when sign out succeeds',
      build: () {
        when(() => mockSignOut(any()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignOutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated when current user exists',
      build: () {
        when(() => mockAuthRepository.currentUser).thenReturn(tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [const AuthAuthenticated(user: tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when no current user',
      build: () {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
