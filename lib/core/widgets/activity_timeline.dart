import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityTimeline extends StatelessWidget {
  final List<ActivityModel> activities;
  final void Function(ActivityModel)? onDelete;
  const ActivityTimeline({super.key, required this.activities, this.onDelete});

  Color _typeColor(ActivityType t) {
    switch (t) {
      case ActivityType.call:     return AppColors.primary;
      case ActivityType.meeting:  return AppColors.primaryGlow;
      case ActivityType.email:    return AppColors.danger;
      case ActivityType.proposal: return AppColors.primaryMid;
      case ActivityType.note:     return AppColors.primarySoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.primaryPale, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          Container(width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 26)),
          const SizedBox(height: 12),
          const Text('No activities yet', style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Tap + Log Activity to add one', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
        ]),
      );
    }

    return Column(
      children: activities.asMap().entries.map((e) {
        final index = e.key; final activity = e.value;
        final isLast = index == activities.length - 1;
        final color  = _typeColor(activity.type);
        // Alternating: white / primaryPale / primaryLight
        final bg = index % 3 == 0 ? AppColors.surface
                 : index % 3 == 1 ? AppColors.primaryPale
                 : AppColors.primaryLight;

        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 36, child: Column(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5)),
                child: Icon(activity.type.icon, color: color, size: 16),
              ),
              if (!isLast) Expanded(child: Container(
                width: 2, margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), AppColors.border],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              )),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(activity.type.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Text(DateFormat('d MMM · h:mm a').format(activity.createdAt),
                        style: const TextStyle(color: AppColors.textLight, fontSize: 10)),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onDelete!(activity),
                        child: Container(width: 22, height: 22,
                          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(7)),
                          child: const Icon(Icons.close, color: AppColors.textLight, size: 13)),
                      ),
                    ],
                  ]),
                  if (activity.outcome?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(activity.outcome!, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                  if (activity.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(activity.notes!, style: const TextStyle(color: AppColors.textMid, fontSize: 12, height: 1.4)),
                  ],
                ]),
              ),
            )),
          ]),
        );
      }).toList(),
    );
  }
}
