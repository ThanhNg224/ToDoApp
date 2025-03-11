import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService instance = NotificationService._internal();
  
  // Factory constructor to return the singleton instance
  factory NotificationService() => instance;
  
  // Private constructor for singleton
  NotificationService._internal();
  
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel constants
  static const String channelId = "high_importance_channel";
  static const String channelName = "High Importance Notifications";
  static const String channelDescription = "Used for heads-up notifications";

  // Request notification permission
  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Setup Flutter notifications
  Future<void> setupFlutterNotifications() async {
    await initialize();
  }

  // Handle background messages
  void handleBackgroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          title: message.notification?.title ?? 'New Notification',
          body: message.notification?.body ?? '',
        );
      }
    });
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max, // Ensures heads-up notification
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,    // For Android 8.0+ (channel-based)
      priority: Priority.high,       // For Android < 8.0
      playSound: true,
      channelShowBadge: true,
      enableVibration: true,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      0,      // notification id
      title,  // notification title
      body,   // notification body
      notificationDetails,
    );
  }
}