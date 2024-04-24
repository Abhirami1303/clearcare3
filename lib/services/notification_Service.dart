import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    print("Initialising notificationService");
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    print("Initialising notificationService complete");

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  static Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDateTime) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails('clearCare', 'clearCareNotification',
            importance: Importance.max);

    tzdata.initializeTimeZones();

    // Set the local time zone to Asia/Kolkata (India)

    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Parse time string into a DateTime object
    /* List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(' ')[0]);
    String meridiem = parts[1].split(' ')[1];
    if (meridiem == 'PM' && hour != 12) {
      hour += 12;
    } else if (meridiem == 'AM' && hour == 12) {
      hour = 0;
    }

    DateTime now = DateTime.now();
    DateTime scheduledDateTime =
        DateTime(now.year, now.month, now.day, hour, minute);*/
//print("scheduled time : $scheduledDateTime");
    print("tzTime  : ${tz.TZDateTime.from(scheduledDateTime, tz.local)}");
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'scheduled notification',
    );

    //print("tzTime  : ${flutterLocalNotificationsPlugin.pendingNotificationRequests()}");
  }

  static Future<List<ActiveNotification>> getActiveNotifications() async {
    List<PendingNotificationRequest> notificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var req in notificationRequests) {
      print("requests  : ${req.body} ${req.title} ${req.id} ");
    }
    print(
        "pending notifications : ${await flutterLocalNotificationsPlugin.pendingNotificationRequests().toString()}");
    return await flutterLocalNotificationsPlugin.getActiveNotifications();
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails('clearCare', 'clearCareNotification',
            importance: Importance.max);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    return flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics);
  }

  static Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
