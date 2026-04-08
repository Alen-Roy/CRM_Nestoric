import 'package:crm/models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Vertical timeline widget that renders a list of ActivityModels.
/// Used in LeadDetailPage to show call/meeting/note history.
class ActivityTimeline extends StatelessWidget {
  final List<ActivityModel> activities;
  final void Function(ActivityModel)? onDelete;

  const ActivityTimeline({
    super.key,
    required this.activities,
    this.onDelete,
  });

  Color _typeColor(ActivityType type) {
    switch (type) {
      case ActivityType.call:
        return const Color(0xFF4CAF50);
      case ActivityType.meeting:
        return const Color(0xFF2196F3);
      case ActivityType.email:
        return const Color(0xFFF44336);
      case ActivityType.proposal:
        return const Color(0xFF9C27B0);
      case ActivityType.note:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: const Text(
          'No activities logged yet.\nTap the + button below to log a call, meeting, or note.',
          style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.6),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        final isLast = index == activities.length - 1;
        final color = _typeColor(activity.type);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Timeline line + dot ──────────────────────────────────────
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          activity.type.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: Colors.white12,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Activity card ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                activity.type.label,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('d MMM, h:mm a')
                                  .format(activity.createdAt),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                            if (onDelete != null) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => onDelete!(activity),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white24,
                                  size: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (activity.outcome != null &&
                            activity.outcome!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            activity.outcome!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (activity.notes != null &&
                            activity.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            activity.notes!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
