# Fase 1 — Setup & Arquitectura Foundation

## Objetivo

Establecer el esqueleto del proyecto: configuración de paquetes, DI container, tipos de error, contrato base de use-cases y utilidades de fecha. Sin features aún — solo los cimientos.

## Paquetes a agregar en pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_messaging: ^15.1.3

  # Google Auth
  google_sign_in: ^6.2.1

  # State management
  flutter_bloc: ^9.0.0
  equatable: ^2.0.5

  # DI
  get_it: ^8.0.2
  injectable: ^2.4.4

  # Functional programming
  dartz: ^0.10.1

  # Data classes / code gen
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Notifications
  flutter_local_notifications: ^18.0.1

  # Storage
  shared_preferences: ^2.3.2

  # Intl
  intl: ^0.20.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

  # Code generation
  build_runner: ^2.4.12
  injectable_generator: ^2.6.2
  freezed: ^2.5.7
  json_serializable: ^6.8.0

  # Testing
  mocktail: ^1.0.4
  bloc_test: ^9.1.7
  fake_cloud_firestore: ^3.0.3
  firebase_auth_mocks: ^0.14.1
```

## Archivos a crear

### Tests (primero — TDD)

#### `test/core/error/failures_test.dart`
```dart
import 'package:easy_todo/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    test('ServerFailure should have correct message', () {
      const failure = ServerFailure(message: 'Server error');
      expect(failure.message, 'Server error');
    });

    test('two ServerFailures with same message should be equal', () {
      const f1 = ServerFailure(message: 'Error');
      const f2 = ServerFailure(message: 'Error');
      expect(f1, equals(f2));
    });

    test('CacheFailure should have correct message', () {
      const failure = CacheFailure(message: 'Cache error');
      expect(failure.message, 'Cache error');
    });

    test('AuthFailure should have correct message', () {
      const failure = AuthFailure(message: 'Auth error');
      expect(failure.message, 'Auth error');
    });
  });
}
```

#### `test/core/utils/date_utils_test.dart`
```dart
import 'package:easy_todo/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskDateUtils', () {
    test('isToday returns true for today', () {
      final now = DateTime.now();
      expect(TaskDateUtils.isToday(now), isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(TaskDateUtils.isToday(yesterday), isFalse);
    });

    test('isToday returns false for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(TaskDateUtils.isToday(tomorrow), isFalse);
    });

    test('isFuture returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(TaskDateUtils.isFuture(tomorrow), isTrue);
    });

    test('isFuture returns false for today', () {
      final today = DateTime.now();
      expect(TaskDateUtils.isFuture(today), isFalse);
    });

    test('isSameDay returns true for same day different time', () {
      final d1 = DateTime(2024, 1, 15, 8, 0);
      final d2 = DateTime(2024, 1, 15, 20, 0);
      expect(TaskDateUtils.isSameDay(d1, d2), isTrue);
    });

    test('isSameDay returns false for different days', () {
      final d1 = DateTime(2024, 1, 15);
      final d2 = DateTime(2024, 1, 16);
      expect(TaskDateUtils.isSameDay(d1, d2), isFalse);
    });
  });
}
```

### Implementación

#### `lib/core/error/exceptions.dart`
```dart
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}
```

#### `lib/core/error/failures.dart`
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
```

#### `lib/core/usecases/usecase.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:easy_todo/core/error/failures.dart';
import 'package:equatable/equatable.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
```

#### `lib/core/utils/date_utils.dart`
```dart
class TaskDateUtils {
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.isAfter(today);
  }

  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.isBefore(today);
  }
}
```

#### `lib/core/di/injection.dart`
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

#### `lib/app.dart`
```dart
import 'package:flutter/material.dart';

class EasyTodoApp extends StatelessWidget {
  const EasyTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Easy Todo')),
      ),
    );
  }
}
```

#### `lib/main.dart`
```dart
import 'package:easy_todo/app.dart';
import 'package:easy_todo/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  runApp(const EasyTodoApp());
}
```

## Comandos a ejecutar

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/
```

## Verificación

- [ ] `flutter test test/core/` pasa en verde (6 tests)
- [ ] `flutter pub get` sin errores
- [ ] `dart run build_runner build` genera `injection.config.dart`
- [ ] App compila y muestra pantalla placeholder
