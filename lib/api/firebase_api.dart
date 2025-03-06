import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/notification_service.dart';

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
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new task
  Future<void> addTask(String title, String category, bool isCompleted, String priority) async {
    await _db.collection('tasks').add({
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
      'priority': priority,
    });
  }

  // Update a task
  Future<void> updateTask(String docId, bool isCompleted) async {
    await _db.collection('tasks').doc(docId).update({
      'isCompleted': isCompleted,
    });
  }

  // Delete a task
  Future<void> deleteTask(String docId) async {
    await _db.collection('tasks').doc(docId).delete();
  }

  // Stream all tasks
  Stream<List<Map<String, dynamic>>> getTasksStream() {
    return _db.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Attach the docId so we can update/delete easily
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
