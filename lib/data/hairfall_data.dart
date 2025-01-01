import 'package:flutter/material.dart';
import 'package:newpapp/data/firestore_db.dart';
import 'package:newpapp/date_time/date_time_helper.dart';
import 'package:newpapp/model/hair.dart';

class HairfallData extends ChangeNotifier {
  List<Hair> overallHairfallSummary = [];
  final db = FirestoreDb(); // Firestore database instance

  // Retrieve daily logs
  List<Hair> getDailyLogs() {
    return overallHairfallSummary;
  }
  
  // Prepare data by fetching it from Firestore
  Future<void> prepareData() async {
    List<Hair> logsFromDb = await db.readData();
    if (logsFromDb.isNotEmpty) {
      overallHairfallSummary = logsFromDb;
      notifyListeners();
    }
  }

  // Add a new log
  Future<void> addNewLog(Hair newHair) async {
    overallHairfallSummary.add(newHair);
    notifyListeners();
    await db.saveData(overallHairfallSummary);
  }
  Future<void> deleteLog(Hair hairToDelete) async {
  try {
    // Update the local list and notify listeners
    overallHairfallSummary.remove(hairToDelete);
    notifyListeners();

    // Delete from Firestore
    await db.deleteData(hairToDelete);
  } catch (e) {
    print("Error deleting log: $e");
  }
}

  // Get day name
  String getDayName(DateTime datetime) {
    switch (datetime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thurs';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  // Calculate the start of the week
  DateTime startOfWeekDate() {
    DateTime today = DateTime.now();
    int daysToSubtract = today.weekday % 7; // Subtract days to get to Sunday
    return today.subtract(Duration(days: daysToSubtract));
  }

  // Calculate daily hairfall summary
  Map<String, double> calculateDailyHairfallSummary() {
    Map<String, double> dailyHairfallSummary = {};
    for (var fall in overallHairfallSummary) {
      String date = convertDateTimetoString(fall.date);
      double amount = double.parse(fall.amount);

      if (dailyHairfallSummary.containsKey(date)) {
        double currentAmount = dailyHairfallSummary[date]!;
        currentAmount += amount;
        dailyHairfallSummary[date] = currentAmount;
      } else {
        dailyHairfallSummary[date] = amount;
      }
    }
    return dailyHairfallSummary;
  }
}
