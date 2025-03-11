import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:pie_chart/pie_chart.dart';
import '../api/firebase_api.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No tasks available for chart'),
            ),
          );
        }

        // Convert docs to Task objects
        final tasks = snapshot.data!
            .map((docData) => Task.fromMap(docData))
            .toList();

        // Build data for Category Breakdown
        final Map<String, double> categoryMap = {};
        for (final task in tasks) {
          categoryMap[task.category] = (categoryMap[task.category] ?? 0) + 1;
        }

        // Build data for Completion Breakdown
        final int totalTasks = tasks.length;
        final int completedTasks = tasks.where((t) => t.isCompleted).length;
        final int incompleteTasks = totalTasks - completedTasks;

        final Map<String, double> completionMap = {
          'Completed': completedTasks.toDouble(),
          'Incomplete': incompleteTasks.toDouble(),
        };

        // Build the two charts side by side
        final categoryChart = PieChart(
          dataMap: categoryMap,
          chartType: ChartType.ring,
          chartRadius: MediaQuery.of(context).size.width / 2.5,
          colorList: const [
            Colors.blue,
            Colors.orange,
            Colors.purple,
            Colors.green,
            Colors.red,
            Colors.cyan,
            Colors.yellow,
            Colors.brown,
          ],
          ringStrokeWidth: 32,
          legendOptions: const LegendOptions(
            legendPosition: LegendPosition.bottom,
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValuesInPercentage: true,
            showChartValuesOutside: true,
          ),
        );

        final completionChart = PieChart(
          dataMap: completionMap,
          chartType: ChartType.disc,
          chartRadius: MediaQuery.of(context).size.width / 2.5,
          colorList: const [Colors.green, Colors.grey],
          legendOptions: const LegendOptions(
            legendPosition: LegendPosition.bottom,
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValuesInPercentage: true,
            showChartValuesOutside: true,
          ),
        );

        // Use the integrated layout
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 122, 166),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: categoryChart),
                const SizedBox(width: 16),
                Expanded(child: completionChart),
              ],
            ),
          ),
        );
      },
    );
  }
}