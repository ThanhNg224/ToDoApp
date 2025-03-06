// lib/models/task_model.dart
class Task {
  final String id;
  final String title;
  final String category;
  final bool isCompleted;
  final String priority;
  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.priority,
  });

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? 'Misc',
      isCompleted: data['isCompleted'] ?? false,
      priority: data['priority'] ?? 'Low',
    );
  }
}