import 'package:flutter/material.dart';
import 'pages/main_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // <-- Initialize Firebase here
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // A helper method to access _MyAppState from other pages
  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool isDark = false; // Global dark mode flag

  // This method toggles dark mode
  void toggleDarkMode(bool value) {
    setState(() {
      isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Dark Mode Demo',

      // Provide both light and dark themes
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      // themeMode chooses which theme to use
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      home: const MainScreen(), 
    );
  }
}