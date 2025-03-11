import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'pages/main_screen.dart';
import 'api/firebase_api.dart';


// Handles incoming FCM messages when the app is completely terminated.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // You must call initializeApp again here if the app is not already running.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var logger = Logger();
  logger.i('Background message received: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();

  // 2. Set up background message handling
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Initialize local notifications & request notification permission
  await NotificationService.instance.requestPermission();
  await NotificationService.instance.setupFlutterNotifications();
  NotificationService.instance.handleBackgroundMessages();

  // 4. Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}
