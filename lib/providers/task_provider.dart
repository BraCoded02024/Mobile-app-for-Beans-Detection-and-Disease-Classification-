import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Mobile App UI Design',
      description: 'Create a modern UI for the task manager app.',
      deadline: DateTime(2024, 6, 10),
      isCompleted: false,
    ),
  ];

  TaskFilter _filter = TaskFilter.all;
  TaskFilter get filter => _filter;

  List<Task> get tasks {
    if (_filter == TaskFilter.completed) {
      return _tasks.where((t) => t.isCompleted).toList();
    } else if (_filter == TaskFilter.pending) {
      return _tasks.where((t) => !t.isCompleted).toList();
    }
    return [..._tasks];
  }

  void addTask(String title, String description, DateTime deadline) {
    final newTask = Task(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      deadline: deadline,
    );
    _tasks.insert(0, newTask);
    notifyListeners();
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleStatus(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void updateTask(String id, String title, String description, DateTime deadline) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index].title = title;
      _tasks[index].description = description;
      _tasks[index].deadline = deadline;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }
}
class UserProvider extends ChangeNotifier {
  String? _username;

  String? get username => _username;

  void setUsername(String username) {
    _username = username;
    notifyListeners(); // tells all listening widgets to rebuild
  }
}