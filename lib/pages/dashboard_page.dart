import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'home_page.dart'; // For the Task model

class DashboardPage extends StatelessWidget {
  final List<Task> tasks;

  const DashboardPage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    

    // 1. Build dataMap for Category Breakdown (left chart)
    final Map<String, double> categoryMap = {};
    for (final task in tasks) {
      final category = task.category;
      categoryMap[category] = (categoryMap[category] ?? 0) + 1;
    }

    // 2. Build dataMap for Completion Breakdown (right chart)
    final int totalTasks = tasks.length;
    final int completedTasks = tasks.where((t) => t.isCompleted).length;
    final int incompleteTasks = totalTasks - completedTasks;

    final Map<String, double> completionMap = {
      'Completed': completedTasks.toDouble(),
      'Incomplete': incompleteTasks.toDouble(),
    };

    // 3. Handle empty tasks
    if (tasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Dashboard'),
          
          backgroundColor: const Color.fromARGB(255, 33, 122, 166),
        ),
        body: const Center(
          child: Text('No tasks available for chart'),
        ),
      );
    }

    // Original Category Chart (Left)
    final categoryChart = PieChart(
      dataMap: categoryMap,
      chartType: ChartType.ring,
      chartRadius: MediaQuery.of(context).size.width / 2.2,
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

    // Completion Chart (Right) - Completed vs. Incomplete
    final completionChart = PieChart(
      dataMap: completionMap,
      chartType: ChartType.disc, // or ring, up to you
      chartRadius: MediaQuery.of(context).size.width / 2.2,
      colorList: const [Colors.green, Colors.grey],
      legendOptions: const LegendOptions(
        legendPosition: LegendPosition.bottom,
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
        showChartValuesOutside: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard'),
        
        backgroundColor: const Color.fromARGB(255, 33, 122, 166),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Chart (Category Breakdown)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: categoryChart,
              ),
              // Right Chart (Completion Breakdown)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: completionChart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
