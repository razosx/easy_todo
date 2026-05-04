# Login / Auth Flow — Easy Todo

Documentación detallada del flujo de autenticación de la aplicación, incluyendo
Sign In con email, Sign Up con email, Sign In con Google y la verificación de sesión
al arrancar la app.

---

## Arquitectura general

La app sigue **Clean Architecture** dividida en tres capas:

```
Presentation  →  Domain  →  Data
(UI + BLoC)      (UseCases    (Repository Impl
                  + Entities    + Remote Data Source
                  + Repository    + Models)
                  Contract)
```

La comunicación entre capas usa el patrón **Either<Failure, T>** del paquete
`dartz`, donde el resultado de cada operación es o un fallo (`Left`) o un valor
exitoso (`Right`).

---

## Archivos involucrados

| Capa | Archivo | Clases principales |
|------|---------|-------------------|
| UI | `lib/features/auth/presentation/pages/login_page.dart` | `LoginPage`, `_LoginPageState` |
| UI | `lib/features/auth/presentation/widgets/email_sign_in_form.dart` | `EmailSignInForm`, `_EmailSignInFormState` |
| UI | `lib/features/auth/presentation/widgets/google_sign_in_button.dart` | `GoogleSignInButton` |
| BLoC | `lib/features/auth/presentation/bloc/auth_bloc.dart` | `AuthBloc` |
| BLoC | `lib/features/auth/presentation/bloc/auth_event.dart` | `AuthEvent` y subclases |
| BLoC | `lib/features/auth/presentation/bloc/auth_state.dart` | `AuthState` y subclases |
| Domain | `lib/features/auth/domain/entities/user_entity.dart` | `UserEntity` |
| Domain | `lib/features/auth/domain/repositories/auth_repository.dart` | `AuthRepository` (abstracto) |
| Domain | `lib/features/auth/domain/usecases/sign_in_with_email.dart` | `SignInWithEmail` |
| Domain | `lib/features/auth/domain/usecases/sign_up_with_email.dart` | `SignUpWithEmail` |
| Domain | `lib/features/auth/domain/usecases/sign_in_with_google.dart` | `SignInWithGoogle` |
| Domain | `lib/features/auth/domain/usecases/sign_out.dart` | `SignOut` |
| Domain | `lib/features/auth/domain/usecases/check_username_available.dart` | `CheckUsernameAvailable` |
| Data | `lib/features/auth/data/repositories/auth_repository_impl.dart` | `AuthRepositoryImpl` |
| Data | `lib/features/auth/data/datasources/auth_remote_data_source.dart` | `AuthRemoteDataSourceImpl` |
| Data | `lib/features/auth/data/models/user_model.dart` | `UserModel` |
| Core | `lib/core/error/exceptions.dart` | `AuthException`, `ServerException`, … |
| Core | `lib/core/error/failures.dart` | `AuthFailure`, `ServerFailure`, … |
| Core | `lib/core/router/app_router.dart` | `AppRouter` |
| Bootstrap | `lib/main.dart` | (inyección manual de dependencias) |
| Bootstrap | `lib/app.dart` | `EasyTodoApp` |

---

## Eventos del BLoC (`auth_event.dart`)

```dart
abstract class AuthEvent {}

class AuthCheckRequested       extends AuthEvent {}   // Revisar sesión al iniciar
class SignInWithEmailRequested extends AuthEvent {    // Login con email
  final String email;
  final String password;
}
class SignUpWithEmailRequested extends AuthEvent {    // Registro con email
  final String email;
  final String password;
  final String name;
  final String username;
}
class SignInWithGoogleRequested extends AuthEvent {}  // Login con Google
class SignOutRequested          extends AuthEvent {}  // Cerrar sesión
```

## Estados del BLoC (`auth_state.dart`)

