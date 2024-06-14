import 'dart:math';

import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/services/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> firebaseMessagingBackgrounHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  Random random = Random();
  var id = random.nextInt(10000000);
  var msn = message.data;

  LocalNotification.showLocalNotification(
      id: id,
      title: message.notification?.title,
      body: message.notification?.body); //print(message.data.toString());
  //print(message.notification?.title);
}

class NotificationFirebase {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  void requestPermission(WidgetRef ref) async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    await LocalNotification.requestPermissionLocalNotification();
    settings.authorizationStatus;
    _getFCMToken(ref);
  }

  /*void initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound:
          true, // sound debe estar en true para recibir notificaciones con sonido
    );

    messaging.getInitialMessage().then((message) {
      if (message != null) {
        print("getInitialMessage");
        handleRemoteMessage(message);
      }
    });
    // Manejo de mensajes cuando la aplicación está en segundo plano y se toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen(backgroundHandler);

    // Manejo de mensajes cuando la aplicación está en primer plano
    FirebaseMessaging.onMessage.listen(backgroundHandler);

    // Manejo de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  }*/

  // Método para inicializar las notificaciones
  Future<void> initNotification(WidgetRef ref) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: false,
    );
    final settings = await messaging.getNotificationSettings();

    settings.authorizationStatus == AuthorizationStatus.authorized
        ? _getFCMToken(ref)
        : requestPermission(ref);

    messaging.getInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Handling a message opened app: ${message.messageId}");
      handleRemoteMessage(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Handling a message: ${message.messageId}");
      handleRemoteMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgrounHandler);

    //initPushNotification();

    //await initNotification(ref);

    //messaging.getToken().then((value) => print(value));
    //initPushNotification();
    //initLocation();
  }

  void _getFCMToken(WidgetRef ref) async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
    final token = await messaging.getToken();
    if (token != null) {
      ref.read(authProvider).saveTokenDispositivo(token);
      // Almacenar token en variables de estado
      print("FCM Token: $token");
      //await ref.read(authProvider).saveTokenDispositivo(token);
    }
  }

  void handleRemoteMessage(RemoteMessage message) {
    print("Handling a Remote message: ${message.messageId}");
    Random random = Random();
    var id = random.nextInt(10000000);
    var msn = message.data;
    print(message);
    print("date : ${message.data}");
    var body = msn['body'];
    var title = msn['title'];
    var route = message.data["route"];
    print("route : $route");
    LocalNotification.showLocalNotification(
        id: id,
        title: message.notification?.title,
        body: message.notification?.body,
        data: route.toString());
  }
}
