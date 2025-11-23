import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduled,
  }) async {
    final int id =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subtrack_channel',
          'Subscription Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),

      // 🔥 FIX — no exact-alarm requirement
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      // 🔥 FIX — prevents Android from demanding exact alarm permission
      matchDateTimeComponents: null,

      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
