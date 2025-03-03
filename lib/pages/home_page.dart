import 'package:flutter/material.dart';

// Model to hold task data, with category
class Task {
  final String title;
  final String category;
  bool isCompleted;

  Task({
    required this.title,
    required this.category,
    this.isCompleted = false,
  });
}

class HomePage extends StatefulWidget {
  final List<Task> tasks; // Use the parent's tasks

  const HomePage({super.key, required this.tasks});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Predefined category options for the dropdown
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

  // Controllers for adding a new task title and searching
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Track the selected category in the dialog
  String? _selectedCategory;

  // Current text in the search bar
  String _searchQuery = '';

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter tasks based on the search query (checks both title & category)
  List<Task> get _filteredTasks {
    if (_searchQuery.isEmpty) {
      return widget.tasks; // Use widget.tasks (the parent's list)
    }

    final query = _searchQuery.toLowerCase();
    return widget.tasks.where((task) {
      return task.title.toLowerCase().contains(query) ||
          task.category.toLowerCase().contains(query);
    }).toList();
  }

  // Update search query as user types
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Add a new task (Debug Print)
  void _addTask(String title, String category) {
    setState(() {
      widget.tasks.add(Task(title: title, category: category));
      // Debug Print: Show updated list in console
      
    });
  }

  // Toggle completion status of a task
  void _toggleComplete(int index, bool? value) {
    final task = _filteredTasks[index];
    setState(() {
      task.isCompleted = value ?? false;
    });
  }

  // Delete a task with "Undo" option (Debug Print)
  void _deleteTask(int index) {
    final removedTask = _filteredTasks[index];
    final actualIndex = widget.tasks.indexOf(removedTask);

    setState(() {
      widget.tasks.removeAt(actualIndex);
      // Debug Print: Show updated list in console
      
    });

    // Show a SnackBar with "Undo" button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${removedTask.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              widget.tasks.insert(actualIndex, removedTask);
              // Debug Print: Show updated list after Undo
              
            });
          },
        ),
      ),
    );
  }

  // Show dialog to add a new task, with a dropdown for category
  void _showAddTaskDialog(BuildContext context) {
    // Reset controllers and selected category each time the dialog opens
    _taskController.clear();
    _selectedCategory = null;

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
                    // Task Title
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        hintText: 'Enter task name',
                        labelText: 'Task Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown for category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory, // can be null
                      hint: const Text('Select a category'),
                      items: _categoryOptions.map((String cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setStateDialog(() {
                          _selectedCategory = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final title = _taskController.text.trim();
                    // Default to 'Misc' if user didn't pick a category
                    final category = _selectedCategory ?? 'Misc';

                    if (title.isNotEmpty) {
                      _addTask(title, category);
                    }
                    Navigator.of(dialogContext).pop();
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

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do App'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 33, 122, 166),
        // Search bar under the AppBar
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

      // Show a message if no tasks match the search
      body: filteredTasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks found.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Card(
                  color: const Color.fromARGB(255, 84, 176, 241),
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
                            ? Colors.grey
                            : const Color.fromARGB(255, 54, 72, 10),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      'Category: ${task.category}',
                      style: TextStyle(
                        color: task.isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) => _toggleComplete(index, value),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 33, 122, 166),
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
