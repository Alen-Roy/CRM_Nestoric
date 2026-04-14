import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final DateTime scheduledAt;
  const TaskCard({super.key, required this.task, required this.onToggle, required this.onDelete, required this.scheduledAt});
  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _drag = 0;
  static const double _max = 88;
  static final DateFormat _fmt = DateFormat('h:mm a');

  Color get _priorityColor {
    switch (widget.task.priority) {
      case 'High':  return AppColors.danger;
      case 'Low':   return AppColors.primaryGlow;
      default:      return AppColors.primaryMid;
    }
  }

  // Card bg — cycle through light purple shades
  Color _cardBg(int? index) => widget.task.isDone ? AppColors.background : AppColors.primaryLight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      onHorizontalDragUpdate: (d) => setState(() => _drag = (_drag + d.delta.dx).clamp(-_max, 0)),
      onHorizontalDragEnd: (d) => setState(() => _drag = _drag < -_max / 2 ? -_max : 0),
      child: Stack(children: [
        Positioned.fill(child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _drag.abs(),
            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(20)),
            child: _drag.abs() > 44
                ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    onPressed: () { setState(() => _drag = 0); widget.onDelete(); })
                : null,
          ),
        )),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(_drag, 0, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _cardBg(null),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _priorityColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(widget.task.priority, style: TextStyle(color: _priorityColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              Text(widget.task.title, style: TextStyle(
                color: widget.task.isDone ? AppColors.textLight : AppColors.textDark,
                fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3,
                decoration: widget.task.isDone ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textLight,
              ), maxLines: 2, overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Start', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
              const SizedBox(height: 3),
              Text(_fmt.format(widget.scheduledAt),
                  style: const TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: widget.task.isDone ? AppColors.primary.withOpacity(0.12) : AppColors.border,
                    shape: BoxShape.circle),
                  child: Icon(
                    widget.task.isDone ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                    color: widget.task.isDone ? AppColors.primary : AppColors.textLight,
                    size: 18),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
