import 'package:crm/core/constants/app_colors.dart';
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
  static final DateFormat _fullDayFormat = DateFormat('EEEE, MMM d');

  final List<DateTime> _dates = List.generate(60, (i) => DateTime.now().add(Duration(days: i)));

  List<TaskModel> _filteredTasks(List<TaskModel> tasks) {
    final sel = _dates[_selectedIndex];
    return tasks.where((t) =>
        t.scheduledAt.year == sel.year &&
        t.scheduledAt.month == sel.month &&
        t.scheduledAt.day == sel.day).toList();
  }

  String get _selectedDateLabel {
    if (_selectedIndex == 0) return 'Today';
    return _fullDayFormat.format(_dates[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => TaskAddPage(selectedDate: _dates[_selectedIndex])));
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Tasks', style: TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              DateSlider(dates: _dates, selectedIndex: _selectedIndex, onDateSelected: (i) => setState(() => _selectedIndex = i)),
              const SizedBox(height: 18),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: const TextStyle(color: AppColors.textMid, fontSize: 16, fontWeight: FontWeight.w600),
                child: Text(_selectedDateLabel),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: tasksAsync.when(
                  data: (tasks) {
                    final filtered = _filteredTasks(tasks);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                              child: const Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 36),
                            ),
                            const SizedBox(height: 16),
                            const Text('No tasks for this day', style: TextStyle(color: AppColors.textMid, fontSize: 15, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            const Text('Tap + to add a new task', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 4, bottom: 120),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        return TaskCard(
                          task: task,
                          scheduledAt: task.scheduledAt,
                          onToggle: () => ref.read(taskActionProvider.notifier).toggleTask(task),
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Task?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
                                content: const Text('Are you sure you want to delete this task?', style: TextStyle(color: AppColors.textMid)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMid)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      if (task.id != null) ref.read(taskActionProvider.notifier).deleteTask(task.id!);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.danger))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
