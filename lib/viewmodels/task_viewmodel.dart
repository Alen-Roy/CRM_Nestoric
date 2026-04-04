import 'package:crm/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskNotifier extends Notifier<List<TaskModel>> {
  @override
  List<TaskModel> build() => [
    TaskModel(title: 'Call A Client', scheduledAt: DateTime.now()),
    TaskModel(title: 'Send A Proposal', scheduledAt: DateTime(2026, 3, 29)),
  ];

  void addTask(TaskModel task) {
    state = [...state, task];
  }

  void toggleTask(TaskModel task) {
    state = state.map((t) {
      if (t == task) {
        t.isDone = !t.isDone;
        return t;
      }
      return t;
    }).toList();
  }

  void deleteTask(TaskModel task) {
    state = state.where((t) => t != task).toList();
  }
}

final tasksProvider = NotifierProvider<TaskNotifier, List<TaskModel>>(
  TaskNotifier.new,
);
