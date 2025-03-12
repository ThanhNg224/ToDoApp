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
  
  // Log message (this won't show anything to the user when app is terminated)
  var logger = Logger();
  logger.i('Background message received: ${message.notification?.title}');
  
  // Actually show the notification to the user
  if (message.notification != null) {
    NotificationService.showNotification(
      title: message.notification!.title ?? 'New Message',
      body: message.notification!.body ?? '',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // 2. Register background handler BEFORE any other Firebase Messaging operations
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // 3. Initialize notification services
  await NotificationService.instance.requestPermission();
  await NotificationService.instance.setupFlutterNotifications();
  NotificationService.instance.handleBackgroundMessages();
  
  // 4. Initialize Firebase API (move this after background handler registration)
  await FirebaseApi().initNotifications();

  // 5. Run the app
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