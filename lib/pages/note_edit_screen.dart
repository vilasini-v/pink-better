import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newpapp/model/note.dart';
import 'package:newpapp/data/notes_data.dart';

class NoteEditScreen extends StatefulWidget {
  final String noteId;

  const NoteEditScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _contentController;
  late NoteItem note;
@override
void initState() {
  super.initState();
  final notesData = Provider.of<NotesData>(context, listen: false);
  note = notesData.getItemById(widget.noteId) ?? 
         NoteItem(id: widget.noteId, title: 'Untitled', isFolder: false);
  _contentController = TextEditingController(text: note.content ?? '');
}
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final notesData = Provider.of<NotesData>(context, listen: false);
    notesData.updateNoteContent(note.id, _contentController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Start typing...',
          ),
        ),
      ),
    );
  }
}
