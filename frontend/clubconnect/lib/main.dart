import 'package:clubconnect/config/router/app_router.dart';
import 'dart:io' show Platform;

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clubconnect/services/firebase.dart';
import 'package:clubconnect/services/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

void main() async {
  await dotenv.load(fileName: '.env');

  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();

  await LocalNotification.initializeLocalNotification();
  //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgrounHandler);

  runApp(const ProviderScope(child: MainApp()));
}

Future<void> _initializeFirebase() async {
  if (Platform.isAndroid) {
    // Si la plataforma es Android
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } else if (Platform.isIOS) {
    // Si la plataforma es iOS
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: dotenv.env["apiKey"]!,
              appId: dotenv.env["appId"]!,
              messagingSenderId: dotenv.env["messagingSenderId"]!,
              projectId: dotenv.env["projectId"]!));
    }
  }
}

/*Future<void> _initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: dotenv.env["apiKey"]!,
            appId: dotenv.env["appId"]!,
            messagingSenderId: dotenv.env["messagingSenderId"]!,
            projectId: dotenv.env["projectId"]!));
  }
}*/

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});
  @override
  MainAppState createState() => MainAppState();
}

@override
class MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    NotificationFirebase().initNotification(ref);
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'es_ES';

    return MaterialApp.router(
      routerConfig: appRouter,
      locale: Locale('es'), // Cambia 'es' por el código del idioma deseado
      supportedLocales: [
        Locale('en'), // Inglés
        Locale('es'), // Español
        // Agrega otros idiomas si es necesario
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
