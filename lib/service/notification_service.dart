import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel constants
  static const String channelId = "high_importance_channel";
  static const String channelName = "High Importance Notifications";
  static const String channelDescription = "Used for heads-up notifications";

  static Future<void> initialize() async {
    // iOS initialization settings (if you support iOS)
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combine platform settings
    const InitializationSettings initSettings = InitializationSettings(
      iOS: iosSettings,
      android: androidSettings,
    );

    // Initialize the plugin
    await _plugin.initialize(initSettings);

    // For Android 8.0+ (API 26+), create a notification channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max, // High importance => heads-up
      );

      // Register the channel with the system
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
    // For Android < 8.0, priority matters for heads-up
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,    // For Android 8.0+ (channel-based)
      priority: Priority.high,       // For Android < 8.0
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(), // if iOS needed
    );

    await _plugin.show(
      0,      // notification id
      title,  // notification title
      body,   // notification body
      notificationDetails,
    );
  }
}
