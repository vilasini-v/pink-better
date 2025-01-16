import 'package:hive/hive.dart';
import '../model/task.dart';
import '../model/note.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDb {
  // Box names
  static const String tasksBox = 'tasks';
  static const String notesBox = 'notes';
  // Singleton instance
  static final HiveDb _instance = HiveDb._internal();
  
  // Factory constructor
  factory HiveDb() {
    return _instance;
  }
  
  // Private constructor
  HiveDb._internal();

  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.openBox<Map>(tasksBox);
    await Hive.openBox<Map>(notesBox);
  }

  // Get box references
  Box<Map> get _tasksBox => Hive.box<Map>(tasksBox);
  Box<Map> get _notesBox => Hive.box<Map>(notesBox);
  //notes related tasks
  Future<void> addNote(NoteItem note) async {
    try {
      await _notesBox.put(note.id, note.toMap());
      print("Note added successfully!");
    } catch (e) {
      print("Error adding note: $e");
      throw e;
    }
  }

  Future<void> updateNote(NoteItem note) async {
    try {
      await _notesBox.put(note.id, note.toMap());
      print("Note updated successfully!");
    } catch (e) {
      print("Error updating note: $e");
      throw e;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _notesBox.delete(id);
      print("Note deleted successfully!");
    } catch (e) {
      print("Error deleting note: $e");
      throw e;
    }
  }

  List<NoteItem> getNotes() {
    try {
      return _notesBox.values.map((data) {
        return NoteItem.fromMap(Map<String, dynamic>.from(data));
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print("Error getting notes: $e");
      return [];
    }
  }

  NoteItem? getNoteById(String id) {
    try {
      final data = _notesBox.get(id);
      if (data != null) {
        return NoteItem.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      print("Error getting note by ID: $e");
      return null;
    }
  }

  List<NoteItem> getNotesInFolder(String folderId) {
    try {
      if (folderId == 'root') {
        // Get items that aren't children of any other folder
        final allNotes = getNotes();
        final allChildren = allNotes
            .where((item) => item.isFolder)
            .expand((folder) => folder.children)
            .toSet();
        
        return allNotes
            .where((item) => !allChildren.contains(item.id))
            .toList();
      } else {
        final folder = getNoteById(folderId);
        if (folder != null && folder.children.isNotEmpty) {
          return folder.children
              .map((id) => getNoteById(id))
              .whereType<NoteItem>()
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error getting notes in folder: $e");
      return [];
    }
  }

  Future<void> addNoteToFolder(String noteId, String folderId) async {
    try {
      final folder = getNoteById(folderId);
      if (folder != null && folder.isFolder) {
        folder.children.add(noteId);
        await updateNote(folder);
        print("Note added to folder successfully!");
      }
    } catch (e) {
      print("Error adding note to folder: $e");
      throw e;
    }
  }

  Future<void> removeNoteFromFolder(String noteId, String folderId) async {
    try {
      final folder = getNoteById(folderId);
      if (folder != null && folder.isFolder) {
        folder.children.remove(noteId);
        await updateNote(folder);
        print("Note removed from folder successfully!");
      }
    } catch (e) {
      print("Error removing note from folder: $e");
      throw e;
    }
  }

  Future<void> deleteNoteRecursively(String id) async {
    try {
      final note = getNoteById(id);
      if (note != null) {
        if (note.isFolder) {
          // Delete all children first
          for (String childId in note.children) {
            await deleteNoteRecursively(childId);
          }
        }
        // Delete the note/folder itself
        await deleteNote(id);
        print("Note and its contents deleted successfully!");
      }
    } catch (e) {
      print("Error deleting note recursively: $e");
      throw e;
    }
  }

  List<NoteItem> searchNotes(String query) {
    try {
      return getNotes().where((note) {
        return note.title.toLowerCase().contains(query.toLowerCase()) ||
               (note.content?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      print("Error searching notes: $e");
      return [];
    }
  }
  // Task-related functions
  Future<void> addTask(Task task) async {
    try {
      await _tasksBox.put(task.id, task.toMap());
      print("Task added successfully!");
    } catch (e) {
      print("Error adding task: $e");
      throw e;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _tasksBox.put(task.id, task.toMap());
      print("Task updated successfully!");
    } catch (e) {
      print("Error updating task: $e");
      throw e;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _tasksBox.delete(id);
      print("Task deleted successfully!");
    } catch (e) {
      print("Error deleting task: $e");
      throw e;
    }
  }

  List<Task> getTasks() {
    try {
      return _tasksBox.values.map((data) {
        return Task(
          id: data['id'],
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
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print("Error getting tasks: $e");
      return [];
    }
  }

  Task? getTaskById(String id) {
    try {
      final data = _tasksBox.get(id);
      if (data != null) {
        return Task(
          id: data['id'],
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

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    try {
      final task = getTaskById(id);
      if (task != null) {
        task.isCompleted = isCompleted;
        await updateTask(task);
        print("Task completion toggled successfully!");
      }
    } catch (e) {
      print("Error toggling task completion: $e");
      throw e;
    }
  }

  List<Task> getTasksByCompletion(bool isCompleted) {
    try {
      return _tasksBox.values
          .where((data) => data['isCompleted'] == isCompleted)
          .map((data) {
        return Task(
          id: data['id'],
          title: data['title'] ?? '',
          priority: data['priority'] ?? 'low',
          isCompleted: data['isCompleted'] ?? false,
          date: data['date'] != null
              ? DateTime.parse(data['date'])
              : DateTime.now(),
        );
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print("Error getting tasks by completion: $e");
      return [];
    }
  }
}