```dart
abstract class AuthState {}

class AuthInitial        extends AuthState {}          // Estado inicial
class AuthLoading        extends AuthState {}          // Operación en curso
class AuthAuthenticated  extends AuthState {           // Usuario autenticado
  final UserEntity user;
}
class AuthUnauthenticated extends AuthState {}         // Sin sesión activa
class AuthError           extends AuthState {          // Error de autenticación
  final String message;
}
```

---

## Flujo 1 — Verificación de sesión al arrancar la app

Se ejecuta automáticamente en `app.dart → initState()` para saber si hay una
sesión activa persistida.

```
app.dart
  initState()
    └─► AuthBloc.add(AuthCheckRequested())
          │
          ▼
        auth_bloc.dart
          _onAuthCheck(AuthCheckRequested, Emitter<AuthState>)
            │
            ├─► emit(AuthLoading())
            │
            ├─► authRepository.currentUser          ← getter en AuthRemoteDataSourceImpl
            │     └─► FirebaseAuth.instance.currentUser   (devuelve User? de Firebase)
            │
            ├─ Si currentUser == null
            │     └─► emit(AuthUnauthenticated())
            │               │
            │               ▼
            │          AppRouter._redirect()
            │            └─► navega a '/login'
            │
            └─ Si currentUser != null
                  └─► authRepository.getFullCurrentUser()
                            │
                            ▼
                        AuthRepositoryImpl.getFullCurrentUser()
                          └─► authRemoteDataSource.getFullCurrentUser()
                                    │
                                    ▼
                                AuthRemoteDataSourceImpl.getFullCurrentUser()
                                  ├─► FirebaseAuth.instance.currentUser
                                  └─► _fetchProfileFromFirestore(firebaseUser)
                                            │
                                            ▼
                                        Firestore.collection('users')
                                          .doc(uid).get()
                                          ├─ Si existe el doc
                                          │     └─► UserModel.fromMap(docData)
                                          └─ Si no existe
                                                └─► UserModel.fromFirebaseUser(user)
                                                      (solo datos de Firebase Auth)
                            │
                            ▼
                       Either<Failure, UserEntity?>
                          ├─ Right(user) → emit(AuthAuthenticated(user))
                          │                      │
                          │                      ▼
                          │               AppRouter._redirect()
                          │                 └─► navega a '/home'
                          └─ Left(failure) → emit(AuthUnauthenticated())
                                                   └─► navega a '/login'
```

---

## Flujo 2 — Sign In con Email y Contraseña

### 2.1 Interacción en la UI

```
login_page.dart
  LoginPage.build()
    └─► EmailSignInForm(isSignUp: false)
          │
          ▼
        email_sign_in_form.dart
          _EmailSignInFormState.build()
            ├─► TextFormField (email)    — validator: debe contener '@'
            └─► TextFormField (password) — validator: mínimo 6 caracteres
            └─► FilledButton("Iniciar sesión")
                    └─► onPressed: _submit()
```

### 2.2 Método `_submit()` en `_EmailSignInFormState`

```dart
void _submit() {
  if (!_formKey.currentState!.validate()) return;   // Valida el Form

  context.read<AuthBloc>().add(
    SignInWithEmailRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    ),
  );
}
```

### 2.3 Diagrama completo del flujo

