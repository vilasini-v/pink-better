import 'package:flutter/material.dart';
import 'package:newpapp/pages/note_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:newpapp/data/notes_data.dart'; // Import your provider

class NotesScreen extends StatefulWidget {
  final String folderId;

  const NotesScreen({Key? key, required this.folderId}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the data is initialized
    Provider.of<NotesData>(context, listen: false).prepareData();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('New Folder'),
              onTap: () {
                Navigator.pop(context);
                _createNewItem(true);
              },
            ),
            ListTile(
              leading: Icon(Icons.note),
              title: Text('New Note'),
              onTap: () {
                Navigator.pop(context);
                _createNewItem(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createNewItem(bool isFolder) async {
    final TextEditingController textController = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFolder ? 'New Folder' : 'New Note'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Enter title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: Text('Create'),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      await Provider.of<NotesData>(context, listen: false).addNewItem(
        title: title,
        isFolder: isFolder,
        parentFolderId: widget.folderId,
      );
      setState(() {});
    }
  }
@override
Widget build(BuildContext context) {
  final notesData = Provider.of<NotesData>(context);
  final items = notesData.getNotesInFolder(widget.folderId);
  final currentTitle = widget.folderId == 'root'
      ? 'My Notes'
      : notesData.getItemById(widget.folderId)?.title ?? 'Notes';
  
  // Function to show delete confirmation dialog
  Future<void> _showDeleteDialog(String itemId, String itemTitle, bool isFolder) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${isFolder ? 'Folder' : 'Note'}'),
          content: Text('Are you sure you want to delete "$itemTitle"?' +
              (isFolder ? '\nThis will delete all contents inside the folder.' : '')),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',
                style: TextStyle(color: Colors.pink),
              ),
              onPressed: () {
                notesData.deleteItem(itemId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(currentTitle),
    ),
    body: GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            if (item.isFolder) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesScreen(folderId: item.id),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditScreen(noteId: item.id),
                ),
              );
            }
          },
          onLongPress: () {
            _showDeleteDialog(item.id, item.title, item.isFolder);
          },
          child: Card(
            color: Colors.white,
            elevation: 0.0,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.isFolder ? Icons.folder : Icons.note,
                    size: 100,
                    color: item.isFolder ? Colors.pink[100] : Colors.pink[200],
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showCreateDialog,
      backgroundColor: Colors.pink[100],
      child: Icon(Icons.add),
    ),
  );
}
}