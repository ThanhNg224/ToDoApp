import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'package:logger/logger.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Add a new task
  Future<void> addTask(Task task) async {
    await _db.collection('tasks').add({
      'title': task.title,
      'category': task.category,
      'isCompleted': task.isCompleted,
      'priority': task.priority,
    });
  }

   // ✅ Add debugging to check if Firestore has data
  Stream<List<Task>> getTasksStream() {
    return _db.collection('tasks').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        Logger().i("Firestore has NO TASKS!");
      } else {
        Logger().i("Firestore fetched ${snapshot.docs.length} tasks.");
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: doc.id, // Firestore document ID
          title: data['title'] ?? '',
          category: data['category'] ?? 'Misc',
          isCompleted: data['isCompleted'] ?? false,
          priority: data['priority'] ?? 'Low',
        );
      }).toList();
    });
  }

  // ✅ Update task completion status
  Future<void> updateTask(String taskId, bool isCompleted) async {
    await _db.collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
      
    });
  }

  // ✅ Delete a task
  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }




}