```
_EmailSignInFormState._submit()
  └─► AuthBloc.add(SignInWithEmailRequested(email, password))
          │
          ▼
        auth_bloc.dart
          _onSignInWithEmail(SignInWithEmailRequested, Emitter<AuthState>)
            │
            ├─► emit(AuthLoading())
            │     UI: botón deshabilitado + spinner
            │
            ├─► signInWithEmail(SignInWithEmailParams(email, password))
            │         │
            │         ▼ (use case)
            │       sign_in_with_email.dart
            │         SignInWithEmail.call(params)
            │           └─► repository.signInWithEmail(email: …, password: …)
            │                     │
            │                     ▼
            │               auth_repository_impl.dart
            │                 AuthRepositoryImpl.signInWithEmail()
            │                   └─► remoteDataSource.signInWithEmail(email, password)
            │                             │
            │                             ▼
            │                       auth_remote_data_source.dart
            │                         AuthRemoteDataSourceImpl.signInWithEmail()
            │                           │
            │                           ├─► FirebaseAuth.signInWithEmailAndPassword(
            │                           │     email: email,
            │                           │     password: password,
            │                           │   )
            │                           │     ├─ FirebaseAuthException
            │                           │     │   └─► throw AuthException(message)
            │                           │     └─ Otra excepción
            │                           │         └─► throw ServerException(message)
            │                           │
            │                           └─► _fetchProfileFromFirestore(firebaseUser)
            │                                     │
            │                                     ▼
            │                               Firestore.collection('users')
            │                                 .doc(firebaseUser.uid).get()
            │                                 ├─ Documento existe
            │                                 │   └─► UserModel.fromMap({
            │                                 │           id, email, displayName,
            │                                 │           name, username, photoUrl
            │                                 │         })
            │                                 └─ No existe
            │                                     └─► UserModel.fromFirebaseUser(user)
            │
            ▼
        Either<Failure, UserEntity>
          │
          ├─ Left(AuthFailure | ServerFailure)
          │     └─► emit(AuthError(message: failure.message))
          │               UI: Snackbar con el mensaje de error
          │
          └─ Right(UserEntity)
                └─► emit(AuthAuthenticated(user: user))
                          │
                          ▼
                    AppRouter._redirect()
                      └─► BLoC state = AuthAuthenticated
                            └─► navega a '/home'  (MainScaffold)
```

---

## Flujo 3 — Sign Up con Email (Registro)

### 3.1 Validación de username en tiempo real

Antes de enviar el formulario, el campo `username` se valida con debounce
cada vez que el usuario escribe.

```
email_sign_in_form.dart
  TextFormField(username)
    onChanged: _onUsernameChanged(value)
                    │
                    ▼
              _EmailSignInFormState._onUsernameChanged()
                ├─► Cancela el Timer anterior (debounce 500ms)
                ├─► Valida formato localmente:
                │     - longitud >= 3
                │     - regex: ^[a-zA-Z0-9_]+$
                │
                └─► Timer(500ms, () {
                      setState(() => _usernameStatus = UsernameStatus.checking)
                        │
                        ▼
                      CheckUsernameAvailable.call(username.toLowerCase())
                        └─► AuthRepositoryImpl.checkUsernameAvailable(username)
                              └─► AuthRemoteDataSourceImpl.checkUsernameAvailable()
                                    │
                                    ▼
                              Firestore.collection('users')
                                .where('username', isEqualTo: username)
                                .limit(1)
                                .get()
                                ├─ docs.isEmpty → true  (disponible)
                                └─ docs.isNotEmpty → false (ocupado)
                        │
                        ▼
                      Either<Failure, bool>
                        ├─ Right(true)  → setState(UsernameStatus.available)
                        │                   UI: ícono verde ✓
                        └─ Right(false) → setState(UsernameStatus.taken)
                                            UI: ícono rojo ✗
                    })
```

### 3.2 Envío del formulario de registro

