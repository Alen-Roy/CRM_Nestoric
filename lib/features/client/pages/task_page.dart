import 'package:crm/core/widgets/date_slider.dart';
import 'package:crm/core/widgets/task_card.dart';
import 'package:crm/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  int _selectedIndex = 0;
  static final DateFormat _fullDayFormat = DateFormat('EEEE');

  final List<DateTime> _dates = List.generate(
    60,
    (i) => DateTime.now().add(Duration(days: i)),
  );
  List<TaskModel> get _filteredTasks {
    final selectedDate = _dates[_selectedIndex];
    return _tasks.where((task) {
      return task.createdAt.year == selectedDate.year &&
          task.createdAt.month == selectedDate.month &&
          task.createdAt.day == selectedDate.day;
    }).toList();
  }

  final List<TaskModel> _tasks = [
    TaskModel(title: 'Design the UI mockup', createdAt: DateTime.now()),
    TaskModel(title: 'Fix login bug', createdAt: DateTime(2026, 3, 29)),
    TaskModel(title: 'Write unit tests', createdAt: DateTime(2026, 3, 29)),
    TaskModel(title: 'Review pull requests', createdAt: DateTime(2026, 3, 29)),
  ];

  void _onDateSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onTaskToggle(int index) {
    setState(
      () => _filteredTasks[index].isDone = !_filteredTasks[index].isDone,
    );
  }

  String get _selectedDateLabel {
    if (_selectedIndex == 0) return 'Today';
    return _fullDayFormat.format(_dates[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 80),
        child: FloatingActionButton(
          onPressed: () {},
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
                'Task Page',
                style: TextStyle(color: Colors.white, fontSize: 24),
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
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                child: Text(_selectedDateLabel),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.separated(
                  itemCount: _filteredTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: _filteredTasks[index],
                      onToggle: () {
                        _onTaskToggle(index);
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
