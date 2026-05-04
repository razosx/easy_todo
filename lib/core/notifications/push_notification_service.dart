import 'package:firebase_messaging/firebase_messaging.dart';

abstract class PushNotificationService {
  Future<bool> requestPermission();
  Future<String?> getToken();
  void subscribeToTokenRefresh(void Function(String token) onToken);
  void onForegroundMessage(void Function(RemoteMessage message) handler);
}

class PushNotificationServiceImpl implements PushNotificationService {
  final FirebaseMessaging _messaging;

  PushNotificationServiceImpl({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  @override
  void subscribeToTokenRefresh(void Function(String token) onToken) {
    _messaging.onTokenRefresh.listen(onToken);
  }

  @override
  void onForegroundMessage(void Function(RemoteMessage message) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }
}
