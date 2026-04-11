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

  // Alternate card schemes
  _CardScheme _scheme(int index) {
    final schemes = [
      const _CardScheme(bg: AppColors.cardDark,    text: Colors.white,      sub: Colors.white60),
      const _CardScheme(bg: AppColors.surface,     text: AppColors.textDark, sub: AppColors.textMid),
      const _CardScheme(bg: AppColors.primaryLight, text: AppColors.primary,  sub: AppColors.textMid),
    ];
    return schemes[index % schemes.length];
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
        ),
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('No activities yet', style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Tap + Log Activity to add one', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
        ]),
      );
    }

    return Column(
      children: activities.asMap().entries.map((entry) {
        final index    = entry.key;
        final activity = entry.value;
        final isLast   = index == activities.length - 1;
        final color    = _typeColor(activity.type);
        final scheme   = _scheme(index);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Timeline spine ──────────────────────────────────────────
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Center(child: Text(activity.type.emoji, style: const TextStyle(fontSize: 14))),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withValues(alpha: 0.4), AppColors.border],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── Activity card ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.bg,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.bg.withValues(alpha: scheme.bg == AppColors.cardDark ? 0.3 : 0.06),
                          blurRadius: 12, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top row: label + time + delete ───────────────
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: scheme.bg == AppColors.cardDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(activity.type.label,
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('d MMM · h:mm a').format(activity.createdAt),
                            style: TextStyle(color: scheme.sub, fontSize: 10),
                          ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => onDelete!(activity),
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.close, color: scheme.sub, size: 13),
                              ),
                            ),
                          ],
                        ]),

                        // ── Outcome ────────────────────────────────────────
                        if (activity.outcome != null && activity.outcome!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(activity.outcome!,
                              style: TextStyle(color: scheme.text, fontSize: 14, fontWeight: FontWeight.w700, height: 1.3)),
                        ],

                        // ── Notes ──────────────────────────────────────────
                        if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(activity.notes!,
                              style: TextStyle(color: scheme.sub, fontSize: 12, height: 1.5)),
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

class _CardScheme {
  final Color bg, text, sub;
  const _CardScheme({required this.bg, required this.text, required this.sub});
}
