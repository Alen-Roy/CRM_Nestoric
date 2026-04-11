import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/task_model.dart';
import 'package:crm/viewmodels/task_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TaskAddPage extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const TaskAddPage({super.key, required this.selectedDate});
  @override
  ConsumerState<TaskAddPage> createState() => _TaskAddPageState();
}

class _TaskAddPageState extends ConsumerState<TaskAddPage> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late DateTime _date;
  TimeOfDay _time     = TimeOfDay.now();
  String _priority    = 'Medium';

  @override
  void initState() { super.initState(); _date = widget.selectedDate; }
  @override
  void dispose() { _titleCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  void _pickDate(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Select Date', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 16)),
              CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.pop(context),
                  child: const Text('Done', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
            ]),
          ),
          Expanded(child: CupertinoTheme(
            data: const CupertinoThemeData(primaryColor: AppColors.primary),
            child: CupertinoDatePicker(
              initialDateTime: _date,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (d) => setState(() => _date = d),
            ),
          )),
        ]),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: AppColors.surface, onSurface: AppColors.textDark),
          dialogBackgroundColor: AppColors.surface,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    await ref.read(taskActionProvider.notifier).addTask(TaskModel(
      title: _titleCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      scheduledAt: dt, priority: _priority, userId: user.uid,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(_date);
    final timeStr = _time.format(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
                    child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 16),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('New Task', style: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800)),
              ]),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Task name — big input ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Task Name', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                        TextField(
                          controller: _titleCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.3),
                          cursorColor: Colors.white,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Add task name...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 28, fontWeight: FontWeight.w800),
                            border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: 8),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // ── Date + Time row ─────────────────────────────────────
                    Row(children: [
                      Expanded(child: _pickerTile(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: dateStr,
                        color: AppColors.primary,
                        onTap: () => _pickDate(context),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _pickerTile(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: timeStr,
                        color: AppColors.secondary,
                        onTap: _pickTime,
                      )),
                    ]),
                    const SizedBox(height: 16),

                    // ── Priority ────────────────────────────────────────────
                    _sectionCard(
                      title: 'Priority',
                      child: Row(children: [
                        _priorityChip('High',   AppColors.danger),
                        const SizedBox(width: 10),
                        _priorityChip('Medium', AppColors.warning),
                        const SizedBox(width: 10),
                        _priorityChip('Low',    AppColors.success),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // ── Notes ───────────────────────────────────────────────
                    _sectionCard(
                      title: 'Notes (optional)',
                      child: TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          hintText: 'Add any extra details...',
                          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                          filled: true, fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Save button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    child: const Text('Save Task', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerTile({required IconData icon, required String label, required String value, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2),
        ]),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _priorityChip(String label, Color color) {
    final isSel = _priority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? color.withOpacity(0.12) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? color : AppColors.border, width: isSel ? 1.5 : 1),
          ),
          child: Center(child: Text(label, style: TextStyle(color: isSel ? color : AppColors.textMid, fontSize: 13, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500))),
        ),
      ),
    );
  }
}
