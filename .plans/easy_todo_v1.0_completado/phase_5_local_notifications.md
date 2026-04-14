# Fase 5 — Notificaciones Locales

## Objetivo

Programar una notificación local cuando una tarea tiene `dueDate`. Al crear/actualizar una tarea con fecha, se programa la notificación. Al completar o eliminar la tarea, se cancela.

## Paquete

`flutter_local_notifications: ^18.0.1` (ya en pubspec.yaml desde Fase 1)

## Archivos

```
lib/core/notifications/
└── local_notification_service.dart

test/core/notifications/
└── local_notification_service_test.dart
```

## Implementación

### `lib/core/notifications/local_notification_service.dart`

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

abstract class LocalNotificationService {
  Future<void> initialize();
  Future<void> scheduleTaskNotification(TaskEntity task);
  Future<void> cancelNotification(int notificationId);
  Future<void> cancelAll();
  Future<bool> requestPermission();
}

class LocalNotificationServiceImpl implements LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'easy_todo_channel',
    'Easy Todo Notifications',
    description: 'Notificaciones de tareas pendientes',
    importance: Importance.high,
  );

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _plugin.initialize(initSettings);

    // Crear canal en Android
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  @override
  Future<void> scheduleTaskNotification(TaskEntity task) async {
    if (task.dueDate == null || task.notificationId == null) return;

    final scheduledDate = tz.TZDateTime.from(task.dueDate!, tz.local);

    // No programar si la fecha ya pasó
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      task.notificationId!,
      'Tarea pendiente: ${task.title}',
      task.description.isNotEmpty ? task.description : 'Tienes una tarea por completar',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<bool> requestPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool? androidGranted = await androidImpl?.requestNotificationsPermission();
    bool? iosGranted = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return (androidGranted ?? true) && (iosGranted ?? true);
  }
}
```

## Integración con TasksBloc

En el `TasksBloc`, al procesar `CreateTaskRequested` y `UpdateTaskRequested`:
1. Generar un `notificationId` único (e.g., `task.hashCode.abs()`)
2. Llamar `localNotificationService.scheduleTaskNotification(task)`
3. Al `CompleteTaskRequested` o `DeleteTaskRequested`: llamar `cancelNotification(task.notificationId)`

## Configuración Nativa

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Dentro de <manifest> -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<!-- Dentro de <application> -->
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver">
    <intent-filter>
        <action android:name="com.dexterous.flutterlocalnotifications.NOTIFICATION_SCHEDULED"/>
    </intent-filter>
</receiver>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

### iOS — `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### iOS — `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Tests

### `test/core/notifications/local_notification_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late LocalNotificationServiceImpl service;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    service = LocalNotificationServiceImpl(plugin: mockPlugin);
  });

  group('scheduleTaskNotification', () {
    test('does nothing when dueDate is null', () async {
      final task = TaskEntity(
        id: '1', userId: 'u1', title: 'Test',
        createdAt: DateTime.now(), dueDate: null,
      );

      await service.scheduleTaskNotification(task);

      verifyNever(() => mockPlugin.zonedSchedule(any(), any(), any(), any(), any()));
    });

    test('cancels notification on cancelNotification call', () async {
      when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});

      await service.cancelNotification(42);

      verify(() => mockPlugin.cancel(42)).called(1);
    });
  });
}
```

## Verificación

- [ ] Tests de `LocalNotificationService` pasan
- [ ] Notificación aparece en hora programada en device físico
- [ ] Completar tarea cancela la notificación
- [ ] Eliminar tarea cancela la notificación
- [ ] Permisos solicitados correctamente en iOS y Android 13+
