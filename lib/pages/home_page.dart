import 'package:flutter/material.dart';
import '../api/firebase_api.dart';
import '../models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  // Category & Priority options
  final List<String> _categoryOptions = [
    'Chores',
    'Work',
    'Entertainment',
    'Leisure',
    'Health',
    'Social',
    'Travel',
    'Misc',
  ];
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  // Priority numeric order for sorting
  final Map<String, int> priorityOrder = {
    'High': 3,
    'Medium': 2,
    'Low': 1,
  };

  // Controllers & selection states
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPriority;
  String _searchQuery = '';

  // Whether we're sorting by priority
  bool _sortByPriority = false;

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Toggle sorting
  void _toggleSortByPriority() {
    setState(() {
      _sortByPriority = !_sortByPriority;
    });
  }

  // Update search query as user types
  void _updateSearchQuery(String query) {
    setState(() => _searchQuery = query);
  }

  // Show dialog to add a new task
  void _showAddTaskDialog(BuildContext context) {
    _taskController.clear();
    _selectedCategory = null;
    _selectedPriority = null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        hintText: 'Enter task name',
                        labelText: 'Task Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: const Text('Select a category'),
                      items: _categoryOptions.map((String cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setStateDialog(() => _selectedCategory = newValue);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Priority Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      hint: const Text('Select priority'),
                      items: _priorityOptions.map((String p) {
                        return DropdownMenuItem<String>(
                          value: p,
                          child: Text(p),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setStateDialog(() => _selectedPriority = newValue);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final title = _taskController.text.trim();
                    final category = _selectedCategory ?? 'Misc';
                    final priority = _selectedPriority ?? 'Low';

                    if (title.isNotEmpty) {
                      // Firestore: addTask(title, category, false, priority)
                      await _firestoreService.addTask(
                        title,
                        category,
                        false,
                        priority,
                      );
                    }
                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Toggle completion status
  Future<void> _toggleComplete(Task task, bool? value) async {
    await _firestoreService.updateTask(task.id, value ?? false);
  }

  // Delete a task
  Future<void> _deleteTask(Task task) async {
    await _firestoreService.deleteTask(task.id);
  }

  // Get card color based on priority
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      default:
        return Colors.greenAccent; // 'Low'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do App'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 33, 122, 166),
        actions: [
          // Sort button
          IconButton(
            icon: Icon(_sortByPriority ? Icons.sort_by_alpha : Icons.sort),
            onPressed: _toggleSortByPriority,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search tasks or categories...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 164, 211, 235),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 33, 122, 166),
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),

      // Real-time stream of tasks from Firestore
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tasks found.', style: TextStyle(fontSize: 18)),
            );
          }

          // Convert Firestore docs into Task objects
          final allTasks = snapshot.data!
              .map((docData) => Task.fromMap(docData))
              .toList();

          // Filter tasks by search query
          final filteredTasks = allTasks.where((task) {
            final query = _searchQuery.toLowerCase();
            return task.title.toLowerCase().contains(query) ||
                task.category.toLowerCase().contains(query);
          }).toList();

          if (filteredTasks.isEmpty) {
            return const Center(
              child: Text('No tasks found for your search.'),
            );
          }

          // Sort by priority if toggled
          if (_sortByPriority) {
            filteredTasks.sort((a, b) {
              final aVal = priorityOrder[a.priority] ?? 1;
              final bVal = priorityOrder[b.priority] ?? 1;
              // Descending order: High (3) > Medium (2) > Low (1)
              return bVal.compareTo(aVal);
            });
          }

          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Card(
                // Color-coded by priority
                color: _getPriorityColor(task.priority),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: task.isCompleted
                          ? Colors.grey[800]
                          : Colors.black,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    'Category: ${task.category} | Priority: ${task.priority}',
                    style: TextStyle(
                      color: task.isCompleted ? Colors.grey[700] : Colors.black87,
                    ),
                  ),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) => _toggleComplete(task, value),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(task),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
