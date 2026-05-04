import 'package:easy_todo/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class LocalNotificationService {
  Future<void> initialize();
  Future<void> scheduleTaskNotification(
    TaskEntity task, {
    required String title,
    required String body,
  });
  Future<void> cancelNotification(int notificationId);
  Future<void> cancelAll();
  Future<bool> requestPermission();
}

class LocalNotificationServiceImpl implements LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'easy_todo_channel';
  static const _channelName = 'Easy Todo Notifications';
  static const _channelDesc = 'Easy Todo Notifications';

  @override
  Future<void> initialize() async {
    // Initialize timezone database and set device's local timezone.
    // This is required so scheduled notifications fire at the correct local time.
    tz.initializeTimeZones();
    final String deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimeZone));

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

    await _plugin.initialize(settings: initSettings);

    // Create the notification channel (required on Android 8+).
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // Request POST_NOTIFICATIONS runtime permission (Android 13+).
    await requestPermission();
  }

  @override
  Future<void> scheduleTaskNotification(
    TaskEntity task, {
    required String title,
    required String body,
  }) async {
    if (task.dueDate == null || task.notificationId == null) return;

    // Build a TZDateTime in the device's local timezone directly from the
    // date/time components the user selected — do NOT use TZDateTime.from()
    // which would misinterpret the DateTime's UTC epoch.
    final due = task.dueDate!;
    final scheduledDate = tz.TZDateTime(
      tz.local,
      due.year,
      due.month,
      due.day,
      due.hour,
      due.minute,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // Check if exact alarm permission is granted on Android 12+.
    // Fall back to inexact scheduling if it was revoked by the user.
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canScheduleExact =
          await androidImpl?.canScheduleExactNotifications() ?? true;
      if (!canScheduleExact) {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _plugin.zonedSchedule(
      id: task.notificationId!,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: scheduleMode,
    );
  }

  @override
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(id: notificationId);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidImpl?.requestNotificationsPermission();
      return granted ?? true;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    }
    return true;
  }
}
