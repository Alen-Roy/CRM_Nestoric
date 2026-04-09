import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityTimeline extends StatelessWidget {
  final List<ActivityModel> activities;
  final void Function(ActivityModel)? onDelete;

  const ActivityTimeline({super.key, required this.activities, this.onDelete});

  Color _typeColor(ActivityType type) {
    switch (type) {
      case ActivityType.call:     return AppColors.success;
      case ActivityType.meeting:  return AppColors.secondary;
      case ActivityType.email:    return AppColors.danger;
      case ActivityType.proposal: return AppColors.primary;
      case ActivityType.note:     return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No activities logged yet.\nTap the + button below to log a call, meeting, or note.',
          style: TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.6),
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
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Center(
                        child: Text(activity.type.emoji, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: AppColors.border,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activity.type.label,
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('d MMM, h:mm a').format(activity.createdAt),
                              style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                            ),
                            if (onDelete != null) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => onDelete!(activity),
                                child: const Icon(Icons.close, color: AppColors.textLight, size: 14),
                              ),
                            ],
                          ],
                        ),
                        if (activity.outcome != null && activity.outcome!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            activity.outcome!,
                            style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                        if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            activity.notes!,
                            style: const TextStyle(color: AppColors.textMid, fontSize: 12, height: 1.4),
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
