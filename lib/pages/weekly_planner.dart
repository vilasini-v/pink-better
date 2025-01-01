import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../date_time/date_time_helper.dart';
import '../model/task.dart';
import '../data/task_data.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  Priority _selectedPriority = Priority.medium;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 7,
        vsync: this,
        initialIndex: DateTime.now().weekday - 1
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskData>(context, listen: false).prepareData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  String _getPriorityLabel(Priority priority) {
    return priority.toString().split('.').last.toUpperCase();
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      final taskData = Provider.of<TaskData>(context, listen: false);
      final newTask = Task(
        id: DateTime.now().toString(),
        title: _titleController.text,
        priority: _selectedPriority,
        date: _selectedDate,
      );

      taskData.addNewTask(newTask);
      _titleController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Task'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<Priority>(
                value: _selectedPriority,
                decoration: InputDecoration(labelText: 'Priority'),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getPriorityColor(priority),
                          ),
                        ),
                        Text(_getPriorityLabel(priority)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPriority = value!);
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Date'),
                subtitle: Text(convertDateTimetoStringTask(_selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: Text('Weekly Planner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: List.generate(7, (index) {
            final date = Provider.of<TaskData>(context, listen: false)
                .startOfWeekDate()
                .add(Duration(days: index));
            return Tab(text: Provider.of<TaskData>(context, listen: false).getDayName(date));
          }),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              final stats = Provider.of<TaskData>(context, listen: false).getWeeklyStatistics();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Weekly Statistics'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Tasks: ${stats['total']}'),
                    Text('Completed: ${stats['completed']}'),
                    Text('Remaining: ${stats['remaining']}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              ),
            );},
          ),
        ],
      ),
      body: Consumer<TaskData>(
        builder: (context, taskData, child) {
          return TabBarView(
            controller: _tabController,
            children: List.generate(7, (index) {
              final currentDate = taskData.startOfWeekDate().add(Duration(days: index));
              final tasksForDay = taskData.weeklyTasks.where((task) =>
              task.date.year == currentDate.year &&
                  task.date.month == currentDate.month &&
                  task.date.day == currentDate.day
              ).toList();

              return tasksForDay.isEmpty
                  ? Center(child: Text('No tasks for this day'))
                  : ListView.builder(
                itemCount: tasksForDay.length,
                itemBuilder: (context, index) {
                  final task = tasksForDay[index];
                  return Dismissible(
                    key: Key(task.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => taskData.deleteTask(task),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => taskData.toggleTaskCompletion(task.id),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${convertDateTimetoStringTask(task.date)} • ${_getPriorityLabel(task.priority)}',
                      ),
                      trailing: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink[100],
      ),
    );
  }
}