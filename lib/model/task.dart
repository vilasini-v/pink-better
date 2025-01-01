class Task {
  String id;
  String title;
  DateTime date;
  bool isCompleted;
  Priority priority;
  
  Task({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.priority = Priority.medium,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.toString(),
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'],
      priority: Priority.values.firstWhere(
        (e) => e.toString() == map['priority'],
      ),
    );
  }
}

enum Priority { high, medium, low }