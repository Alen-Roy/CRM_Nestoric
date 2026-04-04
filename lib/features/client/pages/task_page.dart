import 'package:crm/core/widgets/date_slider.dart';
import 'package:crm/core/widgets/task_card.dart';
import 'package:crm/features/client/pages/task_add_page.dart';
import 'package:crm/models/task_model.dart';
import 'package:crm/viewmodels/task_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  int _selectedIndex = 0;
  static final DateFormat _fullDayFormat = DateFormat('EEEE');

  final List<DateTime> _dates = List.generate(
    60,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  List<TaskModel> _filteredTasks(List<TaskModel> tasks) {
    final selectedDate = _dates[_selectedIndex];
    return tasks.where((task) {
      return task.scheduledAt.year == selectedDate.year &&
          task.scheduledAt.month == selectedDate.month &&
          task.scheduledAt.day == selectedDate.day;
    }).toList();
  }

  void _onDateSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onTaskToggle(TaskModel task) {
    ref.read(tasksProvider.notifier).toggleTask(task);
  }

  String get _selectedDateLabel {
    if (_selectedIndex == 0) return 'Today';
    return _fullDayFormat.format(_dates[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final filtered = _filteredTasks(tasks);

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final newTask = await Navigator.push<TaskModel>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TaskAddPage(selectedDate: _dates[_selectedIndex]),
              ),
            );
            if (newTask != null) {
              ref.read(tasksProvider.notifier).addTask(newTask);
            }
          },
          backgroundColor: Colors.white12,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              DateSlider(
                dates: _dates,
                selectedIndex: _selectedIndex,
                onDateSelected: _onDateSelected,
              ),
              const SizedBox(height: 15),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                child: Text(_selectedDateLabel),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "No tasks for this day.",
                          style: TextStyle(color: Colors.white30, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final task = filtered[index];
                          return TaskCard(
                            task: task,
                            scheduledAt: task.scheduledAt,
                            onToggle: () => _onTaskToggle(task),
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text(
                                    'Delete Task?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Are you sure you want to delete this task?',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ref
                                            .read(tasksProvider.notifier)
                                            .deleteTask(task);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