```
_EmailSignInFormState._submit()   (isSignUp == true)
  └─► AuthBloc.add(SignUpWithEmailRequested(
        email, password, name, username
      ))
          │
          ▼
        auth_bloc.dart
          _onSignUpWithEmail(SignUpWithEmailRequested, Emitter<AuthState>)
            │
            ├─► emit(AuthLoading())
            │
            ├─► signUpWithEmail(SignUpWithEmailParams(
            │     email, password, name, username
            │   ))
            │         │
            │         ▼ (use case)
            │       sign_up_with_email.dart
            │         SignUpWithEmail.call(params)
            │           └─► repository.signUpWithEmail(email, password, name, username)
            │                     │
            │                     ▼
            │               AuthRepositoryImpl.signUpWithEmail()
            │                 └─► remoteDataSource.signUpWithEmail(…)
            │                           │
            │                           ▼
            │                     AuthRemoteDataSourceImpl.signUpWithEmail()
            │                       │
            │                       ├─ 1. Verificar disponibilidad de username
            │                       │       checkUsernameAvailable(username)
            │                       │         └─► Firestore query (igual al flujo 3.1)
            │                       │       Si NO disponible:
            │                       │         throw AuthException(
            │                       │           'El nombre de usuario ya está en uso'
            │                       │         )
            │                       │
            │                       ├─ 2. Crear usuario en Firebase Auth
            │                       │       FirebaseAuth.createUserWithEmailAndPassword(
            │                       │         email: email,
            │                       │         password: password,
            │                       │       )
            │                       │
            │                       ├─ 3. Actualizar displayName en Firebase Auth
            │                       │       firebaseUser.updateDisplayName(name)
            │                       │
            │                       ├─ 4. Crear documento en Firestore
            │                       │       Firestore.collection('users')
            │                       │         .doc(uid)
            │                       │         .set({
            │                       │           'id':          uid,
            │                       │           'email':       email,
            │                       │           'displayName': name,
            │                       │           'name':        name,
            │                       │           'username':    username,
            │                       │           'photoUrl':    null,
            │                       │         })
            │                       │
            │                       └─ 5. Retornar modelo
            │                               UserModel.fromMap(profile)
            │
            ▼
        Either<Failure, UserEntity>
          ├─ Left(AuthFailure | ServerFailure)
          │     └─► emit(AuthError(message))
          │               UI: Snackbar con error
          └─ Right(UserEntity)
                └─► emit(AuthAuthenticated(user))
                          └─► AppRouter navega a '/home'
```

---

## Flujo 4 — Sign In con Google

```
google_sign_in_button.dart
  GoogleSignInButton.build()
    └─► OutlinedButton("Continuar con Google")
              onPressed: () {
                context.read<AuthBloc>().add(
                  SignInWithGoogleRequested()
                )
              }
                    │
                    ▼
                  auth_bloc.dart
                    _onSignInWithGoogle(SignInWithGoogleRequested, Emitter<AuthState>)
                      │
                      ├─► emit(AuthLoading())
                      │
                      ├─► signInWithGoogle(NoParams())
                      │         │
                      │         ▼ (use case)
                      │       sign_in_with_google.dart
                      │         SignInWithGoogle.call(NoParams())
                      │           └─► repository.signInWithGoogle()
                      │                     │
                      │                     ▼
                      │               AuthRepositoryImpl.signInWithGoogle()
                      │                 └─► remoteDataSource.signInWithGoogle()
                      │                           │
                      │                           ▼
                      │                     AuthRemoteDataSourceImpl.signInWithGoogle()
                      │                       │
                      │                       ├─ 1. Flujo interactivo de Google
                      │                       │       GoogleSignIn.authenticate()
                      │                       │         └─► Abre selector de cuenta Google
                      │                       │               (sistema operativo)
                      │                       │
                      │                       ├─ 2. Obtener tokens de Google
                      │                       │       googleAccount.authentication
                      │                       │         → idToken, accessToken
                      │                       │
                      │                       ├─ 3. Crear credencial de Firebase
                      │                       │       GoogleAuthProvider.credential(
                      │                       │         idToken: …,
                      │                       │         accessToken: …,
                      │                       │       )
                      │                       │
                      │                       ├─ 4. Autenticar en Firebase
                      │                       │       FirebaseAuth.signInWithCredential(
                      │                       │         googleCredential
                      │                       │       )
                      │                       │
                      │                       └─ 5. Obtener perfil completo
                      │                               _fetchProfileFromFirestore(firebaseUser)
                      │                                 └─► Firestore 'users' doc
                      │                                       Si existe → UserModel.fromMap()
                      │                                       Si no    → UserModel.fromFirebaseUser()
                      │                                                   (crea perfil mínimo)
                      │
                      ▼
                  Either<Failure, UserEntity>
                    ├─ Left(AuthFailure | ServerFailure)
                    │     └─► emit(AuthError(message))
                    └─ Right(UserEntity)
                          └─► emit(AuthAuthenticated(user))
                                    └─► AppRouter navega a '/home'
```

