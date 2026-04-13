import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class RecentActivity {
  final IconData icon;
  final String title;
  final String time;
  const RecentActivity({required this.icon, required this.title, required this.time});
}

class RecentActivitiesSection extends StatelessWidget {
  final List<RecentActivity> recentActivities;
  final ValueChanged<RecentActivity>? onActivityTap;
  final VoidCallback? onSeeAllTap;

  const RecentActivitiesSection({
    super.key, required this.recentActivities, this.onActivityTap, this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Recent Activities', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
        GestureDetector(onTap: onSeeAllTap,
            child: const Text('See all', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 14),
      if (recentActivities.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border)),
          child: const Center(child: Text('No recent activities', style: TextStyle(color: AppColors.textLight, fontSize: 14))),
        )
      else
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: recentActivities.asMap().entries.map((e) {
              final i = e.key; final a = e.value;
              final isLast = i == recentActivities.length - 1;
              final bg = i % 2 == 0 ? AppColors.surface : AppColors.primaryPale;
              return Column(children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                      top:    i == 0 ? const Radius.circular(22) : Radius.zero,
                      bottom: isLast ? const Radius.circular(22) : Radius.zero,
                    ),
                    onTap: onActivityTap == null ? null : () => onActivityTap!(a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.vertical(
                          top:    i == 0 ? const Radius.circular(22) : Radius.zero,
                          bottom: isLast ? const Radius.circular(22) : Radius.zero,
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                          child: Icon(a.icon, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600))),
                        const SizedBox(width: 8),
                        Text(a.time, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                        const SizedBox(width: 6),
                        const Icon(Symbols.chevron_right, color: AppColors.textLight, size: 16),
                      ]),
                    ),
                  ),
                ),
                if (!isLast) const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 68),
              ]);
            }).toList(),
          ),
        ),
    ]);
  }
}
