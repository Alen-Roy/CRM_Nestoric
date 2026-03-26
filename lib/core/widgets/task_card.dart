import 'package:crm/models/task_model.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final DateTime createdAt;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              task.isDone
                  ? Icons.check_box
                  : Icons.check_box_outline_blank_sharp,
              color: task.isDone ? Colors.greenAccent : Colors.white54,
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),

              style: TextStyle(
                color: task.isDone ? Colors.white30 : Colors.white60,
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.white30,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(task.title),
                  Text(
                    createdAt.hour.toString().padLeft(2, '0') +
                        ":" +
                        createdAt.minute.toString().padLeft(2, '0'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
