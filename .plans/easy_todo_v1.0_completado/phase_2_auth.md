# Fase 2 — Autenticación (Auth Feature)

## Objetivo

Implementar login con email/password y Google Sign-in usando Firebase Auth. El AuthBloc gestiona el estado de sesión globalmente. La navegación entre login y home se maneja según el estado del AuthBloc.

## Orden TDD

1. Tests domain → implementar domain
2. Tests data → implementar data
3. Tests BLoC → implementar BLoC
4. UI (LoginPage + widgets — solo smoke tests de widget)

## Estructura de archivos

```
lib/features/auth/
├── domain/
│   ├── entities/user_entity.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/
│       ├── sign_in_with_email.dart
│       ├── sign_in_with_google.dart
│       ├── sign_up_with_email.dart
│       ├── sign_out.dart
│       └── get_current_user.dart
├── data/
│   ├── datasources/auth_remote_data_source.dart
│   ├── models/user_model.dart
│   └── repositories/auth_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── auth_event.dart
    │   ├── auth_state.dart
    │   └── auth_bloc.dart
    ├── pages/login_page.dart
    └── widgets/
        ├── email_sign_in_form.dart
        └── google_sign_in_button.dart

test/features/auth/
├── domain/usecases/
│   ├── sign_in_with_email_test.dart
│   ├── sign_in_with_google_test.dart
│   ├── sign_up_with_email_test.dart
│   └── sign_out_test.dart
├── data/
│   ├── datasources/auth_remote_data_source_test.dart
│   └── repositories/auth_repository_impl_test.dart
└── presentation/bloc/auth_bloc_test.dart
```

## Domain Layer

### `lib/features/auth/domain/entities/user_entity.dart`
```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
```

### `lib/features/auth/domain/repositories/auth_repository.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Stream<UserEntity?> get authStateChanges;

  UserEntity? get currentUser;
}
```

### Use Cases

```dart
// sign_in_with_email.dart
import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:easy_todo/core/usecases/usecase.dart';
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:easy_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class SignInWithEmail extends UseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository repository;
  SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) {
    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailParams extends Equatable {
  final String email;
  final String password;
  const SignInWithEmailParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
```

Patrones similares para `SignInWithGoogle`, `SignUpWithEmail`, `SignOut`.

## Data Layer

### `lib/features/auth/data/models/user_model.dart`
```dart
import 'package:easy_todo/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}
```

### `lib/features/auth/data/datasources/auth_remote_data_source.dart`
```dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> signUpWithEmail({required String email, required String password});
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  // Implementaciones que envuelven FirebaseAuth en try/catch
  // lanzando AuthException en caso de error
}
```

### `lib/features/auth/data/repositories/auth_repository_impl.dart`
```dart
// Implementa AuthRepository
// Convierte AuthException → AuthFailure (Either)
// Convierte ServerException → ServerFailure (Either)
```

## Presentation Layer

### Estados del AuthBloc

```dart
// auth_state.dart
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState { ... }
class AuthLoading extends AuthState { ... }
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  ...
}
class AuthUnauthenticated extends AuthState { ... }
class AuthError extends AuthState {
  final String message;
  ...
}
```

### Eventos del AuthBloc

```dart
// auth_event.dart
abstract class AuthEvent extends Equatable {}

class AuthCheckRequested extends AuthEvent { ... }
class SignInWithEmailRequested extends AuthEvent {
  final String email, password;
  ...
}
class SignUpWithEmailRequested extends AuthEvent {
  final String email, password;
  ...
}
class SignInWithGoogleRequested extends AuthEvent { ... }
class SignOutRequested extends AuthEvent { ... }
```

## Tests clave

### `test/features/auth/domain/usecases/sign_in_with_email_test.dart`
```dart
void main() {
  late SignInWithEmail usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInWithEmail(mockRepository);
  });

  test('should return UserEntity when sign in succeeds', () async {
    const user = UserEntity(id: '1', email: 'test@test.com');
    const params = SignInWithEmailParams(email: 'test@test.com', password: '123456');

    when(() => mockRepository.signInWithEmail(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => const Right(user));

    final result = await usecase(params);

    expect(result, const Right(user));
  });

  test('should return AuthFailure when sign in fails', () async {
    const params = SignInWithEmailParams(email: 'test@test.com', password: 'wrong');

    when(() => mockRepository.signInWithEmail(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => const Left(AuthFailure(message: 'Invalid credentials')));

    final result = await usecase(params);

    expect(result, const Left(AuthFailure(message: 'Invalid credentials')));
  });
}
```

### `test/features/auth/presentation/bloc/auth_bloc_test.dart`
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
  build: () {
    when(() => mockSignInWithEmail(any()))
        .thenAnswer((_) async => Right(tUser));
    return AuthBloc(signInWithEmail: mockSignInWithEmail, ...);
  },
  act: (bloc) => bloc.add(SignInWithEmailRequested(
    email: 'test@test.com',
    password: '123456',
  )),
  expect: () => [AuthLoading(), AuthAuthenticated(user: tUser)],
);
```

## Configuración nativa requerida

### Android (`android/app/build.gradle.kts`)
- Asegurarse de que `com.google.gms.google-services` está aplicado
- SHA-1 del keystore de debug registrado en Firebase Console

### iOS (`ios/Runner/Info.plist`)
- Agregar `GIDClientID` con el client ID de Google
- URL scheme reverso para Google Sign-In

## Comandos

```bash
flutter test test/features/auth/
flutter run  # verificar login en emulador
```

## Verificación

- [ ] Todos los tests de auth pasan
- [ ] Login con email/password funciona en emulador
- [ ] Login con Google funciona en device real (requiere SHA-1)
- [ ] Sign out redirige a pantalla de login
- [ ] AuthBloc emite estados correctos en cada caso
