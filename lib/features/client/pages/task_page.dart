import 'package:crm/core/constants/app_colors.dart';
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
  static final DateFormat _dayFormat     = DateFormat('d');
  static final DateFormat _dayNameFormat = DateFormat('EEE');
  static final DateFormat _fullFormat    = DateFormat('EEEE, MMM d');
  static final DateFormat _timeFormat    = DateFormat('hh:mm a');

  final List<DateTime> _dates =
      List.generate(60, (i) => DateTime.now().add(Duration(days: i)));

  // Tasks exactly on the selected calendar day
  List<TaskModel> _tasksForDay(List<TaskModel> all, DateTime day) {
    return all
        .where((t) =>
            t.scheduledAt.year  == day.year &&
            t.scheduledAt.month == day.month &&
            t.scheduledAt.day   == day.day)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Overdue = not done AND scheduled strictly before today's midnight
  List<TaskModel> _overdueTasks(List<TaskModel> all) {
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return all
        .where((t) => !t.isDone && t.scheduledAt.isBefore(todayStart))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  String get _selectedDateLabel {
    if (_selectedIndex == 0) return 'Today';
    return _fullFormat.format(_dates[_selectedIndex]);
  }

  // Card color scheme — cycles through 3 variants
  _CardScheme _scheme(int index, bool isDone) {
    if (isDone) {
      return const _CardScheme(
        bg: AppColors.background, fg: AppColors.textLight,
        tag: AppColors.textLight, tagBg: AppColors.border);
    }
    final schemes = [
      const _CardScheme(bg: AppColors.primaryLight, fg: AppColors.primary,  tag: AppColors.primary,  tagBg: AppColors.primarySoft),
      const _CardScheme(bg: AppColors.surface,      fg: AppColors.textDark, tag: AppColors.textMid,  tagBg: AppColors.primaryPale),
      const _CardScheme(bg: AppColors.primaryPale,  fg: AppColors.primaryMid,tag: AppColors.primaryMid,tagBg: AppColors.primaryLight),
    ];
    return schemes[index % schemes.length];
  }

  // Danger-tinted scheme for overdue tasks (light red only)
  _CardScheme _overdueScheme(int index) {
    return _CardScheme(
      bg:    AppColors.dangerLight,
      fg:    AppColors.danger,
      tag:   AppColors.danger,
      tagBg: AppColors.danger.withValues(alpha: 0.12),
    );
  }

  void _confirmDelete(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task?',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        content: Text('"${task.title}" will be removed.',
            style: const TextStyle(color: AppColors.textMid)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMid))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (task.id != null) {
                ref.read(taskActionProvider.notifier).deleteTask(task.id!);
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────────
                  Row(children: [
                    const Text('Tasks',
                        style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                    const Spacer(),
                    _iconBtn(Icons.calendar_today_outlined, () {}),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TaskAddPage(selectedDate: _dates[_selectedIndex])),
                      ),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Date tabs ───────────────────────────────────────────
                  SizedBox(
                    height: 76,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final isSel = _selectedIndex == i;
                        final d     = _dates[i];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 54,
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: isSel ? null : Border.all(color: AppColors.border),
                              boxShadow: isSel
                                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                                  : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 6)],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _dayNameFormat.format(d).toUpperCase(),
                                  style: TextStyle(
                                      color: isSel ? Colors.white.withValues(alpha: 0.8) : AppColors.textLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _dayFormat.format(d),
                                  style: TextStyle(
                                      color: isSel ? Colors.white : AppColors.textDark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stats banner ────────────────────────────────────────────
            tasksAsync.when(
              data: (tasks) => _StatsBanner(tasks: tasks),
              loading: () => const _StatsBanner(tasks: []),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2)),
                error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: const TextStyle(color: AppColors.danger))),
                data: (allTasks) {
                  // Overdue shown only on Today tab
                  final overdue =
                      _selectedIndex == 0 ? _overdueTasks(allTasks) : <TaskModel>[];
                  final dayTasks =
                      _tasksForDay(allTasks, _dates[_selectedIndex]);

                  if (overdue.isEmpty && dayTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(24)),
                            child: const Icon(Icons.task_alt_rounded,
                                color: AppColors.primary, size: 40),
                          ),
                          const SizedBox(height: 16),
                          const Text('No tasks for this day',
                              style: TextStyle(
                                  color: AppColors.textMid,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text('Tap + to add a new task',
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── OVERDUE SECTION (Today only) ────────────────
                        if (overdue.isNotEmpty) ...[
                          // Header
                          Row(children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.danger, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text('Overdue',
                                style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text('${overdue.length}',
                                  style: const TextStyle(
                                      color: AppColors.danger,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ]),
                          const SizedBox(height: 12),

                          // Overdue task cards
                          ...overdue.asMap().entries.map((e) {
                            final task   = e.value;
                            final scheme = _overdueScheme(e.key);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PremiumTaskCard(
                                task: task,
                                scheme: scheme,
                                timeLabel: _timeFormat.format(task.scheduledAt),
                                overdueLabel: _overdueLabel(task.scheduledAt),
                                onToggle: () => ref
                                    .read(taskActionProvider.notifier)
                                    .toggleTask(task),
                                onDelete: () => _confirmDelete(context, task),
                              ),
                            );
                          }),

                          if (dayTasks.isNotEmpty) const SizedBox(height: 8),
                        ],

                        // ── SELECTED DAY SECTION ───────────────────────
                        if (dayTasks.isNotEmpty) ...[
                          // Header
                          Row(children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _selectedDateLabel,
                                key: ValueKey(_selectedIndex),
                                style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text('${dayTasks.length}',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TaskAddPage(
                                        selectedDate: _dates[_selectedIndex])),
                              ),
                              child: Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(9)),
                                child: const Icon(Icons.add,
                                    color: AppColors.primary, size: 18),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),

                          ...dayTasks.asMap().entries.map((e) {
                            final task   = e.value;
                            final scheme = _scheme(e.key, task.isDone);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PremiumTaskCard(
                                task: task,
                                scheme: scheme,
                                timeLabel: _timeFormat.format(task.scheduledAt),
                                onToggle: () => ref
                                    .read(taskActionProvider.notifier)
                                    .toggleTask(task),
                                onDelete: () => _confirmDelete(context, task),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // e.g. "3 days ago", "Yesterday"
  String _overdueLabel(DateTime dt) {
    final days = DateTime.now().difference(dt).inDays;
    if (days == 0) return 'Due today (missed)';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: AppColors.textDark, size: 20),
      ),
    );
  }
}

// ── Card Scheme ───────────────────────────────────────────────────────────────
class _CardScheme {
  final Color bg, fg, tag, tagBg;
  const _CardScheme({required this.bg, required this.fg, required this.tag, required this.tagBg});
}

// ── Premium Task Card ─────────────────────────────────────────────────────────
class _PremiumTaskCard extends StatelessWidget {
  final TaskModel task;
  final _CardScheme scheme;
  final String timeLabel;
  final String? overdueLabel; // only set for overdue cards
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _PremiumTaskCard({
    required this.task,
    required this.scheme,
    required this.timeLabel,
    this.overdueLabel,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: scheme.bg.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority or overdue tag
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: scheme.tagBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(task.priority,
                          style: TextStyle(
                              color: scheme.tag,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    if (overdueLabel != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(overdueLabel!,
                            style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 10),
                  // Title — big display text
                  Text(
                    task.title,
                    style: TextStyle(
                      color: scheme.fg,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                      decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: scheme.fg.withValues(alpha: 0.5),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Time + toggle
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Start',
                    style: TextStyle(
                        color: scheme.fg.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(timeLabel,
                    style: TextStyle(
                        color: scheme.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: scheme.fg.withValues(alpha: 0.15),
                        shape: BoxShape.circle),
                    child: Icon(
                      task.isDone
                          ? Icons.check_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: scheme.fg,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Banner ──────────────────────────────────────────────────────────────
class _StatsBanner extends StatelessWidget {
  final List<TaskModel> tasks;
  const _StatsBanner({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total     = tasks.length;
    final done      = tasks.where((t) => t.isDone).length;
    final today     = DateTime.now();
    final todayCount = tasks.where((t) =>
        t.scheduledAt.year  == today.year &&
        t.scheduledAt.month == today.month &&
        t.scheduledAt.day   == today.day).length;
    final overdueCount = tasks.where((t) {
      final start = DateTime(today.year, today.month, today.day);
      return !t.isDone && t.scheduledAt.isBefore(start);
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 5)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All time overview',
                style: TextStyle(
                    color: AppColors.textMid,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Row(children: [
              _statBox('$total',        'Total',     AppColors.primaryLight, AppColors.primary),
              const SizedBox(width: 10),
              _statBox('$done',         'Done',      AppColors.primaryLight, AppColors.primary),
              const SizedBox(width: 10),
              _statBox('$todayCount',   "Today's",   AppColors.primary,     Colors.white),
              const SizedBox(width: 10),
              _statBox('$overdueCount', 'Overdue',
                overdueCount > 0 ? AppColors.danger.withValues(alpha: 0.15) : AppColors.border,
                overdueCount > 0 ? AppColors.danger : AppColors.textLight,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(value, style: TextStyle(color: fg, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
