import 'package:flutter/material.dart';
import 'home_page.dart';
import 'dashboard_page.dart';
import 'setting_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  Widget get _dashboardPage => KeyedSubtree(
        key: UniqueKey(),
        child: DashboardPage(),
      );

  Widget get _newPage => const KeyedSubtree(
        key: ValueKey('Setting'),
        child: Setting(),
      );

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // No more StreamBuilder here. HomePage does its own Firestore streaming.
      const KeyedSubtree(
        key: ValueKey('HomePage'),
        child: HomePage(),
      ),
      _dashboardPage,
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
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
