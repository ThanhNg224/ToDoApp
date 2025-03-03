import 'package:flutter/material.dart';


void main() {
  runApp(const NewPage());
}

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Testing'),
          backgroundColor: const Color.fromARGB(255, 33, 122, 166),

        ),
        body: const Center(
          child: Text('just a testing app'),
        ),
      ),
    );
  }
}
