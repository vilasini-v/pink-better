// models/note_item.dart
class NoteItem {
  String id;
  String title;
  String? content;
  bool isFolder;
  List<String> children;
  DateTime createdAt;

  NoteItem({
    required this.id,
    required this.title,
    this.content,
    required this.isFolder,
    List<String>? children,
    DateTime? createdAt,
  })  : this.children = children ?? [],
        this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isFolder': isFolder,
      'children': children,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static NoteItem fromMap(Map<String, dynamic> map) {
    return NoteItem(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isFolder: map['isFolder'],
      children: List<String>.from(map['children'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}