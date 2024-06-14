import 'package:clubconnect/config/router/app_router.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/services/firebase.dart';
import 'package:clubconnect/services/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  await LocalNotification.initializeLocalNotification();
  //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgrounHandler);

  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: MainApp()));
}

Future<void> _initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

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
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
