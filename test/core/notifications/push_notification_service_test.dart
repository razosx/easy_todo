import 'package:easy_todo/core/notifications/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  late MockFirebaseMessaging mockMessaging;
  late PushNotificationServiceImpl service;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    service = PushNotificationServiceImpl(messaging: mockMessaging);
  });

  group('PushNotificationService', () {
    group('requestPermission', () {
      test('returns true when permission is granted', () async {
        final settings = _fakeSettings(AuthorizationStatus.authorized);
        when(() => mockMessaging.requestPermission()).thenAnswer((_) async => settings);

        final result = await service.requestPermission();

        expect(result, isTrue);
      });

      test('returns false when permission is denied', () async {
        final settings = _fakeSettings(AuthorizationStatus.denied);
        when(() => mockMessaging.requestPermission()).thenAnswer((_) async => settings);

        final result = await service.requestPermission();

        expect(result, isFalse);
      });

      test('returns true when permission is provisional (iOS quiet delivery)', () async {
        final settings = _fakeSettings(AuthorizationStatus.provisional);
        when(() => mockMessaging.requestPermission()).thenAnswer((_) async => settings);

        final result = await service.requestPermission();

        // provisional counts as granted (iOS shows notifications quietly)
        expect(result, isTrue);
      });
    });

    group('getToken', () {
      test('returns FCM token string when available', () async {
        when(() => mockMessaging.getToken()).thenAnswer((_) async => 'fake-fcm-token-123');

        final token = await service.getToken();

        expect(token, 'fake-fcm-token-123');
      });

      test('returns null when token is not available', () async {
        when(() => mockMessaging.getToken()).thenAnswer((_) async => null);

        final token = await service.getToken();

        expect(token, isNull);
      });
    });

    group('subscribeToTokenRefresh', () {
      test('calls onTokenRefresh stream from FirebaseMessaging', () async {
        const newToken = 'refreshed-token-456';
        when(() => mockMessaging.onTokenRefresh)
            .thenAnswer((_) => Stream.value(newToken));

        final tokens = <String>[];
        service.subscribeToTokenRefresh((token) => tokens.add(token));

        await Future<void>.delayed(Duration.zero);

        expect(tokens, [newToken]);
      });
    });
  });
}

/// Helper to create a fake NotificationSettings without depending on platform plugins.
NotificationSettings _fakeSettings(AuthorizationStatus status) {
  return NotificationSettings(
    authorizationStatus: status,
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.disabled,
    badge: AppleNotificationSetting.enabled,
    carPlay: AppleNotificationSetting.disabled,
    lockScreen: AppleNotificationSetting.enabled,
    notificationCenter: AppleNotificationSetting.enabled,
    showPreviews: AppleShowPreviewSetting.always,
    timeSensitive: AppleNotificationSetting.disabled,
    criticalAlert: AppleNotificationSetting.disabled,
    sound: AppleNotificationSetting.enabled,
    providesAppNotificationSettings: AppleNotificationSetting.disabled,
  );
}
