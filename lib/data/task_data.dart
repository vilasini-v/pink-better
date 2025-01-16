import 'package:flutter/material.dart';
import 'package:newpapp/data/hive_db.dart';
import 'package:newpapp/date_time/date_time_helper.dart';
import 'package:newpapp/model/task.dart';

class TaskData extends ChangeNotifier {
  List<Task> weeklyTasks = [];
  final db = HiveDb();

  // Get all tasks for the week
  List<Task> getWeeklyTasks() {
    return weeklyTasks;
  }

  // Prepare data by fetching from Hive
  void prepareData() {
    try {
      List<Task> tasksFromDb = db.getTasks();
      print("Tasks from DB: ${tasksFromDb.length}");

      if (tasksFromDb.isNotEmpty) {
        DateTime weekStart = startOfWeekDate();
        DateTime weekEnd = weekStart.add(Duration(days: 7));

        print("Week range: $weekStart to $weekEnd");

        weeklyTasks = tasksFromDb.where((task) {
          bool isInRange = task.date.isAfter(weekStart.subtract(Duration(days: 1)));
          print("Task date: ${task.date}, in range: $isInRange");
          return isInRange;
        }).toList();

        print("Filtered tasks: ${weeklyTasks.length}");
        notifyListeners();
      }
    } catch (e) {
      print("Error preparing task data: $e");
    }
  }

  // Add a new task
  Future<void> addNewTask(Task newTask) async {
    try {
      await db.addTask(newTask);
      weeklyTasks.add(newTask);
      notifyListeners();
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  // Delete a task
  Future<void> deleteTask(Task taskToDelete) async {
    try {
      await db.deleteTask(taskToDelete.id);
      weeklyTasks.removeWhere((task) => task.id == taskToDelete.id);
      notifyListeners();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  // Rest of your methods remain unchanged...
  DateTime startOfWeekDate() {
    DateTime today = DateTime.now();
    int daysToSubtract = today.weekday % 7;
    return today.subtract(Duration(days: daysToSubtract));
  }

  String getDayName(DateTime datetime) {
    switch (datetime.weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
    }
  }

  Map<String, int> calculateDailyTaskSummary() {
    Map<String, int> dailyTaskSummary = {};

    DateTime weekStart = startOfWeekDate();
    for (int i = 0; i < 7; i++) {
      DateTime currentDate = weekStart.add(Duration(days: i));
      String dateString = convertDateTimetoString(currentDate);
      dailyTaskSummary[dateString] = 0;
    }

    for (var task in weeklyTasks) {
      String date = convertDateTimetoString(task.date);
      dailyTaskSummary.update(date, (value) => value + 1, ifAbsent: () => 1);
    }

    return dailyTaskSummary;
  }

  List<Task> getTasksForDay(DateTime date) {
    return weeklyTasks.where((task) =>
        task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day
    ).toList();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      int index = weeklyTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        Task task = weeklyTasks[index];
        Task updatedTask = Task(
          id: task.id,
          title: task.title,
          priority: task.priority,
          isCompleted: !task.isCompleted,
          date: task.date,
        );

        await db.updateTask(updatedTask);
        weeklyTasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      print("Error toggling task completion: $e");
    }
  }

  Map<String, int> getWeeklyStatistics() {
    int total = weeklyTasks.length;
    int completed = weeklyTasks.where((task) => task.isCompleted).length;

    return {
      'total': total,
      'completed': completed,
      'remaining': total - completed,
    };
  }

  Map<String, List<Task>> getTasksByPriority() {
    return {
      'high': weeklyTasks.where((task) => task.priority == Priority.high).toList(),
      'medium': weeklyTasks.where((task) => task.priority == Priority.medium).toList(),
      'low': weeklyTasks.where((task) => task.priority == Priority.low).toList(),
    };
  }
}