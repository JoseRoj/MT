import 'dart:convert';

import 'package:clubconnect/config/router/app_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LocalNotification {
  static Future<void> requestPermissionLocalNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: iosShowNotification,
    );

    const initialSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initialSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        //print("notificate : " + notificationResponse.payload!);
        appRouter.push(notificationResponse.payload!);
        //navigatorKey.currentState?.pushNamed('/home/0');
        print("Notification received");

//        navigatorKey.currentState?.pushNamed('/home/0');
        print("Notification received2");
        //showAlertDialog(notificationResponse.payload!);
      },
    );
  }

  static void iosShowNotification(
      int id, String? title, String? body, String? data) {
    showLocalNotification(id: id, title: title, body: body, data: data);
  }

  static void showLocalNotification(
      {required int id, String? title, String? body, String? data}) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'channelName',
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: data.toString(),
    );
  }
}
