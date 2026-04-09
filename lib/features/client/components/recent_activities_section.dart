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
    super.key,
    required this.recentActivities,
    this.onActivityTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Activities',
                style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: onSeeAllTap,
              child: const Text(
                'See All',
                style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentActivities.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('No recent activities', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: List.generate(recentActivities.length, (index) {
                final activity = recentActivities[index];
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onActivityTap == null ? null : () => onActivityTap!(activity),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(activity.icon, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(activity.time, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Symbols.chevron_right, color: AppColors.textLight, size: 18),
                          ],
                        ),
                      ),
                    ),
                    if (index != recentActivities.length - 1)
                      const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 14, endIndent: 14),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }
}
