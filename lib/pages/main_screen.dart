import 'package:flutter/material.dart';
import 'home_page.dart';
import 'dashboard_page.dart';
import 'new_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Shared tasks so both HomePage & DashboardPage see the same list
  final List<Task> tasks = [
    Task(title: 'Buy groceries', category: 'Chores'),
    Task(title: 'Walk the dog', category: 'Chores'),
    Task(title: 'Complete Flutter project', category: 'Work'),
    Task(title: 'Watch Netflix', category: 'Entertainment'),
    Task(title: 'Read a book', category: 'Leisure'),
    Task(title: 'Exercise for 30 minutes', category: 'Health'),
    Task(title: 'Call a friend', category: 'Social'),
    Task(title: 'Plan a trip', category: 'Travel'),
    Task(title: "siuuuu", category: 'Work'),
  ];

  int _selectedIndex = 0;

  // 1. HomePage: stable key => keeps state when switching away

  // 2. DashboardPage: unique key => forces a rebuild each time we switch to it
  Widget get _dashboardPage => KeyedSubtree(
    key: UniqueKey(),
    child: DashboardPage(tasks: tasks),
  );

  // 3. NewPage: stable key => keeps state
  Widget get _newPage => const KeyedSubtree(
    key: ValueKey('NewPage'),
    child: NewPage(),
  );

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // We'll build these children dynamically so we can control keys:
    final pages = [
      // Provide the real HomePage here with a stable key
      KeyedSubtree(
        key: const ValueKey('HomePage'),
        child: HomePage(tasks: tasks),
      ),
      // Force a rebuild of Dashboard each time with a UniqueKey
      _dashboardPage,
      // Keep NewPage stable
      _newPage,
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            label: 'New Page',
          ),
        ],
      ),
    );
  }
}
