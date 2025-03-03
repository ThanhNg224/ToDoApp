import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import '../notification_service.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Request notification permissions.
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    var logger = Logger();
    logger.i("Notification permission status: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get and print the FCM token.
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        logger.i("FCM Token: $fcmToken");
      } else {
        logger.e("Failed to get FCM Token.");
      }
    } else {
      logger.w("User declined or has not accepted notification permissions.");
    }

    // Handle messages when the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i("Received a foreground message:");
      String title = message.notification?.title ?? 'No Title';
      String body = message.notification?.body ?? 'No Body';
      logger.i("Title: $title");
      logger.i("Body: $body");
      logger.i("Data: ${message.data}");
      logger.i("Data: ${message.data}");

      // Show a local notification.
      NotificationService.showNotification(title: title, body: body);
    });
  }
}
