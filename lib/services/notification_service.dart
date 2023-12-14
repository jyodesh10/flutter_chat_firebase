import 'dart:developer';

import 'package:firebase_chat_app/pages/auth/login.dart';
import 'package:firebase_chat_app/router/route_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
  goRouter.go(LoginPage.routename);
  log('notificaiton tapped');
}

class NotificationService {
  final fm = FirebaseMessaging.instance;
  String fireToken = '';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var androidPlatformChannelSpecifics =
      const AndroidNotificationDetails('channel_ID', 'channel name',
          channelDescription: 'channel description',
          importance: Importance.high,
          // sound: UriAndroidNotificationSound(_sound),
          playSound: true,
          showProgress: true,
          priority: Priority.high,
          ticker: 'test ticker');

  getFCMToken() async {
    final fcmToken = await fm.getToken();
    log("Token : $fcmToken");
    fireToken = fcmToken.toString();
    return fcmToken;
  }

  foregroundNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    FirebaseMessaging.onMessage.listen((event) {
      log(event.notification.toString());
      showNotification(event.notification!.title.toString(),
          event.notification!.body.toString());
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      log('message');

      event.data['content'] == 'login'
          ? goRouter.push(LoginPage.routename)
          : goRouter.push('/');

      fm.getInitialMessage();
    });
  }

  void showNotification(String title, String body) async {
    await _demoNotification(title, body);
  }

  Future<void> _demoNotification(String title, String body) async {
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

  scheduleNotificaton(title, body) async {
    tz.initializeTimeZones();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 2)),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }
}