---

## Flujo 5 — Sign Out

```
(Cualquier widget con acceso al AuthBloc)
  context.read<AuthBloc>().add(SignOutRequested())
          │
          ▼
        auth_bloc.dart
          _onSignOut(SignOutRequested, Emitter<AuthState>)
            │
            ├─► emit(AuthLoading())
            │
            ├─► signOut(NoParams())
            │         │
            │         ▼ (use case)
            │       sign_out.dart
            │         SignOut.call(NoParams())
            │           └─► repository.signOut()
            │                     │
            │                     ▼
            │               AuthRepositoryImpl.signOut()
            │                 └─► remoteDataSource.signOut()
            │                           │
            │                           ▼
            │                     AuthRemoteDataSourceImpl.signOut()
            │                       └─► Future.wait([
            │                             FirebaseAuth.instance.signOut(),
            │                             GoogleSignIn.instance.signOut(),
            │                           ])
            │
            ▼
        Either<Failure, void>
          ├─ Left(failure) → emit(AuthError(message))
          └─ Right(void)   → emit(AuthUnauthenticated())
                                      └─► AppRouter navega a '/login'
```

---

## Enrutamiento reactivo (`app_router.dart`)

El router escucha el stream del `AuthBloc` mediante `GoRouterRefreshStream` y
redirige automáticamente en función del estado actual.

```dart
// AppRouter._redirect()
switch (authState) {
  AuthInitial | AuthLoading  →  '/'       (LoadingPage — pantalla de carga)
  AuthAuthenticated          →  '/home'   (MainScaffold)
  AuthUnauthenticated
  | AuthError                →  '/login'  (LoginPage)
}
```

| Ruta | Widget | Condición |
|------|--------|-----------|
| `/` | `LoadingPage` | Estado inicial o cargando |
| `/login` | `LoginPage` | Sin sesión o error |
| `/home` | `MainScaffold` | Sesión activa |

---

## Modelos de datos

### `UserEntity` (`domain/entities/user_entity.dart`)

```dart
class UserEntity extends Equatable {
  final String  id;           // UID de Firebase Auth
  final String  email;
  final String? displayName;  // Nombre visible (Firebase)
  final String? photoUrl;     // URL de avatar
  final String? username;     // Username único en la app
  final String? name;         // Nombre completo
}
```

### `UserModel` (`data/models/user_model.dart`)

Extiende `UserEntity`. Agrega lógica de serialización:

| Factory | Fuente | Descripción |
|---------|--------|-------------|
| `UserModel.fromFirebaseUser(User)` | Firebase Auth | Solo datos básicos de Firebase (sin username) |
| `UserModel.fromMap(Map)` | Firestore | Perfil completo con username y name |
| `.toMap()` | — | Serializa a Map para guardar en Firestore |

### Colección Firestore `users`

```
users/
  {uid}/
    id:          String   — UID de Firebase Auth
    email:       String
    displayName: String   — Nombre para mostrar
    name:        String   — Nombre completo
    username:    String   — Username único (lowercase)
    photoUrl:    String?  — URL del avatar (null por defecto)
```

---

## Manejo de errores

### Excepciones (Data Layer — `core/error/exceptions.dart`)

| Excepción | Cuándo se lanza |
|-----------|----------------|
| `AuthException(message)` | Credenciales inválidas, username tomado, `FirebaseAuthException` |
| `ServerException(message)` | Error de red, fallo de Firestore, error inesperado |
| `NetworkException(message)` | Sin conectividad |
| `CacheException(message)` | Error de caché local |

### Failures (Domain Layer — `core/error/failures.dart`)

El `AuthRepositoryImpl` captura las excepciones y las convierte en `Failure`:

