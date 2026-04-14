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
  TimeOfDay _time  = TimeOfDay.now();
  String _priority = 'Medium';

  @override
  void initState() { super.initState(); _date = widget.selectedDate; }
  @override
  void dispose() { _titleCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  void _pickDate(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Date',
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.light,
                primaryColor: AppColors.primary,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                initialDateTime: _date,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (d) => setState(() => _date = d),
              ),
            ),
          ),
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
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textDark,
          ),
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
      scheduledAt: dt,
      priority: _priority,
      userId: user.uid,
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
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4)),
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textDark, size: 16),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('New Task',
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ]),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Task name ─────────────────────────────────────────
                    // FIX: use white background so purple text is clearly visible
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,             // ✅ white, not lavender
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(
                            color: AppColors.primary.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            const Text('Task Name',
                                style: TextStyle(
                                    color: AppColors.textMid,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleCtrl,
                            style: const TextStyle(
                              color: AppColors.textDark,      // ✅ dark text on white
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                              letterSpacing: -0.5,
                            ),
                            cursorColor: AppColors.primary,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'What do you need to do?',
                              hintStyle: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(top: 4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Date ──────────────────────────────────────────────
                    _pickerTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: dateStr,
                      color: AppColors.primary,
                      onTap: () => _pickDate(context),
                    ),
                    const SizedBox(height: 12),

                    // ── Time ──────────────────────────────────────────────
                    _pickerTile(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: timeStr,
                      color: AppColors.primaryGlow,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 16),

                    // ── Priority ──────────────────────────────────────────
                    _sectionCard(
                      title: 'Priority Level',
                      child: Row(children: [
                        _priorityChip('High',   AppColors.danger, '🔴'),
                        const SizedBox(width: 10),
                        _priorityChip('Medium', AppColors.warning, '🟡'),
                        const SizedBox(width: 10),
                        _priorityChip('Low',    AppColors.primary,       '🟢'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // ── Notes ──────────────────────────────────────────────
                    _sectionCard(
                      title: 'Notes (optional)',
                      child: TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        style: const TextStyle(
                            color: AppColors.textDark, fontSize: 14),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          hintText: 'Add any extra details...',
                          hintStyle: const TextStyle(
                              color: AppColors.textLight, fontSize: 14),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5)),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Save button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Save Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Picker tile ─────────────────────────────────────────────────────────────
  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
          ]),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
        ]),
      ),
    );
  }

  // ── Section card ────────────────────────────────────────────────────────────
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 5)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Divider(color: AppColors.border, height: 14),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  // ── Priority chip ────────────────────────────────────────────────────────────
  // FIX: use explicit, readable colours instead of pale purples for Medium
  Widget _priorityChip(String label, Color color, String emoji) {
    final isSel = _priority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? color.withOpacity(0.10) : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? color : AppColors.border,
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    color: isSel ? color : AppColors.textMid,
                    fontSize: 12,
                    fontWeight:
                        isSel ? FontWeight.w700 : FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
