import 'package:newpapp/model/note.dart';
import 'package:flutter/material.dart';
import 'package:newpapp/data/hive_db.dart';

class NotesData extends ChangeNotifier {
  List<NoteItem> allNotes = [];
  final db = HiveDb();
  bool isInitialized = false;

  // Initialize and prepare data
  Future<void> init() async {
    try {
      await prepareData();
      isInitialized = true;
      notifyListeners();
    } catch (e) {
      print("Error initializing NotesData: $e");
    }
  }

  List<NoteItem> getNotesInFolder(String folderId) {
    return db.getNotesInFolder(folderId);
  }

  // Add this if you need navigation path functionality
  List<NoteItem> getFolderPath(String folderId) {
    List<NoteItem> path = [];
    String? currentId = folderId;
    while (currentId != 'root' && currentId != null) {
      for (var note in allNotes) {
        if (note.isFolder && note.children.contains(currentId)) {
          path.insert(0, note);
          currentId = note.id;
          break;
        }
      }
      // Prevent infinite loop if folder structure is corrupted
      if (path.isEmpty || (path.isNotEmpty && path[0].id == currentId)) {
        break;
      }
    }
    return path;
  }

  // Fetch data from Hive
  Future<void> prepareData() async {
    try {
      allNotes = db.getNotes();
      notifyListeners();
    } catch (e) {
      print("Error preparing notes data: $e");
    }
  }

  // Add a new note or folder
  Future<void> addNewItem({
    required String title,
    required bool isFolder,
    required String parentFolderId,
    String? content,
  }) async {
    try {
      final newItem = NoteItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        isFolder: isFolder,
        content: content,
      );
      await db.addNote(newItem);
      allNotes.add(newItem);
      if (parentFolderId != 'root') {
        await db.addNoteToFolder(newItem.id, parentFolderId);
      }
      notifyListeners();
    } catch (e) {
      print("Error adding new note item: $e");
    }
  }

  // Update a note's content
  Future<void> updateNoteContent(String noteId, String content) async {
    try {
      final note = getItemById(noteId);
      if (note != null) {
        note.content = content;
        await db.updateNote(note);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating note content: $e");
    }
  }

  // Get item by ID
  NoteItem? getItemById(String id) {
    return db.getNoteById(id);
  }

  // Delete an item (note or folder)
  Future<void> deleteItem(String itemId) async {
    try {
      final item = getItemById(itemId);
      if (item == null) return;

      if (item.isFolder) {
        // If it's a folder, recursively delete all contents
        await _deleteFolderContents(itemId);
      }

      // Remove the item from its parent folder
      final parentFolder = _findParentFolder(itemId);
      if (parentFolder != null) {
        parentFolder.children.remove(itemId);
        await db.updateNote(parentFolder);
      }

      // Delete the item itself from Hive
      await db.deleteNote(itemId);
      
      // Remove from allNotes list
      allNotes.removeWhere((note) => note.id == itemId);
      
      notifyListeners();
    } catch (e) {
      print("Error deleting item: $e");
      rethrow;
    }
  }

  // Helper method to recursively delete folder contents
  Future<void> _deleteFolderContents(String folderId) async {
    try {
      final contents = getNotesInFolder(folderId);
      for (var item in contents) {
        if (item.isFolder) {
          // Recursively delete subfolder contents
          await _deleteFolderContents(item.id);
        }
        // Delete the item from Hive
        await db.deleteNote(item.id);
        // Remove from allNotes list
        allNotes.removeWhere((note) => note.id == item.id);
      }
    } catch (e) {
      print("Error deleting folder contents: $e");
      rethrow;
    }
  }

  // Helper method to find parent folder of an item
  NoteItem? _findParentFolder(String itemId) {
    for (var note in allNotes) {
      if (note.isFolder && note.children.contains(itemId)) {
        return note;
      }
    }
    return null;
  }
}