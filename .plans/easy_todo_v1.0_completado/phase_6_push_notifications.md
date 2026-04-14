# Fase 6 — Notificaciones Push (FCM)

## Objetivo

Recibir notificaciones remotas enviadas desde Firebase Cloud Messaging. El token FCM del dispositivo se guarda en Firestore para poder dirigir notificaciones al usuario desde el backend o desde la consola de Firebase.

## Paquete

`firebase_messaging: ^15.1.3` (ya en pubspec.yaml)

## Archivos

```
lib/core/notifications/
└── push_notification_service.dart

test/core/notifications/
└── push_notification_service_test.dart
```

## Implementación

### `lib/core/notifications/push_notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Handler de mensajes en background — debe ser función top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase ya está inicializado desde main()
  debugPrint('Background message: ${message.messageId}');
}

abstract class PushNotificationService {
  Future<void> initialize();
  Future<void> saveTokenToFirestore(String userId);
  Future<String?> getToken();
  Future<void> requestPermission();
}

class PushNotificationServiceImpl implements PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final LocalNotificationService _localNotifications;

  PushNotificationServiceImpl({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
    required LocalNotificationService localNotifications,
  })  : _messaging = messaging,
        _firestore = firestore,
        _localNotifications = localNotifications;

  @override
  Future<void> initialize() async {
    // Registrar background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Mostrar como notificación local mientras app está en foreground
      _showLocalNotificationFromRemote(message);
    });

    // App abierta desde notificación (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // App abierta desde estado terminado
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _showLocalNotificationFromRemote(RemoteMessage message) {
    // Delegar a LocalNotificationService para mostrar en foreground
    // ...
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navegar a la tarea relevante si hay data en el mensaje
    // message.data['taskId']
  }

  @override
  Future<void> saveTokenToFirestore(String userId) async {
    final token = await getToken();
    if (token == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fcmTokens')
        .doc(token)
        .set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': defaultTargetPlatform.name,
    });

    // Escuchar renovación de token
    _messaging.onTokenRefresh.listen((newToken) async {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(newToken)
          .set({
        'token': newToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });
    });
  }

  @override
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
```

## Estructura Firestore

```
users/{userId}/
└── fcmTokens/{token}
      token: String
      createdAt: Timestamp
      platform: String ('android' | 'iOS')
```

## Configuración Nativa

### Android

En `android/app/src/main/AndroidManifest.xml` dentro de `<application>`:

```xml
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT"/>
    </intent-filter>
</service>
```

### iOS — `ios/Runner/AppDelegate.swift`

```swift
// Agregar después del super.application(...)
if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
    )
} else {
    let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    application.registerUserNotificationSettings(settings)
}
application.registerForRemoteNotifications()
```

### iOS — `ios/Runner/Info.plist`

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### APN Certificate

Para iOS, configurar APNs en Firebase Console → Project Settings → Cloud Messaging → APNs Authentication Key.

## Integración en `main.dart`

```dart
// Después de configureDependencies():
final pushService = getIt<PushNotificationService>();
await pushService.initialize();
await pushService.requestPermission();

// Después del login, llamar:
await pushService.saveTokenToFirestore(user.id);
```

## Tests

### `test/core/notifications/push_notification_service_test.dart`

```dart
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late PushNotificationServiceImpl service;
  late MockFirebaseMessaging mockMessaging;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    mockFirestore = MockFirebaseFirestore();
    service = PushNotificationServiceImpl(
      messaging: mockMessaging,
      firestore: mockFirestore,
      localNotifications: MockLocalNotificationService(),
    );
  });

  test('getToken returns token from FirebaseMessaging', () async {
    when(() => mockMessaging.getToken()).thenAnswer((_) async => 'test-token');

    final token = await service.getToken();

    expect(token, 'test-token');
  });

  test('saveTokenToFirestore saves token to correct path', () async {
    when(() => mockMessaging.getToken()).thenAnswer((_) async => 'test-token');
    // Setup FakeFirestore y verificar escritura
  });
}
```

## Verificación

- [ ] Token FCM se guarda en Firestore al hacer login
- [ ] Notificación recibida desde Firebase Console en foreground
- [ ] Notificación recibida en background
- [ ] Tap en notificación abre la app
- [ ] Token se renueva automáticamente
