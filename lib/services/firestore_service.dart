import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

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
  Stream<List<Task>> getTasksStream() {
    return _db.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          category: data['category'] ?? 'Misc',
          isCompleted: data['isCompleted'] ?? false,
          priority: data['priority'] ?? 'Medium',
        );
      }).toList();
    });
  }

  // Stream only high-priority tasks (Optional)
  Stream<List<Task>> getHighPriorityTasksStream() {
    return _db.collection('tasks')
        .where('priority', isEqualTo: 'High')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }
}
