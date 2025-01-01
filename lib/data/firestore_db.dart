import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/hair.dart';
import '../model/task.dart';

class FirestoreDb {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _logsCollection = FirebaseFirestore.instance.collection("expense_logs");
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  // Task-related functions
  Future<void> addTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).set(task.toMap());
      print("Task added successfully!");
    } catch (e) {
      print("Error adding task: $e");
      throw e;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toMap());
      print("Task updated successfully!");
    } catch (e) {
      print("Error updating task: $e");
      throw e;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
      print("Task deleted successfully!");
    } catch (e) {
      print("Error deleting task: $e");
      throw e;
    }
  }

  // Get all tasks as a Stream (real-time updates)
  Stream<List<Task>> getTasksStream() {
    return _tasksCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          priority: Priority.values.firstWhere(
                  (e) => e.toString().split('.').last == data['priority'],
              orElse: () => Priority.medium
          ),
          isCompleted: data['isCompleted'] ?? false,
          date: data['date'] != null
              ? DateTime.parse(data['date'])
              : DateTime.now(),
        );
      }).toList();
    });
  }

  // Get all tasks as a Future (one-time read)
  Future<List<Task>> getTasks() async {
    try {
      QuerySnapshot querySnapshot = await _tasksCollection
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          priority: Priority.values.firstWhere(
                  (e) => e.toString().split('.').last == data['priority'],
              orElse: () => Priority.medium
          ),
          isCompleted: data['isCompleted'] ?? false,
          date: data['date'] != null
              ? DateTime.parse(data['date'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print("Error getting tasks: $e");
      return [];
    }
  }

  // Get a single task by ID
  Future<Task?> getTaskById(String id) async {
    try {
      DocumentSnapshot doc = await _tasksCollection.doc(id).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          priority: Priority.values.firstWhere(
                  (e) => e.toString().split('.').last == data['priority'],
              orElse: () => Priority.medium
          ),
          isCompleted: data['isCompleted'] ?? false,
          date: data['date'] != null
              ? DateTime.parse(data['date'])
              : DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print("Error getting task by ID: $e");
      return null;
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    try {
      await _tasksCollection.doc(id).update({'isCompleted': isCompleted});
      print("Task completion toggled successfully!");
    } catch (e) {
      print("Error toggling task completion: $e");
      throw e;
    }
  }

  // Get tasks filtered by completion status
  Future<List<Task>> getTasksByCompletion(bool isCompleted) async {
    try {
      QuerySnapshot querySnapshot = await _tasksCollection
          .where('isCompleted', isEqualTo: isCompleted)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          priority: data['priority'] ?? 'low',
          isCompleted: data['isCompleted'] ?? false,
          date: data['date'] != null
              ? DateTime.parse(data['date'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print("Error getting tasks by completion: $e");
      return [];
    }
  }

// Rest of your existing code for Hair-related functions...

  // Save data
  Future<void> saveData(List<Hair> allLogs) async {
    List<Map<String, dynamic>> logsFormatted = allLogs.map((log) {
      return {
        "amount": log.amount,
        "note": log.note,
        "date": log.date.toIso8601String(),
      };
    }).toList();

    try {
      WriteBatch batch = _firestore.batch();
      for (var log in logsFormatted) {
        var docRef = _logsCollection.doc(); // Automatically generates a unique ID
        batch.set(docRef, log);
      }
      await batch.commit();
      print("Data saved successfully!");
    } catch (e) {
      print("Error saving data: $e");
    }
  }
  Future<void> cleanupOldLogs() async {
  try {
    final DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    QuerySnapshot querySnapshot = await _logsCollection
        .where("date", isLessThan: oneWeekAgo.toIso8601String())
        .get();

    WriteBatch batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    print("Old logs cleaned up successfully!");
  } catch (e) {
    print("Error cleaning up old logs: $e");
  }
}

  Future<void> deleteData(Hair hairToDelete) async {
  try {
    // Query the Firestore collection to find the matching document
    QuerySnapshot querySnapshot = await _logsCollection
        .where('amount', isEqualTo: hairToDelete.amount)
        .where('note', isEqualTo: hairToDelete.note)
        .where('date', isEqualTo: hairToDelete.date.toIso8601String())
        .get();

    // Check if a matching document was found
    if (querySnapshot.docs.isNotEmpty) {
      // Delete the first matching document (assuming unique entries)
      await querySnapshot.docs.first.reference.delete();
      print("Log deleted successfully!");
    } else {
      print("No matching log found to delete.");
    }
  } catch (e) {
    print("Error deleting log: $e");
  }
}

  // Read data
  Future<List<Hair>> readData() async {
    try {
      QuerySnapshot querySnapshot = await _logsCollection.get();
      List<Hair> allLogs = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Hair(
          amount: data["amount"],
          note: data["note"],
          date: DateTime.parse(data["date"]),
        );
      }).toList();

      return allLogs;
    } catch (e) {
      print("Error reading data: $e");
      return [];
    }
  }
}