```
AuthException   →  AuthFailure(message)
ServerException →  ServerFailure(message)
```

El BLoC recibe el `Either` y emite `AuthError(message)` cuando el lado
izquierdo está presente.

### Presentación de errores

`login_page.dart` usa `BlocListener<AuthBloc, AuthState>`:

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
)
```

---

## Inyección de dependencias (`main.dart` + `app.dart`)

Las dependencias se crean manualmente en `main.dart` y se pasan por constructor:

```
main.dart
  ├─► AuthRemoteDataSourceImpl(
  │     firebaseAuth: FirebaseAuth.instance,
  │     googleSignIn: GoogleSignIn.instance,
  │     firestore:    FirebaseFirestore.instance,
  │   )
  │
  ├─► AuthRepositoryImpl(remoteDataSource)
  │
  ├─► SignInWithEmail(authRepository)
  ├─► SignUpWithEmail(authRepository)
  ├─► SignInWithGoogle(authRepository)
  ├─► SignOut(authRepository)
  └─► CheckUsernameAvailable(authRepository)
            │
            ▼ (se pasan a EasyTodoApp via constructor)
          app.dart
            EasyTodoApp.initState()
              └─► AuthBloc(
                    authRepository,
                    signInWithEmail,
                    signUpWithEmail,
                    signInWithGoogle,
                    signOut,
                  )
              └─► Providers expuestos al árbol de widgets:
                    BlocProvider<AuthBloc>
                    RepositoryProvider<CheckUsernameAvailable>
```

---

## Resumen visual del flujo completo (Sign In con Email)

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                                  │
│                                                                      │
│  LoginPage (login_page.dart)                                         │
│    └─ EmailSignInForm (email_sign_in_form.dart)                      │
│         ├─ TextFormField: email     ──────► validator('@' requerido) │
│         ├─ TextFormField: password  ──────► validator(min 6 chars)   │
│         └─ FilledButton "Iniciar sesión"                             │
│               │                                                      │
│               ▼ _submit()                                            │
│         AuthBloc.add(SignInWithEmailRequested(email, password))      │
│               │                                                      │
│               ▼                                                      │
│         AuthBloc._onSignInWithEmail()                                │
│               ├─► emit(AuthLoading)   ◄─── UI desactiva botón        │
│               └─► signInWithEmail(params)                            │
└────────────────────────────┬────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│  DOMAIN LAYER                                                        │
│                                                                      │
│  SignInWithEmail.call(SignInWithEmailParams)                          │
│    └─► AuthRepository.signInWithEmail(email, password)               │
│          (interfaz abstracta)                                        │
└────────────────────────────┬────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│  DATA LAYER                                                          │
│                                                                      │
│  AuthRepositoryImpl.signInWithEmail()                                │
│    └─► AuthRemoteDataSourceImpl.signInWithEmail()                    │
│          │                                                           │
│          ├─ FirebaseAuth.signInWithEmailAndPassword(email, password) │
│          │     Firebase Auth REST API (gestionado por SDK)           │
│          │                                                           │
│          └─ _fetchProfileFromFirestore(firebaseUser)                 │
│               Firestore: GET /users/{uid}                            │
│                 ├─ existe  → UserModel.fromMap(data)                 │
│                 └─ no existe → UserModel.fromFirebaseUser(user)      │
│                                                                      │
│  Resultado: UserModel (extends UserEntity)                           │
└────────────────────────────┬────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│  DE VUELTA EN PRESENTATION LAYER                                     │
│                                                                      │
│  AuthBloc recibe Either<Failure, UserEntity>                         │
│    ├─ Left(failure)  → emit(AuthError(message))                      │
│    │     LoginPage BlocListener → SnackBar con error                 │
│    │                                                                  │
│    └─ Right(user)    → emit(AuthAuthenticated(user))                 │
│          AppRouter._redirect() → navega a '/home'                    │
└─────────────────────────────────────────────────────────────────────┘
```
