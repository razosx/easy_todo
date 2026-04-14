# Easy Todo

A Flutter application for personal and collaborative task management, built with Clean Architecture and Firebase.

## Features

- **Personal Tasks** — Create, edit, complete and delete tasks with priority levels, due dates and local notifications.
- **Team Tasks** — Create or join a team with an invite code, assign tasks to members and track shared progress.
- **Authentication** — Email/password sign-up (with username) and Google Sign-In via Firebase Auth.
- **Themes** — Five themes: System, Light, Dark, Desert and Forest.
- **Localization** — English and Spanish.

## Architecture

The project follows **Clean Architecture** with feature-based modules.

```
lib/
├── core/
│   ├── di/                     # Dependency injection (get_it)
│   ├── error/                  # Failures & exceptions
│   ├── locale/                 # LocaleCubit
│   ├── notifications/          # Local & push notification services
│   ├── router/                 # GoRouter with auth guards
│   ├── theme/                  # ThemeCubit + 5 theme variants
│   └── usecases/               # Base UseCase abstraction
└── features/
    ├── auth/
    ├── tasks/
    ├── team_tasks/
    └── settings/
```

Each feature follows the same three-layer structure:

```
feature/
├── data/
│   ├── datasources/            # Firebase Firestore operations
│   ├── models/                 # Data models with JSON serialization
│   └── repositories/           # Repository implementations
├── domain/
│   ├── entities/               # Pure business objects
│   ├── repositories/           # Abstract interfaces
│   └── usecases/               # Business logic
└── presentation/
    ├── bloc/                   # BLoC / Cubit state management
    ├── pages/                  # Screens
    └── widgets/                # Reusable UI components
```

**Error handling** uses `dartz` `Either<Failure, T>` throughout the domain and data layers.

## State Management

| Class | Purpose |
|---|---|
| `AuthBloc` | Sign-in, sign-up, sign-out, session |
| `TasksBloc` | Personal task CRUD |
| `TeamBloc` | Team membership and info |
| `TeamTasksBloc` | Shared team task CRUD |
| `ThemeCubit` | Theme switching + persistence |
| `LocaleCubit` | Language switching + persistence |

## Tech Stack

| Category | Package |
|---|---|
| State management | `flutter_bloc ^9.0.0` |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging` |
| Google Sign-In | `google_sign_in ^7.2.0` |
| Navigation | `go_router ^14.0.0` |
| DI | `get_it ^9.2.1`, `injectable ^2.4.4` |
| Functional | `dartz ^0.10.1` |
| Notifications | `flutter_local_notifications ^21.0.0`, `timezone ^0.11.0` |
| Storage | `shared_preferences ^2.3.2` |
| Code generation | `freezed`, `json_serializable`, `build_runner` |
| Localization | `flutter_localizations`, `intl ^0.20.1` |

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.1`
- Dart SDK `^3.11.1`
- A Firebase project configured for Android, iOS and/or Web

### Setup

1. Clone the repository.

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase by placing the platform-specific config files (`google-services.json`, `GoogleService-Info.plist`, etc.) in their respective directories, or run:
   ```bash
   flutterfire configure
   ```

4. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Localization

Supported languages: **English** (`en`) and **Spanish** (`es`).

**The `.arb` files are the single source of truth.** Never edit the generated Dart files under `lib/l10n/` — they are stamped with a `// GENERATED` header and ignored in GitHub diffs via `.gitattributes`.

### Workflow

| Task | Command |
|---|---|
| Regenerate Dart files after editing `.arb` | `make l10n` |
| Add a new string to both languages at once | `make l10n-add KEY=myKey EN="My value" ES="Mi valor"` |
| Check that `en` and `es` are in sync | `make l10n-check` |

### Adding a string manually

1. Add the key to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`.
2. Run `make l10n` to regenerate.

Or use the helper in one step:

```bash
./scripts/add_l10n.sh profileTitle "Profile" "Perfil"
```

## Testing

```bash
flutter test
```

Tests are organized to mirror the source tree:

```
test/
├── core/
│   ├── error/
│   ├── notifications/
│   ├── theme/
│   └── utils/
└── features/
    ├── auth/
    ├── tasks/
    ├── settings/
    └── team_tasks/
```

**Testing dependencies:** `mocktail`, `bloc_test`, `fake_cloud_firestore`, `firebase_auth_mocks`.

## Firebase Collections

| Collection | Description |
|---|---|
| `users` | User profiles (display name, username, photo URL) |
| `tasks` | Personal tasks scoped to the authenticated user |
| `teams` | Team documents with invite codes and member lists |
| `team_tasks` | Tasks belonging to a team |

## Platform Support

Android · iOS · Web · macOS · Linux · Windows
