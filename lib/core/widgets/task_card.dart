import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/task_model.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final DateTime scheduledAt;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.scheduledAt,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _dragOffset = 0;
  static const double _maxReveal = 80;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dx).clamp(-_maxReveal, 0);
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _dragOffset = _dragOffset < -_maxReveal / 2 ? -_maxReveal : 0;
        });
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _dragOffset.abs(),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _dragOffset.abs() > 40
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          setState(() => _dragOffset = 0);
                          widget.onDelete();
                        },
                      )
                    : null,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  widget.task.isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: widget.task.isDone
                      ? AppColors.success
                      : AppColors.textLight,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.task.isDone
                          ? AppColors.textLight
                          : AppColors.textDark,
                      decoration: widget.task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textLight,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(widget.task.title)),
                        Text(
                          '${widget.scheduledAt.hour.toString().padLeft(2, '0')}:${widget.scheduledAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
