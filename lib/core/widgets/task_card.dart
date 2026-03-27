import 'package:crm/models/task_model.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final DateTime createdAt;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.createdAt,
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
              child: ClipRRect(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _dragOffset.abs(),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _dragOffset.abs() > 40
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              setState(() => _dragOffset = 0);
                              widget.onDelete();
                            },
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  widget.task.isDone
                      ? Icons.check_box
                      : Icons.check_box_outline_blank_sharp,
                  color: widget.task.isDone
                      ? Colors.greenAccent
                      : Colors.white54,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.task.isDone
                          ? Colors.white30
                          : Colors.white60,
                      decoration: widget.task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.white30,
                    ),
                    child: Row(
                      children: [
                        Text(widget.task.title),
                        const Spacer(),
                        Text(
                          widget.createdAt.hour.toString().padLeft(2, '0') +
                              ":" +
                              widget.createdAt.minute.toString().padLeft(
                                2,
                                '0',
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
